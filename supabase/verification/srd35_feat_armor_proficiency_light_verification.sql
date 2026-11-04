-- Migration: verify srd35_feat_armor_proficiency_light against the open d20 SRD.
-- Verify srd35_feat_armor_proficiency_light against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 226-237.'
WHERE id = 'srd35_feat_armor_proficiency_light';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 226-237; Light armor proficiency limits armor check penalty to listed movement-related skills; most classes receive it automatically. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_armor_proficiency_light';
