-- Migration: verify avaliacao against the open d20 SRD.
-- Verify avaliacao against the open d20 SRD skills page.
UPDATE public.srd_skills
SET source_status = 'verified_srd',
    srd_source_url = 'https://www.d20srd.org/srd/skills/appraise.htm',
    source_notes = 'Conferência individual concluída no d20 SRD; linhas 37-67.',
    dados_tecnicos = COALESCE(dados_tecnicos, '{}'::jsonb) || jsonb_build_object(
      'verified_against_srd_lines', '37-67',
      'verification_summary', 'Appraise uses Int; common and rare item DCs, action time, retry, and special modifiers verified.',
      'engine_status', 'needs_implementation'
    )
WHERE id = 'avaliacao';

UPDATE public.srd_catalog_entry_audit
SET audit_status = 'manual_verified',
    audit_notes = 'Conferido no d20 SRD Skills, linhas 37-67; Appraise uses Int; common and rare item DCs, action time, retry, and special modifiers verified. Implementação do motor ainda pendente.'
WHERE catalog_key = 'skills' AND entry_id = 'avaliacao';
