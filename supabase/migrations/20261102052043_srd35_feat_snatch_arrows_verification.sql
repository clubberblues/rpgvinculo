-- Verify srd35_feat_snatch_arrows against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 1350-1363.'
WHERE id = 'srd35_feat_snatch_arrows';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 1350-1363; Requires Dex 15, Deflect Arrows, and Improved Unarmed Strike; catches deflected weapons and may throw back a thrown weapon; free hand required. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_snatch_arrows';