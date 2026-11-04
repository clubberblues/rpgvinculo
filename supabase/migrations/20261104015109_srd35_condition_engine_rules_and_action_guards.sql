
CREATE TABLE IF NOT EXISTS priv.srd_condition_engine_rules (
  condition_id text PRIMARY KEY REFERENCES public.srd_conditions(condition_id) ON DELETE CASCADE,
  modifiers jsonb NOT NULL DEFAULT '[]'::jsonb,
  flags jsonb NOT NULL DEFAULT '{}'::jsonb,
  speed_multiplier numeric(4,3),
  stack_group text,
  stack_rank smallint NOT NULL DEFAULT 0,
  enabled boolean NOT NULL DEFAULT true,
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT srd_condition_engine_modifiers_array CHECK (jsonb_typeof(modifiers)='array'),
  CONSTRAINT srd_condition_engine_flags_object CHECK (jsonb_typeof(flags)='object'),
  CONSTRAINT srd_condition_engine_speed_range CHECK (speed_multiplier IS NULL OR speed_multiplier BETWEEN 0.05 AND 1)
);
ALTER TABLE priv.srd_condition_engine_rules ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE priv.srd_condition_engine_rules FROM PUBLIC, anon, authenticated;

INSERT INTO priv.srd_condition_engine_rules
(condition_id,modifiers,flags,speed_multiplier,stack_group,stack_rank)
VALUES
('blinded','[{"stat":"ac","value":-2,"bonus_type":"untyped"},{"stat":"search","value":-4,"bonus_type":"untyped"},{"stat":"strength_dexterity_skill","value":-4,"bonus_type":"untyped"}]','{"loses_dex_ac":true,"vision_checks_fail":true,"opponents_total_concealment":true}',0.5,NULL,0),
('cowering','[{"stat":"ac","value":-2,"bonus_type":"untyped"}]','{"no_actions":true,"loses_dex_ac":true}',NULL,NULL,0),
('dazed','[]','{"no_actions":true}',NULL,NULL,0),
('dazzled','[{"stat":"attack","value":-1,"bonus_type":"untyped"},{"stat":"search","value":-1,"bonus_type":"untyped"},{"stat":"spot","value":-1,"bonus_type":"untyped"}]','{}',NULL,NULL,0),
('deafened','[{"stat":"initiative","value":-4,"bonus_type":"untyped"}]','{"listen_auto_fail":true,"verbal_spell_failure_20":true}',NULL,NULL,0),
('disabled','[]','{"one_move_or_standard":true,"strenuous_action_cost_1hp":true}',0.5,NULL,0),
('dying','[]','{"no_actions":true,"no_move":true,"unconscious":true,"end_round_d100_save":true}',NULL,NULL,0),
('dead','[]','{"no_actions":true,"no_move":true,"no_healing":true,"dead":true}',NULL,NULL,0),
('entangled','[{"stat":"attack","value":-2,"bonus_type":"untyped"},{"stat":"dexterity","value":-4,"bonus_type":"untyped"}]','{"cannot_run_charge":true}',0.5,NULL,0),
('exhausted','[{"stat":"strength","value":-6,"bonus_type":"untyped"},{"stat":"dexterity","value":-6,"bonus_type":"untyped"}]','{"cannot_run_charge":true}',0.5,NULL,0),
('fatigued','[{"stat":"strength","value":-2,"bonus_type":"untyped"},{"stat":"dexterity","value":-2,"bonus_type":"untyped"}]','{"cannot_run_charge":true}',NULL,NULL,0),
('fascinated','[{"stat":"reactive_skill","value":-4,"bonus_type":"untyped"}]','{"no_actions":true,"attention_only":true,"breaks_on_threat":true}',NULL,NULL,0),
('flatfooted','[]','{"loses_dex_ac":true,"no_aoo":true}',NULL,NULL,0),
('frightened','[{"stat":"attack","value":-2,"bonus_type":"untyped"},{"stat":"saving_throw","value":-2,"bonus_type":"untyped"},{"stat":"skill","value":-2,"bonus_type":"untyped"},{"stat":"ability_check","value":-2,"bonus_type":"untyped"}]','{"flee":true}',NULL,'fear',2),
('grappling','[]','{"limited_actions":true,"no_threaten_squares":true,"loses_dex_ac_vs_non_grapplers":true}',NULL,NULL,0),
('helpless','[]','{"helpless":true,"loses_dex_ac":true,"coup_de_grace_vulnerable":true}',NULL,NULL,0),
('invisible','[{"stat":"attack_vs_sighted","value":2,"bonus_type":"untyped"}]','{"ignores_target_dex_ac_if_target_cannot_see":true}',NULL,NULL,0),
('nauseated','[]','{"only_move_action":true,"cannot_attack":true,"cannot_cast":true,"cannot_concentrate":true}',NULL,NULL,0),
('panicked','[{"stat":"attack","value":-2,"bonus_type":"untyped"},{"stat":"saving_throw","value":-2,"bonus_type":"untyped"},{"stat":"skill","value":-2,"bonus_type":"untyped"},{"stat":"ability_check","value":-2,"bonus_type":"untyped"}]','{"no_actions":true,"flee":true,"drop_held_items":true}',NULL,'fear',3),
('paralyzed','[]','{"no_actions":true,"no_move":true,"helpless":true,"loses_dex_ac":true,"strength_zero":true,"dexterity_zero":true}',NULL,NULL,0),
('petrified','[]','{"no_actions":true,"no_move":true,"helpless":true,"unconscious":true}',NULL,NULL,0),
('pinned','[]','{"no_move":true,"limited_actions":true,"no_threaten_squares":true,"loses_dex_ac_vs_non_grapplers":true}',NULL,NULL,0),
('prone','[{"stat":"attack_melee","value":-4,"bonus_type":"untyped"},{"stat":"ac_melee","value":-4,"bonus_type":"untyped"},{"stat":"ac_ranged","value":4,"bonus_type":"untyped"}]','{"no_ranged_weapon_except_crossbows":true,"standing_provokes_aoo":true}',NULL,NULL,0),
('shaken','[{"stat":"attack","value":-2,"bonus_type":"untyped"},{"stat":"saving_throw","value":-2,"bonus_type":"untyped"},{"stat":"skill","value":-2,"bonus_type":"untyped"},{"stat":"ability_check","value":-2,"bonus_type":"untyped"}]','{}',NULL,'fear',1),
('sickened','[{"stat":"attack","value":-2,"bonus_type":"untyped"},{"stat":"damage","value":-2,"bonus_type":"untyped"},{"stat":"saving_throw","value":-2,"bonus_type":"untyped"},{"stat":"skill","value":-2,"bonus_type":"untyped"},{"stat":"ability_check","value":-2,"bonus_type":"untyped"}]','{}',NULL,NULL,0),
('stable','[]','{"no_actions":true,"no_move":true,"unconscious":true,"stable":true}',NULL,NULL,0),
('staggered','[]','{"one_move_or_standard":true,"no_full_round":true}',NULL,NULL,0),
('stunned','[{"stat":"ac","value":-2,"bonus_type":"untyped"}]','{"no_actions":true,"loses_dex_ac":true,"drop_held_items":true}',NULL,NULL,0),
('unconscious','[]','{"no_actions":true,"no_move":true,"helpless":true,"unconscious":true}',NULL,NULL,0),
('confused','[]','{"must_roll_d100_start_turn":true,"no_aoo_against_unengaged":true}',NULL,NULL,0),
('incorporeal','[]','{"immune_to_nonmagical_physical":true}',NULL,NULL,0),
('turned','[]','{"flee":true}',NULL,NULL,0),
('checked','[]','{"cannot_advance":true}',NULL,NULL,0),
('knockeddown','[]','{"prone":true}',NULL,NULL,0),
('blownaway','[]','{"displaced_by_wind":true}',NULL,NULL,0),
('abilitydamaged','[]','{"dynamic_ability_damage":true}',NULL,NULL,0),
('abilitydrained','[]','{"dynamic_ability_drain":true}',NULL,NULL,0),
('energydrained','[]','{"dynamic_negative_levels":true}',NULL,NULL,0)
ON CONFLICT (condition_id) DO UPDATE
SET modifiers=EXCLUDED.modifiers,flags=EXCLUDED.flags,speed_multiplier=EXCLUDED.speed_multiplier,
    stack_group=EXCLUDED.stack_group,stack_rank=EXCLUDED.stack_rank,enabled=true,updated_at=now();

