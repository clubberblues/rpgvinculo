UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://www.d20srd.org/srd/skills/escapeArtist.htm',
    source_notes='Conferência individual concluída no d20 SRD Skills, linhas 37-70.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','37-70',
      'verified_srd_name','Escape Artist',
      'verification_summary','Fuga segue a perícia Escape Artist do SRD, incluindo amarras, apertos e agarrões.',
      'engine_status','needs_implementation'
    )
WHERE id='fuga';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido no d20 SRD Skills, linhas 37-70; Fuga segue a perícia Escape Artist do SRD, incluindo amarras, apertos e agarrões. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='fuga';