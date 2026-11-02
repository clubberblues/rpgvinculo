-- Migration: verify energydrained against the open d20 SRD.
-- Verify energydrained against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '84-86',
      'effect_summary', 'Negative levels can permanently drain levels; death when negative levels reach Hit Dice; each level applies attack/save/skill/ability -1, -5 hit points, -1 effective level; spellcasters lose highest-level spell or slot.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'energydrained';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 84-86; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'energydrained';
