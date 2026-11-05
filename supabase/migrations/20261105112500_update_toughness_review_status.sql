-- Atualiza a revisão do talento Tenacidade após integrar seu efeito de PV.
update public.srd_feats
set mechanics = jsonb_set(
  mechanics,
  '{review_reason}',
  to_jsonb('Bônus de +3 PV máximos por cópia integrado pelo trigger srd_apply_toughness_hp_delta; testes SQL transacionais confirmaram +3 e +6 PV para uma e duas cópias. Fluxos completos de criação e avanço de nível ainda aguardam validação ponta a ponta.'::text),
  true
)
where id='tenacidade';
