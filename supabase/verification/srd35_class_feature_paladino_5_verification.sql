UPDATE public.srd_class_level_features
SET verification_status='verified_srd',
    source_id='dnd35-srd-ogl',
    mechanics=COALESCE(mechanics,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_url','https://www.d20srd.org/srd/classes/paladin.htm',
      'verified_against_srd_lines','66-85,94-142',
      'verification_summary','Nível 5 do Paladino conferido individualmente na tabela e descrição SRD.',
      'engine_status','needs_implementation'
    )
WHERE class_id='paladino' AND class_level=5 AND feature_key='features';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Nível 5 do Paladino conferido no SRD oficial em https://www.d20srd.org/srd/classes/paladin.htm, linhas 66-85 e 94-142. Implementação do motor ainda pendente.'
WHERE catalog_key='class_features' AND entry_id='paladino:5:features';