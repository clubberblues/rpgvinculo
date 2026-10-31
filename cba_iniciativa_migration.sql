-- Vínculo: estado compartilhado do CBA e iniciativa com turnos.
-- Execute no SQL Editor do Supabase usando uma role administrativa.
-- A migração é aditiva; não remove nem altera dados existentes.

ALTER TABLE public.campaigns
  ADD COLUMN IF NOT EXISTS cba_data JSONB DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS combat_data JSONB DEFAULT NULL;

-- Necessário para que campanhas.cba_data e campaigns.combat_data cheguem via Realtime.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime')
     AND NOT EXISTS (
       SELECT 1 FROM pg_publication_tables
       WHERE pubname = 'supabase_realtime'
         AND schemaname = 'public'
         AND tablename = 'campaigns'
     ) THEN
    EXECUTE 'ALTER PUBLICATION supabase_realtime ADD TABLE public.campaigns';
  END IF;
END
$$;

-- Alterna a mesa entre exploração e combate sob lock, limpando a iniciativa
-- anterior na mesma transação para evitar estados parcialmente atualizados.
CREATE OR REPLACE FUNCTION public.alternar_estado_campanha(
  p_campaign_id BIGINT,
  p_novo_estado TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_role TEXT;
  v_estado_atual TEXT;
  v_novo_estado TEXT;
  v_combat JSONB := jsonb_build_object(
    'turn_order', '[]'::JSONB,
    'current_turn', 0,
    'active', FALSE,
    'round', 1,
    'expected_character_ids', '[]'::JSONB
  );
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  SELECT m.role INTO v_role
  FROM public.members AS m
  WHERE m.campaign_id = p_campaign_id AND m.user_id = auth.uid()
  LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre da campanha pode alternar o estado.';
  END IF;
  v_novo_estado := UPPER(BTRIM(COALESCE(p_novo_estado, '')));
  IF v_novo_estado NOT IN ('EXPLORACAO', 'COMBATE') THEN
    RAISE EXCEPTION 'Estado inválido; use EXPLORACAO ou COMBATE.';
  END IF;
  SELECT UPPER(COALESCE(NULLIF(BTRIM(state), ''), 'EXPLORACAO'))
  INTO v_estado_atual
  FROM public.campaigns
  WHERE id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  IF v_estado_atual = v_novo_estado THEN
    RAISE EXCEPTION 'A mesa já está em %.', v_novo_estado;
  END IF;
  UPDATE public.campaigns
  SET state = v_novo_estado, combat_data = v_combat
  WHERE id = p_campaign_id;
  RETURN jsonb_build_object('state', v_novo_estado, 'combat_data', v_combat);
END;
$$;

-- O Mestre inicia uma ordem nova: NPCs/monstros no CBA recebem 1d20+0
-- automaticamente; fichas de jogadores informadas ficam pendentes de rolagem.
CREATE OR REPLACE FUNCTION public.iniciar_iniciativa(
  p_campaign_id BIGINT,
  p_expected_character_ids TEXT[]
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_role TEXT;
  v_state TEXT;
  v_expected TEXT[];
  v_cba JSONB;
  v_combat JSONB;
  v_previous JSONB;
  v_existing_gm_entries JSONB;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  SELECT m.role INTO v_role
  FROM public.members AS m
  WHERE m.campaign_id = p_campaign_id AND m.user_id = auth.uid()
  LIMIT 1;

  IF v_role IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre da campanha pode iniciar a iniciativa.';
  END IF;

  SELECT COALESCE(array_agg(DISTINCT expanded.character_id), ARRAY[]::TEXT[])
  INTO v_expected
  FROM unnest(COALESCE(p_expected_character_ids, ARRAY[]::TEXT[])) AS expanded(character_id);

  IF EXISTS (
    SELECT 1
    FROM unnest(v_expected) AS requested(character_id)
    WHERE NOT EXISTS (
      SELECT 1
      FROM public.characters AS c
      JOIN public.members AS m
        ON m.campaign_id = c.campaign_id
       AND m.user_id = c.user_id
       AND m.role = 'PLAYER'
      WHERE c.campaign_id = p_campaign_id
        AND c.id::TEXT = requested.character_id
    )
  ) THEN
    RAISE EXCEPTION 'A lista inclui personagem que não pertence a um jogador desta campanha.';
  END IF;

  SELECT state, cba_data, combat_data INTO v_state, v_cba, v_previous
  FROM public.campaigns
  WHERE id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  IF UPPER(COALESCE(v_state, '')) <> 'COMBATE' THEN
    RAISE EXCEPTION 'A iniciativa só pode ser iniciada quando a campanha está em COMBATE.';
  END IF;
  IF COALESCE((v_previous->>'active')::BOOLEAN, FALSE)
     OR jsonb_array_length(CASE WHEN jsonb_typeof(v_previous->'expected_character_ids') = 'array'
                                THEN v_previous->'expected_character_ids' ELSE '[]'::JSONB END) > 0 THEN
    RAISE EXCEPTION 'A iniciativa desta rodada já foi iniciada. Encerre e inicie o combate novamente para zerá-la.';
  END IF;

  SELECT COALESCE(jsonb_agg(
    jsonb_build_object('id', rolled.id, 'nome', rolled.nome, 'valor', rolled.valor,
                       'is_monster', TRUE, 'tipo', rolled.tipo)
    ORDER BY rolled.valor DESC, rolled.nome ASC, rolled.id ASC
  ), '[]'::JSONB)
  INTO v_existing_gm_entries
  FROM (
    SELECT token.entry->>'id' AS id,
           LEFT(COALESCE(NULLIF(token.entry->>'nome', ''), 'Criatura'), 120) AS nome,
           CASE WHEN token.entry->>'tipo' = 'monstro' THEN 'monstro' ELSE 'npc' END AS tipo,
           FLOOR(random() * 20)::INTEGER + 1 AS valor
    FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(v_cba->'tokens') = 'array'
           THEN v_cba->'tokens' ELSE '[]'::JSONB END
    ) AS token(entry)
    WHERE token.entry->>'tipo' IN ('npc', 'monstro')
      AND NULLIF(BTRIM(token.entry->>'id'), '') IS NOT NULL
  ) AS rolled;

  IF cardinality(v_expected) = 0 AND jsonb_array_length(v_existing_gm_entries) = 0 THEN
    RAISE EXCEPTION 'Adicione fichas de jogadores ou NPCs/monstros ao CBA antes de iniciar a iniciativa.';
  END IF;

  v_combat := jsonb_build_object(
    'turn_order', v_existing_gm_entries,
    'current_turn', 0,
    'active', cardinality(v_expected) = 0,
    'round', 1,
    'expected_character_ids', to_jsonb(v_expected)
  );

  UPDATE public.campaigns SET combat_data = v_combat WHERE id = p_campaign_id;
  RETURN v_combat;
END;
$$;

-- Registra ou atualiza a iniciativa de um personagem. O bloqueio FOR UPDATE
-- evita que rolagens simultâneas sobrescrevam a fila umas das outras.
CREATE OR REPLACE FUNCTION public.registrar_iniciativa(
  p_campaign_id BIGINT,
  p_personagem_id TEXT,
  p_nome TEXT,
  p_valor INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_role TEXT;
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
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  SELECT m.role INTO v_role
  FROM public.members AS m
  WHERE m.campaign_id = p_campaign_id AND m.user_id = auth.uid()
  LIMIT 1;

  IF v_role IS DISTINCT FROM 'PLAYER' THEN
    RAISE EXCEPTION 'Somente um jogador pode registrar a iniciativa de sua ficha.';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.characters AS c
    WHERE c.campaign_id = p_campaign_id
      AND c.id::TEXT = p_personagem_id
      AND c.user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'A ficha de iniciativa não pertence ao jogador autenticado.';
  END IF;

  SELECT combat_data INTO v_data
  FROM public.campaigns
  WHERE id = p_campaign_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  IF v_data IS NULL THEN
    RAISE EXCEPTION 'O Mestre ainda não solicitou a iniciativa.';
  END IF;

  v_expected := COALESCE(v_data->'expected_character_ids', '[]'::JSONB);
  IF NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements_text(v_expected) AS expected(character_id)
    WHERE expected.character_id = p_personagem_id
  ) THEN
    RAISE EXCEPTION 'Esta ficha não faz parte da solicitação de iniciativa atual.';
  END IF;

  v_order := CASE WHEN jsonb_typeof(v_data->'turn_order') = 'array'
                  THEN v_data->'turn_order' ELSE '[]'::JSONB END;
  v_round := GREATEST(1, COALESCE((v_data->>'round')::INTEGER, 1));

  IF COALESCE((v_data->>'active')::BOOLEAN, FALSE) THEN
    SELECT entry->>'id' INTO v_current_id
    FROM jsonb_array_elements(v_order) WITH ORDINALITY AS old_order(entry, ordinality)
    WHERE old_order.ordinality = COALESCE((v_data->>'current_turn')::INTEGER, 0) + 1
    LIMIT 1;
  END IF;

  v_entry := jsonb_build_object(
    'id', p_personagem_id,
    'nome', LEFT(COALESCE(NULLIF(p_nome, ''), 'Aventureiro'), 120),
    'valor', p_valor,
    'is_monster', FALSE
  );

  SELECT COALESCE(
    jsonb_agg(q.entry ORDER BY COALESCE(NULLIF(q.entry->>'valor', '')::NUMERIC, 0) DESC, q.entry->>'nome' ASC),
    '[]'::JSONB
  ) INTO v_sorted
  FROM (
    SELECT old.entry
    FROM jsonb_array_elements(v_order) AS old(entry)
    WHERE old.entry->>'id' <> p_personagem_id
    UNION ALL
    SELECT v_entry
  ) AS q;

  SELECT NOT EXISTS (
    SELECT 1
    FROM jsonb_array_elements_text(v_expected) AS expected(character_id)
    WHERE NOT EXISTS (
      SELECT 1 FROM jsonb_array_elements(v_sorted) AS current_entry(entry)
      WHERE current_entry.entry->>'id' = expected.character_id
    )
  ) INTO v_active;

  IF v_active AND v_current_id IS NOT NULL THEN
    SELECT ordinality - 1 INTO v_current_turn
    FROM jsonb_array_elements(v_sorted) WITH ORDINALITY AS sorted(entry, ordinality)
    WHERE sorted.entry->>'id' = v_current_id
    LIMIT 1;
    v_current_turn := COALESCE(v_current_turn, 0);
  ELSE
    v_current_turn := 0;
  END IF;

  v_next := COALESCE(v_data, '{}'::JSONB) || jsonb_build_object(
    'turn_order', v_sorted,
    'current_turn', v_current_turn,
    'active', v_active,
    'round', v_round,
    'expected_character_ids', v_expected
  );

  UPDATE public.campaigns SET combat_data = v_next WHERE id = p_campaign_id;
  RETURN v_next;
END;
$$;

-- Avança a ordem com validação: o Mestre pode avançar qualquer turno;
-- o jogador só pode encerrar o turno de uma ficha própria que esteja ativa.
CREATE OR REPLACE FUNCTION public.avancar_turno(p_campaign_id BIGINT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_role TEXT;
  v_data JSONB;
  v_order JSONB;
  v_current INTEGER;
  v_next INTEGER;
  v_round INTEGER;
  v_entry JSONB;
  v_next_data JSONB;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  SELECT m.role INTO v_role
  FROM public.members AS m
  WHERE m.campaign_id = p_campaign_id AND m.user_id = auth.uid()
  LIMIT 1;

  IF v_role IS NULL OR v_role NOT IN ('GM', 'PLAYER') THEN
    RAISE EXCEPTION 'Somente um membro ativo da campanha pode avançar o turno.';
  END IF;

  SELECT combat_data INTO v_data
  FROM public.campaigns
  WHERE id = p_campaign_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  IF v_data IS NULL OR COALESCE((v_data->>'active')::BOOLEAN, FALSE) IS NOT TRUE THEN
    RAISE EXCEPTION 'A iniciativa ainda não está ativa.';
  END IF;

  v_order := CASE WHEN jsonb_typeof(v_data->'turn_order') = 'array'
                  THEN v_data->'turn_order' ELSE '[]'::JSONB END;
  IF jsonb_array_length(v_order) = 0 THEN
    RAISE EXCEPTION 'A fila de iniciativa está vazia.';
  END IF;

  v_current := GREATEST(0, LEAST(jsonb_array_length(v_order)-1, COALESCE((v_data->>'current_turn')::INTEGER, 0)));
  v_entry := v_order->v_current;

  IF v_role <> 'GM' THEN
    IF COALESCE((v_entry->>'is_monster')::BOOLEAN, FALSE) THEN
      RAISE EXCEPTION 'O turno atual pertence a uma criatura controlada pelo Mestre.';
    END IF;
    IF NOT EXISTS (
      SELECT 1 FROM public.characters AS c
      WHERE c.campaign_id = p_campaign_id
        AND c.id::TEXT = v_entry->>'id'
        AND c.user_id = auth.uid()
    ) THEN
      RAISE EXCEPTION 'Você só pode encerrar o turno da sua própria ficha.';
    END IF;
  END IF;

  v_next := v_current + 1;
  v_round := GREATEST(1, COALESCE((v_data->>'round')::INTEGER, 1));
  IF v_next >= jsonb_array_length(v_order) THEN
    v_next := 0;
    v_round := v_round + 1;
  END IF;

  v_next_data := v_data || jsonb_build_object('current_turn', v_next, 'round', v_round, 'active', TRUE);
  UPDATE public.campaigns SET combat_data = v_next_data WHERE id = p_campaign_id;
  RETURN v_next_data;
END;
$$;

-- Acrescenta um token à cena publicada sob lock de linha, para que reforços
-- simultâneos não sobrescrevam o mapa ou as posições de outros tokens.
CREATE OR REPLACE FUNCTION public.adicionar_token_cba(
  p_campaign_id BIGINT,
  p_token JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_role TEXT;
  v_data JSONB;
  v_tokens JSONB;
  v_token JSONB;
  v_tipo TEXT;
  v_id TEXT;
  v_key TEXT;
  v_nome TEXT;
  v_imagem TEXT;
  v_detalhe TEXT;
  v_grid_x INTEGER;
  v_grid_y INTEGER;
  v_columns INTEGER;
  v_rows INTEGER;
  v_total INTEGER;
  v_inicio INTEGER;
  v_i INTEGER;
  v_pos INTEGER;
  v_candidato_x INTEGER;
  v_candidato_y INTEGER;
  v_celula_livre BOOLEAN;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  SELECT m.role INTO v_role
  FROM public.members AS m
  WHERE m.campaign_id = p_campaign_id AND m.user_id = auth.uid()
  LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode adicionar tokens ao tabuleiro.';
  END IF;

  IF jsonb_typeof(p_token) IS DISTINCT FROM 'object' THEN
    RAISE EXCEPTION 'O token enviado é inválido.';
  END IF;
  v_tipo := NULLIF(BTRIM(p_token->>'tipo'), '');
  IF v_tipo IS DISTINCT FROM 'npc' AND v_tipo IS DISTINCT FROM 'monstro' AND v_tipo IS DISTINCT FROM 'player' THEN
    RAISE EXCEPTION 'Tipo de token inválido.';
  END IF;
  v_id := LEFT(BTRIM(COALESCE(p_token->>'id', '')), 120);
  v_key := LEFT(BTRIM(COALESCE(p_token->>'key', '')), 160);
  v_nome := LEFT(BTRIM(COALESCE(p_token->>'nome', '')), 120);
  IF v_id = '' OR v_key = '' OR v_nome = '' THEN
    RAISE EXCEPTION 'O token precisa de identificador, chave e nome.';
  END IF;
  IF v_tipo = 'player' THEN
    SELECT LEFT(COALESCE(NULLIF(BTRIM(c.nome), ''), 'Aventureiro'), 120),
           COALESCE(c.retrato_url, '')
    INTO v_nome, v_imagem
    FROM public.characters AS c
    JOIN public.members AS player_member
      ON player_member.campaign_id = c.campaign_id
     AND player_member.user_id = c.user_id
     AND player_member.role = 'PLAYER'
    WHERE c.campaign_id = p_campaign_id
      AND c.id::TEXT = v_id
    LIMIT 1;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'A ficha player não pertence a um jogador desta campanha.';
    END IF;
  END IF;
  IF v_tipo <> 'player' THEN
    v_imagem := COALESCE(p_token->>'imagem', '');
  END IF;
  IF v_imagem <> '' AND v_imagem !~* '^https?://[^[:space:]"<>]+$' THEN
    v_imagem := '';
  END IF;
  v_detalhe := LEFT(COALESCE(p_token->>'detalhe', ''), 160);
  v_columns := GREATEST(1, LEAST(200, CASE WHEN COALESCE(p_token->>'boardColumns', '') ~ '^[0-9]+$' THEN (p_token->>'boardColumns')::INTEGER ELSE 20 END));
  v_rows := GREATEST(1, LEAST(200, CASE WHEN COALESCE(p_token->>'boardRows', '') ~ '^[0-9]+$' THEN (p_token->>'boardRows')::INTEGER ELSE 20 END));
  v_grid_x := GREATEST(0, LEAST(v_columns - 1, CASE WHEN COALESCE(p_token->>'gridX', '') ~ '^[0-9]+$' THEN (p_token->>'gridX')::INTEGER ELSE 0 END));
  v_grid_y := GREATEST(0, LEAST(v_rows - 1, CASE WHEN COALESCE(p_token->>'gridY', '') ~ '^[0-9]+$' THEN (p_token->>'gridY')::INTEGER ELSE 0 END));

  SELECT cba_data INTO v_data
  FROM public.campaigns
  WHERE id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;

  v_data := COALESCE(v_data, jsonb_build_object(
    'version', 1, 'background', '', 'imgScale', 1, 'gridSize', 50,
    'gridRatio', NULL, 'gridOpacity', 0.3, 'tokens', '[]'::JSONB
  ));
  v_tokens := CASE WHEN jsonb_typeof(v_data->'tokens') = 'array'
                  THEN v_data->'tokens' ELSE '[]'::JSONB END;
  IF jsonb_array_length(v_tokens) >= 500 THEN
    RAISE EXCEPTION 'O limite de 500 tokens por cena foi atingido.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM jsonb_array_elements(v_tokens) AS existing(token)
    WHERE existing.token->>'key' = v_key OR existing.token->>'id' = v_id
  ) THEN
    RAISE EXCEPTION 'Este token já existe no tabuleiro.';
  END IF;

  v_total := v_columns * v_rows;
  IF EXISTS (
    SELECT 1 FROM jsonb_array_elements(v_tokens) AS existing(token)
    WHERE CASE WHEN COALESCE(existing.token->>'gridX', '') ~ '^[0-9]+$' THEN (existing.token->>'gridX')::INTEGER ELSE -1 END = v_grid_x
      AND CASE WHEN COALESCE(existing.token->>'gridY', '') ~ '^[0-9]+$' THEN (existing.token->>'gridY')::INTEGER ELSE -1 END = v_grid_y
  ) THEN
    v_celula_livre := FALSE;
    v_inicio := FLOOR(random() * v_total)::INTEGER;
    FOR v_i IN 0..(v_total - 1) LOOP
      v_pos := (v_inicio + v_i) % v_total;
      v_candidato_x := v_pos % v_columns;
      v_candidato_y := FLOOR(v_pos::NUMERIC / v_columns)::INTEGER;
      IF NOT EXISTS (
        SELECT 1 FROM jsonb_array_elements(v_tokens) AS existing(token)
        WHERE CASE WHEN COALESCE(existing.token->>'gridX', '') ~ '^[0-9]+$' THEN (existing.token->>'gridX')::INTEGER ELSE -1 END = v_candidato_x
          AND CASE WHEN COALESCE(existing.token->>'gridY', '') ~ '^[0-9]+$' THEN (existing.token->>'gridY')::INTEGER ELSE -1 END = v_candidato_y
      ) THEN
        v_grid_x := v_candidato_x;
        v_grid_y := v_candidato_y;
        v_celula_livre := TRUE;
        EXIT;
      END IF;
    END LOOP;
    IF NOT v_celula_livre THEN
      RAISE EXCEPTION 'Não há quadrados vazios no tabuleiro para outro reforço.';
    END IF;
  END IF;

  v_token := jsonb_build_object(
    'key', v_key, 'id', v_id, 'nome', v_nome, 'imagem', v_imagem,
    'tipo', v_tipo, 'detalhe', v_detalhe, 'gridX', v_grid_x, 'gridY', v_grid_y
  );
  v_data := v_data || jsonb_build_object('tokens', v_tokens || jsonb_build_array(v_token));
  UPDATE public.campaigns SET cba_data = v_data WHERE id = p_campaign_id;
  RETURN v_data;
END;
$$;

-- Salva os ajustes de fundo/grade e mescla tokens criados em paralelo que não
-- estavam no rascunho do editor, evitando apagar reforços já publicados.
CREATE OR REPLACE FUNCTION public.salvar_cena_cba(
  p_campaign_id BIGINT,
  p_scene JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_role TEXT;
  v_current JSONB;
  v_current_tokens JSONB;
  v_requested_tokens JSONB;
  v_merged_tokens JSONB;
  v_scene JSONB;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  SELECT m.role INTO v_role
  FROM public.members AS m
  WHERE m.campaign_id = p_campaign_id AND m.user_id = auth.uid()
  LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode publicar alterações no CBA.';
  END IF;
  IF jsonb_typeof(p_scene) IS DISTINCT FROM 'object' THEN
    RAISE EXCEPTION 'A cena enviada é inválida.';
  END IF;

  SELECT cba_data INTO v_current
  FROM public.campaigns
  WHERE id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;

  v_requested_tokens := CASE WHEN jsonb_typeof(p_scene->'tokens') = 'array'
                             THEN p_scene->'tokens' ELSE '[]'::JSONB END;
  v_current_tokens := CASE WHEN jsonb_typeof(v_current->'tokens') = 'array'
                           THEN v_current->'tokens' ELSE '[]'::JSONB END;
  IF jsonb_array_length(v_requested_tokens) > 500 THEN
    RAISE EXCEPTION 'O limite de 500 tokens por cena foi atingido.';
  END IF;

  SELECT COALESCE(jsonb_agg(q.token ORDER BY q.ord), '[]'::JSONB)
  INTO v_merged_tokens
  FROM (
    SELECT requested.token, requested.ordinality::BIGINT AS ord
    FROM jsonb_array_elements(v_requested_tokens) WITH ORDINALITY AS requested(token, ordinality)
    UNION ALL
    SELECT existing.token, jsonb_array_length(v_requested_tokens)::BIGINT + existing.ordinality AS ord
    FROM jsonb_array_elements(v_current_tokens) WITH ORDINALITY AS existing(token, ordinality)
    WHERE NOT EXISTS (
      SELECT 1 FROM jsonb_array_elements(v_requested_tokens) AS requested(token)
      WHERE (requested.token->>'key' IS NOT NULL AND requested.token->>'key' = existing.token->>'key')
         OR (requested.token->>'id' IS NOT NULL AND requested.token->>'id' = existing.token->>'id')
    )
  ) AS q;
  IF jsonb_array_length(v_merged_tokens) > 500 THEN
    RAISE EXCEPTION 'O limite de 500 tokens por cena foi atingido.';
  END IF;

  v_scene := p_scene || jsonb_build_object('tokens', v_merged_tokens);
  UPDATE public.campaigns SET cba_data = v_scene WHERE id = p_campaign_id;
  RETURN v_scene;
END;
$$;

-- Acrescenta reforço à iniciativa apenas depois de o token ter sido publicado
-- no CBA. O ID do token é também o ID único do combatente.
CREATE OR REPLACE FUNCTION public.adicionar_combatente_iniciativa(
  p_campaign_id BIGINT,
  p_combatente_id TEXT,
  p_nome TEXT,
  p_valor INTEGER,
  p_tipo TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_role TEXT;
  v_estado TEXT;
  v_scene JSONB;
  v_data JSONB;
  v_order JSONB;
  v_expected JSONB;
  v_entry JSONB;
  v_sorted JSONB;
  v_current_id TEXT;
  v_current_turn INTEGER := 0;
  v_round INTEGER := 1;
  v_active BOOLEAN := FALSE;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  SELECT m.role INTO v_role
  FROM public.members AS m
  WHERE m.campaign_id = p_campaign_id AND m.user_id = auth.uid()
  LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode inserir reforços na iniciativa.';
  END IF;
  IF NULLIF(BTRIM(p_combatente_id), '') IS NULL OR NULLIF(BTRIM(p_nome), '') IS NULL THEN
    RAISE EXCEPTION 'Identificador e nome do combatente são obrigatórios.';
  END IF;
  IF p_tipo IS DISTINCT FROM 'npc' AND p_tipo IS DISTINCT FROM 'monstro' THEN
    RAISE EXCEPTION 'Tipo de reforço inválido.';
  END IF;
  IF p_valor IS NULL OR p_valor < -50 OR p_valor > 100 THEN
    RAISE EXCEPTION 'A iniciativa deve ser um número entre -50 e 100.';
  END IF;

  SELECT state, cba_data, combat_data INTO v_estado, v_scene, v_data
  FROM public.campaigns
  WHERE id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  IF UPPER(COALESCE(v_estado, '')) <> 'COMBATE' THEN
    RAISE EXCEPTION 'Reforços só entram na iniciativa durante o combate.';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(v_scene->'tokens') = 'array'
           THEN v_scene->'tokens' ELSE '[]'::JSONB END
    ) AS token(item)
    WHERE token.item->>'id' = p_combatente_id
      AND token.item->>'tipo' = p_tipo
  ) THEN
    RAISE EXCEPTION 'O combatente não corresponde a um token publicado nesta campanha.';
  END IF;

  v_data := COALESCE(v_data, jsonb_build_object(
    'turn_order', '[]'::JSONB, 'current_turn', 0, 'active', FALSE,
    'round', 1, 'expected_character_ids', '[]'::JSONB
  ));
  v_order := CASE WHEN jsonb_typeof(v_data->'turn_order') = 'array'
                  THEN v_data->'turn_order' ELSE '[]'::JSONB END;
  v_expected := CASE WHEN jsonb_typeof(v_data->'expected_character_ids') = 'array'
                     THEN v_data->'expected_character_ids' ELSE '[]'::JSONB END;
  v_round := GREATEST(1, COALESCE((v_data->>'round')::INTEGER, 1));
  v_active := COALESCE((v_data->>'active')::BOOLEAN, FALSE);
  IF v_active THEN
    SELECT old.entry->>'id' INTO v_current_id
    FROM jsonb_array_elements(v_order) WITH ORDINALITY AS old(entry, ordinality)
    WHERE old.ordinality = COALESCE((v_data->>'current_turn')::INTEGER, 0) + 1
    LIMIT 1;
  END IF;

  v_entry := jsonb_build_object(
    'id', p_combatente_id, 'nome', LEFT(BTRIM(p_nome), 120), 'valor', p_valor,
    'is_monster', TRUE, 'tipo', p_tipo
  );
  IF v_active THEN
    SELECT COALESCE(jsonb_agg(
      CASE WHEN old.entry->>'id' = p_combatente_id THEN v_entry ELSE old.entry END
      ORDER BY old.ordinality
    ), '[]'::JSONB) INTO v_sorted
    FROM jsonb_array_elements(v_order) WITH ORDINALITY AS old(entry, ordinality);
    IF NOT EXISTS (
      SELECT 1 FROM jsonb_array_elements(v_order) AS old(entry)
      WHERE old.entry->>'id' = p_combatente_id
    ) THEN
      v_sorted := v_sorted || jsonb_build_array(v_entry);
    END IF;
  ELSE
    SELECT COALESCE(
      jsonb_agg(q.entry ORDER BY COALESCE(NULLIF(q.entry->>'valor', '')::NUMERIC, 0) DESC,
                                      q.entry->>'nome' ASC, q.entry->>'id' ASC),
      '[]'::JSONB
    ) INTO v_sorted
    FROM (
      SELECT old.entry
      FROM jsonb_array_elements(v_order) AS old(entry)
      WHERE old.entry->>'id' <> p_combatente_id
      UNION ALL
      SELECT v_entry
    ) AS q;
  END IF;

  IF jsonb_array_length(v_expected) > 0 THEN
    SELECT NOT EXISTS (
      SELECT 1 FROM jsonb_array_elements_text(v_expected) AS expected(character_id)
      WHERE NOT EXISTS (
        SELECT 1 FROM jsonb_array_elements(v_sorted) AS current_entry(entry)
        WHERE current_entry.entry->>'id' = expected.character_id
      )
    ) INTO v_active;
  END IF;
  IF v_active AND v_current_id IS NOT NULL THEN
    SELECT sorted.ordinality - 1 INTO v_current_turn
    FROM jsonb_array_elements(v_sorted) WITH ORDINALITY AS sorted(entry, ordinality)
    WHERE sorted.entry->>'id' = v_current_id
    LIMIT 1;
    v_current_turn := COALESCE(v_current_turn, 0);
  ELSE
    v_current_turn := 0;
  END IF;

  v_data := v_data || jsonb_build_object(
    'turn_order', v_sorted, 'current_turn', v_current_turn,
    'active', v_active, 'round', v_round, 'expected_character_ids', v_expected
  );
  UPDATE public.campaigns SET combat_data = v_data WHERE id = p_campaign_id;
  RETURN v_data;
END;
$$;

-- Reordena dois combatentes adjacentes e recalcula o índice do turno atual
-- pelo ID, mantendo a mesma criatura/jogador ativo apesar da troca.
CREATE OR REPLACE FUNCTION public.mover_combatente_iniciativa(
  p_campaign_id BIGINT,
  p_indice INTEGER,
  p_direcao INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_role TEXT;
  v_data JSONB;
  v_order JSONB;
  v_sorted JSONB;
  v_items JSONB[];
  v_temp JSONB;
  v_target INTEGER;
  v_current_id TEXT;
  v_current_turn INTEGER := 0;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  SELECT m.role INTO v_role
  FROM public.members AS m
  WHERE m.campaign_id = p_campaign_id AND m.user_id = auth.uid()
  LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode reordenar a iniciativa.';
  END IF;
  IF p_direcao IS NULL OR p_direcao NOT IN (-1, 1) THEN
    RAISE EXCEPTION 'A direção de movimento deve ser -1 ou 1.';
  END IF;

  SELECT combat_data INTO v_data
  FROM public.campaigns
  WHERE id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  IF v_data IS NULL OR jsonb_typeof(v_data->'turn_order') IS DISTINCT FROM 'array' THEN
    RAISE EXCEPTION 'Ainda não há uma ordem de iniciativa para reordenar.';
  END IF;
  v_order := v_data->'turn_order';
  IF jsonb_array_length(v_order) = 0 THEN
    RAISE EXCEPTION 'A fila de iniciativa está vazia.';
  END IF;
  v_target := p_indice + p_direcao;
  IF p_indice IS NULL OR p_indice < 0 OR p_indice >= jsonb_array_length(v_order)
     OR v_target < 0 OR v_target >= jsonb_array_length(v_order) THEN
    RAISE EXCEPTION 'A posição solicitada está fora da fila.';
  END IF;

  IF COALESCE((v_data->>'active')::BOOLEAN, FALSE) THEN
    SELECT old.entry->>'id' INTO v_current_id
    FROM jsonb_array_elements(v_order) WITH ORDINALITY AS old(entry, ordinality)
    WHERE old.ordinality = COALESCE((v_data->>'current_turn')::INTEGER, 0) + 1
    LIMIT 1;
  END IF;
  SELECT array_agg(old.entry ORDER BY old.ordinality) INTO v_items
  FROM jsonb_array_elements(v_order) WITH ORDINALITY AS old(entry, ordinality);
  v_temp := v_items[p_indice + 1];
  v_items[p_indice + 1] := v_items[v_target + 1];
  v_items[v_target + 1] := v_temp;
  SELECT COALESCE(jsonb_agg(new_order.entry ORDER BY new_order.ordinality), '[]'::JSONB)
  INTO v_sorted
  FROM unnest(v_items) WITH ORDINALITY AS new_order(entry, ordinality);

  IF v_current_id IS NOT NULL THEN
    SELECT sorted.ordinality - 1 INTO v_current_turn
    FROM jsonb_array_elements(v_sorted) WITH ORDINALITY AS sorted(entry, ordinality)
    WHERE sorted.entry->>'id' = v_current_id
    LIMIT 1;
    v_current_turn := COALESCE(v_current_turn, 0);
  ELSE
    v_current_turn := 0;
  END IF;
  v_data := v_data || jsonb_build_object('turn_order', v_sorted, 'current_turn', v_current_turn);
  UPDATE public.campaigns SET combat_data = v_data WHERE id = p_campaign_id;
  RETURN v_data;
END;
$$;

REVOKE ALL ON FUNCTION public.alternar_estado_campanha(BIGINT, TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.iniciar_iniciativa(BIGINT, TEXT[]) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.registrar_iniciativa(BIGINT, TEXT, TEXT, INTEGER) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.avancar_turno(BIGINT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.adicionar_token_cba(BIGINT, JSONB) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.salvar_cena_cba(BIGINT, JSONB) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.adicionar_combatente_iniciativa(BIGINT, TEXT, TEXT, INTEGER, TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.mover_combatente_iniciativa(BIGINT, INTEGER, INTEGER) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.alternar_estado_campanha(BIGINT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.iniciar_iniciativa(BIGINT, TEXT[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.registrar_iniciativa(BIGINT, TEXT, TEXT, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION public.avancar_turno(BIGINT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.adicionar_token_cba(BIGINT, JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION public.salvar_cena_cba(BIGINT, JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION public.adicionar_combatente_iniciativa(BIGINT, TEXT, TEXT, INTEGER, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.mover_combatente_iniciativa(BIGINT, INTEGER, INTEGER) TO authenticated;
