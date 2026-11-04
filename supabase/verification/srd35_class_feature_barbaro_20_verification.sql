UPDATE public.srd_class_level_features
SET verification_status='verified_srd',
    source_id='dnd35-srd-ogl',
    mechanics=COALESCE(mechanics,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_url','https://www.d20srd.org/srd/classes/barbarian.htm',
      'verified_against_srd_lines','44-63',
      'verification_summary','Nível 20 do Bárbaro conferido individualmente na tabela de progressão SRD.',
      'engine_status','needs_implementation'
    )
WHERE class_id='barbaro' AND class_level=20 AND feature_key='features';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Nível 20 do Bárbaro conferido no SRD oficial em https://www.d20srd.org/srd/classes/barbarian.htm, linhas 44-63. Implementação do motor ainda pendente.'
WHERE catalog_key='class_features' AND entry_id='barbaro:20:features';