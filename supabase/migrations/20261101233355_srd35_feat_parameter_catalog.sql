-- Completa escolhas e cadeias de pré-requisitos do catálogo de talentos SRD 3.5.
-- Mantém o texto de origem; só estrutura escolhas confirmadas na fonte SRD.
BEGIN;

UPDATE public.srd_feats AS f
SET exige_parametro = true,
    requisitos = COALESCE(f.requisitos,'{}'::jsonb) || jsonb_build_object('parameter_type',v.parameter_type)
FROM (VALUES
  ('srd35_feat_exotic_weapon_proficiency','weapon_exotic'),
  ('srd35_feat_improved_critical','weapon'),
  ('srd35_feat_martial_weapon_proficiency','weapon_martial'),
  ('srd35_feat_rapid_reload','crossbow'),
  ('foco_em_arma','weapon'),
  ('srd35_feat_greater_spell_focus','spell_school'),
  ('srd35_feat_greater_weapon_focus','weapon'),
  ('srd35_feat_greater_weapon_specialization','weapon'),
  ('srd35_feat_skill_focus','skill'),
  ('srd35_feat_spell_focus','spell_school'),
  ('srd35_feat_weapon_specialization','weapon')
) AS v(id,parameter_type)
WHERE f.id=v.id;

-- Spell Mastery permite uma lista com número igual ao modificador de INT;
-- a lista pode ficar vazia quando o modificador é zero ou negativo.
UPDATE public.srd_feats
SET exige_parametro = false,
    requisitos = COALESCE(requisitos,'{}'::jsonb) || jsonb_build_object(
      'parameter_type','spell_list',
      'class_level_min',1,
      'class_key_required','wizard',
      'spell_choice_count','int_modifier'
    )
WHERE id='srd35_feat_spell_mastery';

-- O texto original diz que FOR 13 se aplica somente às duas armas indicadas.
UPDATE public.srd_feats
SET requisitos = (COALESCE(requisitos,'{}'::jsonb) - 'for_min') || jsonb_build_object(
      'conditional_ability_min',jsonb_build_object(
        'FOR',jsonb_build_object('minimum',13,'parameters',jsonb_build_array('bastard sword','dwarven waraxe'))
      ),
      'bab_min',1,
      'parameter_type','weapon_exotic',
      'raw','Base attack bonus +1; Str 13 only for bastard sword or dwarven waraxe.'
    )
WHERE id='srd35_feat_exotic_weapon_proficiency';

-- Proficiência com Arma Marcial não tem pré-requisito no SRD.
UPDATE public.srd_feats
SET requisitos = (COALESCE(requisitos,'{}'::jsonb) - 'bab_min' - 'raw') || jsonb_build_object('raw','Nenhum.')
WHERE id='srd35_feat_martial_weapon_proficiency';

-- Cadeias de armas: a arma escolhida deve permanecer a mesma em cada talento.
UPDATE public.srd_feats AS f
SET requisitos = COALESCE(f.requisitos,'{}'::jsonb) || v.requisitos
FROM (VALUES
  ('srd35_feat_weapon_specialization',jsonb_build_object(
    'feat_ids',jsonb_build_array('foco_em_arma'),
    'feat_parameter_matches',jsonb_build_array('foco_em_arma'),
    'class_level_min',4,'class_key_required','fighter',
    'raw','Proficiency with selected weapon, Weapon Focus with selected weapon, fighter level 4th.'
  )),
  ('srd35_feat_greater_weapon_focus',jsonb_build_object(
    'feat_ids',jsonb_build_array('foco_em_arma'),
    'feat_parameter_matches',jsonb_build_array('foco_em_arma'),
    'class_level_min',8,'class_key_required','fighter',
    'raw','Proficiency with selected weapon, Weapon Focus with selected weapon, fighter level 8th.'
  )),
  ('srd35_feat_greater_weapon_specialization',jsonb_build_object(
    'feat_ids',jsonb_build_array('foco_em_arma','srd35_feat_weapon_specialization','srd35_feat_greater_weapon_focus'),
    'feat_parameter_matches',jsonb_build_array('foco_em_arma','srd35_feat_weapon_specialization','srd35_feat_greater_weapon_focus'),
    'class_level_min',12,'class_key_required','fighter',
    'raw','Proficiency with selected weapon, Greater Weapon Focus, Weapon Focus, Weapon Specialization with selected weapon, fighter level 12th.'
  )),
  ('srd35_feat_greater_spell_focus',jsonb_build_object(
    'feat_ids',jsonb_build_array('srd35_feat_spell_focus'),
    'feat_parameter_matches',jsonb_build_array('srd35_feat_spell_focus'),
    'raw','Spell Focus for the selected school.'
  )),
  ('srd35_feat_improved_critical',jsonb_build_object(
    'weapon_proficiency_required',true,
    'raw','Proficient with selected weapon, base attack bonus +8.'
  )),
  ('srd35_feat_rapid_reload',jsonb_build_object(
    'weapon_proficiency_required',true,
    'raw','Weapon Proficiency with the selected crossbow type.'
  )),
  ('foco_em_arma',jsonb_build_object(
    'bab_min',1,
    'weapon_proficiency_required',true,
    'raw','Proficiency with selected weapon, base attack bonus +1.'
  ))
) AS v(id,requisitos)
WHERE f.id=v.id;

COMMIT;

