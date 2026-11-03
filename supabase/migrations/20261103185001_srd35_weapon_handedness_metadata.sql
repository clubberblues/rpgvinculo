-- Propriedades usadas por Ataque Poderoso (D&D 3.5).
UPDATE public.srd_equipment
SET detalhes = COALESCE(detalhes, '{}'::jsonb) || jsonb_build_object('weapon_light', TRUE)
WHERE categoria='arma' AND id=ANY(ARRAY[
  'adaga','foice','maca_leve','machadinha','machado_mao','martelo_leve',
  'picareta_leve','espada_curta','kukri','kama','nunchaku','sai','siangham','porrete'
]);

UPDATE public.srd_equipment
SET detalhes = COALESCE(detalhes, '{}'::jsonb) || jsonb_build_object('weapon_two_handed', TRUE)
WHERE categoria='arma' AND id=ANY(ARRAY[
  'alabarda','bordao','clava_grande','corrente_espinhosa','espada_grande',
  'foice_grande','glaive','guisarme','lanca','lanca_longa','lanca_montaria',
  'machado_grande','mangual','ranseur'
]);