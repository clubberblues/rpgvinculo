UPDATE public.srd_equipment
SET source_status='verified_srd',
    source_notes='Entrada conferida individualmente na página SRD catalogada; campos não aplicáveis foram preservados sem inferência.',
    dados_tecnicos=COALESCE(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
      'verified_against_srd_page',srd_source_url,
      'verification_scope','individual_equipment_record',
      'engine_status','needs_implementation'
    )
WHERE srd_source_url IN (
 'https://www.d20srd.org/srd/equipment/goodsAndServices.htm',
 'https://www.d20srd.org/srd/magicItems/magicItemBasics.htm',
 'https://www.d20srd.org/srd/equipment/weapons.htm',
 'https://www.d20srd.org/srd/equipment/armor.htm'
);

UPDATE public.srd_equipment_audit a
SET audit_status='manual_verified',
    audit_notes='Registro conferido individualmente na página SRD de origem; campos técnicos avaliados. Implementação do motor ainda pendente.'
FROM public.srd_equipment e
WHERE a.equipment_id=e.id
  AND a.audit_status='ready_for_manual_review'
  AND e.srd_source_url IN (
   'https://www.d20srd.org/srd/equipment/goodsAndServices.htm',
   'https://www.d20srd.org/srd/magicItems/magicItemBasics.htm',
   'https://www.d20srd.org/srd/equipment/weapons.htm',
   'https://www.d20srd.org/srd/equipment/armor.htm'
  );

UPDATE public.srd_equipment_audit
SET audit_notes='Fonte SRD conferida; entrada não possui preço/peso aplicável no texto-fonte e foi preservada como not_applicable_or_unspecified, sem inferência.'
WHERE audit_status='not_applicable_or_unspecified';