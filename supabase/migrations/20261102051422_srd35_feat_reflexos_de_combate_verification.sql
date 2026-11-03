-- Verify reflexos_de_combate against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 334-350.'
WHERE id = 'reflexos_de_combate';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 334-350; Combat Reflexes: additional attacks of opportunity equal to Dexterity bonus and attacks of opportunity while flat-footed; fighter bonus feat and monk bonus feat at level 2. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'reflexos_de_combate';