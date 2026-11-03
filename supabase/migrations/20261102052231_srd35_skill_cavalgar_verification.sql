-- Verify cavalgar against the open d20 SRD skills page.
UPDATE public.srd_skills
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/skills/ride.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 37-105.',
    dados_tecnicos = COALESCE(dados_tecnicos, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '37-105',
      'verification_summary', 'Ride uses Dex; riding DCs and mounted actions, reactions, combat control, and synergy rules verified.',
      'engine_status', 'needs_implementation'
    )
WHERE id = 'cavalgar';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Skills, linhas 37-105; Ride uses Dex; riding DCs and mounted actions, reactions, combat control, and synergy rules verified. Implementação do motor ainda pendente.'
WHERE catalog_key = 'skills' AND entry_id = 'cavalgar';