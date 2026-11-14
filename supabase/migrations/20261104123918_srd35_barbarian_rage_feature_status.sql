UPDATE public.srd_class_level_features
SET mechanics = mechanics || jsonb_build_object(
  'engine_status','partial',
  'implemented_features',to_jsonb(ARRAY['fast_movement','rage']::text[]),
  'pending_features',to_jsonb(ARRAY['illiteracy']::text[])
)
WHERE class_id='barbaro' AND class_level=1;

UPDATE public.srd_class_level_features
SET mechanics = mechanics || jsonb_build_object(
  'engine_status','implemented',
  'implemented_features',to_jsonb(ARRAY['rage_uses']::text[]),
  'pending_features','[]'::jsonb
)
WHERE class_id='barbaro' AND class_level IN (4,8);

UPDATE public.srd_class_level_features
SET mechanics = mechanics || jsonb_build_object(
  'engine_status','implemented',
  'implemented_features',to_jsonb(ARRAY['greater_rage']::text[]),
  'pending_features','[]'::jsonb
)
WHERE class_id='barbaro' AND class_level=11;

UPDATE public.srd_class_level_features
SET mechanics = mechanics || jsonb_build_object(
  'engine_status','partial',
  'implemented_features',to_jsonb(ARRAY['rage_uses']::text[]),
  'pending_features',to_jsonb(ARRAY['trap_sense_4']::text[])
)
WHERE class_id='barbaro' AND class_level=12;

UPDATE public.srd_class_level_features
SET mechanics = mechanics || jsonb_build_object(
  'engine_status','implemented',
  'implemented_features',to_jsonb(ARRAY['damage_reduction','rage_uses']::text[]),
  'pending_features','[]'::jsonb
)
WHERE class_id='barbaro' AND class_level=16;

UPDATE public.srd_class_level_features
SET mechanics = mechanics || jsonb_build_object(
  'engine_status','implemented',
  'implemented_features',to_jsonb(ARRAY['tireless_rage']::text[]),
  'pending_features','[]'::jsonb
)
WHERE class_id='barbaro' AND class_level=17;

UPDATE public.srd_class_level_features
SET mechanics = mechanics || jsonb_build_object(
  'engine_status','implemented',
  'implemented_features',to_jsonb(ARRAY['mighty_rage','rage_uses']::text[]),
  'pending_features','[]'::jsonb
)
WHERE class_id='barbaro' AND class_level=20;