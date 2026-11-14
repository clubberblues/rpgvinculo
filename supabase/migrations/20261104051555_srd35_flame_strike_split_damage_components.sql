CREATE OR REPLACE FUNCTION priv.srd_adjust_damage_components(
  p_campaign_id bigint,
  p_target_kind text,
  p_target_id text,
  p_effect_data jsonb
)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $function$
DECLARE
  v_base integer:=GREATEST(0,COALESCE(NULLIF(p_effect_data->>'damage','')::integer,0));
  v_components jsonb:=p_effect_data->'damage_components';
  v_component jsonb;
  v_component_type text;
  v_component_ratio numeric;
  v_component_amount integer;
  v_component_count integer;
  v_allocated integer:=0;
  v_total integer:=0;
  v_ratio_sum numeric:=0;
  v_ord integer;
BEGIN
  IF jsonb_typeof(v_components)<>'array' THEN
    RETURN priv.srd_adjust_damage(p_campaign_id,p_target_kind,p_target_id,
      COALESCE(NULLIF(p_effect_data->>'damage_type',''),'untyped'),v_base);
  END IF;
  v_component_count:=jsonb_array_length(v_components);
  IF v_component_count<1 OR v_component_count>8 THEN RAISE EXCEPTION 'Componentes de dano inválidos.'; END IF;
  SELECT COALESCE(SUM((value->>'ratio')::numeric),0)
    INTO v_ratio_sum FROM jsonb_array_elements(v_components);
  IF ABS(v_ratio_sum-1.0)>0.001 THEN RAISE EXCEPTION 'As proporções dos componentes de dano devem somar 1.'; END IF;

  FOR v_component,v_ord IN
    SELECT value,ordinality::integer
    FROM jsonb_array_elements(v_components) WITH ORDINALITY
  LOOP
    v_component_type:=COALESCE(NULLIF(v_component->>'damage_type',''),'untyped');
    IF v_component_type !~ '^[a-z_]{1,24}$' OR v_component_type='mixed' THEN
      RAISE EXCEPTION 'Tipo de componente de dano inválido.';
    END IF;
    v_component_ratio:=COALESCE((v_component->>'ratio')::numeric,0);
    IF v_component_ratio<0 OR v_component_ratio>1 THEN RAISE EXCEPTION 'Proporção de dano inválida.'; END IF;
    IF v_ord=v_component_count THEN
      v_component_amount:=v_base-v_allocated;
    ELSE
      v_component_amount:=FLOOR(v_base*v_component_ratio)::integer;
    END IF;
    v_allocated:=v_allocated+v_component_amount;
    v_total:=v_total+priv.srd_adjust_damage(p_campaign_id,p_target_kind,p_target_id,v_component_type,v_component_amount);
  END LOOP;
  RETURN GREATEST(0,v_total);
END;
$function$;

REVOKE ALL ON FUNCTION priv.srd_adjust_damage_components(bigint,text,text,jsonb) FROM PUBLIC,anon,authenticated;

