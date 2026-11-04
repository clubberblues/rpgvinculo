UPDATE public.srd_spell_effects
SET effect_kind='damage',
    target_kind='area',
    saving_throw=NULL,
    save_result=NULL,
    spell_resistance=true,
    damage_expression='3d6+2d6',
    verification_status='verified_srd',
    parameters=jsonb_set(
      COALESCE(parameters,'{}'::jsonb),
      '{engine_rule}',
      '{
        "resolver":"damage",
        "effect_kind":"damage",
        "damage_expression":"3d6",
        "damage_type":"bludgeoning",
        "damage_components":[
          {"damage_type":"bludgeoning","roll_key":"primary_damage"},
          {"damage_type":"cold","roll_key":"damage_cold"}
        ],
        "extra_rolls":[
          {"key":"damage_cold","expression":"2d6"}
        ],
        "save_result":"none",
        "spell_resistance":true,
        "partial_scope":"selected_creatures_only_area_geometry_and_timing_manual"
      }'::jsonb,
      true
    ) || jsonb_build_object(
      'automation_status','verified_partial_multi_target',
      'effect_schema_version',1
    )
WHERE spell_id='srd35_spell_ice_storm' AND effect_index=1
  AND verification_status='needs_review';

UPDATE public.srd_spells
SET dados_tecnicos = COALESCE(dados_tecnicos,'{}'::jsonb)
  || jsonb_build_object(
    'target_mode','multiple_targets_pending',
    'engine_status','partial_multi_target',
    'verification_scope','individual_record_on_consulted_spell_page',
    'partial_scope','damage_to_selected_creatures_only; area geometry and one-full-round timing remain manual'
  )
WHERE id='srd35_spell_ice_storm'
  AND dados_tecnicos->>'engine_status'='needs_implementation';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.srd_spell_effects
    WHERE spell_id='srd35_spell_ice_storm'
      AND effect_index=1
      AND verification_status='verified_srd'
      AND parameters->'engine_rule'->>'resolver'='damage'
      AND parameters->'engine_rule'->'extra_rolls'->0->>'expression'='2d6'
      AND parameters->'engine_rule'->'damage_components'->0->>'damage_type'='bludgeoning'
      AND parameters->'engine_rule'->'damage_components'->1->>'damage_type'='cold'
  ) THEN
    RAISE EXCEPTION 'Ice Storm engine rule verification failed.';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.srd_spells
    WHERE id='srd35_spell_ice_storm'
      AND dados_tecnicos->>'target_mode'='multiple_targets_pending'
      AND dados_tecnicos->>'engine_status'='partial_multi_target'
  ) THEN
    RAISE EXCEPTION 'Ice Storm target mode verification failed.';
  END IF;
END $$;
