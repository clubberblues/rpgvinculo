-- Verify srd35_feat_improved_sunder against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 854-871.'
WHERE id = 'srd35_feat_improved_sunder';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 854-871; Improved Sunder requires Str 13 and Power Attack; striking held objects does not provoke and gains +4 attack against held objects. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_improved_sunder';