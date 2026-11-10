
ALTER FUNCTION public.srd_iniciar_derrubar_com_aoo_srd(bigint,text,text,boolean,boolean) SET SCHEMA priv;
ALTER FUNCTION priv.srd_iniciar_derrubar_com_aoo_srd(bigint,text,text,boolean,boolean)
  SET search_path = pg_catalog, public, priv, pg_temp;
REVOKE ALL ON FUNCTION priv.srd_iniciar_derrubar_com_aoo_srd(bigint,text,text,boolean,boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION priv.srd_iniciar_derrubar_com_aoo_srd(bigint,text,text,boolean,boolean) TO authenticated;

CREATE OR REPLACE FUNCTION public.srd_iniciar_derrubar_com_aoo_srd(
  p_campaign_id bigint,p_attacker_token_id text,p_defender_token_id text,
  p_defender_firm_ground boolean DEFAULT false,p_trip_using_weapon boolean DEFAULT false
)
RETURNS jsonb
LANGUAGE sql
SECURITY INVOKER
SET search_path = public, priv, pg_temp
AS $function$
  SELECT priv.srd_iniciar_derrubar_com_aoo_srd(
    p_campaign_id,p_attacker_token_id,p_defender_token_id,
    p_defender_firm_ground,p_trip_using_weapon
  );
$function$;
REVOKE ALL ON FUNCTION public.srd_iniciar_derrubar_com_aoo_srd(bigint,text,text,boolean,boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_iniciar_derrubar_com_aoo_srd(bigint,text,text,boolean,boolean) TO authenticated;

ALTER FUNCTION public.srd_resolver_derrubar_apos_aoo_srd(bigint,uuid,integer,integer,boolean) SET SCHEMA priv;
ALTER FUNCTION priv.srd_resolver_derrubar_apos_aoo_srd(bigint,uuid,integer,integer,boolean)
  SET search_path = pg_catalog, public, priv, pg_temp;
REVOKE ALL ON FUNCTION priv.srd_resolver_derrubar_apos_aoo_srd(bigint,uuid,integer,integer,boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION priv.srd_resolver_derrubar_apos_aoo_srd(bigint,uuid,integer,integer,boolean) TO authenticated;

CREATE OR REPLACE FUNCTION public.srd_resolver_derrubar_apos_aoo_srd(
  p_campaign_id bigint,p_pending_id uuid,p_attacker_d20 integer,p_defender_d20 integer,
  p_defender_firm_ground boolean DEFAULT false
)
RETURNS jsonb
LANGUAGE sql
SECURITY INVOKER
SET search_path = public, priv, pg_temp
AS $function$
  SELECT priv.srd_resolver_derrubar_apos_aoo_srd(
    p_campaign_id,p_pending_id,p_attacker_d20,p_defender_d20,p_defender_firm_ground
  );
$function$;
REVOKE ALL ON FUNCTION public.srd_resolver_derrubar_apos_aoo_srd(bigint,uuid,integer,integer,boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_resolver_derrubar_apos_aoo_srd(bigint,uuid,integer,integer,boolean) TO authenticated;