CREATE OR REPLACE FUNCTION priv.srd_condition_modifier(
  p_campaign_id bigint,p_target_kind text,p_target_id text,p_stat text
)
RETURNS integer LANGUAGE sql STABLE SECURITY DEFINER
SET search_path=pg_catalog,public,priv,pg_temp
AS $function$
  WITH active AS (
    SELECT cc.condition_id,r.stack_group,r.stack_rank,r.modifiers,
      row_number() OVER (PARTITION BY r.stack_group ORDER BY r.stack_rank DESC,cc.condition_instance_id DESC) stack_order
    FROM public.srd_campaign_conditions cc
    JOIN priv.srd_condition_engine_rules r ON r.condition_id=cc.condition_id AND r.enabled
    WHERE cc.campaign_id=p_campaign_id AND cc.target_kind=p_target_kind AND cc.target_id=p_target_id AND cc.active
  ), selected AS (
    SELECT * FROM active WHERE stack_group IS NULL OR stack_order=1
  )
  SELECT COALESCE(sum((m.value->>'value')::integer),0)::integer
  FROM selected a CROSS JOIN LATERAL jsonb_array_elements(a.modifiers) m(value)
  WHERE m.value->>'stat'=p_stat AND COALESCE(m.value->>'value','') ~ '^-?[0-9]{1,3}$';
