-- Verify srd35_feat_improved_unarmed_strike against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 921-935.'
WHERE id = 'srd35_feat_improved_unarmed_strike';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 921-935; Improved Unarmed Strike treats the character as armed while unarmed, avoids attacks of opportunity when attacking armed opponents, and allows lethal or nonlethal unarmed damage. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_improved_unarmed_strike';