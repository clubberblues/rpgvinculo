UPDATE public.srd_class_level_features
SET summary='Graça Divina adiciona o modificador de Carisma às resistências. Imposição das Mãos cura aliados e o Paladino ou causa dano positivo a mortos-vivos com um ataque de toque bem-sucedido.',
    mechanics=mechanics||jsonb_build_object(
      'engine_status','implemented',
      'implemented_features',to_jsonb(ARRAY['divine_grace','lay_on_hands_healing','lay_on_hands_harm_undead']::text[]),
      'pending_features','[]'::jsonb
    )
WHERE class_id='paladino' AND class_level=2;