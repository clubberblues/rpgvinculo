BEGIN;

UPDATE public.srd_equipment
SET srd_source_url = 'https://www.d20srd.org/srd/equipment/goodsAndServices.htm',
    source_status = 'source_attached',
    detalhes = COALESCE(detalhes, '{}'::jsonb) || jsonb_build_object(
      'official_reference_url', 'https://www.d20srd.org/srd/equipment/goodsAndServices.htm',
      'range_increment_feet', 10,
      'attack_type', 'ranged_touch',
      'direct_damage', '1d6 acid',
      'splash_damage', '1 acid within 5 feet',
      'catalog_audit_scope', 'Entrada individual conferida na seção Special Substances and Items e no bloco Acid do SRD.'
    )
WHERE id = 'acido_frasco';

COMMIT;