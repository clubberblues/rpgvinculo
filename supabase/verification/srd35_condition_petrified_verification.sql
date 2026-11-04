-- Migration: verify petrified against the open d20 SRD.
-- Verify petrified against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '137-139',
      'effect_summary', 'Turned to stone and considered unconscious; damage or missing pieces can cause permanent hit point loss or debilitation when restored to flesh.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'petrified';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 137-139; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'petrified';
