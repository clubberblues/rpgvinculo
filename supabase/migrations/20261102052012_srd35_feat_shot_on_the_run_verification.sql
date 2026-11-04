-- Verify srd35_feat_shot_on_the_run against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 1304-1315.'
WHERE id = 'srd35_feat_shot_on_the_run';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 1304-1315; Shot on the Run requires Dex 13, Dodge, Mobility, Point Blank Shot, and BAB +4; permits movement before and after ranged attack within total speed. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_shot_on_the_run';