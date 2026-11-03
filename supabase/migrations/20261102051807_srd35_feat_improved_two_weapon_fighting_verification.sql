-- Verify srd35_feat_improved_two_weapon_fighting against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 902-919.'
WHERE id = 'srd35_feat_improved_two_weapon_fighting';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 902-919; Requires Dex 17, Two-Weapon Fighting, and BAB +6; grants a second off-hand attack at -5, with fighter and ranger exceptions. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_improved_two_weapon_fighting';