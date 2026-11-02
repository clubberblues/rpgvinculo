UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md',
    source_notes='Conferência individual concluída na fonte SRD, linhas 439-453.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','439-453',
      'verified_srd_name','Move Silently',
      'verification_summary','Move Silently do SRD, com oposição a Listen, penalidades de velocidade e superfícies ruidosas.',
      'engine_status','needs_implementation'
    )
WHERE id='mover_silenciosamente';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido na fonte SRD, linhas 439-453; Move Silently do SRD, com oposição a Listen, penalidades de velocidade e superfícies ruidosas. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='mover_silenciosamente';