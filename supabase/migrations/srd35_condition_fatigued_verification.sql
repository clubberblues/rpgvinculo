-- Migration: verify fatigued against the open d20 SRD.
-- Verify fatigued against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '96-98',
      'effect_summary', 'Cannot run or charge; -2 Strength and Dexterity; further fatigue causes exhausted; after 8 hours complete rest no longer fatigued.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'fatigued';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 96-98; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'fatigued';
