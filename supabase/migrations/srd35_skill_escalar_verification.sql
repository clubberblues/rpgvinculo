UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://www.d20srd.org/srd/skills/climb.htm',
    source_notes='Conferência individual concluída no d20 SRD Skills, linhas 37-77.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','37-77',
      'verified_srd_name','Climb',
      'verification_summary','Escalar segue a perícia Climb do SRD, incluindo superfícies, CDs e falha.',
      'engine_status','needs_implementation'
    )
WHERE id='escalar';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido no d20 SRD Skills, linhas 37-77; Escalar segue a perícia Climb do SRD, incluindo superfícies, CDs e falha. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='escalar';