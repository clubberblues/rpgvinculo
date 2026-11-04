-- Migration: verify unconscious against the open d20 SRD.
-- Verify unconscious against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '174-176',
      'effect_summary', 'Knocked out and helpless; can result from -1 to -9 hit points or nonlethal damage exceeding current hit points.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'unconscious';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 174-176; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'unconscious';
