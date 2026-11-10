-- Isolated regression fixture for the exact SECURITY DEFINER remediation migration.
-- Uses disposable PostgreSQL roles/schemas and never touches application data.
\set ON_ERROR_STOP on
BEGIN;

DO $roles$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='authenticated') THEN CREATE ROLE authenticated NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='anon') THEN CREATE ROLE anon NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='service_role') THEN CREATE ROLE service_role NOLOGIN; END IF;
END
$roles$;

CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS priv;
GRANT USAGE ON SCHEMA auth, priv TO authenticated, anon;

CREATE OR REPLACE FUNCTION auth.uid()
RETURNS uuid LANGUAGE sql STABLE
AS $$ SELECT nullif(current_setting('request.jwt.claim.sub',true),'')::uuid $$;
GRANT EXECUTE ON FUNCTION auth.uid() TO PUBLIC;

CREATE OR REPLACE FUNCTION public.my_role(cid bigint)
RETURNS text LANGUAGE sql STABLE
AS $$ SELECT current_setting('fixture.campaign_role',true) $$;
GRANT EXECUTE ON FUNCTION public.my_role(bigint) TO authenticated, anon;

CREATE OR REPLACE FUNCTION priv.srd35_maneuver_profile(bigint,text)
RETURNS jsonb LANGUAGE sql STABLE
AS $$ SELECT jsonb_build_object('ok',true) $$;
REVOKE ALL ON FUNCTION priv.srd35_maneuver_profile(bigint,text) FROM PUBLIC, authenticated, anon;

CREATE OR REPLACE FUNCTION priv.srd_grid_footprint_distance_ft(integer,integer,integer,integer,integer,integer)
RETURNS integer LANGUAGE sql IMMUTABLE
AS $$ SELECT 5 $$;
REVOKE ALL ON FUNCTION priv.srd_grid_footprint_distance_ft(integer,integer,integer,integer,integer,integer) FROM PUBLIC, authenticated, anon;

CREATE OR REPLACE FUNCTION priv.srd_token_grid_footprint(bigint,text)
RETURNS integer LANGUAGE sql STABLE
AS $$ SELECT 1 $$;
REVOKE ALL ON FUNCTION priv.srd_token_grid_footprint(bigint,text) FROM PUBLIC, authenticated, anon;

CREATE OR REPLACE FUNCTION priv.srd_parse_natural_attack_list(text)
RETURNS jsonb LANGUAGE sql IMMUTABLE
AS $$ SELECT '[]'::jsonb $$;
REVOKE ALL ON FUNCTION priv.srd_parse_natural_attack_list(text) FROM PUBLIC, authenticated, anon;


CREATE OR REPLACE FUNCTION priv.srd_feat_saving_throw_modifier(jsonb,text)
RETURNS integer LANGUAGE sql STABLE SECURITY DEFINER
SET search_path TO pg_catalog, public, priv, pg_temp
AS $ SELECT 0 $;
GRANT EXECUTE ON FUNCTION priv.srd_feat_saving_throw_modifier(jsonb,text) TO authenticated, service_role;

CREATE OR REPLACE FUNCTION priv.srd_saving_throw_bonus(bigint,text,text,text,text)
RETURNS integer LANGUAGE sql STABLE SECURITY DEFINER
SET search_path TO pg_catalog, public, priv, pg_temp
AS $ SELECT priv.srd_feat_saving_throw_modifier('[]'::jsonb,'fortitude') $;

CREATE OR REPLACE FUNCTION public.srd_consultar_modificadores_manobra_srd(
  bigint,text,text,text,boolean,boolean
) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY INVOKER
AS $fn$
BEGIN
  IF auth.uid() IS NULL OR public.my_role($1) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre';
  END IF;
  PERFORM priv.srd35_maneuver_profile($1,$2);
  PERFORM priv.srd_grid_footprint_distance_ft(0,0,1,0,0,1);
  PERFORM priv.srd_token_grid_footprint($1,$2);
  RETURN '{"ok":true}'::jsonb;
END
$fn$;

CREATE OR REPLACE FUNCTION public.srd_listar_ataques_naturais_oportunidade_srd(bigint,text)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY INVOKER
AS $fn$
BEGIN
  IF auth.uid() IS NULL OR public.my_role($1) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre';
  END IF;
  PERFORM priv.srd35_maneuver_profile($1,$2);
  PERFORM priv.srd_parse_natural_attack_list('bite');
  RETURN '{"ok":true}'::jsonb;
END
$fn$;

GRANT EXECUTE ON FUNCTION public.srd_consultar_modificadores_manobra_srd(bigint,text,text,text,boolean,boolean) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.srd_listar_ataques_naturais_oportunidade_srd(bigint,text) TO authenticated, service_role;

-- Apply the same migration that will be deployed in production.
\i supabase/migrations/20261110150000_fix_invoker_maneuver_catalog_helper_permissions.sql
\i supabase/verification/verify_maneuver_catalog_rpc_security.sql
\i supabase/migrations/20261110160000_revoke_public_feat_saving_throw_helper.sql
\i supabase/verification/verify_passive_feat_helper_acl.sql

SET ROLE authenticated;
SELECT set_config('request.jwt.claim.sub','11111111-1111-4111-8111-111111111111',true);
SELECT set_config('fixture.campaign_role','GM',true);
DO $gm$
BEGIN
  IF public.srd_consultar_modificadores_manobra_srd(1,'a','b','trip',true,false)->>'ok' <> 'true' THEN
    RAISE EXCEPTION 'GM maneuver wrapper did not return success';
  END IF;
  IF public.srd_listar_ataques_naturais_oportunidade_srd(1,'monster')->>'ok' <> 'true' THEN
    RAISE EXCEPTION 'GM natural attack wrapper did not return success';
  END IF;
  IF priv.srd_feat_saving_throw_modifier('[]'::jsonb,'fortitude') <> 0
     OR priv.srd_saving_throw_bonus(1,'character','1','fortitude','base') <> 0 THEN
    RAISE EXCEPTION 'Authenticated saving throw helper call failed';
  END IF;
  BEGIN
    PERFORM priv.srd35_maneuver_profile(1,'a');
    RAISE EXCEPTION 'Authenticated unexpectedly executed private helper';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;
END
$gm$;

SELECT set_config('fixture.campaign_role','PLAYER',true);
DO $player$
BEGIN
  BEGIN
    PERFORM public.srd_consultar_modificadores_manobra_srd(1,'a','b','trip',true,false);
    RAISE EXCEPTION 'Player unexpectedly passed maneuver GM guard';
  EXCEPTION WHEN raise_exception THEN
    IF SQLERRM='Player unexpectedly passed maneuver GM guard' THEN RAISE; END IF;
  END;
  BEGIN
    PERFORM public.srd_listar_ataques_naturais_oportunidade_srd(1,'monster');
    RAISE EXCEPTION 'Player unexpectedly passed natural attack GM guard';
  EXCEPTION WHEN raise_exception THEN
    IF SQLERRM='Player unexpectedly passed natural attack GM guard' THEN RAISE; END IF;
  END;
END
$player$;
RESET ROLE;

SET ROLE anon;
DO $anon$
BEGIN
  BEGIN
    PERFORM priv.srd_feat_saving_throw_modifier('[]'::jsonb,'fortitude');
    RAISE EXCEPTION 'Anon unexpectedly executed passive feat helper';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;
END
$anon$;
RESET ROLE;

ROLLBACK;
SELECT 'maneuver catalog SECURITY DEFINER fixture passed' AS result;
