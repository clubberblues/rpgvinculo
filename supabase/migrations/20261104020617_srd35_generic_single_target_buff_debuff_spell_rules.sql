
ALTER TABLE priv.srd_pending_spell_resolutions
  ADD COLUMN IF NOT EXISTS effect_kind text NOT NULL DEFAULT 'buff';

INSERT INTO public.srd_conditions(condition_id,name,summary,mechanical_effects,source_id,verification_status)
VALUES(
  'slowed','Lento',
  'Movimento reduzido à metade; sofre -1 em ataques, CA e Reflexos; pode realizar apenas uma ação padrão ou de movimento por rodada.',
  '{"speed_multiplier":0.5,"attack":-1,"ac":-1,"reflex":-1,"one_move_or_standard":true,"no_full_round":true}'::jsonb,
  'dnd35-srd-ogl','verified_srd'
)
ON CONFLICT(condition_id) DO UPDATE
SET name=EXCLUDED.name,summary=EXCLUDED.summary,mechanical_effects=EXCLUDED.mechanical_effects,
    source_id=EXCLUDED.source_id,verification_status='verified_srd';

INSERT INTO priv.srd_condition_engine_rules(condition_id,modifiers,flags,speed_multiplier,stack_group,stack_rank)
VALUES(
  'slowed',
  '[{"stat":"attack","value":-1,"bonus_type":"untyped"},{"stat":"ac","value":-1,"bonus_type":"untyped"},{"stat":"reflex","value":-1,"bonus_type":"untyped"}]'::jsonb,
  '{"one_move_or_standard":true,"no_full_round":true}'::jsonb,
  0.5,'haste_slow',1
)
ON CONFLICT(condition_id) DO UPDATE
SET modifiers=EXCLUDED.modifiers,flags=EXCLUDED.flags,speed_multiplier=EXCLUDED.speed_multiplier,
    stack_group=EXCLUDED.stack_group,stack_rank=EXCLUDED.stack_rank,enabled=true,updated_at=now();

CREATE OR REPLACE FUNCTION priv.srd_effect_has_flag(p_campaign_id bigint,p_target_kind text,p_target_id text,p_flag text)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER
SET search_path=pg_catalog,public,priv,pg_temp
AS $function$
  SELECT EXISTS(
    SELECT 1 FROM public.srd_campaign_effects e
    WHERE e.campaign_id=p_campaign_id AND e.target_kind=p_target_kind AND e.target_id=p_target_id
      AND e.active=true AND COALESCE(e.effect_data->'flags'->>p_flag,'false')='true'
  );
$function$;
REVOKE ALL ON FUNCTION priv.srd_effect_has_flag(bigint,text,text,text) FROM PUBLIC,anon,authenticated;

DO $patch_effect_counter_rules$
DECLARE v_definition text; v_marker text; v_add text;
BEGIN
  SELECT pg_get_functiondef('priv.srd_apply_campaign_effect(bigint,text,text,text,jsonb,integer,text,text)'::regprocedure) INTO v_definition;
  v_marker:='  IF p_effect_data ? ''modifiers'' THEN';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Ponto de aplicação de efeitos não localizado.'; END IF;
  IF position('srd35_spell_haste' IN v_definition)=0 THEN
    v_add:=$patch$
  IF p_source_spell_id='srd35_spell_haste' THEN
    UPDATE public.srd_campaign_conditions SET active=false
     WHERE campaign_id=p_campaign_id AND target_kind=p_target_kind AND target_id=p_target_id
       AND condition_id='slowed' AND active=true;
  ELSIF p_source_spell_id='srd35_bless' THEN
    UPDATE public.srd_campaign_effects SET active=false
     WHERE campaign_id=p_campaign_id AND target_kind=p_target_kind AND target_id=p_target_id
       AND source_spell_id='srd35_spell_bane' AND active=true;
  ELSIF p_source_spell_id='srd35_spell_bane' THEN
    UPDATE public.srd_campaign_effects SET active=false
     WHERE campaign_id=p_campaign_id AND target_kind=p_target_kind AND target_id=p_target_id
       AND source_spell_id='srd35_bless' AND active=true;
  END IF;

$patch$;
    v_definition:=replace(v_definition,v_marker,v_add||v_marker);
  END IF;
  EXECUTE v_definition;
