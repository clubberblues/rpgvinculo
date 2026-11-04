-- Migration: verify srd35_feat_spirited_charge against the open d20 SRD.
-- Verify srd35_feat_spirited_charge against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 1394-1406.'
WHERE id = 'srd35_feat_spirited_charge';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 1394-1406; Requires Ride 1 rank, Mounted Combat, and Ride-By Attack; mounted charge deals double melee damage or triple with a lance. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_spirited_charge';
