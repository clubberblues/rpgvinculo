-- Migration: verify dazed against the open d20 SRD.
-- Verify dazed against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '63-67',
      'effect_summary', 'Cannot act normally; takes no actions, no AC penalty; typically lasts 1 round.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'dazed';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 63-67; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'dazed';
