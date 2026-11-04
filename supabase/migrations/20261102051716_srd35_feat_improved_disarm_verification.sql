-- Verify srd35_feat_improved_disarm against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 701-717.'
WHERE id = 'srd35_feat_improved_disarm';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 701-717; Requires Int 13 and Combat Expertise; disarm does not provoke, opponent cannot disarm you, and you gain +4 opposed attack roll. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_improved_disarm';