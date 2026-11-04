-- Migration: verify srd35_feat_improved_bull_rush against the open d20 SRD.
-- Verify srd35_feat_improved_bull_rush against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 659-671.'
WHERE id = 'srd35_feat_improved_bull_rush';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 659-671; Requires Str 13 and Power Attack; bull rush does not provoke from defender and gains +4 opposed Strength check. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_improved_bull_rush';
