-- Verify srd35_feat_craft_wand against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 387-394.'
WHERE id = 'srd35_feat_craft_wand';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 387-394; Craft Wand requires caster level 5 and creates known spells up to 4th level in 50-charge wands with cost rules. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_craft_wand';