-- Correction/extension migration for initiative and GM token turns.
-- Apply after srd35_initiative_3d_roll.sql.
-- Repairs the initiative registration aliases, then validates GM token movement.
BEGIN;

CREATE OR REPLACE FUNCTION public.iniciar_iniciativa_com_dados(
  p_campaign_id BIGINT,
  p_expected_character_ids TEXT[],
  p_request_id TEXT,
  p_gm_d20_results JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_role TEXT;
  v_state TEXT;
  v_expected TEXT[];
  v_scene JSONB;
  v_previous JSONB;
  v_order JSONB;
  v_gm_count INTEGER;
  v_master TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  SELECT member.role INTO v_role
  FROM public.members AS member
  WHERE member.campaign_id = p_campaign_id AND member.user_id = auth.uid()
  LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode iniciar a iniciativa.';
  END IF;

  SELECT COALESCE(
    array_agg(DISTINCT BTRIM(requested.character_id) ORDER BY BTRIM(requested.character_id)),
    ARRAY[]::TEXT[]
  )
  INTO v_expected
  FROM unnest(COALESCE(p_expected_character_ids, ARRAY[]::TEXT[])) AS requested(character_id)
  WHERE NULLIF(BTRIM(requested.character_id), '') IS NOT NULL;

  IF EXISTS (
    SELECT 1
    FROM unnest(v_expected) AS requested(character_id)
    WHERE NOT EXISTS (
      SELECT 1
      FROM public.characters AS ch
      JOIN public.members AS player
        ON player.campaign_id = ch.campaign_id
       AND player.user_id = ch.user_id
       AND player.role = 'PLAYER'
      WHERE ch.campaign_id = p_campaign_id
        AND ch.id::TEXT = requested.character_id
    )
  ) THEN
    RAISE EXCEPTION 'A lista inclui ficha que não pertence a um jogador desta campanha.';
  END IF;

  IF cardinality(v_expected) > 0 AND NULLIF(BTRIM(p_request_id), '') IS NULL THEN
    RAISE EXCEPTION 'O identificador do pedido de iniciativa é obrigatório.';
  END IF;

  SELECT campaign.state, campaign.cba_data, campaign.combat_data
  INTO v_state, v_scene, v_previous
  FROM public.campaigns AS campaign
  WHERE campaign.id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  IF UPPER(COALESCE(v_state, '')) <> 'COMBATE' THEN
    RAISE EXCEPTION 'A iniciativa só pode ser iniciada no modo COMBATE.';
  END IF;
  IF COALESCE((v_previous->>'active')::BOOLEAN, FALSE)
     OR jsonb_array_length(
       CASE WHEN jsonb_typeof(v_previous->'expected_character_ids') = 'array'
            THEN v_previous->'expected_character_ids' ELSE '[]'::JSONB END
     ) > 0 THEN
    RAISE EXCEPTION 'A iniciativa desta rodada já foi iniciada.';
  END IF;

  IF jsonb_typeof(p_gm_d20_results) IS DISTINCT FROM 'array' THEN
    RAISE EXCEPTION 'Os resultados dos dados do Mestre são inválidos.';
  END IF;
  IF EXISTS (
    SELECT 1
    FROM jsonb_array_elements(p_gm_d20_results) AS roll(value)
    WHERE jsonb_typeof(roll.value) IS DISTINCT FROM 'number'
       OR roll.value::TEXT !~ '^(1[0-9]|20|[1-9])$'
  ) THEN
    RAISE EXCEPTION 'Cada resultado de iniciativa precisa ser um inteiro entre 1 e 20.';
  END IF;

  SELECT count(*)::INTEGER
  INTO v_gm_count
  FROM jsonb_array_elements(
    CASE WHEN jsonb_typeof(v_scene->'tokens') = 'array'
         THEN v_scene->'tokens' ELSE '[]'::JSONB END
  ) AS candidate(token)
  LEFT JOIN public.characters AS character
    ON character.campaign_id = p_campaign_id
   AND character.id::TEXT = candidate.token->>'id'
  WHERE candidate.token->>'tipo' IN ('npc', 'monstro')
     OR (candidate.token->>'tipo' = 'player' AND character.user_id = auth.uid());

  IF jsonb_array_length(p_gm_d20_results) <> v_gm_count THEN
    RAISE EXCEPTION 'O Mestre precisa rolar exatamente % d20 para os tokens que controla; recebeu %.',
      v_gm_count, jsonb_array_length(p_gm_d20_results);
  END IF;
  IF cardinality(v_expected) = 0 AND v_gm_count = 0 THEN
    RAISE EXCEPTION 'Adicione participantes ao combate antes de iniciar a iniciativa.';
  END IF;

  WITH gm_tokens AS (
    SELECT candidate.token,
           character.id AS linked_character_id,
           sheet.atributos AS linked_attributes,
           sheet.talentos AS linked_feats
    FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(v_scene->'tokens') = 'array'
           THEN v_scene->'tokens' ELSE '[]'::JSONB END
    ) AS candidate(token)
    LEFT JOIN public.characters AS character
      ON character.campaign_id = p_campaign_id
     AND character.id::TEXT = candidate.token->>'id'
    LEFT JOIN public.srd_character_sheets AS sheet
      ON sheet.character_id::TEXT = character.id::TEXT
    WHERE candidate.token->>'tipo' IN ('npc', 'monstro')
       OR (candidate.token->>'tipo' = 'player' AND character.user_id = auth.uid())
  ),
  numbered_tokens AS (
    SELECT gm_tokens.*,
           row_number() OVER (ORDER BY random()) AS assignment_number
    FROM gm_tokens
  ),
  numbered_rolls AS (
    SELECT roll.value::INTEGER AS d20,
           row_number() OVER (ORDER BY roll.ordinality) AS assignment_number
    FROM jsonb_array_elements(p_gm_d20_results) WITH ORDINALITY AS roll(value, ordinality)
  ),
  calculated AS (
    SELECT
      COALESCE(NULLIF(BTRIM(token.token->>'id'), ''), 'combatant-' || token.assignment_number::TEXT) AS id,
      LEFT(COALESCE(NULLIF(BTRIM(token.token->>'nome'), ''), 'Criatura'), 120) AS nome,
      CASE WHEN token.token->>'tipo' = 'monstro' THEN 'monstro'
           WHEN token.token->>'tipo' = 'player' THEN 'personagem_gm' ELSE 'npc' END AS tipo,
      roll.d20,
      COALESCE(
        CASE WHEN token.token->>'dexMod' ~ '^-?[0-9]{1,2}$'
             THEN (token.token->>'dexMod')::INTEGER END,
        CASE WHEN token.linked_attributes->>'DES' ~ '^[0-9]{1,2}$'
             THEN FLOOR(((token.linked_attributes->>'DES')::NUMERIC - 10) / 2)::INTEGER END,
        0
      ) AS dex_mod,
      COALESCE(
        CASE WHEN token.token->>'bonusIniciativa' ~ '^-?[0-9]{1,2}$'
             THEN (token.token->>'bonusIniciativa')::INTEGER END,
        CASE WHEN token.token->>'bonus_iniciativa' ~ '^-?[0-9]{1,2}$'
             THEN (token.token->>'bonus_iniciativa')::INTEGER END,
        CASE WHEN token.linked_feats::TEXT LIKE '%iniciativa_aprimorada%' THEN 4 END,
        0
      ) AS initiative_bonus
    FROM numbered_tokens AS token
    JOIN numbered_rolls AS roll USING (assignment_number)
  )
  SELECT COALESCE(jsonb_agg(
    jsonb_build_object(
      'id', calculated.id,
      'nome', calculated.nome,
      'valor', calculated.d20 + calculated.dex_mod + calculated.initiative_bonus,
      'd20', calculated.d20,
      'dex_mod', calculated.dex_mod,
      'bonus_iniciativa', calculated.initiative_bonus,
      'is_monster', TRUE,
      'tipo', calculated.tipo
    )
    ORDER BY calculated.d20 + calculated.dex_mod + calculated.initiative_bonus DESC,
             calculated.nome ASC, calculated.id ASC
  ), '[]'::JSONB)
  INTO v_order
  FROM calculated;

  UPDATE public.campaigns
  SET combat_data = jsonb_build_object(
    'turn_order', v_order,
    'current_turn', 0,
    'active', cardinality(v_expected) = 0,
    'round', 1,
    'expected_character_ids', to_jsonb(v_expected)
  )
  WHERE id = p_campaign_id;

  IF cardinality(v_expected) > 0 THEN
    SELECT COALESCE(NULLIF(BTRIM(profile.username), ''), 'Mestre')
    INTO v_master
    FROM public.profiles AS profile
    WHERE profile.id = auth.uid();
    v_master := COALESCE(v_master, 'Mestre');

    INSERT INTO public.campaign_log (campaign_id, type, visibilidade, data)
    VALUES (
      p_campaign_id, 'test_request', 'PUBLIC',
      jsonb_build_object(
        'tipo', 'Iniciativa (DES)',
        'alvos', to_jsonb(v_expected),
        'mestre', v_master,
        'mestre_id', auth.uid(),
        'request_id', BTRIM(p_request_id)
      )
    );
  END IF;

  RETURN (SELECT combat_data FROM public.campaigns WHERE id = p_campaign_id);