END;
$patch_effect_counter_rules$;

DO $patch_condition_counter_rules$
DECLARE v_definition text; v_marker text;
BEGIN
  SELECT pg_get_functiondef('priv.srd_apply_campaign_condition(bigint,text,text,text,integer,jsonb,text)'::regprocedure) INTO v_definition;
  v_marker:='  UPDATE public.srd_campaign_conditions';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Ponto de aplicação de condição não localizado.'; END IF;
  IF position('source_spell_id=''srd35_spell_haste''' IN v_definition)=0 THEN
    v_definition:=replace(v_definition,v_marker,
      E'  IF p_condition_id=''slowed'' THEN\n' ||
      E'    UPDATE public.srd_campaign_effects SET active=false\n' ||
      E'     WHERE campaign_id=p_campaign_id AND target_kind=p_target_kind AND target_id=p_target_id\n' ||
      E'       AND source_spell_id=''srd35_spell_haste'' AND active=true;\n' ||
      E'  END IF;\n' || v_marker);
  END IF;
  EXECUTE v_definition;
END;
$patch_condition_counter_rules$;

DO $patch_pending_effect_kind$
DECLARE v_definition text; v_old text; v_new text;
BEGIN
  SELECT pg_get_functiondef('priv.srd_apply_pending_spell_resolution(uuid)'::regprocedure) INTO v_definition;
  v_old:='''buff'',v_pending.effect_data,v_pending.duration_rounds';
  v_new:='v_pending.effect_kind,v_pending.effect_data,v_pending.duration_rounds';
  IF position(v_old IN v_definition)=0 THEN RAISE EXCEPTION 'Aplicação de efeito pendente não localizada.'; END IF;
  v_definition:=replace(v_definition,v_old,v_new);
  EXECUTE v_definition;
END;
$patch_pending_effect_kind$;

DO $patch_saving_throw_ability_buffs$
DECLARE v_definition text; v_marker text;
BEGIN
  SELECT pg_get_functiondef('priv.srd_saving_throw_bonus(bigint,text,text,text,text)'::regprocedure) INTO v_definition;
  v_marker:='    v_score:=COALESCE(NULLIF(v_sheet.atributos->>v_ability,'''')::integer,10);';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Atributo de resistência não localizado.'; END IF;
  IF position('v_ability_effect' IN v_definition)=0 THEN
    v_definition:=replace(v_definition,'  v_feats jsonb;','  v_feats jsonb; v_ability_effect text;');
    v_definition:=replace(v_definition,v_marker,
      v_marker || E'\n    v_ability_effect:=CASE v_save WHEN ''fortitude'' THEN ''constitution'' WHEN ''reflex'' THEN ''dexterity'' ELSE ''wisdom'' END;\n' ||
      E'    v_score:=v_score+priv.srd_effective_modifier(p_campaign_id,''character'',BTRIM(p_target_id),v_ability_effect);');
  END IF;
  EXECUTE v_definition;
END;
$patch_saving_throw_ability_buffs$;

DO $patch_spellcasting_ability_buffs$
DECLARE v_definition text; v_marker text;
BEGIN
  SELECT pg_get_functiondef('public.conjurar_magia_srd_manual(text,text,smallint,text,integer[])'::regprocedure) INTO v_definition;
  v_marker:='  IF v_score IS NULL OR v_score < 1 THEN RAISE EXCEPTION ''Atributo-chave ausente ou inválido''; END IF;';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Validação do atributo de conjuração não localizada.'; END IF;
  IF position('v_score:=v_score+priv.srd_effective_modifier' IN v_definition)=0 THEN
    v_definition:=replace(v_definition,v_marker,
      E'  v_score:=v_score+priv.srd_effective_modifier(v_campaign_id,''character'',p_character_id,CASE v_class WHEN ''wizard'' THEN ''intelligence'' WHEN ''sorcerer'' THEN ''charisma'' WHEN ''bard'' THEN ''charisma'' WHEN ''paladin'' THEN ''charisma'' ELSE ''wisdom'' END);\n' ||
      v_marker);
  END IF;
  EXECUTE v_definition;
END;
$patch_spellcasting_ability_buffs$;

