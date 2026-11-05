-- Estrutura Aptidão Mágica como talento passivo com bônus em duas perícias.
-- A tela de perícias já consome efeitos passivos com status ready.
UPDATE public.srd_feats
SET mechanics = jsonb_set(
  jsonb_set(
    jsonb_set(
      mechanics,
      '{activation}',
      '{"mode":"passive","action_type":"no_action","trigger":null}'::jsonb,
      true
    ),
    '{resolution}',
    '{"attack":null,"effects":[{"kind":"modifier","stat":"skill:srd35_skill_spellcraft","value":2,"bonus_type":"untyped"},{"kind":"modifier","stat":"skill:usar_instrumento_magico","value":2,"bonus_type":"untyped"}],"saving_throw":null}'::jsonb,
    true
  ),
  '{engine_status}',
  '"ready"'::jsonb,
  true
) || jsonb_build_object(
  'review_reason','Efeito passivo SRD estruturado; bônus +2 em Identificar Magia e Usar Instrumento Mágico. Consumo pela lista de efeitos passivos da tela de perícias; requer teste integrado em mesa.'
)
WHERE id='srd35_feat_magical_aptitude'
  AND mechanics->>'engine_status'='needs_review';