END;
$$;

REVOKE ALL ON FUNCTION public.iniciar_iniciativa_com_dados(BIGINT, TEXT[], TEXT, JSONB) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.iniciar_iniciativa_com_dados(BIGINT, TEXT[], TEXT, JSONB) TO authenticated;

-- The final player roll activates the already-complete initiative order.
CREATE OR REPLACE FUNCTION public.registrar_iniciativa(
  p_campaign_id BIGINT,
  p_personagem_id TEXT,
  p_nome TEXT,
  p_valor INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_role TEXT;
  v_state TEXT;
  v_data JSONB;
  v_order JSONB;
  v_expected JSONB;
  v_entry JSONB;
  v_sorted JSONB;
  v_next JSONB;
  v_current_id TEXT;
  v_current_turn INTEGER := 0;
  v_round INTEGER := 1;
  v_active BOOLEAN := FALSE;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;

  SELECT member.role INTO v_role
  FROM public.members AS member
  WHERE member.campaign_id = p_campaign_id AND member.user_id = auth.uid()
  LIMIT 1;
  IF v_role IS DISTINCT FROM 'PLAYER' THEN
    RAISE EXCEPTION 'Somente um jogador pode registrar a iniciativa de sua ficha.';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.characters AS character
    WHERE character.campaign_id = p_campaign_id
      AND character.id::TEXT = p_personagem_id
      AND character.user_id = auth.uid()
  ) THEN RAISE EXCEPTION 'A ficha de iniciativa não pertence ao jogador autenticado.'; END IF;

  SELECT campaign.state, campaign.combat_data INTO v_state, v_data
  FROM public.campaigns AS campaign
  WHERE campaign.id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  IF UPPER(COALESCE(v_state,'')) <> 'COMBATE' THEN
    RAISE EXCEPTION 'A iniciativa só pode ser registrada durante o combate.';
  END IF;
  IF v_data IS NULL THEN RAISE EXCEPTION 'O Mestre ainda não solicitou a iniciativa.'; END IF;

  v_expected := CASE WHEN jsonb_typeof(v_data->'expected_character_ids')='array'
                     THEN v_data->'expected_character_ids' ELSE '[]'::JSONB END;
  IF NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements_text(v_expected) AS expected(character_id)
    WHERE expected.character_id = p_personagem_id
  ) THEN RAISE EXCEPTION 'Esta ficha não faz parte da solicitação de iniciativa atual.'; END IF;

  v_order := CASE WHEN jsonb_typeof(v_data->'turn_order')='array' THEN v_data->'turn_order' ELSE '[]'::JSONB END;
  v_round := CASE WHEN COALESCE(v_data->>'round','') ~ '^[0-9]+$' THEN GREATEST(1,(v_data->>'round')::INTEGER) ELSE 1 END;
  IF COALESCE((v_data->>'active')::BOOLEAN,FALSE) THEN
    SELECT old_order.entry->>'id' INTO v_current_id
    FROM jsonb_array_elements(v_order) WITH ORDINALITY AS old_order(entry, ordinality)
    WHERE old_order.ordinality = GREATEST(0,COALESCE((v_data->>'current_turn')::INTEGER,0))+1
    LIMIT 1;
  END IF;

  v_entry := jsonb_build_object('id',p_personagem_id,'nome',LEFT(COALESCE(NULLIF(p_nome,''),'Aventureiro'),120),
    'valor',p_valor,'is_monster',FALSE);
  SELECT COALESCE(jsonb_agg(q.entry ORDER BY COALESCE(NULLIF(q.entry->>'valor','')::NUMERIC,0) DESC,
                            q.entry->>'nome' ASC, q.entry->>'id' ASC),'[]'::JSONB)
  INTO v_sorted
  FROM (
    SELECT old.entry FROM jsonb_array_elements(v_order) AS old(entry)
    WHERE old.entry->>'id' <> p_personagem_id
    UNION ALL SELECT v_entry
  ) AS q;

  SELECT NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements_text(v_expected) AS expected(character_id)
    WHERE NOT EXISTS (
      SELECT 1 FROM jsonb_array_elements(v_sorted) AS current_entry(entry)
      WHERE current_entry.entry->>'id'=expected.character_id
    )
  ) INTO v_active;
  IF v_active AND v_current_id IS NOT NULL THEN
    SELECT sorted.ordinality-1 INTO v_current_turn
    FROM jsonb_array_elements(v_sorted) WITH ORDINALITY AS sorted(entry, ordinality)
    WHERE sorted.entry->>'id'=v_current_id LIMIT 1;
    v_current_turn := COALESCE(v_current_turn,0);
  ELSE v_current_turn := 0; END IF;

  v_next := v_data || jsonb_build_object('turn_order',v_sorted,'current_turn',v_current_turn,
    'active',v_active,'round',v_round,'expected_character_ids',v_expected);
  UPDATE public.campaigns SET combat_data=v_next WHERE id=p_campaign_id;
  RETURN v_next;
