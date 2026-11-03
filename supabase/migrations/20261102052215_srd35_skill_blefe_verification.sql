-- Verify blefe against the open d20 SRD skills page.
UPDATE public.srd_skills
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/skills/bluff.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 37-66.',
    dados_tecnicos = COALESCE(dados_tecnicos, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '37-66',
      'verification_summary', 'Bluff uses Cha; opposed Sense Motive, feint, diversion, and secret-message rules verified.',
      'engine_status', 'needs_implementation'
    )
WHERE id = 'blefe';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Skills, linhas 37-66; Bluff uses Cha; opposed Sense Motive, feint, diversion, and secret-message rules verified. Implementação do motor ainda pendente.'
WHERE catalog_key = 'skills' AND entry_id = 'blefe';