CREATE OR REPLACE FUNCTION priv.srd_apply_pending_spell_resolution(p_pending_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE v_pending priv.srd_pending_spell_resolutions%ROWTYPE; v_instance bigint; v_campaign public.campaigns%ROWTYPE; v_hp integer; v_max_hp integer; v_new_hp integer; v_damage integer; v_tokens jsonb; v_token jsonb; v_index bigint; v_count integer; v_name text; v_condition_id text;
BEGIN
  SELECT * INTO v_pending FROM priv.srd_pending_spell_resolutions WHERE pending_id=p_pending_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Resolução de magia pendente não encontrada.'; END IF;
  IF v_pending.status NOT IN ('pending_save','awaiting_spell_resistance') THEN RAISE EXCEPTION 'Esta resolução de magia já foi concluída.'; END IF;

  IF v_pending.effect_kind='damage' THEN
    IF COALESCE(v_pending.effect_data->>'damage','') !~ '^[0-9]{1,6}$'
       OR (v_pending.effect_data->>'damage')::integer NOT BETWEEN 0 AND 100000
       OR COALESCE(v_pending.effect_data->>'damage_type','') !~ '^[a-z_]{1,24}$' THEN
      RAISE EXCEPTION 'Dados de dano pendente inválidos.';
    END IF;
    v_damage:=(v_pending.effect_data->>'damage')::integer;
    IF priv.srd_effect_has_flag(v_pending.campaign_id,v_pending.target_kind,v_pending.target_id,'negates_magic_missile') THEN
      UPDATE priv.srd_pending_spell_resolutions SET status='resolved',resolved_at=now() WHERE pending_id=p_pending_id;
      RETURN jsonb_build_object('pending_id',p_pending_id,'status','negated_by_shield','damage',0,'spell_negated_by_shield',true);
    END IF;
    SELECT * INTO v_campaign FROM public.campaigns WHERE id=v_pending.campaign_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Campanha do efeito de dano não encontrada.'; END IF;

    IF v_pending.target_kind='character' THEN
      SELECT sh.pv_atual,sh.pv_max INTO v_hp,v_max_hp
      FROM public.characters ch
      JOIN public.srd_character_sheets sh ON sh.character_id=ch.id
      WHERE ch.id::text=v_pending.target_id AND ch.campaign_id=v_pending.campaign_id
      FOR UPDATE OF sh;
      IF NOT FOUND OR v_max_hp IS NULL OR v_max_hp<1 THEN RAISE EXCEPTION 'Ficha do alvo de dano inválida.'; END IF;
      v_damage:=priv.srd_adjust_damage_components(v_pending.campaign_id,'character',v_pending.target_id,v_pending.effect_data);
      v_new_hp:=GREATEST(-10,COALESCE(v_hp,v_max_hp)-v_damage);
      PERFORM priv.srd_sync_character_vital_condition(v_pending.target_id,v_new_hp,false);
      UPDATE public.srd_character_sheets SET pv_atual=v_new_hp WHERE character_id::text=v_pending.target_id;
      v_name:=(SELECT nome FROM public.characters WHERE id::text=v_pending.target_id);
    ELSIF v_pending.target_kind='token' THEN
      v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END;
      SELECT count(*)::integer,min(e.ordinality),min(e.token->>'nome')
        INTO v_count,v_index,v_name
      FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
      WHERE e.token->>'key'=v_pending.target_id OR e.token->>'id'=v_pending.target_id;
      IF v_count<>1 THEN RAISE EXCEPTION 'Token-alvo de dano ausente ou duplicado.'; END IF;
      v_token:=v_tokens->(v_index::integer-1);
      IF COALESCE(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN RAISE EXCEPTION 'Token-alvo sem PV máximo válido.'; END IF;
      v_max_hp:=(v_token->>'maxHp')::integer;
      IF v_max_hp>100000 THEN RAISE EXCEPTION 'PV máximo do token excede o limite.'; END IF;
      v_hp:=CASE WHEN COALESCE(v_token->>'hp','') ~ '^[0-9]{1,6}$' THEN (v_token->>'hp')::integer ELSE v_max_hp END;
      v_damage:=priv.srd_adjust_damage_components(v_pending.campaign_id,'token',v_pending.target_id,v_pending.effect_data);
      v_new_hp:=GREATEST(0,v_hp-v_damage);
      v_tokens:=jsonb_set(v_tokens,ARRAY[(v_index-1)::text],v_token||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp),false);
      UPDATE public.campaigns SET cba_data=COALESCE(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens)
      WHERE id=v_pending.campaign_id;
    ELSE
      RAISE EXCEPTION 'Tipo de alvo incompatível com dano pendente.';
    END IF;
    v_condition_id:=NULLIF(v_pending.effect_data->>'secondary_condition_id','');
    IF v_condition_id IS NOT NULL AND COALESCE((v_pending.effect_data->>'apply_secondary_condition')::boolean,true) THEN
      v_instance:=priv.srd_apply_campaign_condition(
        v_pending.campaign_id,v_pending.target_kind,v_pending.target_id,v_condition_id,
        v_pending.duration_rounds,
        jsonb_build_object('source_spell_id',v_pending.spell_id,'caster_character_id',v_pending.caster_character_id,
          'save_dc',v_pending.save_dc,'save_type',v_pending.save_type,'caster_level',v_pending.caster_level),
        v_pending.spell_id
      );
    END IF;
    UPDATE priv.srd_pending_spell_resolutions SET status='resolved',resolved_at=now() WHERE pending_id=p_pending_id;
    RETURN jsonb_build_object('pending_id',p_pending_id,'status','resolved','damage',v_damage,
      'pv_atual',v_new_hp,'pv_max',v_max_hp,'target_name',COALESCE(v_name,'Alvo'),
      'damage_type',v_pending.effect_data->>'damage_type','condition_id',v_condition_id,'condition_instance_id',v_instance);
  ELSIF v_pending.condition_id IS NOT NULL THEN

    v_instance:=priv.srd_apply_campaign_condition(
      v_pending.campaign_id,v_pending.target_kind,v_pending.target_id,v_pending.condition_id,
      v_pending.duration_rounds,
      jsonb_build_object('source_spell_id',v_pending.spell_id,'caster_character_id',v_pending.caster_character_id,'save_dc',v_pending.save_dc,'save_type',v_pending.save_type,
        'save_each_turn',v_pending.spell_id='srd35_spell_hold_person','caster_level',v_pending.caster_level),
      v_pending.spell_id
    );
  ELSIF v_pending.effect_data<>'{}'::jsonb THEN
    v_instance:=priv.srd_apply_campaign_effect(v_pending.campaign_id,v_pending.target_kind,v_pending.target_id,
      v_pending.effect_kind,v_pending.effect_data,v_pending.duration_rounds,v_pending.spell_id,NULL);
  ELSE
    RAISE EXCEPTION 'A magia não possui uma regra de efeito implementada.';
  END IF;
  UPDATE priv.srd_pending_spell_resolutions SET status='resolved',resolved_at=now() WHERE pending_id=p_pending_id;
  RETURN jsonb_build_object('pending_id',p_pending_id,'status','resolved','instance_id',v_instance,'condition_id',v_pending.condition_id);
END;
$function$
;
CREATE OR REPLACE FUNCTION public.conjurar_magia_srd_manual(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text DEFAULT NULL::text, p_roll_results integer[] DEFAULT NULL::integer[])
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
  v_circle integer; v_spell_level integer; v_use_count integer; v_capacity integer; v_idx integer; v_new_prepared jsonb;
  v_campaign_id public.characters.campaign_id%TYPE; v_caster_name text;
  v_cba_data jsonb; v_tokens jsonb; v_token jsonb; v_token_index bigint; v_token_count integer;
  v_target_type text; v_target_name text; v_target_key text; v_target_character_id text;
  v_target_hp integer; v_target_max_hp integer; v_healing integer := 0;
  v_roll integer := 0; v_die_count integer; v_die_size integer; v_dice text;
  v_per_level integer := 0; v_max_level integer := 0; v_level_bonus integer;
  v_slot_total integer; v_slots_remaining integer;
  v_effect_target_kind text; v_effect_target_id text; v_effect_target_user_id uuid;
  v_engine_rule jsonb; v_effect_data jsonb; v_pending_id uuid; v_condition_id text; v_save_type text; v_save_dc integer; v_duration_rounds integer; v_effect_instance bigint; v_effect_kind text; v_scale jsonb; v_scaled_value integer;
  v_damage integer:=0; v_damage_expression text; v_damage_scale jsonb; v_damage_dice_count integer; v_damage_flat integer:=0; v_damage_type text; v_sr integer:=0; v_spell_resistance boolean:=false; v_willing_target boolean:=false; v_pending_type text; v_resolution jsonb;
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

  IF priv.srd_condition_has_flag(v_campaign_id,'character',BTRIM(p_character_id),'no_actions') OR priv.srd_condition_has_flag(v_campaign_id,'character',BTRIM(p_character_id),'cannot_cast') THEN RAISE EXCEPTION 'A condição atual impede conjurar magias.'; END IF;
  SELECT s.* INTO v_sheet FROM public.srd_character_sheets s
    WHERE s.character_id::text=p_character_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada'; END IF;
  v_doc:=to_jsonb(v_sheet);
  SELECT public._srd35_class_key(cl.nome) INTO v_class
    FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe SRD da ficha não encontrada ou incompatível'; END IF;
  v_level:=public._srd35_character_class_level(p_character_id,v_class,v_sheet.classe_id,v_sheet.nivel);
  IF v_level IS NULL OR v_level NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Nível de conjurador ausente ou inválido para a classe.'; END IF;
  v_score:=CASE v_class
    WHEN 'wizard' THEN public._srd35_attr(v_doc,ARRAY['INT','inteligencia','intelligence','int_score','score_inteligencia'])::integer
    WHEN 'sorcerer' THEN public._srd35_attr(v_doc,ARRAY['CAR','carisma','charisma','cha','cha_score','score_carisma'])::integer
    ELSE public._srd35_attr(v_doc,ARRAY['SAB','sabedoria','wisdom','wis','wis_score','score_sabedoria'])::integer END;
  v_score:=v_score+priv.srd_effective_modifier(v_campaign_id,'character',p_character_id,CASE v_class WHEN 'wizard' THEN 'intelligence' WHEN 'sorcerer' THEN 'charisma' WHEN 'bard' THEN 'charisma' WHEN 'paladin' THEN 'charisma' ELSE 'wisdom' END);
  IF v_score IS NULL OR v_score < 1 THEN RAISE EXCEPTION 'Atributo-chave ausente ou inválido'; END IF;
  IF p_slot_level IS NULL OR p_slot_level NOT BETWEEN 0 AND 9 THEN RAISE EXCEPTION 'slot_level deve estar entre 0 e 9'; END IF;
  SELECT id,circulo,classes,dados_tecnicos,nivel INTO v_spell FROM public.srd_spells WHERE id=p_spell_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Magia inexistente ou nível inválido'; END IF;
  v_spell_level:=public._srd35_spell_level_for_class(v_spell.nivel,v_class,v_spell_level);
  IF v_spell_level NOT BETWEEN 0 AND 9 THEN RAISE EXCEPTION 'Nível da magia incompatível com a classe.'; END IF;
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
  v_circle:=CASE WHEN v_class_access THEN v_spell_level ELSE v_domain_circle END;
  IF v_class_access AND
     (coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_spell_level)::integer
                  FROM public.srd_spell_progressions WHERE class_key=v_class),0)>0
      AND v_score>=10+v_circle) THEN
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
  v_circle:=CASE WHEN v_class_access THEN v_spell_level ELSE v_domain_circle END;
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
    IF v_target_character_id IS NOT NULL THEN
      v_healing:=GREATEST(0,v_healing+priv.srd_effective_modifier(v_campaign_id,'character',v_target_character_id,'healing_received'));
    ELSIF v_target_key IS NOT NULL THEN
      v_healing:=GREATEST(0,v_healing+priv.srd_effective_modifier(v_campaign_id,'token',v_target_key,'healing_received'));
    END IF;

    IF v_target_type='player' THEN
      IF v_target_key IS NULL THEN
        v_target_hp:=v_sheet.pv_atual; v_target_max_hp:=v_sheet.pv_max;
        IF v_target_max_hp IS NULL OR v_target_max_hp<0 THEN RAISE EXCEPTION 'PV máximo válido ausente na ficha do conjurador'; END IF;
        IF v_target_character_id IS NOT NULL AND priv.srd_condition_has_flag(v_campaign_id,'character',v_target_character_id,'no_healing') THEN v_healing:=0; END IF;
