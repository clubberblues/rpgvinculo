-- Estrutura bônus passivos parametrizados de foco e especialização em arma.
with feat_effects(id,stat_template,value,reason) as (
  values
    ('foco_em_arma','weapon_attack:{parameter}',1,'Bônus passivo +1 nas jogadas de ataque com a arma escolhida. Efeito estruturado e lido pelo cálculo de ataque da mesa; teste de combate ponta a ponta pendente.'),
    ('srd35_feat_greater_weapon_focus','weapon_attack:{parameter}',1,'Bônus passivo adicional +1 nas jogadas de ataque com a arma escolhida. Efeito estruturado e lido pelo cálculo de ataque da mesa; teste de combate ponta a ponta pendente.'),
    ('srd35_feat_weapon_specialization','weapon_damage:{parameter}',2,'Bônus passivo +2 no dano com a arma escolhida. Efeito estruturado e lido pelo cálculo de dano da mesa; teste de combate ponta a ponta pendente.'),
    ('srd35_feat_greater_weapon_specialization','weapon_damage:{parameter}',2,'Bônus passivo adicional +2 no dano com a arma escolhida. Efeito estruturado e lido pelo cálculo de dano da mesa; teste de combate ponta a ponta pendente.')
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
          'kind','modifier',
          'stat_template',e.stat_template,
          'parameter_source','feat_parameter',
          'value',e.value,
          'bonus_type','untyped'
        ))
      ), true),
    '{engine_status}', '"ready"'::jsonb, true
  ) || jsonb_build_object('review_reason',e.reason)
from feat_effects e
where f.id=e.id;
