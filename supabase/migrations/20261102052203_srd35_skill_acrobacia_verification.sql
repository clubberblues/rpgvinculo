-- Verify acrobacia against the open d20 SRD skills page.
UPDATE public.srd_skills
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/skills/tumble.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 37-82.',
    dados_tecnicos = COALESCE(dados_tecnicos, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '37-82',
      'verification_summary', 'Portuguese Acrobacia corresponds to SRD Tumble; attribute Dex, trained-only and armor check penalty; movement and fall/avoidance DC rules verified.',
      'engine_status', 'needs_implementation'
    )
WHERE id = 'acrobacia';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Skills, linhas 37-82; Portuguese Acrobacia corresponds to SRD Tumble; attribute Dex, trained-only and armor check penalty; movement and fall/avoidance DC rules verified. Implementação do motor ainda pendente.'
WHERE catalog_key = 'skills' AND entry_id = 'acrobacia';