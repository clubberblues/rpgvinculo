UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://www.d20srd.org/srd/skills/perform.htm',
    source_notes='Conferência individual concluída no d20 SRD Skills, linhas 37-86.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','37-86',
      'verified_srd_name','Perform',
      'verification_summary','Perform do SRD, incluindo categorias de atuação e CDs de apresentação.',
      'engine_status','needs_implementation'
    )
WHERE id='srd35_skill_perform';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido no d20 SRD Skills, linhas 37-86; Perform do SRD, incluindo categorias de atuação e CDs de apresentação. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='srd35_skill_perform';