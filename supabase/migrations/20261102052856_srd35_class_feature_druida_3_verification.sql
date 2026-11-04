UPDATE public.srd_class_level_features
SET verification_status='verified_srd',
    source_id='dnd35-srd-ogl',
    mechanics=COALESCE(mechanics,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_url','https://www.d20srd.org/srd/classes/druid.htm',
      'verified_against_srd_lines','65-84,111-160',
      'verification_summary','Nível 3 do Druida conferido individualmente na tabela e descrição de habilidades SRD.',
      'engine_status','needs_implementation'
    )
WHERE class_id='druida' AND class_level=3 AND feature_key='features';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Nível 3 do Druida conferido no SRD oficial em https://www.d20srd.org/srd/classes/druid.htm, linhas 65-84 e 111-160. Implementação do motor ainda pendente.'
WHERE catalog_key='class_features' AND entry_id='druida:3:features';