$function$;

CREATE OR REPLACE FUNCTION priv.srd_condition_has_flag(
  p_campaign_id bigint,p_target_kind text,p_target_id text,p_flag text
)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER
SET search_path=pg_catalog,public,priv,pg_temp
AS $function$
  SELECT EXISTS (
    SELECT 1 FROM public.srd_campaign_conditions cc
    JOIN priv.srd_condition_engine_rules r ON r.condition_id=cc.condition_id AND r.enabled
    WHERE cc.campaign_id=p_campaign_id AND cc.target_kind=p_target_kind AND cc.target_id=p_target_id
      AND cc.active AND COALESCE(r.flags->>p_flag,'false')='true'
  );
$function$;

CREATE OR REPLACE FUNCTION priv.srd_condition_speed_multiplier(
  p_campaign_id bigint,p_target_kind text,p_target_id text
)
RETURNS numeric LANGUAGE sql STABLE SECURITY DEFINER
SET search_path=pg_catalog,public,priv,pg_temp
AS $function$
  SELECT COALESCE(min(r.speed_multiplier),1)::numeric
  FROM public.srd_campaign_conditions cc
  JOIN priv.srd_condition_engine_rules r ON r.condition_id=cc.condition_id AND r.enabled
  WHERE cc.campaign_id=p_campaign_id AND cc.target_kind=p_target_kind AND cc.target_id=p_target_id
    AND cc.active AND r.speed_multiplier IS NOT NULL;
$function$;

CREATE OR REPLACE FUNCTION priv.srd_effective_modifier(
  p_campaign_id bigint,p_target_kind text,p_target_id text,p_stat text
)
RETURNS integer LANGUAGE sql STABLE SECURITY DEFINER
SET search_path=pg_catalog,public,priv,pg_temp
AS $function$
  WITH modifiers AS (
    SELECT COALESCE(NULLIF(m.value->>'bonus_type',''),'untyped') bonus_type,
           (m.value->>'value')::integer value
    FROM public.srd_campaign_effects e
    CROSS JOIN LATERAL jsonb_array_elements(
      CASE WHEN jsonb_typeof(e.effect_data->'modifiers')='array' THEN e.effect_data->'modifiers' ELSE '[]'::jsonb END
    ) m(value)
    WHERE e.campaign_id=p_campaign_id AND e.target_kind=p_target_kind AND e.target_id=p_target_id AND e.active
      AND m.value->>'stat'=p_stat AND COALESCE(m.value->>'value','') ~ '^-?[0-9]{1,3}$'
  ), positive_typed AS (
    SELECT bonus_type,max(value) value FROM modifiers
    WHERE value>0 AND bonus_type NOT IN ('untyped','dodge','circumstance') GROUP BY bonus_type
  )
  SELECT COALESCE((SELECT sum(value) FROM positive_typed),0)
       + COALESCE((SELECT sum(value) FROM modifiers WHERE value>0 AND bonus_type IN ('untyped','dodge','circumstance')),0)
       + COALESCE((SELECT sum(value) FROM modifiers WHERE value<0),0)
       + COALESCE(priv.srd_condition_modifier(p_campaign_id,p_target_kind,p_target_id,p_stat),0);
$function$;

