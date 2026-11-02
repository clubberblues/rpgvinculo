-- Migration: verify srd35_feat_improved_precise_shot against the open d20 SRD.
-- Verify srd35_feat_improved_precise_shot against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 818-835.'
WHERE id = 'srd35_feat_improved_precise_shot';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 818-835; Improved Precise Shot requires Dex 19, Point Blank Shot, Precise Shot, and BAB +11; source entry verified individually. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_improved_precise_shot';
