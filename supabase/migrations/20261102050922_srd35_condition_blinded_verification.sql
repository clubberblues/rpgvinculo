-- Verify Blinded against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '46-48',
      'effect_summary', 'Cannot see; -2 AC; loses Dexterity bonus to AC; half speed; -4 Search and most Strength/Dexterity-based skill checks; vision-dependent checks fail; opponents have total concealment.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'blinded';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 46-48; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'blinded';