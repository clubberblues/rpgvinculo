UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://www.d20srd.org/srd/skills/search.htm',
    source_notes='Conferência individual concluída no d20 SRD Skills, linhas 37-84.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','37-84',
      'verified_srd_name','Search',
      'verification_summary','Procurar é a equivalência localizada de Search, incluindo portas secretas, armadilhas e buscas.',
      'engine_status','needs_implementation'
    )
WHERE id='procurar';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido no d20 SRD Skills, linhas 37-84; Procurar é a equivalência localizada de Search, incluindo portas secretas, armadilhas e buscas. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='procurar';