-- Migration: verify srd35_feat_rapid_shot against the open d20 SRD.
-- Verify srd35_feat_rapid_shot against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 1241-1253.'
WHERE id = 'srd35_feat_rapid_shot';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 1241-1253; Rapid Shot requires Dex 13 and Point Blank Shot; grants one extra ranged attack with -2 to all attacks in a full attack. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_rapid_shot';
