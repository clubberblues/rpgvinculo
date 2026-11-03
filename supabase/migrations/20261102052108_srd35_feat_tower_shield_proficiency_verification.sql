-- Verify srd35_feat_tower_shield_proficiency against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 1457-1472.'
WHERE id = 'srd35_feat_tower_shield_proficiency';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 1457-1472; Requires Shield Proficiency; permits tower shield use with standard penalties; fighters automatically gain it. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_tower_shield_proficiency';