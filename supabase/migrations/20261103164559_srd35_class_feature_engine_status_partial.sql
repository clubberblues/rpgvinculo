UPDATE public.srd_class_level_features
SET mechanics = jsonb_set(
  jsonb_set(
    jsonb_set(COALESCE(mechanics,'{}'::jsonb),'{engine_status}','"partial"'::jsonb,true),
    '{implemented_features}','["fast_movement"]'::jsonb,true
  ),
  '{pending_features}','["illiteracy","rage"]'::jsonb,true
)
WHERE class_id='barbaro' AND class_level=1;

UPDATE public.srd_class_level_features
SET mechanics = jsonb_set(
  jsonb_set(
    jsonb_set(COALESCE(mechanics,'{}'::jsonb),'{engine_status}','"partial"'::jsonb,true),
    '{implemented_features}','["fast_movement_bonus"]'::jsonb,true
  ),
  '{pending_features}',jsonb_build_array(name),true
)
WHERE class_id='monge' AND class_level IN (3,6,9,12,15,18);
