-- Verify esquiva against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 456-469.'
WHERE id = 'esquiva';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 456-469; Dodge: Dex 13; designate an opponent during your action for +1 dodge AC against that opponent; may change opponent on any action; dodge bonuses are lost when Dexterity bonus is lost. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'esquiva';