UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://www.d20srd.org/srd/skills/profession.htm',
    source_notes='Conferência individual concluída no d20 SRD Skills, linhas 37-62.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','37-62',
      'verified_srd_name','Profession',
      'verification_summary','Profissão segue Profession do SRD, representando vocação ampla distinta de Craft.',
      'engine_status','needs_implementation'
    )
WHERE id='profissao';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido no d20 SRD Skills, linhas 37-62; Profissão segue Profession do SRD, representando vocação ampla distinta de Craft. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='profissao';