DO $patch_action_economy$
DECLARE v_definition text; v_marker text;
BEGIN
  SELECT pg_get_functiondef('public.consumir_acao_turno_srd(bigint,text,text)'::regprocedure) INTO v_definition;
  v_marker:='  v_combat := COALESCE(v_campaign.combat_data, ''{}''::JSONB);';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Ponto de validação de ação não localizado.'; END IF;
  IF position('srd_condition_has_flag' IN v_definition)=0 THEN
    v_definition:=replace(v_definition,v_marker,
      E'  IF priv.srd_condition_has_flag(p_campaign_id,''character'',BTRIM(p_character_id),''no_actions'') THEN RAISE EXCEPTION ''A condição atual impede qualquer ação.''; END IF;\n' ||
      E'  IF v_action<>''movimento'' AND priv.srd_condition_has_flag(p_campaign_id,''character'',BTRIM(p_character_id),''only_move_action'') THEN RAISE EXCEPTION ''A condição atual permite somente uma ação de movimento.''; END IF;\n' ||
      v_marker);
  END IF;
  v_marker:='  IF LOWER(COALESCE(v_character_actions->>v_action, ''false'')) = ''true'' THEN';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Validação de ação repetida não localizada.'; END IF;
  IF position('one_move_or_standard' IN v_definition)=0 THEN
    v_definition:=replace(v_definition,v_marker,
      E'  IF priv.srd_condition_has_flag(p_campaign_id,''character'',BTRIM(p_character_id),''one_move_or_standard'')\n' ||
      E'     AND (LOWER(COALESCE(v_character_actions->>''padrao'',''false''))=''true'' OR LOWER(COALESCE(v_character_actions->>''movimento'',''false''))=''true'') THEN\n' ||
      E'    RAISE EXCEPTION ''A condição permite apenas uma ação padrão ou de movimento por rodada.'';\n' ||
      E'  END IF;\n' || v_marker);
  END IF;
  v_marker:='  UPDATE public.campaigns';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Persistência da economia de ações não localizada.'; END IF;
  IF position('strenuous_action_cost_1hp' IN v_definition)=0 THEN
    v_definition:=replace(v_definition,v_marker,
      E'  IF v_action=''padrao'' AND priv.srd_condition_has_flag(p_campaign_id,''character'',BTRIM(p_character_id),''strenuous_action_cost_1hp'') THEN\n' ||
      E'    UPDATE public.srd_character_sheets SET pv_atual=-1 WHERE character_id::text=BTRIM(p_character_id) AND COALESCE(pv_atual,0)=0;\n' ||
      E'    IF FOUND THEN PERFORM priv.srd_sync_character_vital_condition(BTRIM(p_character_id),-1,false); END IF;\n' ||
      E'  END IF;\n' || v_marker);
  END IF;
  EXECUTE v_definition;
END;
$patch_action_economy$;

DO $patch_player_movement$
DECLARE v_definition text; v_marker text;
BEGIN
  SELECT pg_get_functiondef('public.mover_token_player_cba(bigint,text,integer,integer)'::regprocedure) INTO v_definition;
  v_marker:='  v_speed_m := public.srd35_deslocamento_personagem(v_character_id,v_speed_m);';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Cálculo de deslocamento do jogador não localizado.'; END IF;
  IF position('srd_condition_speed_multiplier' IN v_definition)=0 THEN
    v_definition:=replace(v_definition,v_marker,
      E'  IF priv.srd_condition_has_flag(p_campaign_id,''character'',v_character_id,''no_move'') THEN RAISE EXCEPTION ''A condição atual impede movimentação.''; END IF;\n' ||
      v_marker || E'\n  v_speed_m:=v_speed_m*priv.srd_condition_speed_multiplier(p_campaign_id,''character'',v_character_id);');
  END IF;
  EXECUTE v_definition;
END;
$patch_player_movement$;

DO $patch_gm_movement$
DECLARE v_definition text; v_marker text;
BEGIN
  SELECT pg_get_functiondef('public.mover_token_gm_cba_srd(bigint,text,integer,integer)'::regprocedure) INTO v_definition;
  v_marker:='    v_speed_m := v_speed_number::NUMERIC;';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Leitura de deslocamento do token não localizada.'; END IF;
  IF position('srd_condition_speed_multiplier' IN v_definition)=0 THEN
    v_definition:=replace(v_definition,v_marker,
      v_marker || E'\n    IF v_token_type<>''player'' THEN\n' ||
      E'      IF priv.srd_condition_has_flag(p_campaign_id,''token'',BTRIM(p_token_id),''no_move'') THEN RAISE EXCEPTION ''A condição atual impede movimentação.''; END IF;\n' ||
      E'      v_speed_m:=v_speed_m*priv.srd_condition_speed_multiplier(p_campaign_id,''token'',BTRIM(p_token_id));\n' ||
      E'    END IF;');
    v_marker:='    v_speed_m:=public.srd35_deslocamento_personagem(BTRIM(p_token_id),v_speed_m);';
    IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Deslocamento racial do token jogador não localizado.'; END IF;
    v_definition:=replace(v_definition,v_marker,
      E'    IF priv.srd_condition_has_flag(p_campaign_id,''character'',BTRIM(p_token_id),''no_move'') THEN RAISE EXCEPTION ''A condição atual impede movimentação.''; END IF;\n' ||
      v_marker || E'\n    v_speed_m:=v_speed_m*priv.srd_condition_speed_multiplier(p_campaign_id,''character'',BTRIM(p_token_id));');
  END IF;
  EXECUTE v_definition;
