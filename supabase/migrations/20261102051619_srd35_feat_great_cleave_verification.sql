-- Verify srd35_feat_great_cleave against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 568-580.'
WHERE id = 'srd35_feat_great_cleave';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 568-580; Great Cleave requires Str 13, Cleave, Power Attack, and base attack bonus +4; Cleave''s extra attack has no per-round limit. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_great_cleave';