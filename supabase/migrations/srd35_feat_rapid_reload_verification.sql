-- Migration: verify srd35_feat_rapid_reload against the open d20 SRD.
-- Verify srd35_feat_rapid_reload against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 1219-1239.'
WHERE id = 'srd35_feat_rapid_reload';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 1219-1239; Rapid Reload chooses a crossbow type; reduces reload action, retains attack-of-opportunity risk, and allows bow-like full attacks for hand/light crossbows. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_rapid_reload';
