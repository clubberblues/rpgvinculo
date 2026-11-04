-- Migration: verify adestrar_animais against the open d20 SRD.
-- Verify adestrar_animais against the open d20 SRD skills page.
UPDATE public.srd_skills
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/skills/handleAnimal.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 37-96.',
    dados_tecnicos = COALESCE(dados_tecnicos, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '37-96',
      'verification_summary', 'Handle Animal uses Cha and is trained-only; animal handling, pushing, training tricks, and purpose DCs verified.',
      'engine_status', 'needs_implementation'
    )
WHERE id = 'adestrar_animais';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Skills, linhas 37-96; Handle Animal uses Cha and is trained-only; animal handling, pushing, training tricks, and purpose DCs verified. Implementação do motor ainda pendente.'
WHERE catalog_key = 'skills' AND entry_id = 'adestrar_animais';
