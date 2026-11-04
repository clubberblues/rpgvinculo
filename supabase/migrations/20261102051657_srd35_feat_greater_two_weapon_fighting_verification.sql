-- Verify srd35_feat_greater_two_weapon_fighting against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 607-620.'
WHERE id = 'srd35_feat_greater_two_weapon_fighting';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 607-620; Requires Dex 19, Improved Two-Weapon Fighting, Two-Weapon Fighting, and BAB +11; grants a third off-hand attack at -10. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_greater_two_weapon_fighting';