UPDATE public.srd_class_level_features
SET mechanics=COALESCE(mechanics,'{}'::jsonb)||jsonb_build_object('verified_against_srd_lines','188','verification_summary','Nível 20 do Mago: talento adicional na tabela do Mago.')
WHERE class_id='mago' AND class_level=20 AND feature_key='features';
UPDATE public.srd_catalog_entry_audit
SET audit_notes='Nível 20 do Mago: talento adicional na tabela do Mago. Fonte: https://www.d20srd.org/srd/classes/sorcererWizard.htm, linha 188. Implementação do motor ainda pendente.'
WHERE catalog_key='class_features' AND entry_id='mago:20:features';