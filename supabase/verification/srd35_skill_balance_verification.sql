UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://www.d20srd.org/srd/skills/balance.htm',
    source_notes='Conferência individual concluída no d20 SRD Skills, linhas 37-85.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','37-85',
      'verified_srd_name','Balance',
      'verification_summary','Balance do SRD, com superfícies estreitas/difíceis e penalidade de armadura.',
      'engine_status','needs_implementation'
    )
WHERE id='srd35_skill_balance';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido no d20 SRD Skills, linhas 37-85; Balance do SRD, com superfícies estreitas/difíceis e penalidade de armadura. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='srd35_skill_balance';