-- Migration: verify knowledge domain against the open d20 SRD.
-- Verify knowledge domain against the open d20 SRD cleric domains.
UPDATE public.srd_domains
SET verification_status = 'verified_srd',
    source_url = 'https://www.d20srd.org/srd/spellLists/clericDomains.htm',
    mechanics = COALESCE(mechanics, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '200-216',
      'verification_summary', 'All Knowledge skills become cleric class skills and divination spells gain +1 caster level; nine domain spells verified.',
      'engine_status', 'needs_implementation'
    )
WHERE domain_id = 'knowledge';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Cleric Domains, linhas 200-216; poder concedido e lista de magias conferidos, implementação do motor ainda pendente.'
WHERE catalog_key = 'domains' AND entry_id = 'knowledge';
