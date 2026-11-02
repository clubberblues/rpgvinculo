-- Migration: verify entangled against the open d20 SRD.
-- Verify entangled against the open d20 SRD condition summary.
UPDATE public.srd_conditions
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects = COALESCE(mechanical_effects, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '87-89',
      'effect_summary', 'Movement impeded but not fully prevented unless anchored; half speed; cannot run or charge; -2 attacks; -4 Dexterity; spellcasting requires Concentration DC 15 + spell level or spell is lost.',
      'engine_status', 'needs_implementation'
    )
WHERE condition_id = 'entangled';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Condition Summary, linhas 87-89; efeitos registrados, implementação do motor ainda pendente.'
WHERE catalog_key = 'conditions' AND entry_id = 'entangled';
