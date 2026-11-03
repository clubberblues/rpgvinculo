-- Restrict the cleric-domain selection RPC to signed-in users.
-- The function also checks auth.uid() and character ownership in its body.
REVOKE EXECUTE ON FUNCTION public.salvar_dominios_personagem_srd(text, text[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.salvar_dominios_personagem_srd(text, text[]) TO authenticated;
