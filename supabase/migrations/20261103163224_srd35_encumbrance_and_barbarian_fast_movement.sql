CREATE OR REPLACE FUNCTION public.srd35_deslocamento_personagem(p_character_id text,p_base_speed_m numeric)
RETURNS numeric
LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_attrs JSONB; v_race_id TEXT; v_race_name TEXT; v_size TEXT; v_class_key TEXT;
  v_level INTEGER:=1; v_gold NUMERIC:=0; v_strength INTEGER:=10; v_base_speed NUMERIC:=COALESCE(p_base_speed_m,9);
  v_speed NUMERIC; v_weight_kg NUMERIC:=0; v_heavy_armor BOOLEAN:=FALSE;
  v_medium_heavy_armor BOOLEAN:=FALSE; v_any_armor BOOLEAN:=FALSE; v_is_dwarf BOOLEAN:=FALSE;
  v_heavy_table NUMERIC[]:=ARRAY[5,10,15,20,25,30,35,40,45,50,57.5,65,75,87.5,100,115,130,150,175,200,230,260,300,350,400,460,520,600,700]::NUMERIC[];
  v_table_strength INTEGER; v_decades INTEGER:=0; v_heavy_max NUMERIC; v_light_max NUMERIC;
  v_medium_max NUMERIC; v_size_multiplier NUMERIC:=1; v_load TEXT:='light'; v_size_normalized TEXT;
BEGIN
  SELECT sh.atributos,sh.raca_id,sh.nivel,COALESCE(sh.ouro,0),race.nome,race.tamanho,
         COALESCE(class.class_key,class.id)
    INTO v_attrs,v_race_id,v_level,v_gold,v_race_name,v_size,v_class_key
    FROM public.srd_character_sheets sh
    LEFT JOIN public.srd_races race ON race.id::TEXT=sh.raca_id::TEXT
    LEFT JOIN public.srd_classes class ON class.id::TEXT=sh.classe_id::TEXT
   WHERE sh.character_id::TEXT=BTRIM(p_character_id);
  IF NOT FOUND THEN RETURN v_base_speed; END IF;

  v_strength:=GREATEST(1,COALESCE((v_attrs->>'FOR')::INTEGER,10));
  v_is_dwarf:=v_race_id='anao' OR public.srd35_normalizar_parametro_talento(COALESCE(v_race_name,''))='anao';
  v_size_normalized:=public.srd35_normalizar_parametro_talento(COALESCE(v_size,'medio'));

  -- srd_equipment.peso está em libras no SRD; o Livro do Jogador usa 0,5 kg por libra.
  SELECT COALESCE(SUM(COALESCE(eq.peso,0)*0.5*GREATEST(1,ce.quantidade)),0),
         COALESCE(BOOL_OR(ce.equipado AND armor.kind LIKE 'heavyarmor%'),FALSE),
         COALESCE(BOOL_OR(ce.equipado AND (armor.kind LIKE 'mediumarmor%' OR armor.kind LIKE 'heavyarmor%')),FALSE),
         COALESCE(BOOL_OR(ce.equipado AND armor.kind IN ('lightarmor','mediumarmor','heavyarmor')),FALSE)
    INTO v_weight_kg,v_heavy_armor,v_medium_heavy_armor,v_any_armor
    FROM public.srd_character_equipment ce
    JOIN public.srd_equipment eq ON eq.id=ce.equipment_id
    CROSS JOIN LATERAL (SELECT public.srd35_normalizar_parametro_talento(COALESCE(eq.detalhes->>'category',eq.categoria,'')) AS kind) armor
   WHERE ce.character_id=BTRIM(p_character_id);
  -- 500 PO pesam 5 kg.
  v_weight_kg:=v_weight_kg+(v_gold/100.0);

  v_size_multiplier:=CASE
    WHEN v_size_normalized IN ('minusculo','fine') THEN 0.125
    WHEN v_size_normalized IN ('diminuto','diminutive') THEN 0.25
    WHEN v_size_normalized IN ('miudo','tiny') THEN 0.5
    WHEN v_size_normalized IN ('pequeno','small') THEN 0.75
    WHEN v_size_normalized IN ('grande','large') THEN 2
    WHEN v_size_normalized IN ('enorme','huge') THEN 4
    WHEN v_size_normalized IN ('imenso','gargantuan') THEN 8
    WHEN v_size_normalized='colossal' THEN 16 ELSE 1 END;
  IF v_strength>=30 THEN
    v_decades:=FLOOR((v_strength-20)/10.0)::INTEGER;
    v_table_strength:=v_strength-(10*v_decades);
  ELSE v_table_strength:=v_strength; END IF;
  v_table_strength:=GREATEST(1,LEAST(29,v_table_strength));
  v_heavy_max:=v_heavy_table[v_table_strength]*POWER(4::NUMERIC,v_decades)*v_size_multiplier;
  v_light_max:=FLOOR((v_heavy_max/3.0)*2.0)/2.0;
  v_medium_max:=FLOOR((v_heavy_max*2.0/3.0)*2.0)/2.0;
  IF v_weight_kg>v_medium_max THEN v_load:='heavy';
  ELSIF v_weight_kg>v_light_max THEN v_load:='medium';
  ELSE v_load:='light'; END IF;

  v_speed:=v_base_speed;
  -- Movimento Rápido do Bárbaro: +3 m antes dos ajustes de armadura/carga.
  IF v_class_key='barbarian' AND COALESCE(v_level,1)>=1 AND NOT v_heavy_armor AND v_load<>'heavy' THEN
    v_speed:=v_speed+3;
  END IF;
  -- O deslocamento do anão não é reduzido por armadura média/pesada ou carga média/pesada.
  IF NOT v_is_dwarf AND (v_medium_heavy_armor OR v_load IN ('medium','heavy')) THEN
    IF v_speed>=12 THEN v_speed:=9;
    ELSIF v_speed>=9 THEN v_speed:=6;
    ELSIF v_speed>=6 THEN v_speed:=4.5;
    ELSE v_speed:=GREATEST(1.5,FLOOR((v_speed*0.75)/1.5)*1.5); END IF;
  END IF;
  RETURN ROUND(v_speed,2);
