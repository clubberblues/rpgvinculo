-- Alcances e modos de uso conferidos na Tabela 7-5 do Livro do Jogador 3.5.
UPDATE public.srd_equipment
SET detalhes = COALESCE(detalhes, '{}'::jsonb) || jsonb_build_object(
  'weapon_ranged', TRUE, 'weapon_melee', FALSE, 'range_increment_m', v.range_m
)
FROM (VALUES
  ('arco_curto',18.0),('arco_curto_composto',21.0),('arco_longo',30.0),('arco_longo_composto',33.0),
  ('besta_mao',9.0),('besta_leve',24.0),('besta_pesada',36.0),('besta_repeticao_leve',24.0),
  ('dardo',6.0),('funda',15.0),('rede',3.0),('shuriken_10',3.0)
) AS v(id,range_m)
WHERE public.srd_equipment.id = v.id AND public.srd_equipment.categoria = 'arma';

-- Armas que podem ser usadas tanto em combate corporal quanto arremessadas.
UPDATE public.srd_equipment
SET detalhes = COALESCE(detalhes, '{}'::jsonb) || jsonb_build_object(
  'weapon_ranged', TRUE, 'weapon_melee', TRUE, 'range_increment_m', v.range_m,
  'ranged_damage_uses_strength', TRUE
)
FROM (VALUES
  ('adaga',3.0),('clava',3.0),('lanca_curta',6.0),('lanca',6.0),
  ('machado_mao',3.0),('martelo_leve',6.0),('tridente',3.0)
) AS v(id,range_m)
WHERE public.srd_equipment.id = v.id AND public.srd_equipment.categoria = 'arma';

-- Força também é aplicada ao dano das armas de arremesso e da funda.
UPDATE public.srd_equipment
SET detalhes = COALESCE(detalhes, '{}'::jsonb) || jsonb_build_object('ranged_damage_uses_strength', TRUE)
WHERE categoria = 'arma' AND id IN ('dardo','funda','shuriken_10');
