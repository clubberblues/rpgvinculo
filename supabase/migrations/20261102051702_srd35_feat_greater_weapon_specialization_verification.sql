-- Verify srd35_feat_greater_weapon_specialization against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 638-653.'
WHERE id = 'srd35_feat_greater_weapon_specialization';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 638-653; Requires proficiency, Greater Weapon Focus, Weapon Focus, Weapon Specialization, and fighter level 12; grants +2 damage with selected weapon. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_greater_weapon_specialization';