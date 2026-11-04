-- Migration: verify srd35_feat_craft_staff against the open d20 SRD.
-- Verify srd35_feat_craft_staff against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 374-385.'
WHERE id = 'srd35_feat_craft_staff';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 374-385; Craft Staff requires caster level 12 and creates qualifying staffs with one-day-per-1000-gp time, XP, materials, and 50 charges. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_craft_staff';
