-- Verify srd35_feat_combat_expertise against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 318-332.'
WHERE id = 'srd35_feat_combat_expertise';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 318-332; Combat Expertise requires Int 13; trade up to -5 attack for equal dodge AC bonus, capped by base attack bonus. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_combat_expertise';