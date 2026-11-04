-- Verify srd35_feat_precise_shot against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 1179-1191.'
WHERE id = 'srd35_feat_precise_shot';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 1179-1191; Precise Shot requires Point Blank Shot and removes the standard -4 ranged attack penalty against opponents in melee. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'srd35_feat_precise_shot';