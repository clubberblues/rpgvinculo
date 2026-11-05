-- Auditoria mecânica: bônus passivos de resistência e pontos de vida.
-- "ready" registra regra estruturada e revisada; não promove o efeito a implemented.
with feat_effects(id,stat,value,reason) as (
  values
    ('srd35_feat_great_fortitude','fortitude',2,'Bônus passivo +2 em testes de Fortitude. O resolvedor atual já aplica este talento por ID; migração para efeito genérico e teste automatizado pendentes.'),
    ('srd35_feat_iron_will','will',2,'Bônus passivo +2 em testes de Vontade. O resolvedor atual já aplica este talento por ID; migração para efeito genérico e teste automatizado pendentes.'),
    ('srd35_feat_lightning_reflexes','reflex',2,'Bônus passivo +2 em testes de Reflexos. O resolvedor atual já aplica este talento por ID; migração para efeito genérico e teste automatizado pendentes.'),
    ('tenacidade','hit_points',3,'Toughness concede +3 PV máximos por escolha e acumula consigo mesmo. Integração ao cálculo autoritativo de PV máximos e teste pendentes.')
)
update public.srd_feats f
set mechanics =
  jsonb_set(
    jsonb_set(
      jsonb_set(
        jsonb_set(coalesce(f.mechanics,'{}'::jsonb),
          '{activation}', '{"mode":"passive","action_type":"no_action","trigger":null}'::jsonb, true),
        '{duration}', '{"type":"passive","value":null,"end_trigger":null}'::jsonb, true),
      '{resolution}',
      coalesce(f.mechanics->'resolution','{}'::jsonb) || jsonb_build_object(
        'attack',null,'saving_throw',null,
        'effects',jsonb_build_array(jsonb_build_object(
          'kind','modifier','stat',e.stat,'value',e.value,'bonus_type','untyped'
        ))
      ), true),
    '{engine_status}', '"ready"'::jsonb, true
  ) || jsonb_build_object('review_reason',e.reason)
from feat_effects e
where f.id=e.id;
