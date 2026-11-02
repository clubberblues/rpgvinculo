-- Migration: verify srd35_feat_spring_attack against the open d20 SRD.
-- Verify srd35_feat_spring_attack against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 1408-1419.'
WHERE id = 'srd35_feat_spring_attack';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 1408-1419; Requires Dex 13, Dodge, Mobility, and BAB +4; move before and after a melee attack, at least 5 feet each side. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_spring_attack';
