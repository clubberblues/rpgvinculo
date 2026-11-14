
UPDATE public.srd_spell_effects
SET verification_status='verified_srd',
    damage_expression='1d6',
    parameters=jsonb_set(COALESCE(parameters,'{}'::jsonb),'{engine_rule}',
      '{"resolver":"damage","effect_kind":"damage","damage_expression":"1d6","damage_type":"mixed","damage_scaling":{"base_dice":1,"dice_per_level":1,"start_level":1,"every_levels":1,"cap_dice":15},"damage_components":[{"damage_type":"fire","ratio":0.5},{"damage_type":"untyped","ratio":0.5}],"save_type":"reflex","save_result":"half","spell_resistance":true,"partial_scope":"selected_creatures_only_area_geometry_manual"}'::jsonb,true)
WHERE spell_id='srd35_spell_flame_strike' AND effect_index=1;
UPDATE public.srd_spells
SET dados_tecnicos=jsonb_set(jsonb_set(COALESCE(dados_tecnicos,'{}'::jsonb),'{engine_status}','"partial_multi_target"'::jsonb,true),'{target_mode}','"multiple_targets_pending"'::jsonb,true)
WHERE id='srd35_spell_flame_strike';
