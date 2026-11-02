-- Migration: verify srd35_feat_forge_ring against the open d20 SRD.
-- Verify srd35_feat_forge_ring against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 557-567.'
WHERE id = 'srd35_feat_forge_ring';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 557-567; Forge Ring requires caster level 12; creates or repairs qualifying rings with one-day-per-1000-gp time, XP, materials, and extra cost rules. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_forge_ring';
