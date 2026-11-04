DO $migration$
DECLARE
  v_definition TEXT;
  v_old_turn TEXT := $old_turn$IF v_actor->>'id' IS DISTINCT FROM BTRIM(p_token_id)
     OR COALESCE(v_actor->>'is_monster', 'false') <> 'true' THEN
    RAISE EXCEPTION 'O token não está no turno ativo do Mestre.';
  END IF;$old_turn$;
  v_new_turn TEXT := $new_turn$IF v_actor->>'id' IS DISTINCT FROM BTRIM(p_token_id) THEN
    RAISE EXCEPTION 'O token não está no turno ativo.';
  END IF;$new_turn$;
BEGIN
  SELECT pg_get_functiondef('public.mover_token_gm_cba_srd(bigint,text,integer,integer)'::regprocedure)
  INTO v_definition;

  IF position(v_old_turn IN v_definition) = 0 THEN
    RAISE EXCEPTION 'Guarda de turno esperada não encontrada.';
  END IF;
  v_definition := replace(v_definition, v_old_turn, v_new_turn);

  IF strpos(v_definition, E'      AND character.campaign_id = p_campaign_id\n      AND character.user_id = v_user\n  )') = 0 THEN
    RAISE EXCEPTION 'Guarda de propriedade da ficha não encontrada.';
  END IF;
  v_definition := replace(v_definition,
    E'      AND character.campaign_id = p_campaign_id\n      AND character.user_id = v_user\n  )',
    E'      AND character.campaign_id = p_campaign_id\n  )');

  IF strpos(v_definition, E'      AND character.campaign_id = p_campaign_id\n      AND character.user_id = v_user;') = 0 THEN
    RAISE EXCEPTION 'Filtro de propriedade na leitura de deslocamento não encontrado.';
  END IF;
  v_definition := replace(v_definition,
    E'      AND character.campaign_id = p_campaign_id\n      AND character.user_id = v_user;',
    E'      AND character.campaign_id = p_campaign_id;');

  EXECUTE v_definition;
END
$migration$;