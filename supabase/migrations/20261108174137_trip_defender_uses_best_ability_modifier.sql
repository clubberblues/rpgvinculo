
CREATE OR REPLACE FUNCTION priv.srd_resolver_derrubar_srd_api(
  p_campaign_id bigint,
  p_attacker_token_id text,
  p_defender_token_id text,
  p_attacker_d20 integer,
  p_defender_d20 integer,
  p_defender_firm_ground boolean DEFAULT false,
  p_trip_using_weapon boolean DEFAULT false
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, pg_temp
AS $function$
DECLARE
  v_defender jsonb;
  v_use_dex boolean;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode resolver esta manobra.';
  END IF;
  v_defender:=priv.srd35_maneuver_profile(p_campaign_id,p_defender_token_id);
  v_use_dex:=(v_defender->>'dexterity_modifier')::integer >
             (v_defender->>'strength_modifier')::integer;
  RETURN priv.srd_resolver_derrubar_srd(
    p_campaign_id,p_attacker_token_id,p_defender_token_id,
    p_attacker_d20,p_defender_d20,v_use_dex,
    p_defender_firm_ground,p_trip_using_weapon
  );
END;
$function$;

REVOKE ALL ON FUNCTION priv.srd_resolver_derrubar_srd_api(bigint,text,text,integer,integer,boolean,boolean)
  FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION priv.srd_resolver_derrubar_srd_api(bigint,text,text,integer,integer,boolean,boolean)
  TO authenticated;

CREATE OR REPLACE FUNCTION public.srd_resolver_derrubar_srd(
  p_campaign_id bigint,
  p_attacker_token_id text,
  p_defender_token_id text,
  p_attacker_d20 integer,
  p_defender_d20 integer,
  p_defender_uses_dex boolean DEFAULT false,
  p_defender_firm_ground boolean DEFAULT false,
  p_trip_using_weapon boolean DEFAULT false
)
RETURNS jsonb
LANGUAGE sql
SECURITY INVOKER
SET search_path = public, pg_temp
AS $function$
  SELECT priv.srd_resolver_derrubar_srd_api(
    p_campaign_id,p_attacker_token_id,p_defender_token_id,
    p_attacker_d20,p_defender_d20,p_defender_firm_ground,p_trip_using_weapon
  );
$function$;

REVOKE ALL ON FUNCTION public.srd_resolver_derrubar_srd(bigint,text,text,integer,integer,boolean,boolean,boolean)
  FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_resolver_derrubar_srd(bigint,text,text,integer,integer,boolean,boolean,boolean)
  TO authenticated;
