-- Migration: verify helpless against the open d20 SRD.
-- Verify helpless against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '109-115',
      'effect_summary', 'Paralyzed, held, bound, sleeping, unconscious, or otherwise at opponent''s mercy; effective Dexterity 0; melee attacks +4; coup de grace rules apply.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'helpless';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 109-115; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'helpless';
