-- Verify trickery domain against the open d20 SRD cleric domains.
UPDATE public.srd_domains
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/spellLists/clericDomains.htm',
    mechanics = COALESCE(mechanics, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '342-356',
      'verification_summary', 'Bluff, Disguise, and Hide become cleric class skills; nine domain spells verified.',
      'engine_status', 'needs_implementation'
    )
WHERE domain_id = 'trickery';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Cleric Domains, linhas 342-356; poder concedido e lista de magias conferidos, implementação do motor ainda pendente.'
WHERE catalog_key = 'domains' AND entry_id = 'trickery';