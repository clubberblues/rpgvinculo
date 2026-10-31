-- Vínculo D&D 3.5: rotinas finais protegidas para campanha, PV e movimento.
-- Preparada a partir dos SQLs de migração existentes; não executa nem conecta ao Supabase.
-- Todas as rotinas SECURITY DEFINER usam search_path fixo e têm EXECUTE revogado de PUBLIC.

-- Exclui logs da ficha somente quando algum valor JSON escalar contém exatamente
-- o ID do personagem. Valores/estruturas desconhecidos ou sem essa referência são preservados.
CREATE OR REPLACE FUNCTION public._jsonb_contem_texto_exato(p_valor JSONB, p_alvo TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
IMMUTABLE
STRICT
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_filho JSONB;
BEGIN
  CASE jsonb_typeof(p_valor)
    WHEN 'string' THEN
      RETURN p_valor #>> '{}' = p_alvo;
    WHEN 'array' THEN
      FOR v_filho IN SELECT elemento FROM jsonb_array_elements(p_valor) AS a(elemento) LOOP
        IF public._jsonb_contem_texto_exato(v_filho, p_alvo) THEN
          RETURN TRUE;
        END IF;
      END LOOP;
    WHEN 'object' THEN
      FOR v_filho IN SELECT valor FROM jsonb_each(p_valor) AS o(chave, valor) LOOP
        IF public._jsonb_contem_texto_exato(v_filho, p_alvo) THEN
          RETURN TRUE;
        END IF;
      END LOOP;
    ELSE
      RETURN FALSE;
  END CASE;
  RETURN FALSE;
END;
$$;
REVOKE ALL ON FUNCTION public._jsonb_contem_texto_exato(JSONB, TEXT) FROM PUBLIC;

-- Substitui a RPC existente para limpar dependências conhecidas e apenas os logs
-- que comprovadamente contêm o ID exato desta ficha. Registros alheios/ambíguos ficam.
CREATE OR REPLACE FUNCTION public.excluir_ficha_propria(p_character_id TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_character_id public.characters.id%TYPE;
  v_campaign_id public.characters.campaign_id%TYPE;
  v_combat JSONB;
  v_order JSONB := '[]'::JSONB;
  v_expected JSONB := '[]'::JSONB;
  v_order_novo JSONB := '[]'::JSONB;
  v_expected_novo JSONB := '[]'::JSONB;
  v_current_id TEXT;
  v_old_turn INTEGER := 0;
  v_new_turn INTEGER := 0;
  v_active BOOLEAN := FALSE;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF NULLIF(BTRIM(p_character_id), '') IS NULL THEN
    RAISE EXCEPTION 'O identificador da ficha é obrigatório.';
  END IF;

  SELECT c.id, c.campaign_id
  INTO v_character_id, v_campaign_id
  FROM public.characters AS c
  WHERE c.id::TEXT = BTRIM(p_character_id)
    AND c.user_id = auth.uid()
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Ficha não encontrada ou não pertence à sua conta.';
  END IF;

  IF v_campaign_id IS NOT NULL THEN
    SELECT c.combat_data INTO v_combat
    FROM public.campaigns AS c
    WHERE c.id = v_campaign_id
    FOR UPDATE;
    IF FOUND AND v_combat IS NOT NULL THEN
      v_order := CASE WHEN jsonb_typeof(v_combat->'turn_order') = 'array'
                      THEN v_combat->'turn_order' ELSE '[]'::JSONB END;
      v_expected := CASE WHEN jsonb_typeof(v_combat->'expected_character_ids') = 'array'
                         THEN v_combat->'expected_character_ids' ELSE '[]'::JSONB END;
      v_old_turn := CASE WHEN COALESCE(v_combat->>'current_turn', '') ~ '^-?[0-9]+$'
                         THEN GREATEST(0, (v_combat->>'current_turn')::INTEGER) ELSE 0 END;
      SELECT entry->>'id' INTO v_current_id
      FROM jsonb_array_elements(v_order) WITH ORDINALITY AS q(entry, ordinality)
      WHERE q.ordinality = v_old_turn + 1
      LIMIT 1;

      SELECT COALESCE(jsonb_agg(q.entry ORDER BY q.ordinality), '[]'::JSONB)
      INTO v_order_novo
      FROM jsonb_array_elements(v_order) WITH ORDINALITY AS q(entry, ordinality)
      WHERE q.entry->>'id' IS DISTINCT FROM v_character_id::TEXT;
      SELECT COALESCE(jsonb_agg(q.character_id ORDER BY q.ordinality), '[]'::JSONB)
      INTO v_expected_novo
      FROM jsonb_array_elements_text(v_expected) WITH ORDINALITY AS q(character_id, ordinality)
      WHERE q.character_id IS DISTINCT FROM v_character_id::TEXT;

      SELECT jsonb_array_length(v_order_novo) > 0
         AND NOT EXISTS (
           SELECT 1
           FROM jsonb_array_elements_text(v_expected_novo) AS e(character_id)
           WHERE NOT EXISTS (
             SELECT 1 FROM jsonb_array_elements(v_order_novo) AS o(entry)
             WHERE o.entry->>'id' = e.character_id
           )
         )
      INTO v_active;
      IF v_active THEN
        SELECT q.ordinality - 1 INTO v_new_turn
        FROM jsonb_array_elements(v_order_novo) WITH ORDINALITY AS q(entry, ordinality)
        WHERE q.entry->>'id' = v_current_id
        LIMIT 1;
        IF v_new_turn IS NULL THEN
          v_new_turn := LEAST(v_old_turn, GREATEST(jsonb_array_length(v_order_novo) - 1, 0));
        END IF;
      END IF;
      UPDATE public.campaigns
      SET combat_data = v_combat || jsonb_build_object(
        'turn_order', v_order_novo,
        'expected_character_ids', v_expected_novo,
        'active', v_active,
        'current_turn', v_new_turn
      )
      WHERE id = v_campaign_id;

    END IF;
  END IF;

  -- JSON data não tem FK: apagar somente entradas com referência escalar exata
  -- ao ID, em qualquer campanha; não inferir referência por nomes ou texto parcial.
  DELETE FROM public.campaign_log AS l
  WHERE public._jsonb_contem_texto_exato(l.data, v_character_id::TEXT);

  DELETE FROM public.character_spells WHERE character_id::TEXT = v_character_id::TEXT;
  DELETE FROM public.character_talents WHERE character_id::TEXT = v_character_id::TEXT;
  DELETE FROM public.character_notes WHERE character_id::TEXT = v_character_id::TEXT;
  DELETE FROM public.inventory WHERE character_id::TEXT = v_character_id::TEXT;
  DELETE FROM public.srd_character_sheets WHERE character_id::TEXT = v_character_id::TEXT;
  DELETE FROM public.vinculo_character_sheets WHERE character_id::TEXT = v_character_id::TEXT;
  DELETE FROM public.characters
  WHERE id = v_character_id AND user_id = auth.uid();
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Não foi possível excluir a ficha.';
  END IF;
  RETURN jsonb_build_object('deleted', TRUE, 'character_id', v_character_id::TEXT);
END;
$$;
REVOKE ALL ON FUNCTION public.excluir_ficha_propria(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.excluir_ficha_propria(TEXT) TO authenticated;

-- Exclui campanha somente pelo proprietário que também é membro GM. A linha da
-- campanha fica bloqueada durante todas as alterações; a chamada é transacional.
CREATE OR REPLACE FUNCTION public.excluir_campanha_propria(
  p_campaign_id BIGINT,
  p_confirmation_name TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_owner UUID;
  v_name TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  SELECT c.owner_id, c.name INTO v_owner, v_name
  FROM public.campaigns AS c
  WHERE c.id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  IF v_owner IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'Somente o proprietário da campanha pode excluí-la.';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.members AS m
    WHERE m.campaign_id = p_campaign_id
      AND m.user_id = auth.uid()
      AND m.role = 'GM'
  ) THEN
    RAISE EXCEPTION 'A exclusão exige que o proprietário seja membro GM da campanha.';
  END IF;
  IF p_confirmation_name IS DISTINCT FROM v_name THEN
    RAISE EXCEPTION 'O nome de confirmação deve corresponder exatamente ao nome da campanha.';
  END IF;

  DELETE FROM public.members WHERE campaign_id = p_campaign_id;
  DELETE FROM public.campaign_log WHERE campaign_id = p_campaign_id;
  UPDATE public.characters SET campaign_id = NULL WHERE campaign_id = p_campaign_id;
  DELETE FROM public.campaigns WHERE id = p_campaign_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Não foi possível excluir a campanha.';
  END IF;
  RETURN jsonb_build_object('deleted', TRUE, 'campaign_id', p_campaign_id);
END;
$$;
REVOKE ALL ON FUNCTION public.excluir_campanha_propria(BIGINT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.excluir_campanha_propria(BIGINT, TEXT) TO authenticated;

-- GM altera PV por variação positiva/negativa. pv_atual é limitado a 0..pv_max.
CREATE OR REPLACE FUNCTION public.alterar_pv_personagem(
  p_campaign_id BIGINT,
  p_character_id TEXT,
  p_variacao INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_role TEXT;
  v_pv_atual INTEGER;
  v_pv_max INTEGER;
  v_pv_novo INTEGER;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF p_variacao IS NULL THEN
    RAISE EXCEPTION 'A variação de PV é obrigatória.';
  END IF;
  SELECT m.role INTO v_role
  FROM public.members AS m
  WHERE m.campaign_id = p_campaign_id AND m.user_id = auth.uid()
  LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre da campanha pode alterar os PV.';
  END IF;

  PERFORM 1 FROM public.campaigns WHERE id = p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  SELECT s.pv_atual, s.pv_max INTO v_pv_atual, v_pv_max
  FROM public.characters AS c
  JOIN public.srd_character_sheets AS s
    ON s.character_id::TEXT = c.id::TEXT
  WHERE c.id::TEXT = BTRIM(p_character_id)
    AND c.campaign_id = p_campaign_id
  FOR UPDATE OF s;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Personagem SRD não encontrado nesta campanha.';
  END IF;
  IF v_pv_max IS NULL OR v_pv_max < 0 THEN
    RAISE EXCEPTION 'A ficha não possui um PV máximo válido.';
  END IF;
  v_pv_novo := GREATEST(0, LEAST(v_pv_max, COALESCE(v_pv_atual, 0) + p_variacao));
  UPDATE public.srd_character_sheets AS s
  SET pv_atual = v_pv_novo
  WHERE s.character_id::TEXT = BTRIM(p_character_id);
  RETURN jsonb_build_object(
    'character_id', BTRIM(p_character_id),
    'pv_atual', v_pv_novo,
    'pv_max', v_pv_max,
    'variacao_solicitada', p_variacao
  );
END;
$$;
REVOKE ALL ON FUNCTION public.alterar_pv_personagem(BIGINT, TEXT, INTEGER) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.alterar_pv_personagem(BIGINT, TEXT, INTEGER) TO authenticated;

-- Movimento de token player do personagem ativo. Uso por turno fica em
-- combat_data.movement_usage e reinicia ao mudar round/índice/personagem ativo.
-- O SQL de origem não persiste dimensões da grade: a validação usa o domínio
-- 0..199 aceito por adicionar_token_cba, sem afirmar os limites reais do mapa.
CREATE OR REPLACE FUNCTION public.mover_token_player_cba(
  p_campaign_id BIGINT,
  p_character_id TEXT,
  p_grid_x INTEGER,
  p_grid_y INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_combat JSONB;
  v_scene JSONB;
  v_tokens JSONB;
  v_order JSONB;
  v_usage JSONB;
  v_entry JSONB;
  v_current_id TEXT;
  v_round INTEGER;
  v_current_turn INTEGER;
  v_token_index BIGINT;
  v_token_count INTEGER;
  v_character_id TEXT;
  v_race_id TEXT;
  v_raw_speed TEXT;
  v_speed_m NUMERIC;
  v_used_squares INTEGER := 0;
  v_move_squares INTEGER;
  v_total_squares INTEGER;
  v_remaining_m NUMERIC;
  v_old_x INTEGER;
  v_old_y INTEGER;
  v_active BOOLEAN;
  v_new_token JSONB;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF NULLIF(BTRIM(p_character_id), '') IS NULL THEN
    RAISE EXCEPTION 'O identificador do personagem é obrigatório.';
  END IF;
  IF p_grid_x IS NULL OR p_grid_y IS NULL OR p_grid_x < 0 OR p_grid_y < 0
     OR p_grid_x > 199 OR p_grid_y > 199 THEN
    RAISE EXCEPTION 'A posição deve estar na grade, com coordenadas inteiras entre 0 e 199.';
  END IF;

  SELECT c.cba_data, c.combat_data INTO v_scene, v_combat
  FROM public.campaigns AS c
  WHERE c.id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  v_active := lower(COALESCE(v_combat->>'active', 'false')) = 'true';
  IF NOT v_active THEN
    RAISE EXCEPTION 'Não há um turno de combate ativo.';
  END IF;
  v_order := CASE WHEN jsonb_typeof(v_combat->'turn_order') = 'array'
                  THEN v_combat->'turn_order' ELSE '[]'::JSONB END;
  IF jsonb_array_length(v_order) = 0 THEN
    RAISE EXCEPTION 'A ordem de iniciativa está vazia.';
  END IF;
  v_current_turn := CASE WHEN COALESCE(v_combat->>'current_turn', '') ~ '^[0-9]+$'
                         THEN (v_combat->>'current_turn')::INTEGER ELSE 0 END;
  IF v_current_turn >= jsonb_array_length(v_order) THEN
    RAISE EXCEPTION 'O turno atual da iniciativa é inválido.';
  END IF;
  v_entry := v_order->v_current_turn;
  v_current_id := v_entry->>'id';
  IF COALESCE(lower(v_entry->>'is_monster'), 'false') = 'true' THEN
    RAISE EXCEPTION 'O turno atual pertence a uma criatura controlada pelo Mestre.';
  END IF;
  IF v_current_id IS DISTINCT FROM BTRIM(p_character_id) THEN
    RAISE EXCEPTION 'Somente o personagem cujo turno está ativo pode mover seu token.';
  END IF;

  SELECT c.id::TEXT, s.raca_id::TEXT INTO v_character_id, v_race_id
  FROM public.characters AS c
  JOIN public.srd_character_sheets AS s ON s.character_id::TEXT = c.id::TEXT
  WHERE c.id::TEXT = BTRIM(p_character_id)
    AND c.campaign_id = p_campaign_id
    AND c.user_id = auth.uid()
  FOR UPDATE OF c, s;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'O personagem não pertence à sua conta ou não tem ficha SRD nesta campanha.';
  END IF;

  SELECT to_jsonb(r)->>'deslocamento' INTO v_raw_speed
  FROM public.srd_races AS r
  WHERE r.id::TEXT = v_race_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'A raça da ficha não foi encontrada.';
  END IF;
  IF v_raw_speed IS NULL THEN
    v_speed_m := 9;
  ELSIF v_raw_speed ~ '^[0-9]+([.][0-9]+)?$' THEN
    v_speed_m := v_raw_speed::NUMERIC;
  ELSE
    RAISE EXCEPTION 'O deslocamento racial não possui um valor numérico válido em metros.';
  END IF;
  IF v_speed_m < 0 THEN
    RAISE EXCEPTION 'O deslocamento racial não pode ser negativo.';
  END IF;

  v_tokens := CASE WHEN jsonb_typeof(v_scene->'tokens') = 'array'
                   THEN v_scene->'tokens' ELSE '[]'::JSONB END;
  SELECT count(*)::INTEGER, min(q.ordinality)
  INTO v_token_count, v_token_index
  FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS q(token, ordinality)
  WHERE q.token->>'id' = v_character_id AND q.token->>'tipo' = 'player';
  IF v_token_count = 0 THEN
    RAISE EXCEPTION 'Não existe token player publicado para este personagem.';
  ELSIF v_token_count > 1 THEN
    RAISE EXCEPTION 'Há mais de um token player para este personagem; peça ao Mestre para corrigir a cena.';
  END IF;
  v_entry := v_tokens->(v_token_index::INTEGER - 1);
  IF COALESCE(v_entry->>'gridX', '') !~ '^[0-9]+$'
     OR COALESCE(v_entry->>'gridY', '') !~ '^[0-9]+$' THEN
    RAISE EXCEPTION 'A posição atual do token é inválida.';
  END IF;
  v_old_x := (v_entry->>'gridX')::INTEGER;
  v_old_y := (v_entry->>'gridY')::INTEGER;
  IF v_old_x < 0 OR v_old_y < 0 OR v_old_x > 199 OR v_old_y > 199 THEN
    RAISE EXCEPTION 'A posição atual do token está fora do domínio válido da grade.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS q(token, ordinality)
    WHERE q.ordinality <> v_token_index
      AND CASE WHEN COALESCE(q.token->>'gridX', '') ~ '^[0-9]{1,3}$'
               THEN (q.token->>'gridX')::INTEGER ELSE -1 END = p_grid_x
      AND CASE WHEN COALESCE(q.token->>'gridY', '') ~ '^[0-9]{1,3}$'
               THEN (q.token->>'gridY')::INTEGER ELSE -1 END = p_grid_y
  ) THEN
    RAISE EXCEPTION 'A célula de destino já está ocupada.';
  END IF;

  v_move_squares := GREATEST(ABS(p_grid_x - v_old_x), ABS(p_grid_y - v_old_y));
  v_round := CASE WHEN COALESCE(v_combat->>'round', '') ~ '^[0-9]+$'
                  THEN GREATEST(1, (v_combat->>'round')::INTEGER) ELSE 1 END;
  v_usage := CASE WHEN jsonb_typeof(v_combat->'movement_usage') = 'object'
                  THEN v_combat->'movement_usage' ELSE '{}'::JSONB END;
  IF v_usage->>'character_id' = v_character_id
     AND v_usage->>'round' = v_round::TEXT
     AND v_usage->>'current_turn' = v_current_turn::TEXT
     AND COALESCE(v_usage->>'moved_squares', '') ~ '^[0-9]+$' THEN
    v_used_squares := (v_usage->>'moved_squares')::INTEGER;
  END IF;
  v_total_squares := v_used_squares + v_move_squares;
  v_remaining_m := GREATEST(0::NUMERIC, v_speed_m - (v_total_squares * 1.5));
  IF v_total_squares * 1.5 > v_speed_m THEN
    RAISE EXCEPTION 'Movimento excede o deslocamento restante deste turno (%.1f m restantes).',
      GREATEST(0::NUMERIC, v_speed_m - (v_used_squares * 1.5));
  END IF;

  v_new_token := v_entry || jsonb_build_object('gridX', p_grid_x, 'gridY', p_grid_y);
  v_scene := COALESCE(v_scene, '{}'::JSONB) || jsonb_build_object(
    'tokens', jsonb_set(v_tokens, ARRAY[(v_token_index - 1)::TEXT], v_new_token, FALSE)
  );
  v_combat := v_combat || jsonb_build_object(
    'movement_usage', jsonb_build_object(
      'round', v_round,
      'current_turn', v_current_turn,
      'character_id', v_character_id,
      'moved_squares', v_total_squares
    )
  );
  UPDATE public.campaigns
  SET cba_data = v_scene, combat_data = v_combat
  WHERE id = p_campaign_id;
  RETURN jsonb_build_object(
    'cba_data', v_scene,
    'movement_remaining_m', v_remaining_m
  );
END;
$$;
REVOKE ALL ON FUNCTION public.mover_token_player_cba(BIGINT, TEXT, INTEGER, INTEGER) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.mover_token_player_cba(BIGINT, TEXT, INTEGER, INTEGER) TO authenticated;


-- Inventário D&D 3.5 para a mesa. Criado aqui porque os SQL anteriores não
-- definem srd_equipment nem uma relação de equipamento da ficha SRD.
CREATE TABLE IF NOT EXISTS public.srd_equipment (
  id TEXT PRIMARY KEY,
  nome TEXT NOT NULL,
  categoria TEXT NOT NULL CHECK (categoria IN ('arma','armadura','escudo','consumivel','outro')),
  dano TEXT,
  tipo_dano TEXT,
  bonus_ca INTEGER NOT NULL DEFAULT 0,
  bonus_max_des INTEGER,
  custo_po NUMERIC(10,2) NOT NULL DEFAULT 0,
  peso NUMERIC(8,2) NOT NULL DEFAULT 0,
  detalhes JSONB NOT NULL DEFAULT '{}'::JSONB
);

CREATE TABLE IF NOT EXISTS public.srd_character_equipment (
  character_id TEXT NOT NULL,
  equipment_id TEXT NOT NULL REFERENCES public.srd_equipment(id) ON DELETE RESTRICT,
  quantidade INTEGER NOT NULL DEFAULT 1 CHECK (quantidade > 0),
  equipado BOOLEAN NOT NULL DEFAULT FALSE,
  criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (character_id, equipment_id)
);

ALTER TABLE public.srd_character_equipment ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.srd_character_equipment TO authenticated;
GRANT SELECT ON public.srd_equipment TO authenticated;
DROP POLICY IF EXISTS srd_character_equipment_owner_all ON public.srd_character_equipment;
CREATE POLICY srd_character_equipment_owner_all
ON public.srd_character_equipment
FOR ALL TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.characters AS ch
  WHERE ch.id::TEXT = srd_character_equipment.character_id
    AND ch.user_id = auth.uid()
))
WITH CHECK (EXISTS (
  SELECT 1 FROM public.characters AS ch
  WHERE ch.id::TEXT = srd_character_equipment.character_id
    AND ch.user_id = auth.uid()
));

INSERT INTO public.srd_equipment(id,nome,categoria,dano,tipo_dano,bonus_ca,bonus_max_des,custo_po,peso,detalhes) VALUES
('unarmed','Desarmado','arma','1d3','contundente',0,NULL,0,0,'{"alcance_m":1.5}'::JSONB),
('dagger','Adaga','arma','1d4','perfurante/cortante',0,NULL,2,0.5,'{"alcance_m":1.5,"critico":"19-20/x2"}'::JSONB),
('longsword','Espada longa','arma','1d8','cortante',0,NULL,15,2,'{"alcance_m":1.5,"critico":"19-20/x2"}'::JSONB),
('greatsword','Espada larga','arma','2d6','cortante',0,NULL,50,4,'{"alcance_m":1.5,"critico":"19-20/x2","duas_maos":true}'::JSONB),
('shortbow','Arco curto','arma','1d6','perfurante',0,NULL,30,1,'{"alcance_m":18,"distancia":true}'::JSONB),
('longbow','Arco longo','arma','1d8','perfurante',0,NULL,75,1,'{"alcance_m":30,"distancia":true}'::JSONB),
('quarterstaff','Bordão','arma','1d6','contundente',0,NULL,0,2,'{"alcance_m":1.5,"duas_maos":true}'::JSONB),
('leather','Armadura de couro','armadura',NULL,NULL,2,6,10,7,'{"penalidade_armadura":0}'::JSONB),
('chain_shirt','Camisa de cota de malha','armadura',NULL,NULL,4,4,100,12.5,'{"penalidade_armadura":-2}'::JSONB),
('chainmail','Cota de malha','armadura',NULL,NULL,5,2,150,20,'{"penalidade_armadura":-5}'::JSONB),
('breastplate','Peitoral','armadura',NULL,NULL,5,3,200,15,'{"penalidade_armadura":-4}'::JSONB),
('full_plate','Armadura completa','armadura',NULL, NULL,8,1,1500,25,'{"penalidade_armadura":-6}'::JSONB),
('wooden_shield','Escudo de madeira','escudo',NULL,NULL,2,NULL,7,5,'{"penalidade_armadura":-1}'::JSONB),
('heavy_steel_shield','Escudo pesado de aço','escudo',NULL,NULL,2,NULL,20,7.5,'{"penalidade_armadura":-2}'::JSONB)
ON CONFLICT (id) DO NOTHING;

CREATE OR REPLACE FUNCTION public.equipar_item_srd(
  p_character_id TEXT,
  p_equipment_id TEXT,
  p_equipado BOOLEAN
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_category TEXT;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.characters AS ch
    WHERE ch.id::TEXT = BTRIM(p_character_id) AND ch.user_id = auth.uid()
  ) THEN RAISE EXCEPTION 'A ficha não pertence à sua conta.'; END IF;
  SELECT categoria INTO v_category FROM public.srd_equipment WHERE id = p_equipment_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Equipamento não encontrado.'; END IF;
  IF p_equipado THEN
    UPDATE public.srd_character_equipment AS inventory
    SET equipado = FALSE
    FROM public.srd_equipment AS equipment
    WHERE inventory.character_id = BTRIM(p_character_id)
      AND inventory.equipment_id = equipment.id
      AND equipment.categoria = v_category;
  END IF;
  INSERT INTO public.srd_character_equipment(character_id,equipment_id,quantidade,equipado)
  VALUES (BTRIM(p_character_id),p_equipment_id,1,COALESCE(p_equipado,FALSE))
  ON CONFLICT (character_id,equipment_id)
  DO UPDATE SET equipado = EXCLUDED.equipado;
  RETURN jsonb_build_object('character_id',BTRIM(p_character_id),'equipment_id',p_equipment_id,'equipado',COALESCE(p_equipado,FALSE));
END;
$$;
REVOKE ALL ON FUNCTION public.equipar_item_srd(TEXT,TEXT,BOOLEAN) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.equipar_item_srd(TEXT,TEXT,BOOLEAN) TO authenticated;

CREATE OR REPLACE FUNCTION public.entregar_item_srd(
  p_campaign_id BIGINT,
  p_character_id TEXT,
  p_equipment_id TEXT,
  p_quantidade INTEGER DEFAULT 1
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_role TEXT;
  v_item TEXT;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT role INTO v_role FROM public.members
  WHERE campaign_id = p_campaign_id AND user_id = auth.uid() LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'Somente o Mestre pode entregar equipamento.'; END IF;
  IF p_quantidade IS NULL OR p_quantidade < 1 OR p_quantidade > 99 THEN RAISE EXCEPTION 'Quantidade inválida.'; END IF;
  SELECT id INTO v_item FROM public.srd_equipment WHERE id = p_equipment_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Equipamento não encontrado.'; END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.characters AS ch
    JOIN public.members AS player ON player.campaign_id = ch.campaign_id AND player.user_id = ch.user_id AND player.role = 'PLAYER'
    WHERE ch.id::TEXT = BTRIM(p_character_id) AND ch.campaign_id = p_campaign_id
  ) THEN RAISE EXCEPTION 'A ficha não pertence a um jogador desta campanha.'; END IF;
  INSERT INTO public.srd_character_equipment(character_id,equipment_id,quantidade,equipado)
  VALUES (BTRIM(p_character_id),p_equipment_id,p_quantidade,FALSE)
  ON CONFLICT (character_id,equipment_id)
  DO UPDATE SET quantidade = public.srd_character_equipment.quantidade + EXCLUDED.quantidade;
  RETURN jsonb_build_object('character_id',BTRIM(p_character_id),'equipment_id',v_item,'quantidade',p_quantidade);
END;
$$;
REVOKE ALL ON FUNCTION public.entregar_item_srd(BIGINT,TEXT,TEXT,INTEGER) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.entregar_item_srd(BIGINT,TEXT,TEXT,INTEGER) TO authenticated;


INSERT INTO public.srd_equipment(id,nome,categoria,dano,tipo_dano,bonus_ca,bonus_max_des,custo_po,peso,detalhes)
VALUES ('healing_potion','Poção de cura','consumivel',NULL,NULL,0,NULL,50,0.05,'{"cura":"2d4+2"}'::JSONB)
ON CONFLICT (id) DO NOTHING;

CREATE OR REPLACE FUNCTION public.usar_pocao_cura_srd(p_character_id TEXT,p_equipment_id TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_amount INTEGER;
  v_pv INTEGER;
  v_max INTEGER;
  v_healing INTEGER;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.characters WHERE id::TEXT=BTRIM(p_character_id) AND user_id=auth.uid()) THEN
    RAISE EXCEPTION 'A ficha não pertence à sua conta.';
  END IF;
  SELECT quantidade INTO v_amount FROM public.srd_character_equipment
  WHERE character_id=BTRIM(p_character_id) AND equipment_id=p_equipment_id AND quantidade>0 FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Poção não encontrada na mochila.'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.srd_equipment WHERE id=p_equipment_id AND categoria='consumivel') THEN
    RAISE EXCEPTION 'Este item não pode ser consumido como poção.';
  END IF;
  SELECT pv_atual,pv_max INTO v_pv,v_max FROM public.srd_character_sheets
  WHERE character_id::TEXT=BTRIM(p_character_id) FOR UPDATE;
  IF NOT FOUND OR v_max IS NULL THEN RAISE EXCEPTION 'Ficha SRD sem PV máximo.'; END IF;
  v_healing := (FLOOR(random()*4)::INTEGER+1)+(FLOOR(random()*4)::INTEGER+1)+2;
  UPDATE public.srd_character_sheets SET pv_atual=LEAST(v_max,COALESCE(v_pv,0)+v_healing)
  WHERE character_id::TEXT=BTRIM(p_character_id) RETURNING pv_atual INTO v_pv;
  IF v_amount=1 THEN
    DELETE FROM public.srd_character_equipment WHERE character_id=BTRIM(p_character_id) AND equipment_id=p_equipment_id;
  ELSE
    UPDATE public.srd_character_equipment SET quantidade=quantidade-1
    WHERE character_id=BTRIM(p_character_id) AND equipment_id=p_equipment_id;
  END IF;
  RETURN jsonb_build_object('character_id',BTRIM(p_character_id),'healing_rolled',v_healing,'pv_atual',v_pv,'pv_max',v_max,'quantidade_restante',GREATEST(v_amount-1,0));
END;
$$;
REVOKE ALL ON FUNCTION public.usar_pocao_cura_srd(TEXT,TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.usar_pocao_cura_srd(TEXT,TEXT) TO authenticated;


-- Iniciativa de NPCs/monstros: d20 + bônus DES salvo no token pelo Mestre.
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
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT m.role INTO v_role FROM public.members AS m
  WHERE m.campaign_id=p_campaign_id AND m.user_id=auth.uid() LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'Somente o Mestre da campanha pode iniciar a iniciativa.'; END IF;
  SELECT COALESCE(array_agg(DISTINCT expanded.character_id),ARRAY[]::TEXT[]) INTO v_expected
  FROM unnest(COALESCE(p_expected_character_ids,ARRAY[]::TEXT[])) AS expanded(character_id);
  IF EXISTS (
    SELECT 1 FROM unnest(v_expected) AS requested(character_id)
    WHERE NOT EXISTS (
      SELECT 1 FROM public.characters AS c
      JOIN public.members AS m ON m.campaign_id=c.campaign_id AND m.user_id=c.user_id AND m.role='PLAYER'
      WHERE c.campaign_id=p_campaign_id AND c.id::TEXT=requested.character_id
    )
  ) THEN RAISE EXCEPTION 'A lista inclui personagem que não pertence a um jogador desta campanha.'; END IF;
  SELECT state,cba_data,combat_data INTO v_state,v_cba,v_previous
  FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  IF UPPER(COALESCE(v_state,''))<>'COMBATE' THEN RAISE EXCEPTION 'A iniciativa só pode ser iniciada quando a campanha está em COMBATE.'; END IF;
  IF COALESCE((v_previous->>'active')::BOOLEAN,FALSE)
     OR jsonb_array_length(CASE WHEN jsonb_typeof(v_previous->'expected_character_ids')='array' THEN v_previous->'expected_character_ids' ELSE '[]'::JSONB END)>0 THEN
    RAISE EXCEPTION 'A iniciativa desta rodada já foi iniciada. Encerre e inicie o combate novamente para zerá-la.';
  END IF;
  SELECT COALESCE(jsonb_agg(
    jsonb_build_object('id',rolled.id,'nome',rolled.nome,'valor',rolled.valor,'d20',rolled.d20,'dex_mod',rolled.dex_mod,'is_monster',TRUE,'tipo',rolled.tipo)
    ORDER BY rolled.valor DESC,rolled.nome ASC,rolled.id ASC
  ),'[]'::JSONB) INTO v_existing_gm_entries
  FROM (
    SELECT token.entry->>'id' AS id,
      LEFT(COALESCE(NULLIF(token.entry->>'nome',''),'Criatura'),120) AS nome,
      CASE WHEN token.entry->>'tipo'='monstro' THEN 'monstro' ELSE 'npc' END AS tipo,
      roll.d20,
      CASE WHEN COALESCE(token.entry->>'dexMod','') ~ '^-?[0-9]{1,2}$' THEN (token.entry->>'dexMod')::INTEGER ELSE 0 END AS dex_mod,
      roll.d20 + CASE WHEN COALESCE(token.entry->>'dexMod','') ~ '^-?[0-9]{1,2}$' THEN (token.entry->>'dexMod')::INTEGER ELSE 0 END AS valor
    FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_cba->'tokens')='array' THEN v_cba->'tokens' ELSE '[]'::JSONB END) AS token(entry)
    CROSS JOIN LATERAL (SELECT FLOOR(random()*20)::INTEGER+1 AS d20) AS roll
    WHERE token.entry->>'tipo' IN ('npc','monstro') AND NULLIF(BTRIM(token.entry->>'id'),'') IS NOT NULL
  ) AS rolled;
  IF cardinality(v_expected)=0 AND jsonb_array_length(v_existing_gm_entries)=0 THEN
    RAISE EXCEPTION 'Adicione fichas de jogadores ou NPCs/monstros ao CBA antes de iniciar a iniciativa.';
  END IF;
  v_combat:=jsonb_build_object('turn_order',v_existing_gm_entries,'current_turn',0,'active',cardinality(v_expected)=0,'round',1,'expected_character_ids',to_jsonb(v_expected));
  UPDATE public.campaigns SET combat_data=v_combat WHERE id=p_campaign_id;
  RETURN v_combat;
END;
$$;
REVOKE ALL ON FUNCTION public.iniciar_iniciativa(BIGINT,TEXT[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.iniciar_iniciativa(BIGINT,TEXT[]) TO authenticated;


CREATE OR REPLACE FUNCTION public.alterar_pv_token_cba(
  p_campaign_id BIGINT,
  p_token_id TEXT,
  p_variacao INTEGER,
  p_pv_max INTEGER DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_role TEXT;
  v_scene JSONB;
  v_tokens JSONB;
  v_token JSONB;
  v_index BIGINT;
  v_count INTEGER;
  v_old_hp INTEGER;
  v_max_hp INTEGER;
  v_new_hp INTEGER;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT role INTO v_role FROM public.members WHERE campaign_id=p_campaign_id AND user_id=auth.uid() LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'Somente o Mestre pode ajustar PV de NPCs e monstros.'; END IF;
  IF p_variacao IS NULL OR p_variacao=0 THEN RAISE EXCEPTION 'Informe dano ou cura diferente de zero.'; END IF;
  SELECT cba_data INTO v_scene FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  v_tokens:=CASE WHEN jsonb_typeof(v_scene->'tokens')='array' THEN v_scene->'tokens' ELSE '[]'::JSONB END;
  SELECT count(*)::INTEGER,min(t.ordinality) INTO v_count,v_index
  FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(token,ordinality)
  WHERE t.token->>'id'=BTRIM(p_token_id) AND t.token->>'tipo' IN ('npc','monstro');
  IF v_count<>1 THEN RAISE EXCEPTION 'Token NPC/monstro não encontrado ou duplicado.'; END IF;
  v_token:=v_tokens->(v_index::INTEGER-1);
  v_max_hp:=CASE WHEN COALESCE(v_token->>'maxHp','') ~ '^[1-9][0-9]{0,5}$' THEN (v_token->>'maxHp')::INTEGER ELSE p_pv_max END;
  IF v_max_hp IS NULL OR v_max_hp<1 OR v_max_hp>100000 THEN RAISE EXCEPTION 'Defina um PV máximo inteiro entre 1 e 100000 para esta criatura.'; END IF;
  v_old_hp:=CASE WHEN COALESCE(v_token->>'hp','') ~ '^[0-9]{1,6}$' THEN (v_token->>'hp')::INTEGER ELSE v_max_hp END;
  v_new_hp:=GREATEST(0,LEAST(v_max_hp,v_old_hp+p_variacao));
  v_token:=v_token||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp);
  v_scene:=COALESCE(v_scene,'{}'::JSONB)||jsonb_build_object('tokens',jsonb_set(v_tokens,ARRAY[(v_index-1)::TEXT],v_token,FALSE));
  UPDATE public.campaigns SET cba_data=v_scene WHERE id=p_campaign_id;
  RETURN jsonb_build_object('cba_data',v_scene,'hp',v_new_hp,'max_hp',v_max_hp);
END;
$$;
REVOKE ALL ON FUNCTION public.alterar_pv_token_cba(BIGINT,TEXT,INTEGER,INTEGER) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.alterar_pv_token_cba(BIGINT,TEXT,INTEGER,INTEGER) TO authenticated;

-- Mantém o inventário sem órfãos mesmo quando uma ficha é excluída por outro fluxo autorizado.
CREATE OR REPLACE FUNCTION public.limpar_inventario_srd_ao_excluir_personagem()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
BEGIN
  DELETE FROM public.srd_character_equipment WHERE character_id=OLD.id::TEXT;
  RETURN OLD;
END;
$$;
REVOKE ALL ON FUNCTION public.limpar_inventario_srd_ao_excluir_personagem() FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_limpar_inventario_srd_ao_excluir_personagem ON public.characters;
CREATE TRIGGER trg_limpar_inventario_srd_ao_excluir_personagem
AFTER DELETE ON public.characters
FOR EACH ROW EXECUTE FUNCTION public.limpar_inventario_srd_ao_excluir_personagem();


DROP POLICY IF EXISTS srd_character_equipment_campaign_gm_select ON public.srd_character_equipment;
CREATE POLICY srd_character_equipment_campaign_gm_select
ON public.srd_character_equipment
FOR SELECT TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.characters AS ch
  JOIN public.members AS member ON member.campaign_id=ch.campaign_id
  WHERE ch.id::TEXT=srd_character_equipment.character_id
    AND member.user_id=auth.uid()
    AND member.role='GM'
));


-- Normaliza aliases de localização que podem ter sido carregados no catálogo SRD.
UPDATE public.srd_classes
SET bab_progression=CASE LOWER(BTRIM(bab_progression))
  WHEN 'bom' THEN 'good'
  WHEN 'medio' THEN 'average'
  WHEN 'médio' THEN 'average'
  WHEN 'ruim' THEN 'poor'
  ELSE bab_progression
END
WHERE LOWER(BTRIM(bab_progression)) IN ('bom','medio','médio','ruim');
