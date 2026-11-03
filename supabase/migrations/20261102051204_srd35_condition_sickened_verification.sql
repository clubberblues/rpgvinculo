-- Verify sickened against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '155-157',
      'effect_summary', '-2 penalty on attack rolls, weapon damage rolls, saving throws, skill checks, and ability checks.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'sickened';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 155-157; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'sickened';