UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://www.d20srd.org/srd/skills/disguise.htm',
    source_notes='Conferência individual concluída no d20 SRD Skills, linhas 37-51.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','37-51',
      'verified_srd_name','Disguise',
      'verification_summary','Disfarce segue a perícia Disguise do SRD, incluindo testes opostos e modificadores.',
      'engine_status','needs_implementation'
    )
WHERE id='disfarce';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido no d20 SRD Skills, linhas 37-51; Disfarce segue a perícia Disguise do SRD, incluindo testes opostos e modificadores. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='disfarce';