-- Migration: verify panicked against the open d20 SRD.
-- Verify panicked against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '130-133',
      'effect_summary', 'Drops held items and flees at top speed from fear source and other dangers along a random path; no other actions; -2 saves, skills, and ability checks; cowers if cornered.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'panicked';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 130-133; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'panicked';