END;
$$;

REVOKE ALL ON FUNCTION public.registrar_iniciativa(BIGINT, TEXT, TEXT, INTEGER) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.registrar_iniciativa(BIGINT, TEXT, TEXT, INTEGER) TO authenticated;

-- Prevent older clients from silently bypassing the 3D die and rolling on the server.
REVOKE ALL ON FUNCTION public.iniciar_iniciativa(BIGINT, TEXT[]) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.iniciar_iniciativa_com_pedido(BIGINT, TEXT[], TEXT) FROM PUBLIC, anon, authenticated;

-- Movement by the GM follows the same per-turn movement allowance as a player.
CREATE OR REPLACE FUNCTION public.mover_token_gm_cba_srd(
  p_campaign_id BIGINT,
  p_token_id TEXT,
  p_grid_x INTEGER,
  p_grid_y INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_campaign public.campaigns%ROWTYPE;
  v_combat JSONB;
  v_scene JSONB;
  v_tokens JSONB;
  v_order JSONB;
  v_actor JSONB;
  v_token JSONB;
  v_token_count INTEGER;
  v_token_index BIGINT;
  v_token_type TEXT;
  v_speed_text TEXT;
  v_speed_number TEXT;
  v_speed_m NUMERIC;
  v_old_x INTEGER;
  v_old_y INTEGER;
  v_move_squares INTEGER;
  v_movement_used NUMERIC;
  v_remaining_m NUMERIC;
  v_round INTEGER;
  v_current_turn INTEGER;
  v_economy JSONB;
  v_by_token JSONB;
  v_token_actions JSONB;
  v_movement_usage JSONB;
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  IF p_grid_x IS NULL OR p_grid_y IS NULL OR p_grid_x < 0 OR p_grid_y < 0
     OR p_grid_x > 199 OR p_grid_y > 199 THEN
    RAISE EXCEPTION 'A posição deve estar na grade, com coordenadas inteiras entre 0 e 199.';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.members
    WHERE campaign_id = p_campaign_id AND user_id = v_user AND role = 'GM'
  ) THEN RAISE EXCEPTION 'Somente o Mestre pode mover tokens sob seu controle.'; END IF;

  SELECT campaign.* INTO v_campaign
  FROM public.campaigns AS campaign
  WHERE campaign.id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND OR UPPER(COALESCE(v_campaign.state, '')) <> 'COMBATE' THEN
    RAISE EXCEPTION 'A campanha não está em combate.';
  END IF;
  v_combat := COALESCE(v_campaign.combat_data, '{}'::JSONB);
  IF COALESCE(v_combat->>'active', 'false') <> 'true' THEN
    RAISE EXCEPTION 'Não há turno de combate ativo.';
  END IF;
  v_order := CASE WHEN jsonb_typeof(v_combat->'turn_order') = 'array'
                  THEN v_combat->'turn_order' ELSE '[]'::JSONB END;
  IF COALESCE(v_combat->>'current_turn', '') !~ '^[0-9]+$' THEN
    RAISE EXCEPTION 'O turno atual da iniciativa é inválido.';
  END IF;
  v_current_turn := (v_combat->>'current_turn')::INTEGER;
  v_actor := v_order->v_current_turn;
  IF v_actor->>'id' IS DISTINCT FROM BTRIM(p_token_id)
     OR COALESCE(v_actor->>'is_monster', 'false') <> 'true' THEN
    RAISE EXCEPTION 'O token não está no turno ativo do Mestre.';
  END IF;

  v_scene := COALESCE(v_campaign.cba_data, '{}'::JSONB);
  v_tokens := CASE WHEN jsonb_typeof(v_scene->'tokens') = 'array'
                   THEN v_scene->'tokens' ELSE '[]'::JSONB END;
  SELECT COUNT(*)::INTEGER, MIN(token.ordinality)
  INTO v_token_count, v_token_index
  FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS token(value, ordinality)
  WHERE token.value->>'id' = BTRIM(p_token_id);
  IF v_token_count <> 1 THEN RAISE EXCEPTION 'O token não existe na cena ou está duplicado.'; END IF;
  v_token := v_tokens->(v_token_index::INTEGER - 1);
  v_token_type := v_token->>'tipo';
  IF v_token_type NOT IN ('npc', 'monstro', 'player') THEN
    RAISE EXCEPTION 'Este tipo de token não pode ser movido pelo Mestre nesta ação.';
  END IF;
  IF v_token_type = 'player' AND NOT EXISTS (
    SELECT 1 FROM public.characters AS character
    WHERE character.id::TEXT = BTRIM(p_token_id)
      AND character.campaign_id = p_campaign_id
      AND character.user_id = v_user
  ) THEN RAISE EXCEPTION 'O token de personagem não pertence ao Mestre.'; END IF;
  IF COALESCE(v_token->>'gridX', '') !~ '^[0-9]{1,3}$'
     OR COALESCE(v_token->>'gridY', '') !~ '^[0-9]{1,3}$' THEN
    RAISE EXCEPTION 'A posição atual do token é inválida.';
  END IF;
  v_old_x := (v_token->>'gridX')::INTEGER;
  v_old_y := (v_token->>'gridY')::INTEGER;
  IF EXISTS (
    SELECT 1 FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS other(value, ordinality)
    WHERE other.ordinality <> v_token_index
      AND CASE WHEN COALESCE(other.value->>'gridX', '') ~ '^[0-9]{1,3}$'
               THEN (other.value->>'gridX')::INTEGER ELSE -1 END = p_grid_x
      AND CASE WHEN COALESCE(other.value->>'gridY', '') ~ '^[0-9]{1,3}$'
               THEN (other.value->>'gridY')::INTEGER ELSE -1 END = p_grid_y
  ) THEN RAISE EXCEPTION 'A célula de destino já está ocupada.'; END IF;

  v_speed_text := COALESCE(
    NULLIF(v_token->>'deslocamento_m', ''),
    NULLIF(v_token->'monsterStats'->>'deslocamento', ''),
    NULLIF(v_token->'monsterStats'->>'speed', ''),
    NULLIF(v_token->>'speed_m', '')
  );
  IF v_token_type = 'player' THEN
    SELECT race.deslocamento::TEXT INTO v_speed_text
    FROM public.characters AS character
    JOIN public.srd_character_sheets AS sheet ON sheet.character_id::TEXT = character.id::TEXT
    JOIN public.srd_races AS race ON race.id::TEXT = sheet.raca_id::TEXT
    WHERE character.id::TEXT = BTRIM(p_token_id)
      AND character.campaign_id = p_campaign_id
      AND character.user_id = v_user;
  END IF;
  IF v_speed_text IS NULL OR BTRIM(v_speed_text) = '' THEN
    v_speed_m := 9;
  ELSE
    v_speed_number := substring(v_speed_text FROM '([0-9]+([.][0-9]+)?)');
    IF v_speed_number IS NULL THEN RAISE EXCEPTION 'Não foi possível ler o deslocamento de %.', v_token->>'nome'; END IF;
    v_speed_m := v_speed_number::NUMERIC;
    IF LOWER(v_speed_text) ~ '(ft|feet|foot|p[eé]s|pé)' THEN v_speed_m := v_speed_m * 0.3048; END IF;
  END IF;

  v_move_squares := GREATEST(ABS(p_grid_x - v_old_x), ABS(p_grid_y - v_old_y));
  v_movement_used := v_move_squares * 1.5;
  IF v_movement_used > v_speed_m THEN
    RAISE EXCEPTION 'Movimento de % excede o deslocamento de %.1f m.', v_token->>'nome', v_speed_m;
  END IF;
  v_round := CASE WHEN COALESCE(v_combat->>'round', '') ~ '^[0-9]+$'
                  THEN GREATEST(1, (v_combat->>'round')::INTEGER) ELSE 1 END;
  v_economy := v_combat->'action_economy';
  IF jsonb_typeof(v_economy) = 'object'
     AND COALESCE(v_economy->>'round', '') = v_round::TEXT
     AND jsonb_typeof(v_economy->'by_character') = 'object' THEN
    v_by_token := v_economy->'by_character';
  ELSE v_by_token := '{}'::JSONB; END IF;
  v_token_actions := CASE WHEN jsonb_typeof(v_by_token->BTRIM(p_token_id)) = 'object'
                          THEN v_by_token->BTRIM(p_token_id) ELSE '{}'::JSONB END;
  IF COALESCE(v_token_actions->>'movimento', 'false') = 'true' THEN
    RAISE EXCEPTION 'A ação de movimento deste token já foi usada no turno.';
  END IF;
  v_token_actions := v_token_actions || jsonb_build_object('movimento', TRUE);
  v_by_token := jsonb_set(v_by_token, ARRAY[BTRIM(p_token_id)], v_token_actions, TRUE);
  v_combat := v_combat || jsonb_build_object(
    'action_economy', jsonb_build_object('round', v_round, 'by_character', v_by_token),
    'movement_usage', jsonb_build_object('round',v_round,'current_turn',v_current_turn,
      'character_id',BTRIM(p_token_id),'moved_squares',v_move_squares)
  );
  v_token := v_token || jsonb_build_object('gridX', p_grid_x, 'gridY', p_grid_y);
  v_scene := v_scene || jsonb_build_object('tokens', jsonb_set(v_tokens, ARRAY[(v_token_index - 1)::TEXT], v_token, FALSE));
  UPDATE public.campaigns SET cba_data = v_scene, combat_data = v_combat WHERE id = p_campaign_id;
  RETURN jsonb_build_object('cba_data',v_scene,'combat_data',v_combat,
    'movement_remaining_m',GREATEST(0::NUMERIC,v_speed_m-v_movement_used));
END
$$;

REVOKE ALL ON FUNCTION public.mover_token_gm_cba_srd(BIGINT, TEXT, INTEGER, INTEGER) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.mover_token_gm_cba_srd(BIGINT, TEXT, INTEGER, INTEGER) TO authenticated;
COMMIT;


