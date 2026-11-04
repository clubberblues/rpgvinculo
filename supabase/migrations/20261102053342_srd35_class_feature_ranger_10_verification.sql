UPDATE public.srd_class_level_features
SET verification_status='verified_srd',
    source_id='dnd35-srd-ogl',
    mechanics=COALESCE(mechanics,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_url','https://www.d20srd.org/srd/classes/ranger.htm',
      'verified_against_srd_lines','63-82,108-159',
      'verification_summary','Nível 10 do Ranger conferido na tabela e descrição SRD.',
      'engine_status','needs_implementation'
    )
WHERE class_id='ranger' AND class_level=10 AND feature_key='features';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Nível 10 do Ranger conferido na tabela e descrição SRD. Fonte: https://www.d20srd.org/srd/classes/ranger.htm, linhas 63-82,108-159. Implementação do motor ainda pendente.'
WHERE catalog_key='class_features' AND entry_id='ranger:10:features';