UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://www.d20srd.org/srd/skills/disableDevice.htm',
    source_notes='Conferência individual concluída no d20 SRD Skills, linhas 37-98.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','37-98',
      'verified_srd_name','Disable Device',
      'verification_summary','Disable Device do SRD, com CDs, armadilhas e tentativa de desarme.',
      'engine_status','needs_implementation'
    )
WHERE id='srd35_skill_disable_device';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido no d20 SRD Skills, linhas 37-98; Disable Device do SRD, com CDs, armadilhas e tentativa de desarme. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='srd35_skill_disable_device';