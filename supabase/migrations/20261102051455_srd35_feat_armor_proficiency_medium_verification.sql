-- Verify srd35_feat_armor_proficiency_medium against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 239-254.'
WHERE id = 'srd35_feat_armor_proficiency_medium';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 239-254; Medium armor proficiency requires light armor proficiency and uses its benefit; several martial classes receive it automatically. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_armor_proficiency_medium';