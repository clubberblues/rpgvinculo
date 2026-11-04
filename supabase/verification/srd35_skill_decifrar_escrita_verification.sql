UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-i.md',
    source_notes='Conferência individual concluída na fonte SRD, linhas 579-591.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','579-591',
      'verified_srd_name','Decipher Script',
      'verification_summary','Decipher Script do SRD, incluindo CDs 20/25/30+, leitura de uma página, ação e sinergia.',
      'engine_status','needs_implementation'
    )
WHERE id='decifrar_escrita';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido na fonte SRD, linhas 579-591; Decipher Script do SRD, incluindo CDs 20/25/30+, leitura de uma página, ação e sinergia. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='decifrar_escrita';