END;
$function$;

CREATE OR REPLACE FUNCTION public.mover_token_player_cba(p_campaign_id bigint, p_character_id text, p_grid_x integer, p_grid_y integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_combat JSONB;
  v_campaign_state TEXT;
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
  v_mover_size_text TEXT;
  v_token_size INTEGER := 1;
  v_raw_speed TEXT;
  v_speed_m NUMERIC;
  v_used_squares INTEGER := 0;
  v_move_squares INTEGER;
  v_total_squares INTEGER;
  v_used_diagonal_steps INTEGER := 0;
  v_segment_diagonal_steps INTEGER := 0;
  v_diagonal_steps INTEGER := 0;
  v_diagonal_extra INTEGER := 0;
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

  SELECT c.cba_data, c.combat_data, c.state INTO v_scene, v_combat, v_campaign_state
  FROM public.campaigns AS c
  WHERE c.id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  v_combat := COALESCE(v_combat,'{}'::JSONB);
  v_active := lower(COALESCE(v_combat->>'active', 'false')) = 'true';
  IF v_active THEN
    v_order := CASE WHEN jsonb_typeof(v_combat->'turn_order') = 'array'
                    THEN v_combat->'turn_order' ELSE '[]'::JSONB END;
    IF jsonb_array_length(v_order) = 0 THEN RAISE EXCEPTION 'A ordem de iniciativa está vazia.'; END IF;
    v_current_turn := CASE WHEN COALESCE(v_combat->>'current_turn', '') ~ '^[0-9]+$'
                           THEN (v_combat->>'current_turn')::INTEGER ELSE 0 END;
    IF v_current_turn >= jsonb_array_length(v_order) THEN RAISE EXCEPTION 'O turno atual da iniciativa é inválido.'; END IF;
    v_entry := v_order->v_current_turn;
    v_current_id := v_entry->>'id';
    IF COALESCE(lower(v_entry->>'is_monster'), 'false') = 'true' THEN RAISE EXCEPTION 'O turno atual pertence a uma criatura controlada pelo Mestre.'; END IF;
    IF v_current_id IS DISTINCT FROM BTRIM(p_character_id) THEN RAISE EXCEPTION 'Somente o personagem cujo turno está ativo pode mover seu token.'; END IF;
  ELSIF UPPER(COALESCE(v_campaign_state,''))='COMBATE' THEN
    RAISE EXCEPTION 'Aguarde a ativação da iniciativa para mover durante o combate.';
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

  SELECT to_jsonb(r)->>'deslocamento', r.tamanho::TEXT INTO v_raw_speed, v_mover_size_text
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
  v_speed_m := public.srd35_deslocamento_personagem(v_character_id,v_speed_m);
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
  v_token_size := CASE
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'colossal%' THEN 5
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'gargantuan%'
      OR public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'imenso%' THEN 4
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'huge%'
      OR public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'enorme%' THEN 3
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'large%'
      OR public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'grande%' THEN 2
    ELSE 1 END;

  IF EXISTS (
    SELECT 1
      FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS q(token, ordinality)
      LEFT JOIN public.characters other_character
        ON other_character.id::TEXT=q.token->>'id' AND other_character.campaign_id=p_campaign_id
      LEFT JOIN public.srd_character_sheets other_sheet
        ON other_sheet.character_id=other_character.id
      LEFT JOIN public.srd_races other_race
        ON other_race.id::TEXT=other_sheet.raca_id::TEXT
      CROSS JOIN LATERAL (
        SELECT
          CASE
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'colossal%' THEN 5
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'gargantuan%'
              OR public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'imenso%' THEN 4
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'huge%'
              OR public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'enorme%' THEN 3
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'large%'
              OR public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'grande%' THEN 2
            ELSE 1
          END AS footprint,
          CASE WHEN COALESCE(q.token->>'gridX','') ~ '^[0-9]{1,3}$' THEN (q.token->>'gridX')::INTEGER ELSE -1 END AS gx,
          CASE WHEN COALESCE(q.token->>'gridY','') ~ '^[0-9]{1,3}$' THEN (q.token->>'gridY')::INTEGER ELSE -1 END AS gy
      ) AS other_space
     WHERE q.ordinality<>v_token_index AND other_space.gx>=0 AND other_space.gy>=0
       AND p_grid_x < other_space.gx+other_space.footprint AND p_grid_x+v_token_size > other_space.gx
       AND p_grid_y < other_space.gy+other_space.footprint AND p_grid_y+v_token_size > other_space.gy
  ) THEN
    RAISE EXCEPTION 'O espaço de destino está ocupado pela área de outro token.';
  END IF;

-- O custo do deslocamento é calculado após recuperar a sequência diagonal da rodada.
  IF v_active THEN
    v_round := CASE WHEN COALESCE(v_combat->>'round', '') ~ '^[0-9]+$'
                    THEN GREATEST(1, (v_combat->>'round')::INTEGER) ELSE 1 END;
    v_usage := CASE WHEN jsonb_typeof(v_combat->'movement_usage') = 'object'
                    THEN v_combat->'movement_usage' ELSE '{}'::JSONB END;
    IF v_usage->>'character_id' = v_character_id
       AND v_usage->>'round' = v_round::TEXT
       AND v_usage->>'current_turn' = v_current_turn::TEXT
       AND COALESCE(v_usage->>'moved_squares', '') ~ '^[0-9]+$' THEN
      v_used_squares := (v_usage->>'moved_squares')::INTEGER;
      IF COALESCE(v_usage->>'diagonal_steps','') ~ '^[0-9]+$' THEN
        v_used_diagonal_steps := (v_usage->>'diagonal_steps')::INTEGER;
      END IF;
    END IF;
    -- D&D 3.5: diagonais alternam custo de 1 e 2 quadrados (5 ft / 10 ft).
    v_segment_diagonal_steps := LEAST(ABS(p_grid_x - v_old_x), ABS(p_grid_y - v_old_y));
    v_diagonal_extra := FLOOR((v_used_diagonal_steps + v_segment_diagonal_steps) / 2.0)::INTEGER
      - FLOOR(v_used_diagonal_steps / 2.0)::INTEGER;
    v_move_squares := GREATEST(ABS(p_grid_x - v_old_x), ABS(p_grid_y - v_old_y)) + v_diagonal_extra;
    v_diagonal_steps := v_used_diagonal_steps + v_segment_diagonal_steps;
    v_total_squares := v_used_squares + v_move_squares;
    v_remaining_m := GREATEST(0::NUMERIC, v_speed_m - (v_total_squares * 1.5));
    IF v_total_squares * 1.5 > v_speed_m THEN
      RAISE EXCEPTION 'Movimento excede o deslocamento restante deste turno (%.1f m restantes).',
        GREATEST(0::NUMERIC, v_speed_m - (v_used_squares * 1.5));
    END IF;
  ELSE
    v_remaining_m := NULL;
  END IF;

  v_new_token := v_entry || jsonb_build_object('gridX', p_grid_x, 'gridY', p_grid_y);
  v_scene := COALESCE(v_scene, '{}'::JSONB) || jsonb_build_object(
    'tokens', jsonb_set(v_tokens, ARRAY[(v_token_index - 1)::TEXT], v_new_token, FALSE)
  );
  IF v_active THEN
    v_combat := v_combat || jsonb_build_object(
      'movement_usage', jsonb_build_object(
        'round', v_round,
        'current_turn', v_current_turn,
        'character_id', v_character_id,
        'moved_squares', v_total_squares,
        'diagonal_steps', v_diagonal_steps
      )
    );
  END IF;
  UPDATE public.campaigns
  SET cba_data = v_scene, combat_data = v_combat
  WHERE id = p_campaign_id;
  RETURN jsonb_build_object(
    'cba_data', v_scene,
    'movement_remaining_m', v_remaining_m
  );
END;
$function$
;

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

  -- A primeira diagonal custa 5 ft; cada segunda diagonal custa 10 ft.
  v_diagonal_steps := LEAST(ABS(p_grid_x - v_old_x), ABS(p_grid_y - v_old_y));
  v_diagonal_extra := FLOOR(v_diagonal_steps / 2.0)::INTEGER;
  v_move_squares := GREATEST(ABS(p_grid_x - v_old_x), ABS(p_grid_y - v_old_y)) + v_diagonal_extra;
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
      'character_id',BTRIM(p_token_id),'moved_squares',v_move_squares,'diagonal_steps',v_diagonal_steps)
  );
  v_token := v_token || jsonb_build_object('gridX', p_grid_x, 'gridY', p_grid_y);
  v_scene := v_scene || jsonb_build_object('tokens', jsonb_set(v_tokens, ARRAY[(v_token_index - 1)::TEXT], v_token, FALSE));
  UPDATE public.campaigns SET cba_data = v_scene, combat_data = v_combat WHERE id = p_campaign_id;
  RETURN jsonb_build_object('cba_data',v_scene,'combat_data',v_combat,
    'movement_remaining_m',GREATEST(0::NUMERIC,v_speed_m-v_movement_used));
END
$function$
;
