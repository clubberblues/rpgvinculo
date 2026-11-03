-- Verify Portuguese Tenacidade as the SRD Toughness feat.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Correspondência individual conferida: Tenacidade = Toughness no d20 SRD, linhas 1448-1455.'
WHERE id = 'tenacidade';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 1448-1455; Toughness concede +3 PV e pode ser adquirido múltiplas vezes com efeitos cumulativos. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'tenacidade';