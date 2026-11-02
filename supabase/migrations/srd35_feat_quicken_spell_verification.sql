-- Migration: verify srd35_feat_quicken_spell against the open d20 SRD.
-- Verify srd35_feat_quicken_spell against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 1211-1217.'
WHERE id = 'srd35_feat_quicken_spell';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 1211-1217; Quicken Spell makes a spell a swift action, allows another action in the round, uses a slot four levels higher, and does not provoke opportunity attacks; spontaneous-casting limitation applies. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_quicken_spell';
