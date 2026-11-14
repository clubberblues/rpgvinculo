\set ON_ERROR_STOP on

-- These are minimal signature-compatible stand-ins for the GM-only readers.
-- The fixture verifies their security mode and ACL after the migration.
CREATE OR REPLACE FUNCTION public.srd_consultar_modificadores_manobra_srd(
  p_campaign_id bigint,
  p_attacker_token_id text,
  p_defender_token_id text,
  p_maneuver text,
  p_defender_firm_ground boolean,
  p_trip_using_weapon boolean
)
RETURNS jsonb
LANGUAGE sql
SECURITY INVOKER
SET search_path = pg_catalog, public, priv, pg_temp
AS $fixture$
  SELECT '{}'::jsonb
$fixture$;

CREATE OR REPLACE FUNCTION public.srd_listar_ataques_naturais_oportunidade_srd(
  p_campaign_id bigint,
  p_reactor_token_id text
)
RETURNS jsonb
LANGUAGE sql
SECURITY INVOKER
SET search_path = pg_catalog, public, priv, pg_temp
AS $fixture$
  SELECT '{}'::jsonb
$fixture$;

\ir ../../supabase/migrations/20261112170000_restrict_campaign_state_columns.sql

DO $test$
DECLARE
  v_definer boolean;
  v_search_path text;
BEGIN
  IF has_table_privilege('authenticated','public.campaigns','SELECT') THEN
    RAISE EXCEPTION 'Authenticated retains table-level SELECT on campaigns.';
  END IF;
  IF has_column_privilege('authenticated','public.campaigns','cba_data','SELECT') THEN
    RAISE EXCEPTION 'Authenticated can directly read private cba_data.';
  END IF;
  IF has_column_privilege('authenticated','public.campaigns','combat_data','SELECT') THEN
    RAISE EXCEPTION 'Authenticated can directly read private combat_data.';
  END IF;
  IF NOT has_column_privilege('authenticated','public.campaigns','id','SELECT')
     OR NOT has_column_privilege('authenticated','public.campaigns','owner_id','SELECT') THEN
    RAISE EXCEPTION 'Safe campaign metadata columns are no longer readable.';
  END IF;
  IF NOT has_table_privilege('service_role','public.campaigns','SELECT') THEN
    RAISE EXCEPTION 'service_role lost campaign table access.';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
     WHERE schemaname='public'
       AND tablename='campaigns'
       AND policyname='campaigns_member_read'
  ) THEN
    RAISE EXCEPTION 'Campaign membership RLS policy was unexpectedly removed.';
  END IF;

  SELECT p.prosecdef, array_to_string(p.proconfig, ',')
    INTO v_definer, v_search_path
    FROM pg_proc p
   WHERE p.oid='public.srd_consultar_modificadores_manobra_srd(bigint,text,text,text,boolean,boolean)'::regprocedure;
  IF NOT coalesce(v_definer,false) OR coalesce(v_search_path,'') NOT LIKE '%search_path=pg_catalog, public, priv, auth, pg_temp%' THEN
    RAISE EXCEPTION 'GM maneuver reader is not a fixed-path SECURITY DEFINER function.';
  END IF;

  SELECT p.prosecdef, array_to_string(p.proconfig, ',')
    INTO v_definer, v_search_path
    FROM pg_proc p
   WHERE p.oid='public.srd_listar_ataques_naturais_oportunidade_srd(bigint,text)'::regprocedure;
  IF NOT coalesce(v_definer,false) OR coalesce(v_search_path,'') NOT LIKE '%search_path=pg_catalog, public, priv, auth, pg_temp%' THEN
    RAISE EXCEPTION 'GM natural-attack reader is not a fixed-path SECURITY DEFINER function.';
  END IF;

  IF NOT has_function_privilege(
    'authenticated',
    'public.srd_consultar_modificadores_manobra_srd(bigint,text,text,text,boolean,boolean)',
    'EXECUTE'
  ) OR NOT has_function_privilege(
    'authenticated',
    'public.srd_listar_ataques_naturais_oportunidade_srd(bigint,text)',
    'EXECUTE'
  ) THEN
    RAISE EXCEPTION 'Authenticated lost the intended GM-only public RPC entry points.';
  END IF;
END
$test$;

SET ROLE authenticated;
SELECT id, owner_id FROM public.campaigns LIMIT 1;
RESET ROLE;

SELECT 'campaign state column privilege fixture passed' AS result;
