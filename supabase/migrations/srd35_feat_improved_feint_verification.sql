-- Migration: verify srd35_feat_improved_feint against the open d20 SRD.
-- Verify srd35_feat_improved_feint against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 757-771.'
WHERE id = 'srd35_feat_improved_feint';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 757-771; Improved Feint requires Int 13 and Combat Expertise; feinting in combat becomes a move action. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_improved_feint';
