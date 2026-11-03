-- Verify iniciativa_aprimorada against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 791-799.'
WHERE id = 'iniciativa_aprimorada';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 791-799; Improved Initiative: +4 bonus on initiative checks; fighter bonus feat. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'iniciativa_aprimorada';