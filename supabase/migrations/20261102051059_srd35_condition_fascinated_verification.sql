-- Verify fascinated against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '93-95',
      'effect_summary', 'Entranced by supernatural or spell effect; takes no actions except attention; -4 reactive skill checks; potential threat allows new save; obvious threat breaks effect; ally can free with standard action.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'fascinated';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 93-95; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'fascinated';