-- Disposable regression test for the legacy six-argument character creator.
\set ON_ERROR_STOP on
BEGIN;

DO $roles$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='authenticated') THEN CREATE ROLE authenticated NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='anon') THEN CREATE ROLE anon NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='service_role') THEN CREATE ROLE service_role NOLOGIN; END IF;
END
$roles$;

CREATE OR REPLACE FUNCTION public.criar_personagem_srd_completo(
  text, text, text, jsonb, jsonb, jsonb
) RETURNS text LANGUAGE sql SECURITY DEFINER
AS $$ SELECT 'legacy-path'::text $$;

CREATE OR REPLACE FUNCTION public.criar_personagem_srd_completo(
  text, text, text, jsonb, jsonb, jsonb, jsonb
) RETURNS text LANGUAGE sql SECURITY DEFINER
AS $$ SELECT 'validated-path'::text $$;

GRANT EXECUTE ON FUNCTION public.criar_personagem_srd_completo(
  text, text, text, jsonb, jsonb, jsonb
) TO authenticated;
REVOKE ALL ON FUNCTION public.criar_personagem_srd_completo(
  text, text, text, jsonb, jsonb, jsonb, jsonb
) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.criar_personagem_srd_completo(
  text, text, text, jsonb, jsonb, jsonb, jsonb
) TO authenticated;

DO $before$
BEGIN
  IF NOT has_function_privilege('authenticated',
      'public.criar_personagem_srd_completo(text,text,text,jsonb,jsonb,jsonb)','EXECUTE') THEN
    RAISE EXCEPTION 'Fixture precondition failed: legacy endpoint is not exposed to authenticated.';
  END IF;
END
$before$;

\i supabase/migrations/20261112110000_revoke_legacy_character_creation_rpc.sql

DO $after$
DECLARE
  v_legacy oid := to_regprocedure('public.criar_personagem_srd_completo(text,text,text,jsonb,jsonb,jsonb)');
  v_current oid := to_regprocedure('public.criar_personagem_srd_completo(text,text,text,jsonb,jsonb,jsonb,jsonb)');
BEGIN
  IF v_legacy IS NULL OR v_current IS NULL THEN
    RAISE EXCEPTION 'Expected both legacy and current overloads to exist.';
  END IF;
  IF has_function_privilege('authenticated',v_legacy,'EXECUTE')
     OR has_function_privilege('anon',v_legacy,'EXECUTE') THEN
    RAISE EXCEPTION 'Legacy six-argument character creation remains client-callable.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM aclexplode(COALESCE((SELECT proacl FROM pg_proc WHERE oid=v_legacy),
                                      acldefault('f',(SELECT proowner FROM pg_proc WHERE oid=v_legacy)))) a
    WHERE a.grantee=0 AND a.privilege_type='EXECUTE'
  ) THEN
    RAISE EXCEPTION 'PUBLIC still has EXECUTE on the legacy character creator.';
  END IF;
  IF NOT has_function_privilege('authenticated',v_current,'EXECUTE') THEN
    RAISE EXCEPTION 'The current validated seven-argument creator was unexpectedly revoked.';
  END IF;
END
$after$;

ROLLBACK;
SELECT 'legacy character creation ACL fixture passed' AS result;
