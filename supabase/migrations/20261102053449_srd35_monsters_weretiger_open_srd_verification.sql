UPDATE public.srd_monsters
SET source_status='verified_srd',
    srd_source_url='https://olimot.github.io/srd-v3.5-ko/monsters/monsters-k-l.html',
    source_notes='Registro conferido na página SRD aberta de licantropia; implementação do motor ainda pendente.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_page','https://olimot.github.io/srd-v3.5-ko/monsters/monsters-k-l.html',
      'verification_scope','weretiger_forms',
      'engine_status','needs_implementation'
    )
WHERE id IN ('weretiger_hybrid_form','weretiger_tiger_form');

UPDATE public.srd_catalog_entry_audit
SET audit_status='manual_verified',
    audit_notes='Forma do Weretiger conferida na página SRD aberta https://olimot.github.io/srd-v3.5-ko/monsters/monsters-k-l.html; implementação do motor ainda pendente.'
WHERE catalog_key='monsters' AND entry_id IN ('weretiger_hybrid_form','weretiger_tiger_form');