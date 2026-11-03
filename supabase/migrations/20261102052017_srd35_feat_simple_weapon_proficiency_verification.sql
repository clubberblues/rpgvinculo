-- Verify srd35_feat_simple_weapon_proficiency against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 1326-1337.'
WHERE id = 'srd35_feat_simple_weapon_proficiency';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 1326-1337; Simple Weapon Proficiency enables normal attacks with selected simple weapons; most classes gain all simple weapon proficiency automatically. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_simple_weapon_proficiency';