-- Verify srd35_feat_improved_grapple against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 773-789.'
WHERE id = 'srd35_feat_improved_grapple';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 773-789; Improved Grapple requires Dex 13 and Improved Unarmed Strike; starting a grapple does not provoke and grants +4 grapple checks. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_improved_grapple';