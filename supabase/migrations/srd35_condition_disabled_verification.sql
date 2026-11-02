-- Migration: verify disabled against the open d20 SRD.
-- Verify disabled against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '77-80',
      'effect_summary', 'At 0 or negative stable and conscious; one move or standard action per round, half speed; strenuous standard action deals 1 damage; natural recovery rules apply.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'disabled';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 77-80; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'disabled';
