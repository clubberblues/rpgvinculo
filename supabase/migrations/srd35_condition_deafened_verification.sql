-- Migration: verify deafened against the open d20 SRD.
-- Verify deafened against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '74-76',
      'effect_summary', 'Cannot hear; -4 initiative; Listen automatically fails; 20% spell failure for verbal components; long-term adaptation may overcome some drawbacks.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'deafened';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 74-76; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'deafened';
