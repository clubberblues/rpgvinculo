-- Migration: verify knockeddown against the open d20 SRD.
-- Verify knockeddown against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '123-125',
      'effect_summary', 'Ground creatures are knocked prone by high-velocity wind; flying creatures are blown back 1d6 x 10 feet.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'knockeddown';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 123-125; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'knockeddown';
