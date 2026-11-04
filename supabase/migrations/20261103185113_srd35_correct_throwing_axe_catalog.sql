-- Corrige a distinção entre Machadinha (handaxe) e Machado de Arremesso.
UPDATE public.srd_equipment
SET nome='Machadinha',
    detalhes=(COALESCE(detalhes,'{}'::jsonb)-'weapon_ranged'-'range_increment_m'-'ranged_damage_uses_strength')
      || jsonb_build_object('weapon_melee',TRUE,'weapon_light',TRUE,'weapon_finesse_eligible',TRUE,
        'weapon_proficiency_name','Machadinha','weapon_focus_name','Machadinha')
WHERE id='machado_mao' AND categoria='arma';

UPDATE public.srd_equipment
SET nome='Machado de Arremesso',
    detalhes=COALESCE(detalhes,'{}'::jsonb)
      || jsonb_build_object('weapon_melee',TRUE,'weapon_ranged',TRUE,'range_increment_m',3,
        'ranged_damage_uses_strength',TRUE,'weapon_light',TRUE,'weapon_finesse_eligible',TRUE,
        'weapon_proficiency_name','Machado de Arremesso','weapon_focus_name','Machado de Arremesso')
WHERE id='machadinha' AND categoria='arma';

-- A Espada Larga do catálogo corresponde à falcione (arma de duas mãos).
UPDATE public.srd_equipment
SET detalhes=COALESCE(detalhes,'{}'::jsonb)||jsonb_build_object('weapon_two_handed',TRUE)
WHERE id='espada_larga' AND categoria='arma';

-- O Mangual do catálogo é o mangual leve (1d8), uma arma de uma mão.
UPDATE public.srd_equipment
SET detalhes=COALESCE(detalhes,'{}'::jsonb)-'weapon_two_handed'
WHERE id='mangual' AND categoria='arma';