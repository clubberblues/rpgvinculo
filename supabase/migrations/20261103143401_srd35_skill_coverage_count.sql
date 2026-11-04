UPDATE public.srd_catalog_coverage
SET actual_entries=50,
    audit_notes='50 perícias no catálogo atual. Conferir cada perícia, uso treinado, sinergias, CDs e integração com ações.'
WHERE ruleset_id='dnd35-srd' AND catalog_key='skills';