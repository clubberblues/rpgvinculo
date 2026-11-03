-- D&D 3.5: armas de arremesso alcançam no máximo 5 incrementos;
-- armas de disparo alcançam no máximo 10 incrementos.
UPDATE public.srd_equipment
SET detalhes=COALESCE(detalhes,'{}'::jsonb)||jsonb_build_object('weapon_ranged_type','thrown','max_range_increments',5)
WHERE categoria='arma' AND id=ANY(ARRAY[
  'adaga','clava','lanca','lanca_curta','machadinha','martelo_leve','tridente','dardo','rede','shuriken_10'
]);

UPDATE public.srd_equipment
SET detalhes=COALESCE(detalhes,'{}'::jsonb)||jsonb_build_object('weapon_ranged_type','projectile','max_range_increments',10)
WHERE categoria='arma' AND id=ANY(ARRAY[
  'arco_curto','arco_curto_composto','arco_longo','arco_longo_composto',
  'besta_mao','besta_leve','besta_pesada','besta_repeticao_leve','funda'
]);