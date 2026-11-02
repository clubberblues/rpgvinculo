-- Migration: verify paralyzed against the open d20 SRD.
-- Verify paralyzed against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '134-136',
      'effect_summary', 'Frozen and unable to move or act; effective Dexterity and Strength 0; helpless; purely mental actions allowed; flying creatures fall and swimmers may drown.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'paralyzed';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 134-136; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'paralyzed';
