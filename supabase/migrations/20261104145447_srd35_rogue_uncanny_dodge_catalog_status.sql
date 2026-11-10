UPDATE public.srd_class_level_features
SET summary='Esquiva Sobrenatural: mantém o bônus de Destreza na CA quando surpreendido ou atacado por criatura invisível. Ainda perde Destreza quando uma condição incapacitante remove esse bônus.',
    mechanics=mechanics||jsonb_build_object('engine_status','implemented','implemented_features',jsonb_build_array('uncanny_dodge_flatfooted','uncanny_dodge_invisible_attacker','retains_dex_unless_other_dex_loss'),'pending_features','[]'::jsonb)
WHERE class_id='ladino' AND class_level=4;

UPDATE public.srd_class_level_features
SET summary='Esquiva Sobrenatural Aprimorada: preserva a proteção contra flanqueamento, exceto contra atacante com pelo menos quatro níveis a mais em classe que concede Esquiva Sobrenatural. O motor já expõe o nível e a característica; a resolução de flanqueamento permanece pendente.',
    mechanics=mechanics||jsonb_build_object('engine_status','partial','implemented_features',jsonb_build_array('uncanny_dodge_flatfooted','uncanny_dodge_invisible_attacker','improved_uncanny_dodge_level_flag'),'pending_features',jsonb_build_array('flanking_resolution','higher_level_flanker_exception'))
WHERE class_id='ladino' AND class_level=8;