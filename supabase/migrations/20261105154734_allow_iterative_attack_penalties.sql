-- Permite que o servidor valide ataques iterativos e penalidades legítimas
-- sem exigir que todo ataque de uma sequência use o BBA do primeiro golpe.
-- A validação continua conservadora: o cliente nunca pode informar bônus maior
-- que o bônus-base recalculado pelo servidor; a margem inferior só permite
-- penalidades adicionais (iterativos, Tiro Rápido e combate com duas armas).

DO $$
DECLARE
  v_def text;
  v_old text := 'IF p_bonus_ataque<>v_expected_bonus THEN RAISE EXCEPTION ''Bônus de ataque não confere com a ficha. Esperado: %, recebido: %.'',v_expected_bonus,p_bonus_ataque; END IF;';
  v_new text := 'IF p_bonus_ataque>v_expected_bonus OR p_bonus_ataque<v_expected_bonus-30 THEN RAISE EXCEPTION ''Bônus de ataque excede o bônus calculado da ficha ou aplica penalidade inválida. Máximo: %, recebido: %.'',v_expected_bonus,p_bonus_ataque; END IF;';
BEGIN
  SELECT pg_get_functiondef(
    'public.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer,integer,integer)'::regprocedure
  ) INTO v_def;

  IF position(v_new IN v_def) > 0 THEN
    RETURN;
  END IF;

  IF position(v_old IN v_def) = 0 THEN
    RAISE EXCEPTION 'Trecho de validação original não encontrado; migration interrompida.';
  END IF;

  v_def := replace(v_def, v_old, v_new);
  EXECUTE v_def;
END
$$;