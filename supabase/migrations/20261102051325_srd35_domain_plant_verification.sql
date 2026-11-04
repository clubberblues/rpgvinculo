-- Verify plant domain against the open d20 SRD cleric domains.
UPDATE public.srd_domains
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/spellLists/clericDomains.htm',
    mechanics = COALESCE(mechanics, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '263-279',
      'verification_summary', 'Rebuke or command plant creatures 3 + Charisma modifier times per day and add Knowledge (nature) to cleric skills; nine domain spells verified.',
      'engine_status', 'needs_implementation'
    )
WHERE domain_id = 'plant';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Cleric Domains, linhas 263-279; poder concedido e lista de magias conferidos, implementação do motor ainda pendente.'
WHERE catalog_key = 'domains' AND entry_id = 'plant';