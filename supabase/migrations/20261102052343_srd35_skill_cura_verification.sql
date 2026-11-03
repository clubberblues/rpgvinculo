UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://www.d20srd.org/srd/skills/heal.htm',
    source_notes='Conferência individual concluída no d20 SRD Skills, linhas 37-59.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','37-59',
      'verified_srd_name','Heal',
      'verification_summary','Cura segue a perícia Heal do SRD, incluindo primeiros socorros e tratamento.',
      'engine_status','needs_implementation'
    )
WHERE id='cura';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido no d20 SRD Skills, linhas 37-59; Cura segue a perícia Heal do SRD, incluindo primeiros socorros e tratamento. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='cura';