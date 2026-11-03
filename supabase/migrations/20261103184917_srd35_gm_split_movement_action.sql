CREATE OR REPLACE FUNCTION public.mover_token_gm_cba_srd(p_campaign_id bigint, p_token_id text, p_grid_x integer, p_grid_y integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
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
  v_token_size_text TEXT;
  v_token_size INTEGER := 1;
  v_speed_text TEXT;
  v_speed_number TEXT;
  v_speed_m NUMERIC;
  v_old_x INTEGER;
  v_old_y INTEGER;
  v_move_squares INTEGER;
  v_diagonal_steps INTEGER := 0;
  v_diagonal_extra INTEGER := 0;
  v_movement_used NUMERIC;
  v_remaining_m NUMERIC;
  v_round INTEGER;
  v_current_turn INTEGER;
  v_economy JSONB;
  v_by_token JSONB;
  v_token_actions JSONB;
  v_movement_usage JSONB;
  v_usage JSONB;
  v_used_squares INTEGER:=0;
  v_total_squares INTEGER;
  v_used_diagonal_steps INTEGER:=0;
  v_segment_diagonal_steps INTEGER:=0;
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
  IF v_actor->>'id' IS DISTINCT FROM BTRIM(p_token_id) THEN
    RAISE EXCEPTION 'O token não está no turno ativo.';
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
  ) THEN RAISE EXCEPTION 'O token de personagem não pertence ao Mestre.'; END IF;
  IF COALESCE(v_token->>'gridX', '') !~ '^[0-9]{1,3}$'
     OR COALESCE(v_token->>'gridY', '') !~ '^[0-9]{1,3}$' THEN
    RAISE EXCEPTION 'A posição atual do token é inválida.';
  END IF;
  v_old_x := (v_token->>'gridX')::INTEGER;
  v_old_y := (v_token->>'gridY')::INTEGER;
  v_token_size_text := COALESCE(v_token->'monsterStats'->>'tamanho',v_token->'monsterStats'->>'size',v_token->>'tamanho');
  IF v_token_type='player' THEN
    SELECT race.tamanho::TEXT INTO v_token_size_text
      FROM public.characters character
      JOIN public.srd_character_sheets sheet ON sheet.character_id=character.id
      JOIN public.srd_races race ON race.id::TEXT=sheet.raca_id::TEXT
     WHERE character.id::TEXT=BTRIM(p_token_id) AND character.campaign_id=p_campaign_id;
  END IF;
  v_token_size := CASE
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_token_size_text,'')) LIKE 'colossal%' THEN 5
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_token_size_text,'')) LIKE 'gargantuan%'
      OR public.srd35_normalizar_parametro_talento(COALESCE(v_token_size_text,'')) LIKE 'imenso%' THEN 4
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_token_size_text,'')) LIKE 'huge%'
      OR public.srd35_normalizar_parametro_talento(COALESCE(v_token_size_text,'')) LIKE 'enorme%' THEN 3
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_token_size_text,'')) LIKE 'large%'
      OR public.srd35_normalizar_parametro_talento(COALESCE(v_token_size_text,'')) LIKE 'grande%' THEN 2
    ELSE 1 END;

  IF EXISTS (
    SELECT 1
      FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS other_token(value, ordinality)
      LEFT JOIN public.characters other_character
        ON other_character.id::TEXT=other_token.value->>'id' AND other_character.campaign_id=p_campaign_id
      LEFT JOIN public.srd_character_sheets other_sheet
        ON other_sheet.character_id=other_character.id
      LEFT JOIN public.srd_races other_race
        ON other_race.id::TEXT=other_sheet.raca_id::TEXT
      CROSS JOIN LATERAL (
        SELECT
          CASE
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(other_token.value->'monsterStats'->>'tamanho',other_token.value->'monsterStats'->>'size',other_token.value->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'colossal%' THEN 5
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(other_token.value->'monsterStats'->>'tamanho',other_token.value->'monsterStats'->>'size',other_token.value->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'gargantuan%'
              OR public.srd35_normalizar_parametro_talento(COALESCE(other_token.value->'monsterStats'->>'tamanho',other_token.value->'monsterStats'->>'size',other_token.value->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'imenso%' THEN 4
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(other_token.value->'monsterStats'->>'tamanho',other_token.value->'monsterStats'->>'size',other_token.value->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'huge%'
              OR public.srd35_normalizar_parametro_talento(COALESCE(other_token.value->'monsterStats'->>'tamanho',other_token.value->'monsterStats'->>'size',other_token.value->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'enorme%' THEN 3
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(other_token.value->'monsterStats'->>'tamanho',other_token.value->'monsterStats'->>'size',other_token.value->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'large%'
              OR public.srd35_normalizar_parametro_talento(COALESCE(other_token.value->'monsterStats'->>'tamanho',other_token.value->'monsterStats'->>'size',other_token.value->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'grande%' THEN 2
            ELSE 1
          END AS footprint,
          CASE WHEN COALESCE(other_token.value->>'gridX','') ~ '^[0-9]{1,3}$' THEN (other_token.value->>'gridX')::INTEGER ELSE -1 END AS gx,
          CASE WHEN COALESCE(other_token.value->>'gridY','') ~ '^[0-9]{1,3}$' THEN (other_token.value->>'gridY')::INTEGER ELSE -1 END AS gy
      ) AS other_space
     WHERE other_token.ordinality<>v_token_index AND other_space.gx>=0 AND other_space.gy>=0
       AND p_grid_x < other_space.gx+other_space.footprint AND p_grid_x+v_token_size > other_space.gx
       AND p_grid_y < other_space.gy+other_space.footprint AND p_grid_y+v_token_size > other_space.gy
  ) THEN RAISE EXCEPTION 'O espaço de destino está ocupado pela área de outro token.'; END IF;

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
      AND character.campaign_id = p_campaign_id;
  END IF;
  IF v_speed_text IS NULL OR BTRIM(v_speed_text) = '' THEN
    v_speed_m := 9;
  ELSE
    v_speed_number := substring(v_speed_text FROM '([0-9]+([.][0-9]+)?)');
    IF v_speed_number IS NULL THEN RAISE EXCEPTION 'Não foi possível ler o deslocamento de %.', v_token->>'nome'; END IF;
    v_speed_m := v_speed_number::NUMERIC;
    IF LOWER(v_speed_text) ~ '(ft|feet|foot|p[eé]s|pé)' THEN v_speed_m := v_speed_m * 0.3048; END IF;
  END IF;
  IF v_token_type='player' THEN
    v_speed_m:=public.srd35_deslocamento_personagem(BTRIM(p_token_id),v_speed_m);
  END IF;

  -- D&D 3.5: permite dividir a ação de movimento antes/depois da ação padrão,
  -- acumulando distância e alternância diagonal durante o mesmo turno.
  v_round := CASE WHEN COALESCE(v_combat->>'round', '') ~ '^[0-9]+$'
                  THEN GREATEST(1, (v_combat->>'round')::INTEGER) ELSE 1 END;
  v_usage := CASE WHEN jsonb_typeof(v_combat->'movement_usage')='object'
                  THEN v_combat->'movement_usage' ELSE '{}'::JSONB END;
  IF v_usage->>'character_id'=BTRIM(p_token_id)
     AND v_usage->>'round'=v_round::TEXT
     AND v_usage->>'current_turn'=v_current_turn::TEXT
     AND COALESCE(v_usage->>'moved_squares','') ~ '^[0-9]+$' THEN
    v_used_squares:=(v_usage->>'moved_squares')::INTEGER;
    IF COALESCE(v_usage->>'diagonal_steps','') ~ '^[0-9]+$' THEN
      v_used_diagonal_steps:=(v_usage->>'diagonal_steps')::INTEGER;
    END IF;
  END IF;
  v_segment_diagonal_steps:=LEAST(ABS(p_grid_x-v_old_x),ABS(p_grid_y-v_old_y));
  v_diagonal_extra:=FLOOR((v_used_diagonal_steps+v_segment_diagonal_steps)/2.0)::INTEGER
    - FLOOR(v_used_diagonal_steps/2.0)::INTEGER;
  v_move_squares:=GREATEST(ABS(p_grid_x-v_old_x),ABS(p_grid_y-v_old_y))+v_diagonal_extra;
  v_diagonal_steps:=v_used_diagonal_steps+v_segment_diagonal_steps;
  v_total_squares:=v_used_squares+v_move_squares;
  v_movement_used:=v_total_squares*1.5;
  v_remaining_m:=GREATEST(0::NUMERIC,v_speed_m-v_movement_used);
  IF v_movement_used>v_speed_m THEN
    RAISE EXCEPTION 'Movimento excede o deslocamento restante deste turno (%.1f m restantes).',
      GREATEST(0::NUMERIC,v_speed_m-(v_used_squares*1.5));
  END IF;
  v_economy := v_combat->'action_economy';
  IF jsonb_typeof(v_economy) = 'object'
     AND COALESCE(v_economy->>'round', '') = v_round::TEXT
     AND jsonb_typeof(v_economy->'by_character') = 'object' THEN
    v_by_token := v_economy->'by_character';
  ELSE v_by_token := '{}'::JSONB; END IF;
  v_token_actions := CASE WHEN jsonb_typeof(v_by_token->BTRIM(p_token_id)) = 'object'
                          THEN v_by_token->BTRIM(p_token_id) ELSE '{}'::JSONB END;
  IF COALESCE(v_token_actions->>'movimento', 'false') = 'true' AND v_used_squares=0 THEN
    RAISE EXCEPTION 'A ação de movimento deste token já foi usada no turno.';
  END IF;
  v_token_actions := v_token_actions || jsonb_build_object('movimento', TRUE);
  v_by_token := jsonb_set(v_by_token, ARRAY[BTRIM(p_token_id)], v_token_actions, TRUE);
  v_combat := v_combat || jsonb_build_object(
    'action_economy', jsonb_build_object('round', v_round, 'by_character', v_by_token),
    'movement_usage', jsonb_build_object('round',v_round,'current_turn',v_current_turn,
      'character_id',BTRIM(p_token_id),'moved_squares',v_total_squares,'diagonal_steps',v_diagonal_steps)
  );
  v_token := v_token || jsonb_build_object('gridX', p_grid_x, 'gridY', p_grid_y);
  v_scene := v_scene || jsonb_build_object('tokens', jsonb_set(v_tokens, ARRAY[(v_token_index - 1)::TEXT], v_token, FALSE));
  UPDATE public.campaigns SET cba_data = v_scene, combat_data = v_combat WHERE id = p_campaign_id;
  RETURN jsonb_build_object('cba_data',v_scene,'combat_data',v_combat,
    'movement_remaining_m',GREATEST(0::NUMERIC,v_speed_m-v_movement_used));
END
$function$
;
