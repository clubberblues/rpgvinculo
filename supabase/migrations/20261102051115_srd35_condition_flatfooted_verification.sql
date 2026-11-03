-- Verify flatfooted against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '99-101',
      'effect_summary', 'Before acting in combat, a character is flat-footed; loses Dexterity bonus to AC and cannot make attacks of opportunity.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'flatfooted';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 99-101; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'flatfooted';