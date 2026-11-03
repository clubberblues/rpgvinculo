UPDATE public.srd_class_level_features
SET verification_status='verified_srd',
    source_id='dnd35-srd-ogl',
    mechanics=COALESCE(mechanics,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_url','https://www.d20srd.org/srd/classes/sorcererWizard.htm',
      'verified_against_srd_lines','178,?',
      'verification_summary','Nível 10 do Mago: talento adicional, conferido na tabela do Mago.',
      'engine_status','needs_implementation'
    )
WHERE class_id='mago' AND class_level=10 AND feature_key='features';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Nível 10 do Mago: talento adicional, conferido na tabela do Mago. Fonte: https://www.d20srd.org/srd/classes/sorcererWizard.htm, linhas 178,?. Implementação do motor ainda pendente.'
WHERE catalog_key='class_features' AND entry_id='mago:10:features';