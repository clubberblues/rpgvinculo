UPDATE public.srd_equipment
SET detalhes = COALESCE(detalhes, '{}'::jsonb)
  || jsonb_build_object('weapon_proficiency_name','Shuriken','weapon_focus_name','Shuriken')
WHERE id='shuriken_10' AND categoria='arma';