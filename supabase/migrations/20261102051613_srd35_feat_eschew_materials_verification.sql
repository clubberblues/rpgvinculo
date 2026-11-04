-- Verify srd35_feat_eschew_materials against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 495-499.'
WHERE id = 'srd35_feat_eschew_materials';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 495-499; Eschew Materials allows spells with material components costing 1 gp or less without the component; casting still provokes attacks of opportunity. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_eschew_materials';