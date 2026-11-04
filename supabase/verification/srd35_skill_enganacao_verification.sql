UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://www.d20srd.org/srd/skills/bluff.htm',
    source_notes='Conferência individual concluída no d20 SRD Skills, linhas 37-66.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','37-66',
      'verified_srd_name','Bluff',
      'verification_summary','Enganação segue a perícia Bluff do SRD, incluindo blefes, finta e mensagens secretas.',
      'engine_status','needs_implementation'
    )
WHERE id='enganacao';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido no d20 SRD Skills, linhas 37-66; Enganação segue a perícia Bluff do SRD, incluindo blefes, finta e mensagens secretas. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='enganacao';