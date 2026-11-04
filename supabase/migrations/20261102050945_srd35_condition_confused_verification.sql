-- Verify Confused against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '55-58',
      'effect_summary', 'At the start of each turn roll d%: 01-10 attack caster or close; 11-20 act normally; 21-50 babble; 51-70 flee; 71-100 attack nearest creature. A confused creature does not make attacks of opportunity against creatures it is not already attacking.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'confused';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 55-58; tabela de comportamento registrada, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'confused';