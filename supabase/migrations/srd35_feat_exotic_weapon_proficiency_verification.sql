-- Migration: verify srd35_feat_exotic_weapon_proficiency against the open d20 SRD.
-- Verify srd35_feat_exotic_weapon_proficiency against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 500-506.'
WHERE id = 'srd35_feat_exotic_weapon_proficiency';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 500-506; Choose an exotic weapon and gain proficiency; prerequisite base attack bonus +1, plus Str 13 for bastard sword or dwarven waraxe. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_exotic_weapon_proficiency';