IF v_target_key IS NOT NULL AND v_target_character_id IS NULL AND priv.srd_condition_has_flag(v_campaign_id,'token',v_target_key,'no_healing') THEN v_healing:=0; END IF;
IF COALESCE(v_target_hp,0)<=-10 THEN v_healing:=0; END IF;
v_target_hp:=CASE WHEN COALESCE(v_target_hp,0)<=-10 THEN COALESCE(v_target_hp,0) ELSE LEAST(v_target_max_hp,COALESCE(v_target_hp,0)+v_healing) END;
        UPDATE public.srd_character_sheets SET pv_atual=v_target_hp WHERE character_id::text=p_character_id;
        PERFORM priv.srd_sync_character_vital_condition(p_character_id,v_target_hp,v_healing>0);
      ELSE
        SELECT sh.pv_atual,sh.pv_max,ch.id::text,coalesce(ch.nome,'Aventureiro')
          INTO v_target_hp,v_target_max_hp,v_target_character_id,v_target_name
          FROM public.characters ch JOIN public.srd_character_sheets sh ON sh.character_id::text=ch.id::text
         WHERE ch.id::text=v_target_character_id AND ch.campaign_id=v_campaign_id
         FOR UPDATE OF ch,sh;
        IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD do alvo player não encontrada nesta campanha'; END IF;
        IF v_target_max_hp IS NULL OR v_target_max_hp<0 THEN RAISE EXCEPTION 'PV máximo válido ausente na ficha do alvo'; END IF;
        IF v_target_character_id IS NOT NULL AND priv.srd_condition_has_flag(v_campaign_id,'character',v_target_character_id,'no_healing') THEN v_healing:=0; END IF;
