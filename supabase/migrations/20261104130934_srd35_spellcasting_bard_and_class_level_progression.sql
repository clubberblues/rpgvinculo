-- Bardo conjura como classe espontânea; níveis de magia usam a trilha da classe,
-- não o nível total da ficha. Paladino e Patrulheiro resolvem suas chaves canônicas.
CREATE OR REPLACE FUNCTION public.conjurar_magia_srd(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_doc jsonb; v_class text; v_level integer; v_score integer;
  v_state jsonb; v_known jsonb; v_prepared jsonb; v_usos jsonb; v_spell record;
  v_domain_prepared jsonb; v_domain_idx integer; v_domain_circle integer; v_domain_id text;
  v_class_access boolean := false; v_domain_access boolean := false; v_domain_slot_used boolean := false;
  v_circle integer; v_use_count integer; v_capacity integer; v_idx integer; v_new_prepared jsonb;
  v_campaign_id public.characters.campaign_id%TYPE; v_caster_name text;
  v_cba_data jsonb; v_tokens jsonb; v_token jsonb; v_token_index bigint; v_token_count integer;
  v_target_type text; v_target_name text; v_target_key text; v_target_character_id text;
  v_target_hp integer; v_target_max_hp integer; v_healing integer := 0;
  v_roll integer := 0; v_die_count integer; v_die_size integer; v_dice text;
  v_per_level integer := 0; v_max_level integer := 0; v_level_bonus integer;
  v_slot_total integer; v_slots_remaining integer;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória'; END IF;
  SELECT c.campaign_id,c.nome INTO v_campaign_id,v_caster_name
    FROM public.characters c
   WHERE c.id::text=p_character_id AND c.user_id=auth.uid()
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou sem autorização'; END IF;
  IF v_campaign_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM public.members m WHERE m.campaign_id=v_campaign_id AND m.user_id=auth.uid()
    UNION ALL SELECT 1 FROM public.campaigns c WHERE c.id=v_campaign_id AND c.owner_id=auth.uid()
  ) THEN RAISE EXCEPTION 'O personagem não pertence a uma campanha da qual você participa'; END IF;


  IF priv.srd_condition_has_flag(v_campaign_id,'character',BTRIM(p_character_id),'no_actions')
     OR priv.srd_condition_has_flag(v_campaign_id,'character',BTRIM(p_character_id),'cannot_cast') THEN
    RAISE EXCEPTION 'A condição atual impede conjurar magias.';
  END IF;

  SELECT s.* INTO v_sheet FROM public.srd_character_sheets s

    WHERE s.character_id::text=p_character_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada'; END IF;
  v_doc:=to_jsonb(v_sheet);
  SELECT public._srd35_class_key(cl.nome) INTO v_class
    FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe SRD da ficha não encontrada ou incompatível'; END IF;
  SELECT COALESCE(
    MAX(cl.class_level) FILTER (WHERE cls.class_key=v_class),
    CASE WHEN NOT EXISTS (
      SELECT 1 FROM public.srd_character_class_levels any_level
       WHERE any_level.character_id=v_sheet.character_id
    ) THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
  )
    INTO v_level
    FROM public.srd_character_sheets sh
    LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
    LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
   WHERE sh.character_id=v_sheet.character_id
   GROUP BY sh.character_id,sh.nivel;
  IF v_level IS NULL OR v_level NOT BETWEEN 1 AND 20 THEN
    RAISE EXCEPTION 'Nível efetivo da classe conjuradora ausente ou inválido.';
  END IF;
  v_score:=CASE
    WHEN v_class='wizard' THEN public._srd35_attr(v_doc,ARRAY['INT','inteligencia','intelligence','int_score','score_inteligencia'])::integer
    WHEN v_class IN ('sorcerer','bard') THEN public._srd35_attr(v_doc,ARRAY['CAR','carisma','charisma','cha','cha_score','score_carisma'])::integer
    ELSE public._srd35_attr(v_doc,ARRAY['SAB','sabedoria','wisdom','wis','wis_score','score_sabedoria'])::integer END;
  IF v_score IS NULL OR v_score < 1 THEN RAISE EXCEPTION 'Atributo-chave ausente ou inválido'; END IF;
  IF p_slot_level IS NULL OR p_slot_level NOT BETWEEN 0 AND 9 THEN RAISE EXCEPTION 'slot_level deve estar entre 0 e 9'; END IF;
  SELECT id,circulo,classes,dados_tecnicos INTO v_spell FROM public.srd_spells WHERE id=p_spell_id;
  IF NOT FOUND OR v_spell.circulo NOT BETWEEN 0 AND 9 THEN
    RAISE EXCEPTION 'Magia inexistente ou nível inválido';
  END IF;
  v_class_access:=public._srd35_spell_class_ok(v_spell.classes,v_class);
  IF v_class='cleric' THEN
    SELECT ds.domain_id,ds.spell_level INTO v_domain_id,v_domain_circle
      FROM public.srd_character_domain_choices choice
      JOIN public.srd_domain_spells ds USING (domain_id)
     WHERE choice.character_id::text=p_character_id AND ds.spell_id=v_spell.id
       AND ds.spell_level=p_slot_level
     ORDER BY choice.domain_slot LIMIT 1;
    v_domain_access:=FOUND;
  END IF;
  IF NOT v_class_access AND NOT v_domain_access THEN
    RAISE EXCEPTION 'Magia inexistente ou não disponível pela classe/domínio escolhido';
  END IF;
  v_circle:=CASE WHEN v_class_access THEN v_spell.circulo ELSE v_domain_circle END;
  IF v_class_access AND
     (coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_spell.circulo)::integer
                  FROM public.srd_spell_progressions WHERE class_key=v_class),0)>0
      AND v_score>=10+v_spell.circulo) THEN
    v_class_access:=true;
  ELSE
    v_class_access:=false;
  END IF;
  IF v_domain_access AND
     (coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_domain_circle)::integer
                  FROM public.srd_spell_progressions WHERE class_key='cleric'),0)>0
      AND v_score>=10+v_domain_circle) THEN
    v_domain_access:=true;
  ELSE
    v_domain_access:=false;
  END IF;
  IF NOT v_class_access AND NOT v_domain_access THEN
    RAISE EXCEPTION 'Nível de magia, espaço de domínio ou atributo insuficiente';
  END IF;
  v_circle:=CASE WHEN v_class_access THEN v_spell.circulo ELSE v_domain_circle END;
  IF v_class IN ('sorcerer','bard') AND p_slot_level<>v_circle THEN RAISE EXCEPTION 'Feiticeiro conjura a magia no próprio círculo'; END IF;
  IF v_class NOT IN ('sorcerer','bard') AND p_slot_level<v_circle AND NOT v_domain_access THEN RAISE EXCEPTION 'Espaço menor que o círculo da magia'; END IF;

  v_state:=coalesce(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
  v_known:=coalesce(v_state->'conhecidas','[]'::jsonb);
  v_prepared:=coalesce(v_state->'preparadas','[]'::jsonb);
  v_usos:=coalesce(v_state->'usos','{}'::jsonb);
  v_domain_prepared:=coalesce(v_state->'dominio_preparadas','[]'::jsonb);
  IF v_class IN ('sorcerer','bard') THEN
    IF NOT (v_known ? p_spell_id) THEN RAISE EXCEPTION 'Feiticeiro só pode conjurar magias conhecidas'; END IF;
    v_capacity:=public._srd35_slots(v_class,v_level,v_score,v_circle);
    v_use_count:=coalesce((v_usos->>v_circle::text)::integer,0);
    IF v_use_count>=v_capacity THEN RAISE EXCEPTION 'Sem usos diários restantes para este círculo'; END IF;
    v_usos:=jsonb_set(v_usos,ARRAY[v_circle::text],to_jsonb(v_use_count+1),true);
    v_slot_total:=v_capacity; v_slots_remaining:=v_capacity-v_use_count-1;
  ELSE
    IF v_class='cleric' AND v_domain_access THEN
      SELECT (ord-1)::integer INTO v_domain_idx
        FROM jsonb_array_elements(v_domain_prepared) WITH ORDINALITY e(value,ord)
       WHERE value->>'spell_id'=p_spell_id AND value->>'domain_id'=v_domain_id
         AND (value->>'slot_level')::integer=p_slot_level
         AND coalesce((value->>'expended')::boolean,false)=false
       ORDER BY ord LIMIT 1;
    END IF;
    IF v_domain_idx IS NOT NULL THEN
      v_domain_prepared:=jsonb_set(v_domain_prepared,ARRAY[v_domain_idx::text,'expended'],'true'::jsonb,true);
      v_domain_slot_used:=true; v_slot_total:=1; v_slots_remaining:=0;
    ELSE
      IF NOT v_class_access THEN RAISE EXCEPTION 'Espaço de domínio não preparado ou já gasto'; END IF;
      SELECT (ord-1)::integer INTO v_idx FROM jsonb_array_elements(v_prepared) WITH ORDINALITY e(value,ord)
        WHERE value->>'spell_id'=p_spell_id AND (value->>'slot_level')::integer=p_slot_level
          AND coalesce((value->>'expended')::boolean,false)=false ORDER BY ord LIMIT 1;
      IF v_idx IS NULL THEN RAISE EXCEPTION 'Nenhum espaço preparado disponível para essa magia e círculo'; END IF;
      v_prepared:=jsonb_set(v_prepared,ARRAY[v_idx::text,'expended'],'true'::jsonb,true);
      v_slot_total:=public._srd35_slots(v_class,v_level,v_score,p_slot_level);
      SELECT count(*)::integer INTO v_slots_remaining FROM jsonb_array_elements(v_prepared) e(value)
        WHERE (value->>'slot_level')::integer=p_slot_level AND coalesce((value->>'expended')::boolean,false)=false;
    END IF;
  END IF;

  v_target_key:=NULLIF(btrim(p_target_token_key),'');
  IF v_target_key IS NOT NULL AND v_campaign_id IS NULL THEN
    RAISE EXCEPTION 'Um alvo por token exige que o conjurador esteja em uma campanha';
  END IF;
  IF v_target_key IS NOT NULL THEN
    IF coalesce(v_spell.dados_tecnicos->>'tipo_efeito','')='cura' THEN
      SELECT c.cba_data INTO v_cba_data FROM public.campaigns c WHERE c.id=v_campaign_id FOR UPDATE;
    ELSE
      SELECT c.cba_data INTO v_cba_data FROM public.campaigns c WHERE c.id=v_campaign_id;
    END IF;
    IF NOT FOUND THEN RAISE EXCEPTION 'Campanha do conjurador não encontrada'; END IF;
    v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array' THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;
    SELECT count(*)::integer,min(e.ordinality),min(e.token->>'nome')
      INTO v_token_count,v_token_index,v_target_name
      FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
      WHERE e.token->>'key'=v_target_key;
    IF v_token_count<>1 THEN RAISE EXCEPTION 'Token-alvo não encontrado ou duplicado nesta campanha'; END IF;
    v_token:=v_tokens->(v_token_index::integer-1);
    v_target_type:=v_token->>'tipo';
    IF v_target_type IS NULL OR v_target_type NOT IN ('player','npc','monstro') THEN RAISE EXCEPTION 'Tipo do token-alvo inválido'; END IF;
  ELSIF coalesce(v_spell.dados_tecnicos->>'tipo_efeito','')='cura' THEN
    v_target_type:='player'; v_target_name:=v_caster_name; v_target_character_id:=p_character_id;
    IF v_campaign_id IS NOT NULL THEN
      SELECT c.cba_data INTO v_cba_data FROM public.campaigns c WHERE c.id=v_campaign_id FOR UPDATE;
      IF NOT FOUND THEN RAISE EXCEPTION 'Campanha do conjurador não encontrada'; END IF;
      v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array' THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;
    END IF;
  END IF;

  IF coalesce(v_spell.dados_tecnicos->>'tipo_efeito','')='cura' THEN
    v_target_character_id:=CASE WHEN v_target_key IS NULL THEN p_character_id ELSE NULL END;
    IF v_target_key IS NOT NULL AND v_target_type='player' THEN
      v_target_character_id:=v_token->>'id';
      IF NOT EXISTS (
        SELECT 1 FROM public.characters ch
        JOIN public.members m ON m.campaign_id=ch.campaign_id AND m.user_id=ch.user_id AND m.role='PLAYER'
        WHERE ch.id::text=v_target_character_id AND ch.campaign_id=v_campaign_id
      ) THEN RAISE EXCEPTION 'O token player não corresponde a um personagem jogador desta campanha'; END IF;
    END IF;
    v_dice:=coalesce(v_spell.dados_tecnicos->'cura'->>'dados','');
    IF v_dice ~ '^[0-9]+d[0-9]+([+-][0-9]+)?$' THEN
      v_die_count:=split_part(v_dice,'d',1)::integer;
      v_die_size:=regexp_replace(split_part(v_dice,'d',2),'[+-].*$','')::integer;
      IF v_die_count<1 OR v_die_count>100 OR v_die_size<2 OR v_die_size>100000 THEN RAISE EXCEPTION 'Dados de cura inválidos'; END IF;
      FOR v_idx IN 1..v_die_count LOOP v_roll:=v_roll+floor(random()*v_die_size)::integer+1; END LOOP;
      IF substring(v_dice from '([+-][0-9]+)$') IS NOT NULL THEN
        v_roll:=v_roll+substring(v_dice from '([+-][0-9]+)$')::integer;
      END IF;
    ELSIF v_dice ~ '^[0-9]+$' THEN
      v_roll:=v_dice::integer;
    ELSE
      RAISE EXCEPTION 'Expressão de cura inválida na magia';
    END IF;
    IF coalesce(v_spell.dados_tecnicos->'cura'->>'por_nivel','0') !~ '^-?[0-9]+$'
       OR coalesce(v_spell.dados_tecnicos->'cura'->>'max_nivel','0') !~ '^-?[0-9]+$' THEN
      RAISE EXCEPTION 'Parâmetros por_nivel/max_nivel inválidos na cura';
    END IF;
    v_per_level:=coalesce((v_spell.dados_tecnicos->'cura'->>'por_nivel')::integer,0);
    v_max_level:=coalesce((v_spell.dados_tecnicos->'cura'->>'max_nivel')::integer,0);
    IF v_per_level<0 OR v_max_level<0 THEN RAISE EXCEPTION 'Parâmetros de cura não podem ser negativos'; END IF;
    v_level_bonus:=CASE WHEN v_max_level>0 THEN least(v_level,v_max_level) ELSE v_level END;
    v_healing:=greatest(0,v_roll+v_per_level*v_level_bonus);

    IF v_target_type='player' THEN
      IF v_target_key IS NULL THEN
        v_target_hp:=v_sheet.pv_atual; v_target_max_hp:=v_sheet.pv_max;
        IF v_target_max_hp IS NULL OR v_target_max_hp<0 THEN RAISE EXCEPTION 'PV máximo válido ausente na ficha do conjurador'; END IF;
        v_target_hp:=least(v_target_max_hp,greatest(0,coalesce(v_target_hp,0)+v_healing));
        UPDATE public.srd_character_sheets SET pv_atual=v_target_hp WHERE character_id::text=p_character_id;
      ELSE
        SELECT sh.pv_atual,sh.pv_max,ch.id::text,coalesce(ch.nome,'Aventureiro')
          INTO v_target_hp,v_target_max_hp,v_target_character_id,v_target_name
          FROM public.characters ch JOIN public.srd_character_sheets sh ON sh.character_id::text=ch.id::text
         WHERE ch.id::text=v_target_character_id AND ch.campaign_id=v_campaign_id
         FOR UPDATE OF ch,sh;
        IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD do alvo player não encontrada nesta campanha'; END IF;
        IF v_target_max_hp IS NULL OR v_target_max_hp<0 THEN RAISE EXCEPTION 'PV máximo válido ausente na ficha do alvo'; END IF;
        v_target_hp:=least(v_target_max_hp,greatest(0,coalesce(v_target_hp,0)+v_healing));
        UPDATE public.srd_character_sheets SET pv_atual=v_target_hp WHERE character_id::text=v_target_character_id;
      END IF;
      IF v_campaign_id IS NOT NULL THEN
        IF v_tokens IS NULL THEN
          v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array' THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;
        END IF;
        SELECT count(*)::integer,min(e.ordinality) INTO v_token_count,v_token_index
          FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
         WHERE e.token->>'id'=v_target_character_id AND e.token->>'tipo'='player';
        IF v_target_key IS NOT NULL AND v_token_count<>1 THEN RAISE EXCEPTION 'Token player do alvo ausente ou duplicado na cena'; END IF;
        IF v_token_count>1 THEN RAISE EXCEPTION 'Há tokens player duplicados para o personagem-alvo'; END IF;
        IF v_token_count=1 THEN
          v_token:=v_tokens->(v_token_index::integer-1);
          v_token:=v_token||jsonb_build_object('hp',v_target_hp,'maxHp',v_target_max_hp);
          v_tokens:=jsonb_set(v_tokens,ARRAY[(v_token_index-1)::text],v_token,false);
          v_cba_data:=coalesce(v_cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens);
          UPDATE public.campaigns SET cba_data=v_cba_data WHERE id=v_campaign_id;
        END IF;
      END IF;
    ELSE
      IF coalesce(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN
        RAISE EXCEPTION 'O token NPC/monstro precisa de maxHp válido para receber cura';
      END IF;
      v_target_max_hp:=(v_token->>'maxHp')::integer;
      IF v_target_max_hp>100000 THEN RAISE EXCEPTION 'maxHp do token excede o limite aceito'; END IF;
      v_target_hp:=CASE WHEN coalesce(v_token->>'hp','') ~ '^[0-9]{1,6}$' THEN (v_token->>'hp')::integer ELSE v_target_max_hp END;
      v_target_hp:=least(v_target_max_hp,greatest(0,v_target_hp+v_healing));
      v_token:=v_token||jsonb_build_object('hp',v_target_hp,'maxHp',v_target_max_hp);
      v_tokens:=jsonb_set(v_tokens,ARRAY[(v_token_index-1)::text],v_token,false);
      v_cba_data:=coalesce(v_cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens);
      UPDATE public.campaigns SET cba_data=v_cba_data WHERE id=v_campaign_id;
    END IF;
  END IF;

  v_state:=jsonb_build_object('version',1,'conhecidas',v_known,'preparadas',v_prepared,'dominio_preparadas',v_domain_prepared,'usos',v_usos);
  UPDATE public.srd_character_sheets SET magias_preparadas=v_state WHERE character_id::text=p_character_id;
  RETURN jsonb_build_object(
    'estado',v_state,'healing',v_healing,'pv_atual',v_target_hp,'cba_data',v_cba_data,
    'target_name',v_target_name,'target_token_key',v_target_key,
    'slot_level',p_slot_level,'slots_remaining',v_slots_remaining,'slots_total',v_slot_total,
    'domain_slot_used',v_domain_slot_used,'domain_id',CASE WHEN v_domain_slot_used THEN v_domain_id ELSE NULL END
  );
END
$function$
;

CREATE OR REPLACE FUNCTION public.repor_magias_srd(p_character_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE v_sheet public.srd_character_sheets%ROWTYPE; v_doc jsonb; v_class text; v_state jsonb;
BEGIN
  IF auth.uid() IS NULL OR NOT EXISTS (SELECT 1 FROM public.characters c
       WHERE c.id::text=p_character_id AND c.user_id=auth.uid()) THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem autorização';
  END IF;
  SELECT s.* INTO v_sheet FROM public.srd_character_sheets s
    WHERE s.character_id::text=p_character_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada'; END IF;
  v_doc:=to_jsonb(v_sheet);
  SELECT COALESCE(NULLIF(cl.class_key,''),public._srd35_class_key(cl.nome)) INTO v_class FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe não resolvida na ficha'; END IF;
  v_state:=coalesce(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
  IF jsonb_typeof(v_state->'preparadas')<>'array' THEN RAISE EXCEPTION 'Estado de magias inválido'; END IF;
  SELECT jsonb_build_object('version',1,'conhecidas',coalesce(v_state->'conhecidas','[]'::jsonb),
      'preparadas',coalesce(jsonb_agg(jsonb_set(e.value,'{expended}','false'::jsonb,true) ORDER BY e.ord),'[]'::jsonb),
      'dominio_preparadas',coalesce((SELECT jsonb_agg(jsonb_set(d.value,'{expended}','false'::jsonb,true) ORDER BY d.ord)
        FROM jsonb_array_elements(coalesce(v_state->'dominio_preparadas','[]'::jsonb)) WITH ORDINALITY d(value,ord)),'[]'::jsonb),
      'usos',CASE WHEN v_class IN ('sorcerer','bard') THEN '{}'::jsonb ELSE coalesce(v_state->'usos','{}'::jsonb) END)
    INTO v_state FROM jsonb_array_elements(v_state->'preparadas') WITH ORDINALITY e(value,ord);
  UPDATE public.srd_character_sheets SET magias_preparadas=v_state,magias_descanso_em=clock_timestamp()
    WHERE character_id::text=p_character_id;
  RETURN v_state || jsonb_build_object('descanso_em',clock_timestamp());
END
$function$
;