DO $patch_generic_spell_engine$
DECLARE v_definition text; v_old text; v_new text; v_old_block text; v_new_block text;
BEGIN
  SELECT pg_get_functiondef('public.conjurar_magia_srd_manual(text,text,smallint,text,integer[])'::regprocedure) INTO v_definition;
  v_old:='IF v_campaign_id IS NOT NULL AND v_spell.id IN (''srd35_spell_bull_s_strength'',''srd35_spell_hold_person'',''srd35_spell_blindness_deafness'') THEN';
  v_new:='IF v_campaign_id IS NOT NULL AND EXISTS(SELECT 1 FROM public.srd_spell_effects se WHERE se.spell_id=v_spell.id AND se.verification_status=''verified_srd'' AND se.parameters ? ''engine_rule'') THEN';
  IF position(v_old IN v_definition)=0 THEN RAISE EXCEPTION 'Filtro de magias automatizadas não localizado.'; END IF;
  v_definition:=replace(v_definition,v_old,v_new);

  v_old_block:=$old$
    IF v_spell.id='srd35_spell_bull_s_strength' THEN
      v_effect_data:=v_engine_rule->'effect_data';
      v_duration_rounds:=v_level*COALESCE((v_engine_rule->>'duration_rounds_per_caster_level')::integer,10);
      v_effect_instance:=priv.srd_apply_campaign_effect(v_campaign_id,v_effect_target_kind,v_effect_target_id,'buff',v_effect_data,v_duration_rounds,v_spell.id,NULL);
    ELSE
      v_condition_id:=CASE WHEN v_spell.id='srd35_spell_blindness_deafness' AND p_roll_results IS NOT NULL AND p_roll_results[1]=2 THEN 'deafened' ELSE v_engine_rule->>'condition_id' END;
      v_save_type:=v_engine_rule->>'save_type';
      v_save_dc:=10+v_spell.circulo+FLOOR((v_score-10)::numeric/2)::integer;
      v_duration_rounds:=CASE WHEN v_engine_rule ? 'duration_rounds_per_caster_level'
        THEN v_level*(v_engine_rule->>'duration_rounds_per_caster_level')::integer ELSE NULL END;
      INSERT INTO priv.srd_pending_spell_resolutions(
        campaign_id,caster_character_id,target_kind,target_id,target_user_id,spell_id,
        save_type,save_dc,condition_id,duration_rounds,effect_data,spell_resistance,caster_level
      ) VALUES (
        v_campaign_id,p_character_id,v_effect_target_kind,v_effect_target_id,v_effect_target_user_id,v_spell.id,
        v_save_type,v_save_dc,v_condition_id,v_duration_rounds,'{}'::jsonb,
        COALESCE((v_engine_rule->>'spell_resistance')::boolean,false),v_level
      ) RETURNING pending_id INTO v_pending_id;
      INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
      VALUES (
        v_campaign_id,'test_request','PUBLIC',
        jsonb_build_object(
          'tipo','Resistência de '||CASE v_save_type WHEN 'fortitude' THEN 'Fortitude' WHEN 'reflex' THEN 'Reflexos' ELSE 'Vontade' END||' (D20)',
          'alvos',CASE WHEN v_effect_target_kind='character' THEN jsonb_build_array(v_effect_target_id) ELSE '[]'::jsonb END,
          'npc_alvos',CASE WHEN v_effect_target_kind='token' THEN jsonb_build_array(v_effect_target_id) ELSE '[]'::jsonb END,
          'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
          'resolution_type','spell_save','pending_id',v_pending_id,'spell_id',v_spell.id,'save_type',v_save_type,'save_dc',v_save_dc
        )
      );
    END IF;
