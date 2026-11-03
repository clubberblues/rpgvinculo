-- Verify foco_em_arma against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 1600-1615.'
WHERE id = 'foco_em_arma';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 1600-1615; Weapon Focus: selected weapon, unarmed strike, grapple, or ray; prerequisites proficiency and base attack bonus +1; grants +1 attack with selected weapon; repeatable for different weapons. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'foco_em_arma';