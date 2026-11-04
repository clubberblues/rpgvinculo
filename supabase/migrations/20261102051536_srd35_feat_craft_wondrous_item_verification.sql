-- Verify srd35_feat_craft_wondrous_item against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 395-405.'
WHERE id = 'srd35_feat_craft_wondrous_item';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 395-405; Craft Wondrous Item requires caster level 3 and creates or repairs qualifying items with time, XP, and materials costs. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_craft_wondrous_item';