$old$;

  v_new_block:=$new$
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

    IF v_engine_rule->>'resolver'='buff' OR (v_engine_rule->>'resolver'='debuff' AND v_save_type IS NULL) THEN
      v_effect_instance:=priv.srd_apply_campaign_effect(v_campaign_id,v_effect_target_kind,v_effect_target_id,v_effect_kind,
        v_effect_data,v_duration_rounds,v_spell.id,NULL);
    ELSIF v_engine_rule->>'resolver'='condition' AND v_save_type IS NULL THEN
      v_effect_instance:=priv.srd_apply_campaign_condition(v_campaign_id,v_effect_target_kind,v_effect_target_id,
        v_condition_id,v_duration_rounds,jsonb_build_object('source_spell_id',v_spell.id,'caster_character_id',p_character_id),v_spell.id);
    ELSE
      IF v_save_type IS NULL THEN RAISE EXCEPTION 'A regra automática da magia não possui uma resistência válida.'; END IF;
      v_save_dc:=10+v_spell.circulo+FLOOR((v_score-10)::numeric/2)::integer;
      INSERT INTO priv.srd_pending_spell_resolutions(
        campaign_id,caster_character_id,target_kind,target_id,target_user_id,spell_id,
        save_type,save_dc,condition_id,duration_rounds,effect_data,effect_kind,spell_resistance,caster_level
      ) VALUES (
        v_campaign_id,p_character_id,v_effect_target_kind,v_effect_target_id,v_effect_target_user_id,v_spell.id,
        v_save_type,v_save_dc,v_condition_id,v_duration_rounds,v_effect_data,v_effect_kind,
        COALESCE((v_engine_rule->>'spell_resistance')::boolean,false),v_level
      ) RETURNING pending_id INTO v_pending_id;
      INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
      VALUES (
        v_campaign_id,'test_request','PUBLIC',
        jsonb_build_object(
          'tipo','Resistência de '||CASE v_save_type WHEN 'fortitude' THEN 'Fortitude' WHEN 'reflex' THEN 'Reflexos' ELSE 'Vontade' END||' (D20)',
          'alvos',CASE WHEN v_effect_target_kind='character' THEN jsonb_build_array(v_effect_target_id) ELSE '[]'::jsonb END,
          'npc_alvos',CASE WHEN v_effect_target_kind='token' THEN jsonb_build_array(v_effect_target_id) ELSE '[]'::jsonb END,
          'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
          'resolution_type','spell_save','pending_id',v_pending_id,'spell_id',v_spell.id,'save_type',v_save_type,'save_dc',v_save_dc
        )
      );
    END IF;
$new$;
  IF position(v_old_block IN v_definition)=0 THEN RAISE EXCEPTION 'Bloco de resolução individual de magia não localizado.'; END IF;
  v_definition:=replace(v_definition,v_old_block,v_new_block);
  v_definition:=replace(v_definition,'v_effect_instance bigint;','v_effect_instance bigint; v_effect_kind text; v_scale jsonb; v_scaled_value integer;');
  EXECUTE v_definition;
END;
$patch_generic_spell_engine$;

DO $patch_effect_movement_speed$
DECLARE v_definition text; v_marker text;
BEGIN
  SELECT pg_get_functiondef('public.mover_token_player_cba(bigint,text,integer,integer)'::regprocedure) INTO v_definition;
  v_marker:='v_speed_m:=v_speed_m*priv.srd_condition_speed_multiplier(p_campaign_id,''character'',v_character_id);';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Velocidade do jogador não localizada para bônus de efeito.'; END IF;
  IF position('''speed_m''' IN v_definition)=0 THEN
    v_definition:=replace(v_definition,v_marker,v_marker||E'\n  v_speed_m:=LEAST(v_speed_m*2,v_speed_m+priv.srd_effective_modifier(p_campaign_id,''character'',v_character_id,''speed_m''));');
  END IF;
  EXECUTE v_definition;

  SELECT pg_get_functiondef('public.mover_token_gm_cba_srd(bigint,text,integer,integer)'::regprocedure) INTO v_definition;
  v_marker:='v_speed_m:=v_speed_m*priv.srd_condition_speed_multiplier(p_campaign_id,''character'',BTRIM(p_token_id));';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Velocidade do personagem pelo Mestre não localizada.'; END IF;
  IF position('''speed_m''' IN v_definition)=0 THEN
    v_definition:=replace(v_definition,v_marker,v_marker||E'\n    v_speed_m:=LEAST(v_speed_m*2,v_speed_m+priv.srd_effective_modifier(p_campaign_id,''character'',BTRIM(p_token_id),''speed_m''));');
    v_marker:='v_speed_m:=v_speed_m*priv.srd_condition_speed_multiplier(p_campaign_id,''token'',BTRIM(p_token_id));';
    IF position(v_marker IN v_definition)>0 THEN
      v_definition:=replace(v_definition,v_marker,v_marker||E'\n      v_speed_m:=LEAST(v_speed_m*2,v_speed_m+priv.srd_effective_modifier(p_campaign_id,''token'',BTRIM(p_token_id),''speed_m''));');
    END IF;
  END IF;
  EXECUTE v_definition;
