-- Migration: verify srd35_feat_still_spell against the open d20 SRD.
-- Verify srd35_feat_still_spell against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 1427-1433.'
WHERE id = 'srd35_feat_still_spell';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 1427-1433; Still Spell removes somatic components and uses a slot one level higher. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_still_spell';
