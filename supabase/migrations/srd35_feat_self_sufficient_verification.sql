-- Migration: verify srd35_feat_self_sufficient against the open d20 SRD.
-- Verify srd35_feat_self_sufficient against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 1285-1289.'
WHERE id = 'srd35_feat_self_sufficient';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 1285-1289; Self-Sufficient grants +2 Heal and Survival. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_self_sufficient';
