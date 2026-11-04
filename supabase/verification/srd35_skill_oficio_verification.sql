UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://www.d20srd.org/srd/skills/craft.htm',
    source_notes='Conferência individual concluída no d20 SRD Skills, linhas 37-121.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','37-121',
      'verified_srd_name','Craft',
      'verification_summary','Ofício é a equivalência localizada de Craft, incluindo criação, ferramentas, CDs e progresso.',
      'engine_status','needs_implementation'
    )
WHERE id='oficio';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido no d20 SRD Skills, linhas 37-121; Ofício é a equivalência localizada de Craft, incluindo criação, ferramentas, CDs e progresso. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='oficio';