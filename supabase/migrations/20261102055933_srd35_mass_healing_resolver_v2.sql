-- Dedicated SRD 3.5 mass-healing resolver.
-- Supports living healing and positive-energy damage against undead tokens.
CREATE OR REPLACE FUNCTION public.conjurar_magia_srd_multialvo_v2(
  p_character_id text,
  p_spell_id text,
  p_slot_level smallint,
  p_target_token_keys text[]
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public','pg_temp'
AS $function$
DECLARE
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_spell record;
  v_campaign_id bigint;
  v_doc jsonb;
  v_state jsonb;
  v_prepared jsonb;
  v_class text;
  v_level integer;
  v_score integer;
  v_idx integer;
  v_capacity integer;
  v_slot_total integer;
  v_slots_remaining integer;
  v_prepared_idx integer;
  v_cba_data jsonb;
  v_tokens jsonb;
  v_token jsonb;
  v_token_count integer;
  v_token_index bigint;
  v_key text;
  v_target_type text;
  v_target_character_id text;
  v_hp integer;
  v_max_hp integer;
  v_healing integer;
  v_roll integer;
  v_die_count integer;
  v_die_size integer;
  v_dice text;
  v_per_level integer;
  v_max_level integer;
  v_is_undead boolean;
  v_targets jsonb := '[]'::jsonb;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória'; END IF;
  IF p_target_token_keys IS NULL OR cardinality(p_target_token_keys) NOT BETWEEN 1 AND 20 THEN
    RAISE EXCEPTION 'Informe entre 1 e 20 tokens-alvo';
  END IF;
  IF EXISTS (
    SELECT 1 FROM (
      SELECT btrim(k) AS key,count(*) AS n
      FROM unnest(p_target_token_keys) k
      GROUP BY btrim(k)
    ) d WHERE d.n>1 OR NULLIF(d.key,'') IS NULL
  ) THEN
    RAISE EXCEPTION 'Tokens-alvo inválidos ou duplicados';
  END IF;

  SELECT ch.campaign_id INTO v_campaign_id
  FROM public.characters ch
  WHERE ch.id::text=btrim(p_character_id) AND ch.user_id=auth.uid()
  FOR UPDATE;
  IF NOT FOUND OR v_campaign_id IS NULL THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem campanha autorizada';
  END IF;

  SELECT s.* INTO v_sheet
  FROM public.srd_character_sheets s
  WHERE s.character_id::text=btrim(p_character_id)
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada'; END IF;

  v_doc:=to_jsonb(v_sheet);
  SELECT public._srd35_class_key(cl.nome) INTO v_class
  FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe SRD incompatível'; END IF;
  v_level:=v_sheet.nivel;
  IF v_level IS NULL OR v_level NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Nível inválido'; END IF;
  v_score:=CASE v_class
    WHEN 'wizard' THEN public._srd35_attr(v_doc,ARRAY['INT','inteligencia','intelligence'])::integer
    WHEN 'sorcerer' THEN public._srd35_attr(v_doc,ARRAY['CAR','carisma','charisma','cha'])::integer
    ELSE public._srd35_attr(v_doc,ARRAY['SAB','sabedoria','wisdom','wis'])::integer
  END;
  IF v_score IS NULL OR v_score<1 THEN RAISE EXCEPTION 'Atributo-chave inválido'; END IF;

  SELECT sp.* INTO v_spell FROM public.srd_spells sp WHERE sp.id=p_spell_id;
  IF NOT FOUND OR coalesce(v_spell.dados_tecnicos->>'tipo_efeito','')<>'cura'
     OR coalesce(v_spell.dados_tecnicos->>'target_mode','')<>'multiple_targets_pending'
  THEN
    RAISE EXCEPTION 'Magia não é uma cura SRD de múltiplos alvos';
  END IF;
  IF p_slot_level IS NULL OR p_slot_level<>v_spell.circulo THEN
    RAISE EXCEPTION 'O espaço deve corresponder ao círculo da magia';
  END IF;
  IF NOT public._srd35_spell_class_ok(v_spell.classes,v_class) THEN
    RAISE EXCEPTION 'Magia não disponível para a classe';
  END IF;
  IF coalesce((SELECT (slots_by_level->(v_level-1)->>v_spell.circulo)::integer
               FROM public.srd_spell_progressions WHERE class_key=v_class),0)<=0
     OR v_score<10+v_spell.circulo
  THEN
    RAISE EXCEPTION 'Nível de magia, espaço ou atributo insuficiente';
  END IF;

  v_state:=coalesce(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
  v_prepared:=coalesce(v_state->'preparadas','[]'::jsonb);
  SELECT (e.ord-1)::integer INTO v_prepared_idx
  FROM jsonb_array_elements(v_prepared) WITH ORDINALITY e(value,ord)
  WHERE e.value->>'spell_id'=p_spell_id
    AND (e.value->>'slot_level')::integer=p_slot_level
    AND coalesce((e.value->>'expended')::boolean,false)=false
  ORDER BY e.ord LIMIT 1;
  IF v_prepared_idx IS NULL THEN RAISE EXCEPTION 'Nenhum espaço preparado disponível'; END IF;
  v_prepared:=jsonb_set(v_prepared,ARRAY[v_prepared_idx::text,'expended'],'true'::jsonb,true);
  SELECT count(*)::integer INTO v_slots_remaining
  FROM jsonb_array_elements(v_prepared) e(value)
  WHERE (e.value->>'slot_level')::integer=p_slot_level
    AND coalesce((e.value->>'expended')::boolean,false)=false;
  v_slot_total:=public._srd35_slots(v_class,v_level,v_score,p_slot_level);

  SELECT c.cba_data INTO v_cba_data FROM public.campaigns c WHERE c.id=v_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada'; END IF;
  v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array' THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;
  v_dice:=coalesce(v_spell.dados_tecnicos->'cura'->>'dados','');
  IF v_dice ~ '^[0-9]+d[0-9]+([+-][0-9]+)?$' THEN
    v_die_count:=split_part(v_dice,'d',1)::integer;
    v_die_size:=regexp_replace(split_part(v_dice,'d',2),'[+-].*$','')::integer;
  ELSIF v_dice ~ '^[0-9]+$' THEN
    v_die_count:=0; v_die_size:=0;
  ELSE RAISE EXCEPTION 'Expressão de cura inválida'; END IF;
  v_per_level:=coalesce((v_spell.dados_tecnicos->'cura'->>'por_nivel')::integer,0);
  v_max_level:=coalesce((v_spell.dados_tecnicos->'cura'->>'max_nivel')::integer,0);

  FOREACH v_key IN ARRAY p_target_token_keys LOOP
    SELECT count(*)::integer,min(e.ordinality),min(e.token->>'tipo'),
           min(e.token->>'id'),bool_or(coalesce(e.token->'monsterStats'->>'tipo','') ILIKE '%undead%')
      INTO v_token_count,v_token_index,v_target_type,v_target_character_id,v_is_undead
    FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
    WHERE e.token->>'key'=btrim(v_key);
    IF v_token_count<>1 THEN RAISE EXCEPTION 'Token-alvo não encontrado ou duplicado: %',v_key; END IF;
    SELECT e.token INTO v_token FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
    WHERE e.token->>'key'=btrim(v_key) LIMIT 1;

    IF v_die_count>0 THEN
      v_roll:=0;
      FOR v_idx IN 1..v_die_count LOOP v_roll:=v_roll+floor(random()*v_die_size)::integer+1; END LOOP;
      IF substring(v_dice from '([+-][0-9]+)$') IS NOT NULL THEN
        v_roll:=v_roll+substring(v_dice from '([+-][0-9]+)$')::integer;
      END IF;
    ELSE v_roll:=v_dice::integer; END IF;
    v_healing:=greatest(0,v_roll+v_per_level*CASE WHEN v_max_level>0 THEN least(v_level,v_max_level) ELSE v_level END);

    IF v_target_type='player' THEN
      IF v_is_undead THEN RAISE EXCEPTION 'Personagem jogador não pode ser classificado como morto-vivo'; END IF;
      SELECT sh.pv_atual,sh.pv_max INTO v_hp,v_max_hp
      FROM public.characters ch JOIN public.srd_character_sheets sh ON sh.character_id::text=ch.id::text
      WHERE ch.id::text=v_target_character_id AND ch.campaign_id=v_campaign_id
      FOR UPDATE OF sh;
      IF NOT FOUND THEN RAISE EXCEPTION 'Ficha do alvo não encontrada: %',v_key; END IF;
      v_hp:=least(v_max_hp,greatest(0,coalesce(v_hp,0)+v_healing));
      UPDATE public.srd_character_sheets SET pv_atual=v_hp WHERE character_id::text=v_target_character_id;
    ELSE
      IF coalesce(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$'
         OR coalesce(v_token->>'hp','') !~ '^[0-9]{1,6}$'
      THEN RAISE EXCEPTION 'Token sem HP válido: %',v_key; END IF;
      v_max_hp:=(v_token->>'maxHp')::integer;
      v_hp:=CASE WHEN v_is_undead
                 THEN greatest(0,(v_token->>'hp')::integer-v_healing)
                 ELSE least(v_max_hp,greatest(0,(v_token->>'hp')::integer+v_healing)) END;
    END IF;
    v_token:=v_token||jsonb_build_object('hp',v_hp,'maxHp',v_max_hp);
    v_tokens:=jsonb_set(v_tokens,ARRAY[(v_token_index-1)::text],v_token,false);
    v_targets:=v_targets||jsonb_build_array(jsonb_build_object(
      'token_key',btrim(v_key),
      'healing',CASE WHEN v_is_undead THEN -v_healing ELSE v_healing END,
      'pv_atual',v_hp,'undead',v_is_undead
    ));
  END LOOP;

  v_cba_data:=coalesce(v_cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens);
  UPDATE public.campaigns SET cba_data=v_cba_data WHERE id=v_campaign_id;
  v_state:=jsonb_build_object('version',1,'conhecidas',coalesce(v_state->'conhecidas','[]'::jsonb),
    'preparadas',v_prepared,'dominio_preparadas',coalesce(v_state->'dominio_preparadas','[]'::jsonb),'usos',coalesce(v_state->'usos','{}'::jsonb));
  UPDATE public.srd_character_sheets SET magias_preparadas=v_state WHERE character_id::text=btrim(p_character_id);
  RETURN jsonb_build_object('estado',v_state,'cba_data',v_cba_data,'targets',v_targets,
    'target_count',cardinality(p_target_token_keys),'multiple_targets',true,
    'slots_total',v_slot_total,'slots_remaining',v_slots_remaining);
END;
$function$;

CREATE OR REPLACE FUNCTION public.conjurar_magia_com_acao_srd_multialvo_v2(
  p_character_id text,p_spell_id text,p_slot_level smallint,p_target_token_keys text[]
)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public','pg_temp'
AS $function$
DECLARE v_campaign_id bigint; v_state text; v_result jsonb; v_combat jsonb;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória'; END IF;
  SELECT ch.campaign_id INTO v_campaign_id FROM public.characters ch
  WHERE ch.id::text=btrim(p_character_id) AND ch.user_id=auth.uid() FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou sem autorização'; END IF;
  SELECT c.state INTO v_state FROM public.campaigns c WHERE c.id=v_campaign_id FOR UPDATE;
  IF upper(coalesce(v_state,''))='COMBATE' THEN
    PERFORM public.consumir_acao_turno_srd(v_campaign_id,p_character_id,'padrao');
  END IF;
  v_result:=public.conjurar_magia_srd_multialvo_v2(p_character_id,p_spell_id,p_slot_level,p_target_token_keys);
  IF upper(coalesce(v_state,''))='COMBATE' THEN
    SELECT combat_data INTO v_combat FROM public.campaigns WHERE id=v_campaign_id;
    RETURN v_result||jsonb_build_object('combat_data',coalesce(v_combat,'{}'::jsonb));
  END IF;
  RETURN v_result;
END;
$function$;
REVOKE ALL ON FUNCTION public.conjurar_magia_srd_multialvo_v2(text,text,smallint,text[]) FROM PUBLIC,anon;
REVOKE ALL ON FUNCTION public.conjurar_magia_com_acao_srd_multialvo_v2(text,text,smallint,text[]) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.conjurar_magia_srd_multialvo_v2(text,text,smallint,text[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.conjurar_magia_com_acao_srd_multialvo_v2(text,text,smallint,text[]) TO authenticated;