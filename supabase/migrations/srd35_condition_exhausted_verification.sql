-- Migration: verify exhausted against the open d20 SRD.
-- Verify exhausted against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '90-92',
      'effect_summary', 'Half speed and -6 Strength and Dexterity; after 1 hour complete rest becomes fatigued; additional fatigue causes exhausted.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'exhausted';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 90-92; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'exhausted';
