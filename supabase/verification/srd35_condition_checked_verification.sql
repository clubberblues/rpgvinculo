-- Migration: verify Checked against the open d20 SRD.
-- Verify Checked against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '52-54',
      'effect_summary', 'Forward motion is prevented by an applied force such as wind; grounded creatures stop and flying creatures move back the distance specified by the effect.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'checked';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 52-54; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'checked';
