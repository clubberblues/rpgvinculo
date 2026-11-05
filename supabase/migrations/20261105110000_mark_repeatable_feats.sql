-- Marca os talentos que o SRD permite escolher mais de uma vez.
-- A validação de fichas e avanço de nível será atualizada para permitir repetição
-- apenas com parâmetros distintos ou quando o efeito acumula.
update public.srd_feats f
set requisitos = coalesce(f.requisitos,'{}'::jsonb) || jsonb_build_object(
  'repeatable', true,
  'repeatable_mode', case when f.id in ('srd35_feat_extra_turning','tenacidade') then 'stacking' else 'different_parameter' end
)
where f.id in (
  'srd35_feat_weapon_specialization',
  'srd35_feat_greater_weapon_specialization',
  'srd35_feat_extra_turning',
  'foco_em_arma',
  'srd35_feat_greater_weapon_focus',
  'srd35_feat_spell_focus',
  'srd35_feat_greater_spell_focus',
  'srd35_feat_skill_focus',
  'srd35_feat_martial_weapon_proficiency',
  'srd35_feat_rapid_reload',
  'srd35_feat_improved_critical',
  'tenacidade',
  'srd35_feat_exotic_weapon_proficiency'
);
