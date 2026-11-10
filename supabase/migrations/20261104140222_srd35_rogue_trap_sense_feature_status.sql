UPDATE public.srd_class_level_features
SET summary='Recebe Sentido para Armadilhas +1 na CA e em Reflexos contra armadilhas. Ataque Furtivo +2d6 permanece pendente de integração ao dano.',
    mechanics=mechanics||jsonb_build_object('engine_status','partial','implemented_features',to_jsonb(ARRAY['trap_sense_ca_bonus','trap_sense_reflex_bonus']::text[]),'pending_features',to_jsonb(ARRAY['sneak_attack_damage']::text[]))
WHERE class_id='ladino' AND class_level=3;

UPDATE public.srd_class_level_features
SET summary='Recebe Sentido para Armadilhas +2 na CA e em Reflexos contra armadilhas.',
    mechanics=mechanics||jsonb_build_object('engine_status','implemented','implemented_features',to_jsonb(ARRAY['trap_sense_ca_bonus','trap_sense_reflex_bonus']::text[]),'pending_features','[]'::jsonb)
WHERE class_id='ladino' AND class_level=6;

UPDATE public.srd_class_level_features
SET summary='Recebe Sentido para Armadilhas +3 na CA e em Reflexos contra armadilhas. Ataque Furtivo +5d6 permanece pendente de integração ao dano.',
    mechanics=mechanics||jsonb_build_object('engine_status','partial','implemented_features',to_jsonb(ARRAY['trap_sense_ca_bonus','trap_sense_reflex_bonus']::text[]),'pending_features',to_jsonb(ARRAY['sneak_attack_damage']::text[]))
WHERE class_id='ladino' AND class_level=9;

UPDATE public.srd_class_level_features
SET summary='Recebe Sentido para Armadilhas +4 na CA e em Reflexos contra armadilhas.',
    mechanics=mechanics||jsonb_build_object('engine_status','implemented','implemented_features',to_jsonb(ARRAY['trap_sense_ca_bonus','trap_sense_reflex_bonus']::text[]),'pending_features','[]'::jsonb)
WHERE class_id='ladino' AND class_level=12;

UPDATE public.srd_class_level_features
SET summary='Recebe Sentido para Armadilhas +5 na CA e em Reflexos contra armadilhas. Ataque Furtivo +8d6 permanece pendente de integração ao dano.',
    mechanics=mechanics||jsonb_build_object('engine_status','partial','implemented_features',to_jsonb(ARRAY['trap_sense_ca_bonus','trap_sense_reflex_bonus']::text[]),'pending_features',to_jsonb(ARRAY['sneak_attack_damage']::text[]))
WHERE class_id='ladino' AND class_level=15;

UPDATE public.srd_class_level_features
SET summary='Recebe Sentido para Armadilhas +6 na CA e em Reflexos contra armadilhas.',
    mechanics=mechanics||jsonb_build_object('engine_status','implemented','implemented_features',to_jsonb(ARRAY['trap_sense_ca_bonus','trap_sense_reflex_bonus']::text[]),'pending_features','[]'::jsonb)
WHERE class_id='ladino' AND class_level=18;