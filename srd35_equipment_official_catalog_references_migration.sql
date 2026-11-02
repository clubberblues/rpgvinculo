BEGIN;
UPDATE public.srd_equipment
SET srd_source_url = CASE
  WHEN lower(coalesce(categoria,'')) LIKE '%arma%' THEN 'https://www.d20srd.org/srd/equipment/weapons.htm'
  WHEN lower(coalesce(categoria,'')) LIKE '%armadura%' OR lower(coalesce(categoria,'')) LIKE '%escudo%' THEN 'https://www.d20srd.org/srd/equipment/armor.htm'
  WHEN lower(coalesce(categoria,'')) LIKE '%poção%' OR lower(coalesce(categoria,'')) LIKE '%potion%' OR lower(coalesce(categoria,'')) LIKE '%anel%' OR lower(coalesce(categoria,'')) LIKE '%ring%' OR lower(coalesce(categoria,'')) LIKE '%varinha%' OR lower(coalesce(categoria,'')) LIKE '%wand%' OR lower(coalesce(categoria,'')) LIKE '%maravilhoso%' THEN 'https://www.d20srd.org/srd/magicItems/magicItemBasics.htm'
  ELSE 'https://www.d20srd.org/srd/equipment/goodsAndServices.htm'
END,
detalhes = COALESCE(detalhes,'{}'::jsonb) || jsonb_build_object('official_catalog_reference', CASE
  WHEN lower(coalesce(categoria,'')) LIKE '%arma%' THEN 'https://www.d20srd.org/srd/equipment/weapons.htm'
  WHEN lower(coalesce(categoria,'')) LIKE '%armadura%' OR lower(coalesce(categoria,'')) LIKE '%escudo%' THEN 'https://www.d20srd.org/srd/equipment/armor.htm'
  WHEN lower(coalesce(categoria,'')) LIKE '%poção%' OR lower(coalesce(categoria,'')) LIKE '%potion%' OR lower(coalesce(categoria,'')) LIKE '%anel%' OR lower(coalesce(categoria,'')) LIKE '%ring%' OR lower(coalesce(categoria,'')) LIKE '%varinha%' OR lower(coalesce(categoria,'')) LIKE '%wand%' OR lower(coalesce(categoria,'')) LIKE '%maravilhoso%' THEN 'https://www.d20srd.org/srd/magicItems/magicItemBasics.htm'
  ELSE 'https://www.d20srd.org/srd/equipment/goodsAndServices.htm'
END, 'audit_status','source_attached')
WHERE COALESCE(source_status,'') <> 'excluded';
COMMIT;