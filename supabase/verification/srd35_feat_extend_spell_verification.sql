-- Migration: verify srd35_feat_extend_spell against the open d20 SRD.
-- Verify srd35_feat_extend_spell against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 521-524.'
WHERE id = 'srd35_feat_extend_spell';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 521-524; Extend Spell doubles duration, except concentration, instantaneous, or permanent durations; uses a slot one level higher. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_extend_spell';
