UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://www.d20srd.org/srd/skills/openLock.htm',
    source_notes='Conferência individual concluída no d20 SRD Skills, linhas 37-72.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','37-72',
      'verified_srd_name','Open Lock',
      'verification_summary','Open Lock do SRD, com CDs de fechaduras e ferramentas de ladrão.',
      'engine_status','needs_implementation'
    )
WHERE id='srd35_skill_open_lock';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido no d20 SRD Skills, linhas 37-72; Open Lock do SRD, com CDs de fechaduras e ferramentas de ladrão. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='srd35_skill_open_lock';