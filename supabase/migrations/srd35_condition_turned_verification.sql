-- Migration: verify turned against the open d20 SRD.
-- Verify turned against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '171-173',
      'effect_summary', 'Affected by turn undead; turned undead flee for 10 rounds by fastest means, or cower if unable to flee.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'turned';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 171-173; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'turned';
