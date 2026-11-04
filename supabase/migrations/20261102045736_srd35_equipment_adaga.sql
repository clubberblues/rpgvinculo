BEGIN;

UPDATE public.srd_equipment
SET srd_source_url = 'https://www.d20srd.org/srd/equipment/weapons.htm',
    source_status = 'source_attached',
    detalhes = COALESCE(detalhes, '{}'::jsonb) || jsonb_build_object(
      'official_reference_url', 'https://www.d20srd.org/srd/equipment/weapons.htm',
      'weapon_proficiency', 'simple',
      'weapon_group', 'light_melee',
      'damage_medium', '1d4',
      'damage_small', '1d3',
      'critical', '19-20/x2',
      'range_increment_feet', 10,
      'weight_lb', 1,
      'damage_type', 'piercing_or_slashing',
      'special_rule', '+2 Sleight of Hand to conceal the dagger'
    )
WHERE id = 'adaga';

COMMIT;