-- Verify evil domain against the open d20 SRD cleric domains.
UPDATE public.srd_domains
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/spellLists/clericDomains.htm',
    mechanics = COALESCE(mechanics, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '135-150',
      'verification_summary', '+1 caster level for evil spells and nine Evil domain spells verified in the SRD.',
      'engine_status', 'needs_implementation'
    )
WHERE domain_id = 'evil';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Cleric Domains, linhas 135-150; poder concedido e lista de magias conferidos, implementação do motor ainda pendente.'
WHERE catalog_key = 'domains' AND entry_id = 'evil';