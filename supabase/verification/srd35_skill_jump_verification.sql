UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://www.d20srd.org/srd/skills/jump.htm',
    source_notes='Conferência individual concluída no d20 SRD Skills, linhas 37-129.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','37-129',
      'verified_srd_name','Jump',
      'verification_summary','Jump do SRD, com CDs de saltos e modificadores de velocidade.',
      'engine_status','needs_implementation'
    )
WHERE id='srd35_skill_jump';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido no d20 SRD Skills, linhas 37-129; Jump do SRD, com CDs de saltos e modificadores de velocidade. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='srd35_skill_jump';