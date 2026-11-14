CREATE OR REPLACE FUNCTION public.remove_condition(p_char bigint, p_condition text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  c public.characters;
  role_jogador text;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  SELECT * INTO c
  FROM public.characters
  WHERE id = p_char;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Personagem inexistente.';
  END IF;

  role_jogador := public.my_role(c.campaign_id);
  IF role_jogador IS NULL OR role_jogador NOT IN ('GM', 'PLAYER') THEN
    RAISE EXCEPTION 'Sem permissão.';
  END IF;
  IF role_jogador = 'PLAYER' AND c.user_id IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'Você só remove condições de si mesmo.';
  END IF;

  DELETE FROM public.character_conditions
  WHERE character_id = p_char
    AND condition_id = p_condition;

  PERFORM priv.log(
    c.campaign_id,
    'CONDICAO_REMOVIDA',
    jsonb_build_object('char', p_char, 'cond', p_condition)
  );
END
$function$;

CREATE OR REPLACE FUNCTION public.srd_expire_campaign_conditions(p_campaign_id bigint)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_round integer;
  v_count integer;
  v_role text;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  v_role := public.my_role(p_campaign_id);
  IF v_role IS NULL OR v_role NOT IN ('GM', 'PLAYER') THEN
    RAISE EXCEPTION 'Sem acesso à campanha.';
  END IF;

  SELECT coalesce(nullif(combat_data->>'round','')::integer,0)
  INTO v_round
  FROM public.campaigns
  WHERE id = p_campaign_id;
  IF NOT FOUND OR v_round < 1 THEN
    RETURN 0;
  END IF;

  UPDATE public.srd_campaign_conditions
  SET active = false
  WHERE campaign_id = p_campaign_id
    AND active = true
    AND expires_round IS NOT NULL
    AND expires_round <= v_round;

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END
$function$;

REVOKE ALL ON FUNCTION public.remove_condition(bigint, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.remove_condition(bigint, text) TO authenticated;

REVOKE ALL ON FUNCTION public.srd_expire_campaign_conditions(bigint) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_expire_campaign_conditions(bigint) TO authenticated;