
ALTER FUNCTION public.srd_resolver_derrubar_srd(
  bigint,text,text,integer,integer,boolean,boolean,boolean
) SET SCHEMA priv;

ALTER FUNCTION priv.srd_resolver_derrubar_srd(
  bigint,text,text,integer,integer,boolean,boolean,boolean
) SET search_path = pg_catalog, public, priv, pg_temp;

REVOKE ALL ON FUNCTION priv.srd_resolver_derrubar_srd(
  bigint,text,text,integer,integer,boolean,boolean,boolean
) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION priv.srd_resolver_derrubar_srd(
  bigint,text,text,integer,integer,boolean,boolean,boolean
) TO authenticated;

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
  SELECT priv.srd_resolver_derrubar_srd(
    p_campaign_id,p_attacker_token_id,p_defender_token_id,
    p_attacker_d20,p_defender_d20,p_defender_uses_dex,
    p_defender_firm_ground,p_trip_using_weapon
  );
$function$;

REVOKE ALL ON FUNCTION public.srd_resolver_derrubar_srd(
  bigint,text,text,integer,integer,boolean,boolean,boolean
) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_resolver_derrubar_srd(
  bigint,text,text,integer,integer,boolean,boolean,boolean
) TO authenticated;
