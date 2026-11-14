UPDATE public.srd_class_level_features
SET summary='Recebe +2 em testes de Vontade contra magias e efeitos da escola Encantamento.',
    mechanics=mechanics||jsonb_build_object(
      'engine_status','implemented',
      'implemented_features',to_jsonb(ARRAY['still_mind','fast_movement_bonus']::text[]),
      'pending_features','[]'::jsonb
    )
WHERE class_id='monge' AND class_level=3;

UPDATE public.srd_class_level_features
SET mechanics=mechanics||jsonb_build_object(
      'engine_status','partial',
      'implemented_features',to_jsonb(ARRAY['fast_movement','rage_core','rage_skill_restrictions']::text[]),
      'pending_features',to_jsonb(ARRAY['illiteracy_scroll_reading_guard']::text[])
    )
WHERE class_id='barbaro' AND class_level=1;