-- SRD 3.5 weapon proficiency categories, verified against the official open SRD weapon table.
-- Source: https://www.d20srd.org/srd/equipment/weapons.htm (Simple, Martial and Exotic Weapons tables).
UPDATE public.srd_equipment
SET detalhes = COALESCE(detalhes,'{}'::jsonb) ||
  jsonb_build_object(
    'weapon_proficiency', CASE id
      WHEN 'besta_repeticao_leve' THEN 'exotic'
      WHEN 'besta_pesada' THEN 'simple'
      WHEN 'bordao' THEN 'simple'
      WHEN 'chicote' THEN 'exotic'
      WHEN 'cimitarra' THEN 'martial'
      WHEN 'clava' THEN 'simple'
      WHEN 'clava_grande' THEN 'martial'
      WHEN 'corrente_espinhosa' THEN 'exotic'
      WHEN 'dardo' THEN 'simple'
      WHEN 'espada_curta' THEN 'martial'
      WHEN 'espada_grande' THEN 'martial'
      WHEN 'espada_larga' THEN 'martial'
      WHEN 'espada_longa' THEN 'martial'
      WHEN 'foice' THEN 'simple'
      WHEN 'foice_grande' THEN 'martial'
      WHEN 'funda' THEN 'simple'
      WHEN 'glaive' THEN 'martial'
      WHEN 'guisarme' THEN 'martial'
      WHEN 'kama' THEN 'exotic'
      WHEN 'kukri' THEN 'martial'
      WHEN 'lanca' THEN 'simple'
      WHEN 'lanca_curta' THEN 'simple'
      WHEN 'lanca_longa' THEN 'martial'
      WHEN 'lanca_montaria' THEN 'martial'
      WHEN 'maca_estrela' THEN 'simple'
      WHEN 'maca_leve' THEN 'simple'
      WHEN 'maca_pesada' THEN 'simple'
      WHEN 'machadinha' THEN 'martial'
      WHEN 'machado_batalha' THEN 'martial'
      WHEN 'machado_mao' THEN 'martial'
      WHEN 'machado_grande' THEN 'martial'
      WHEN 'mangual' THEN 'martial'
      WHEN 'martelo_guerra' THEN 'martial'
      WHEN 'martelo_leve' THEN 'martial'
      WHEN 'nunchaku' THEN 'exotic'
      WHEN 'picareta_leve' THEN 'martial'
      WHEN 'picareta_pesada' THEN 'martial'
      WHEN 'porrete' THEN 'simple'
      WHEN 'ranseur' THEN 'martial'
      WHEN 'rapieira' THEN 'martial'
      WHEN 'rede' THEN 'exotic'
      WHEN 'sai' THEN 'exotic'
      WHEN 'shuriken_10' THEN 'exotic'
      WHEN 'siangham' THEN 'exotic'
      WHEN 'tridente' THEN 'martial'
    END,
    'weapon_proficiency_source_url','https://www.d20srd.org/srd/equipment/weapons.htm',
    'weapon_proficiency_source_section', CASE
      WHEN id IN ('besta_repeticao_leve','chicote','corrente_espinhosa','kama','nunchaku','rede','sai','shuriken_10','siangham') THEN 'Exotic Weapons'
      WHEN id IN ('besta_pesada','bordao','clava','dardo','foice','funda','lanca','lanca_curta','maca_estrela','maca_leve','maca_pesada','porrete') THEN 'Simple Weapons'
      ELSE 'Martial Weapons'
    END
  )
WHERE id IN (
  'besta_repeticao_leve','besta_pesada','bordao','chicote','cimitarra','clava','clava_grande',
  'corrente_espinhosa','dardo','espada_curta','espada_grande','espada_larga','espada_longa',
  'foice','foice_grande','funda','glaive','guisarme','kama','kukri','lanca','lanca_curta',
  'lanca_longa','lanca_montaria','maca_estrela','maca_leve','maca_pesada','machadinha',
  'machado_batalha','machado_mao','machado_grande','mangual','martelo_guerra','martelo_leve',
  'nunchaku','picareta_leve','picareta_pesada','porrete','ranseur','rapieira','rede','sai',
  'shuriken_10','siangham','tridente'
)
AND COALESCE(detalhes->>'weapon_proficiency','')='';

NOTIFY pgrst,'reload schema';
