-- Verify Blown Away against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '49-51',
      'effect_summary', 'High-velocity wind can blow creatures away: grounded creatures are knocked down and roll 1d4 x 10 feet with 1d4 nonlethal damage per 10 feet; flying creatures move back 2d6 x 10 feet and take 2d6 nonlethal damage.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'blownaway';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 49-51; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'blownaway';