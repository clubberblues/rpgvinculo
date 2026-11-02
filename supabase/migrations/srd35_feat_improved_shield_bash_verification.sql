-- Migration: verify srd35_feat_improved_shield_bash against the open d20 SRD.
-- Verify srd35_feat_improved_shield_bash against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 837-852.'
WHERE id = 'srd35_feat_improved_shield_bash';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 837-852; Improved Shield Bash lets you retain shield AC bonus while shield bashing and is a fighter bonus feat. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_improved_shield_bash';
