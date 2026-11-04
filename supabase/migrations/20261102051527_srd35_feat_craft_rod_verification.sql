-- Verify srd35_feat_craft_rod against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 363-373.'
WHERE id = 'srd35_feat_craft_rod';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 363-373; Craft Rod requires caster level 9 and creates qualifying rods with one-day-per-1000-gp time, XP, and materials costs. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_craft_rod';