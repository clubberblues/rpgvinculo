update public.srd_equipment
set preco='0',
    custo_po='0.00',
    detalhes=coalesce(detalhes,'{}'::jsonb) || jsonb_build_object(
      'price_interpretation','Sem custo listado no SRD; disponível por 0 PO',
      'price_source','D&D 3.5 SRD - Weapons'
    )
where id in (
  'srd35_equipment_simple_weapons_one_handed_melee_weapons_club',
  'srd35_equipment_simple_weapons_two_handed_melee_weapons_quarterstaff',
  'srd35_equipment_simple_weapons_ranged_weapons_sling'
)
and coalesce(custo_po,preco) is null;