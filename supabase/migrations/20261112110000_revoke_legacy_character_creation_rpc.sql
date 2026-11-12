-- The six-argument creation endpoint bypasses the identity/race/class-choice
-- validation performed by the current seven-argument flow and has no active
-- frontend call site. Keep creation on finalizar_criacao_personagem_srd.
BEGIN;

REVOKE ALL ON FUNCTION public.criar_personagem_srd_completo(
  text, text, text, jsonb, jsonb, jsonb
) FROM PUBLIC, anon, authenticated;

COMMIT;
