UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://www.d20srd.org/srd/skills/spot.htm',
    source_notes='Conferência individual concluída no d20 SRD Skills, linhas 37-86.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','37-86',
      'verified_srd_name','Spot',
      'verification_summary','Observar é a equivalência localizada de Spot, usada para detectar criaturas, disfarces e sinais.',
      'engine_status','needs_implementation'
    )
WHERE id='observar';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido no d20 SRD Skills, linhas 37-86; Observar é a equivalência localizada de Spot, usada para detectar criaturas, disfarces e sinais. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='observar';