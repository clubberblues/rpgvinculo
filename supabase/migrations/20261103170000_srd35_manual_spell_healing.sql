CREATE OR REPLACE FUNCTION public.conjurar_magia_srd_manual(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text DEFAULT NULL::text, p_roll_results integer[] DEFAULT NULL)
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

  SELECT s.* INTO v_sheet FROM public.srd_character_sheets s
    WHERE s.character_id::text=p_character_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada'; END IF;
  v_doc:=to_jsonb(v_sheet);
  SELECT public._srd35_class_key(cl.nome) INTO v_class
    FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe SRD da ficha não encontrada ou incompatível'; END IF;
  v_level:=v_sheet.nivel;
  IF v_level IS NULL OR v_level NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Nível de classe ausente ou inválido'; END IF;
  v_score:=CASE v_class
    WHEN 'wizard' THEN public._srd35_attr(v_doc,ARRAY['INT','inteligencia','intelligence','int_score','score_inteligencia'])::integer
    WHEN 'sorcerer' THEN public._srd35_attr(v_doc,ARRAY['CAR','carisma','charisma','cha','cha_score','score_carisma'])::integer
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
  IF v_class='sorcerer' AND p_slot_level<>v_circle THEN RAISE EXCEPTION 'Feiticeiro conjura a magia no próprio círculo'; END IF;
  IF v_class<>'sorcerer' AND p_slot_level<v_circle AND NOT v_domain_access THEN RAISE EXCEPTION 'Espaço menor que o círculo da magia'; END IF;

  v_state:=coalesce(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
  v_known:=coalesce(v_state->'conhecidas','[]'::jsonb);
  v_prepared:=coalesce(v_state->'preparadas','[]'::jsonb);
  v_usos:=coalesce(v_state->'usos','{}'::jsonb);
  v_domain_prepared:=coalesce(v_state->'dominio_preparadas','[]'::jsonb);
  IF v_class='sorcerer' THEN
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
      IF p_roll_results IS NULL OR cardinality(p_roll_results)<>v_die_count
         OR EXISTS(SELECT 1 FROM unnest(p_roll_results) value WHERE value<1 OR value>v_die_size) THEN
        RAISE EXCEPTION 'A cura exige exatamente % resultado(s) manual(is) de d%.',v_die_count,v_die_size;
      END IF;
      SELECT coalesce(sum(value),0) INTO v_roll FROM unnest(p_roll_results) value;
      IF substring(v_dice from '([+-][0-9]+)$') IS NOT NULL THEN
        v_roll:=v_roll+substring(v_dice from '([+-][0-9]+)$')::integer;
      END IF;
    ELSIF v_dice ~ '^[0-9]+$' THEN
      IF p_roll_results IS NOT NULL AND cardinality(p_roll_results)>0 THEN RAISE EXCEPTION 'Esta cura não exige dados adicionais.'; END IF;
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
$function$;

CREATE OR REPLACE FUNCTION public.conjurar_magia_com_acao_srd_manual(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text DEFAULT NULL::text, p_roll_results integer[] DEFAULT NULL)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_campaign_id BIGINT;
  v_campaign_state TEXT;
  v_combat JSONB;
  v_result JSONB;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Autenticação obrigatória.';
  END IF;
  SELECT ch.campaign_id INTO v_campaign_id
    FROM public.characters AS ch
   WHERE ch.id::TEXT = BTRIM(p_character_id)
     AND ch.user_id = auth.uid()
   FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem autorização.';
  END IF;

  IF v_campaign_id IS NOT NULL THEN
    SELECT c.state INTO v_campaign_state
      FROM public.campaigns AS c
     WHERE c.id = v_campaign_id
     FOR UPDATE;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Campanha do personagem não encontrada.';
    END IF;
    IF UPPER(COALESCE(v_campaign_state, '')) = 'COMBATE' THEN
      PERFORM public.consumir_acao_turno_srd(v_campaign_id, p_character_id, 'padrao');
    END IF;
  END IF;

  v_result := public.conjurar_magia_srd_manual(
    p_character_id,
    p_spell_id,
    p_slot_level,
    p_target_token_key,
    p_roll_results
  );

  IF v_campaign_id IS NOT NULL
     AND UPPER(COALESCE(v_campaign_state, '')) = 'COMBATE' THEN
    SELECT c.combat_data INTO v_combat
      FROM public.campaigns AS c
     WHERE c.id = v_campaign_id;
    RETURN COALESCE(v_result, '{}'::JSONB) || jsonb_build_object(
      'combat_data', COALESCE(v_combat, '{}'::JSONB),
      'action_economy', COALESCE(v_combat->'action_economy', '{}'::JSONB)
    );
  END IF;
  RETURN COALESCE(v_result, '{}'::JSONB);
END;
$function$;

CREATE OR REPLACE FUNCTION public.conjurar_magia_srd_multialvo_v3(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
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
      IF p_roll_results IS NULL OR cardinality(p_roll_results)<>v_die_count
         OR EXISTS(SELECT 1 FROM unnest(p_roll_results) value WHERE value<1 OR value>v_die_size) THEN
        RAISE EXCEPTION 'A cura em massa exige exatamente % resultado(s) manual(is) de d%.',v_die_count,v_die_size;
      END IF;
      SELECT coalesce(sum(value),0) INTO v_roll FROM unnest(p_roll_results) value;
      IF substring(v_dice from '([+-][0-9]+)$') IS NOT NULL THEN
        v_roll:=v_roll+substring(v_dice from '([+-][0-9]+)$')::integer;
      END IF;
    ELSE
      IF p_roll_results IS NOT NULL AND cardinality(p_roll_results)>0 THEN RAISE EXCEPTION 'Esta cura não exige dados adicionais.'; END IF;
      v_roll:=v_dice::integer;
    END IF;
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

CREATE OR REPLACE FUNCTION public.conjurar_magia_com_acao_srd_multialvo_v3(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
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
  v_result:=public.conjurar_magia_srd_multialvo_v3(p_character_id,p_spell_id,p_slot_level,p_target_token_keys,p_roll_results);
  IF upper(coalesce(v_state,''))='COMBATE' THEN
    SELECT combat_data INTO v_combat FROM public.campaigns WHERE id=v_campaign_id;
    RETURN v_result||jsonb_build_object('combat_data',coalesce(v_combat,'{}'::jsonb));
  END IF;
  RETURN v_result;
END;
$function$;
REVOKE EXECUTE ON FUNCTION public.conjurar_magia_srd(text,text,smallint,text) FROM PUBLIC,anon,authenticated;
REVOKE EXECUTE ON FUNCTION public.conjurar_magia_com_acao_srd(text,text,smallint,text) FROM PUBLIC,anon,authenticated;
REVOKE EXECUTE ON FUNCTION public.conjurar_magia_srd_multialvo_v2(text,text,smallint,text[]) FROM PUBLIC,anon,authenticated;
REVOKE EXECUTE ON FUNCTION public.conjurar_magia_com_acao_srd_multialvo_v2(text,text,smallint,text[]) FROM PUBLIC,anon,authenticated;
REVOKE EXECUTE ON FUNCTION public.conjurar_magia_srd_multialvo(text,text,smallint,text[]) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.conjurar_magia_srd_manual(text,text,smallint,text,integer[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.conjurar_magia_com_acao_srd_manual(text,text,smallint,text,integer[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.conjurar_magia_srd_multialvo_v3(text,text,smallint,text[],integer[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.conjurar_magia_com_acao_srd_multialvo_v3(text,text,smallint,text[],integer[]) TO authenticated;
