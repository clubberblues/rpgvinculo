UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://www.d20srd.org/srd/skills/knowledge.htm',
    source_notes='Conferência individual concluída no d20 SRD Skills, linhas 37-79.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','37-79',
      'verified_srd_name','Knowledge',
      'verification_summary','Conhecimento (religião) segue a perícia Knowledge do SRD; a especialização identifica religião.',
      'engine_status','needs_implementation'
    )
WHERE id='conhecimento_religiao';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido no d20 SRD Skills, linhas 37-79; Conhecimento (religião) segue a perícia Knowledge do SRD; a especialização identifica religião. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='conhecimento_religiao';