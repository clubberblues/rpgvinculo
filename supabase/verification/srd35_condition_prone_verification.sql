-- Migration: verify prone against the open d20 SRD.
-- Verify prone against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '144-148',
      'effect_summary', 'On the ground; -4 melee attacks and cannot use ranged weapons except crossbows; +4 AC against ranged attacks and -4 AC against melee attacks; standing provokes attack of opportunity.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'prone';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 144-148; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'prone';
