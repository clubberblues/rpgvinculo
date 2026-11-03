UPDATE public.srd_skills
SET source_status='verified_srd',
    srd_source_url='https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md',
    source_notes='Conferência individual concluída na fonte SRD, linhas 613-644.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_lines','613-644',
      'verified_srd_name','Speak Language',
      'verification_summary','Speak Language do SRD, sem testes; pontos compram idiomas e alfabetos são definidos por idioma.',
      'engine_status','needs_implementation'
    )
WHERE id='srd35_skill_speak_language';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferido na fonte SRD, linhas 613-644; Speak Language do SRD, sem testes; pontos compram idiomas e alfabetos são definidos por idioma. Implementação do motor ainda pendente.'
WHERE catalog_key='skills' AND entry_id='srd35_skill_speak_language';