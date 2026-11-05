-- Atualiza a observação de auditoria após a integração genérica dos bônus de resistência.
UPDATE public.srd_feats
SET mechanics=jsonb_set(
  mechanics,
  '{review_reason}',
  to_jsonb('Bônus passivo de +2 estruturado no catálogo e aplicado pelo resolvedor genérico de testes de resistência; cálculo do pedido completo ainda requer validação ponta a ponta na mesa.'::text),
  true
)
WHERE id IN ('srd35_feat_great_fortitude','srd35_feat_lightning_reflexes','srd35_feat_iron_will');
