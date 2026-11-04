-- SRD 3.5 healing spell mechanics verified against d20srd.org.
-- Preserve source audit metadata while adding only engine-consumable mechanics.
UPDATE public.srd_spells
SET dados_tecnicos = COALESCE(dados_tecnicos, '{}'::jsonb)
  || jsonb_build_object(
    'tipo_efeito','cura',
    'cura',jsonb_build_object('dados','1','por_nivel',0,'max_nivel',0),
    'engine_status','implemented_srd_healing',
    'engine_rule_source','https://www.d20srd.org/srd/spells/cureMinorWounds.htm'
  )
WHERE id = 'srd35_cure_minor_wounds';

UPDATE public.srd_spells
SET dados_tecnicos = COALESCE(dados_tecnicos, '{}'::jsonb)
  || jsonb_build_object(
    'tipo_efeito','cura',
    'cura',jsonb_build_object('dados','1d8','por_nivel',1,'max_nivel',5),
    'engine_status','implemented_srd_healing',
    'engine_rule_source','https://www.d20srd.org/srd/spells/cureLightWounds.htm'
  )
WHERE id = 'srd35_cure_light_wounds';

UPDATE public.srd_spells
SET dados_tecnicos = COALESCE(dados_tecnicos, '{}'::jsonb)
  || jsonb_build_object(
    'tipo_efeito','cura',
    'cura',jsonb_build_object('dados','2d8','por_nivel',1,'max_nivel',10),
    'engine_status','implemented_srd_healing',
    'engine_rule_source','https://www.d20srd.org/srd/spells/cureModerateWounds.htm'
  )
WHERE id = 'srd35_spell_cure_moderate_wounds';

UPDATE public.srd_spells
SET dados_tecnicos = COALESCE(dados_tecnicos, '{}'::jsonb)
  || jsonb_build_object(
    'tipo_efeito','cura',
    'cura',jsonb_build_object('dados','3d8','por_nivel',1,'max_nivel',15),
    'engine_status','implemented_srd_healing',
    'engine_rule_source','https://www.d20srd.org/srd/spells/cureSeriousWounds.htm'
  )
WHERE id = 'srd35_spell_cure_serious_wounds';

UPDATE public.srd_spells
SET dados_tecnicos = COALESCE(dados_tecnicos, '{}'::jsonb)
  || jsonb_build_object(
    'tipo_efeito','cura',
    'cura',jsonb_build_object('dados','4d8','por_nivel',1,'max_nivel',20),
    'engine_status','implemented_srd_healing',
    'engine_rule_source','https://www.d20srd.org/srd/spells/cureCriticalWounds.htm'
  )
WHERE id = 'srd35_spell_cure_critical_wounds';

UPDATE public.srd_spells
SET dados_tecnicos = COALESCE(dados_tecnicos, '{}'::jsonb)
  || jsonb_build_object(
    'tipo_efeito','cura',
    'cura',jsonb_build_object('dados','1d8','por_nivel',1,'max_nivel',25),
    'target_mode','multiple_targets_pending',
    'engine_status','partial_srd_healing_formula',
    'engine_rule_source','https://www.d20srd.org/srd/spells/cureLightWoundsMass.htm'
  )
WHERE id = 'srd35_spell_cure_light_wounds_mass';

UPDATE public.srd_spells
SET dados_tecnicos = COALESCE(dados_tecnicos, '{}'::jsonb)
  || jsonb_build_object(
    'tipo_efeito','cura',
    'cura',jsonb_build_object('dados','2d8','por_nivel',1,'max_nivel',30),
    'target_mode','multiple_targets_pending',
    'engine_status','partial_srd_healing_formula',
    'engine_rule_source','https://www.d20srd.org/srd/spells/cureModerateWoundsMass.htm'
  )
WHERE id = 'srd35_spell_cure_moderate_wounds_mass';

UPDATE public.srd_spells
SET dados_tecnicos = COALESCE(dados_tecnicos, '{}'::jsonb)
  || jsonb_build_object(
    'tipo_efeito','cura',
    'cura',jsonb_build_object('dados','3d8','por_nivel',1,'max_nivel',35),
    'target_mode','multiple_targets_pending',
    'engine_status','partial_srd_healing_formula',
    'engine_rule_source','https://www.d20srd.org/srd/spells/cureSeriousWoundsMass.htm'
  )
WHERE id = 'srd35_spell_cure_serious_wounds_mass';

UPDATE public.srd_spells
SET dados_tecnicos = COALESCE(dados_tecnicos, '{}'::jsonb)
  || jsonb_build_object(
    'tipo_efeito','cura',
    'cura',jsonb_build_object('dados','4d8','por_nivel',1,'max_nivel',40),
    'target_mode','multiple_targets_pending',
    'engine_status','partial_srd_healing_formula',
    'engine_rule_source','https://www.d20srd.org/srd/spells/cureCriticalWoundsMass.htm'
  )
WHERE id = 'srd35_spell_cure_critical_wounds_mass';

UPDATE public.srd_spells
SET dados_tecnicos = COALESCE(dados_tecnicos, '{}'::jsonb)
  || jsonb_build_object(
    'tipo_efeito','cura',
    'cura',jsonb_build_object('dados','0','por_nivel',10,'max_nivel',15),
    'engine_status','implemented_srd_healing',
    'engine_rule_source','https://www.d20srd.org/srd/spells/heal.htm'
  )
WHERE id = 'srd35_spell_heal';

UPDATE public.srd_spells
SET dados_tecnicos = COALESCE(dados_tecnicos, '{}'::jsonb)
  || jsonb_build_object(
    'tipo_efeito','cura',
    'cura',jsonb_build_object('dados','0','por_nivel',10,'max_nivel',25),
    'target_mode','multiple_targets_pending',
    'engine_status','partial_srd_healing_formula',
    'engine_rule_source','https://www.d20srd.org/srd/spells/healMass.htm'
  )
WHERE id = 'srd35_spell_heal_mass';