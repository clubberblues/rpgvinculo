UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://www.d20srd.org/srd/skills/useMagicDevice.htm',
    source_notes='Conferência individual concluída na fonte SRD, linhas 37-110.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','37-110',
      'verified_srd_name','Use Magic Device',
      'verification_summary','Usar Instrumento Mágico é a equivalência localizada de Use Magic Device, com ativação, emulação e sinergias.',
      'engine_status','needs_implementation'
    )
WHERE id='usar_instrumento_magico';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido na fonte SRD, linhas 37-110; Usar Instrumento Mágico é a equivalência localizada de Use Magic Device, com ativação, emulação e sinergias. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='usar_instrumento_magico';