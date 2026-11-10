
UPDATE public.srd_class_level_features
SET mechanics=COALESCE(mechanics,'{}'::jsonb)||jsonb_build_object(
 'engine_status','partial',
 'implemented_features',jsonb_build_array('divine_grace','lay_on_hands_healing'),
 'pending_features',jsonb_build_array('lay_on_hands_harm_undead'),
 'engine_rule',jsonb_build_object(
   'kind','active_feature',
   'key','lay_on_hands',
   'resource_pool','paladin_level * max(0, charisma_modifier)',
   'reset','long_rest',
   'action','standard',
   'target','touch'
 )
)
WHERE class_id='paladino' AND class_level=2
  AND (mechanics->>'source_text') ILIKE '%Divine grace%'
  AND (mechanics->>'source_text') ILIKE '%Lay on hands%';
