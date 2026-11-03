-- Verify frightened against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '102-105',
      'effect_summary', 'Flees from fear source if possible, may fight if unable to flee; -2 attacks, saves, skills, and ability checks; may use abilities or spells to flee.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'frightened';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 102-105; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'frightened';