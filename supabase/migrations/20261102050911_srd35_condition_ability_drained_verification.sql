-- Verify Ability Drained against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '43-45',
      'effect_summary', 'Permanent loss of one or more ability score points; recovery only by magical means; score 0 consequences match the SRD.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'abilitydrained';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 43-45; regra mecânica registrada, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'abilitydrained';