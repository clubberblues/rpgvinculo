-- Migration: verify Dead against the open d20 SRD.
-- Verify Dead against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '71-73',
      'effect_summary', 'Dead at -10 hit points, Constitution 0, or instant death; soul leaves body; normal or magical healing does not help, but magic can restore life and restores the body according to the effect.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'dead';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 71-73; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'dead';
