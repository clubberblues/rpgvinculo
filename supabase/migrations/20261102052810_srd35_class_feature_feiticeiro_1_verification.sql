UPDATE public.srd_class_level_features
SET verification_status='verified_srd',
    source_id='dnd35-srd-ogl',
    mechanics=COALESCE(mechanics,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_url','https://www.d20srd.org/srd/classes/sorcererWizard.htm',
      'verified_against_srd_lines','47-48,132-139',
      'verification_summary','Nível 1 do Feiticeiro: invocar familiar, conferido na tabela e descrição de familiar.',
      'engine_status','needs_implementation'
    )
WHERE class_id='feiticeiro' AND class_level=1 AND feature_key='features';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Nível 1 do Feiticeiro: invocar familiar, conferido na tabela e descrição de familiar. Fonte: https://www.d20srd.org/srd/classes/sorcererWizard.htm, linhas 47-48,132-139. Implementação do motor ainda pendente.'
WHERE catalog_key='class_features' AND entry_id='feiticeiro:1:features';