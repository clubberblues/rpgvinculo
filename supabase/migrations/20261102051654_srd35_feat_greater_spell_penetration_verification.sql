-- Verify srd35_feat_greater_spell_penetration against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 598-606.'
WHERE id = 'srd35_feat_greater_spell_penetration';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 598-606; Greater Spell Penetration requires Spell Penetration and grants +2 caster-level checks to overcome spell resistance, stacking with Spell Penetration. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_greater_spell_penetration';