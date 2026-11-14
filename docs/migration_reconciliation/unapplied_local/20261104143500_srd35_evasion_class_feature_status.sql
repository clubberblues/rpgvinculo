-- Atualiza o catálogo após validação de Evasão e Evasão Aprimorada.
UPDATE public.srd_class_level_features
SET summary='Evasão: em um teste de Reflexos bem-sucedido contra um efeito que normalmente causa metade do dano, não sofre dano. Exige armadura leve ou nenhuma armadura.',
    mechanics=mechanics||jsonb_build_object('engine_status','implemented','implemented_features',to_jsonb(ARRAY['evasion_reflex_zero_damage','light_or_no_armor_requirement']::text[]),'pending_features','[]'::jsonb)
WHERE class_id='ladino' AND class_level=2;

UPDATE public.srd_class_level_features
SET summary='Recebe Evasão. Em Reflexos bem-sucedido contra efeitos de dano reduzido à metade, não sofre dano; a habilidade exige armadura leve ou nenhuma armadura.',
    mechanics=mechanics||jsonb_build_object('engine_status','partial','implemented_features',to_jsonb(ARRAY['evasion_reflex_zero_damage','light_or_no_armor_requirement']::text[]),'pending_features',to_jsonb(ARRAY['bonus_feat_selection']::text[]))
WHERE class_id='monge' AND class_level=2;

UPDATE public.srd_class_level_features
SET summary='Evasão Aprimorada: não sofre dano em um sucesso de Reflexos e sofre apenas metade do dano em uma falha, desde que use armadura leve ou nenhuma armadura.',
    mechanics=mechanics||jsonb_build_object('engine_status','implemented','implemented_features',to_jsonb(ARRAY['improved_evasion_reflex_zero_on_success','improved_evasion_half_on_failure','light_or_no_armor_requirement']::text[]),'pending_features','[]'::jsonb)
WHERE class_id='monge' AND class_level=9;

UPDATE public.srd_class_level_features
SET summary='Evasão: em um teste de Reflexos bem-sucedido contra um efeito que normalmente causa metade do dano, não sofre dano. Exige armadura leve ou nenhuma armadura.',
    mechanics=mechanics||jsonb_build_object('engine_status','implemented','implemented_features',to_jsonb(ARRAY['evasion_reflex_zero_damage','light_or_no_armor_requirement']::text[]),'pending_features','[]'::jsonb)
WHERE class_id='ranger' AND class_level=9;
