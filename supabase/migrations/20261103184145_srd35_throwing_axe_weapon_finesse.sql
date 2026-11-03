UPDATE public.srd_equipment
SET detalhes = COALESCE(detalhes, '{}'::jsonb) || jsonb_build_object('weapon_finesse_eligible', TRUE)
WHERE id = 'machado_mao' AND categoria = 'arma';