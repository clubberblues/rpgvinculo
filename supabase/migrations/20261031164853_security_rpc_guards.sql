-- Close NULL-role authorization gaps in legacy SECURITY DEFINER RPCs.
BEGIN;

CREATE POLICY campaign_codes_gm_read ON public.campaign_codes
  FOR SELECT TO authenticated
  USING (public.my_role(campaign_id) = 'GM');
GRANT SELECT ON TABLE public.campaign_codes TO authenticated;

CREATE OR REPLACE FUNCTION public.apply_condition(
  p_char BIGINT,
  p_condition TEXT,
  p_origem TEXT DEFAULT NULL,
  p_duracao TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, pg_temp
AS $$
DECLARE
  v_character public.characters%ROWTYPE;
  v_role TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  SELECT * INTO v_character
  FROM public.characters
  WHERE id = p_char;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Personagem inexistente.';
  END IF;

  v_role := public.my_role(v_character.campaign_id);
  IF v_role IS NULL OR v_role NOT IN ('GM', 'PLAYER') THEN
    RAISE EXCEPTION 'Sem permissão.';
  END IF;
  IF v_role = 'PLAYER' AND v_character.user_id IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'Você só aplica condições em si mesmo.';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.conditions WHERE id = p_condition) THEN
    RAISE EXCEPTION 'Condição inválida.';
  END IF;

  INSERT INTO public.character_conditions (character_id, condition_id, origem, duracao)
  VALUES (p_char, p_condition, p_origem, p_duracao)
  ON CONFLICT (character_id, condition_id)
  DO UPDATE SET origem = EXCLUDED.origem, duracao = EXCLUDED.duracao;

  PERFORM priv.log(
    v_character.campaign_id,
    'CONDICAO_APLICADA',
    JSONB_BUILD_OBJECT('char', p_char, 'cond', p_condition, 'origem', p_origem)
  );
END
$$;

CREATE OR REPLACE FUNCTION public.end_turn(p_token BIGINT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, pg_temp
AS $$
DECLARE
  v_token public.tokens%ROWTYPE;
  v_combat public.combat_state%ROWTYPE;
  v_role TEXT;
  v_owner UUID;
  v_count INTEGER;
  v_next_index INTEGER;
  v_next_round INTEGER;
  v_next_token BIGINT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  SELECT * INTO v_token
  FROM public.tokens t
  WHERE t.id = p_token;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Token inexistente.';
  END IF;
  SELECT c.user_id INTO v_owner
  FROM public.characters c
  WHERE c.id = v_token.character_id;

  v_role := public.my_role(v_token.campaign_id);
  IF v_role IS NULL OR v_role NOT IN ('GM', 'PLAYER') THEN
    RAISE EXCEPTION 'Sem permissão.';
  END IF;
  IF v_role = 'PLAYER' AND v_owner IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'Você só encerra o seu próprio turno.';
  END IF;

  SELECT * INTO v_combat
  FROM public.combat_state
  WHERE campaign_id = v_token.campaign_id
  FOR UPDATE;
  IF NOT FOUND OR v_combat.ativo IS NOT TRUE THEN
    RAISE EXCEPTION 'Combate não está ativo.';
  END IF;
  IF (v_combat.ordem->>v_combat.turno_index)::BIGINT IS DISTINCT FROM p_token THEN
    RAISE EXCEPTION 'Não é o turno deste token.';
  END IF;

  v_count := JSONB_ARRAY_LENGTH(v_combat.ordem);
  IF v_count = 0 THEN
    RAISE EXCEPTION 'A ordem de combate está vazia.';
  END IF;
  v_next_index := v_combat.turno_index + 1;
  v_next_round := v_combat.rodada;
  IF v_next_index >= v_count THEN
    v_next_index := 0;
    v_next_round := v_next_round + 1;
  END IF;
  v_next_token := (v_combat.ordem->>v_next_index)::BIGINT;

  UPDATE public.combat_state
  SET turno_index = v_next_index, rodada = v_next_round
  WHERE campaign_id = v_token.campaign_id;
  PERFORM priv.log(
    v_token.campaign_id,
    'TURNO_AVANCOU',
    JSONB_BUILD_OBJECT('de', p_token, 'para', v_next_token, 'rodada', v_next_round)
  );
  RETURN JSONB_BUILD_OBJECT('ok', TRUE, 'proximo', v_next_token, 'rodada', v_next_round);
END
$$;

REVOKE EXECUTE ON FUNCTION public.apply_condition(BIGINT, TEXT, TEXT, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.apply_condition(BIGINT, TEXT, TEXT, TEXT) TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.end_turn(BIGINT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.end_turn(BIGINT) TO authenticated, service_role;

COMMIT;

