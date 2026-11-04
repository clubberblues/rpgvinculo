UPDATE public.srd_class_level_features
SET verification_status='verified_srd',
    source_id='dnd35-srd-ogl',
    mechanics=COALESCE(mechanics,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_url','https://www.d20srd.org/srd/classes/cleric.htm',
      'verified_against_srd_lines','68,121-125',
      'verification_summary','Nível 1 do Clérigo: expulsar ou fascinar mortos-vivos, conferido na tabela e descrição da habilidade.',
      'engine_status','needs_implementation'
    )
WHERE class_id='clerigo' AND class_level=1 AND feature_key='features';

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Nível 1 do Clérigo conferido no SRD oficial em https://www.d20srd.org/srd/classes/cleric.htm, linhas 68 e 121-125. Implementação do motor ainda pendente.'
WHERE catalog_key='class_features' AND entry_id='clerigo:1:features';