END;
$patch_effect_movement_speed$;

DO $patch_round_effect_expiry$
DECLARE v_definition text; v_marker text;
BEGIN
  SELECT pg_get_functiondef('public.avancar_turno(bigint)'::regprocedure) INTO v_definition;
  v_marker:='  RETURN v_next_data;';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Retorno de avanço de turno não localizado para expiração.'; END IF;
  IF position('expires_round<=v_round' IN v_definition)=0 THEN
    v_definition:=replace(v_definition,v_marker,
      E'  IF v_next=0 THEN\n' ||
      E'    UPDATE public.srd_campaign_effects SET active=false\n' ||
      E'     WHERE campaign_id=p_campaign_id AND active=true AND expires_round IS NOT NULL AND expires_round<=v_round;\n' ||
      E'  END IF;\n' || v_marker);
  END IF;
  EXECUTE v_definition;
END;
$patch_round_effect_expiry$;

DO $patch_spell_rules$
BEGIN
  UPDATE public.srd_spell_effects SET parameters=jsonb_set(parameters,'{engine_rule}',
    '{"resolver":"buff","effect_data":{"modifiers":[{"stat":"dexterity","value":4,"bonus_type":"enhancement"}],"stacking_key":"cats_grace","stacking_policy":"replace"},"duration_rounds_per_caster_level":10,"willing_target":true}'::jsonb,true),
    verification_status='verified_srd' WHERE spell_id='srd35_spell_cat_s_grace' AND effect_index=1;
  UPDATE public.srd_spell_effects SET parameters=jsonb_set(parameters,'{engine_rule}',
    '{"resolver":"buff","effect_data":{"modifiers":[{"stat":"charisma","value":4,"bonus_type":"enhancement"}],"stacking_key":"eagles_splendor","stacking_policy":"replace"},"duration_rounds_per_caster_level":10,"willing_target":true}'::jsonb,true),
    verification_status='verified_srd' WHERE spell_id='srd35_spell_eagle_s_splendor' AND effect_index=1;
  UPDATE public.srd_spell_effects SET parameters=jsonb_set(parameters,'{engine_rule}',
    '{"resolver":"buff","effect_data":{"modifiers":[{"stat":"intelligence","value":4,"bonus_type":"enhancement"}],"stacking_key":"foxs_cunning","stacking_policy":"replace"},"duration_rounds_per_caster_level":10,"willing_target":true}'::jsonb,true),
    verification_status='verified_srd' WHERE spell_id='srd35_spell_fox_s_cunning' AND effect_index=1;
  UPDATE public.srd_spell_effects SET parameters=jsonb_set(parameters,'{engine_rule}',
    '{"resolver":"buff","effect_data":{"modifiers":[{"stat":"wisdom","value":4,"bonus_type":"enhancement"}],"stacking_key":"owls_wisdom","stacking_policy":"replace"},"duration_rounds_per_caster_level":10,"willing_target":true}'::jsonb,true),
    verification_status='verified_srd' WHERE spell_id='srd35_spell_owl_s_wisdom' AND effect_index=1;
  UPDATE public.srd_spell_effects SET parameters=jsonb_set(parameters,'{engine_rule}',
    '{"resolver":"buff","effect_data":{"modifiers":[{"stat":"ac","value":2,"bonus_type":"natural_armor"}],"stacking_key":"barkskin","stacking_policy":"replace"},"duration_rounds_per_caster_level":100,"level_scale":{"base":2,"start_level":3,"every_levels":3,"cap":5},"willing_target":true}'::jsonb,true),
    verification_status='verified_srd' WHERE spell_id='srd35_spell_barkskin' AND effect_index=1;
  UPDATE public.srd_spell_effects SET parameters=jsonb_set(parameters,'{engine_rule}',
    '{"resolver":"buff","effect_data":{"modifiers":[{"stat":"ac","value":2,"bonus_type":"deflection"}],"stacking_key":"shield_of_faith","stacking_policy":"replace"},"duration_rounds_per_caster_level":10,"level_scale":{"base":2,"start_level":6,"every_levels":6,"cap":5},"willing_target":true}'::jsonb,true),
    verification_status='verified_srd' WHERE spell_id='srd35_spell_shield_of_faith' AND effect_index=1;
  UPDATE public.srd_spell_effects SET parameters=jsonb_set(parameters,'{engine_rule}',
    '{"resolver":"buff","effect_data":{"modifiers":[{"stat":"ac","value":2,"bonus_type":"deflection"},{"stat":"saving_throw","value":2,"bonus_type":"resistance"}],"flags":{"blocks_mind_control":true,"blocks_possession":true,"blocks_summoned_contact":true},"stacking_key":"protection_from_evil","stacking_policy":"replace"},"duration_rounds_per_caster_level":10,"willing_target":true}'::jsonb,true),
    verification_status='verified_srd' WHERE spell_id='srd35_spell_protection_from_evil' AND effect_index=1;
  UPDATE public.srd_spell_effects SET parameters=jsonb_set(parameters,'{engine_rule}',
    '{"resolver":"buff","effect_data":{"modifiers":[{"stat":"attack","value":1,"bonus_type":"morale"},{"stat":"fear_saving_throw","value":1,"bonus_type":"morale"}],"stacking_key":"bless","stacking_policy":"replace"},"duration_rounds_per_caster_level":10,"willing_target":true}'::jsonb,true),
    verification_status='verified_srd' WHERE spell_id='srd35_bless' AND effect_index=1;
  UPDATE public.srd_spell_effects SET parameters=jsonb_set(parameters,'{engine_rule}',
    '{"resolver":"debuff","effect_kind":"debuff","effect_data":{"modifiers":[{"stat":"attack","value":-1,"bonus_type":"untyped"},{"stat":"fear_saving_throw","value":-1,"bonus_type":"untyped"}],"stacking_key":"bane","stacking_policy":"replace"},"save_type":"will","save_result":"negates","duration_rounds_per_caster_level":10,"spell_resistance":true}'::jsonb,true),
    verification_status='verified_srd' WHERE spell_id='srd35_spell_bane' AND effect_index=1;
  UPDATE public.srd_spell_effects SET parameters=jsonb_set(parameters,'{engine_rule}',
    '{"resolver":"buff","effect_data":{"modifiers":[{"stat":"attack","value":1,"bonus_type":"untyped"},{"stat":"ac","value":1,"bonus_type":"dodge"},{"stat":"reflex","value":1,"bonus_type":"untyped"},{"stat":"speed_m","value":9,"bonus_type":"untyped"}],"flags":{"extra_attack_full_attack":true},"stacking_key":"haste","stacking_policy":"replace"},"duration_rounds_per_caster_level":1,"willing_target":true}'::jsonb,true),
    verification_status='verified_srd' WHERE spell_id='srd35_spell_haste' AND effect_index=1;
  UPDATE public.srd_spell_effects SET parameters=jsonb_set(parameters,'{engine_rule}',
    '{"resolver":"condition","condition_id":"slowed","save_type":"will","save_result":"negates","duration_rounds_per_caster_level":1,"spell_resistance":true}'::jsonb,true),
    verification_status='verified_srd' WHERE spell_id='srd35_spell_slow' AND effect_index=1;
  UPDATE public.srd_spells SET dados_tecnicos=jsonb_set(COALESCE(dados_tecnicos,'{}'::jsonb),'{engine_status}',to_jsonb('ready_single_target'::text),true)
   WHERE id IN ('srd35_spell_bull_s_strength','srd35_spell_hold_person','srd35_spell_blindness_deafness',
     'srd35_spell_cat_s_grace','srd35_spell_eagle_s_splendor','srd35_spell_fox_s_cunning','srd35_spell_owl_s_wisdom',
     'srd35_spell_barkskin','srd35_spell_shield_of_faith','srd35_spell_protection_from_evil',
     'srd35_bless','srd35_spell_bane','srd35_spell_haste','srd35_spell_slow');
END;
$patch_spell_rules$;