IF v_target_key IS NOT NULL AND v_target_character_id IS NULL AND priv.srd_condition_has_flag(v_campaign_id,'token',v_target_key,'no_healing') THEN v_healing:=0; END IF;
IF COALESCE(v_target_hp,0)<=-10 THEN v_healing:=0; END IF;
v_target_hp:=CASE WHEN COALESCE(v_target_hp,0)<=-10 THEN COALESCE(v_target_hp,0) ELSE LEAST(v_target_max_hp,COALESCE(v_target_hp,0)+v_healing) END;
        UPDATE public.srd_character_sheets SET pv_atual=v_target_hp WHERE character_id::text=v_target_character_id;
        PERFORM priv.srd_sync_character_vital_condition(v_target_character_id,v_target_hp,v_healing>0);
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


  IF v_campaign_id IS NOT NULL AND EXISTS(SELECT 1 FROM public.srd_spell_effects se WHERE se.spell_id=v_spell.id AND se.verification_status='verified_srd' AND se.parameters ? 'engine_rule') THEN
    SELECT se.parameters->'engine_rule' INTO v_engine_rule
    FROM public.srd_spell_effects se
    WHERE se.spell_id=v_spell.id AND se.verification_status='verified_srd'
    ORDER BY se.effect_index LIMIT 1;
    IF v_engine_rule IS NULL THEN RAISE EXCEPTION 'A regra automática desta magia não está validada.'; END IF;
    IF v_engine_rule->>'target_scope'='self_only' AND v_target_key IS NOT NULL THEN
      RAISE EXCEPTION 'Esta magia só pode ser aplicada automaticamente ao próprio conjurador nesta versão.';
    END IF;
    IF v_target_key IS NULL THEN
      v_effect_target_kind:='character'; v_effect_target_id:=p_character_id;
      v_target_character_id:=p_character_id; v_target_type:='player'; v_target_name:=v_caster_name;
    ELSIF v_target_type='player' THEN
      v_effect_target_kind:='character'; v_target_character_id:=v_token->>'id'; v_effect_target_id:=v_target_character_id;
    ELSE
      v_effect_target_kind:='token'; v_effect_target_id:=v_target_key;
    END IF;
    IF v_effect_target_kind='character' THEN
      SELECT ch.user_id INTO v_effect_target_user_id FROM public.characters ch
      WHERE ch.id::text=v_effect_target_id AND ch.campaign_id=v_campaign_id;
      IF NOT FOUND THEN RAISE EXCEPTION 'Personagem-alvo não pertence à campanha.'; END IF;
    END IF;
    v_effect_data:=COALESCE(v_engine_rule->'effect_data','{}'::jsonb);
    v_effect_kind:=COALESCE(v_engine_rule->>'effect_kind',CASE v_engine_rule->>'resolver' WHEN 'debuff' THEN 'debuff' ELSE 'buff' END);
    v_save_type:=NULLIF(v_engine_rule->>'save_type','');
    v_condition_id:=CASE
      WHEN v_spell.id='srd35_spell_blindness_deafness' AND p_roll_results IS NOT NULL AND p_roll_results[1]=2 THEN 'deafened'
      ELSE NULLIF(v_engine_rule->>'condition_id','') END;
    v_duration_rounds:=CASE
      WHEN v_engine_rule ? 'duration_rounds_per_caster_level' THEN v_level*(v_engine_rule->>'duration_rounds_per_caster_level')::integer
      WHEN v_engine_rule ? 'duration_rounds' THEN (v_engine_rule->>'duration_rounds')::integer
      ELSE NULL END;

    v_scale:=v_engine_rule->'level_scale';
    IF v_scale IS NOT NULL AND jsonb_typeof(v_scale)='object' AND jsonb_typeof(v_effect_data->'modifiers')='array' THEN
      v_scaled_value:=COALESCE((v_scale->>'base')::integer,0)
        +GREATEST(0,FLOOR((v_level-COALESCE((v_scale->>'start_level')::integer,1))::numeric/GREATEST(1,COALESCE((v_scale->>'every_levels')::integer,1)))::integer);
      IF v_scale ? 'cap' THEN v_scaled_value:=LEAST(v_scaled_value,(v_scale->>'cap')::integer); END IF;
      v_effect_data:=jsonb_set(v_effect_data,'{modifiers,0,value}',to_jsonb(v_scaled_value),true);
    END IF;

    v_willing_target:=COALESCE((v_engine_rule->>'willing_target')::boolean,false);
    v_spell_resistance:=COALESCE((v_engine_rule->>'spell_resistance')::boolean,false) AND NOT v_willing_target;

    IF v_engine_rule->>'resolver'='damage' THEN
      IF v_target_key IS NULL THEN RAISE EXCEPTION 'Esta magia exige um alvo selecionado.'; END IF;
      IF v_engine_rule->>'target_filter'='plant_creature' THEN
        IF v_target_type NOT IN ('npc','monstro')
           OR lower(COALESCE(v_token->'monsterStats'->>'type',v_token->'monsterStats'->>'tipo','')) NOT LIKE '%plant%' THEN
          RAISE EXCEPTION 'Esta magia só afeta criaturas do tipo Planta; o alvo selecionado não corresponde.';
        END IF;
      END IF;

      v_damage_expression:=COALESCE(v_engine_rule->>'damage_expression',v_effect_data->>'damage_expression');
      IF COALESCE(v_damage_expression,'') !~ '^[0-9]{1,3}d(2|3|4|6|8|10|12|20|100)([+-][0-9]{1,5})?$' THEN
        RAISE EXCEPTION 'Expressão de dano automática inválida para esta magia.';
      END IF;
      v_die_count:=split_part(v_damage_expression,'d',1)::integer;
      v_die_size:=regexp_replace(split_part(v_damage_expression,'d',2),'[+-].*$','')::integer;
      v_damage_flat:=COALESCE(substring(v_damage_expression from '([+-][0-9]+)$')::integer,0);
      v_damage_dice_count:=v_die_count;
      v_damage_scale:=v_engine_rule->'damage_scaling';
      IF v_damage_scale IS NOT NULL AND jsonb_typeof(v_damage_scale)='object' THEN
        v_damage_dice_count:=COALESCE((v_damage_scale->>'base_dice')::integer,v_die_count)
          +GREATEST(0,FLOOR((v_level-COALESCE((v_damage_scale->>'start_level')::integer,1))::numeric
          /GREATEST(1,COALESCE((v_damage_scale->>'every_levels')::integer,1)))::integer)
          *COALESCE((v_damage_scale->>'dice_per_level')::integer,0);
        IF v_damage_scale ? 'cap_dice' THEN v_damage_dice_count:=LEAST(v_damage_dice_count,(v_damage_scale->>'cap_dice')::integer); END IF;
      END IF;
      IF v_damage_dice_count<1 OR v_damage_dice_count>100 THEN RAISE EXCEPTION 'Quantidade de dados de dano fora do limite.'; END IF;
      IF p_roll_results IS NULL OR cardinality(p_roll_results)<>v_damage_dice_count
         OR EXISTS(SELECT 1 FROM unnest(p_roll_results) value WHERE value<1 OR value>v_die_size) THEN
        RAISE EXCEPTION 'Esta magia exige exatamente % resultado(s) manual(is) de d%.',v_damage_dice_count,v_die_size;
      END IF;
      SELECT COALESCE(SUM(value),0) INTO v_roll FROM unnest(p_roll_results) value;
      v_damage:=GREATEST(0,v_roll+v_damage_flat);
      v_damage_type:=COALESCE(NULLIF(v_engine_rule->>'damage_type',''),'untyped');
      IF v_damage_type !~ '^[a-z_]{1,24}$' THEN RAISE EXCEPTION 'Tipo de dano inválido.'; END IF;
      v_effect_data:=v_effect_data||jsonb_build_object(
        'damage',v_damage,'damage_type',v_damage_type,
        'save_result',COALESCE(v_engine_rule->>'save_result','none'),
        'damage_expression',v_damage_dice_count::text||'d'||v_die_size,
        'damage_components',v_engine_rule->'damage_components'
      );
      v_effect_kind:='damage';
      v_save_type:=NULLIF(v_engine_rule->>'save_type','');
      v_save_dc:=CASE WHEN v_save_type IS NOT NULL THEN 10+v_circle+FLOOR((v_score-10)::numeric/2)::integer ELSE NULL END;
      v_sr:=CASE WHEN v_spell_resistance THEN priv.srd_spell_resistance_value(v_campaign_id,v_effect_target_kind,v_effect_target_id) ELSE 0 END;

      INSERT INTO priv.srd_pending_spell_resolutions(
        campaign_id,caster_character_id,target_kind,target_id,target_user_id,spell_id,
        save_type,save_dc,condition_id,duration_rounds,effect_data,effect_kind,spell_resistance,caster_level,status
      ) VALUES (
        v_campaign_id,p_character_id,v_effect_target_kind,v_effect_target_id,v_effect_target_user_id,v_spell.id,
        v_save_type,v_save_dc,NULL,v_duration_rounds,v_effect_data,'damage',v_spell_resistance,v_level,
        CASE WHEN v_sr>0 THEN 'awaiting_spell_resistance' ELSE 'pending_save' END
      ) RETURNING pending_id INTO v_pending_id;

      IF v_sr>0 THEN
        v_pending_type:='spell_resistance';
        INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
        VALUES(v_campaign_id,'test_request','PUBLIC',jsonb_build_object(
          'tipo','Penetração de Resistência à Magia (D20)',
          'alvos',jsonb_build_array(p_character_id),'npc_alvos','[]'::jsonb,
          'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
          'resolution_type','spell_resistance','pending_id',v_pending_id,'spell_id',v_spell.id,
          'spell_resistance',v_sr,'caster_level',v_level
        ));
      ELSIF v_save_type IS NOT NULL THEN
        v_pending_type:='spell_save';
        INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
        VALUES(v_campaign_id,'test_request','PUBLIC',jsonb_build_object(
          'tipo','Resistência de '||CASE v_save_type WHEN 'fortitude' THEN 'Fortitude' WHEN 'reflex' THEN 'Reflexos' ELSE 'Vontade' END||' (D20)',
          'alvos',CASE WHEN v_effect_target_kind='character' THEN jsonb_build_array(v_effect_target_id) ELSE '[]'::jsonb END,
          'npc_alvos',CASE WHEN v_effect_target_kind='token' THEN jsonb_build_array(v_effect_target_id) ELSE '[]'::jsonb END,
          'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
          'resolution_type','spell_save','pending_id',v_pending_id,'spell_id',v_spell.id,'save_type',v_save_type,'save_dc',v_save_dc
        ));
      ELSE
        v_resolution:=priv.srd_apply_pending_spell_resolution(v_pending_id);
        v_damage:=COALESCE((v_resolution->>'damage')::integer,0);
        v_target_hp:=NULLIF(v_resolution->>'pv_atual','')::integer;
        v_target_max_hp:=NULLIF(v_resolution->>'pv_max','')::integer;
        v_target_name:=COALESCE(v_resolution->>'target_name',v_target_name);
        SELECT cba_data INTO v_cba_data FROM public.campaigns WHERE id=v_campaign_id;
      END IF;
    ELSE
      IF v_willing_target THEN v_save_type:=NULL; END IF;
      v_sr:=CASE WHEN v_spell_resistance THEN priv.srd_spell_resistance_value(v_campaign_id,v_effect_target_kind,v_effect_target_id) ELSE 0 END;
      IF v_sr>0 THEN
        v_pending_type:='spell_resistance';
        v_save_dc:=CASE WHEN v_save_type IS NOT NULL THEN 10+v_circle+FLOOR((v_score-10)::numeric/2)::integer ELSE NULL END;
        INSERT INTO priv.srd_pending_spell_resolutions(
          campaign_id,caster_character_id,target_kind,target_id,target_user_id,spell_id,
          save_type,save_dc,condition_id,duration_rounds,effect_data,effect_kind,spell_resistance,caster_level,status
        ) VALUES(
          v_campaign_id,p_character_id,v_effect_target_kind,v_effect_target_id,v_effect_target_user_id,v_spell.id,
          v_save_type,v_save_dc,v_condition_id,v_duration_rounds,v_effect_data,v_effect_kind,true,v_level,'awaiting_spell_resistance'
        ) RETURNING pending_id INTO v_pending_id;
        INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
        VALUES(v_campaign_id,'test_request','PUBLIC',jsonb_build_object(
          'tipo','Penetração de Resistência à Magia (D20)','alvos',jsonb_build_array(p_character_id),'npc_alvos','[]'::jsonb,
          'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
          'resolution_type','spell_resistance','pending_id',v_pending_id,'spell_id',v_spell.id,
          'spell_resistance',v_sr,'caster_level',v_level
        ));
      ELSIF v_engine_rule->>'resolver'='buff' OR (v_engine_rule->>'resolver'='debuff' AND v_save_type IS NULL) THEN
        v_effect_instance:=priv.srd_apply_campaign_effect(v_campaign_id,v_effect_target_kind,v_effect_target_id,v_effect_kind,
          v_effect_data,v_duration_rounds,v_spell.id,NULL);
      ELSIF v_engine_rule->>'resolver'='condition' AND v_save_type IS NULL THEN
        v_effect_instance:=priv.srd_apply_campaign_condition(v_campaign_id,v_effect_target_kind,v_effect_target_id,
          v_condition_id,v_duration_rounds,jsonb_build_object('source_spell_id',v_spell.id,'caster_character_id',p_character_id),v_spell.id);
      ELSE
        IF v_save_type IS NULL THEN RAISE EXCEPTION 'A regra automática da magia não possui uma resistência válida.'; END IF;
        v_save_dc:=10+v_circle+FLOOR((v_score-10)::numeric/2)::integer;
        v_pending_type:='spell_save';
        INSERT INTO priv.srd_pending_spell_resolutions(
          campaign_id,caster_character_id,target_kind,target_id,target_user_id,spell_id,
          save_type,save_dc,condition_id,duration_rounds,effect_data,effect_kind,spell_resistance,caster_level,status
        ) VALUES(
          v_campaign_id,p_character_id,v_effect_target_kind,v_effect_target_id,v_effect_target_user_id,v_spell.id,
          v_save_type,v_save_dc,v_condition_id,v_duration_rounds,v_effect_data,v_effect_kind,false,v_level,'pending_save'
        ) RETURNING pending_id INTO v_pending_id;
        INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
        VALUES(v_campaign_id,'test_request','PUBLIC',jsonb_build_object(
          'tipo','Resistência de '||CASE v_save_type WHEN 'fortitude' THEN 'Fortitude' WHEN 'reflex' THEN 'Reflexos' ELSE 'Vontade' END||' (D20)',
          'alvos',CASE WHEN v_effect_target_kind='character' THEN jsonb_build_array(v_effect_target_id) ELSE '[]'::jsonb END,
          'npc_alvos',CASE WHEN v_effect_target_kind='token' THEN jsonb_build_array(v_effect_target_id) ELSE '[]'::jsonb END,
          'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
          'resolution_type','spell_save','pending_id',v_pending_id,'spell_id',v_spell.id,'save_type',v_save_type,'save_dc',v_save_dc
        ));
      END IF;
    END IF;
  END IF;

  v_state:=jsonb_build_object('version',1,'conhecidas',v_known,'preparadas',v_prepared,'dominio_preparadas',v_domain_prepared,'usos',v_usos);
  UPDATE public.srd_character_sheets SET magias_preparadas=v_state WHERE character_id::text=p_character_id;
  RETURN jsonb_build_object(
    'estado',v_state,'healing',v_healing,'damage',v_damage,'pv_atual',v_target_hp,'pv_max',v_target_max_hp,'cba_data',v_cba_data,
    'target_name',v_target_name,'target_token_key',v_target_key,
    'slot_level',p_slot_level,'slots_remaining',v_slots_remaining,'slots_total',v_slot_total,
    'domain_slot_used',v_domain_slot_used,'domain_id',CASE WHEN v_domain_slot_used THEN v_domain_id ELSE NULL END,'pending_resolution_id',v_pending_id,'pending_resolution_type',v_pending_type,'effect_instance_id',v_effect_instance
  );
