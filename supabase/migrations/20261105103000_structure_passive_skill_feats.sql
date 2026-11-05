-- Auditoria mecânica inicial dos talentos passivos SRD.
-- Classifica 12 talentos de bônus fixo em perícias como passive/ready.
-- "ready" indica regra estruturada e revisada; não significa integração ao motor.
with feat_skill_map(id, skill_ids) as (
  values
    ('srd35_feat_acrobatic', array['srd35_skill_jump','acrobacia']::text[]),
    ('srd35_feat_agile', array['srd35_skill_balance','fuga']::text[]),
    ('srd35_feat_alertness', array['ouvir','observar']::text[]),
    ('srd35_feat_animal_affinity', array['adestrar_animais','cavalgar']::text[]),
    ('srd35_feat_athletic', array['escalar','natacao']::text[]),
    ('srd35_feat_deceitful', array['disfarce','srd35_skill_forgery']::text[]),
    ('srd35_feat_deft_hands', array['prestidigitacao','srd35_skill_use_rope']::text[]),
    ('srd35_feat_diligent', array['avaliacao','decifrar_escrita']::text[]),
    ('srd35_feat_nimble_fingers', array['srd35_skill_disable_device','srd35_skill_open_lock']::text[]),
    ('srd35_feat_persuasive', array['enganacao','intimidacao']::text[]),
    ('srd35_feat_self_sufficient', array['cura','sobrevivencia']::text[]),
    ('srd35_feat_stealthy', array['esconder_se','mover_silenciosamente']::text[])
),
effects as (
  select m.id,
         jsonb_agg(jsonb_build_object(
           'kind','modifier',
           'stat','skill:' || skill_id,
           'value',2,
           'bonus_type','untyped'
         ) order by skill_id) as effect_list
  from feat_skill_map m
  cross join unnest(m.skill_ids) as skill_id
  group by m.id
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
      coalesce(f.mechanics->'resolution','{}'::jsonb) || jsonb_build_object('attack',null,'saving_throw',null,'effects',e.effect_list),
      true),
    '{engine_status}', '"ready"'::jsonb, true
  ) || jsonb_build_object('review_reason','Regra SRD conferida e bônus passivos estruturados por perícia; integração ao resolvedor de testes e validação em mesa ainda pendentes.')
from effects e
where f.id=e.id;

-- Diferencia os dois talentos metamágicos, evitando nomes duplicados:
-- Enlarge Spell = Aumentar Magia; Widen Spell = Ampliar Magia.
update public.srd_feats
set nome_pt='Aumentar Magia'
where id='srd35_feat_enlarge_spell';
