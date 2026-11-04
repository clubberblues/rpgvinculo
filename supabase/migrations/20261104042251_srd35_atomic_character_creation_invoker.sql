-- O RPC de orquestração não precisa de privilégios elevados próprios.
-- As operações internas já são RPCs SECURITY DEFINER com validação de auth.uid().
ALTER FUNCTION public.finalizar_criacao_personagem_srd(
  text,text,text,jsonb,jsonb,jsonb,jsonb,jsonb,jsonb,text[],jsonb,text,jsonb,jsonb
) SECURITY INVOKER;
