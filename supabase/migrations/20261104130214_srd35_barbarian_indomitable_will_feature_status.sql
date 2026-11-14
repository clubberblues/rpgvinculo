UPDATE public.srd_class_level_features
SET summary='Enquanto estiver em Fúria, recebe +4 nos testes de Vontade contra magias da escola de Encantamento. Esse bônus se acumula com o bônus normal de Vontade da Fúria.',
    mechanics=mechanics||jsonb_build_object(
      'engine_status','implemented',
      'implemented_features',to_jsonb(ARRAY['indomitable_will']::text[]),
      'pending_features','[]'::jsonb
    )
WHERE class_id='barbaro' AND class_level=14;