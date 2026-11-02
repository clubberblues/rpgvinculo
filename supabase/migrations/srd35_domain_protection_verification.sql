-- Migration: verify protection domain against the open d20 SRD.
-- Verify protection domain against the open d20 SRD cleric domains.
UPDATE public.srd_domains
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/spellLists/clericDomains.htm',
    mechanics = COALESCE(mechanics, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '280-294',
      'verification_summary', 'Once-per-day supernatural protective ward grants touched target resistance bonus equal to cleric level on next saving throw for 1 hour; nine domain spells verified.',
      'engine_status', 'needs_implementation'
    )
WHERE domain_id = 'protection';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Cleric Domains, linhas 280-294; poder concedido e lista de magias conferidos, implementação do motor ainda pendente.'
WHERE catalog_key = 'domains' AND entry_id = 'protection';
