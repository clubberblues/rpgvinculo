DO $migration$
DECLARE
  r record;
  v_def text;
  v_new text;
  v_old text;
  v_replacement text;
BEGIN
  FOR r IN
    SELECT p.oid
      FROM pg_proc p
      JOIN pg_namespace n ON n.oid=p.pronamespace
     WHERE n.nspname='public'
       AND p.proname='aplicar_dano_token_ataque_srd_v2'
       AND p.prokind='f'
  LOOP
    v_def:=pg_get_functiondef(r.oid);
    v_new:=v_def;

    v_old:='v_weapon_proficiency_type:=COALESCE(v_weapon.detalhes->>''weapon_proficiency'','''');';
    v_replacement:=$replace$
v_weapon_proficiency_type:=COALESCE(
  NULLIF(v_weapon.detalhes->>'weapon_proficiency',''),
  CASE
    WHEN lower(concat_ws(' ',v_weapon.detalhes->>'weapon_group',v_weapon.categoria)) LIKE '%exotic%' THEN 'exotic'
    WHEN lower(concat_ws(' ',v_weapon.detalhes->>'weapon_group',v_weapon.categoria)) LIKE '%martial%' THEN 'martial'
    WHEN lower(concat_ws(' ',v_weapon.detalhes->>'weapon_group',v_weapon.categoria)) LIKE '%simple%' THEN 'simple'
    ELSE ''
  END
);
v_is_dwarf_familiar_weapon:=v_sheet.raca_id='anao'
  AND regexp_replace(lower(translate(v_weapon_name,'ã','a')),'[^a-z0-9]+','','g')
    IN ('waraxedwarven','dwarvenwaraxe','urgroshdwarven','dwarvenurgrosh','machadodeguerraanao','urgroshanao');
$replace$;
    IF position(v_old in v_new)=0 THEN
      IF position('v_is_dwarf_familiar_weapon:=' in v_new)=0 THEN
        RAISE EXCEPTION 'Não foi possível localizar o cálculo do tipo de proficiência em %.',r.oid::regprocedure;
      END IF;
    ELSE
      v_new:=replace(v_new,v_old,v_replacement);
    END IF;

    v_old:='v_has_exotic_feat BOOLEAN:=FALSE; v_is_proficient BOOLEAN:=FALSE;';
    v_replacement:='v_has_exotic_feat BOOLEAN:=FALSE; v_is_dwarf_familiar_weapon BOOLEAN:=FALSE; v_is_proficient BOOLEAN:=FALSE;';
    IF position(v_old in v_new)>0 THEN
      v_new:=replace(v_new,v_old,v_replacement);
    ELSIF position('v_is_dwarf_familiar_weapon BOOLEAN' in v_new)=0 THEN
      RAISE EXCEPTION 'Não foi possível declarar a familiaridade racial em %.',r.oid::regprocedure;
    END IF;

    v_old:=$old$
     WHEN v_weapon_proficiency_type='exotic' THEN v_class_has_exact_weapon OR v_has_exotic_feat
$old$;
    v_replacement:=$new$
     WHEN v_weapon_proficiency_type='exotic' THEN
       v_class_has_exact_weapon OR v_has_exotic_feat
       OR (v_is_dwarf_familiar_weapon AND (v_class_has_simple_martial OR v_has_martial_feat))
$new$;
    IF position(v_old in v_new)>0 THEN
      v_new:=replace(v_new,v_old,v_replacement);
    ELSIF position('v_is_dwarf_familiar_weapon AND (v_class_has_simple_martial' in v_new)=0 THEN
      RAISE EXCEPTION 'Não foi possível aplicar a familiaridade do Anão em %.',r.oid::regprocedure;
    END IF;

    IF v_new<>v_def THEN EXECUTE v_new; END IF;
  END LOOP;
END
$migration$;