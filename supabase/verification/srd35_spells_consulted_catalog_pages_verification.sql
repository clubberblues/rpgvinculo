UPDATE public.srd_spells
SET source_status='verified_srd',
    source_notes='Registro conferido na página SRD indicada; efeitos e integração do motor documentados para implementação.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_page',srd_source_url,
      'verification_scope','individual_record_on_consulted_spell_page',
      'engine_status','needs_implementation'
    )
WHERE srd_source_url IN ('https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md','https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md','https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md','https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md','https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md','https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md','https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md','https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md','https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md','https://www.d20srd.org/srd/spells/entangle.htm','https://www.d20srd.org/srd/spells/ordersWrath.htm','https://www.d20srd.org/srd/spells/unholyBlight.htm','https://www.d20srd.org/srd/spells/chaosHammer.htm','https://www.d20srd.org/srd/spells/holySmite.htm','https://www.d20srd.org/srd/spells/burningHands.htm');

UPDATE public.srd_catalog_entry_audit a
SET audit_status='manual_verified',
    audit_notes='Entrada de magia conferida individualmente na página SRD catalogada em '||s.srd_source_url||'. Implementação do motor ainda pendente.'
FROM public.srd_spells s
WHERE a.catalog_key='spells' AND a.entry_id=s.id AND s.srd_source_url IN ('https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md','https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md','https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md','https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md','https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md','https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md','https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md','https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md','https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md','https://www.d20srd.org/srd/spells/entangle.htm','https://www.d20srd.org/srd/spells/ordersWrath.htm','https://www.d20srd.org/srd/spells/unholyBlight.htm','https://www.d20srd.org/srd/spells/chaosHammer.htm','https://www.d20srd.org/srd/spells/holySmite.htm','https://www.d20srd.org/srd/spells/burningHands.htm');