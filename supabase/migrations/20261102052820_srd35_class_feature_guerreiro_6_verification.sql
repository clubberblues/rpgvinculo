UPDATE public.srd_class_level_features
SET verification_status='verified_srd',
    source_id='dnd35-srd-ogl',
    mechanics=COALESCE(mechanics,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_url','https://www.d20srd.org/srd/classes/fighter.htm',
      'verified_against_srd_lines','45-45,88-91',
      'verification_summary','Nível 6 do Guerreiro: talento adicional, conferido na tabela e descrição de talentos bônus.',
      'engine_status','needs_implementation'
    )
WHERE class_id='guerreiro' AND class_level=6 AND feature_key='features';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Nível 6 do Guerreiro: talento adicional, conferido na tabela e descrição de talentos bônus. Fonte: https://www.d20srd.org/srd/classes/fighter.htm, linhas 45-45,88-91. Implementação do motor ainda pendente.'
WHERE catalog_key='class_features' AND entry_id='guerreiro:6:features';