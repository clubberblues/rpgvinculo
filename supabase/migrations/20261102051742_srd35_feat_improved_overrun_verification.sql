-- Verify srd35_feat_improved_overrun against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 801-816.'
WHERE id = 'srd35_feat_improved_overrun';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 801-816; Improved Overrun requires Str 13 and Power Attack; target cannot avoid, and you gain +4 Strength check to knock down. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_improved_overrun';