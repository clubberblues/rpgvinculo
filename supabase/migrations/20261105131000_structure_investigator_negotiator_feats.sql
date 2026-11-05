-- Estrutura Investigador e Negociador como bônus passivos de perícia.
-- O leitor da tela de perícias já processa talentos passive em status ready.
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
    CASE id
      WHEN 'srd35_feat_investigator' THEN
        '{"attack":null,"effects":[{"kind":"modifier","stat":"skill:srd35_skill_gather_information","value":2,"bonus_type":"untyped"},{"kind":"modifier","stat":"skill:procurar","value":2,"bonus_type":"untyped"}],"saving_throw":null}'::jsonb
      WHEN 'srd35_feat_negotiator' THEN
        '{"attack":null,"effects":[{"kind":"modifier","stat":"skill:diplomacia","value":2,"bonus_type":"untyped"},{"kind":"modifier","stat":"skill:sentir_motivacao","value":2,"bonus_type":"untyped"}],"saving_throw":null}'::jsonb
    END,
    true
  ),
  '{engine_status}',
  '"ready"'::jsonb,
  true
) || jsonb_build_object(
  'review_reason','Bônus passivo de +2 nas duas perícias indicadas pelo SRD; efeitos consumidos pelo leitor de talentos passivos da tela de perícias. Validar em ficha de teste na mesa.'
)
WHERE id IN ('srd35_feat_investigator','srd35_feat_negotiator')
  AND mechanics->>'engine_status'='needs_review';
