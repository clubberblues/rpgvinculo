UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://www.d20srd.org/srd/skills/survival.htm',
    source_notes='Conferência individual concluída no d20 SRD Skills, linhas 37-83.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','37-83',
      'verified_srd_name','Survival',
      'verification_summary','Sobrevivência segue Survival do SRD, incluindo alimentação, rastreamento e segurança na natureza.',
      'engine_status','needs_implementation'
    )
WHERE id='sobrevivencia';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido no d20 SRD Skills, linhas 37-83; Sobrevivência segue Survival do SRD, incluindo alimentação, rastreamento e segurança na natureza. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='sobrevivencia';