-- Migration: verify srd35_feat_craft_magic_arms_and_armor against the open d20 SRD.
-- Verify srd35_feat_craft_magic_arms_and_armor against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 352-362.'
WHERE id = 'srd35_feat_craft_magic_arms_and_armor';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 352-362; Craft Magic Arms and Armor requires caster level 5; creates or repairs qualifying magic weapons, armor, or shields with time, XP, and material costs. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_craft_magic_arms_and_armor';
