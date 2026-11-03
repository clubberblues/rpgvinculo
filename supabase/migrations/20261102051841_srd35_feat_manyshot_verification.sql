-- Verify srd35_feat_manyshot against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 1045-1062.'
WHERE id = 'srd35_feat_manyshot';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 1045-1062; Manyshot requires Dex 17, Point Blank Shot, Rapid Shot, BAB +6; fires multiple arrows as a standard action with specified penalties and precision/critical rules. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_manyshot';