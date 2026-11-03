UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://www.d20srd.org/srd/skills/listen.htm',
    source_notes='Conferência individual concluída no d20 SRD Skills, linhas 37-99.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','37-99',
      'verified_srd_name','Listen',
      'verification_summary','Ouvir é a equivalência localizada de Listen, com CDs de ruídos e oposição a Move Silently.',
      'engine_status','needs_implementation'
    )
WHERE id='ouvir';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido no d20 SRD Skills, linhas 37-99; Ouvir é a equivalência localizada de Listen, com CDs de ruídos e oposição a Move Silently. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='ouvir';