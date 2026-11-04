-- Estrutura pré-requisitos de talentos para a ficha e a validação do catálogo.
BEGIN;

WITH parsed AS (
  SELECT f.id,
    regexp_match(COALESCE(f.requisitos->>'raw',''), '(?i)(wizard|mago)[[:space:]]+level[[:space:]]+([0-9]+)') AS class_m
  FROM public.srd_feats AS f
)
UPDATE public.srd_feats AS f
SET requisitos = COALESCE(f.requisitos,'{}'::jsonb) || jsonb_strip_nulls(jsonb_build_object(
  'class_level_min', CASE WHEN p.class_m IS NOT NULL THEN (p.class_m)[2]::integer END,
  'class_key_required', CASE WHEN p.class_m IS NOT NULL THEN 'wizard' END
))
FROM parsed AS p
WHERE p.id=f.id;

-- Pré-requisitos que citam outro talento recebem os IDs já existentes no
-- catálogo; o texto original continua como referência legível.
UPDATE public.srd_feats AS f
SET requisitos = f.requisitos || jsonb_build_object('feat_ids', v.feat_ids)
FROM (VALUES
  ('srd35_feat_armor_proficiency_medium', jsonb_build_array('srd35_feat_armor_proficiency_light')),
  ('srd35_feat_augment_summoning', jsonb_build_array('srd35_feat_spell_focus')),
  ('srd35_feat_diehard', jsonb_build_array('srd35_feat_endurance')),
  ('srd35_feat_far_shot', jsonb_build_array('srd35_feat_point_blank_shot')),
  ('srd35_feat_greater_spell_penetration', jsonb_build_array('srd35_feat_spell_penetration')),
  ('srd35_feat_improved_shield_bash', jsonb_build_array('srd35_feat_shield_proficiency')),
  ('srd35_feat_precise_shot', jsonb_build_array('srd35_feat_point_blank_shot')),
  ('srd35_feat_tower_shield_proficiency', jsonb_build_array('srd35_feat_shield_proficiency'))
) AS v(id,feat_ids)
WHERE f.id=v.id;

UPDATE public.srd_feats
SET requisitos = requisitos || jsonb_build_object(
  'feat_parameters', jsonb_build_object('srd35_feat_spell_focus','conjuration')
)
WHERE id='srd35_feat_augment_summoning';

COMMIT;

