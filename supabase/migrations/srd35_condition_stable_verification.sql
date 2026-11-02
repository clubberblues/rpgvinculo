-- Migration: verify stable against the open d20 SRD.
-- Verify stable against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '158-161',
      'effect_summary', 'Dying character has stopped losing hit points and remains unconscious; with aid, no further hit point loss and 10% hourly chance conscious/disabled; without aid, 10% chance or loses 1 hit point.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'stable';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 158-161; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'stable';
