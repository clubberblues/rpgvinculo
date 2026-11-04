-- Verify srd35_feat_improved_trip against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 872-891.'
WHERE id = 'srd35_feat_improved_trip';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 872-891; Improved Trip requires Int 13 and Combat Expertise; unarmed trip does not provoke, grants +4 trip check, and gives immediate melee attack after successful trip. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_improved_trip';