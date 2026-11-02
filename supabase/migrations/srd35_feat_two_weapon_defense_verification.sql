-- Migration: verify srd35_feat_two_weapon_defense against the open d20 SRD.
-- Verify srd35_feat_two_weapon_defense against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 1552-1565.'
WHERE id = 'srd35_feat_two_weapon_defense';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 1552-1565; Requires Dex 15 and Two-Weapon Fighting; grants +1 shield AC with two weapons, +2 while fighting defensively or total defense. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_two_weapon_defense';
