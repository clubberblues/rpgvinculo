-- Migration: verify air domain against the open d20 SRD.
-- Verify air domain against the open d20 SRD cleric domains.
UPDATE public.srd_domains
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/spellLists/clericDomains.htm',
    mechanics = COALESCE(mechanics, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '39-54',
      'verification_summary', 'Granted power and nine Air domain spells verified in the SRD.',
      'engine_status', 'needs_implementation'
    )
WHERE domain_id = 'air';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Cleric Domains, linhas 39-54; poder concedido e lista de magias conferidos, implementação do motor ainda pendente.'
WHERE catalog_key = 'domains' AND entry_id = 'air';
