
UPDATE public.srd_class_level_features
SET mechanics = COALESCE(mechanics,'{}'::jsonb) || jsonb_build_object(
  'engine_status',CASE WHEN class_level=16 THEN 'partial' ELSE 'implemented' END,
  'implemented_features',jsonb_build_array('damage_reduction'),
  'pending_features',CASE WHEN class_level=16 THEN jsonb_build_array('rage 5/day') ELSE '[]'::jsonb END,
  'engine_rule',jsonb_build_object(
    'kind','passive_damage_reduction',
    'value',LEAST(5,GREATEST(1,FLOOR((class_level-4)::numeric/3)::integer)),
    'damage_type','physical',
    'bypass','none'
  )
)
WHERE class_id='barbaro'
  AND class_level IN (7,10,13,16,19)
  AND (mechanics->>'source_text') ILIKE 'Damage reduction%';
