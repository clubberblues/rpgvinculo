UPDATE public.srd_class_level_features
SET summary='Mantém o bônus de Destreza na CA quando surpreendido ou atacado por criatura invisível, exceto quando incapacitado.',
    mechanics=mechanics||jsonb_build_object(
      'engine_status','implemented',
      'implemented_features',to_jsonb(ARRAY['uncanny_dodge']::text[]),
      'pending_features','[]'::jsonb
    )
WHERE class_id='barbaro' AND class_level=2;

UPDATE public.srd_class_level_features
SET summary='Não pode ser flanqueado, exceto por um atacante com pelo menos quatro níveis a mais em uma classe que concede Esquiva Sobrenatural.',
    mechanics=mechanics||jsonb_build_object(
      'engine_status','partial',
      'implemented_features',to_jsonb(ARRAY['improved_uncanny_dodge_flag']::text[]),
      'pending_features',to_jsonb(ARRAY['flanking_resolution']::text[])
    )
WHERE class_id='barbaro' AND class_level=5;

UPDATE public.srd_class_level_features
SET summary='Recebe +'|| (class_level/3)::text ||' em testes de Reflexos e CA contra armadilhas.',
    mechanics=mechanics||jsonb_build_object(
      'engine_status','implemented',
      'implemented_features',CASE WHEN class_level=12
        THEN to_jsonb(ARRAY['rage_uses','trap_sense_ac_bonus','trap_sense_reflex_bonus']::text[])
        ELSE to_jsonb(ARRAY['trap_sense_ac_bonus','trap_sense_reflex_bonus']::text[]) END,
      'pending_features','[]'::jsonb
    )
WHERE class_id='barbaro' AND class_level IN (3,6,9,12,15,18);

UPDATE public.srd_class_level_features
SET mechanics=mechanics||jsonb_build_object(
      'engine_status','partial',
      'implemented_features',to_jsonb(ARRAY['fast_movement','rage_core']::text[]),
      'pending_features',to_jsonb(ARRAY['illiteracy','rage_skill_restrictions']::text[])
    )
WHERE class_id='barbaro' AND class_level=1;