END;
$patch_gm_movement$;

DO $patch_attack_condition_guards$
DECLARE v_definition text; v_marker text;
BEGIN
  SELECT pg_get_functiondef('public.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer)'::regprocedure) INTO v_definition;
  v_marker:=' v_effective_attack_modifier:=priv.srd_effective_modifier(p_campaign_id,''character'',BTRIM(p_character_id),''attack'');';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Modificador de ataque não localizado.'; END IF;
  IF position('no_actions' IN v_definition)=0 THEN
    v_definition:=replace(v_definition,v_marker,
      E' IF priv.srd_condition_has_flag(p_campaign_id,''character'',BTRIM(p_character_id),''no_actions'') OR priv.srd_condition_has_flag(p_campaign_id,''character'',BTRIM(p_character_id),''cannot_attack'') THEN RAISE EXCEPTION ''A condição atual impede ataques.''; END IF;\n' ||
      v_marker);
  END IF;
  v_definition:=replace(v_definition,
    'v_effective_attack_modifier:=priv.srd_effective_modifier(p_campaign_id,''character'',BTRIM(p_character_id),''attack'');',
    'v_effective_attack_modifier:=priv.srd_effective_modifier(p_campaign_id,''character'',BTRIM(p_character_id),''attack'')+CASE WHEN p_attack_type=''atk-corpo'' THEN priv.srd_effective_modifier(p_campaign_id,''character'',BTRIM(p_character_id),''attack_melee'') ELSE priv.srd_effective_modifier(p_campaign_id,''character'',BTRIM(p_character_id),''attack_ranged'') END;');
  v_definition:=replace(v_definition,
    'v_effective_ac_modifier:=priv.srd_effective_modifier(p_campaign_id,''token'',BTRIM(p_token_id),''ac'');',
    'v_effective_ac_modifier:=priv.srd_effective_modifier(p_campaign_id,''token'',BTRIM(p_token_id),''ac'')+CASE WHEN p_attack_type=''atk-corpo'' THEN priv.srd_effective_modifier(p_campaign_id,''token'',BTRIM(p_token_id),''ac_melee'') ELSE priv.srd_effective_modifier(p_campaign_id,''token'',BTRIM(p_token_id),''ac_ranged'') END;');
  EXECUTE v_definition;
END;
$patch_attack_condition_guards$;

DO $patch_spell_condition_guards$
DECLARE v_definition text; v_marker text;
BEGIN
  SELECT pg_get_functiondef('public.conjurar_magia_srd_manual(text,text,smallint,text,integer[])'::regprocedure) INTO v_definition;
  v_marker:='  SELECT s.* INTO v_sheet FROM public.srd_character_sheets s';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Ponto de validação de personagem para magia não localizado.'; END IF;
  IF position('cannot_cast' IN v_definition)=0 THEN
    v_definition:=replace(v_definition,v_marker,
      E'  IF priv.srd_condition_has_flag(v_campaign_id,''character'',BTRIM(p_character_id),''no_actions'') OR priv.srd_condition_has_flag(v_campaign_id,''character'',BTRIM(p_character_id),''cannot_cast'') THEN RAISE EXCEPTION ''A condição atual impede conjurar magias.''; END IF;\n' ||
      v_marker);
  END IF;
  EXECUTE v_definition;
END;
$patch_spell_condition_guards$;

REVOKE ALL ON FUNCTION priv.srd_condition_modifier(bigint,text,text,text) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION priv.srd_condition_has_flag(bigint,text,text,text) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION priv.srd_condition_speed_multiplier(bigint,text,text) FROM PUBLIC, anon, authenticated;
