BEGIN;
UPDATE public.srd_conditions
SET verification_status='verified_srd',
    source_url='https://www.d20srd.org/srd/conditionSummary.htm',
    mechanical_effects=COALESCE(mechanical_effects,'{}'::jsonb)||jsonb_build_object('verified_against_srd_lines','40-42','engine_status','needs_implementation')
WHERE condition_id='abilitydamaged';
UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Conferida contra a seção Ability Damaged do Condition Summary do SRD; implementação no motor ainda pendente.'
WHERE catalog_key='conditions' AND entry_id='abilitydamaged';
COMMIT;