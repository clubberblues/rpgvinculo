-- Migration: verify srd35_feat_improved_familiar against the open d20 SRD.
-- Verify srd35_feat_improved_familiar against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 745-756.'
WHERE id = 'srd35_feat_improved_familiar';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 745-756; Improved Familiar allows qualifying spellcasters to choose nonstandard familiars with alignment and level prerequisites; type and communication exceptions apply. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_improved_familiar';
