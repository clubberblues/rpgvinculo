UPDATE public.srd_class_level_features
SET verification_status='verified_srd',
    source_id='dnd35-srd-ogl',
    mechanics=COALESCE(mechanics,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_url','https://www.d20srd.org/srd/classes/bard.htm',
      'verified_against_srd_lines','65-86',
      'verification_summary','Nível 15 do Bardo conferido individualmente na tabela de progressão SRD.',
      'engine_status','needs_implementation'
    )
WHERE class_id='bardo' AND class_level=15 AND feature_key='features';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Nível 15 do Bardo conferido no SRD oficial em https://www.d20srd.org/srd/classes/bard.htm, linhas 65-86. Implementação do motor ainda pendente.'
WHERE catalog_key='class_features' AND entry_id='bardo:15:features';