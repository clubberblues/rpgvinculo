-- Verify srd35_feat_augment_summoning against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 262-269.'
WHERE id = 'srd35_feat_augment_summoning';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 262-269; Augment Summoning requires Spell Focus (conjuration) and grants summoned creatures +4 enhancement to Strength and Constitution. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_augment_summoning';