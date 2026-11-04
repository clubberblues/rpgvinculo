DO $extend_effect_duration$
DECLARE v_definition text;
BEGIN
  SELECT pg_get_functiondef('priv.srd_apply_campaign_effect(bigint,text,text,text,jsonb,integer,text,text)'::regprocedure) INTO v_definition;
  IF position('NOT BETWEEN 1 AND 20000' IN v_definition)=0 THEN
    IF position('NOT BETWEEN 1 AND 10000' IN v_definition)=0 THEN RAISE EXCEPTION 'Limite de duração do motor de efeitos não localizado.'; END IF;
    v_definition:=replace(v_definition,'NOT BETWEEN 1 AND 10000','NOT BETWEEN 1 AND 20000');
    EXECUTE v_definition;
  END IF;
END;
$extend_effect_duration$;

DO $patch_self_target_spell_guard$
DECLARE v_definition text; v_marker text; v_add text;
BEGIN
  SELECT pg_get_functiondef('public.conjurar_magia_srd_manual(text,text,smallint,text,integer[])'::regprocedure) INTO v_definition;
  IF position('target_scope' IN v_definition)>0 THEN RETURN; END IF;
  v_marker:='    IF v_engine_rule IS NULL THEN RAISE EXCEPTION ''A regra automática desta magia não está validada.''; END IF;';
  v_add:=v_marker||E'\n    IF v_engine_rule->>''target_scope''=''self_only'' AND v_target_key IS NOT NULL THEN\n      RAISE EXCEPTION ''Esta magia só pode ser aplicada automaticamente ao próprio conjurador nesta versão.'';\n    END IF;';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Ponto de validação da regra automática não encontrado.'; END IF;
  v_definition:=replace(v_definition,v_marker,v_add);
  EXECUTE v_definition;
END;
$patch_self_target_spell_guard$;

UPDATE public.srd_spell_effects
SET parameters=jsonb_set(parameters,'{engine_rule}',
  '{"resolver":"buff","effect_data":{"modifiers":[{"stat":"ac","value":4,"bonus_type":"armor"}],"stacking_key":"mage_armor","stacking_policy":"replace"},"duration_rounds_per_caster_level":600,"target_scope":"self_only","willing_target":true,"spell_resistance":false}'::jsonb,true),
  verification_status='verified_srd'
WHERE spell_id='srd35_mage_armor' AND effect_index=1;

UPDATE public.srd_spell_effects
SET parameters=jsonb_set(parameters,'{engine_rule}',
  '{"resolver":"buff","effect_data":{"modifiers":[{"stat":"ac","value":4,"bonus_type":"shield"}],"flags":{"negates_magic_missile":true},"stacking_key":"shield_spell","stacking_policy":"replace"},"duration_rounds_per_caster_level":10,"target_scope":"self_only","willing_target":true,"spell_resistance":false}'::jsonb,true),
  verification_status='verified_srd'
WHERE spell_id='srd35_shield' AND effect_index=1;

UPDATE public.srd_spell_effects
SET parameters=jsonb_set(parameters,'{engine_rule}',
  '{"resolver":"buff","effect_data":{"modifiers":[{"stat":"saving_throw","value":1,"bonus_type":"resistance"}],"stacking_key":"resistance_spell","stacking_policy":"replace"},"duration_rounds":10,"target_scope":"self_only","willing_target":true,"spell_resistance":false}'::jsonb,true),
  verification_status='verified_srd'
WHERE spell_id='srd35_resistance' AND effect_index=1;

UPDATE public.srd_spells
SET dados_tecnicos=jsonb_set(COALESCE(dados_tecnicos,'{}'::jsonb),'{engine_status}',to_jsonb('ready_single_target'::text),true)
WHERE id IN ('srd35_mage_armor','srd35_shield','srd35_resistance')
  AND EXISTS(SELECT 1 FROM public.srd_spell_effects e WHERE e.spell_id=srd_spells.id AND e.verification_status='verified_srd' AND e.parameters ? 'engine_rule');