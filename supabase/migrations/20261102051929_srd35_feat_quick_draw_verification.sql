-- Verify srd35_feat_quick_draw against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 1193-1209.'
WHERE id = 'srd35_feat_quick_draw';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 1193-1209; Quick Draw requires BAB +1; drawing weapons becomes a free action and enables full-rate thrown weapon attacks. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_quick_draw';