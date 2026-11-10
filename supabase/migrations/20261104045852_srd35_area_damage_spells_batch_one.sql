
WITH rules(spell_id,damage_type,max_dice,damage_die,save_type,save_result,spell_resistance) AS (
  VALUES
    ('srd35_burning_hands','fire',5,4,'reflex','half',true),
    ('srd35_spell_lightning_bolt','electricity',10,6,'reflex','half',true),
    ('srd35_spell_fire_storm','fire',20,6,'reflex','half',true),
    ('srd35_spell_cone_of_cold','cold',15,6,'reflex','half',true)
)
UPDATE public.srd_spell_effects e
SET effect_kind='damage',
    verification_status='verified_srd',
    damage_expression='1d'||r.damage_die::text,
    parameters=jsonb_set(
      COALESCE(e.parameters,'{}'::jsonb),
      '{engine_rule}',
      jsonb_build_object(
        'resolver','damage',
        'effect_kind','damage',
        'damage_expression','1d'||r.damage_die::text,
        'damage_type',r.damage_type,
        'damage_scaling',jsonb_build_object('base_dice',1,'dice_per_level',1,'start_level',1,'every_levels',1,'cap_dice',r.max_dice),
        'save_type',r.save_type,
        'save_result',r.save_result,
        'spell_resistance',r.spell_resistance,
        'partial_scope','selected_creatures_only_area_geometry_and_object_effects_manual'
      ),
      true
    )
FROM rules r
WHERE e.spell_id=r.spell_id AND e.effect_index=1;

WITH ids(spell_id) AS (
  VALUES ('srd35_burning_hands'),('srd35_spell_lightning_bolt'),('srd35_spell_fire_storm'),('srd35_spell_cone_of_cold')
)
UPDATE public.srd_spells s
SET dados_tecnicos=jsonb_set(
  jsonb_set(COALESCE(s.dados_tecnicos,'{}'::jsonb),'{engine_status}','"partial_multi_target"'::jsonb,true),
  '{target_mode}','"multiple_targets_pending"'::jsonb,true
)
FROM ids
WHERE s.id=ids.spell_id;