END
$function$
;
CREATE OR REPLACE FUNCTION public.conjurar_magia_dano_multialvo_srd(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_campaign_id bigint;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_spell record;
  v_class text;
  v_level integer;
  v_spell_level integer;
  v_score integer;
  v_state jsonb;
  v_prepared jsonb;
  v_prepared_idx integer;
  v_slots_remaining integer;
  v_slot_total integer;
  v_cba_data jsonb;
  v_tokens jsonb;
  v_key text;
  v_token jsonb;
  v_target_type text;
  v_target_kind text;
  v_target_id text;
  v_target_user_id uuid;
  v_target_name text;
  v_rule jsonb;
  v_effect_data jsonb;
  v_damage_expression text;
  v_damage_scale jsonb;
  v_die_count integer;
  v_die_size integer;
  v_damage_flat integer:=0;
  v_damage_dice_count integer;
  v_damage integer;
  v_damage_type text;
  v_save_type text;
  v_save_result text;
  v_save_dc integer;
  v_spell_resistance boolean:=false;
  v_sr integer:=0;
  v_pending_id uuid;
  v_pending_ids jsonb:='[]'::jsonb;
  v_pending_types jsonb:='[]'::jsonb;
  v_targets jsonb:='[]'::jsonb;
  v_roll_total integer:=0;
  v_resolution jsonb;
  v_pending_status text;
  v_willing_target boolean:=false;
  v_effect_kind text:='damage';
  v_extra_rolls jsonb:='[]'::jsonb; v_extra jsonb; v_extra_expression text; v_extra_count integer:=0; v_extra_size integer:=0;
  v_extra_dice_count integer:=0; v_total_roll_count integer:=0; v_extra_total integer:=0; v_duration_rounds integer:=0; v_secondary_condition_id text;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_target_token_keys IS NULL OR cardinality(p_target_token_keys) NOT BETWEEN 1 AND 20 THEN
    RAISE EXCEPTION 'Selecione entre 1 e 20 alvos.';
  END IF;
  IF EXISTS(SELECT 1 FROM (SELECT btrim(k) k,count(*) n FROM unnest(p_target_token_keys) k GROUP BY btrim(k)) x WHERE x.n>1 OR NULLIF(x.k,'') IS NULL) THEN
    RAISE EXCEPTION 'A lista de alvos contém identificadores vazios ou repetidos.';
  END IF;
  IF p_roll_results IS NULL OR cardinality(p_roll_results)<1 THEN RAISE EXCEPTION 'Role o dano manualmente antes de conjurar.'; END IF;

  SELECT ch.campaign_id INTO v_campaign_id
  FROM public.characters ch
  WHERE ch.id::text=btrim(p_character_id) AND ch.user_id=auth.uid()
  FOR UPDATE;
  IF NOT FOUND OR v_campaign_id IS NULL THEN RAISE EXCEPTION 'Personagem não encontrado ou sem campanha autorizada.'; END IF;
  IF NOT EXISTS(
    SELECT 1 FROM public.members m WHERE m.campaign_id=v_campaign_id AND m.user_id=auth.uid()
    UNION ALL SELECT 1 FROM public.campaigns c WHERE c.id=v_campaign_id AND c.owner_id=auth.uid()
  ) THEN RAISE EXCEPTION 'O personagem não pertence a uma campanha da qual você participa.'; END IF;
  IF priv.srd_condition_has_flag(v_campaign_id,'character',btrim(p_character_id),'no_actions')
     OR priv.srd_condition_has_flag(v_campaign_id,'character',btrim(p_character_id),'cannot_cast') THEN
    RAISE EXCEPTION 'A condição atual impede conjurar magias.';
  END IF;

  SELECT sh.* INTO v_sheet FROM public.srd_character_sheets sh WHERE sh.character_id::text=btrim(p_character_id) FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada.'; END IF;
  SELECT public._srd35_class_key(cl.nome) INTO v_class FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe SRD incompatível.'; END IF;
  v_level:=public._srd35_character_class_level(p_character_id,v_class,v_sheet.classe_id,v_sheet.nivel);
  IF v_level NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Nível de conjurador inválido para a classe.'; END IF;
  v_score:=CASE v_class
    WHEN 'wizard' THEN public._srd35_attr(to_jsonb(v_sheet),ARRAY['INT','inteligencia','intelligence'])::integer
    WHEN 'sorcerer' THEN public._srd35_attr(to_jsonb(v_sheet),ARRAY['CAR','carisma','charisma','cha'])::integer
    WHEN 'bard' THEN public._srd35_attr(to_jsonb(v_sheet),ARRAY['CAR','carisma','charisma','cha'])::integer
    WHEN 'paladin' THEN public._srd35_attr(to_jsonb(v_sheet),ARRAY['CAR','carisma','charisma','cha'])::integer
    ELSE public._srd35_attr(to_jsonb(v_sheet),ARRAY['SAB','sabedoria','wisdom','wis'])::integer END;
  IF v_score IS NULL OR v_score<1 THEN RAISE EXCEPTION 'Atributo-chave inválido.'; END IF;
  v_score:=v_score+priv.srd_effective_modifier(v_campaign_id,'character',p_character_id,
    CASE v_class WHEN 'wizard' THEN 'intelligence' WHEN 'sorcerer' THEN 'charisma' WHEN 'bard' THEN 'charisma' WHEN 'paladin' THEN 'charisma' ELSE 'wisdom' END);

  SELECT sp.* INTO v_spell FROM public.srd_spells sp WHERE sp.id=p_spell_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Magia não encontrada.'; END IF;
  v_spell_level:=public._srd35_spell_level_for_class(v_spell.nivel,v_class,v_spell_level);
  IF COALESCE(v_spell.dados_tecnicos->>'target_mode','')<>'multiple_targets_pending'
     OR COALESCE(v_spell.dados_tecnicos->>'engine_status','') NOT IN ('ready_multi_target','partial_multi_target') THEN
    RAISE EXCEPTION 'A magia não possui resolução automática de dano em múltiplos alvos.';
  END IF;
  IF p_slot_level IS NULL OR p_slot_level<>v_spell_level THEN RAISE EXCEPTION 'O espaço deve corresponder ao círculo da magia.'; END IF;
  IF NOT public._srd35_spell_class_ok(v_spell.classes,v_class) THEN RAISE EXCEPTION 'Magia não disponível para esta classe.'; END IF;
  IF COALESCE((SELECT (slots_by_level->(v_level-1)->>v_spell_level)::integer FROM public.srd_spell_progressions WHERE class_key=v_class),0)<=0
     OR v_score<10+v_spell_level THEN RAISE EXCEPTION 'Nível de magia, espaço ou atributo insuficiente.'; END IF;

  SELECT se.parameters->'engine_rule' INTO v_rule
  FROM public.srd_spell_effects se
  WHERE se.spell_id=p_spell_id AND se.verification_status='verified_srd'
    AND se.effect_kind='damage'
  ORDER BY se.effect_index LIMIT 1;
  IF v_rule IS NULL OR v_rule->>'resolver'<>'damage' THEN RAISE EXCEPTION 'Regra de dano não validada.'; END IF;

  v_damage_expression:=COALESCE(v_rule->>'damage_expression','');
  IF v_damage_expression !~ '^[0-9]{1,3}d(2|3|4|6|8|10|12|20|100)([+-][0-9]{1,5})?$' THEN
    RAISE EXCEPTION 'Expressão de dano inválida.';
  END IF;
  v_die_count:=split_part(v_damage_expression,'d',1)::integer;
  v_die_size:=regexp_replace(split_part(v_damage_expression,'d',2),'[+-].*$','')::integer;
  v_damage_flat:=COALESCE(substring(v_damage_expression from '([+-][0-9]+)$')::integer,0);
  v_damage_dice_count:=v_die_count;
  v_damage_scale:=v_rule->'damage_scaling';
  IF v_damage_scale IS NOT NULL AND jsonb_typeof(v_damage_scale)='object' THEN
    v_damage_dice_count:=COALESCE((v_damage_scale->>'base_dice')::integer,v_die_count)
      +GREATEST(0,FLOOR((v_level-COALESCE((v_damage_scale->>'start_level')::integer,1))::numeric
      /GREATEST(1,COALESCE((v_damage_scale->>'every_levels')::integer,1)))::integer)
      *COALESCE((v_damage_scale->>'dice_per_level')::integer,0);
    IF v_damage_scale ? 'cap_dice' THEN v_damage_dice_count:=LEAST(v_damage_dice_count,(v_damage_scale->>'cap_dice')::integer); END IF;
  END IF;
  IF v_damage_dice_count<1 OR v_damage_dice_count>100 THEN RAISE EXCEPTION 'Quantidade de dados de dano fora do limite.'; END IF;
  v_extra_rolls:=COALESCE(v_rule->'extra_rolls','[]'::jsonb);
  IF jsonb_typeof(v_extra_rolls)='array' THEN
    FOR v_extra IN SELECT value FROM jsonb_array_elements(v_extra_rolls) LOOP
      v_extra_expression:=COALESCE(v_extra->>'expression','');
      IF v_extra_expression !~ '^[0-9]{1,2}d(2|4|6|8|10|12|20|100)$' THEN
        RAISE EXCEPTION 'Rolagem adicional inválida na regra de efeito.';
      END IF;
      v_extra_count:=split_part(v_extra_expression,'d',1)::integer;
      v_extra_size:=split_part(v_extra_expression,'d',2)::integer;
      IF v_extra_size<>v_die_size THEN RAISE EXCEPTION 'Rolagens adicionais precisam usar o mesmo tipo de dado do dano.'; END IF;
      v_extra_dice_count:=v_extra_dice_count+v_extra_count;
    END LOOP;
  END IF;
  v_total_roll_count:=v_damage_dice_count+v_extra_dice_count;
  IF v_total_roll_count>100 OR cardinality(p_roll_results)<>v_total_roll_count
     OR EXISTS(SELECT 1 FROM unnest(p_roll_results) value WHERE value<1 OR value>v_die_size) THEN
    RAISE EXCEPTION 'A rolagem precisa conter % dado(s) de dano e duração.',v_total_roll_count;
  END IF;
  SELECT COALESCE(SUM(value),0) INTO v_roll_total
  FROM unnest(p_roll_results) WITH ORDINALITY u(value,ord) WHERE ord<=v_damage_dice_count;
  SELECT COALESCE(SUM(value),0) INTO v_extra_total
  FROM unnest(p_roll_results) WITH ORDINALITY u(value,ord) WHERE ord>v_damage_dice_count;
  v_duration_rounds:=COALESCE((v_rule->>'duration_rounds')::integer,0);
  FOR v_extra IN SELECT value FROM jsonb_array_elements(v_extra_rolls) LOOP
    IF v_extra->>'key'='duration_rounds' THEN v_duration_rounds:=v_extra_total; END IF;
  END LOOP;
  v_secondary_condition_id:=NULLIF(v_rule->>'secondary_condition_id','');
  IF v_secondary_condition_id IS NOT NULL AND v_duration_rounds NOT BETWEEN 1 AND 10000 THEN
    RAISE EXCEPTION 'Duração da condição secundária inválida.';
  END IF;
  v_damage:=GREATEST(0,v_roll_total+v_damage_flat);
  v_damage_type:=COALESCE(NULLIF(v_rule->>'damage_type',''),'untyped');
  IF v_damage_type !~ '^[a-z_]{1,24}$' THEN RAISE EXCEPTION 'Tipo de dano inválido.'; END IF;
  v_save_type:=NULLIF(v_rule->>'save_type','');
  v_save_result:=COALESCE(v_rule->>'save_result','none');
  IF v_save_type IS NOT NULL AND v_save_type NOT IN ('fortitude','reflex','will') THEN RAISE EXCEPTION 'Tipo de resistência inválido.'; END IF;
  v_save_dc:=CASE WHEN v_save_type IS NOT NULL THEN 10+v_spell_level+FLOOR((v_score-10)::numeric/2)::integer ELSE NULL END;
  v_spell_resistance:=COALESCE((v_rule->>'spell_resistance')::boolean,false);
  v_willing_target:=COALESCE((v_rule->>'willing_target')::boolean,false);
  IF v_willing_target THEN v_save_type:=NULL; v_save_dc:=NULL; v_spell_resistance:=false; END IF;

  v_effect_data:=COALESCE(v_rule->'effect_data','{}'::jsonb)||jsonb_build_object(
    'damage',v_damage,'damage_type',v_damage_type,'save_result',v_save_result,
    'damage_expression',v_damage_dice_count::text||'d'||v_die_size,
    'damage_components',v_rule->'damage_components',
    'secondary_condition_id',v_secondary_condition_id,'apply_secondary_condition',true
  );
  v_state:=COALESCE(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
  v_prepared:=COALESCE(v_state->'preparadas','[]'::jsonb);
  SELECT (e.ord-1)::integer INTO v_prepared_idx
  FROM jsonb_array_elements(v_prepared) WITH ORDINALITY e(value,ord)
  WHERE e.value->>'spell_id'=p_spell_id AND (e.value->>'slot_level')::integer=p_slot_level
    AND COALESCE((e.value->>'expended')::boolean,false)=false
  ORDER BY e.ord LIMIT 1;
  IF v_prepared_idx IS NULL THEN RAISE EXCEPTION 'Nenhum espaço preparado disponível.'; END IF;
  v_prepared:=jsonb_set(v_prepared,ARRAY[v_prepared_idx::text,'expended'],'true'::jsonb,true);
  SELECT count(*)::integer INTO v_slots_remaining FROM jsonb_array_elements(v_prepared) e(value)
  WHERE (e.value->>'slot_level')::integer=p_slot_level AND COALESCE((e.value->>'expended')::boolean,false)=false;
  v_slot_total:=public._srd35_slots(v_class,v_level,v_score,p_slot_level);

  IF EXISTS(SELECT 1 FROM public.campaigns c WHERE c.id=v_campaign_id AND UPPER(COALESCE(c.state,''))='COMBATE') THEN
    PERFORM public.consumir_acao_turno_srd(v_campaign_id,p_character_id,'padrao');
  END IF;
  SELECT c.cba_data INTO v_cba_data FROM public.campaigns c WHERE c.id=v_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array' THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;

  FOREACH v_key IN ARRAY p_target_token_keys LOOP
    SELECT t.value INTO v_token FROM jsonb_array_elements(v_tokens) t(value)
    WHERE t.value->>'key'=btrim(v_key) OR t.value->>'id'=btrim(v_key) LIMIT 1;
    IF NOT FOUND THEN RAISE EXCEPTION 'Token-alvo não encontrado: %.',v_key; END IF;
    v_target_type:=COALESCE(v_token->>'tipo','');
    IF v_target_type='player' THEN
      v_target_kind:='character'; v_target_id:=v_token->>'id';
      SELECT ch.user_id INTO v_target_user_id FROM public.characters ch
      WHERE ch.id::text=v_target_id AND ch.campaign_id=v_campaign_id;
      IF NOT FOUND THEN RAISE EXCEPTION 'Personagem-alvo não pertence à campanha.'; END IF;
    ELSIF v_target_type IN ('npc','monstro') THEN
      v_target_kind:='token'; v_target_id:=COALESCE(v_token->>'key',v_token->>'id'); v_target_user_id:=NULL;
    ELSE
      RAISE EXCEPTION 'Tipo de alvo inválido para magia de dano.';
    END IF;
    v_target_name:=COALESCE(v_token->>'nome',v_token->>'name','Alvo');
    v_sr:=CASE WHEN v_spell_resistance THEN priv.srd_spell_resistance_value(v_campaign_id,v_target_kind,v_target_id) ELSE 0 END;
    v_pending_status:=CASE WHEN v_sr>0 THEN 'awaiting_spell_resistance' ELSE 'pending_save' END;

    INSERT INTO priv.srd_pending_spell_resolutions(
      campaign_id,caster_character_id,target_kind,target_id,target_user_id,spell_id,
      save_type,save_dc,condition_id,duration_rounds,effect_data,effect_kind,spell_resistance,caster_level,status
    ) VALUES(
      v_campaign_id,p_character_id,v_target_kind,v_target_id,v_target_user_id,p_spell_id,
      v_save_type,v_save_dc,NULL,CASE WHEN v_secondary_condition_id IS NOT NULL THEN v_duration_rounds ELSE NULL END,
      v_effect_data,'damage',v_spell_resistance,v_level,v_pending_status
    ) RETURNING pending_id INTO v_pending_id;
    v_pending_ids:=v_pending_ids||jsonb_build_array(v_pending_id);
    v_pending_types:=v_pending_types||jsonb_build_array(CASE WHEN v_sr>0 THEN 'spell_resistance' WHEN v_save_type IS NOT NULL THEN 'spell_save' ELSE 'damage' END);

    IF v_sr>0 THEN
      INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
      VALUES(v_campaign_id,'test_request','PUBLIC',jsonb_build_object(
        'tipo','Penetração de Resistência à Magia (D20)','alvos',jsonb_build_array(p_character_id),'npc_alvos','[]'::jsonb,
        'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
        'resolution_type','spell_resistance','pending_id',v_pending_id,'spell_id',p_spell_id,
        'spell_resistance',v_sr,'caster_level',v_level
      ));
      v_targets:=v_targets||jsonb_build_array(jsonb_build_object('target_id',v_target_id,'target_kind',v_target_kind,'name',v_target_name,'status','awaiting_spell_resistance','pending_id',v_pending_id));
    ELSIF v_save_type IS NOT NULL THEN
      INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
      VALUES(v_campaign_id,'test_request','PUBLIC',jsonb_build_object(
        'tipo','Resistência de '||CASE v_save_type WHEN 'fortitude' THEN 'Fortitude' WHEN 'reflex' THEN 'Reflexos' ELSE 'Vontade' END||' (D20)',
        'alvos',CASE WHEN v_target_kind='character' THEN jsonb_build_array(v_target_id) ELSE '[]'::jsonb END,
        'npc_alvos',CASE WHEN v_target_kind='token' THEN jsonb_build_array(v_target_id) ELSE '[]'::jsonb END,
        'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
        'resolution_type','spell_save','pending_id',v_pending_id,'spell_id',p_spell_id,'save_type',v_save_type,'save_dc',v_save_dc
      ));
      v_targets:=v_targets||jsonb_build_array(jsonb_build_object('target_id',v_target_id,'target_kind',v_target_kind,'name',v_target_name,'status','pending_save','pending_id',v_pending_id));
    ELSE
      v_resolution:=priv.srd_apply_pending_spell_resolution(v_pending_id);
      v_targets:=v_targets||jsonb_build_array(jsonb_build_object('target_id',v_target_id,'target_kind',v_target_kind,'name',v_target_name,'status','applied','resolution',v_resolution));
    END IF;
  END LOOP;

  v_state:=jsonb_build_object('version',1,'conhecidas',COALESCE(v_state->'conhecidas','[]'::jsonb),
    'preparadas',v_prepared,'dominio_preparadas',COALESCE(v_state->'dominio_preparadas','[]'::jsonb),
    'usos',COALESCE(v_state->'usos','{}'::jsonb));
  UPDATE public.srd_character_sheets SET magias_preparadas=v_state WHERE character_id::text=p_character_id;
  SELECT cba_data INTO v_cba_data FROM public.campaigns WHERE id=v_campaign_id;
  RETURN jsonb_build_object(
    'estado',v_state,'damage_roll',v_damage,'damage_expression',v_damage_dice_count::text||'d'||v_die_size,
    'damage_type',v_damage_type,'duration_rounds',NULLIF(v_duration_rounds,0),'secondary_condition_id',v_secondary_condition_id,'targets',v_targets,'target_count',cardinality(p_target_token_keys),
    'pending_resolution_ids',v_pending_ids,'pending_resolution_types',v_pending_types,
    'slots_total',v_slot_total,'slots_remaining',v_slots_remaining,'cba_data',v_cba_data,'multiple_targets',true
  );
END;
$function$
;

UPDATE public.srd_spell_effects
SET verification_status='verified_srd',
    damage_expression='1d6',
    parameters=jsonb_set(
      COALESCE(parameters,'{}'::jsonb),
      '{engine_rule}',
      '{
        "resolver":"damage",
        "effect_kind":"damage",
        "damage_expression":"1d6",
        "damage_type":"mixed",
        "damage_scaling":{"base_dice":1,"dice_per_level":1,"start_level":1,"every_levels":1,"cap_dice":15},
        "damage_components":[
          {"damage_type":"fire","ratio":0.5},
          {"damage_type":"untyped","ratio":0.5}
        ],
        "save_type":"reflex",
        "save_result":"half",
        "spell_resistance":true,
        "partial_scope":"selected_creatures_only_area_geometry_manual"
      }'::jsonb,
      true
    )
WHERE spell_id='srd35_spell_flame_strike' AND effect_index=1;

UPDATE public.srd_spells
SET dados_tecnicos=jsonb_set(
  jsonb_set(COALESCE(dados_tecnicos,'{}'::jsonb),'{engine_status}','"partial_multi_target"'::jsonb,true),
  '{target_mode}','"multiple_targets_pending"'::jsonb,true
)
WHERE id='srd35_spell_flame_strike';
