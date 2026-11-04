-- Migration: verify ataque_poderoso against the open d20 SRD.
-- Verify ataque_poderoso against the open d20 SRD feats page.
UPDATE public.srd_feats
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/feats.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 1166-1178.'
WHERE id = 'ataque_poderoso';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Feats, linhas 1166-1178; Power Attack: Str 13; choose attack penalty up to base attack bonus and equal melee damage bonus; two-handed use doubles damage bonus; light weapons excluded except unarmed/natural attacks. Implementação do motor ainda pendente.'
WHERE catalog_key = 'feats' AND entry_id = 'ataque_poderoso';
