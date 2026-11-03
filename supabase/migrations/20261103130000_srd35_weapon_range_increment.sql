alter table public.srd_equipment
  add column if not exists alcance_incremento text;

update public.srd_equipment
set alcance_incremento = nullif(nullif(detalhes->>'range_increment','—'),'')
where tipo in ('weapon','arma');

-- Correct two source-table rows whose importer shifted the range and weight columns.
update public.srd_equipment
set critico='—',
    alcance_incremento='10 ft.',
    peso=6,
    detalhes=coalesce(detalhes,'{}'::jsonb) || jsonb_build_object(
      'range_increment','10 ft.',
      'weight','6 lb.',
      'catalog_correction','Range and weight columns corrected against D&D 3.5 SRD'
    )
where id='srd35_equipment_exotic_weapons_ranged_weapons_net';

update public.srd_equipment
set critico='—',
    alcance_incremento=null,
    peso=1,
    detalhes=coalesce(detalhes,'{}'::jsonb) || jsonb_build_object(
      'range_increment','—',
      'weight','1 lb.',
      'catalog_correction','Ammunition weight corrected against D&D 3.5 SRD'
    )
where id='srd35_equipment_exotic_weapons_ranged_weapons_bolts_5';
