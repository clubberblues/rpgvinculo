
CREATE OR REPLACE FUNCTION priv.srd_weapon_proficiency(p_details jsonb, p_weapon_name text)
RETURNS text
LANGUAGE plpgsql
IMMUTABLE
SET search_path TO 'pg_catalog'
AS $function$
DECLARE
  v_prof text:=lower(btrim(coalesce(p_details->>'weapon_proficiency','')));
  v_group text:=lower(btrim(coalesce(p_details->>'weapon_group','')));
  v_text text;
BEGIN
  IF v_prof LIKE '%exotic%' THEN RETURN 'exotic'; END IF;
  IF v_prof LIKE '%martial%' THEN RETURN 'martial'; END IF;
  IF v_prof LIKE '%simple%' THEN RETURN 'simple'; END IF;

  IF v_group LIKE '%exotic%' THEN RETURN 'exotic'; END IF;
  IF v_group LIKE '%martial%' THEN RETURN 'martial'; END IF;
  IF v_group LIKE '%simple%' THEN RETURN 'simple'; END IF;

  v_text:=lower(translate(
    concat_ws(' ',coalesce(p_weapon_name,''),coalesce(p_details->'campos_catalogo'->>'descricao_origem','')),
    'áàâãäéèêëíìîïóòôõöúùûüç','aaaaaeeeeiiiiooooouuuuc'
  ));

  -- Specific weapons whose SRD text defines an exceptional base weapon.
  IF v_text LIKE '%sun blade%' OR v_text LIKE '%luck blade%' THEN
    RETURN 'martial';
  END IF;

  IF v_text ~ '(^|[^a-z])(bastard sword|two[- ]bladed sword|orc double axe|dwarven waraxe|waraxe|urgrosh|spiked chain|hand crossbow|repeating crossbow|dire flail|gnome hooked hammer|kama|nunchaku|sai|shuriken|siangham|bolas|net|whip)([^a-z]|$)' THEN
    RETURN 'exotic';
  END IF;

  IF v_text ~ '(^|[^a-z])(dagger|javelin|heavy mace|light mace|mace|heavy crossbow|light crossbow|crossbow|club|dart|gauntlet|light hammer|morningstar|quarterstaff|sickle|spear|longspear|shortspear|sling|bolt|arrow|unarmed strike)([^a-z]|$)' THEN
    RETURN 'simple';
  END IF;

  IF v_text ~ '(^|[^a-z])(battleaxe|longsword|greatsword|greataxe|warhammer|rapier|scimitar|trident|longbow|shortbow|glaive|halberd|flail|guisarme|ranseur|lance|falchion|kukri|handaxe|throwing axe|heavy pick|light pick|short sword|shortsword|sap)([^a-z]|$)' THEN
    RETURN 'martial';
  END IF;

  RETURN '';
END;
$function$;

REVOKE ALL ON FUNCTION priv.srd_weapon_proficiency(jsonb,text) FROM PUBLIC, anon, authenticated;
