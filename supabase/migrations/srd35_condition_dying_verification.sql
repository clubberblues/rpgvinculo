-- Migration: verify dying against the open d20 SRD.
-- Verify dying against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '81-83',
      'effect_summary', 'Unconscious at -1 to -9 hit points; no actions; each round 10% chance to stabilize, otherwise loses 1 hit point; at -10 becomes dead.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'dying';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 81-83; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'dying';
