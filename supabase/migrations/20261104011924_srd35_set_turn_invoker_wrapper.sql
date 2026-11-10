CREATE OR REPLACE FUNCTION public.set_turn(cid bigint, p_token bigint)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path TO 'public', 'pg_temp'
AS $function$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.tokens
    WHERE id = p_token AND campaign_id = cid
  ) THEN
    RAISE EXCEPTION 'Token inexistente.';
  END IF;

  -- A RPC privilegiada mantém a validação definitiva de GM e combate ativo.
  PERFORM public.combat_set_turn(p_token);
END
$function$;

REVOKE ALL ON FUNCTION public.set_turn(bigint, bigint) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_turn(bigint, bigint) TO authenticated;