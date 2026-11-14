-- Disposable PostgreSQL fixture. The database is destroyed after the CI job.
\set ON_ERROR_STOP on
DO $roles$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='authenticated') THEN CREATE ROLE authenticated NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='anon') THEN CREATE ROLE anon NOLOGIN; END IF;
END
$roles$;

CREATE OR REPLACE FUNCTION public.finalizar_criacao_personagem_srd(
 text,text,text,jsonb,jsonb,jsonb,jsonb,jsonb,jsonb,text[],jsonb,text,jsonb,jsonb
) RETURNS text LANGUAGE sql SECURITY INVOKER
AS $$ SELECT current_user::text $$;

CREATE OR REPLACE FUNCTION public.criar_personagem_srd_completo(
 text,text,text,jsonb,jsonb,jsonb
) RETURNS text LANGUAGE sql SECURITY DEFINER
AS $$ SELECT 'legacy'::text $$;

CREATE OR REPLACE FUNCTION public.criar_personagem_srd_completo(
 text,text,text,jsonb,jsonb,jsonb,jsonb
) RETURNS text LANGUAGE sql SECURITY DEFINER
AS $$ SELECT 'internal'::text $$;

GRANT EXECUTE ON FUNCTION public.finalizar_criacao_personagem_srd(
 text,text,text,jsonb,jsonb,jsonb,jsonb,jsonb,jsonb,text[],jsonb,text,jsonb,jsonb
) TO authenticated;
GRANT EXECUTE ON FUNCTION public.criar_personagem_srd_completo(
 text,text,text,jsonb,jsonb,jsonb
) TO authenticated;
GRANT EXECUTE ON FUNCTION public.criar_personagem_srd_completo(
 text,text,text,jsonb,jsonb,jsonb,jsonb
) TO authenticated;

\i supabase/migrations/20261112120000_lock_down_character_creation_entrypoint.sql
\i supabase/verification/verify_character_creation_entrypoint.sql

SET ROLE authenticated;
DO $runtime$
DECLARE v_owner text;
BEGIN
  v_owner := public.finalizar_criacao_personagem_srd(
    NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
  );
  IF v_owner <> 'postgres' THEN
    RAISE EXCEPTION 'Finalizer did not execute with its trusted owner; current_user=%',v_owner;
  END IF;
END
$runtime$;
RESET ROLE;
SELECT 'character creation entrypoint fixture passed' AS result;
