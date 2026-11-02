-- Migration: verify srd35_feat_stunning_fist against the open d20 SRD.
-- Verify srd35_feat_stunning_fist against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 1435-1446.'
WHERE id = 'srd35_feat_stunning_fist';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 1435-1446; Stunning Fist forces Fortitude save DC 10 + half character level + Wis after a damaging unarmed attack; failure stuns for 1 round, with class uses and prerequisites. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_stunning_fist';
