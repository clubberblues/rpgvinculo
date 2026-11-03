UPDATE public.srd_class_level_features
SET verification_status='verified_srd',
    source_id='dnd35-srd-ogl',
    mechanics=COALESCE(mechanics,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_url','https://www.d20srd.org/srd/classes/monk.htm',
      'verified_against_srd_section','Table: The Monk',
      'verification_summary','Nível 3 do Monge conferido individualmente na tabela de progressão SRD.',
      'engine_status','needs_implementation'
    )
WHERE class_id='monge' AND class_level=3 AND feature_key='features';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Nível 3 do Monge conferido na fonte SRD oficial https://www.d20srd.org/srd/classes/monk.htm, Table: The Monk. Implementação do motor ainda pendente.'
WHERE catalog_key='class_features' AND entry_id='monge:3:features';