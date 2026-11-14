-- Make the validated finalizer the only client-facing character-creation entry point.
-- The wrapper retains auth.uid() checks and delegates all creation steps in one transaction.
-- Running as the postgres-owned SECURITY DEFINER wrapper lets its internal creation
-- functions be revoked from clients without breaking the public workflow.
BEGIN;

ALTER FUNCTION public.finalizar_criacao_personagem_srd(
  text, text, text, jsonb, jsonb, jsonb, jsonb, jsonb, jsonb,
  text[], jsonb, text, jsonb, jsonb
) SECURITY DEFINER;

ALTER FUNCTION public.finalizar_criacao_personagem_srd(
  text, text, text, jsonb, jsonb, jsonb, jsonb, jsonb, jsonb,
  text[], jsonb, text, jsonb, jsonb
) SET search_path TO public, pg_temp;

REVOKE ALL ON FUNCTION public.finalizar_criacao_personagem_srd(
  text, text, text, jsonb, jsonb, jsonb, jsonb, jsonb, jsonb,
  text[], jsonb, text, jsonb, jsonb
) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.finalizar_criacao_personagem_srd(
  text, text, text, jsonb, jsonb, jsonb, jsonb, jsonb, jsonb,
  text[], jsonb, text, jsonb, jsonb
) TO authenticated;

REVOKE ALL ON FUNCTION public.criar_personagem_srd_completo(
  text, text, text, jsonb, jsonb, jsonb
) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.criar_personagem_srd_completo(
  text, text, text, jsonb, jsonb, jsonb, jsonb
) FROM PUBLIC, anon, authenticated;

COMMIT;
