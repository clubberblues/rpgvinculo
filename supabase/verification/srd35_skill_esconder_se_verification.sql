UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://www.d20srd.org/srd/skills/hide.htm',
    source_notes='Conferência individual concluída no d20 SRD Skills, linhas 37-44.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','37-44',
      'verified_srd_name','Hide',
      'verification_summary','Esconder-se segue a perícia Hide do SRD, incluindo cobertura, tamanho e observação.',
      'engine_status','needs_implementation'
    )
WHERE id='esconder_se';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido no d20 SRD Skills, linhas 37-44; Esconder-se segue a perícia Hide do SRD, incluindo cobertura, tamanho e observação. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='esconder_se';