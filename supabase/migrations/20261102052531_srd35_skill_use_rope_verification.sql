UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://www.d20srd.org/srd/skills/useRope.htm',
    source_notes='Conferência individual concluída no d20 SRD Skills, linhas 37-88.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','37-88',
      'verified_srd_name','Use Rope',
      'verification_summary','Use Rope do SRD, com nós, gancho, amarras e sinergias.',
      'engine_status','needs_implementation'
    )
WHERE id='srd35_skill_use_rope';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido no d20 SRD Skills, linhas 37-88; Use Rope do SRD, com nós, gancho, amarras e sinergias. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='srd35_skill_use_rope';