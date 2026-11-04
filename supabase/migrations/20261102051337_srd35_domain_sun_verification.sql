-- Verify sun domain against the open d20 SRD cleric domains.
UPDATE public.srd_domains
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/spellLists/clericDomains.htm',
    mechanics = COALESCE(mechanics, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '310-324',
      'verification_summary', 'Once-per-day greater turning destroys undead that would be turned; nine domain spells verified.',
      'engine_status', 'needs_implementation'
    )
WHERE domain_id = 'sun';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Cleric Domains, linhas 310-324; poder concedido e lista de magias conferidos, implementação do motor ainda pendente.'
WHERE catalog_key = 'domains' AND entry_id = 'sun';