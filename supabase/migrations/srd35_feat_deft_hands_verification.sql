-- Migration: verify srd35_feat_deft_hands against the open d20 SRD.
-- Verify srd35_feat_deft_hands against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 428-432.'
WHERE id = 'srd35_feat_deft_hands';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 428-432; Deft Hands grants +2 Sleight of Hand and Use Rope. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_deft_hands';
