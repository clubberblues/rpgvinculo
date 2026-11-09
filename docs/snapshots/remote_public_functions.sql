-- REMOTE FUNCTION EXPORT
-- Project: grrgwxcagvvafdmzsmro
-- Captured: 2026-11-09
-- Schema: public
-- Count: 225
-- Source: pg_get_functiondef; definitions only, not a restore script.
-- Owners, grants, types, tables, triggers, policies and dependency order are separate.

-- _srd35_attr(p_doc jsonb, p_keys text[])
CREATE OR REPLACE FUNCTION public._srd35_attr(p_doc jsonb, p_keys text[])
 RETURNS text
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE k text; v text; nested_key text; pair record;
BEGIN
  IF p_doc IS NULL THEN RETURN NULL; END IF;
  FOREACH k IN ARRAY p_keys LOOP
    SELECT value INTO v FROM jsonb_each_text(p_doc) AS e(key,value)
      WHERE lower(e.key)=lower(k) LIMIT 1;
    IF v IS NOT NULL AND btrim(v) <> '' THEN RETURN v; END IF;
  END LOOP;
  FOREACH nested_key IN ARRAY ARRAY['atributos','abilities','stats','ability_scores','character'] LOOP
    IF jsonb_typeof(p_doc -> nested_key) = 'object' THEN
      FOREACH k IN ARRAY p_keys LOOP
        SELECT value INTO v FROM jsonb_each_text(p_doc -> nested_key) AS e(key,value)
          WHERE lower(e.key)=lower(k) LIMIT 1;
        IF v IS NOT NULL AND btrim(v) <> '' THEN RETURN v; END IF;
      END LOOP;
    END IF;
    -- Attribute JSON may itself be wrapped in Portuguese/English nesting.
    IF jsonb_typeof(p_doc -> nested_key) = 'object' THEN
      FOR pair IN SELECT value FROM jsonb_each(p_doc -> nested_key) WHERE jsonb_typeof(value)='object' LOOP
        FOREACH k IN ARRAY p_keys LOOP
          SELECT value INTO v FROM jsonb_each_text(pair.value) AS e(key,value)
            WHERE lower(e.key)=lower(k) LIMIT 1;
          IF v IS NOT NULL AND btrim(v) <> '' THEN RETURN v; END IF;
        END LOOP;
      END LOOP;
    END IF;
  END LOOP;
  RETURN NULL;
END
$function$
;

-- _srd35_character_class_level(p_character_id text, p_class_key text, p_primary_class_id text, p_total_level integer)
CREATE OR REPLACE FUNCTION public._srd35_character_class_level(p_character_id text, p_class_key text, p_primary_class_id text, p_total_level integer)
 RETURNS integer
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
DECLARE
  v_level integer;
  v_primary_key text;
BEGIN
  SELECT MAX(cl.class_level)::integer INTO v_level
  FROM public.srd_character_class_levels cl
  JOIN public.srd_classes cls ON cls.id=cl.class_id
  WHERE cl.character_id::text=BTRIM(p_character_id)
    AND public._srd35_class_key(cls.nome)=p_class_key;
  IF v_level IS NOT NULL THEN RETURN v_level; END IF;

  SELECT public._srd35_class_key(cls.nome) INTO v_primary_key
  FROM public.srd_classes cls WHERE cls.id=p_primary_class_id;
  IF v_primary_key=p_class_key THEN RETURN GREATEST(0,COALESCE(p_total_level,0)); END IF;
  RETURN 0;
END;
$function$
;

-- _srd35_class_key(p_value text)
CREATE OR REPLACE FUNCTION public._srd35_class_key(p_value text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE PARALLEL SAFE
 SET search_path TO 'pg_catalog', 'public'
AS $function$
  SELECT CASE translate(lower(trim(coalesce(p_value,''))), 'áéíóúãõâêôç', 'aeiouaoaeoc')
    WHEN 'wizard' THEN 'wizard' WHEN 'mago' THEN 'wizard'
    WHEN 'sorcerer' THEN 'sorcerer' WHEN 'feiticeiro' THEN 'sorcerer'
    WHEN 'cleric' THEN 'cleric' WHEN 'clerigo' THEN 'cleric' WHEN 'sacerdote' THEN 'cleric'
    WHEN 'druid' THEN 'druid' WHEN 'druida' THEN 'druid'
    WHEN 'bard' THEN 'bard' WHEN 'bardo' THEN 'bard'
    WHEN 'paladin' THEN 'paladin' WHEN 'paladino' THEN 'paladin'
    WHEN 'ranger' THEN 'ranger' WHEN 'patrulheiro' THEN 'ranger'
    ELSE NULL
  END
$function$
;

-- _srd35_school_key(p_school text)
CREATE OR REPLACE FUNCTION public._srd35_school_key(p_school text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO 'pg_catalog'
AS $function$
select case
when lower(coalesce(p_school,'')) like 'abjur%' then 'abjuration'
when lower(coalesce(p_school,'')) like 'conjur%' then 'conjuration'
when lower(coalesce(p_school,'')) like 'divin%' or lower(coalesce(p_school,'')) like 'adivin%' then 'divination'
when lower(coalesce(p_school,'')) like 'enchant%' or lower(coalesce(p_school,'')) like 'encant%' then 'enchantment'
when lower(coalesce(p_school,'')) like 'evoc%' then 'evocation'
when lower(coalesce(p_school,'')) like 'illus%' then 'illusion'
when lower(coalesce(p_school,'')) like 'necrom%' then 'necromancy'
when lower(coalesce(p_school,'')) like 'transmut%' then 'transmutation'
when lower(coalesce(p_school,'')) like 'universal%' then 'universal'
else null end
$function$
;

-- _srd35_slots(p_class text, p_level integer, p_score integer, p_circle integer)
CREATE OR REPLACE FUNCTION public._srd35_slots(p_class text, p_level integer, p_score integer, p_circle integer)
 RETURNS integer
 LANGUAGE plpgsql
 STABLE
 SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE base_slots integer; ability_mod integer; bonus_slots integer := 0;
BEGIN
  IF p_level < 1 OR p_level > 20 OR p_circle < 0 OR p_circle > 9 THEN RETURN 0; END IF;
  SELECT (slots_by_level -> (p_level-1) ->> p_circle)::integer
    INTO base_slots FROM public.srd_spell_progressions WHERE class_key=p_class;
  base_slots := coalesce(base_slots,0);
  IF p_circle > 0 AND p_score IS NOT NULL THEN
    ability_mod := floor((p_score-10)::numeric/2)::integer;
    IF ability_mod >= p_circle THEN
      bonus_slots := floor((ability_mod-p_circle)::numeric/4)::integer+1;
    END IF;
  END IF;
  -- Domain slots are tracked separately in srd_character_sheets.magias_preparadas.dominio_preparadas.
  RETURN base_slots+bonus_slots;
END
$function$
;

-- _srd35_spell_class_ok(p_classes text[], p_class text)
CREATE OR REPLACE FUNCTION public._srd35_spell_class_ok(p_classes text[], p_class text)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE PARALLEL SAFE
 SET search_path TO 'pg_catalog', 'public'
AS $function$
  SELECT coalesce(bool_or(public._srd35_class_key(c)=p_class),false)
    FROM unnest(coalesce(p_classes,ARRAY[]::text[])) AS u(c)
$function$
;

-- _srd35_spell_level_for_class(p_levels text, p_class_key text, p_fallback integer)
CREATE OR REPLACE FUNCTION public._srd35_spell_level_for_class(p_levels text, p_class_key text, p_fallback integer DEFAULT 0)
 RETURNS integer
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
DECLARE
  v_key text:=lower(COALESCE(p_class_key,''));
  v_pattern text;
  v_match text[];
BEGIN
  v_pattern:=CASE v_key
    WHEN 'wizard' THEN '(^|,)[[:space:]]*(wiz|sor/wiz)[[:space:]]+([0-9]+)'
    WHEN 'sorcerer' THEN '(^|,)[[:space:]]*(sor|sor/wiz)[[:space:]]+([0-9]+)'
    WHEN 'bard' THEN '(^|,)[[:space:]]*brd[[:space:]]+([0-9]+)'
    WHEN 'cleric' THEN '(^|,)[[:space:]]*clr[[:space:]]+([0-9]+)'
    WHEN 'druid' THEN '(^|,)[[:space:]]*drd[[:space:]]+([0-9]+)'
    WHEN 'paladin' THEN '(^|,)[[:space:]]*pal[[:space:]]+([0-9]+)'
    WHEN 'ranger' THEN '(^|,)[[:space:]]*rgr[[:space:]]+([0-9]+)'
    ELSE NULL
  END;
  IF v_pattern IS NOT NULL THEN
    v_match:=regexp_match(lower(COALESCE(p_levels,'')),v_pattern);
    IF v_match IS NOT NULL THEN
      RETURN v_match[array_length(v_match,1)]::integer;
    END IF;
  END IF;
  RETURN GREATEST(0,COALESCE(p_fallback,0));
END;
$function$
;

-- add_monster_to_scene(cid bigint, p_monster text, p_x integer, p_y integer)
CREATE OR REPLACE FUNCTION public.add_monster_to_scene(cid bigint, p_monster text, p_x integer, p_y integer)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE m public.srd_monsters; mi_id bigint; token_id bigint; n integer;
BEGIN
  PERFORM priv.need_gm(cid);
  SELECT * INTO m FROM public.srd_monsters WHERE id=p_monster;
  IF NOT FOUND THEN RAISE EXCEPTION 'Monstro SRD inexistente.'; END IF;
  IF p_x IS NULL OR p_y IS NULL OR p_x<0 OR p_y<0 THEN RAISE EXCEPTION 'Posição inválida.'; END IF;
  SELECT count(*)+1 INTO n FROM public.monster_instances WHERE campaign_id=cid AND monster_id=p_monster;
  INSERT INTO public.monster_instances(campaign_id,monster_id,rotulo,hp_atual,hp_max,visivel,estado)
  VALUES(cid,p_monster,m.nome||' #'||n,coalesce(m.pv,1),coalesce(m.pv,1),true,'{}'::jsonb)
  RETURNING id INTO mi_id;
  INSERT INTO public.tokens(campaign_id,monster_instance_id,col,row,visivel)
  VALUES(cid,mi_id,p_x,p_y,true) RETURNING id INTO token_id;
  PERFORM priv.log(cid,'MONSTRO_ADICIONADO',jsonb_build_object('token',token_id,'monstro',p_monster,'por',auth.uid()));
  RETURN token_id;
END $function$
;

-- add_owner_as_gm()
CREATE OR REPLACE FUNCTION public.add_owner_as_gm()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
begin
  insert into members (campaign_id, user_id, role)
  values (new.id, new.owner_id, 'GM')
  on conflict do nothing;
  return new;
end $function$
;

-- adicionar_combatente_iniciativa(p_campaign_id bigint, p_combatente_id text, p_nome text, p_valor integer, p_tipo text)
CREATE OR REPLACE FUNCTION public.adicionar_combatente_iniciativa(p_campaign_id bigint, p_combatente_id text, p_nome text, p_valor integer, p_tipo text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
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
$function$
;

-- adicionar_token_cba(p_campaign_id bigint, p_token jsonb)
CREATE OR REPLACE FUNCTION public.adicionar_token_cba(p_campaign_id bigint, p_token jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
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
$function$
;

-- adicionar_token_cba_completo(p_campaign_id bigint, p_token jsonb)
CREATE OR REPLACE FUNCTION public.adicionar_token_cba_completo(p_campaign_id bigint, p_token jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_scene jsonb;
  v_key text;
  v_id text;
  v_extra jsonb;
  v_base_ac numeric;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF jsonb_typeof(p_token) IS DISTINCT FROM 'object' THEN
    RAISE EXCEPTION 'O token enviado é inválido.';
  END IF;

  -- The existing routine validates GM membership, token identity, and free grid cell.
  v_scene := public.adicionar_token_cba(p_campaign_id, p_token);
  v_key := LEFT(BTRIM(COALESCE(p_token->>'key','')),160);
  v_id := LEFT(BTRIM(COALESCE(p_token->>'id','')),120);
  v_base_ac := CASE WHEN COALESCE(p_token->>'ac','') ~ '^[0-9]+(\.[0-9]+)?$'
    THEN (p_token->>'ac')::numeric ELSE NULL END;

  v_extra := jsonb_build_object(
    'monsterId', p_token->'monsterId',
    'monsterStats', CASE WHEN jsonb_typeof(p_token->'monsterStats')='object' THEN p_token->'monsterStats' ELSE NULL END,
    'srdSourceUrl', CASE WHEN COALESCE(p_token->>'srdSourceUrl','') ~* '^https?://' THEN p_token->'srdSourceUrl' ELSE '""'::jsonb END,
    'hp', CASE WHEN COALESCE(p_token->>'hp','') ~ '^-?[0-9]+$' THEN to_jsonb(GREATEST(0,(p_token->>'hp')::integer)) ELSE 'null'::jsonb END,
    'maxHp', CASE WHEN COALESCE(p_token->>'maxHp','') ~ '^[0-9]+$' THEN to_jsonb(GREATEST(1,(p_token->>'maxHp')::integer)) ELSE 'null'::jsonb END,
    'dexMod', CASE WHEN COALESCE(p_token->>'dexMod','') ~ '^-?[0-9]+$' THEN to_jsonb(GREATEST(-20,LEAST(20,(p_token->>'dexMod')::integer))) ELSE 'null'::jsonb END,
    'ac', COALESCE(to_jsonb(v_base_ac),'null'::jsonb),
    'baseAc', COALESCE(to_jsonb(v_base_ac),'null'::jsonb),
    'sourceCharacterId', p_token->'sourceCharacterId',
    'attackBonus', p_token->'attackBonus',
    'damageDice', p_token->'damageDice',
    'spellState', CASE WHEN jsonb_typeof(p_token->'spellState')='object' THEN p_token->'spellState' ELSE NULL END
  );
  UPDATE public.campaigns c
  SET cba_data = jsonb_set(c.cba_data, '{tokens}',
    (SELECT jsonb_agg(CASE WHEN t->>'key'=v_key AND t->>'id'=v_id THEN t || v_extra ELSE t END ORDER BY ord)
     FROM jsonb_array_elements(c.cba_data->'tokens') WITH ORDINALITY AS e(t,ord)), true)
  WHERE c.id=p_campaign_id
  RETURNING c.cba_data INTO v_scene;
  IF v_scene IS NULL THEN RAISE EXCEPTION 'A cena não foi atualizada.'; END IF;
  RETURN v_scene;
END;
$function$
;

-- alterar_pv_personagem(p_campaign_id bigint, p_character_id text, p_variacao integer)
CREATE OR REPLACE FUNCTION public.alterar_pv_personagem(p_campaign_id bigint, p_character_id text, p_variacao integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  v_owner UUID;
  v_campaign_id BIGINT;
  v_pv_atual INTEGER;
  v_pv_max INTEGER;
  v_pv_novo INTEGER;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF p_variacao IS NULL OR p_variacao = 0 THEN
    RAISE EXCEPTION 'A variação de PV é obrigatória.';
  END IF;

  SELECT c.user_id, c.campaign_id, s.pv_atual, s.pv_max
    INTO v_owner, v_campaign_id, v_pv_atual, v_pv_max
    FROM public.characters AS c
    JOIN public.srd_character_sheets AS s
      ON s.character_id::TEXT = c.id::TEXT
   WHERE c.id::TEXT = BTRIM(p_character_id)
   FOR UPDATE OF s;

  IF NOT FOUND OR v_campaign_id IS DISTINCT FROM p_campaign_id THEN
    RAISE EXCEPTION 'Personagem SRD não encontrado nesta campanha.';
  END IF;

  IF v_owner IS DISTINCT FROM auth.uid()
     AND NOT (
       public.my_role(p_campaign_id) = 'GM'
       OR EXISTS (
         SELECT 1
           FROM public.campaigns AS campaign
          WHERE campaign.id = p_campaign_id
            AND campaign.owner_id = auth.uid()
       )
     ) THEN
    RAISE EXCEPTION 'Somente o dono da ficha ou o Mestre desta campanha pode ajustar os PV.';
  END IF;

  IF v_pv_max IS NULL OR v_pv_max < 1 THEN
    RAISE EXCEPTION 'A ficha não possui um PV máximo válido.';
  END IF;

  v_pv_novo := GREATEST(
    0,
    LEAST(v_pv_max, COALESCE(v_pv_atual, v_pv_max) + p_variacao)
  );

  UPDATE public.srd_character_sheets
     SET pv_atual = v_pv_novo
   WHERE character_id::TEXT = BTRIM(p_character_id);

  RETURN jsonb_build_object(
    'character_id', BTRIM(p_character_id),
    'pv_atual', v_pv_novo,
    'pv_max', v_pv_max,
    'variacao_solicitada', p_variacao
  );
END;
$function$
;

-- alterar_pv_token_cba(p_campaign_id bigint, p_token_id text, p_variacao integer, p_pv_max integer)
CREATE OR REPLACE FUNCTION public.alterar_pv_token_cba(p_campaign_id bigint, p_token_id text, p_variacao integer, p_pv_max integer DEFAULT NULL::integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_scene jsonb;
  v_tokens jsonb;
  v_token jsonb;
  v_hp integer;
  v_max integer;
  v_found boolean := false;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.members m
    WHERE m.campaign_id=p_campaign_id AND m.user_id=auth.uid() AND m.role='GM'
  ) THEN RAISE EXCEPTION 'Somente o Mestre pode alterar PV dos tokens.'; END IF;

  SELECT cba_data INTO v_scene
  FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  v_tokens := CASE WHEN jsonb_typeof(v_scene->'tokens')='array' THEN v_scene->'tokens' ELSE '[]'::jsonb END;
  SELECT t INTO v_token FROM jsonb_array_elements(v_tokens) AS x(t)
  WHERE t->>'id'=p_token_id AND COALESCE(t->>'tipo','') IN ('npc','monstro')
  LIMIT 1;
  IF NOT FOUND THEN RAISE EXCEPTION 'Token não encontrado ou não é uma criatura controlada pelo Mestre.'; END IF;

  v_max := COALESCE(p_pv_max, NULLIF(v_token->>'maxHp','')::integer, NULLIF(v_token->>'hp','')::integer, 1);
  v_max := GREATEST(1,LEAST(100000,v_max));
  v_hp := COALESCE(NULLIF(v_token->>'hp','')::integer,v_max);
  IF v_hp<=-10 OR EXISTS (SELECT 1 FROM public.srd_campaign_conditions cc WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='token' AND cc.target_id=p_token_id AND cc.condition_id='dead' AND cc.active=true) THEN RAISE EXCEPTION 'Uma criatura morta não pode ser recuperada por ajuste comum de PV.'; END IF;
  v_hp := GREATEST(-10,LEAST(v_max,v_hp+COALESCE(p_variacao,0)));
  SELECT jsonb_agg(CASE WHEN t->>'id'=p_token_id AND COALESCE(t->>'tipo','') IN ('npc','monstro')
    THEN t || jsonb_build_object('hp',v_hp,'maxHp',v_max) ELSE t END ORDER BY ord)
  INTO v_tokens FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS e(t,ord);
  v_scene := jsonb_set(v_scene,'{tokens}',COALESCE(v_tokens,'[]'::jsonb),true);
  UPDATE public.campaigns SET cba_data=v_scene WHERE id=p_campaign_id;
  PERFORM priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,v_hp,v_max,(p_variacao>0 AND EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='token' AND cc.target_id=p_token_id AND cc.condition_id='stable' AND cc.active=true)));
  RETURN jsonb_build_object('cba_data',v_scene,'hp',v_hp,'max_hp',v_max);
END;
$function$
;

-- alternar_estado_campanha(p_campaign_id bigint, p_novo_estado text)
CREATE OR REPLACE FUNCTION public.alternar_estado_campanha(p_campaign_id bigint, p_novo_estado text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_role text;
  v_estado_atual text;
  v_novo_estado text;
  v_rage record;
  v_rage_token record;
  v_combat jsonb:=jsonb_build_object(
    'turn_order','[]'::jsonb,'current_turn',0,'active',false,'round',1,
    'expected_character_ids','[]'::jsonb
  );
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT m.role INTO v_role FROM public.members m
   WHERE m.campaign_id=p_campaign_id AND m.user_id=auth.uid() LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre da campanha pode alternar o estado.';
  END IF;
  v_novo_estado:=UPPER(BTRIM(COALESCE(p_novo_estado,'')));
  IF v_novo_estado NOT IN ('EXPLORACAO','COMBATE') THEN
    RAISE EXCEPTION 'Estado inválido; use EXPLORACAO ou COMBATE.';
  END IF;
  SELECT UPPER(COALESCE(NULLIF(BTRIM(state),''),'EXPLORACAO'))
    INTO v_estado_atual FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  IF v_estado_atual=v_novo_estado THEN
    RAISE EXCEPTION 'A mesa já está em %.',v_novo_estado;
  END IF;

  IF v_estado_atual='COMBATE' AND v_novo_estado='EXPLORACAO' THEN
    FOR v_rage IN
      SELECT target_id FROM public.srd_campaign_effects
       WHERE campaign_id=p_campaign_id AND target_kind='character'
         AND active=true AND effect_data->>'source_feature'='barbarian_rage'
       FOR UPDATE
    LOOP
      PERFORM priv.srd_end_barbarian_rage(p_campaign_id,v_rage.target_id,false);
    END LOOP;

    -- NPCs linked to source sheets store rage on their scene token, not on a character target.
    FOR v_rage_token IN
      SELECT target_id FROM public.srd_campaign_effects
       WHERE campaign_id=p_campaign_id AND target_kind='token'
         AND active=true AND effect_data->>'source_feature'='barbarian_rage'
       FOR UPDATE
    LOOP
      PERFORM priv.srd_end_barbarian_rage_token(p_campaign_id,v_rage_token.target_id,false);
    END LOOP;

    UPDATE public.srd_campaign_conditions
       SET active=false
     WHERE campaign_id=p_campaign_id AND active=true
       AND notes->>'source_feature'='barbarian_rage'
       AND condition_id IN ('fatigued','exhausted');
  END IF;

  IF v_estado_atual='COMBATE' AND v_novo_estado='EXPLORACAO' THEN
    UPDATE priv.srd_aoo_attacks a SET status='cancelled'
    WHERE a.pending_id IN (SELECT p.pending_id FROM priv.srd_aoo_pending_movements p
      WHERE p.campaign_id=p_campaign_id AND p.status IN ('waiting_reactions','ready_to_commit'))
      AND a.status IN ('awaiting_attack_roll','awaiting_critical_confirmation','awaiting_damage');
    UPDATE priv.srd_aoo_pending_movements p
    SET status='expired',cancelled_at=now(),updated_at=now(),
      pending_reactions=coalesce((SELECT jsonb_agg(
        CASE WHEN r.value->>'status' IN ('waiting','reserved','attack_started','hit_pending_damage')
          THEN r.value||jsonb_build_object('status','skipped','skip_reason','combat_ended')
          ELSE r.value END ORDER BY r.ordinality)
        FROM jsonb_array_elements(p.pending_reactions) WITH ORDINALITY r(value,ordinality)),'[]'::jsonb)
    WHERE p.campaign_id=p_campaign_id AND p.status IN ('waiting_reactions','ready_to_commit');
  END IF;
  IF v_estado_atual='COMBATE' AND v_novo_estado='EXPLORACAO' THEN
    PERFORM priv.srd_clear_combat_flatfooted_all(p_campaign_id);
  END IF;
  UPDATE public.campaigns SET state=v_novo_estado,combat_data=v_combat WHERE id=p_campaign_id;
  RETURN jsonb_build_object('state',v_novo_estado,'combat_data',v_combat);
END;
$function$
;

-- answer_roll(p_id bigint, p_d20 integer)
CREATE OR REPLACE FUNCTION public.answer_roll(p_id bigint, p_d20 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare r public.roll_requests; s public.character_sheets; c public.characters;
        mod int := 0; total int;
begin
  if p_d20 is null or p_d20 < 1 or p_d20 > 20 then raise exception 'd20 fora do intervalo.'; end if;
  select * into r from public.roll_requests where id = p_id for update;
  if not found then raise exception 'Pedido inexistente.'; end if;
  if r.to_id is distinct from auth.uid() then raise exception 'Este pedido não é seu.'; end if;
  if r.status <> 'PENDENTE' then raise exception 'Pedido já respondido.'; end if;

  select c0.* into c from public.characters c0
    where c0.campaign_id = r.campaign_id and c0.user_id = auth.uid();
  if found then
    select * into s from public.character_sheets where character_id = c.id;
    if s.character_id is not null and r.atributo is not null then
      mod := coalesce((s.atributos->>r.atributo)::int, 0);
    end if;
  end if;

  total := p_d20 + mod;

  update public.roll_requests
     set status = 'RESPONDIDO', d20 = p_d20, total = total, resposta_em = now()
   where id = p_id;

  insert into public.roll_log(campaign_id, tipo, autor_id, expressao, d20, total, resultado, detalhes)
  values (r.campaign_id,
          case r.kind when 'INICIATIVA' then 'INICIATIVA' when 'RESISTENCIA' then 'RESISTENCIA' else 'PERICIA' end,
          auth.uid(), coalesce(r.atributo, '') || ' d20+' || mod, p_d20, total, 'RESPOSTA',
          jsonb_build_object('pedido', p_id, 'label', r.label, 'cd', r.cd, 'mod', mod));

  perform priv.log(r.campaign_id, 'ROLAGEM_RESPONDIDA',
    jsonb_build_object('pedido', p_id, 'label', r.label, 'd20', p_d20, 'mod', mod, 'total', total, 'cd', r.cd));

  return jsonb_build_object('ok', true, 'd20', p_d20, 'mod', mod, 'total', total, 'cd', r.cd);
end $function$
;

-- aplicar_dano_ataque_iterativo_npc_srd(p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid, p_sneak_damage_rolls integer[])
CREATE OR REPLACE FUNCTION public.aplicar_dano_ataque_iterativo_npc_srd(p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid, p_sneak_damage_rolls integer[])
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO ''
AS $function$ select priv.npc_aplicar_dano_ataque_iterativo_impl($1,$2,$3,$4,$5); $function$
;

-- aplicar_dano_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)
CREATE OR REPLACE FUNCTION public.aplicar_dano_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_user uuid := auth.uid();
  v_campaign public.campaigns%rowtype;
  v_attempt public.srd_attack_sequence_attempts%rowtype;
  v_seq public.srd_attack_sequences%rowtype;
  v_sheet public.srd_character_sheets%rowtype;
  v_race public.srd_races%rowtype;
  v_weapon public.srd_equipment%rowtype;
  v_scene jsonb;
  v_tokens jsonb;
  v_target jsonb;
  v_target_ord bigint;
  v_target_count integer;
  v_expr text;
  v_dice integer;
  v_faces integer;
  v_mult integer := 1;
  v_roll_sum integer := 0;
  v_str integer := 0;
  v_str_bonus integer := 0;
  v_damage_bonus integer := 0;
  v_weapon_specialization_bonus integer := 0;
  v_critical_static_bonus integer := 0;
  v_raw_damage integer := 0;
  v_final_damage integer := 0;
  v_damage_type text;
  v_max_hp integer;
  v_hp integer;
  v_new_hp integer;
  v_end_meta jsonb;
  v_existing public.srd_attack_sequence_attempts%rowtype;
  v_round integer;
  v_turn integer;
  i integer;
begin
  if v_user is null then raise exception 'É necessário estar autenticado.'; end if;
  if p_idempotency_key is null or p_damage_rolls is null
     or cardinality(p_damage_rolls)<1 or cardinality(p_damage_rolls)>30
     or array_position(p_damage_rolls,null) is not null
     or exists(select 1 from unnest(p_damage_rolls) x where x<1 or x>1000) then
    raise exception 'Rolagens de dano inválidas.';
  end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE' then
    raise exception 'A campanha não está em combate.';
  end if;

  select * into v_existing from public.srd_attack_sequence_attempts
    where damage_idempotency_key=p_idempotency_key;
  if found then
    if v_existing.id<>p_attempt_id then raise exception 'Chave de dano já utilizada em outra tentativa.'; end if;
    return jsonb_build_object('attempt_id',v_existing.id,'status',v_existing.status,
      'damage_applied',v_existing.damage_applied,'damage_rolls',v_existing.damage_rolls,
      'replayed',true);
  end if;

  select * into v_attempt from public.srd_attack_sequence_attempts where id=p_attempt_id for update;
  if not found then raise exception 'Tentativa de ataque não encontrada.'; end if;
  select * into v_seq from public.srd_attack_sequences
    where id=v_attempt.sequence_id and campaign_id=p_campaign_id for update;
  if not found then raise exception 'Sequência não encontrada.'; end if;
  if v_seq.status<>'active' then raise exception 'A sequência de ataques não está mais ativa.'; end if;
  if v_seq.created_by<>v_user then raise exception 'Somente quem iniciou a sequência pode registrar o dano.'; end if;
  if v_attempt.status<>'hit_pending_damage' then raise exception 'A tentativa ainda não está pronta para receber dano.'; end if;
  if not exists (
    select 1 from public.characters ch join public.members m
      on m.campaign_id=ch.campaign_id and m.user_id=ch.user_id
    where ch.id=v_seq.actor_character_id and ch.campaign_id=p_campaign_id
      and ch.user_id=v_user and m.role='PLAYER'
  ) then raise exception 'Personagem não pertence ao jogador autenticado.'; end if;

  v_turn:=case when coalesce(v_campaign.combat_data->>'current_turn','') ~ '^[0-9]+$'
    then (v_campaign.combat_data->>'current_turn')::integer else -1 end;
  v_round:=case when coalesce(v_campaign.combat_data->>'round','') ~ '^[0-9]+$'
    then greatest(1,(v_campaign.combat_data->>'round')::integer) else -1 end;
  if lower(coalesce(v_campaign.combat_data->>'active','false'))<>'true'
    or v_turn<>v_seq.turn_index or v_round<>v_seq.round_number then
    raise exception 'Turno ou rodada mudou antes da aplicação do dano.';
  end if;

  select sh.* into v_sheet from public.srd_character_sheets sh where sh.character_id=v_seq.actor_character_id;
  select r.* into v_race from public.srd_races r where r.id=v_sheet.raca_id;
  if not exists (
    select 1 from public.srd_character_weapon_instances wi
    where wi.instance_id=v_seq.weapon_instance_id and wi.character_id=v_seq.actor_character_id::text
      and wi.equipado is true and wi.hand_slot=v_seq.weapon_hand_slot
  ) then raise exception 'A arma não está mais equipada na mão vinculada.'; end if;
  if not exists (
    select 1 from public.srd_character_equipment ce
    join public.srd_character_weapon_instances wi on wi.instance_id=v_seq.weapon_instance_id
    where ce.character_id=v_seq.actor_character_id::text and ce.equipment_id=wi.equipment_id
      and ce.equipado is true and ce.hand_slot=v_seq.weapon_hand_slot
  ) then raise exception 'Inventário e instância da arma ficaram inconsistentes antes do dano.'; end if;
  select eq.* into v_weapon from public.srd_character_weapon_instances wi
    join public.srd_equipment eq on eq.id=wi.equipment_id
    where wi.instance_id=v_seq.weapon_instance_id;
  if not found then raise exception 'Arma não encontrada.'; end if;
  select coalesce(sum(case f->>'id'
    when 'srd35_feat_weapon_specialization' then 2
    when 'srd35_feat_greater_weapon_specialization' then 2
    else 0 end),0)::integer into v_weapon_specialization_bonus
  from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
  where f->>'id' in ('srd35_feat_weapon_specialization','srd35_feat_greater_weapon_specialization')
    and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))
      = public.srd35_normalizar_parametro_talento(v_weapon.nome);

  v_end_meta:=case when v_seq.weapon_end='off' then coalesce(v_weapon.detalhes->'weapon_end_off','{}'::jsonb)
    when v_seq.weapon_end='main' then coalesce(v_weapon.detalhes->'weapon_end_main','{}'::jsonb)
    else '{}'::jsonb end;
  v_expr:=coalesce(
    case when lower(coalesce(v_race.tamanho,'')) in ('pequeno','small')
      then v_end_meta->>'damage_small' else v_end_meta->>'damage_medium' end,
    case when lower(coalesce(v_race.tamanho,'')) in ('pequeno','small')
      then v_weapon.detalhes->>'damage_small' else v_weapon.detalhes->>'damage_medium' end,
    v_weapon.dano
  );
  if v_expr !~ '^[0-9]+d[0-9]+$' then
    raise exception 'Expressão de dano da arma não está normalizada: %.',coalesce(v_expr,'(vazia)');
  end if;
  v_dice:=split_part(v_expr,'d',1)::integer;
  v_faces:=split_part(v_expr,'d',2)::integer;
  if v_dice<1 or v_dice>10 or v_faces<2 or v_faces>100 then
    raise exception 'Expressão de dano da arma fora dos limites suportados.';
  end if;
  v_mult:=case when v_attempt.is_critical then
    coalesce(nullif(v_attempt.resolution_data->>'critical_multiplier','')::integer,2)
    else 1 end;
  if v_mult<2 or v_mult>5 then
    if v_attempt.is_critical then raise exception 'Multiplicador crítico inválido.'; else v_mult:=1; end if;
  end if;
  if cardinality(p_damage_rolls)<>v_dice*v_mult then
    raise exception 'A arma exige % resultados de dado de dano (% dados x multiplicador %).',
      v_dice*v_mult,v_dice,v_mult;
  end if;
  for i in 1..cardinality(p_damage_rolls) loop
    if p_damage_rolls[i]>v_faces then
      raise exception 'Resultado % excede o dado d%.',p_damage_rolls[i],v_faces;
    end if;
    v_roll_sum:=v_roll_sum+p_damage_rolls[i];
  end loop;

   v_damage_bonus:=priv.srd_effective_modifier(p_campaign_id,'character',v_seq.actor_character_id::text,'damage');
  if v_seq.attack_type='atk-corpo' then
    v_str:=coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10);
    v_str_bonus:=floor((v_str+priv.srd_effective_modifier(p_campaign_id,'character',v_seq.actor_character_id::text,'strength')-10)::numeric/2)::integer;
    if v_seq.weapon_hand_slot='off_hand' then
      v_str_bonus:=floor(v_str_bonus/2.0)::integer;
    elsif coalesce((v_weapon.detalhes->>'weapon_two_handed')::boolean,false)
      and not coalesce((v_weapon.detalhes->>'weapon_double')::boolean,false) then
      v_str_bonus:=floor(v_str_bonus*1.5)::integer;
    end if;
    v_damage_bonus:=v_damage_bonus+v_str_bonus;
    v_critical_static_bonus:=v_critical_static_bonus+v_str_bonus;
  end if;
  v_damage_bonus:=v_damage_bonus+v_weapon_specialization_bonus;
  v_critical_static_bonus:=v_critical_static_bonus+v_weapon_specialization_bonus;
  if v_seq.attack_type='atk-corpo' and v_seq.power_attack_penalty>0 then
    v_damage_bonus:=v_damage_bonus+v_seq.power_attack_penalty * case when coalesce((v_weapon.detalhes->>'weapon_two_handed')::boolean,false) then 2 else 1 end;
    v_critical_static_bonus:=v_critical_static_bonus+v_seq.power_attack_penalty * case when coalesce((v_weapon.detalhes->>'weapon_two_handed')::boolean,false) then 2 else 1 end;
  end if;
  v_raw_damage:=v_roll_sum+v_damage_bonus+(v_critical_static_bonus*greatest(0,v_mult-1));
  v_damage_type:=lower(coalesce(v_end_meta->>'damage_type',v_weapon.tipo_dano,'bludgeoning'));
  v_damage_type:=case v_damage_type
    when 'cortante' then 'slashing' when 'perfurante' then 'piercing'
    when 'impacto' then 'bludgeoning' when 'cortante/perfurante' then 'physical'
    when 'impacto/perfurante' then 'physical' else v_damage_type end;
  v_final_damage:=priv.srd_adjust_damage(p_campaign_id,'token',v_seq.target_token_id,v_damage_type,greatest(0,v_raw_damage));

  v_scene:=coalesce(v_campaign.cba_data,'{}'::jsonb);
  v_tokens:=case when jsonb_typeof(v_scene->'tokens')='array' then v_scene->'tokens' else '[]'::jsonb end;
  select count(*)::integer,min(t.ordinality) into v_target_count,v_target_ord
    from jsonb_array_elements(v_tokens) with ordinality t(token,ordinality)
    where t.token->>'id'=v_seq.target_token_id and t.token->>'tipo' in ('npc','monstro','player');
  if v_target_count<>1 then raise exception 'Alvo ausente ou duplicado na cena.'; end if;
  v_target:=v_tokens->(v_target_ord::integer-1);
  if v_target->>'tipo'='player' then
    select sh.pv_max,sh.pv_atual into v_max_hp,v_hp
    from public.characters ch
    join public.members m on m.campaign_id=ch.campaign_id and m.user_id=ch.user_id
    join public.srd_character_sheets sh on sh.character_id=ch.id
    where ch.id::text=v_seq.target_token_id
      and ch.campaign_id=p_campaign_id and m.role='PLAYER'
    for update of sh;
    if not found or coalesce(v_max_hp,0)<1 or v_hp is null then
      raise exception 'Ficha de PV do personagem alvo ausente ou inválida.';
    end if;
  else
    if coalesce(v_target->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' then raise exception 'PV máximo do alvo inválido.'; end if;
    v_max_hp:=(v_target->>'maxHp')::integer;
    v_hp:=case when coalesce(v_target->>'hp','') ~ '^-?[0-9]{1,6}$' then (v_target->>'hp')::integer else v_max_hp end;
  end if;
  v_new_hp:=greatest(-10,least(v_max_hp,v_hp-v_final_damage));
  v_target:=v_target||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp);
  v_scene:=v_scene||jsonb_build_object('tokens',jsonb_set(v_tokens,array[(v_target_ord-1)::text],v_target,false));
  update public.campaigns set cba_data=v_scene where id=p_campaign_id;
  if v_target->>'tipo'='player' then
    update public.srd_character_sheets
       set pv_atual=v_new_hp
     where character_id::text=v_seq.target_token_id;
    if not found then raise exception 'Não foi possível sincronizar os PV da ficha do personagem.'; end if;
  else
    perform priv.srd_sync_linked_npc_token_vitals(p_campaign_id,v_seq.target_token_id,v_new_hp,v_max_hp);
  end if;

  update public.srd_attack_sequence_attempts
    set status='damage_applied',damage_rolls=p_damage_rolls,damage_applied=v_final_damage,
      damage_type=v_damage_type,damage_applied_at=now(),damage_idempotency_key=p_idempotency_key,
      resolution_data=resolution_data||jsonb_build_object('damage_expression',v_expr,
        'damage_roll_sum',v_roll_sum,'damage_bonus',v_damage_bonus,'damage_raw',v_raw_damage,
        'damage_final',v_final_damage,'critical_multiplier_applied',v_mult)
    where id=p_attempt_id returning * into v_attempt;

  if v_attempt.attempt_index=v_seq.attacks_total then
    update public.srd_attack_sequences set status='completed',completed_at=now() where id=v_seq.id;
  end if;
  return jsonb_build_object('attempt_id',v_attempt.id,'status',v_attempt.status,
    'damage_applied',v_final_damage,'damage_rolls',p_damage_rolls,'damage_type',v_damage_type,
    'target_hp',v_new_hp,'target_max_hp',v_max_hp,'critical',v_attempt.is_critical,
    'critical_multiplier',v_mult,'replayed',false);
end;
$function$
;

-- aplicar_dano_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid, p_sneak_damage_rolls integer[])
CREATE OR REPLACE FUNCTION public.aplicar_dano_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid, p_sneak_damage_rolls integer[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_user uuid := auth.uid();
  v_campaign public.campaigns%rowtype;
  v_attempt public.srd_attack_sequence_attempts%rowtype;
  v_seq public.srd_attack_sequences%rowtype;
  v_sheet public.srd_character_sheets%rowtype;
  v_race public.srd_races%rowtype;
  v_weapon public.srd_equipment%rowtype;
  v_scene jsonb;
  v_tokens jsonb;
  v_target jsonb;
  v_target_ord bigint;
  v_target_count integer;
  v_expr text;
  v_dice integer;
  v_faces integer;
  v_mult integer := 1;
  v_roll_sum integer := 0;
  v_sneak_roll_sum integer := 0;
  v_sneak_dice_expected integer := 0;
  v_str integer := 0;
  v_str_bonus integer := 0;
  v_damage_bonus integer := 0;
  v_weapon_specialization_bonus integer := 0;
  v_critical_static_bonus integer := 0;
  v_raw_damage integer := 0;
  v_final_damage integer := 0;
  v_damage_type text;
  v_max_hp integer;
  v_hp integer;
  v_new_hp integer;
  v_end_meta jsonb;
  v_existing public.srd_attack_sequence_attempts%rowtype;
  v_round integer;
  v_turn integer;
  i integer;
begin
  if v_user is null then raise exception 'É necessário estar autenticado.'; end if;
  if p_idempotency_key is null or p_damage_rolls is null
     or cardinality(p_damage_rolls)<1 or cardinality(p_damage_rolls)>30
     or array_position(p_damage_rolls,null) is not null
     or exists(select 1 from unnest(p_damage_rolls) x where x<1 or x>1000) then
    raise exception 'Rolagens de dano inválidas.';
  end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE' then
    raise exception 'A campanha não está em combate.';
  end if;

  select * into v_existing from public.srd_attack_sequence_attempts
    where damage_idempotency_key=p_idempotency_key;
  if found then
    if v_existing.id<>p_attempt_id then raise exception 'Chave de dano já utilizada em outra tentativa.'; end if;
    return jsonb_build_object('attempt_id',v_existing.id,'status',v_existing.status,
      'damage_applied',v_existing.damage_applied,'damage_rolls',v_existing.damage_rolls,
      'replayed',true);
  end if;

  select * into v_attempt from public.srd_attack_sequence_attempts where id=p_attempt_id for update;
  if not found then raise exception 'Tentativa de ataque não encontrada.'; end if;
  select * into v_seq from public.srd_attack_sequences
    where id=v_attempt.sequence_id and campaign_id=p_campaign_id for update;
  if not found then raise exception 'Sequência não encontrada.'; end if;
  if v_seq.status<>'active' then raise exception 'A sequência de ataques não está mais ativa.'; end if;
  if v_seq.created_by<>v_user then raise exception 'Somente quem iniciou a sequência pode registrar o dano.'; end if;
  if v_attempt.status<>'hit_pending_damage' then raise exception 'A tentativa ainda não está pronta para receber dano.'; end if;
  if not exists (
    select 1 from public.characters ch join public.members m
      on m.campaign_id=ch.campaign_id and m.user_id=ch.user_id
    where ch.id=v_seq.actor_character_id and ch.campaign_id=p_campaign_id
      and ch.user_id=v_user and m.role='PLAYER'
  ) then raise exception 'Personagem não pertence ao jogador autenticado.'; end if;

  v_turn:=case when coalesce(v_campaign.combat_data->>'current_turn','') ~ '^[0-9]+$'
    then (v_campaign.combat_data->>'current_turn')::integer else -1 end;
  v_round:=case when coalesce(v_campaign.combat_data->>'round','') ~ '^[0-9]+$'
    then greatest(1,(v_campaign.combat_data->>'round')::integer) else -1 end;
  if lower(coalesce(v_campaign.combat_data->>'active','false'))<>'true'
    or v_turn<>v_seq.turn_index or v_round<>v_seq.round_number then
    raise exception 'Turno ou rodada mudou antes da aplicação do dano.';
  end if;

  select sh.* into v_sheet from public.srd_character_sheets sh where sh.character_id=v_seq.actor_character_id;
  select r.* into v_race from public.srd_races r where r.id=v_sheet.raca_id;
  if not exists (
    select 1 from public.srd_character_weapon_instances wi
    where wi.instance_id=v_seq.weapon_instance_id and wi.character_id=v_seq.actor_character_id::text
      and wi.equipado is true and wi.hand_slot=v_seq.weapon_hand_slot
  ) then raise exception 'A arma não está mais equipada na mão vinculada.'; end if;
  if not exists (
    select 1 from public.srd_character_equipment ce
    join public.srd_character_weapon_instances wi on wi.instance_id=v_seq.weapon_instance_id
    where ce.character_id=v_seq.actor_character_id::text and ce.equipment_id=wi.equipment_id
      and ce.equipado is true and ce.hand_slot=v_seq.weapon_hand_slot
  ) then raise exception 'Inventário e instância da arma ficaram inconsistentes antes do dano.'; end if;
  select eq.* into v_weapon from public.srd_character_weapon_instances wi
    join public.srd_equipment eq on eq.id=wi.equipment_id
    where wi.instance_id=v_seq.weapon_instance_id;
  if not found then raise exception 'Arma não encontrada.'; end if;
  select coalesce(sum(case f->>'id'
    when 'srd35_feat_weapon_specialization' then 2
    when 'srd35_feat_greater_weapon_specialization' then 2
    else 0 end),0)::integer into v_weapon_specialization_bonus
  from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
  where f->>'id' in ('srd35_feat_weapon_specialization','srd35_feat_greater_weapon_specialization')
    and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))
      = public.srd35_normalizar_parametro_talento(v_weapon.nome);

  v_end_meta:=case when v_seq.weapon_end='off' then coalesce(v_weapon.detalhes->'weapon_end_off','{}'::jsonb)
    when v_seq.weapon_end='main' then coalesce(v_weapon.detalhes->'weapon_end_main','{}'::jsonb)
    else '{}'::jsonb end;
  v_expr:=coalesce(
    case when lower(coalesce(v_race.tamanho,'')) in ('pequeno','small')
      then v_end_meta->>'damage_small' else v_end_meta->>'damage_medium' end,
    case when lower(coalesce(v_race.tamanho,'')) in ('pequeno','small')
      then v_weapon.detalhes->>'damage_small' else v_weapon.detalhes->>'damage_medium' end,
    v_weapon.dano
  );
  if v_expr !~ '^[0-9]+d[0-9]+$' then
    raise exception 'Expressão de dano da arma não está normalizada: %.',coalesce(v_expr,'(vazia)');
  end if;
  v_dice:=split_part(v_expr,'d',1)::integer;
  v_faces:=split_part(v_expr,'d',2)::integer;
  if v_dice<1 or v_dice>10 or v_faces<2 or v_faces>100 then
    raise exception 'Expressão de dano da arma fora dos limites suportados.';
  end if;
  v_mult:=case when v_attempt.is_critical then
    coalesce(nullif(v_attempt.resolution_data->>'critical_multiplier','')::integer,2)
    else 1 end;
  if v_mult<2 or v_mult>5 then
    if v_attempt.is_critical then raise exception 'Multiplicador crítico inválido.'; else v_mult:=1; end if;
  end if;
  if cardinality(p_damage_rolls)<>v_dice*v_mult then
    raise exception 'A arma exige % resultados de dado de dano (% dados x multiplicador %).',
      v_dice*v_mult,v_dice,v_mult;
  end if;
  v_sneak_dice_expected:=greatest(0,coalesce(nullif(v_attempt.resolution_data->>'sneak_attack_dice','')::integer,0));
  if v_sneak_dice_expected=0 then
    if coalesce(cardinality(p_sneak_damage_rolls),0)<>0 then raise exception 'Esta tentativa não possui Ataque Furtivo elegível.'; end if;
  else
    if p_sneak_damage_rolls is null or cardinality(p_sneak_damage_rolls)<>v_sneak_dice_expected
       or array_position(p_sneak_damage_rolls,null) is not null
       or exists(select 1 from unnest(p_sneak_damage_rolls) x where x<1 or x>6) then
      raise exception 'Ataque Furtivo exige exatamente % resultados de d6 manuais.',v_sneak_dice_expected;
    end if;
    select coalesce(sum(x),0)::integer into v_sneak_roll_sum from unnest(p_sneak_damage_rolls) x;
  end if;
  for i in 1..cardinality(p_damage_rolls) loop
    if p_damage_rolls[i]>v_faces then
      raise exception 'Resultado % excede o dado d%.',p_damage_rolls[i],v_faces;
    end if;
    v_roll_sum:=v_roll_sum+p_damage_rolls[i];
  end loop;

   v_damage_bonus:=priv.srd_effective_modifier(p_campaign_id,'character',v_seq.actor_character_id::text,'damage');
  if v_seq.attack_type='atk-corpo' then
    v_str:=coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10);
    v_str_bonus:=floor((v_str+priv.srd_effective_modifier(p_campaign_id,'character',v_seq.actor_character_id::text,'strength')-10)::numeric/2)::integer;
    if v_seq.weapon_hand_slot='off_hand' then
      v_str_bonus:=floor(v_str_bonus/2.0)::integer;
    elsif coalesce((v_weapon.detalhes->>'weapon_two_handed')::boolean,false)
      and not coalesce((v_weapon.detalhes->>'weapon_double')::boolean,false) then
      v_str_bonus:=floor(v_str_bonus*1.5)::integer;
    end if;
    v_damage_bonus:=v_damage_bonus+v_str_bonus;
    v_critical_static_bonus:=v_critical_static_bonus+v_str_bonus;
  end if;
  v_damage_bonus:=v_damage_bonus+v_weapon_specialization_bonus;
  v_critical_static_bonus:=v_critical_static_bonus+v_weapon_specialization_bonus;
  if v_seq.attack_type='atk-corpo' and v_seq.power_attack_penalty>0 then
    v_damage_bonus:=v_damage_bonus+v_seq.power_attack_penalty * case when coalesce((v_weapon.detalhes->>'weapon_two_handed')::boolean,false) then 2 else 1 end;
    v_critical_static_bonus:=v_critical_static_bonus+v_seq.power_attack_penalty * case when coalesce((v_weapon.detalhes->>'weapon_two_handed')::boolean,false) then 2 else 1 end;
  end if;
  v_raw_damage:=v_roll_sum+v_damage_bonus+(v_critical_static_bonus*greatest(0,v_mult-1))+v_sneak_roll_sum;
  v_damage_type:=lower(coalesce(v_end_meta->>'damage_type',v_weapon.tipo_dano,'bludgeoning'));
  v_damage_type:=case v_damage_type
    when 'cortante' then 'slashing' when 'perfurante' then 'piercing'
    when 'impacto' then 'bludgeoning' when 'cortante/perfurante' then 'physical'
    when 'impacto/perfurante' then 'physical' else v_damage_type end;
  v_final_damage:=priv.srd_adjust_damage(p_campaign_id,'token',v_seq.target_token_id,v_damage_type,greatest(0,v_raw_damage));

  v_scene:=coalesce(v_campaign.cba_data,'{}'::jsonb);
  v_tokens:=case when jsonb_typeof(v_scene->'tokens')='array' then v_scene->'tokens' else '[]'::jsonb end;
  select count(*)::integer,min(t.ordinality) into v_target_count,v_target_ord
    from jsonb_array_elements(v_tokens) with ordinality t(token,ordinality)
    where t.token->>'id'=v_seq.target_token_id and t.token->>'tipo' in ('npc','monstro','player');
  if v_target_count<>1 then raise exception 'Alvo ausente ou duplicado na cena.'; end if;
  v_target:=v_tokens->(v_target_ord::integer-1);
  if v_target->>'tipo'='player' then
    select sh.pv_max,sh.pv_atual into v_max_hp,v_hp
    from public.characters ch
    join public.members m on m.campaign_id=ch.campaign_id and m.user_id=ch.user_id
    join public.srd_character_sheets sh on sh.character_id=ch.id
    where ch.id::text=v_seq.target_token_id
      and ch.campaign_id=p_campaign_id and m.role='PLAYER'
    for update of sh;
    if not found or coalesce(v_max_hp,0)<1 or v_hp is null then
      raise exception 'Ficha de PV do personagem alvo ausente ou inválida.';
    end if;
  else
    if coalesce(v_target->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' then raise exception 'PV máximo do alvo inválido.'; end if;
    v_max_hp:=(v_target->>'maxHp')::integer;
    v_hp:=case when coalesce(v_target->>'hp','') ~ '^-?[0-9]{1,6}$' then (v_target->>'hp')::integer else v_max_hp end;
  end if;
  v_new_hp:=greatest(-10,least(v_max_hp,v_hp-v_final_damage));
  v_target:=v_target||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp);
  v_scene:=v_scene||jsonb_build_object('tokens',jsonb_set(v_tokens,array[(v_target_ord-1)::text],v_target,false));
  update public.campaigns set cba_data=v_scene where id=p_campaign_id;
  if v_target->>'tipo'='player' then
    update public.srd_character_sheets
       set pv_atual=v_new_hp
     where character_id::text=v_seq.target_token_id;
    if not found then raise exception 'Não foi possível sincronizar os PV da ficha do personagem.'; end if;
  else
    perform priv.srd_sync_linked_npc_token_vitals(p_campaign_id,v_seq.target_token_id,v_new_hp,v_max_hp);
  end if;

  update public.srd_attack_sequence_attempts
    set status='damage_applied',damage_rolls=p_damage_rolls,damage_applied=v_final_damage,
      damage_type=v_damage_type,damage_applied_at=now(),damage_idempotency_key=p_idempotency_key,
      resolution_data=resolution_data||jsonb_build_object('damage_expression',v_expr,
        'damage_roll_sum',v_roll_sum,'sneak_attack_roll_sum',v_sneak_roll_sum,'sneak_attack_dice',v_sneak_dice_expected,'sneak_damage_rolls',to_jsonb(coalesce(p_sneak_damage_rolls,'{}'::integer[])),'damage_bonus',v_damage_bonus,'damage_raw',v_raw_damage,
        'damage_final',v_final_damage,'critical_multiplier_applied',v_mult)
    where id=p_attempt_id returning * into v_attempt;

  if v_attempt.attempt_index=v_seq.attacks_total then
    update public.srd_attack_sequences set status='completed',completed_at=now() where id=v_seq.id;
  end if;
  return jsonb_build_object('attempt_id',v_attempt.id,'status',v_attempt.status,
    'damage_applied',v_final_damage,'damage_rolls',p_damage_rolls,'sneak_damage_rolls',coalesce(p_sneak_damage_rolls,'{}'::integer[]),'damage_type',v_damage_type,
    'target_hp',v_new_hp,'target_max_hp',v_max_hp,'critical',v_attempt.is_critical,
    'critical_multiplier',v_mult,'replayed',false);
end;
$function$
;

-- aplicar_dano_ataque_npc_gm_srd(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_raw_damage integer, p_damage_type text)
CREATE OR REPLACE FUNCTION public.aplicar_dano_ataque_npc_gm_srd(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_raw_damage integer, p_damage_type text DEFAULT 'untyped'::text)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO ''
AS $function$ select priv.gm_npc_apply_typed_damage_impl($1,$2,$3,$4,$5); $function$
;

-- aplicar_dano_token_ataque_srd(p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer, p_bonus_ataque integer, p_dano integer)
CREATE OR REPLACE FUNCTION public.aplicar_dano_token_ataque_srd(p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer, p_bonus_ataque integer, p_dano integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
 v_user UUID:=auth.uid(); v_campaign public.campaigns%ROWTYPE; v_combat JSONB; v_order JSONB; v_actor JSONB; v_scene JSONB; v_tokens JSONB; v_target JSONB;
 v_target_count INTEGER; v_target_index BIGINT; v_ca_text TEXT; v_ca INTEGER; v_max_hp INTEGER; v_hp INTEGER; v_new_hp INTEGER; v_attack_total INTEGER; v_round INTEGER;
BEGIN
 IF v_user IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
 IF p_d20 IS NULL OR p_d20<1 OR p_d20>20 THEN RAISE EXCEPTION 'Resultado de ataque inválido.'; END IF;
 IF p_bonus_ataque IS NULL OR p_bonus_ataque < -30 OR p_bonus_ataque > 60 THEN RAISE EXCEPTION 'Bônus de ataque inválido.'; END IF;
 IF p_dano IS NULL OR p_dano<1 OR p_dano>1000 THEN RAISE EXCEPTION 'Dano inválido.'; END IF;
 SELECT c.* INTO v_campaign FROM public.campaigns c WHERE c.id=p_campaign_id FOR UPDATE;
 IF NOT FOUND OR UPPER(COALESCE(v_campaign.state,''))<>'COMBATE' THEN RAISE EXCEPTION 'A campanha não está em combate.'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.characters ch JOIN public.members m ON m.campaign_id=ch.campaign_id AND m.user_id=ch.user_id AND m.role='PLAYER' WHERE ch.id::TEXT=BTRIM(p_character_id) AND ch.campaign_id=p_campaign_id AND ch.user_id=v_user) THEN RAISE EXCEPTION 'A ficha atacante não pertence ao jogador nesta campanha.'; END IF;
 v_combat:=COALESCE(v_campaign.combat_data,'{}'::JSONB);
 IF COALESCE(v_combat->>'active','false')<>'true' THEN RAISE EXCEPTION 'A iniciativa não está ativa.'; END IF;
 v_order:=CASE WHEN jsonb_typeof(v_combat->'turn_order')='array' THEN v_combat->'turn_order' ELSE '[]'::JSONB END;
 IF COALESCE(v_combat->>'current_turn','') !~ '^[0-9]+$' THEN RAISE EXCEPTION 'O turno atual é inválido.'; END IF;
 v_actor:=v_order->(v_combat->>'current_turn')::INTEGER;
 IF v_actor->>'id' IS DISTINCT FROM BTRIM(p_character_id) OR COALESCE(v_actor->>'is_monster','false')='true' THEN RAISE EXCEPTION 'Apenas o personagem ativo pode concluir este ataque.'; END IF;
 v_round:=CASE WHEN COALESCE(v_combat->>'round','') ~ '^[0-9]+$' THEN GREATEST(1,(v_combat->>'round')::INTEGER) ELSE 1 END;
 IF COALESCE(v_combat->'action_economy'->>'round','')<>v_round::TEXT OR COALESCE(v_combat->'action_economy'->'by_character'->BTRIM(p_character_id)->>'padrao','false')<>'true' THEN RAISE EXCEPTION 'A ação padrão do atacante ainda não foi consumida neste turno.'; END IF;
 v_scene:=COALESCE(v_campaign.cba_data,'{}'::JSONB); v_tokens:=CASE WHEN jsonb_typeof(v_scene->'tokens')='array' THEN v_scene->'tokens' ELSE '[]'::JSONB END;
 SELECT count(*)::INTEGER,min(t.ordinality),min(coalesce(t.token->>'ac',t.token->'monsterStats'->>'ca')) INTO v_target_count,v_target_index,v_ca_text FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(token,ordinality) WHERE t.token->>'id'=BTRIM(p_token_id) AND t.token->>'tipo' IN ('npc','monstro');
 IF v_target_count<>1 THEN RAISE EXCEPTION 'O alvo NPC/monstro não foi encontrado ou está duplicado.'; END IF;
 IF COALESCE(v_ca_text,'') !~ '[0-9]{1,3}' THEN RAISE EXCEPTION 'O token alvo precisa ter uma CA numérica.'; END IF;
 v_ca:=substring(v_ca_text from '[0-9]{1,3}')::INTEGER; v_attack_total:=p_d20+p_bonus_ataque;
 IF p_d20=1 OR (p_d20<>20 AND v_attack_total<v_ca) THEN RAISE EXCEPTION 'Ataque não atingiu a CA do alvo (%). Nenhum dano foi aplicado.',v_ca; END IF;
 v_target:=v_tokens->(v_target_index::INTEGER-1);
 IF COALESCE(v_target->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN RAISE EXCEPTION 'O alvo não possui PV máximo configurado.'; END IF;
 v_max_hp:=(v_target->>'maxHp')::INTEGER; v_hp:=CASE WHEN COALESCE(v_target->>'hp','') ~ '^[0-9]{1,6}$' THEN (v_target->>'hp')::INTEGER ELSE v_max_hp END;
 v_new_hp:=GREATEST(0,LEAST(v_max_hp,v_hp-p_dano)); v_target:=v_target||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp);
 v_scene:=v_scene||jsonb_build_object('tokens',jsonb_set(v_tokens,ARRAY[(v_target_index-1)::TEXT],v_target,FALSE)); UPDATE public.campaigns SET cba_data=v_scene WHERE id=p_campaign_id;
 RETURN jsonb_build_object('cba_data',v_scene,'hp',v_new_hp,'max_hp',v_max_hp,'ca',v_ca,'attack_total',v_attack_total,'damage',p_dano);
END; $function$
;

-- aplicar_dano_token_ataque_srd_v2(p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer, p_bonus_ataque integer, p_dano integer, p_weapon_id text, p_attack_type text, p_power_penalty integer)
CREATE OR REPLACE FUNCTION public.aplicar_dano_token_ataque_srd_v2(p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer, p_bonus_ataque integer, p_dano integer, p_weapon_id text, p_attack_type text, p_power_penalty integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
 v_user UUID:=auth.uid(); v_campaign public.campaigns%ROWTYPE; v_combat JSONB; v_order JSONB; v_actor JSONB; v_scene JSONB; v_tokens JSONB; v_target JSONB;
 v_target_count INTEGER; v_target_index BIGINT; v_ca_text TEXT; v_ca INTEGER; v_max_hp INTEGER; v_hp INTEGER; v_new_hp INTEGER; v_attack_total INTEGER; v_round INTEGER;
 v_sheet public.srd_character_sheets%ROWTYPE; v_weapon public.srd_equipment%ROWTYPE; v_bab_progression TEXT; v_race_size TEXT;
 v_level INTEGER; v_bab INTEGER; v_str_score INTEGER; v_dex_score INTEGER; v_ability_mod INTEGER; v_ability_key TEXT;
 v_size_modifier INTEGER:=0; v_weapon_focus INTEGER:=0; v_power_penalty INTEGER:=0; v_range_penalty INTEGER:=0; v_expected_bonus INTEGER; v_racial_attack_bonus INTEGER:=0; v_target_traits TEXT;
 v_has_finesse BOOLEAN:=FALSE; v_has_power_attack BOOLEAN:=FALSE; v_weapon_name TEXT;
 v_effective_attack_modifier INTEGER:=0; v_effective_ac_modifier INTEGER:=0; v_damage_final INTEGER:=0; v_damage_type TEXT;
 v_attacker_count INTEGER; v_attacker_index BIGINT; v_attacker JSONB;
 v_attacker_size INTEGER:=1; v_target_size INTEGER:=1; v_reach_squares INTEGER:=1;
 v_ax INTEGER; v_ay INTEGER; v_bx INTEGER; v_by INTEGER; v_dx INTEGER; v_dy INTEGER; v_distance_squares INTEGER;
 v_range_increment_m NUMERIC; v_range_increments INTEGER; v_max_range_increments INTEGER:=10;
 v_class_weapon_proficiencies JSONB; v_weapon_proficiency_type TEXT; v_weapon_proficiency_penalty INTEGER:=0; v_weapon_focus_name TEXT;
 v_class_has_simple BOOLEAN:=FALSE; v_class_has_simple_martial BOOLEAN:=FALSE; v_class_has_exact_weapon BOOLEAN:=FALSE;
 v_has_simple_feat BOOLEAN:=FALSE; v_has_martial_feat BOOLEAN:=FALSE; v_has_exotic_feat BOOLEAN:=FALSE; v_is_dwarf_familiar_weapon BOOLEAN:=FALSE; v_is_proficient BOOLEAN:=FALSE;
BEGIN
 IF v_user IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
 IF p_d20 IS NULL OR p_d20<1 OR p_d20>20 THEN RAISE EXCEPTION 'Resultado de ataque inválido.'; END IF;
 IF p_bonus_ataque IS NULL OR p_bonus_ataque < -30 OR p_bonus_ataque > 60 THEN RAISE EXCEPTION 'Bônus de ataque inválido.'; END IF;
 IF p_dano IS NULL OR p_dano<1 OR p_dano>1000 THEN RAISE EXCEPTION 'Dano inválido.'; END IF;
 SELECT c.* INTO v_campaign FROM public.campaigns c WHERE c.id=p_campaign_id FOR UPDATE;
 IF NOT FOUND OR UPPER(COALESCE(v_campaign.state,''))<>'COMBATE' THEN RAISE EXCEPTION 'A campanha não está em combate.'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.characters ch JOIN public.members m ON m.campaign_id=ch.campaign_id AND m.user_id=ch.user_id AND m.role='PLAYER' WHERE ch.id::TEXT=BTRIM(p_character_id) AND ch.campaign_id=p_campaign_id AND ch.user_id=v_user) THEN RAISE EXCEPTION 'A ficha atacante não pertence ao jogador nesta campanha.'; END IF;
 v_combat:=COALESCE(v_campaign.combat_data,'{}'::JSONB);
 IF COALESCE(v_combat->>'active','false')<>'true' THEN RAISE EXCEPTION 'A iniciativa não está ativa.'; END IF;
 v_order:=CASE WHEN jsonb_typeof(v_combat->'turn_order')='array' THEN v_combat->'turn_order' ELSE '[]'::JSONB END;
 IF COALESCE(v_combat->>'current_turn','') !~ '^[0-9]+$' THEN RAISE EXCEPTION 'O turno atual é inválido.'; END IF;
 v_actor:=v_order->(v_combat->>'current_turn')::INTEGER;
 IF v_actor->>'id' IS DISTINCT FROM BTRIM(p_character_id) OR COALESCE(v_actor->>'is_monster','false')='true' THEN RAISE EXCEPTION 'Apenas o personagem ativo pode concluir este ataque.'; END IF;
 v_round:=CASE WHEN COALESCE(v_combat->>'round','') ~ '^[0-9]+$' THEN GREATEST(1,(v_combat->>'round')::INTEGER) ELSE 1 END;
 IF COALESCE(v_combat->'action_economy'->>'round','')<>v_round::TEXT OR COALESCE(v_combat->'action_economy'->'by_character'->BTRIM(p_character_id)->>'padrao','false')<>'true' THEN RAISE EXCEPTION 'A ação padrão do atacante ainda não foi consumida neste turno.'; END IF;
 v_scene:=COALESCE(v_campaign.cba_data,'{}'::JSONB); v_tokens:=CASE WHEN jsonb_typeof(v_scene->'tokens')='array' THEN v_scene->'tokens' ELSE '[]'::JSONB END;
 SELECT count(*)::INTEGER,min(t.ordinality),min(coalesce(t.token->>'ac',t.token->'monsterStats'->>'ca')) INTO v_target_count,v_target_index,v_ca_text FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(token,ordinality) WHERE t.token->>'id'=BTRIM(p_token_id) AND t.token->>'tipo' IN ('npc','monstro');
 IF v_target_count<>1 THEN RAISE EXCEPTION 'O alvo NPC/monstro não foi encontrado ou está duplicado.'; END IF;
 v_target:=v_tokens->(v_target_index::INTEGER-1);
 IF p_attack_type IS NULL OR p_attack_type NOT IN ('atk-corpo','atk-dist') THEN RAISE EXCEPTION 'Tipo de ataque inválido.'; END IF;
 v_power_penalty:=COALESCE(p_power_penalty,0);
 IF v_power_penalty<0 THEN RAISE EXCEPTION 'Penalidade de Ataque Poderoso inválida.'; END IF;
 SELECT sh.* INTO v_sheet
 FROM public.characters ch JOIN public.srd_character_sheets sh ON sh.character_id=ch.id
 WHERE ch.id::TEXT=BTRIM(p_character_id) AND ch.campaign_id=p_campaign_id AND ch.user_id=v_user;
 IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD 3.5 do atacante não encontrada.'; END IF;
 SELECT cl.bab_progression,r.tamanho,cl.dados_tecnicos->'proficiencias'->'armas' INTO v_bab_progression,v_race_size,v_class_weapon_proficiencies
 FROM public.srd_classes cl CROSS JOIN public.srd_races r
 WHERE cl.id=v_sheet.classe_id AND r.id=v_sheet.raca_id;
 IF NOT FOUND THEN RAISE EXCEPTION 'Classe ou raça da ficha não encontrada.'; END IF;
 v_level:=GREATEST(1,COALESCE(v_sheet.nivel,1));
 v_bab:=CASE lower(COALESCE(v_bab_progression,''))
   WHEN 'good' THEN v_level WHEN 'bom' THEN v_level
   WHEN 'average' THEN FLOOR(3*v_level/4)::INTEGER WHEN 'medium' THEN FLOOR(3*v_level/4)::INTEGER WHEN 'medio' THEN FLOOR(3*v_level/4)::INTEGER
   WHEN 'poor' THEN FLOOR(v_level/2)::INTEGER WHEN 'ruim' THEN FLOOR(v_level/2)::INTEGER ELSE 0 END;
 v_str_score:=CASE WHEN COALESCE(v_sheet.atributos->>'FOR','') ~ '^[0-9]+$' THEN (v_sheet.atributos->>'FOR')::INTEGER ELSE 10 END;
 v_dex_score:=CASE WHEN COALESCE(v_sheet.atributos->>'DES','') ~ '^[0-9]+$' THEN (v_sheet.atributos->>'DES')::INTEGER ELSE 10 END;
 v_has_finesse:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_weapon_finesse');
 v_has_power_attack:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='ataque_poderoso');
 IF NULLIF(BTRIM(p_weapon_id),'') IS NOT NULL THEN
   SELECT eq.* INTO v_weapon FROM public.srd_character_equipment ce JOIN public.srd_equipment eq ON eq.id=ce.equipment_id
   WHERE ce.character_id=v_sheet.character_id AND ce.equipment_id=BTRIM(p_weapon_id) AND ce.equipado IS TRUE AND public.srd35_equipment_slot(eq.categoria,eq.nome)='arma' AND EXISTS (SELECT 1 FROM public.srd_character_weapon_instances wi WHERE wi.character_id=ce.character_id AND wi.equipment_id=ce.equipment_id AND wi.equipado IS TRUE AND wi.hand_slot='main_hand');
   IF NOT FOUND THEN RAISE EXCEPTION 'A arma informada não está equipada nesta ficha.'; END IF;
 END IF;
 v_weapon_name:=COALESCE(v_weapon.detalhes->>'weapon_proficiency_name',v_weapon.nome,'Ataque desarmado'); v_weapon_focus_name:=COALESCE(v_weapon.detalhes->>'weapon_focus_name',v_weapon.nome,'Ataque desarmado');
 
v_weapon_proficiency_type:=priv.srd_weapon_proficiency(v_weapon.detalhes,v_weapon_name);
v_is_dwarf_familiar_weapon:=v_sheet.raca_id='anao'
  AND regexp_replace(lower(translate(v_weapon_name,'ã','a')),'[^a-z0-9]+','','g')
    IN ('waraxedwarven','dwarvenwaraxe','urgroshdwarven','dwarvenurgrosh','machadodeguerraanao','urgroshanao');

 IF v_weapon.id IS NOT NULL THEN
   v_class_has_simple:=EXISTS(
     SELECT 1 FROM jsonb_array_elements_text(CASE WHEN jsonb_typeof(v_class_weapon_proficiencies)='array' THEN v_class_weapon_proficiencies ELSE '[]'::JSONB END) p(value)
     WHERE lower(BTRIM(p.value))='armas simples'
   );
   v_class_has_simple_martial:=EXISTS(
     SELECT 1 FROM jsonb_array_elements_text(CASE WHEN jsonb_typeof(v_class_weapon_proficiencies)='array' THEN v_class_weapon_proficiencies ELSE '[]'::JSONB END) p(value)
     WHERE lower(BTRIM(p.value))='todas as armas simples e marciais'
   );
   v_class_has_exact_weapon:=EXISTS(
     SELECT 1 FROM jsonb_array_elements_text(CASE WHEN jsonb_typeof(v_class_weapon_proficiencies)='array' THEN v_class_weapon_proficiencies ELSE '[]'::JSONB END) p(value)
     WHERE public.srd35_normalizar_parametro_talento(p.value)=public.srd35_normalizar_parametro_talento(v_weapon_name)
   );
   v_has_simple_feat:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_simple_weapon_proficiency');
   v_has_martial_feat:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_martial_weapon_proficiency' AND public.srd35_normalizar_parametro_talento(COALESCE(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name));
   v_has_exotic_feat:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_exotic_weapon_proficiency' AND public.srd35_normalizar_parametro_talento(COALESCE(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name));
   v_is_proficient:=CASE
     WHEN v_weapon_proficiency_type='simple' THEN v_class_has_exact_weapon OR v_class_has_simple OR v_class_has_simple_martial OR v_has_simple_feat
     WHEN v_weapon_proficiency_type='martial' THEN v_class_has_exact_weapon OR v_class_has_simple_martial OR v_has_martial_feat
     WHEN v_weapon_proficiency_type='exotic' THEN
       v_class_has_exact_weapon OR v_has_exotic_feat
       OR (v_is_dwarf_familiar_weapon AND (v_class_has_simple_martial OR v_has_martial_feat))
     ELSE FALSE END;
   v_weapon_proficiency_penalty:=CASE WHEN v_is_proficient THEN 0 ELSE 4 END;
 END IF;
 IF p_attack_type='atk-dist' THEN
   IF v_weapon.id IS NULL OR COALESCE(v_weapon.detalhes->>'weapon_ranged','false')<>'true' THEN RAISE EXCEPTION 'A arma equipada não permite ataque à distância.'; END IF;
   v_ability_key:='DES';
 ELSE
   IF v_weapon.id IS NOT NULL AND COALESCE(v_weapon.detalhes->>'weapon_melee','true')='false' THEN RAISE EXCEPTION 'A arma equipada não permite ataque corpo a corpo.'; END IF;
   IF v_has_finesse AND v_bab<1 THEN RAISE EXCEPTION 'Acuidade com Arma exige bônus base de ataque +1.'; END IF;
 IF v_has_finesse AND (v_weapon.id IS NULL OR COALESCE(v_weapon.detalhes->>'weapon_finesse_eligible','false')='true') THEN v_ability_key:='DES'; ELSE v_ability_key:='FOR'; END IF;
 END IF;
 v_ability_mod:=FLOOR(((CASE WHEN v_ability_key='DES' THEN v_dex_score ELSE v_str_score END)-10)::NUMERIC/2)::INTEGER;
 v_size_modifier:=CASE WHEN lower(COALESCE(v_race_size,'')) IN ('pequeno','small') THEN 1 ELSE 0 END;
 SELECT (CASE WHEN EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='foco_em_arma' AND public.srd35_normalizar_parametro_talento(COALESCE(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_focus_name)) THEN 1 ELSE 0 END)+(CASE WHEN EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_greater_weapon_focus' AND public.srd35_normalizar_parametro_talento(COALESCE(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_focus_name)) THEN 1 ELSE 0 END) INTO v_weapon_focus;
 IF v_power_penalty>0 AND (p_attack_type<>'atk-corpo' OR (v_weapon.id IS NOT NULL AND COALESCE(v_weapon.detalhes->>'weapon_light','false')='true') OR NOT v_has_power_attack OR v_power_penalty>v_bab) THEN RAISE EXCEPTION 'Ataque Poderoso inválido para esta ficha ou ataque.'; END IF;
 SELECT count(*)::INTEGER,min(t.ordinality) INTO v_attacker_count,v_attacker_index
 FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(token,ordinality)
 WHERE t.token->>'id'=BTRIM(p_character_id) AND t.token->>'tipo'='player';
 IF v_attacker_count<>1 THEN RAISE EXCEPTION 'O token do personagem atacante não foi encontrado ou está duplicado.'; END IF;
 v_attacker:=v_tokens->(v_attacker_index::INTEGER-1);
 v_attacker_size:=CASE
   WHEN lower(COALESCE(v_race_size,'')) LIKE 'large%' OR lower(COALESCE(v_race_size,'')) LIKE 'grande%' THEN 2
   WHEN lower(COALESCE(v_race_size,'')) LIKE 'huge%' OR lower(COALESCE(v_race_size,'')) LIKE 'enorme%' THEN 3
   WHEN lower(COALESCE(v_race_size,'')) LIKE 'gargantuan%' OR lower(COALESCE(v_race_size,'')) LIKE 'imenso%' THEN 4
   WHEN lower(COALESCE(v_race_size,'')) LIKE 'colossal%' THEN 5 ELSE 1 END;
 v_target_size:=CASE
   WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'large%' OR lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'grande%' THEN 2
   WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'huge%' OR lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'enorme%' THEN 3
   WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'gargantuan%' OR lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'imenso%' THEN 4
   WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'colossal%' THEN 5 ELSE 1 END;
 IF COALESCE(v_attacker->>'gridX','') !~ '^-?[0-9]+$' OR COALESCE(v_attacker->>'gridY','') !~ '^-?[0-9]+$' OR COALESCE(v_target->>'gridX','') !~ '^-?[0-9]+$' OR COALESCE(v_target->>'gridY','') !~ '^-?[0-9]+$' THEN RAISE EXCEPTION 'Posição de token inválida para calcular alcance.'; END IF;
 v_ax:=(v_attacker->>'gridX')::INTEGER; v_ay:=(v_attacker->>'gridY')::INTEGER; v_bx:=(v_target->>'gridX')::INTEGER; v_by:=(v_target->>'gridY')::INTEGER;
 v_dx:=GREATEST(0,v_bx-(v_ax+v_attacker_size-1),v_ax-(v_bx+v_target_size-1));
 v_dy:=GREATEST(0,v_by-(v_ay+v_attacker_size-1),v_ay-(v_by+v_target_size-1));
 v_distance_squares:=GREATEST(v_dx,v_dy)+FLOOR(LEAST(v_dx,v_dy)::NUMERIC/2)::INTEGER;
 IF p_attack_type='atk-corpo' THEN
   v_reach_squares:=GREATEST(1,v_attacker_size);
   IF v_distance_squares>v_reach_squares THEN RAISE EXCEPTION 'Alvo fora do alcance corpo a corpo.'; END IF;
 ELSE
   v_range_increment_m:=NULLIF(v_weapon.detalhes->>'range_increment_m','')::NUMERIC;
   IF v_range_increment_m IS NULL OR v_range_increment_m<=0 THEN RAISE EXCEPTION 'Incremento de distância da arma não cadastrado.'; END IF;
   v_range_increments:=GREATEST(1,CEIL((v_distance_squares*1.5)/v_range_increment_m)::INTEGER);
   v_max_range_increments:=COALESCE(NULLIF(v_weapon.detalhes->>'max_range_increments','')::INTEGER,10); IF v_range_increments>v_max_range_increments THEN RAISE EXCEPTION 'Alvo fora do alcance máximo de % incrementos da arma.',v_max_range_increments; END IF;
   v_range_penalty:=(v_range_increments-1)*2;
 END IF;
 
v_target_traits:=lower(concat_ws(' ',
  v_target->>'nome',v_target->>'detalhe',
  v_target->'monsterStats'->>'tipo',v_target->'monsterStats'->>'subtipo',
  v_target->'monsterStats'->>'subtype',v_target->'monsterStats'->>'subtypes',
  v_target->'monsterStats'->>'type',v_target->'monsterStats'->>'creature_type',
  v_target->'monsterStats'->>'race_id',v_target->>'creature_type',
  (SELECT lower(sh.raca_id::text) FROM public.srd_character_sheets sh
    WHERE sh.character_id::text=CASE
      WHEN v_target->>'tipo'='player' THEN v_target->>'id'
      WHEN v_target->>'tipo'='npc' THEN v_target->>'sourceCharacterId'
      ELSE NULL END LIMIT 1)
));
IF v_sheet.raca_id='anao'
   AND v_target_traits ~ '(^|[^a-z])(orc|goblin|hobgoblin|bugbear|goblinoid(e)?)([^a-z]|$)' THEN
  v_racial_attack_bonus:=1;
ELSIF v_sheet.raca_id='gnomo'
   AND v_target_traits ~ '(^|[^a-z])(kobold|goblin|hobgoblin|bugbear|goblinoid(e)?)([^a-z]|$)' THEN
  v_racial_attack_bonus:=1;
ELSIF v_sheet.raca_id='halfling'
   AND p_attack_type='atk-dist'
   AND (
     COALESCE(v_weapon.detalhes->>'weapon_ranged_type','')='thrown'
     OR lower(COALESCE(v_weapon.nome,''))='funda'
   ) THEN
  v_racial_attack_bonus:=1;
END IF;
v_expected_bonus:=v_bab+v_ability_mod+v_size_modifier+v_weapon_focus-v_power_penalty-v_range_penalty-v_weapon_proficiency_penalty+v_racial_attack_bonus;

 IF p_bonus_ataque<>v_expected_bonus THEN RAISE EXCEPTION 'Bônus de ataque não confere com a ficha. Esperado: %, recebido: %.',v_expected_bonus,p_bonus_ataque; END IF;
 IF priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_character_id),'no_actions') OR priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_character_id),'cannot_attack') THEN RAISE EXCEPTION 'A condição atual impede ataques.'; END IF;
 v_effective_attack_modifier:=priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'attack')+CASE WHEN p_attack_type='atk-corpo' THEN priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'attack_melee')+FLOOR((v_str_score+priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'strength')-10)::numeric/2)::integer-FLOOR((v_str_score-10)::numeric/2)::integer ELSE priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'attack_ranged')+FLOOR((v_dex_score+priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'dexterity')-10)::numeric/2)::integer-FLOOR((v_dex_score-10)::numeric/2)::integer END;
 IF COALESCE(v_ca_text,'') !~ '[0-9]{1,3}' THEN RAISE EXCEPTION 'O token alvo precisa ter uma CA numérica.'; END IF;
 v_effective_ac_modifier:=priv.srd_effective_modifier(p_campaign_id,'token',BTRIM(p_token_id),'ac')+CASE WHEN p_attack_type='atk-corpo' THEN priv.srd_effective_modifier(p_campaign_id,'token',BTRIM(p_token_id),'ac_melee') ELSE priv.srd_effective_modifier(p_campaign_id,'token',BTRIM(p_token_id),'ac_ranged') END;
 v_ca:=substring(v_ca_text from '[0-9]{1,3}')::INTEGER+v_effective_ac_modifier; v_attack_total:=p_d20+p_bonus_ataque+v_effective_attack_modifier;
 IF p_d20=1 OR (p_d20<>20 AND v_attack_total<v_ca) THEN RAISE EXCEPTION 'Ataque não atingiu a CA do alvo (%). Nenhum dano foi aplicado.',v_ca; END IF;
 v_target:=v_tokens->(v_target_index::INTEGER-1);
 IF COALESCE(v_target->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN RAISE EXCEPTION 'O alvo não possui PV máximo configurado.'; END IF;
 v_max_hp:=(v_target->>'maxHp')::INTEGER; v_hp:=CASE WHEN COALESCE(v_target->>'hp','') ~ '^-?[0-9]{1,6}$' THEN (v_target->>'hp')::INTEGER ELSE v_max_hp END;
 v_damage_type:=CASE lower(COALESCE(v_weapon.tipo_dano,'bludgeoning')) WHEN 'cortante' THEN 'slashing' WHEN 'perfurante' THEN 'piercing' WHEN 'impacto' THEN 'bludgeoning' WHEN 'cortante/perfurante' THEN 'physical' WHEN 'impacto/perfurante' THEN 'physical' ELSE lower(COALESCE(v_weapon.tipo_dano,'bludgeoning')) END;
 v_damage_final:=priv.srd_adjust_damage(p_campaign_id,'token',BTRIM(p_token_id),v_damage_type,GREATEST(0,p_dano+priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'damage')));
 v_new_hp:=GREATEST(-10,LEAST(v_max_hp,v_hp-v_damage_final)); v_target:=v_target||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp);
 v_scene:=v_scene||jsonb_build_object('tokens',jsonb_set(v_tokens,ARRAY[(v_target_index-1)::TEXT],v_target,FALSE)); UPDATE public.campaigns SET cba_data=v_scene WHERE id=p_campaign_id;
  PERFORM priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,v_new_hp,v_max_hp);
 RETURN jsonb_build_object('cba_data',v_scene,'hp',v_new_hp,'max_hp',v_max_hp,'ca',v_ca,'attack_total',v_attack_total,'damage',v_damage_final,'damage_roll',p_dano,'attack_effect_modifier',v_effective_attack_modifier,'target_ac_modifier',v_effective_ac_modifier);
END; $function$
;

-- aplicar_dano_token_ataque_srd_v2(p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer, p_bonus_ataque integer, p_dano integer, p_weapon_id text, p_attack_type text, p_power_penalty integer, p_sneak_attack_dice integer, p_sneak_attack_damage integer)
CREATE OR REPLACE FUNCTION public.aplicar_dano_token_ataque_srd_v2(p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer, p_bonus_ataque integer, p_dano integer, p_weapon_id text, p_attack_type text, p_power_penalty integer, p_sneak_attack_dice integer, p_sneak_attack_damage integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
 v_user UUID:=auth.uid(); v_campaign public.campaigns%ROWTYPE; v_combat JSONB; v_order JSONB; v_actor JSONB; v_scene JSONB; v_tokens JSONB; v_target JSONB;
 v_target_count INTEGER; v_target_index BIGINT; v_ca_text TEXT; v_ca INTEGER; v_max_hp INTEGER; v_hp INTEGER; v_new_hp INTEGER; v_attack_total INTEGER; v_round INTEGER;
 v_sheet public.srd_character_sheets%ROWTYPE; v_weapon public.srd_equipment%ROWTYPE; v_bab_progression TEXT; v_race_size TEXT;
 v_level INTEGER; v_bab INTEGER; v_str_score INTEGER; v_dex_score INTEGER; v_ability_mod INTEGER; v_ability_key TEXT;
 v_size_modifier INTEGER:=0; v_weapon_focus INTEGER:=0; v_power_penalty INTEGER:=0; v_range_penalty INTEGER:=0; v_expected_bonus INTEGER; v_racial_attack_bonus INTEGER:=0; v_target_traits TEXT;
 v_has_finesse BOOLEAN:=FALSE; v_has_power_attack BOOLEAN:=FALSE; v_weapon_name TEXT;
 v_effective_attack_modifier INTEGER:=0; v_effective_ac_modifier INTEGER:=0; v_damage_final INTEGER:=0; v_damage_type TEXT;
 v_attacker_count INTEGER; v_attacker_index BIGINT; v_attacker JSONB;
 v_attacker_size INTEGER:=1; v_target_size INTEGER:=1; v_reach_squares INTEGER:=1;
 v_ax INTEGER; v_ay INTEGER; v_bx INTEGER; v_by INTEGER; v_dx INTEGER; v_dy INTEGER; v_distance_squares INTEGER;
 v_range_increment_m NUMERIC; v_range_increments INTEGER; v_max_range_increments INTEGER:=10;
 v_class_weapon_proficiencies JSONB; v_weapon_proficiency_type TEXT; v_weapon_proficiency_penalty INTEGER:=0; v_weapon_focus_name TEXT;
 v_class_has_simple BOOLEAN:=FALSE; v_class_has_simple_martial BOOLEAN:=FALSE; v_class_has_exact_weapon BOOLEAN:=FALSE;
 v_has_simple_feat BOOLEAN:=FALSE; v_has_martial_feat BOOLEAN:=FALSE; v_has_exotic_feat BOOLEAN:=FALSE; v_is_dwarf_familiar_weapon BOOLEAN:=FALSE; v_is_proficient BOOLEAN:=FALSE; v_rogue_level INTEGER:=0; v_expected_sneak_dice INTEGER:=0; v_target_type TEXT;
BEGIN
 IF v_user IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
 IF p_d20 IS NULL OR p_d20<1 OR p_d20>20 THEN RAISE EXCEPTION 'Resultado de ataque inválido.'; END IF;
 IF p_bonus_ataque IS NULL OR p_bonus_ataque < -30 OR p_bonus_ataque > 60 THEN RAISE EXCEPTION 'Bônus de ataque inválido.'; END IF;
 IF p_dano IS NULL OR p_dano<1 OR p_dano>1000 THEN RAISE EXCEPTION 'Dano inválido.'; END IF;
 SELECT c.* INTO v_campaign FROM public.campaigns c WHERE c.id=p_campaign_id FOR UPDATE;
 IF NOT FOUND OR UPPER(COALESCE(v_campaign.state,''))<>'COMBATE' THEN RAISE EXCEPTION 'A campanha não está em combate.'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.characters ch JOIN public.members m ON m.campaign_id=ch.campaign_id AND m.user_id=ch.user_id AND m.role='PLAYER' WHERE ch.id::TEXT=BTRIM(p_character_id) AND ch.campaign_id=p_campaign_id AND ch.user_id=v_user) THEN RAISE EXCEPTION 'A ficha atacante não pertence ao jogador nesta campanha.'; END IF;
 v_combat:=COALESCE(v_campaign.combat_data,'{}'::JSONB);
 IF COALESCE(v_combat->>'active','false')<>'true' THEN RAISE EXCEPTION 'A iniciativa não está ativa.'; END IF;
 v_order:=CASE WHEN jsonb_typeof(v_combat->'turn_order')='array' THEN v_combat->'turn_order' ELSE '[]'::JSONB END;
 IF COALESCE(v_combat->>'current_turn','') !~ '^[0-9]+$' THEN RAISE EXCEPTION 'O turno atual é inválido.'; END IF;
 v_actor:=v_order->(v_combat->>'current_turn')::INTEGER;
 IF v_actor->>'id' IS DISTINCT FROM BTRIM(p_character_id) OR COALESCE(v_actor->>'is_monster','false')='true' THEN RAISE EXCEPTION 'Apenas o personagem ativo pode concluir este ataque.'; END IF;
 v_round:=CASE WHEN COALESCE(v_combat->>'round','') ~ '^[0-9]+$' THEN GREATEST(1,(v_combat->>'round')::INTEGER) ELSE 1 END;
 IF COALESCE(v_combat->'action_economy'->>'round','')<>v_round::TEXT OR COALESCE(v_combat->'action_economy'->'by_character'->BTRIM(p_character_id)->>'padrao','false')<>'true' THEN RAISE EXCEPTION 'A ação padrão do atacante ainda não foi consumida neste turno.'; END IF;
 v_scene:=COALESCE(v_campaign.cba_data,'{}'::JSONB); v_tokens:=CASE WHEN jsonb_typeof(v_scene->'tokens')='array' THEN v_scene->'tokens' ELSE '[]'::JSONB END;
 SELECT count(*)::INTEGER,min(t.ordinality),min(coalesce(t.token->>'ac',t.token->'monsterStats'->>'ca')) INTO v_target_count,v_target_index,v_ca_text FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(token,ordinality) WHERE t.token->>'id'=BTRIM(p_token_id) AND t.token->>'tipo' IN ('npc','monstro');
 IF v_target_count<>1 THEN RAISE EXCEPTION 'O alvo NPC/monstro não foi encontrado ou está duplicado.'; END IF;
 v_target:=v_tokens->(v_target_index::INTEGER-1);
 IF p_attack_type IS NULL OR p_attack_type NOT IN ('atk-corpo','atk-dist') THEN RAISE EXCEPTION 'Tipo de ataque inválido.'; END IF;
 v_power_penalty:=COALESCE(p_power_penalty,0);
 IF v_power_penalty<0 THEN RAISE EXCEPTION 'Penalidade de Ataque Poderoso inválida.'; END IF;
 SELECT sh.* INTO v_sheet
 FROM public.characters ch JOIN public.srd_character_sheets sh ON sh.character_id=ch.id
 WHERE ch.id::TEXT=BTRIM(p_character_id) AND ch.campaign_id=p_campaign_id AND ch.user_id=v_user;
 IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD 3.5 do atacante não encontrada.'; END IF;
 SELECT COALESCE(
   MAX(cl.class_level) FILTER (WHERE cls.class_key='rogue'),
   CASE WHEN NOT EXISTS (SELECT 1 FROM public.srd_character_class_levels any_level WHERE any_level.character_id=v_sheet.character_id)
          AND v_sheet.classe_id='ladino' THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
 ) INTO v_rogue_level
 FROM public.srd_character_sheets sh
 LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
 LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
 WHERE sh.character_id=v_sheet.character_id
 GROUP BY sh.character_id,sh.classe_id,sh.nivel;
 v_expected_sneak_dice:=LEAST(10,FLOOR((COALESCE(v_rogue_level,0)+1)/2.0)::INTEGER);
 v_target_type:=lower(COALESCE(v_target->'monsterStats'->>'creature_type',v_target->'monsterStats'->>'type',v_target->>'creature_type',''));
 IF COALESCE(p_sneak_attack_dice,0)<0 OR COALESCE(p_sneak_attack_damage,0)<0 THEN RAISE EXCEPTION 'Dados de Ataque Furtivo inválidos.'; END IF;
 IF COALESCE(p_sneak_attack_dice,0)>0 THEN
   IF p_sneak_attack_dice<>v_expected_sneak_dice OR p_sneak_attack_damage<p_sneak_attack_dice OR p_sneak_attack_damage>p_sneak_attack_dice*6 THEN
     RAISE EXCEPTION 'Rolagem de Ataque Furtivo não corresponde ao nível do Ladino.';
   END IF;
   IF NOT (priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'loses_dex_ac')
        OR priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'loses_dex_ac_vs_non_grapplers')) THEN
     RAISE EXCEPTION 'Ataque Furtivo exige que o alvo perca seu bônus de Destreza na CA; flanqueamento ainda não foi validado pelo motor.';
   END IF;
   IF v_target_type IN ('undead','construct','ooze','plant','elemental','incorporeal') THEN
     RAISE EXCEPTION 'Este tipo de criatura é imune a Ataque Furtivo.';
   END IF;

 ELSE
   IF COALESCE(p_sneak_attack_damage,0)<>0 THEN RAISE EXCEPTION 'Dano de Ataque Furtivo sem dados declarados.';
   END IF;
 END IF;
 SELECT cl.bab_progression,r.tamanho,cl.dados_tecnicos->'proficiencias'->'armas' INTO v_bab_progression,v_race_size,v_class_weapon_proficiencies
 FROM public.srd_classes cl CROSS JOIN public.srd_races r
 WHERE cl.id=v_sheet.classe_id AND r.id=v_sheet.raca_id;
 IF NOT FOUND THEN RAISE EXCEPTION 'Classe ou raça da ficha não encontrada.'; END IF;
 v_level:=GREATEST(1,COALESCE(v_sheet.nivel,1));
 v_bab:=CASE lower(COALESCE(v_bab_progression,''))
   WHEN 'good' THEN v_level WHEN 'bom' THEN v_level
   WHEN 'average' THEN FLOOR(3*v_level/4)::INTEGER WHEN 'medium' THEN FLOOR(3*v_level/4)::INTEGER WHEN 'medio' THEN FLOOR(3*v_level/4)::INTEGER
   WHEN 'poor' THEN FLOOR(v_level/2)::INTEGER WHEN 'ruim' THEN FLOOR(v_level/2)::INTEGER ELSE 0 END;
 v_str_score:=CASE WHEN COALESCE(v_sheet.atributos->>'FOR','') ~ '^[0-9]+$' THEN (v_sheet.atributos->>'FOR')::INTEGER ELSE 10 END;
 v_dex_score:=CASE WHEN COALESCE(v_sheet.atributos->>'DES','') ~ '^[0-9]+$' THEN (v_sheet.atributos->>'DES')::INTEGER ELSE 10 END;
 v_has_finesse:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_weapon_finesse');
 v_has_power_attack:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='ataque_poderoso');
 IF NULLIF(BTRIM(p_weapon_id),'') IS NOT NULL THEN
   SELECT eq.* INTO v_weapon FROM public.srd_character_equipment ce JOIN public.srd_equipment eq ON eq.id=ce.equipment_id
   WHERE ce.character_id=v_sheet.character_id AND ce.equipment_id=BTRIM(p_weapon_id) AND ce.equipado IS TRUE AND public.srd35_equipment_slot(eq.categoria,eq.nome)='arma' AND EXISTS (SELECT 1 FROM public.srd_character_weapon_instances wi WHERE wi.character_id=ce.character_id AND wi.equipment_id=ce.equipment_id AND wi.equipado IS TRUE AND wi.hand_slot='main_hand');
   IF NOT FOUND THEN RAISE EXCEPTION 'A arma informada não está equipada nesta ficha.'; END IF;
 END IF;
 v_weapon_name:=COALESCE(v_weapon.detalhes->>'weapon_proficiency_name',v_weapon.nome,'Ataque desarmado'); v_weapon_focus_name:=COALESCE(v_weapon.detalhes->>'weapon_focus_name',v_weapon.nome,'Ataque desarmado');
 
v_weapon_proficiency_type:=priv.srd_weapon_proficiency(v_weapon.detalhes,v_weapon_name);
v_is_dwarf_familiar_weapon:=v_sheet.raca_id='anao'
  AND regexp_replace(lower(translate(v_weapon_name,'ã','a')),'[^a-z0-9]+','','g')
    IN ('waraxedwarven','dwarvenwaraxe','urgroshdwarven','dwarvenurgrosh','machadodeguerraanao','urgroshanao');

 IF v_weapon.id IS NOT NULL THEN
   v_class_has_simple:=EXISTS(
     SELECT 1 FROM jsonb_array_elements_text(CASE WHEN jsonb_typeof(v_class_weapon_proficiencies)='array' THEN v_class_weapon_proficiencies ELSE '[]'::JSONB END) p(value)
     WHERE lower(BTRIM(p.value))='armas simples'
   );
   v_class_has_simple_martial:=EXISTS(
     SELECT 1 FROM jsonb_array_elements_text(CASE WHEN jsonb_typeof(v_class_weapon_proficiencies)='array' THEN v_class_weapon_proficiencies ELSE '[]'::JSONB END) p(value)
     WHERE lower(BTRIM(p.value))='todas as armas simples e marciais'
   );
   v_class_has_exact_weapon:=EXISTS(
     SELECT 1 FROM jsonb_array_elements_text(CASE WHEN jsonb_typeof(v_class_weapon_proficiencies)='array' THEN v_class_weapon_proficiencies ELSE '[]'::JSONB END) p(value)
     WHERE public.srd35_normalizar_parametro_talento(p.value)=public.srd35_normalizar_parametro_talento(v_weapon_name)
   );
   v_has_simple_feat:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_simple_weapon_proficiency');
   v_has_martial_feat:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_martial_weapon_proficiency' AND public.srd35_normalizar_parametro_talento(COALESCE(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name));
   v_has_exotic_feat:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_exotic_weapon_proficiency' AND public.srd35_normalizar_parametro_talento(COALESCE(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name));
   v_is_proficient:=CASE
     WHEN v_weapon_proficiency_type='simple' THEN v_class_has_exact_weapon OR v_class_has_simple OR v_class_has_simple_martial OR v_has_simple_feat
     WHEN v_weapon_proficiency_type='martial' THEN v_class_has_exact_weapon OR v_class_has_simple_martial OR v_has_martial_feat
     WHEN v_weapon_proficiency_type='exotic' THEN
       v_class_has_exact_weapon OR v_has_exotic_feat
       OR (v_is_dwarf_familiar_weapon AND (v_class_has_simple_martial OR v_has_martial_feat))
     ELSE FALSE END;
   v_weapon_proficiency_penalty:=CASE WHEN v_is_proficient THEN 0 ELSE 4 END;
 END IF;
 IF p_attack_type='atk-dist' THEN
   IF v_weapon.id IS NULL OR COALESCE(v_weapon.detalhes->>'weapon_ranged','false')<>'true' THEN RAISE EXCEPTION 'A arma equipada não permite ataque à distância.'; END IF;
   v_ability_key:='DES';
 ELSE
   IF v_weapon.id IS NOT NULL AND COALESCE(v_weapon.detalhes->>'weapon_melee','true')='false' THEN RAISE EXCEPTION 'A arma equipada não permite ataque corpo a corpo.'; END IF;
   IF v_has_finesse AND v_bab<1 THEN RAISE EXCEPTION 'Acuidade com Arma exige bônus base de ataque +1.'; END IF;
 IF v_has_finesse AND (v_weapon.id IS NULL OR COALESCE(v_weapon.detalhes->>'weapon_finesse_eligible','false')='true') THEN v_ability_key:='DES'; ELSE v_ability_key:='FOR'; END IF;
 END IF;
 v_ability_mod:=FLOOR(((CASE WHEN v_ability_key='DES' THEN v_dex_score ELSE v_str_score END)-10)::NUMERIC/2)::INTEGER;
 v_size_modifier:=CASE WHEN lower(COALESCE(v_race_size,'')) IN ('pequeno','small') THEN 1 ELSE 0 END;
 SELECT (CASE WHEN EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='foco_em_arma' AND public.srd35_normalizar_parametro_talento(COALESCE(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_focus_name)) THEN 1 ELSE 0 END)+(CASE WHEN EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_greater_weapon_focus' AND public.srd35_normalizar_parametro_talento(COALESCE(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_focus_name)) THEN 1 ELSE 0 END) INTO v_weapon_focus;
 IF v_power_penalty>0 AND (p_attack_type<>'atk-corpo' OR (v_weapon.id IS NOT NULL AND COALESCE(v_weapon.detalhes->>'weapon_light','false')='true') OR NOT v_has_power_attack OR v_power_penalty>v_bab) THEN RAISE EXCEPTION 'Ataque Poderoso inválido para esta ficha ou ataque.'; END IF;
 SELECT count(*)::INTEGER,min(t.ordinality) INTO v_attacker_count,v_attacker_index
 FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(token,ordinality)
 WHERE t.token->>'id'=BTRIM(p_character_id) AND t.token->>'tipo'='player';
 IF v_attacker_count<>1 THEN RAISE EXCEPTION 'O token do personagem atacante não foi encontrado ou está duplicado.'; END IF;
 v_attacker:=v_tokens->(v_attacker_index::INTEGER-1);
 v_attacker_size:=CASE
   WHEN lower(COALESCE(v_race_size,'')) LIKE 'large%' OR lower(COALESCE(v_race_size,'')) LIKE 'grande%' THEN 2
   WHEN lower(COALESCE(v_race_size,'')) LIKE 'huge%' OR lower(COALESCE(v_race_size,'')) LIKE 'enorme%' THEN 3
   WHEN lower(COALESCE(v_race_size,'')) LIKE 'gargantuan%' OR lower(COALESCE(v_race_size,'')) LIKE 'imenso%' THEN 4
   WHEN lower(COALESCE(v_race_size,'')) LIKE 'colossal%' THEN 5 ELSE 1 END;
 v_target_size:=CASE
   WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'large%' OR lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'grande%' THEN 2
   WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'huge%' OR lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'enorme%' THEN 3
   WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'gargantuan%' OR lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'imenso%' THEN 4
   WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'colossal%' THEN 5 ELSE 1 END;
 IF COALESCE(v_attacker->>'gridX','') !~ '^-?[0-9]+$' OR COALESCE(v_attacker->>'gridY','') !~ '^-?[0-9]+$' OR COALESCE(v_target->>'gridX','') !~ '^-?[0-9]+$' OR COALESCE(v_target->>'gridY','') !~ '^-?[0-9]+$' THEN RAISE EXCEPTION 'Posição de token inválida para calcular alcance.'; END IF;
 v_ax:=(v_attacker->>'gridX')::INTEGER; v_ay:=(v_attacker->>'gridY')::INTEGER; v_bx:=(v_target->>'gridX')::INTEGER; v_by:=(v_target->>'gridY')::INTEGER;
 v_dx:=GREATEST(0,v_bx-(v_ax+v_attacker_size-1),v_ax-(v_bx+v_target_size-1));
 v_dy:=GREATEST(0,v_by-(v_ay+v_attacker_size-1),v_ay-(v_by+v_target_size-1));
 v_distance_squares:=GREATEST(v_dx,v_dy)+FLOOR(LEAST(v_dx,v_dy)::NUMERIC/2)::INTEGER;
 IF p_attack_type='atk-dist' AND COALESCE(p_sneak_attack_dice,0)>0 AND v_distance_squares>6 THEN RAISE EXCEPTION 'Ataque Furtivo à distância exige até 9 metros.'; END IF;
 IF p_attack_type='atk-corpo' THEN
   v_reach_squares:=GREATEST(1,v_attacker_size);
   IF v_distance_squares>v_reach_squares THEN RAISE EXCEPTION 'Alvo fora do alcance corpo a corpo.'; END IF;
 ELSE
   v_range_increment_m:=NULLIF(v_weapon.detalhes->>'range_increment_m','')::NUMERIC;
   IF v_range_increment_m IS NULL OR v_range_increment_m<=0 THEN RAISE EXCEPTION 'Incremento de distância da arma não cadastrado.'; END IF;
   v_range_increments:=GREATEST(1,CEIL((v_distance_squares*1.5)/v_range_increment_m)::INTEGER);
   v_max_range_increments:=COALESCE(NULLIF(v_weapon.detalhes->>'max_range_increments','')::INTEGER,10); IF v_range_increments>v_max_range_increments THEN RAISE EXCEPTION 'Alvo fora do alcance máximo de % incrementos da arma.',v_max_range_increments; END IF;
   v_range_penalty:=(v_range_increments-1)*2;
 END IF;
 
v_target_traits:=lower(concat_ws(' ',
  v_target->>'nome',v_target->>'detalhe',
  v_target->'monsterStats'->>'tipo',v_target->'monsterStats'->>'subtipo',
  v_target->'monsterStats'->>'subtype',v_target->'monsterStats'->>'subtypes',
  v_target->'monsterStats'->>'type',v_target->'monsterStats'->>'creature_type',
  v_target->'monsterStats'->>'race_id',v_target->>'creature_type',
  (SELECT lower(sh.raca_id::text) FROM public.srd_character_sheets sh
    WHERE sh.character_id::text=CASE
      WHEN v_target->>'tipo'='player' THEN v_target->>'id'
      WHEN v_target->>'tipo'='npc' THEN v_target->>'sourceCharacterId'
      ELSE NULL END LIMIT 1)
));
IF v_sheet.raca_id='anao'
   AND v_target_traits ~ '(^|[^a-z])(orc|goblin|hobgoblin|bugbear|goblinoid(e)?)([^a-z]|$)' THEN
  v_racial_attack_bonus:=1;
ELSIF v_sheet.raca_id='gnomo'
   AND v_target_traits ~ '(^|[^a-z])(kobold|goblin|hobgoblin|bugbear|goblinoid(e)?)([^a-z]|$)' THEN
  v_racial_attack_bonus:=1;
ELSIF v_sheet.raca_id='halfling'
   AND p_attack_type='atk-dist'
   AND (
     COALESCE(v_weapon.detalhes->>'weapon_ranged_type','')='thrown'
     OR lower(COALESCE(v_weapon.nome,''))='funda'
   ) THEN
  v_racial_attack_bonus:=1;
END IF;
v_expected_bonus:=v_bab+v_ability_mod+v_size_modifier+v_weapon_focus-v_power_penalty-v_range_penalty-v_weapon_proficiency_penalty+v_racial_attack_bonus;

 IF p_bonus_ataque>v_expected_bonus OR p_bonus_ataque<v_expected_bonus-30 THEN RAISE EXCEPTION 'Bônus de ataque excede o bônus calculado da ficha ou aplica penalidade inválida. Máximo: %, recebido: %.',v_expected_bonus,p_bonus_ataque; END IF;
 IF priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_character_id),'no_actions') OR priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_character_id),'cannot_attack') THEN RAISE EXCEPTION 'A condição atual impede ataques.'; END IF;
 v_effective_attack_modifier:=priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'attack')+CASE WHEN p_attack_type='atk-corpo' THEN priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'attack_melee')+FLOOR((v_str_score+priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'strength')-10)::numeric/2)::integer-FLOOR((v_str_score-10)::numeric/2)::integer ELSE priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'attack_ranged')+FLOOR((v_dex_score+priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'dexterity')-10)::numeric/2)::integer-FLOOR((v_dex_score-10)::numeric/2)::integer END;
 IF COALESCE(v_ca_text,'') !~ '[0-9]{1,3}' THEN RAISE EXCEPTION 'O token alvo precisa ter uma CA numérica.'; END IF;
 v_effective_ac_modifier:=priv.srd_effective_modifier(p_campaign_id,'token',BTRIM(p_token_id),'ac')+CASE WHEN p_attack_type='atk-corpo' THEN priv.srd_effective_modifier(p_campaign_id,'token',BTRIM(p_token_id),'ac_melee') ELSE priv.srd_effective_modifier(p_campaign_id,'token',BTRIM(p_token_id),'ac_ranged') END;
 v_ca:=substring(v_ca_text from '[0-9]{1,3}')::INTEGER+v_effective_ac_modifier; v_attack_total:=p_d20+p_bonus_ataque+v_effective_attack_modifier;
 IF p_d20=1 OR (p_d20<>20 AND v_attack_total<v_ca) THEN RAISE EXCEPTION 'Ataque não atingiu a CA do alvo (%). Nenhum dano foi aplicado.',v_ca; END IF;
 v_target:=v_tokens->(v_target_index::INTEGER-1);
 IF COALESCE(v_target->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN RAISE EXCEPTION 'O alvo não possui PV máximo configurado.'; END IF;
 v_max_hp:=(v_target->>'maxHp')::INTEGER; v_hp:=CASE WHEN COALESCE(v_target->>'hp','') ~ '^-?[0-9]{1,6}$' THEN (v_target->>'hp')::INTEGER ELSE v_max_hp END;
 v_damage_type:=CASE lower(COALESCE(v_weapon.tipo_dano,'bludgeoning')) WHEN 'cortante' THEN 'slashing' WHEN 'perfurante' THEN 'piercing' WHEN 'impacto' THEN 'bludgeoning' WHEN 'cortante/perfurante' THEN 'physical' WHEN 'impacto/perfurante' THEN 'physical' ELSE lower(COALESCE(v_weapon.tipo_dano,'bludgeoning')) END;
 v_damage_final:=priv.srd_adjust_damage(p_campaign_id,'token',BTRIM(p_token_id),v_damage_type,GREATEST(0,p_dano+COALESCE(p_sneak_attack_damage,0)+priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'damage')));
 v_new_hp:=GREATEST(-10,LEAST(v_max_hp,v_hp-v_damage_final)); v_target:=v_target||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp);
 v_scene:=v_scene||jsonb_build_object('tokens',jsonb_set(v_tokens,ARRAY[(v_target_index-1)::TEXT],v_target,FALSE)); UPDATE public.campaigns SET cba_data=v_scene WHERE id=p_campaign_id;
  PERFORM priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,v_new_hp,v_max_hp);
 RETURN jsonb_build_object('cba_data',v_scene,'hp',v_new_hp,'max_hp',v_max_hp,'ca',v_ca,'attack_total',v_attack_total,'damage',v_damage_final,'damage_roll',p_dano,'attack_effect_modifier',v_effective_attack_modifier,'target_ac_modifier',v_effective_ac_modifier);
END; $function$
;

-- aplicar_dano_token_gm_personagem_srd(p_campaign_id bigint, p_token_id text, p_character_id text, p_dano integer)
CREATE OR REPLACE FUNCTION public.aplicar_dano_token_gm_personagem_srd(p_campaign_id bigint, p_token_id text, p_character_id text, p_dano integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
DECLARE
  v_campaign public.campaigns%ROWTYPE;
  v_combat JSONB;
  v_order JSONB;
  v_current INTEGER;
  v_actor JSONB;
  v_hp INTEGER;
  v_max_hp INTEGER;
  v_new_hp INTEGER;
  v_damage_final INTEGER;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  IF p_dano IS NULL OR p_dano<1 OR p_dano>1000 THEN RAISE EXCEPTION 'Dano inválido.'; END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.members m
    WHERE m.campaign_id=p_campaign_id AND m.user_id=auth.uid() AND m.role='GM'
  ) THEN RAISE EXCEPTION 'Somente o Mestre da campanha pode resolver dano de criatura.'; END IF;
  SELECT c.* INTO v_campaign FROM public.campaigns c WHERE c.id=p_campaign_id FOR UPDATE;
  IF NOT FOUND OR UPPER(COALESCE(v_campaign.state,''))<>'COMBATE' THEN RAISE EXCEPTION 'A campanha não está em combate.'; END IF;
  v_combat:=COALESCE(v_campaign.combat_data,'{}'::JSONB);
  IF COALESCE(v_combat->>'active','false')<>'true' THEN RAISE EXCEPTION 'A iniciativa não está ativa.'; END IF;
  v_order:=CASE WHEN jsonb_typeof(v_combat->'turn_order')='array' THEN v_combat->'turn_order' ELSE '[]'::JSONB END;
  IF COALESCE(v_combat->>'current_turn','') !~ '^[0-9]+$' THEN RAISE EXCEPTION 'O turno atual é inválido.'; END IF;
  v_current:=(v_combat->>'current_turn')::INTEGER;
  v_actor:=v_order->v_current;
  IF COALESCE(v_actor->>'is_monster','false')<>'true' OR v_actor->>'id' IS DISTINCT FROM BTRIM(p_token_id) THEN
    RAISE EXCEPTION 'O token atacante não pertence ao turno ativo do Mestre.';
  END IF;
  SELECT s.pv_atual,s.pv_max INTO v_hp,v_max_hp
  FROM public.characters c
  JOIN public.members m ON m.campaign_id=c.campaign_id AND m.user_id=c.user_id AND m.role='PLAYER'
  JOIN public.srd_character_sheets s ON s.character_id::TEXT=c.id::TEXT
  WHERE c.id::TEXT=BTRIM(p_character_id) AND c.campaign_id=p_campaign_id
  FOR UPDATE OF s;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha de jogador não encontrada nesta campanha.'; END IF;
  IF v_max_hp IS NULL OR v_max_hp<1 THEN RAISE EXCEPTION 'A ficha não possui um PV máximo válido.'; END IF;
  v_damage_final:=priv.srd_adjust_damage(p_campaign_id,'character',BTRIM(p_character_id),'untyped',p_dano);
  v_new_hp:=GREATEST(-10,LEAST(v_max_hp,COALESCE(v_hp,v_max_hp)-v_damage_final));
  PERFORM priv.srd_sync_character_vital_condition(BTRIM(p_character_id),v_new_hp,false);
  UPDATE public.srd_character_sheets SET pv_atual=v_new_hp WHERE character_id::TEXT=BTRIM(p_character_id);
  RETURN jsonb_build_object('character_id',BTRIM(p_character_id),'pv_atual',v_new_hp,'pv_max',v_max_hp,'dano',v_damage_final,'dano_bruto',p_dano);
END;
$function$
;

-- apply_condition(p_char bigint, p_condition text, p_origem text, p_duracao text)
CREATE OR REPLACE FUNCTION public.apply_condition(p_char bigint, p_condition text, p_origem text DEFAULT NULL::text, p_duracao text DEFAULT NULL::text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
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
$function$
;

-- apply_damage(p_alvo bigint, p_qtd integer, p_tipo text)
CREATE OR REPLACE FUNCTION public.apply_damage(p_alvo bigint, p_qtd integer, p_tipo text DEFAULT 'Impacto'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE d public.tokens; v_role text; v_now integer; v_max integer; v_kind text;
BEGIN
  IF p_qtd IS NULL OR p_qtd<0 THEN RAISE EXCEPTION 'Dano inválido.'; END IF;
  SELECT * INTO d FROM public.tokens WHERE id=p_alvo FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Alvo inexistente.'; END IF;
  PERFORM priv.need_gm(d.campaign_id);
  v_role:=public.my_role(d.campaign_id);
  IF v_role IS NULL THEN RAISE EXCEPTION 'Sem permissão.'; END IF;
  IF d.character_id IS NOT NULL THEN
    SELECT pv_atual,pv_max INTO v_now,v_max FROM public.srd_character_sheets WHERE character_id=d.character_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD do alvo inexistente.'; END IF;
    v_kind:='character';
    v_now:=greatest(0,v_now-p_qtd);
    UPDATE public.srd_character_sheets SET pv_atual=v_now WHERE character_id=d.character_id;
  ELSIF d.monster_instance_id IS NOT NULL THEN
    SELECT hp_atual,hp_max INTO v_now,v_max FROM public.monster_instances WHERE id=d.monster_instance_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Instância de monstro inexistente.'; END IF;
    v_kind:='monster';
    v_now:=greatest(0,v_now-p_qtd);
    UPDATE public.monster_instances SET hp_atual=v_now WHERE id=d.monster_instance_id;
  ELSE
    RAISE EXCEPTION 'Token sem ficha ou instância.';
  END IF;
  INSERT INTO public.roll_log(campaign_id,tipo,autor_id,alvo_id,expressao,total,resultado,detalhes)
  VALUES(d.campaign_id,'DANO',auth.uid(),d.id,p_tipo,p_qtd,CASE WHEN v_now=0 THEN 'QUEDA' ELSE 'DANO' END,
         jsonb_build_object('pv_apos',v_now,'pv_max',v_max,'alvo_tipo',v_kind));
  RETURN jsonb_build_object('pv',v_now,'pv_max',v_max,'dano',p_qtd,'alvo_tipo',v_kind);
END $function$
;

-- apply_heal(p_alvo bigint, p_qtd integer)
CREATE OR REPLACE FUNCTION public.apply_heal(p_alvo bigint, p_qtd integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE d public.tokens; v_role text; v_now integer; v_max integer; v_kind text;
BEGIN
  IF p_qtd IS NULL OR p_qtd<0 THEN RAISE EXCEPTION 'Cura inválida.'; END IF;
  SELECT * INTO d FROM public.tokens WHERE id=p_alvo FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Alvo inexistente.'; END IF;
  PERFORM priv.need_gm(d.campaign_id);
  v_role:=public.my_role(d.campaign_id);
  IF v_role IS NULL THEN RAISE EXCEPTION 'Sem permissão.'; END IF;
  IF d.character_id IS NOT NULL THEN
    SELECT pv_atual,pv_max INTO v_now,v_max FROM public.srd_character_sheets WHERE character_id=d.character_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD do alvo inexistente.'; END IF;
    v_kind:='character'; v_now:=least(v_max,v_now+p_qtd);
    UPDATE public.srd_character_sheets SET pv_atual=v_now WHERE character_id=d.character_id;
  ELSIF d.monster_instance_id IS NOT NULL THEN
    SELECT hp_atual,hp_max INTO v_now,v_max FROM public.monster_instances WHERE id=d.monster_instance_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Instância de monstro inexistente.'; END IF;
    v_kind:='monster'; v_now:=least(v_max,v_now+p_qtd);
    UPDATE public.monster_instances SET hp_atual=v_now WHERE id=d.monster_instance_id;
  ELSE
    RAISE EXCEPTION 'Token sem ficha ou instância.';
  END IF;
  INSERT INTO public.roll_log(campaign_id,tipo,autor_id,alvo_id,total,resultado,detalhes)
  VALUES(d.campaign_id,'CURA',auth.uid(),d.id,p_qtd,'CURA',jsonb_build_object('pv_apos',v_now,'pv_max',v_max,'alvo_tipo',v_kind));
  RETURN jsonb_build_object('pv',v_now,'pv_max',v_max,'cura',p_qtd,'alvo_tipo',v_kind);
END $function$
;

-- ask_roll(cid bigint, p_to uuid, p_kind text, p_label text, p_atributo text, p_cd integer, p_motivo text)
CREATE OR REPLACE FUNCTION public.ask_roll(cid bigint, p_to uuid, p_kind text, p_label text, p_atributo text DEFAULT NULL::text, p_cd integer DEFAULT NULL::integer, p_motivo text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare rid bigint;
begin
  perform priv.need_gm(cid);
  if p_kind not in ('PERICIA','RESISTENCIA','INICIATIVA','LIVRE') then
    raise exception 'Tipo de pedido inválido.';
  end if;
  if p_label is null or char_length(trim(p_label)) < 1 or char_length(p_label) > 80 then
    raise exception 'Rótulo entre 1 e 80 caracteres.';
  end if;
  if p_atributo is not null and p_atributo not in ('FOR','DES','CON','INT','SAB','CAR') then
    raise exception 'Atributo inválido.';
  end if;
  if not exists (select 1 from public.members where campaign_id = cid and user_id = p_to) then
    raise exception 'Destinatário não está na mesa.';
  end if;
  insert into public.roll_requests(campaign_id, from_id, to_id, kind, label, atributo, cd, motivo)
  values (cid, auth.uid(), p_to, p_kind, trim(p_label), p_atributo, p_cd, p_motivo)
  returning id into rid;

  perform priv.log(cid, 'PEDIDO_ROLAGEM',
    jsonb_build_object('pedido', rid, 'para', p_to, 'label', trim(p_label), 'atributo', p_atributo, 'cd', p_cd));

  return jsonb_build_object('ok', true, 'id', rid);
end $function$
;

-- attack(p_atk bigint, p_alvo bigint, p_tipo text)
CREATE OR REPLACE FUNCTION public.attack(p_atk bigint, p_alvo bigint, p_tipo text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  a public.tokens;
  d public.tokens;
  a_char public.characters;
  d_char public.characters;
  a_sheet public.srd_character_sheets;
  d_sheet public.srd_character_sheets;
  a_monster public.monster_instances;
  d_monster public.monster_instances;
  a_monster_def public.srd_monsters;
  d_monster_def public.srd_monsters;
  v_mod integer := 0;
  v_d20 integer;
  v_total integer;
  v_defense integer;
  v_defense_type text := 'CA';
  v_target_rm integer;
  v_crit boolean;
  v_fumble boolean;
  v_hit boolean;
  v_result text;
  v_score integer;
  v_damage_dice text;
BEGIN
  IF p_tipo NOT IN ('corporal','precisao','magico') THEN
    RAISE EXCEPTION 'Tipo inválido.';
  END IF;

  SELECT * INTO a FROM public.tokens WHERE id = p_atk;
  IF NOT FOUND THEN RAISE EXCEPTION 'Atacante inexistente.'; END IF;

  SELECT * INTO d FROM public.tokens WHERE id = p_alvo;
  IF NOT FOUND THEN RAISE EXCEPTION 'Alvo inexistente.'; END IF;

  IF a.campaign_id <> d.campaign_id THEN
    RAISE EXCEPTION 'Tokens de mesas diferentes.';
  END IF;

  IF public.my_role(a.campaign_id) IS NULL THEN
    RAISE EXCEPTION 'Você não participa desta mesa.';
  END IF;

  IF public.my_role(a.campaign_id) = 'PLAYER' THEN
    IF a.character_id IS NULL THEN
      RAISE EXCEPTION 'Jogador só pode atacar com token de personagem.';
    END IF;
    SELECT * INTO a_char FROM public.characters WHERE id = a.character_id;
    IF a_char.user_id IS DISTINCT FROM auth.uid() THEN
      RAISE EXCEPTION 'Você só ataca com o seu token.';
    END IF;
    IF NOT priv.is_my_turn(a.campaign_id, a.id) THEN
      RAISE EXCEPTION 'Não é o seu turno.';
    END IF;
  END IF;

  IF p_tipo = 'corporal' AND public.hex_dist(a.col, a.row, d.col, d.row) > 1 THEN
    RAISE EXCEPTION 'Alvo fora de alcance corpo a corpo.';
  END IF;

  IF a.character_id IS NOT NULL THEN
    SELECT * INTO a_sheet FROM public.srd_character_sheets
    WHERE character_id = a.character_id;
    v_score := NULLIF(public._srd35_attr(
      a_sheet.atributos,
      CASE WHEN p_tipo = 'corporal' THEN ARRAY['FOR','STR']::text[]
           WHEN p_tipo = 'precisao' THEN ARRAY['DES','DEX']::text[]
           ELSE ARRAY['INT']::text[] END
    ), '')::integer;
    v_mod := floor((COALESCE(v_score,10)-10)::numeric / 2)::integer;

    SELECT e.dano INTO v_damage_dice
    FROM public.srd_character_equipment ce
    JOIN public.srd_equipment e ON e.id = ce.equipment_id
    WHERE ce.character_id = a.character_id
      AND ce.equipado
      AND public.srd35_equipment_slot(e.categoria,e.nome) = 'arma'
    ORDER BY ce.criado_em
    LIMIT 1;
  ELSE
    SELECT * INTO a_monster FROM public.monster_instances
    WHERE id = a.monster_instance_id;
    IF a_monster.monster_id IS NOT NULL THEN
      SELECT * INTO a_monster_def FROM public.srd_monsters
      WHERE id = a_monster.monster_id;
      v_mod := COALESCE((regexp_match(a_monster_def.base_attack_grapple, '[-+]?[0-9]+'))[1]::integer, 0);
    END IF;
  END IF;

  IF d.character_id IS NOT NULL THEN
    SELECT * INTO d_sheet FROM public.srd_character_sheets
    WHERE character_id = d.character_id;
    v_score := NULLIF(public._srd35_attr(d_sheet.atributos, ARRAY['DES','DEX']::text[]), '')::integer;
    v_defense := 10 + floor((COALESCE(v_score,10)-10)::numeric / 2)::integer;
    SELECT v_defense + COALESCE(sum(public.srd35_equipment_ca_bonus(equipment_id)),0)
      INTO v_defense
    FROM public.srd_character_equipment
    WHERE character_id = d.character_id AND equipado;
  ELSE
    SELECT * INTO d_monster FROM public.monster_instances
    WHERE id = d.monster_instance_id;
    IF d_monster.monster_id IS NOT NULL THEN
      SELECT * INTO d_monster_def FROM public.srd_monsters
      WHERE id = d_monster.monster_id;
      v_defense := COALESCE((regexp_match(d_monster_def.ca, '([0-9]+)'))[1]::integer, 10);
      v_target_rm := NULLIF((regexp_match(COALESCE(d_monster_def.dados_tecnicos->>'resistencia_magia',''), '([0-9]+)'))[1], '')::integer;
    ELSE
      v_defense := 10;
    END IF;
  END IF;

  IF p_tipo = 'magico' THEN
    IF v_target_rm IS NULL THEN
      RAISE EXCEPTION 'Resistência à magia do alvo não está disponível para resolução automática.';
    END IF;
    v_defense := v_target_rm;
    v_defense_type := 'RM';
  END IF;

  v_d20 := priv.d20();
  v_total := v_d20 + v_mod;
  v_crit := v_d20 = 20;
  v_fumble := v_d20 = 1;
  v_hit := v_crit OR (NOT v_fumble AND v_total >= v_defense);

  IF v_crit THEN v_result := 'CRITICO';
  ELSIF v_fumble THEN v_result := 'FALHA_AUTO';
  ELSIF v_hit THEN v_result := 'ACERTO';
  ELSE v_result := 'ERRO';
  END IF;

  INSERT INTO public.roll_log(campaign_id,tipo,autor_id,alvo_id,expressao,d20,total,resultado,detalhes)
  VALUES (
    a.campaign_id,'ATAQUE',auth.uid(),d.id,p_tipo,v_d20,v_total,v_result,
    jsonb_build_object(
      'mod',v_mod,'defesa',v_defense,'defesa_tipo',v_defense_type,
      'dano_dice',v_damage_dice,'dano_pendente',v_hit AND v_damage_dice IS NULL,
      'fonte_esquema','tokens.col/row + SRD character/monster data'
    )
  );

  RETURN jsonb_build_object(
    'acertou',v_hit,'critico',v_crit,'falha',v_fumble,
    'd20',v_d20,'mod',v_mod,'total',v_total,
    'defesa',v_defense,'defesa_tipo',v_defense_type,
    'dano_dice',v_damage_dice,
    'dano_pendente',v_hit AND v_damage_dice IS NULL
  );
END;
$function$
;

-- attr_max(p_nivel integer)
CREATE OR REPLACE FUNCTION public.attr_max(p_nivel integer)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  select case when p_nivel <= 1 then 3 else 2 * p_nivel end
$function$
;

-- attr_points(p_nivel integer)
CREATE OR REPLACE FUNCTION public.attr_points(p_nivel integer)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  select 15 + 3 * (p_nivel - 1)
$function$
;

-- atualizar_configuracoes_campanha(p_campaign_id bigint, p_name text, p_require_code boolean, p_code text)
CREATE OR REPLACE FUNCTION public.atualizar_configuracoes_campanha(p_campaign_id bigint, p_name text, p_require_code boolean, p_code text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare
  v_uid uuid := auth.uid();
  v_name text := btrim(coalesce(p_name, ''));
begin
  if v_uid is null then raise exception 'Não autenticado.'; end if;
  if not exists (
    select 1 from public.campaigns
    where id = p_campaign_id and owner_id = v_uid and active
    for update
  ) then raise exception 'Somente o criador da mesa pode alterar suas configurações.'; end if;
  if char_length(v_name) < 2 or char_length(v_name) > 60 then
    raise exception 'O nome da mesa deve ter entre 2 e 60 caracteres.';
  end if;
  if p_require_code then
    if p_code is null or p_code !~ '^[0-9]{4}$' then
      raise exception 'O código deve conter exatamente 4 números.';
    end if;
    if exists(select 1 from public.campaign_codes where code = p_code and campaign_id <> p_campaign_id) then
      raise exception 'Esse código já está sendo usado por outra mesa.';
    end if;
    insert into public.campaign_codes(campaign_id, code)
    values(p_campaign_id, p_code)
    on conflict(campaign_id) do update set code = excluded.code;
  else
    delete from public.campaign_codes where campaign_id = p_campaign_id;
  end if;
  update public.campaigns set name = v_name where id = p_campaign_id and owner_id = v_uid;
  return jsonb_build_object('ok', true, 'id', p_campaign_id, 'name', v_name, 'requires_code', p_require_code);
end;
$function$
;

-- avancar_turno(p_campaign_id bigint)
CREATE OR REPLACE FUNCTION public.avancar_turno(p_campaign_id bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_role TEXT;
  v_data JSONB;
  v_order JSONB;
  v_current INTEGER;
  v_next INTEGER;
  v_round INTEGER;
  v_entry JSONB;
  v_next_data JSONB;
  v_dying_ids TEXT[]; v_dying_targets JSONB; v_current_actor JSONB; v_actor_id TEXT; v_actor_kind TEXT; v_condition_break RECORD; v_condition_break_pending UUID;
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
  IF EXISTS(select 1 from priv.srd_aoo_pending_movements
    where campaign_id=p_campaign_id and status in ('waiting_reactions','ready_to_commit')) THEN
    RAISE EXCEPTION 'Há um movimento interrompido por Ataques de Oportunidade. O Mestre deve concluir ou cancelar esse movimento antes de avançar o turno.';
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

  -- Rodada surpresa: somente participantes conscientes recebem turno nesta fase.
  IF coalesce(v_data->'surprise'->>'phase','')='surprise_round' THEN
    DECLARE v_indices jsonb; v_cursor integer; v_next_index integer; v_surprise jsonb; v_actor jsonb;
    BEGIN
      v_surprise:=v_data->'surprise';
      v_indices:=CASE WHEN jsonb_typeof(v_surprise->'order_indices')='array' THEN v_surprise->'order_indices' ELSE '[]'::jsonb END;
      v_cursor:=coalesce(nullif(v_surprise->>'cursor','')::integer,0)+1;
      IF v_cursor<jsonb_array_length(v_indices) THEN
        v_next_index:=(v_indices->>v_cursor)::integer;
        v_actor:=v_order->v_next_index;
        v_surprise:=v_surprise||jsonb_build_object('cursor',v_cursor);
        v_next_data:=v_data||jsonb_build_object('surprise',v_surprise,'current_turn',v_next_index,'round',0,'active',true);
        UPDATE public.campaigns SET combat_data=v_next_data WHERE id=p_campaign_id;
        PERFORM priv.srd_clear_combat_flatfooted_actor(p_campaign_id,v_actor);
        RETURN v_next_data;
      ELSE
        v_surprise:=v_surprise||jsonb_build_object('phase','normal','completed_at',now());
        v_next_data:=v_data||jsonb_build_object('surprise',v_surprise,'current_turn',0,'round',1,'active',true,'action_economy',jsonb_build_object('round',1,'by_character','{}'::jsonb),'movement_usage','{}'::jsonb);
        UPDATE public.campaigns SET combat_data=v_next_data WHERE id=p_campaign_id;
        v_actor:=v_order->0;
        PERFORM priv.srd_clear_combat_flatfooted_actor(p_campaign_id,v_actor);
        RETURN v_next_data;
      END IF;
    END;
  END IF;

  v_next := v_current + 1;
  v_round := GREATEST(1, COALESCE((v_data->>'round')::INTEGER, 1));
  IF v_next >= jsonb_array_length(v_order) THEN
    v_next := 0;
    v_round := v_round + 1;
  END IF;

  v_next_data := v_data || jsonb_build_object('current_turn', v_next, 'round', v_round, 'active', TRUE);
  UPDATE public.campaigns SET combat_data = v_next_data WHERE id = p_campaign_id;
  IF v_next = 0 THEN
    PERFORM public.srd_expire_campaign_conditions(p_campaign_id);

    SELECT array_agg(DISTINCT ch.id::text ORDER BY ch.id::text)
      INTO v_dying_ids
      FROM public.srd_campaign_conditions cc
      JOIN public.characters ch
        ON ch.id::text=cc.target_id AND ch.campaign_id=cc.campaign_id
      JOIN public.srd_character_sheets sh
        ON sh.character_id=ch.id
     WHERE cc.campaign_id=p_campaign_id
       AND cc.target_kind='character'
       AND cc.condition_id='dying'
       AND cc.active=true
       AND COALESCE(sh.pv_atual,0) BETWEEN -9 AND -1
       AND COALESCE(NULLIF(cc.notes->>'last_resolved_round','')::integer,0)<v_round;

    IF COALESCE(cardinality(v_dying_ids),0)>0 THEN
      SELECT jsonb_agg(
        jsonb_build_object(
          'character_id',ch.id::text,
          'name',ch.nome,
          'user_id',ch.user_id,
          'pv',sh.pv_atual
        ) ORDER BY ch.id
      )
      INTO v_dying_targets
      FROM public.characters ch
      JOIN public.srd_character_sheets sh ON sh.character_id=ch.id
      WHERE ch.campaign_id=p_campaign_id
        AND ch.id::text=ANY(v_dying_ids);

      INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
      VALUES (
        p_campaign_id,
        'test_request',
        'PUBLIC',
        jsonb_build_object(
          'tipo','Estabilização (D100)',
          'alvos',to_jsonb(v_dying_ids),
          'mestre','Sistema',
          'mestre_id',auth.uid(),
          'request_id',gen_random_uuid()::text,
          'detalhes',COALESCE(v_dying_targets,'[]'::jsonb)
        )
      );
      v_next_data:=v_next_data||jsonb_build_object('dying_saves',COALESCE(v_dying_targets,'[]'::jsonb));
    ELSE
      v_next_data:=v_next_data||jsonb_build_object('dying_saves','[]'::jsonb);
    END IF;

  END IF;


  IF v_next=0 THEN
    DECLARE
      v_npc_dying_ids text[];
      v_npc_dying_targets jsonb;
    BEGIN
      SELECT array_agg(DISTINCT t.token->>'id' ORDER BY t.token->>'id')
        INTO v_npc_dying_ids
      FROM public.campaigns c
      CROSS JOIN LATERAL jsonb_array_elements(
        CASE WHEN jsonb_typeof(c.cba_data->'tokens')='array' THEN c.cba_data->'tokens' ELSE '[]'::jsonb END
      ) t(token)
      JOIN public.srd_campaign_conditions cc
        ON cc.campaign_id=c.id AND cc.target_kind='token'
       AND cc.target_id=t.token->>'id'
       AND cc.condition_id='dying' AND cc.active=true
      WHERE c.id=p_campaign_id
        AND t.token->>'tipo'='npc'
        AND NULLIF(t.token->>'sourceCharacterId','') ~ '^[0-9]+$'
        AND COALESCE(t.token->>'id','')<>''
        AND COALESCE(t.token->>'hp','') ~ '^-?[0-9]{1,6}$'
        AND (t.token->>'hp')::integer BETWEEN -9 AND -1
        AND COALESCE(NULLIF(cc.notes->>'last_resolved_round','')::integer,0)<v_round;

      IF COALESCE(cardinality(v_npc_dying_ids),0)>0 THEN
        SELECT jsonb_agg(jsonb_build_object(
          'token_id',t.token->>'id',
          'name',COALESCE(t.token->>'nome',t.token->>'name','NPC'),
          'source_character_id',t.token->>'sourceCharacterId',
          'pv',(t.token->>'hp')::integer
        ) ORDER BY t.token->>'id')
        INTO v_npc_dying_targets
        FROM public.campaigns c
        CROSS JOIN LATERAL jsonb_array_elements(
          CASE WHEN jsonb_typeof(c.cba_data->'tokens')='array' THEN c.cba_data->'tokens' ELSE '[]'::jsonb END
        ) t(token)
        WHERE c.id=p_campaign_id AND t.token->>'tipo'='npc'
          AND t.token->>'id'=ANY(v_npc_dying_ids);

        INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
        VALUES(
          p_campaign_id,'test_request','PUBLIC',
          jsonb_build_object(
            'tipo','Estabilização (D100)',
            'npc_alvos',to_jsonb(v_npc_dying_ids),
            'mestre','Sistema','mestre_id',auth.uid(),
            'request_id',gen_random_uuid()::text,
            'resolution_type','npc_dying_save',
            'detalhes',COALESCE(v_npc_dying_targets,'[]'::jsonb)
          )
        );
        v_next_data:=v_next_data||jsonb_build_object('npc_dying_saves',COALESCE(v_npc_dying_targets,'[]'::jsonb));
      ELSE
        v_next_data:=v_next_data||jsonb_build_object('npc_dying_saves','[]'::jsonb);
      END IF;
    END;
  END IF;

  v_current_actor:=v_order->v_next;
  v_actor_id:=v_current_actor->>'id';
  v_actor_kind:=CASE WHEN COALESCE((v_current_actor->>'is_monster')::boolean,false) THEN 'token' ELSE 'character' END;
  PERFORM priv.srd_clear_combat_flatfooted_actor(p_campaign_id,v_current_actor);

  SELECT cc.condition_instance_id,cc.target_kind,cc.target_id,cc.notes,ch.user_id
    INTO v_condition_break
    FROM public.srd_campaign_conditions cc
    LEFT JOIN public.characters ch
      ON cc.target_kind='character' AND ch.id::text=cc.target_id AND ch.campaign_id=cc.campaign_id
   WHERE cc.campaign_id=p_campaign_id
     AND cc.target_kind=v_actor_kind
     AND cc.target_id=v_actor_id
     AND cc.condition_id='paralyzed'
     AND cc.active=true
     AND cc.notes->>'save_each_turn'='true'
     AND COALESCE(NULLIF(cc.notes->>'last_save_round','')::integer,0)<v_round
     AND NULLIF(cc.notes->>'caster_character_id','') IS NOT NULL
     AND NULLIF(cc.notes->>'source_spell_id','') IS NOT NULL
   ORDER BY cc.condition_instance_id DESC
   LIMIT 1;

  IF FOUND THEN
    INSERT INTO priv.srd_pending_spell_resolutions(
      campaign_id,caster_character_id,target_kind,target_id,target_user_id,spell_id,
      save_type,save_dc,condition_id,duration_rounds,effect_data,spell_resistance,caster_level,
      condition_break,condition_break_instance_id
    ) VALUES (
      p_campaign_id,v_condition_break.notes->>'caster_character_id',
      v_condition_break.target_kind,v_condition_break.target_id,v_condition_break.user_id,
      v_condition_break.notes->>'source_spell_id',
      COALESCE(v_condition_break.notes->>'save_type','will'),
      COALESCE(NULLIF(v_condition_break.notes->>'save_dc','')::integer,10),
      'paralyzed',NULL,'{}'::jsonb,false,
      GREATEST(1,COALESCE(NULLIF(v_condition_break.notes->>'caster_level','')::integer,1)),
      true,v_condition_break.condition_instance_id
    ) RETURNING pending_id INTO v_condition_break_pending;

    INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
    VALUES (
      p_campaign_id,'test_request','PUBLIC',
      jsonb_build_object(
        'tipo','Resistência de Vontade para encerrar Paralisia (D20)',
        'alvos',CASE WHEN v_actor_kind='character' THEN jsonb_build_array(v_actor_id) ELSE '[]'::jsonb END,
        'npc_alvos',CASE WHEN v_actor_kind='token' THEN jsonb_build_array(v_actor_id) ELSE '[]'::jsonb END,
        'mestre','Sistema','mestre_id',auth.uid(),
        'request_id',v_condition_break_pending::text,
        'resolution_type','condition_break',
        'pending_id',v_condition_break_pending,
        'spell_id',v_condition_break.notes->>'source_spell_id',
        'save_type',COALESCE(v_condition_break.notes->>'save_type','will'),
        'save_dc',COALESCE(NULLIF(v_condition_break.notes->>'save_dc','')::integer,10)
      )
    );
  END IF;

  IF v_next=0 THEN
    UPDATE public.srd_campaign_effects SET active=false
     WHERE campaign_id=p_campaign_id AND active=true AND expires_round IS NOT NULL AND expires_round<=v_round;
  END IF;
  RETURN v_next_data;
END;
$function$
;

-- calc_ca(p_armadura text, p_escudo text, p_des integer, p_bonus integer)
CREATE OR REPLACE FUNCTION public.calc_ca(p_armadura text, p_escudo text, p_des integer, p_bonus integer DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  select coalesce((select (dados->>'ca')::int from public.items where id = p_armadura and categoria = 'armadura'), 0)
       + coalesce((select (dados->>'ca')::int from public.items where id = p_escudo and categoria = 'escudo'), 0)
       + p_des + coalesce(p_bonus, 0)
$function$
;

-- calc_desl(p_classe text, p_des integer, p_armadura text, p_escudo text, p_condicoes jsonb, p_carga numeric, p_capacidade numeric)
CREATE OR REPLACE FUNCTION public.calc_desl(p_classe text, p_des integer, p_armadura text, p_escudo text, p_condicoes jsonb DEFAULT '[]'::jsonb, p_carga numeric DEFAULT 0, p_capacidade numeric DEFAULT NULL::numeric)
 RETURNS integer
 LANGUAGE plpgsql
 STABLE
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  d int; cond jsonb; exaustos int := 0; lento boolean := false; imovel boolean := false; exc numeric;
begin
  d := (select desl from public.classes where id = p_classe) + p_des
     - coalesce((select sum((dados->>'penalidade_desl')::int) from public.items
                 where id in (p_armadura, p_escudo) and categoria in ('armadura','escudo')), 0);
  if p_capacidade is not null and p_capacidade > 0 and p_carga > p_capacidade then
    exc := (p_carga - p_capacidade) / p_capacidade;
    if exc > 1 then return 0; end if;
    d := d - ceil(exc / 0.25)::int;
  end if;
  for cond in select e from jsonb_array_elements(coalesce(p_condicoes, '[]'::jsonb)) e loop
    if cond->>'id' = 'lento' then lento := true;
    elsif cond->>'id' = 'exausto' then exaustos := exaustos + coalesce((cond->>'niveis')::int, 1);
    elsif exists (select 1 from public.conditions where id = cond->>'id' and sem_movimento) then imovel := true;
    end if;
  end loop;
  if imovel then return 0; end if;
  d := greatest(d, 0);
  if lento then d := floor(d / 2.0)::int; end if;
  return greatest(0, d - exaustos);
end $function$
;

-- calc_ini(p_des integer)
CREATE OR REPLACE FUNCTION public.calc_ini(p_des integer)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  select 10 + p_des
$function$
;

-- calc_pm(p_classe text, p_int integer)
CREATE OR REPLACE FUNCTION public.calc_pm(p_classe text, p_int integer)
 RETURNS integer
 LANGUAGE sql
 STABLE
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  select (select pm from public.classes where id = p_classe) + p_int
$function$
;

-- calc_pv(p_classe text, p_con integer)
CREATE OR REPLACE FUNCTION public.calc_pv(p_classe text, p_con integer)
 RETURNS integer
 LANGUAGE sql
 STABLE
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  select (select pv from public.classes where id = p_classe) + 2 * p_con
$function$
;

-- calc_rm(p_classe text, p_int integer, p_bonus integer)
CREATE OR REPLACE FUNCTION public.calc_rm(p_classe text, p_int integer, p_bonus integer DEFAULT 0)
 RETURNS integer
 LANGUAGE sql
 STABLE
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  select (select rm from public.classes where id = p_classe) + p_int + coalesce(p_bonus, 0)
$function$
;

-- calc_sheet(p_char bigint)
CREATE OR REPLACE FUNCTION public.calc_sheet(p_char bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare c public.characters; s public.character_sheets; a jsonb; nivel int; carga numeric; cap numeric; conds jsonb; soma int;
begin
  select * into c from public.characters where id = p_char;
  if not found then return null; end if;
  select * into s from public.character_sheets where character_id = p_char;
  if not found then return jsonb_build_object('character_id', p_char, 'nome', c.nome, 'sem_ficha', true); end if;
  a := s.atributos; nivel := public.level_from_xp(c.xp);
  soma := (select coalesce(sum(value::int), 0) from jsonb_each_text(a));
  cap := 10 + 2 * (a->>'FOR')::int;
  carga := (select coalesce(sum(i.peso * inv.qtd), 0)
            from public.inventory inv join public.items i on i.id = inv.item_id
            where inv.character_id = p_char);
  conds := coalesce((select jsonb_agg(jsonb_build_object('id', cc.condition_id, 'niveis', cc.niveis, 'origem', cc.origem, 'duracao', cc.duracao))
                     from public.character_conditions cc where cc.character_id = p_char), '[]'::jsonb);
  return jsonb_build_object(
    'character_id', p_char, 'nome', c.nome, 'xp', c.xp, 'nivel', nivel,
    'xp_proximo', public.xp_to_next(c.xp), 'ouro', c.ouro,
    'classe', s.classe, 'cultura', s.cultura, 'atributos', a, 'pericias', s.pericias,
    'armadura', s.armadura, 'escudo', s.escudo, 'ready', s.ready,
    'pontos', jsonb_build_object(
      'total', public.attr_points(nivel), 'soma', soma,
      'distribuidos', soma - 6, 'livres', public.attr_points(nivel) - soma,
      'max_atributo', public.attr_max(nivel)),
    'derivados', case when s.classe is null then null else jsonb_build_object(
      'pv_max', public.calc_pv(s.classe, (a->>'CON')::int),
      'pm_max', public.calc_pm(s.classe, (a->>'INT')::int),
      'rm', public.calc_rm(s.classe, (a->>'INT')::int, s.bonus_rm),
      'ca', public.calc_ca(s.armadura, s.escudo, (a->>'DES')::int, s.bonus_ca),
      'ini', public.calc_ini((a->>'DES')::int),
      'desl', public.calc_desl(s.classe, (a->>'DES')::int, s.armadura, s.escudo, conds, carga, cap)) end,
    'pv_atual', s.pv_atual, 'pm_atual', s.pm_atual,
    'carga', jsonb_build_object('usada', carga, 'capacidade', cap),
    'condicoes', conds,
    'death_state', s.death_state
  );
end $function$
;

-- can_read_media(p_path text)
CREATE OR REPLACE FUNCTION public.can_read_media(p_path text)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
  select exists (select 1 from media m where m.path = p_path and (public.my_role(m.campaign_id) = 'GM'
    or (public.my_role(m.campaign_id) is not null and exists (select 1 from layers l where l.media_id = m.id and l.visible)))) $function$
;

-- capacity(p_for integer)
CREATE OR REPLACE FUNCTION public.capacity(p_for integer)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$ select 10 + 2 * p_for $function$
;

-- clonar_equipamento_ficha_para_token(p_campaign_id bigint, p_token_id text, p_character_id text)
CREATE OR REPLACE FUNCTION public.clonar_equipamento_ficha_para_token(p_campaign_id bigint, p_token_id text, p_character_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare
  v_role text;
  v_owner uuid;
  v_source_exists boolean;
  v_token_source text;
  v_existing boolean;
  v_items integer := 0;
  v_weapons integer := 0;
begin
  if auth.uid() is null then
    raise exception 'É necessário estar autenticado.';
  end if;

  select m.role into v_role
  from public.members m
  where m.campaign_id = p_campaign_id and m.user_id = auth.uid()
  limit 1;

  if v_role is distinct from 'GM' then
    raise exception 'Somente o Mestre pode copiar equipamento para um token.';
  end if;

  select ch.user_id into v_owner
  from public.characters ch
  where ch.id::text = p_character_id;

  if not found or v_owner is distinct from auth.uid() then
    raise exception 'A ficha de origem não pertence ao Mestre autenticado.';
  end if;

  if not exists (
    select 1 from public.srd_character_sheets s
    where s.character_id = p_character_id
  ) then
    raise exception 'A ficha SRD de origem não foi encontrada.';
  end if;

  select t->>'sourceCharacterId' into v_token_source
  from public.campaigns c
  cross join lateral jsonb_array_elements(coalesce(c.cba_data->'tokens','[]'::jsonb)) t
  where c.id = p_campaign_id and t->>'id' = p_token_id and t->>'tipo' = 'npc'
  limit 1;

  if v_token_source is distinct from p_character_id then
    raise exception 'O token NPC não está vinculado à ficha de origem informada.';
  end if;

  select exists (
    select 1 from public.srd_cba_token_equipment e
    where e.campaign_id = p_campaign_id and e.token_id = p_token_id
  ) into v_existing;

  if v_existing then
    select count(*) into v_items from public.srd_cba_token_equipment e
    where e.campaign_id = p_campaign_id and e.token_id = p_token_id;
    select count(*) into v_weapons from public.srd_cba_token_weapon_instances wi
    where wi.campaign_id = p_campaign_id and wi.token_id = p_token_id;
    return jsonb_build_object('ok',true,'already_synced',true,'items',v_items,'weapon_instances',v_weapons);
  end if;

  insert into public.srd_cba_token_equipment
    (campaign_id, token_id, equipment_id, quantidade, equipado, hand_slot)
  select p_campaign_id, p_token_id, ce.equipment_id, ce.quantidade, ce.equipado, ce.hand_slot
  from public.srd_character_equipment ce
  where ce.character_id = p_character_id
  on conflict (campaign_id, token_id, equipment_id) do nothing;

  get diagnostics v_items = row_count;

  -- The inventory trigger creates default weapon instances. Replace those with
  -- a faithful snapshot of the source character's individual hand assignments.
  delete from public.srd_cba_token_weapon_instances
  where campaign_id = p_campaign_id and token_id = p_token_id;

  insert into public.srd_cba_token_weapon_instances
    (campaign_id, token_id, equipment_id, equipado, hand_slot)
  select p_campaign_id, p_token_id, wi.equipment_id, wi.equipado, wi.hand_slot
  from public.srd_character_weapon_instances wi
  where wi.character_id = p_character_id;

  get diagnostics v_weapons = row_count;

  return jsonb_build_object('ok',true,'already_synced',false,'items',v_items,'weapon_instances',v_weapons);
end;
$function$
;

-- combat_set_turn(p_token bigint)
CREATE OR REPLACE FUNCTION public.combat_set_turn(p_token bigint)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE t public.tokens; cs public.combat_state; idx integer;
BEGIN
  SELECT * INTO t FROM public.tokens WHERE id=p_token;
  IF NOT FOUND THEN RAISE EXCEPTION 'Token inexistente.'; END IF;
  PERFORM priv.need_gm(t.campaign_id);
  SELECT * INTO cs FROM public.combat_state WHERE campaign_id=t.campaign_id FOR UPDATE;
  IF NOT FOUND OR cs.ativo IS NOT TRUE THEN RAISE EXCEPTION 'Combate não está ativo.'; END IF;
  SELECT ordinality-1 INTO idx FROM jsonb_array_elements_text(cs.ordem) WITH ORDINALITY WHERE value=p_token::text;
  IF idx IS NULL THEN RAISE EXCEPTION 'Token fora da ordem.'; END IF;
  UPDATE public.combat_state SET turno_index=idx WHERE campaign_id=t.campaign_id;
  PERFORM priv.log(t.campaign_id,'TURNO_DEFINIDO',jsonb_build_object('token',p_token,'por',auth.uid()));
END $function$
;

-- conceder_xp_personagem_srd(p_campaign_id bigint, p_character_id text, p_xp integer)
CREATE OR REPLACE FUNCTION public.conceder_xp_personagem_srd(p_campaign_id bigint, p_character_id text, p_xp integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
DECLARE v_xp INTEGER; v_old_level INTEGER; v_target_level INTEGER; v_pending INTEGER; v_srd BOOLEAN:=FALSE;
BEGIN
 IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
 IF p_xp IS NULL OR p_xp<1 OR p_xp>1000000 THEN RAISE EXCEPTION 'Quantidade de XP inválida.'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.members m WHERE m.campaign_id=p_campaign_id AND m.user_id=auth.uid() AND m.role='GM') THEN RAISE EXCEPTION 'Somente o Mestre desta campanha pode conceder XP.'; END IF;
 PERFORM 1 FROM public.characters c WHERE c.id::TEXT=BTRIM(p_character_id) AND c.campaign_id=p_campaign_id FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado nesta campanha.'; END IF;
 UPDATE public.characters SET xp=COALESCE(xp,0)+p_xp WHERE id::TEXT=BTRIM(p_character_id) AND campaign_id=p_campaign_id RETURNING xp INTO v_xp;
 SELECT s.nivel INTO v_old_level FROM public.srd_character_sheets s WHERE s.character_id::TEXT=BTRIM(p_character_id) FOR UPDATE;
 IF FOUND THEN
  v_srd:=TRUE; v_old_level:=GREATEST(1,COALESCE(v_old_level,1)); v_target_level:=GREATEST(v_old_level,LEAST(20,public.nivel_de_xp(v_xp)));
  UPDATE public.srd_character_sheets SET xp=v_xp,niveis_pendentes=GREATEST(0,v_target_level-v_old_level) WHERE character_id::TEXT=BTRIM(p_character_id) RETURNING niveis_pendentes INTO v_pending;
 END IF;
 RETURN jsonb_build_object('character_id',BTRIM(p_character_id),'xp',v_xp,'nivel',v_old_level,'nivel_disponivel',v_target_level,'niveis_pendentes',v_pending,'ficha_srd',v_srd);
END; $function$
;

-- concluir_avanco_nivel_personagem_srd_v2(p_campaign_id bigint, p_character_id text, p_hit_die_roll integer, p_skill_ranks jsonb, p_feats jsonb, p_attribute text, p_idiomas jsonb)
CREATE OR REPLACE FUNCTION public.concluir_avanco_nivel_personagem_srd_v2(p_campaign_id bigint, p_character_id text, p_hit_die_roll integer, p_skill_ranks jsonb DEFAULT '{}'::jsonb, p_feats jsonb DEFAULT '[]'::jsonb, p_attribute text DEFAULT NULL::text, p_idiomas jsonb DEFAULT NULL::jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  v_result JSONB;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  v_result:=priv.concluir_avanco_nivel_personagem_srd(
    p_campaign_id,p_character_id,p_hit_die_roll,p_skill_ranks,p_feats,p_attribute
  );
  IF p_idiomas IS NOT NULL THEN
    PERFORM public.salvar_idiomas_personagem_srd(p_character_id,p_idiomas);
  END IF;
  RETURN v_result;
END;
$function$
;

-- confirm_sheet(p_char bigint)
CREATE OR REPLACE FUNCTION public.confirm_sheet(p_char bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare c public.characters; s public.character_sheets; soma int;
begin
  select * into c from public.characters where id = p_char;
  if not found or (c.user_id is distinct from auth.uid() and public.my_role(c.campaign_id) is distinct from 'GM') then
    raise exception 'Sem permissão.'; end if;
  select * into s from public.character_sheets where character_id = p_char for update;
  if s.classe is null or s.cultura is null then raise exception 'Escolha classe e cultura antes de confirmar.'; end if;
  soma := (select sum(value::int) from jsonb_each_text(s.atributos));
  if soma <> public.attr_points(public.level_from_xp(c.xp)) then
    raise exception 'Distribua todos os pontos de atributo antes de confirmar (% de %).',
      soma, public.attr_points(public.level_from_xp(c.xp)); end if;
  update public.character_sheets set ready = true, preserve_pv = false, updated_at = now()
    where character_id = p_char;
  return public.calc_sheet(p_char);
end $function$
;

-- confirmar_critico_ataque_iterativo_npc_srd(p_campaign_id bigint, p_attempt_id uuid, p_confirmation_d20 integer)
CREATE OR REPLACE FUNCTION public.confirmar_critico_ataque_iterativo_npc_srd(p_campaign_id bigint, p_attempt_id uuid, p_confirmation_d20 integer)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO ''
AS $function$ select priv.npc_confirmar_critico_ataque_iterativo_impl($1,$2,$3); $function$
;

-- confirmar_critico_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid, p_confirmation_d20 integer)
CREATE OR REPLACE FUNCTION public.confirmar_critico_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid, p_confirmation_d20 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_user uuid := auth.uid();
  v_campaign public.campaigns%rowtype;
  v_attempt public.srd_attack_sequence_attempts%rowtype;
  v_seq public.srd_attack_sequences%rowtype;
  v_bonus integer;
  v_total integer;
  v_confirmed boolean;
  v_scene jsonb;
  v_tokens jsonb;
begin
  if v_user is null then raise exception 'É necessário estar autenticado.'; end if;
  if p_confirmation_d20 is null or p_confirmation_d20<1 or p_confirmation_d20>20 then
    raise exception 'Confirmação crítica exige um d20 válido.';
  end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE' then
    raise exception 'A campanha não está em combate.';
  end if;
  select * into v_attempt from public.srd_attack_sequence_attempts where id=p_attempt_id for update;
  if not found then raise exception 'Tentativa de ataque não encontrada.'; end if;
  select * into v_seq from public.srd_attack_sequences
    where id=v_attempt.sequence_id and campaign_id=p_campaign_id for update;
  if not found then raise exception 'Sequência não encontrada.'; end if;
  if v_seq.created_by<>v_user then raise exception 'Somente quem iniciou a sequência pode confirmar o crítico.'; end if;
  if v_attempt.status<>'critical_confirmation_pending' then
    return jsonb_build_object('attempt_id',v_attempt.id,'status',v_attempt.status,
      'is_critical',v_attempt.is_critical,'resolution_data',v_attempt.resolution_data,'replayed',true);
  end if;
  if not exists (
    select 1 from public.characters ch join public.members m
      on m.campaign_id=ch.campaign_id and m.user_id=ch.user_id
    where ch.id=v_seq.actor_character_id and ch.campaign_id=p_campaign_id
      and ch.user_id=v_user and m.role='PLAYER'
  ) then raise exception 'Personagem não pertence ao jogador autenticado.'; end if;
  if lower(coalesce(v_campaign.combat_data->>'active','false'))<>'true'
    or coalesce(v_campaign.combat_data->>'current_turn','') !~ '^[0-9]+$'
    or (v_campaign.combat_data->>'current_turn')::integer<>v_seq.turn_index
    or coalesce(v_campaign.combat_data->>'round','') !~ '^[0-9]+$'
    or greatest(1,(v_campaign.combat_data->>'round')::integer)<>v_seq.round_number then
    raise exception 'Turno ou rodada mudou antes da confirmação crítica.';
  end if;
  select * into strict v_campaign from public.campaigns where id=p_campaign_id;
  v_scene:=coalesce(v_campaign.cba_data,'{}'::jsonb);
  v_tokens:=case when jsonb_typeof(v_scene->'tokens')='array' then v_scene->'tokens' else '[]'::jsonb end;
  if (select count(*) from jsonb_array_elements(v_tokens) t
      where t->>'id'=v_seq.target_token_id and t->>'tipo' in ('npc','monstro'))<>1 then
    raise exception 'Alvo não está mais presente na cena.';
  end if;
  if not exists (
    select 1 from public.srd_character_weapon_instances wi
    where wi.instance_id=v_seq.weapon_instance_id
      and wi.character_id=v_seq.actor_character_id::text
      and wi.equipado is true and wi.hand_slot=v_seq.weapon_hand_slot
  ) then raise exception 'A arma não está mais equipada na mão original.'; end if;
  if jsonb_typeof(v_attempt.resolution_data)<>'object'
     or coalesce(v_attempt.resolution_data->>'attack_total','') !~ '^-?[0-9]+$'
     or coalesce(v_attempt.resolution_data->>'target_ac','') !~ '^-?[0-9]+$' then
    raise exception 'Dados originais do ataque não permitem confirmar o crítico.';
  end if;
  v_bonus:=(v_attempt.resolution_data->>'attack_total')::integer-v_attempt.manual_d20;
  v_total:=p_confirmation_d20+v_bonus;
  v_confirmed:=p_confirmation_d20=20 or (p_confirmation_d20<>1 and v_total>=v_attempt.target_ac);
  update public.srd_attack_sequence_attempts
  set critical_confirmation_d20=p_confirmation_d20,
      is_critical=v_confirmed,
      status='hit_pending_damage',
      resolution_data=resolution_data||jsonb_build_object(
        'critical_confirmation_d20',p_confirmation_d20,
        'critical_confirmation_total',v_total,
        'critical_confirmed',v_confirmed
      )
  where id=p_attempt_id returning * into v_attempt;
  return jsonb_build_object('attempt_id',v_attempt.id,'status',v_attempt.status,
    'is_critical',v_attempt.is_critical,'confirmation_total',v_total,
    'target_ac',v_attempt.target_ac,'replayed',false);
end;
$function$
;

-- conjurar_magia_com_acao_srd(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text)
CREATE OR REPLACE FUNCTION public.conjurar_magia_com_acao_srd(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_campaign_id BIGINT;
  v_campaign_state TEXT;
  v_combat JSONB;
  v_result JSONB;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Autenticação obrigatória.';
  END IF;
  SELECT ch.campaign_id INTO v_campaign_id
    FROM public.characters AS ch
   WHERE ch.id::TEXT = BTRIM(p_character_id)
     AND ch.user_id = auth.uid()
   FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem autorização.';
  END IF;

  IF v_campaign_id IS NOT NULL THEN
    SELECT c.state INTO v_campaign_state
      FROM public.campaigns AS c
     WHERE c.id = v_campaign_id
     FOR UPDATE;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Campanha do personagem não encontrada.';
    END IF;
    IF UPPER(COALESCE(v_campaign_state, '')) = 'COMBATE' THEN
      PERFORM public.consumir_acao_turno_srd(v_campaign_id, p_character_id, 'padrao');
    END IF;
  END IF;

  v_result := public.conjurar_magia_srd(
    p_character_id,
    p_spell_id,
    p_slot_level,
    p_target_token_key
  );

  IF v_campaign_id IS NOT NULL
     AND UPPER(COALESCE(v_campaign_state, '')) = 'COMBATE' THEN
    SELECT c.combat_data INTO v_combat
      FROM public.campaigns AS c
     WHERE c.id = v_campaign_id;
    RETURN COALESCE(v_result, '{}'::JSONB) || jsonb_build_object(
      'combat_data', COALESCE(v_combat, '{}'::JSONB),
      'action_economy', COALESCE(v_combat->'action_economy', '{}'::JSONB)
    );
  END IF;
  RETURN COALESCE(v_result, '{}'::JSONB);
END;
$function$
;

-- conjurar_magia_com_acao_srd_manual(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text, p_roll_results integer[])
CREATE OR REPLACE FUNCTION public.conjurar_magia_com_acao_srd_manual(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text DEFAULT NULL::text, p_roll_results integer[] DEFAULT NULL::integer[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_campaign_id BIGINT;
  v_campaign_state TEXT;
  v_combat JSONB;
  v_result JSONB;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Autenticação obrigatória.';
  END IF;
  SELECT ch.campaign_id INTO v_campaign_id
    FROM public.characters AS ch
   WHERE ch.id::TEXT = BTRIM(p_character_id)
     AND ch.user_id = auth.uid()
   FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem autorização.';
  END IF;

  IF v_campaign_id IS NOT NULL THEN
    SELECT c.state INTO v_campaign_state
      FROM public.campaigns AS c
     WHERE c.id = v_campaign_id
     FOR UPDATE;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Campanha do personagem não encontrada.';
    END IF;
    IF UPPER(COALESCE(v_campaign_state, '')) = 'COMBATE' THEN
      PERFORM public.consumir_acao_turno_srd(v_campaign_id, p_character_id, 'padrao');
    END IF;
  END IF;

  v_result := public.conjurar_magia_srd_manual(
    p_character_id,
    p_spell_id,
    p_slot_level,
    p_target_token_key,
    p_roll_results
  );

  IF v_campaign_id IS NOT NULL
     AND UPPER(COALESCE(v_campaign_state, '')) = 'COMBATE' THEN
    SELECT c.combat_data INTO v_combat
      FROM public.campaigns AS c
     WHERE c.id = v_campaign_id;
    RETURN COALESCE(v_result, '{}'::JSONB) || jsonb_build_object(
      'combat_data', COALESCE(v_combat, '{}'::JSONB),
      'action_economy', COALESCE(v_combat->'action_economy', '{}'::JSONB)
    );
  END IF;
  RETURN COALESCE(v_result, '{}'::JSONB);
END;
$function$
;

-- conjurar_magia_com_acao_srd_multialvo(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])
CREATE OR REPLACE FUNCTION public.conjurar_magia_com_acao_srd_multialvo(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_campaign_id bigint;
  v_state text;
  v_result jsonb;
  v_combat jsonb;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória'; END IF;
  SELECT ch.campaign_id INTO v_campaign_id
  FROM public.characters ch
  WHERE ch.id::text=btrim(p_character_id) AND ch.user_id=auth.uid()
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou sem autorização'; END IF;
  SELECT c.state INTO v_state FROM public.campaigns c
  WHERE c.id=v_campaign_id FOR UPDATE;
  IF upper(coalesce(v_state,''))='COMBATE' THEN
    PERFORM public.consumir_acao_turno_srd(v_campaign_id,p_character_id,'padrao');
  END IF;
  v_result:=public.conjurar_magia_srd_multialvo(
    p_character_id,p_spell_id,p_slot_level,p_target_token_keys
  );
  IF upper(coalesce(v_state,''))='COMBATE' THEN
    SELECT combat_data INTO v_combat FROM public.campaigns WHERE id=v_campaign_id;
    RETURN coalesce(v_result,'{}'::jsonb)||jsonb_build_object(
      'combat_data',coalesce(v_combat,'{}'::jsonb),
      'action_economy',coalesce(v_combat->'action_economy','{}'::jsonb)
    );
  END IF;
  RETURN coalesce(v_result,'{}'::jsonb);
END;
$function$
;

-- conjurar_magia_com_acao_srd_multialvo_v2(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])
CREATE OR REPLACE FUNCTION public.conjurar_magia_com_acao_srd_multialvo_v2(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE v_campaign_id bigint; v_state text; v_result jsonb; v_combat jsonb;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória'; END IF;
  SELECT ch.campaign_id INTO v_campaign_id FROM public.characters ch
  WHERE ch.id::text=btrim(p_character_id) AND ch.user_id=auth.uid() FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou sem autorização'; END IF;
  SELECT c.state INTO v_state FROM public.campaigns c WHERE c.id=v_campaign_id FOR UPDATE;
  IF upper(coalesce(v_state,''))='COMBATE' THEN
    PERFORM public.consumir_acao_turno_srd(v_campaign_id,p_character_id,'padrao');
  END IF;
  v_result:=public.conjurar_magia_srd_multialvo_v2(p_character_id,p_spell_id,p_slot_level,p_target_token_keys);
  IF upper(coalesce(v_state,''))='COMBATE' THEN
    SELECT combat_data INTO v_combat FROM public.campaigns WHERE id=v_campaign_id;
    RETURN v_result||jsonb_build_object('combat_data',coalesce(v_combat,'{}'::jsonb));
  END IF;
  RETURN v_result;
END;
$function$
;

-- conjurar_magia_com_acao_srd_multialvo_v3(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[])
CREATE OR REPLACE FUNCTION public.conjurar_magia_com_acao_srd_multialvo_v3(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_campaign_id bigint;
  v_state text;
  v_result jsonb;
  v_combat jsonb;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Autenticação obrigatória';
  END IF;

  SELECT ch.campaign_id
    INTO v_campaign_id
    FROM public.characters ch
   WHERE ch.id::text = btrim(p_character_id)
     AND ch.user_id = auth.uid()
   FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem autorização';
  END IF;

  IF priv.srd_condition_has_flag(
       v_campaign_id, 'character', btrim(p_character_id), 'no_actions'
     )
     OR priv.srd_condition_has_flag(
       v_campaign_id, 'character', btrim(p_character_id), 'cannot_cast'
     ) THEN
    RAISE EXCEPTION 'A condição atual impede conjurar magias.';
  END IF;

  SELECT c.state
    INTO v_state
    FROM public.campaigns c
   WHERE c.id = v_campaign_id
   FOR UPDATE;

  IF upper(coalesce(v_state, '')) = 'COMBATE' THEN
    PERFORM public.consumir_acao_turno_srd(
      v_campaign_id, p_character_id, 'padrao'
    );
  END IF;

  v_result := public.conjurar_magia_srd_multialvo_v3(
    p_character_id, p_spell_id, p_slot_level,
    p_target_token_keys, p_roll_results
  );

  IF upper(coalesce(v_state, '')) = 'COMBATE' THEN
    SELECT combat_data
      INTO v_combat
      FROM public.campaigns
     WHERE id = v_campaign_id;

    RETURN v_result || jsonb_build_object(
      'combat_data', coalesce(v_combat, '{}'::jsonb)
    );
  END IF;

  RETURN v_result;
END;
$function$
;

-- conjurar_magia_dano_multialvo_srd(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[])
CREATE OR REPLACE FUNCTION public.conjurar_magia_dano_multialvo_srd(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_campaign_id bigint;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_spell record;
  v_class text;
  v_level integer;
  v_spell_level integer;
  v_score integer;
  v_state jsonb;
  v_prepared jsonb;
  v_prepared_idx integer;
  v_slots_remaining integer;
  v_slot_total integer;
  v_cba_data jsonb;
  v_tokens jsonb;
  v_key text;
  v_token jsonb;
  v_target_type text;
  v_target_kind text;
  v_target_id text;
  v_target_user_id uuid;
  v_target_name text;
  v_rule jsonb;
  v_effect_data jsonb;
  v_damage_expression text;
  v_damage_scale jsonb;
  v_die_count integer;
  v_die_size integer;
  v_damage_flat integer:=0;
  v_damage_dice_count integer;
  v_damage integer;
  v_damage_type text;
  v_save_type text;
  v_save_result text;
  v_save_dc integer;
  v_spell_resistance boolean:=false;
  v_sr integer:=0;
  v_pending_id uuid;
  v_pending_ids jsonb:='[]'::jsonb;
  v_pending_types jsonb:='[]'::jsonb;
  v_targets jsonb:='[]'::jsonb;
  v_roll_total integer:=0;
  v_resolution jsonb;
  v_pending_status text;
  v_willing_target boolean:=false;
  v_effect_kind text:='damage';
  v_extra_rolls jsonb:='[]'::jsonb; v_extra jsonb; v_extra_expression text; v_extra_count integer:=0; v_extra_size integer:=0;
  v_extra_dice_count integer:=0; v_total_roll_count integer:=0; v_extra_total integer:=0; v_duration_rounds integer:=0; v_secondary_condition_id text;
  v_damage_extra integer:=0; v_effect_components jsonb; v_component jsonb; v_component_key text; v_component_amount integer;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_target_token_keys IS NULL OR cardinality(p_target_token_keys) NOT BETWEEN 1 AND 20 THEN
    RAISE EXCEPTION 'Selecione entre 1 e 20 alvos.';
  END IF;
  IF EXISTS(SELECT 1 FROM (SELECT btrim(k) k,count(*) n FROM unnest(p_target_token_keys) k GROUP BY btrim(k)) x WHERE x.n>1 OR NULLIF(x.k,'') IS NULL) THEN
    RAISE EXCEPTION 'A lista de alvos contém identificadores vazios ou repetidos.';
  END IF;
  IF p_roll_results IS NULL OR cardinality(p_roll_results)<1 THEN RAISE EXCEPTION 'Role o dano manualmente antes de conjurar.'; END IF;

  SELECT ch.campaign_id INTO v_campaign_id
  FROM public.characters ch
  WHERE ch.id::text=btrim(p_character_id) AND ch.user_id=auth.uid()
  FOR UPDATE;
  IF NOT FOUND OR v_campaign_id IS NULL THEN RAISE EXCEPTION 'Personagem não encontrado ou sem campanha autorizada.'; END IF;
  IF NOT EXISTS(
    SELECT 1 FROM public.members m WHERE m.campaign_id=v_campaign_id AND m.user_id=auth.uid()
    UNION ALL SELECT 1 FROM public.campaigns c WHERE c.id=v_campaign_id AND c.owner_id=auth.uid()
  ) THEN RAISE EXCEPTION 'O personagem não pertence a uma campanha da qual você participa.'; END IF;
  IF priv.srd_condition_has_flag(v_campaign_id,'character',btrim(p_character_id),'no_actions')
     OR priv.srd_condition_has_flag(v_campaign_id,'character',btrim(p_character_id),'cannot_cast') THEN
    RAISE EXCEPTION 'A condição atual impede conjurar magias.';
  END IF;

  SELECT sh.* INTO v_sheet FROM public.srd_character_sheets sh WHERE sh.character_id::text=btrim(p_character_id) FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada.'; END IF;
  SELECT public._srd35_class_key(cl.nome) INTO v_class FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe SRD incompatível.'; END IF;
  v_level:=public._srd35_character_class_level(p_character_id,v_class,v_sheet.classe_id,v_sheet.nivel);
  IF v_level NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Nível de conjurador inválido para a classe.'; END IF;
  v_score:=CASE v_class
    WHEN 'wizard' THEN public._srd35_attr(to_jsonb(v_sheet),ARRAY['INT','inteligencia','intelligence'])::integer
    WHEN 'sorcerer' THEN public._srd35_attr(to_jsonb(v_sheet),ARRAY['CAR','carisma','charisma','cha'])::integer
    WHEN 'bard' THEN public._srd35_attr(to_jsonb(v_sheet),ARRAY['CAR','carisma','charisma','cha'])::integer
    WHEN 'paladin' THEN public._srd35_attr(to_jsonb(v_sheet),ARRAY['CAR','carisma','charisma','cha'])::integer
    ELSE public._srd35_attr(to_jsonb(v_sheet),ARRAY['SAB','sabedoria','wisdom','wis'])::integer END;
  IF v_score IS NULL OR v_score<1 THEN RAISE EXCEPTION 'Atributo-chave inválido.'; END IF;
  v_score:=v_score+priv.srd_effective_modifier(v_campaign_id,'character',p_character_id,
    CASE v_class WHEN 'wizard' THEN 'intelligence' WHEN 'sorcerer' THEN 'charisma' WHEN 'bard' THEN 'charisma' WHEN 'paladin' THEN 'charisma' ELSE 'wisdom' END);

  SELECT sp.* INTO v_spell FROM public.srd_spells sp WHERE sp.id=p_spell_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Magia não encontrada.'; END IF;
  v_spell_level:=public._srd35_spell_level_for_class(v_spell.nivel,v_class,v_spell.circulo);
  IF COALESCE(v_spell.dados_tecnicos->>'target_mode','')<>'multiple_targets_pending'
     OR COALESCE(v_spell.dados_tecnicos->>'engine_status','') NOT IN ('ready_multi_target','partial_multi_target') THEN
    RAISE EXCEPTION 'A magia não possui resolução automática de dano em múltiplos alvos.';
  END IF;
  IF p_slot_level IS NULL OR p_slot_level<>v_spell_level THEN RAISE EXCEPTION 'O espaço deve corresponder ao círculo da magia.'; END IF;
  IF NOT public._srd35_spell_class_ok(v_spell.classes,v_class) THEN RAISE EXCEPTION 'Magia não disponível para esta classe.'; END IF;
  IF COALESCE((SELECT (slots_by_level->(v_level-1)->>v_spell_level)::integer FROM public.srd_spell_progressions WHERE class_key=v_class),0)<=0
     OR v_score<10+v_spell_level THEN RAISE EXCEPTION 'Nível de magia, espaço ou atributo insuficiente.'; END IF;

  SELECT se.parameters->'engine_rule' INTO v_rule
  FROM public.srd_spell_effects se
  WHERE se.spell_id=p_spell_id AND se.verification_status='verified_srd'
    AND se.effect_kind='damage'
  ORDER BY se.effect_index LIMIT 1;
  IF v_rule IS NULL OR v_rule->>'resolver'<>'damage' THEN RAISE EXCEPTION 'Regra de dano não validada.'; END IF;

  v_damage_expression:=COALESCE(v_rule->>'damage_expression','');
  IF v_damage_expression !~ '^[0-9]{1,3}d(2|3|4|6|8|10|12|20|100)([+-][0-9]{1,5})?$' THEN
    RAISE EXCEPTION 'Expressão de dano inválida.';
  END IF;
  v_die_count:=split_part(v_damage_expression,'d',1)::integer;
  v_die_size:=regexp_replace(split_part(v_damage_expression,'d',2),'[+-].*$','')::integer;
  v_damage_flat:=COALESCE(substring(v_damage_expression from '([+-][0-9]+)$')::integer,0);
  v_damage_dice_count:=v_die_count;
  v_damage_scale:=v_rule->'damage_scaling';
  IF v_damage_scale IS NOT NULL AND jsonb_typeof(v_damage_scale)='object' THEN
    v_damage_dice_count:=COALESCE((v_damage_scale->>'base_dice')::integer,v_die_count)
      +GREATEST(0,FLOOR((v_level-COALESCE((v_damage_scale->>'start_level')::integer,1))::numeric
      /GREATEST(1,COALESCE((v_damage_scale->>'every_levels')::integer,1)))::integer)
      *COALESCE((v_damage_scale->>'dice_per_level')::integer,0);
    IF v_damage_scale ? 'cap_dice' THEN v_damage_dice_count:=LEAST(v_damage_dice_count,(v_damage_scale->>'cap_dice')::integer); END IF;
  END IF;
  IF v_damage_dice_count<1 OR v_damage_dice_count>100 THEN RAISE EXCEPTION 'Quantidade de dados de dano fora do limite.'; END IF;
  v_extra_rolls:=COALESCE(v_rule->'extra_rolls','[]'::jsonb);
  IF jsonb_typeof(v_extra_rolls)='array' THEN
    FOR v_extra IN SELECT value FROM jsonb_array_elements(v_extra_rolls) LOOP
      v_extra_expression:=COALESCE(v_extra->>'expression','');
      IF v_extra_expression !~ '^[0-9]{1,2}d(2|4|6|8|10|12|20|100)$' THEN
        RAISE EXCEPTION 'Rolagem adicional inválida na regra de efeito.';
      END IF;
      v_extra_count:=split_part(v_extra_expression,'d',1)::integer;
      v_extra_size:=split_part(v_extra_expression,'d',2)::integer;
      IF v_extra_size<>v_die_size THEN RAISE EXCEPTION 'Rolagens adicionais precisam usar o mesmo tipo de dado do dano.'; END IF;
      v_extra_dice_count:=v_extra_dice_count+v_extra_count;
    END LOOP;
  END IF;
  v_total_roll_count:=v_damage_dice_count+v_extra_dice_count;
  IF v_total_roll_count>100 OR cardinality(p_roll_results)<>v_total_roll_count
     OR EXISTS(SELECT 1 FROM unnest(p_roll_results) value WHERE value<1 OR value>v_die_size) THEN
    RAISE EXCEPTION 'A rolagem precisa conter % dado(s) de dano e duração.',v_total_roll_count;
  END IF;
  SELECT COALESCE(SUM(value),0) INTO v_roll_total
  FROM unnest(p_roll_results) WITH ORDINALITY u(value,ord) WHERE ord<=v_damage_dice_count;
  SELECT COALESCE(SUM(value),0) INTO v_extra_total
  FROM unnest(p_roll_results) WITH ORDINALITY u(value,ord) WHERE ord>v_damage_dice_count;
  v_duration_rounds:=COALESCE((v_rule->>'duration_rounds')::integer,0);
  FOR v_extra IN SELECT value FROM jsonb_array_elements(v_extra_rolls) LOOP
    IF v_extra->>'key'='duration_rounds' THEN v_duration_rounds:=v_extra_total;
    ELSIF COALESCE(v_extra->>'key','') LIKE 'damage_%' THEN v_damage_extra:=v_damage_extra+v_extra_total;
    END IF;
  END LOOP;
  v_secondary_condition_id:=NULLIF(v_rule->>'secondary_condition_id','');
  IF v_secondary_condition_id IS NOT NULL AND v_duration_rounds NOT BETWEEN 1 AND 10000 THEN
    RAISE EXCEPTION 'Duração da condição secundária inválida.';
  END IF;
  v_damage:=GREATEST(0,v_roll_total+v_damage_flat+v_damage_extra);
  v_effect_components:=v_rule->'damage_components';
  IF jsonb_typeof(v_effect_components)='array' AND EXISTS(
    SELECT 1 FROM jsonb_array_elements(v_effect_components) c WHERE c ? 'roll_key'
  ) THEN
    v_effect_components:='[]'::jsonb;
    FOR v_component IN SELECT value FROM jsonb_array_elements(v_rule->'damage_components') LOOP
      v_component_key:=COALESCE(v_component->>'roll_key','primary_damage');
      IF v_component_key='primary_damage' THEN
        v_component_amount:=v_roll_total+v_damage_flat;
      ELSIF v_component_key LIKE 'damage_%' THEN
        v_component_amount:=v_extra_total;
      ELSE
        RAISE EXCEPTION 'Chave de rolagem de componente desconhecida.';
      END IF;
      v_effect_components:=v_effect_components||jsonb_build_array(jsonb_build_object(
        'damage_type',v_component->>'damage_type','amount',v_component_amount
      ));
    END LOOP;
  END IF;
  v_damage_expression:=v_damage_dice_count::text||'d'||v_die_size;
  FOR v_extra IN SELECT value FROM jsonb_array_elements(v_extra_rolls) LOOP
    IF COALESCE(v_extra->>'key','') LIKE 'damage_%' THEN
      v_damage_expression:=v_damage_expression||'+'||(v_extra->>'expression');
    END IF;
  END LOOP;
  v_damage_type:=COALESCE(NULLIF(v_rule->>'damage_type',''),'untyped');
  IF v_damage_type !~ '^[a-z_]{1,24}$' THEN RAISE EXCEPTION 'Tipo de dano inválido.'; END IF;
  v_save_type:=NULLIF(v_rule->>'save_type','');
  v_save_result:=COALESCE(v_rule->>'save_result','none');
  IF v_save_type IS NOT NULL AND v_save_type NOT IN ('fortitude','reflex','will') THEN RAISE EXCEPTION 'Tipo de resistência inválido.'; END IF;
  v_save_dc:=CASE WHEN v_save_type IS NOT NULL THEN 10+v_spell_level+FLOOR((v_score-10)::numeric/2)::integer+CASE WHEN v_sheet.raca_id='gnomo' AND lower(COALESCE(v_spell.escola,'') ) LIKE '%illusion%' THEN 1 ELSE 0 END ELSE NULL END;
  v_spell_resistance:=COALESCE((v_rule->>'spell_resistance')::boolean,false);
  v_willing_target:=COALESCE((v_rule->>'willing_target')::boolean,false);
  IF v_willing_target THEN v_save_type:=NULL; v_save_dc:=NULL; v_spell_resistance:=false; END IF;

  v_effect_data:=COALESCE(v_rule->'effect_data','{}'::jsonb)||jsonb_build_object(
    'damage',v_damage,'damage_type',v_damage_type,'save_result',v_save_result,
    'damage_expression',v_damage_expression,
    'damage_components',v_effect_components,
    'secondary_condition_id',v_secondary_condition_id,'apply_secondary_condition',true
  );
  v_state:=COALESCE(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
  v_prepared:=COALESCE(v_state->'preparadas','[]'::jsonb);
  SELECT (e.ord-1)::integer INTO v_prepared_idx
  FROM jsonb_array_elements(v_prepared) WITH ORDINALITY e(value,ord)
  WHERE e.value->>'spell_id'=p_spell_id AND (e.value->>'slot_level')::integer=p_slot_level
    AND COALESCE((e.value->>'expended')::boolean,false)=false
  ORDER BY e.ord LIMIT 1;
  IF v_prepared_idx IS NULL THEN RAISE EXCEPTION 'Nenhum espaço preparado disponível.'; END IF;
  v_prepared:=jsonb_set(v_prepared,ARRAY[v_prepared_idx::text,'expended'],'true'::jsonb,true);
  SELECT count(*)::integer INTO v_slots_remaining FROM jsonb_array_elements(v_prepared) e(value)
  WHERE (e.value->>'slot_level')::integer=p_slot_level AND COALESCE((e.value->>'expended')::boolean,false)=false;
  v_slot_total:=public._srd35_slots(v_class,v_level,v_score,p_slot_level);

  IF EXISTS(SELECT 1 FROM public.campaigns c WHERE c.id=v_campaign_id AND UPPER(COALESCE(c.state,''))='COMBATE') THEN
    PERFORM public.consumir_acao_turno_srd(v_campaign_id,p_character_id,'padrao');
  END IF;
  SELECT c.cba_data INTO v_cba_data FROM public.campaigns c WHERE c.id=v_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array' THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;

  FOREACH v_key IN ARRAY p_target_token_keys LOOP
    SELECT t.value INTO v_token FROM jsonb_array_elements(v_tokens) t(value)
    WHERE t.value->>'key'=btrim(v_key) OR t.value->>'id'=btrim(v_key) LIMIT 1;
    IF NOT FOUND THEN RAISE EXCEPTION 'Token-alvo não encontrado: %.',v_key; END IF;
    v_target_type:=COALESCE(v_token->>'tipo','');
    IF v_target_type='player' THEN
      v_target_kind:='character'; v_target_id:=v_token->>'id';
      SELECT ch.user_id INTO v_target_user_id FROM public.characters ch
      WHERE ch.id::text=v_target_id AND ch.campaign_id=v_campaign_id;
      IF NOT FOUND THEN RAISE EXCEPTION 'Personagem-alvo não pertence à campanha.'; END IF;
    ELSIF v_target_type IN ('npc','monstro') THEN
      v_target_kind:='token'; v_target_id:=COALESCE(v_token->>'key',v_token->>'id'); v_target_user_id:=NULL;
    ELSE
      RAISE EXCEPTION 'Tipo de alvo inválido para magia de dano.';
    END IF;
    v_target_name:=COALESCE(v_token->>'nome',v_token->>'name','Alvo');
    v_sr:=CASE WHEN v_spell_resistance THEN priv.srd_spell_resistance_value(v_campaign_id,v_target_kind,v_target_id) ELSE 0 END;
    v_pending_status:=CASE WHEN v_sr>0 THEN 'awaiting_spell_resistance' ELSE 'pending_save' END;

    INSERT INTO priv.srd_pending_spell_resolutions(
      campaign_id,caster_character_id,target_kind,target_id,target_user_id,spell_id,
      save_type,save_dc,condition_id,duration_rounds,effect_data,effect_kind,spell_resistance,caster_level,status
    ) VALUES(
      v_campaign_id,p_character_id,v_target_kind,v_target_id,v_target_user_id,p_spell_id,
      v_save_type,v_save_dc,NULL,CASE WHEN v_secondary_condition_id IS NOT NULL THEN v_duration_rounds ELSE NULL END,
      v_effect_data,'damage',v_spell_resistance,v_level,v_pending_status
    ) RETURNING pending_id INTO v_pending_id;
    v_pending_ids:=v_pending_ids||jsonb_build_array(v_pending_id);
    v_pending_types:=v_pending_types||jsonb_build_array(CASE WHEN v_sr>0 THEN 'spell_resistance' WHEN v_save_type IS NOT NULL THEN 'spell_save' ELSE 'damage' END);

    IF v_sr>0 THEN
      INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
      VALUES(v_campaign_id,'test_request','PUBLIC',jsonb_build_object(
        'tipo','Penetração de Resistência à Magia (D20)','alvos',jsonb_build_array(p_character_id),'npc_alvos','[]'::jsonb,
        'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
        'resolution_type','spell_resistance','pending_id',v_pending_id,'spell_id',p_spell_id,
        'spell_resistance',v_sr,'caster_level',v_level
      ));
      v_targets:=v_targets||jsonb_build_array(jsonb_build_object('target_id',v_target_id,'target_kind',v_target_kind,'name',v_target_name,'status','awaiting_spell_resistance','pending_id',v_pending_id));
    ELSIF v_save_type IS NOT NULL THEN
      INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
      VALUES(v_campaign_id,'test_request','PUBLIC',jsonb_build_object(
        'tipo','Resistência de '||CASE v_save_type WHEN 'fortitude' THEN 'Fortitude' WHEN 'reflex' THEN 'Reflexos' ELSE 'Vontade' END||' (D20)',
        'alvos',CASE WHEN v_target_kind='character' THEN jsonb_build_array(v_target_id) ELSE '[]'::jsonb END,
        'npc_alvos',CASE WHEN v_target_kind='token' THEN jsonb_build_array(v_target_id) ELSE '[]'::jsonb END,
        'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
        'resolution_type','spell_save','pending_id',v_pending_id,'spell_id',p_spell_id,'save_type',v_save_type,'save_dc',v_save_dc
      ));
      v_targets:=v_targets||jsonb_build_array(jsonb_build_object('target_id',v_target_id,'target_kind',v_target_kind,'name',v_target_name,'status','pending_save','pending_id',v_pending_id));
    ELSE
      v_resolution:=priv.srd_apply_pending_spell_resolution(v_pending_id);
      v_targets:=v_targets||jsonb_build_array(jsonb_build_object('target_id',v_target_id,'target_kind',v_target_kind,'name',v_target_name,'status','applied','resolution',v_resolution));
    END IF;
  END LOOP;

  v_state:=jsonb_build_object('version',1,'conhecidas',COALESCE(v_state->'conhecidas','[]'::jsonb),
    'preparadas',v_prepared,'dominio_preparadas',COALESCE(v_state->'dominio_preparadas','[]'::jsonb),
    'usos',COALESCE(v_state->'usos','{}'::jsonb));
  UPDATE public.srd_character_sheets SET magias_preparadas=v_state WHERE character_id::text=p_character_id;
  SELECT cba_data INTO v_cba_data FROM public.campaigns WHERE id=v_campaign_id;
  RETURN jsonb_build_object(
    'estado',v_state,'damage_roll',v_damage,'damage_expression',v_damage_expression,
    'damage_type',v_damage_type,'duration_rounds',NULLIF(v_duration_rounds,0),'secondary_condition_id',v_secondary_condition_id,'targets',v_targets,'target_count',cardinality(p_target_token_keys),
    'pending_resolution_ids',v_pending_ids,'pending_resolution_types',v_pending_types,
    'slots_total',v_slot_total,'slots_remaining',v_slots_remaining,'cba_data',v_cba_data,'multiple_targets',true
  );
END;
$function$
;

-- conjurar_magia_efeitos_multialvo(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])
CREATE OR REPLACE FUNCTION public.conjurar_magia_efeitos_multialvo(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_campaign_id bigint; v_sheet public.srd_character_sheets%ROWTYPE; v_spell record;
  v_class text; v_level integer; v_spell_level integer; v_score integer; v_state jsonb; v_prepared jsonb;
  v_prepared_idx integer; v_slots_remaining integer; v_slot_total integer;
  v_cba_data jsonb; v_tokens jsonb; v_key text; v_token jsonb; v_target_type text;
  v_target_kind text; v_target_id text; v_target_user_id uuid; v_target_name text;
  v_engine_rule jsonb; v_effect_data jsonb; v_effect_kind text; v_save_type text;
  v_save_dc integer; v_condition_id text; v_duration_rounds integer; v_scale jsonb;
  v_scaled_value integer; v_pending_id uuid; v_effect_instance bigint;
  v_pending_ids jsonb:='[]'::jsonb; v_effect_ids jsonb:='[]'::jsonb; v_targets jsonb:='[]'::jsonb;
  v_willing_target boolean:=false; v_spell_resistance boolean:=false; v_sr integer:=0;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_target_token_keys IS NULL OR cardinality(p_target_token_keys) NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Selecione entre 1 e 20 alvos.'; END IF;
  IF EXISTS(SELECT 1 FROM (SELECT btrim(k) k,count(*) n FROM unnest(p_target_token_keys) k GROUP BY btrim(k)) x WHERE x.n>1 OR NULLIF(x.k,'') IS NULL) THEN
    RAISE EXCEPTION 'A lista de alvos contém identificadores vazios ou repetidos.';
  END IF;
  SELECT ch.campaign_id INTO v_campaign_id FROM public.characters ch
  WHERE ch.id::text=btrim(p_character_id) AND ch.user_id=auth.uid() FOR UPDATE;
  IF NOT FOUND OR v_campaign_id IS NULL THEN RAISE EXCEPTION 'Personagem não encontrado ou sem campanha autorizada.'; END IF;
  IF NOT EXISTS(SELECT 1 FROM public.members m WHERE m.campaign_id=v_campaign_id AND m.user_id=auth.uid()
    UNION ALL SELECT 1 FROM public.campaigns c WHERE c.id=v_campaign_id AND c.owner_id=auth.uid()) THEN
    RAISE EXCEPTION 'O personagem não pertence a uma campanha da qual você participa.';
  END IF;

  IF priv.srd_condition_has_flag(v_campaign_id,'character',BTRIM(p_character_id),'no_actions')
     OR priv.srd_condition_has_flag(v_campaign_id,'character',BTRIM(p_character_id),'cannot_cast') THEN
    RAISE EXCEPTION 'A condição atual impede conjurar magias.';
  END IF;  SELECT sh.* INTO v_sheet FROM public.srd_character_sheets sh WHERE sh.character_id::text=btrim(p_character_id) FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada.'; END IF;
  SELECT public._srd35_class_key(cl.nome) INTO v_class FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe SRD incompatível.'; END IF;
  v_level:=public._srd35_character_class_level(p_character_id,v_class,v_sheet.classe_id,v_sheet.nivel);
  IF v_level IS NULL OR v_level NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Nível de conjurador inválido para a classe.'; END IF;
  v_score:=CASE v_class
    WHEN 'wizard' THEN public._srd35_attr(to_jsonb(v_sheet),ARRAY['INT','inteligencia','intelligence'])::integer
    WHEN 'sorcerer' THEN public._srd35_attr(to_jsonb(v_sheet),ARRAY['CAR','carisma','charisma','cha'])::integer
    WHEN 'bard' THEN public._srd35_attr(to_jsonb(v_sheet),ARRAY['CAR','carisma','charisma','cha'])::integer
    WHEN 'paladin' THEN public._srd35_attr(to_jsonb(v_sheet),ARRAY['CAR','carisma','charisma','cha'])::integer
    ELSE public._srd35_attr(to_jsonb(v_sheet),ARRAY['SAB','sabedoria','wisdom','wis'])::integer END;
  IF v_score IS NULL OR v_score<1 THEN RAISE EXCEPTION 'Atributo-chave inválido.'; END IF;
  v_score:=v_score+priv.srd_effective_modifier(v_campaign_id,'character',p_character_id,
    CASE v_class WHEN 'wizard' THEN 'intelligence' WHEN 'sorcerer' THEN 'charisma' WHEN 'bard' THEN 'charisma' WHEN 'paladin' THEN 'charisma' ELSE 'wisdom' END);
  SELECT sp.* INTO v_spell FROM public.srd_spells sp WHERE sp.id=p_spell_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Magia não encontrada.'; END IF;
  v_spell_level:=public._srd35_spell_level_for_class(v_spell.nivel,v_class,v_spell.circulo);
  IF COALESCE(v_spell.dados_tecnicos->>'target_mode','')<>'multiple_targets_pending'
     OR COALESCE(v_spell.dados_tecnicos->>'engine_status','') NOT IN ('ready_multi_target','partial_multi_target') THEN
    RAISE EXCEPTION 'A magia ainda não possui resolução automática de múltiplos alvos.';
  END IF;
  IF p_slot_level IS NULL OR p_slot_level<>v_spell_level THEN RAISE EXCEPTION 'O espaço deve corresponder ao círculo da magia.'; END IF;
  IF NOT public._srd35_spell_class_ok(v_spell.classes,v_class) THEN RAISE EXCEPTION 'Magia não disponível para esta classe.'; END IF;
  IF COALESCE((SELECT (slots_by_level->(v_level-1)->>v_spell_level)::integer FROM public.srd_spell_progressions WHERE class_key=v_class),0)<=0
     OR v_score<10+v_spell_level THEN RAISE EXCEPTION 'Nível de magia, espaço ou atributo insuficiente.'; END IF;
  IF p_spell_id IN ('srd35_spell_haste','srd35_spell_slow') AND cardinality(p_target_token_keys)>v_level THEN
    RAISE EXCEPTION 'Esta magia pode afetar no máximo % alvo(s) no seu nível de conjurador.',v_level;
  END IF;
  SELECT se.parameters->'engine_rule' INTO v_engine_rule FROM public.srd_spell_effects se
  WHERE se.spell_id=p_spell_id AND se.verification_status='verified_srd' ORDER BY se.effect_index LIMIT 1;
  IF v_engine_rule IS NULL THEN RAISE EXCEPTION 'Regra automática de efeito não validada.'; END IF;
  v_state:=COALESCE(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
  v_prepared:=COALESCE(v_state->'preparadas','[]'::jsonb);
  SELECT (e.ord-1)::integer INTO v_prepared_idx
  FROM jsonb_array_elements(v_prepared) WITH ORDINALITY e(value,ord)
  WHERE e.value->>'spell_id'=p_spell_id AND (e.value->>'slot_level')::integer=p_slot_level
    AND COALESCE((e.value->>'expended')::boolean,false)=false ORDER BY e.ord LIMIT 1;
  IF v_prepared_idx IS NULL THEN RAISE EXCEPTION 'Nenhum espaço preparado disponível.'; END IF;
  v_prepared:=jsonb_set(v_prepared,ARRAY[v_prepared_idx::text,'expended'],'true'::jsonb,true);
  SELECT count(*)::integer INTO v_slots_remaining FROM jsonb_array_elements(v_prepared) e(value)
  WHERE (e.value->>'slot_level')::integer=p_slot_level AND COALESCE((e.value->>'expended')::boolean,false)=false;
  v_slot_total:=public._srd35_slots(v_class,v_level,v_score,p_slot_level);

  IF EXISTS(SELECT 1 FROM public.campaigns c WHERE c.id=v_campaign_id AND UPPER(COALESCE(c.state,''))='COMBATE') THEN
    PERFORM public.consumir_acao_turno_srd(v_campaign_id,p_character_id,'padrao');
  END IF;

  SELECT c.cba_data INTO v_cba_data FROM public.campaigns c WHERE c.id=v_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array' THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;
  v_effect_data:=COALESCE(v_engine_rule->'effect_data','{}'::jsonb);
  v_effect_kind:=COALESCE(v_engine_rule->>'effect_kind',CASE v_engine_rule->>'resolver' WHEN 'debuff' THEN 'debuff' ELSE 'buff' END);
  v_save_type:=NULLIF(v_engine_rule->>'save_type','');
  v_condition_id:=NULLIF(v_engine_rule->>'condition_id','');
  v_duration_rounds:=CASE WHEN v_engine_rule ? 'duration_rounds_per_caster_level' THEN v_level*(v_engine_rule->>'duration_rounds_per_caster_level')::integer
    WHEN v_engine_rule ? 'duration_rounds' THEN (v_engine_rule->>'duration_rounds')::integer ELSE NULL END;
  v_scale:=v_engine_rule->'level_scale';
  IF v_scale IS NOT NULL AND jsonb_typeof(v_scale)='object' AND jsonb_typeof(v_effect_data->'modifiers')='array' THEN
    v_scaled_value:=COALESCE((v_scale->>'base')::integer,0)
      +GREATEST(0,FLOOR((v_level-COALESCE((v_scale->>'start_level')::integer,1))::numeric/GREATEST(1,COALESCE((v_scale->>'every_levels')::integer,1)))::integer);
    IF v_scale ? 'cap' THEN v_scaled_value:=LEAST(v_scaled_value,(v_scale->>'cap')::integer); END IF;
    v_effect_data:=jsonb_set(v_effect_data,'{modifiers,0,value}',to_jsonb(v_scaled_value),true);
  END IF;
  IF v_save_type IS NOT NULL THEN v_save_dc:=10+v_spell_level+FLOOR((v_score-10)::numeric/2)::integer+CASE WHEN v_sheet.raca_id='gnomo' AND lower(COALESCE(v_spell.escola,'') ) LIKE '%illusion%' THEN 1 ELSE 0 END; END IF;

  FOREACH v_key IN ARRAY p_target_token_keys LOOP
    SELECT t.value INTO v_token FROM jsonb_array_elements(v_tokens) t(value) WHERE t.value->>'key'=btrim(v_key) LIMIT 1;
    IF NOT FOUND THEN RAISE EXCEPTION 'Token-alvo não encontrado: %',v_key; END IF;
    v_target_type:=COALESCE(v_token->>'tipo','');
    IF v_target_type='player' THEN
      v_target_kind:='character'; v_target_id:=v_token->>'id';
      SELECT ch.user_id INTO v_target_user_id FROM public.characters ch WHERE ch.id::text=v_target_id AND ch.campaign_id=v_campaign_id;
      IF NOT FOUND THEN RAISE EXCEPTION 'Ficha do alvo não pertence à campanha: %',v_key; END IF;
    ELSE
      v_target_kind:='token'; v_target_id:=btrim(v_key); v_target_user_id:=NULL;
    END IF;
    v_target_name:=COALESCE(v_token->>'nome',v_token->>'name','Alvo');
    v_willing_target:=COALESCE((v_engine_rule->>'willing_target')::boolean,false);
    IF v_willing_target THEN v_save_type:=NULL; END IF;
    v_spell_resistance:=COALESCE((v_engine_rule->>'spell_resistance')::boolean,false) AND NOT v_willing_target;
    v_sr:=CASE WHEN v_spell_resistance THEN priv.srd_spell_resistance_value(v_campaign_id,v_target_kind,v_target_id) ELSE 0 END;
    IF v_sr>0 THEN
      v_save_dc:=CASE WHEN v_save_type IS NOT NULL THEN 10+v_spell_level+FLOOR((v_score-10)::numeric/2)::integer+CASE WHEN v_sheet.raca_id='gnomo' AND lower(COALESCE(v_spell.escola,'') ) LIKE '%illusion%' THEN 1 ELSE 0 END ELSE NULL END;
      INSERT INTO priv.srd_pending_spell_resolutions(campaign_id,caster_character_id,target_kind,target_id,target_user_id,spell_id,
        save_type,save_dc,condition_id,duration_rounds,effect_data,effect_kind,spell_resistance,caster_level,status)
      VALUES(v_campaign_id,p_character_id,v_target_kind,v_target_id,v_target_user_id,p_spell_id,v_save_type,v_save_dc,v_condition_id,
        v_duration_rounds,v_effect_data,v_effect_kind,true,v_level,'awaiting_spell_resistance')
      RETURNING pending_id INTO v_pending_id;
      v_pending_ids:=v_pending_ids||jsonb_build_array(v_pending_id);
      v_targets:=v_targets||jsonb_build_array(jsonb_build_object('target_id',v_target_id,'target_kind',v_target_kind,'name',v_target_name,'status','awaiting_spell_resistance','pending_id',v_pending_id));
      INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
      VALUES(v_campaign_id,'test_request','PUBLIC',jsonb_build_object(
        'tipo','Penetração de Resistência à Magia (D20)','alvos',jsonb_build_array(p_character_id),'npc_alvos','[]'::jsonb,
        'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
        'resolution_type','spell_resistance','pending_id',v_pending_id,'spell_id',p_spell_id,
        'spell_resistance',v_sr,'caster_level',v_level
      ));
    ELSIF v_engine_rule->>'resolver'='buff' OR (v_engine_rule->>'resolver'='debuff' AND v_save_type IS NULL) THEN
      v_effect_instance:=priv.srd_apply_campaign_effect(v_campaign_id,v_target_kind,v_target_id,v_effect_kind,v_effect_data,v_duration_rounds,p_spell_id,NULL);
      v_effect_ids:=v_effect_ids||jsonb_build_array(v_effect_instance);
      v_targets:=v_targets||jsonb_build_array(jsonb_build_object('target_id',v_target_id,'target_kind',v_target_kind,'name',v_target_name,'status','applied','effect_instance_id',v_effect_instance));
    ELSIF v_engine_rule->>'resolver'='condition' AND v_save_type IS NULL THEN
      v_effect_instance:=priv.srd_apply_campaign_condition(v_campaign_id,v_target_kind,v_target_id,v_condition_id,v_duration_rounds,
        jsonb_build_object('source_spell_id',p_spell_id,'caster_character_id',p_character_id),p_spell_id);
      v_effect_ids:=v_effect_ids||jsonb_build_array(v_effect_instance);
      v_targets:=v_targets||jsonb_build_array(jsonb_build_object('target_id',v_target_id,'target_kind',v_target_kind,'name',v_target_name,'status','applied','condition_instance_id',v_effect_instance));
    ELSE
      IF v_save_type IS NULL THEN RAISE EXCEPTION 'Regra multialvo sem tipo de resistência.'; END IF;
      INSERT INTO priv.srd_pending_spell_resolutions(campaign_id,caster_character_id,target_kind,target_id,target_user_id,spell_id,
        save_type,save_dc,condition_id,duration_rounds,effect_data,effect_kind,spell_resistance,caster_level)
      VALUES(v_campaign_id,p_character_id,v_target_kind,v_target_id,v_target_user_id,p_spell_id,v_save_type,v_save_dc,v_condition_id,
        v_duration_rounds,v_effect_data,v_effect_kind,COALESCE((v_engine_rule->>'spell_resistance')::boolean,false),v_level)
      RETURNING pending_id INTO v_pending_id;
      v_pending_ids:=v_pending_ids||jsonb_build_array(v_pending_id);
      v_targets:=v_targets||jsonb_build_array(jsonb_build_object('target_id',v_target_id,'target_kind',v_target_kind,'name',v_target_name,'status','pending_save','pending_id',v_pending_id));
      INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
      VALUES(v_campaign_id,'test_request','PUBLIC',jsonb_build_object(
        'tipo','Resistência de '||CASE v_save_type WHEN 'fortitude' THEN 'Fortitude' WHEN 'reflex' THEN 'Reflexos' ELSE 'Vontade' END||' (D20)',
        'alvos',CASE WHEN v_target_kind='character' THEN jsonb_build_array(v_target_id) ELSE '[]'::jsonb END,
        'npc_alvos',CASE WHEN v_target_kind='token' THEN jsonb_build_array(v_target_id) ELSE '[]'::jsonb END,
        'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
        'resolution_type','spell_save','pending_id',v_pending_id,'spell_id',p_spell_id,'save_type',v_save_type,'save_dc',v_save_dc
      ));
    END IF;
  END LOOP;
  v_state:=jsonb_build_object('version',1,'conhecidas',COALESCE(v_state->'conhecidas','[]'::jsonb),'preparadas',v_prepared,
    'dominio_preparadas',COALESCE(v_state->'dominio_preparadas','[]'::jsonb),'usos',COALESCE(v_state->'usos','{}'::jsonb));
  UPDATE public.srd_character_sheets SET magias_preparadas=v_state WHERE character_id::text=p_character_id;
  RETURN jsonb_build_object('estado',v_state,'targets',v_targets,'target_count',cardinality(p_target_token_keys),
    'pending_resolution_ids',v_pending_ids,'effect_instance_ids',v_effect_ids,'slots_total',v_slot_total,'slots_remaining',v_slots_remaining,'multiple_targets',true);
END;
$function$
;

-- conjurar_magia_srd(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text)
CREATE OR REPLACE FUNCTION public.conjurar_magia_srd(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_doc jsonb; v_class text; v_level integer; v_score integer;
  v_state jsonb; v_known jsonb; v_prepared jsonb; v_usos jsonb; v_spell record;
  v_domain_prepared jsonb; v_domain_idx integer; v_domain_circle integer; v_domain_id text;
  v_class_access boolean := false; v_domain_access boolean := false; v_domain_slot_used boolean := false;
  v_circle integer; v_use_count integer; v_capacity integer; v_idx integer; v_new_prepared jsonb;
  v_campaign_id public.characters.campaign_id%TYPE; v_caster_name text;
  v_cba_data jsonb; v_tokens jsonb; v_token jsonb; v_token_index bigint; v_token_count integer;
  v_target_type text; v_target_name text; v_target_key text; v_target_character_id text;
  v_target_hp integer; v_target_max_hp integer; v_healing integer := 0;
  v_roll integer := 0; v_die_count integer; v_die_size integer; v_dice text;
  v_per_level integer := 0; v_max_level integer := 0; v_level_bonus integer;
  v_slot_total integer; v_slots_remaining integer;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória'; END IF;
  SELECT c.campaign_id,c.nome INTO v_campaign_id,v_caster_name
    FROM public.characters c
   WHERE c.id::text=p_character_id AND c.user_id=auth.uid()
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou sem autorização'; END IF;
  IF v_campaign_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM public.members m WHERE m.campaign_id=v_campaign_id AND m.user_id=auth.uid()
    UNION ALL SELECT 1 FROM public.campaigns c WHERE c.id=v_campaign_id AND c.owner_id=auth.uid()
  ) THEN RAISE EXCEPTION 'O personagem não pertence a uma campanha da qual você participa'; END IF;


  IF priv.srd_condition_has_flag(v_campaign_id,'character',BTRIM(p_character_id),'no_actions')
     OR priv.srd_condition_has_flag(v_campaign_id,'character',BTRIM(p_character_id),'cannot_cast') THEN
    RAISE EXCEPTION 'A condição atual impede conjurar magias.';
  END IF;

  SELECT s.* INTO v_sheet FROM public.srd_character_sheets s

    WHERE s.character_id::text=p_character_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada'; END IF;
  v_doc:=to_jsonb(v_sheet);
  SELECT public._srd35_class_key(cl.nome) INTO v_class
    FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe SRD da ficha não encontrada ou incompatível'; END IF;
  SELECT COALESCE(
    MAX(cl.class_level) FILTER (WHERE cls.class_key=v_class),
    CASE WHEN NOT EXISTS (
      SELECT 1 FROM public.srd_character_class_levels any_level
       WHERE any_level.character_id=v_sheet.character_id
    ) THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
  )
    INTO v_level
    FROM public.srd_character_sheets sh
    LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
    LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
   WHERE sh.character_id=v_sheet.character_id
   GROUP BY sh.character_id,sh.nivel;
  IF v_level IS NULL OR v_level NOT BETWEEN 1 AND 20 THEN
    RAISE EXCEPTION 'Nível efetivo da classe conjuradora ausente ou inválido.';
  END IF;
  v_score:=CASE
    WHEN v_class='wizard' THEN public._srd35_attr(v_doc,ARRAY['INT','inteligencia','intelligence','int_score','score_inteligencia'])::integer
    WHEN v_class IN ('sorcerer','bard') THEN public._srd35_attr(v_doc,ARRAY['CAR','carisma','charisma','cha','cha_score','score_carisma'])::integer
    ELSE public._srd35_attr(v_doc,ARRAY['SAB','sabedoria','wisdom','wis','wis_score','score_sabedoria'])::integer END;
  IF v_score IS NULL OR v_score < 1 THEN RAISE EXCEPTION 'Atributo-chave ausente ou inválido'; END IF;
  IF p_slot_level IS NULL OR p_slot_level NOT BETWEEN 0 AND 9 THEN RAISE EXCEPTION 'slot_level deve estar entre 0 e 9'; END IF;
  SELECT id,circulo,classes,dados_tecnicos INTO v_spell FROM public.srd_spells WHERE id=p_spell_id;
  IF NOT FOUND OR v_spell.circulo NOT BETWEEN 0 AND 9 THEN
    RAISE EXCEPTION 'Magia inexistente ou nível inválido';
  END IF;
  v_class_access:=public._srd35_spell_class_ok(v_spell.classes,v_class);
  IF v_class='cleric' THEN
    SELECT ds.domain_id,ds.spell_level INTO v_domain_id,v_domain_circle
      FROM public.srd_character_domain_choices choice
      JOIN public.srd_domain_spells ds USING (domain_id)
     WHERE choice.character_id::text=p_character_id AND ds.spell_id=v_spell.id
       AND ds.spell_level=p_slot_level
     ORDER BY choice.domain_slot LIMIT 1;
    v_domain_access:=FOUND;
  END IF;
  IF NOT v_class_access AND NOT v_domain_access THEN
    RAISE EXCEPTION 'Magia inexistente ou não disponível pela classe/domínio escolhido';
  END IF;
  v_circle:=CASE WHEN v_class_access THEN v_spell.circulo ELSE v_domain_circle END;
  IF v_class_access AND
     (coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_spell.circulo)::integer
                  FROM public.srd_spell_progressions WHERE class_key=v_class),0)>0
      AND v_score>=10+v_spell.circulo) THEN
    v_class_access:=true;
  ELSE
    v_class_access:=false;
  END IF;
  IF v_domain_access AND
     (coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_domain_circle)::integer
                  FROM public.srd_spell_progressions WHERE class_key='cleric'),0)>0
      AND v_score>=10+v_domain_circle) THEN
    v_domain_access:=true;
  ELSE
    v_domain_access:=false;
  END IF;
  IF NOT v_class_access AND NOT v_domain_access THEN
    RAISE EXCEPTION 'Nível de magia, espaço de domínio ou atributo insuficiente';
  END IF;
  v_circle:=CASE WHEN v_class_access THEN v_spell.circulo ELSE v_domain_circle END;
  IF v_class IN ('sorcerer','bard') AND p_slot_level<>v_circle THEN RAISE EXCEPTION 'Feiticeiro conjura a magia no próprio círculo'; END IF;
  IF v_class NOT IN ('sorcerer','bard') AND p_slot_level<v_circle AND NOT v_domain_access THEN RAISE EXCEPTION 'Espaço menor que o círculo da magia'; END IF;

  v_state:=coalesce(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
  v_known:=coalesce(v_state->'conhecidas','[]'::jsonb);
  v_prepared:=coalesce(v_state->'preparadas','[]'::jsonb);
  v_usos:=coalesce(v_state->'usos','{}'::jsonb);
  v_domain_prepared:=coalesce(v_state->'dominio_preparadas','[]'::jsonb);
  IF v_class IN ('sorcerer','bard') THEN
    IF NOT (v_known ? p_spell_id) THEN RAISE EXCEPTION 'Feiticeiro só pode conjurar magias conhecidas'; END IF;
    v_capacity:=public._srd35_slots(v_class,v_level,v_score,v_circle);
    v_use_count:=coalesce((v_usos->>v_circle::text)::integer,0);
    IF v_use_count>=v_capacity THEN RAISE EXCEPTION 'Sem usos diários restantes para este círculo'; END IF;
    v_usos:=jsonb_set(v_usos,ARRAY[v_circle::text],to_jsonb(v_use_count+1),true);
    v_slot_total:=v_capacity; v_slots_remaining:=v_capacity-v_use_count-1;
  ELSE
    IF v_class='cleric' AND v_domain_access THEN
      SELECT (ord-1)::integer INTO v_domain_idx
        FROM jsonb_array_elements(v_domain_prepared) WITH ORDINALITY e(value,ord)
       WHERE value->>'spell_id'=p_spell_id AND value->>'domain_id'=v_domain_id
         AND (value->>'slot_level')::integer=p_slot_level
         AND coalesce((value->>'expended')::boolean,false)=false
       ORDER BY ord LIMIT 1;
    END IF;
    IF v_domain_idx IS NOT NULL THEN
      v_domain_prepared:=jsonb_set(v_domain_prepared,ARRAY[v_domain_idx::text,'expended'],'true'::jsonb,true);
      v_domain_slot_used:=true; v_slot_total:=1; v_slots_remaining:=0;
    ELSE
      IF NOT v_class_access THEN RAISE EXCEPTION 'Espaço de domínio não preparado ou já gasto'; END IF;
      SELECT (ord-1)::integer INTO v_idx FROM jsonb_array_elements(v_prepared) WITH ORDINALITY e(value,ord)
        WHERE value->>'spell_id'=p_spell_id AND (value->>'slot_level')::integer=p_slot_level
          AND coalesce((value->>'expended')::boolean,false)=false ORDER BY ord LIMIT 1;
      IF v_idx IS NULL THEN RAISE EXCEPTION 'Nenhum espaço preparado disponível para essa magia e círculo'; END IF;
      v_prepared:=jsonb_set(v_prepared,ARRAY[v_idx::text,'expended'],'true'::jsonb,true);
      v_slot_total:=public._srd35_slots(v_class,v_level,v_score,p_slot_level);
      SELECT count(*)::integer INTO v_slots_remaining FROM jsonb_array_elements(v_prepared) e(value)
        WHERE (value->>'slot_level')::integer=p_slot_level AND coalesce((value->>'expended')::boolean,false)=false;
    END IF;
  END IF;

  v_target_key:=NULLIF(btrim(p_target_token_key),'');
  IF v_target_key IS NOT NULL AND v_campaign_id IS NULL THEN
    RAISE EXCEPTION 'Um alvo por token exige que o conjurador esteja em uma campanha';
  END IF;
  IF v_target_key IS NOT NULL THEN
    IF coalesce(v_spell.dados_tecnicos->>'tipo_efeito','')='cura' THEN
      SELECT c.cba_data INTO v_cba_data FROM public.campaigns c WHERE c.id=v_campaign_id FOR UPDATE;
    ELSE
      SELECT c.cba_data INTO v_cba_data FROM public.campaigns c WHERE c.id=v_campaign_id;
    END IF;
    IF NOT FOUND THEN RAISE EXCEPTION 'Campanha do conjurador não encontrada'; END IF;
    v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array' THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;
    SELECT count(*)::integer,min(e.ordinality),min(e.token->>'nome')
      INTO v_token_count,v_token_index,v_target_name
      FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
      WHERE e.token->>'key'=v_target_key;
    IF v_token_count<>1 THEN RAISE EXCEPTION 'Token-alvo não encontrado ou duplicado nesta campanha'; END IF;
    v_token:=v_tokens->(v_token_index::integer-1);
    v_target_type:=v_token->>'tipo';
    IF v_target_type IS NULL OR v_target_type NOT IN ('player','npc','monstro') THEN RAISE EXCEPTION 'Tipo do token-alvo inválido'; END IF;
  ELSIF coalesce(v_spell.dados_tecnicos->>'tipo_efeito','')='cura' THEN
    v_target_type:='player'; v_target_name:=v_caster_name; v_target_character_id:=p_character_id;
    IF v_campaign_id IS NOT NULL THEN
      SELECT c.cba_data INTO v_cba_data FROM public.campaigns c WHERE c.id=v_campaign_id FOR UPDATE;
      IF NOT FOUND THEN RAISE EXCEPTION 'Campanha do conjurador não encontrada'; END IF;
      v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array' THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;
    END IF;
  END IF;

  IF coalesce(v_spell.dados_tecnicos->>'tipo_efeito','')='cura' THEN
    v_target_character_id:=CASE WHEN v_target_key IS NULL THEN p_character_id ELSE NULL END;
    IF v_target_key IS NOT NULL AND v_target_type='player' THEN
      v_target_character_id:=v_token->>'id';
      IF NOT EXISTS (
        SELECT 1 FROM public.characters ch
        JOIN public.members m ON m.campaign_id=ch.campaign_id AND m.user_id=ch.user_id AND m.role='PLAYER'
        WHERE ch.id::text=v_target_character_id AND ch.campaign_id=v_campaign_id
      ) THEN RAISE EXCEPTION 'O token player não corresponde a um personagem jogador desta campanha'; END IF;
    END IF;
    v_dice:=coalesce(v_spell.dados_tecnicos->'cura'->>'dados','');
    IF v_dice ~ '^[0-9]+d[0-9]+([+-][0-9]+)?$' THEN
      v_die_count:=split_part(v_dice,'d',1)::integer;
      v_die_size:=regexp_replace(split_part(v_dice,'d',2),'[+-].*$','')::integer;
      IF v_die_count<1 OR v_die_count>100 OR v_die_size<2 OR v_die_size>100000 THEN RAISE EXCEPTION 'Dados de cura inválidos'; END IF;
      FOR v_idx IN 1..v_die_count LOOP v_roll:=v_roll+floor(random()*v_die_size)::integer+1; END LOOP;
      IF substring(v_dice from '([+-][0-9]+)$') IS NOT NULL THEN
        v_roll:=v_roll+substring(v_dice from '([+-][0-9]+)$')::integer;
      END IF;
    ELSIF v_dice ~ '^[0-9]+$' THEN
      v_roll:=v_dice::integer;
    ELSE
      RAISE EXCEPTION 'Expressão de cura inválida na magia';
    END IF;
    IF coalesce(v_spell.dados_tecnicos->'cura'->>'por_nivel','0') !~ '^-?[0-9]+$'
       OR coalesce(v_spell.dados_tecnicos->'cura'->>'max_nivel','0') !~ '^-?[0-9]+$' THEN
      RAISE EXCEPTION 'Parâmetros por_nivel/max_nivel inválidos na cura';
    END IF;
    v_per_level:=coalesce((v_spell.dados_tecnicos->'cura'->>'por_nivel')::integer,0);
    v_max_level:=coalesce((v_spell.dados_tecnicos->'cura'->>'max_nivel')::integer,0);
    IF v_per_level<0 OR v_max_level<0 THEN RAISE EXCEPTION 'Parâmetros de cura não podem ser negativos'; END IF;
    v_level_bonus:=CASE WHEN v_max_level>0 THEN least(v_level,v_max_level) ELSE v_level END;
    v_healing:=greatest(0,v_roll+v_per_level*v_level_bonus);

    IF v_target_type='player' THEN
      IF v_target_key IS NULL THEN
        v_target_hp:=v_sheet.pv_atual; v_target_max_hp:=v_sheet.pv_max;
        IF v_target_max_hp IS NULL OR v_target_max_hp<0 THEN RAISE EXCEPTION 'PV máximo válido ausente na ficha do conjurador'; END IF;
        IF COALESCE(v_target_hp,0)<=-10 OR priv.srd_condition_has_flag(v_campaign_id,'character',BTRIM(p_character_id),'no_healing') THEN
          RAISE EXCEPTION 'Personagens mortos não podem receber cura comum.';
        END IF;
        v_target_hp:=least(v_target_max_hp,coalesce(v_target_hp,0)+v_healing);
        UPDATE public.srd_character_sheets SET pv_atual=v_target_hp WHERE character_id::text=p_character_id;
        PERFORM priv.srd_sync_character_vital_condition(BTRIM(p_character_id),v_target_hp,
          v_target_hp<0 AND EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc WHERE cc.campaign_id=v_campaign_id AND cc.target_kind='character' AND cc.target_id=BTRIM(p_character_id) AND cc.condition_id='stable' AND cc.active=true));
      ELSE
        SELECT sh.pv_atual,sh.pv_max,ch.id::text,coalesce(ch.nome,'Aventureiro')
          INTO v_target_hp,v_target_max_hp,v_target_character_id,v_target_name
          FROM public.characters ch JOIN public.srd_character_sheets sh ON sh.character_id::text=ch.id::text
         WHERE ch.id::text=v_target_character_id AND ch.campaign_id=v_campaign_id
         FOR UPDATE OF ch,sh;
        IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD do alvo player não encontrada nesta campanha'; END IF;
        IF v_target_max_hp IS NULL OR v_target_max_hp<0 THEN RAISE EXCEPTION 'PV máximo válido ausente na ficha do alvo'; END IF;
        IF COALESCE(v_target_hp,0)<=-10 OR priv.srd_condition_has_flag(v_campaign_id,'character',BTRIM(v_target_character_id),'no_healing') THEN
          RAISE EXCEPTION 'Personagens mortos não podem receber cura comum.';
        END IF;
        v_target_hp:=least(v_target_max_hp,coalesce(v_target_hp,0)+v_healing);
        UPDATE public.srd_character_sheets SET pv_atual=v_target_hp WHERE character_id::text=v_target_character_id;
        PERFORM priv.srd_sync_character_vital_condition(BTRIM(v_target_character_id),v_target_hp,
          v_target_hp<0 AND EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc WHERE cc.campaign_id=v_campaign_id AND cc.target_kind='character' AND cc.target_id=BTRIM(v_target_character_id) AND cc.condition_id='stable' AND cc.active=true));
      END IF;
      IF v_campaign_id IS NOT NULL THEN
        IF v_tokens IS NULL THEN
          v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array' THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;
        END IF;
        SELECT count(*)::integer,min(e.ordinality) INTO v_token_count,v_token_index
          FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
         WHERE e.token->>'id'=v_target_character_id AND e.token->>'tipo'='player';
        IF v_target_key IS NOT NULL AND v_token_count<>1 THEN RAISE EXCEPTION 'Token player do alvo ausente ou duplicado na cena'; END IF;
        IF v_token_count>1 THEN RAISE EXCEPTION 'Há tokens player duplicados para o personagem-alvo'; END IF;
        IF v_token_count=1 THEN
          v_token:=v_tokens->(v_token_index::integer-1);
          v_token:=v_token||jsonb_build_object('hp',v_target_hp,'maxHp',v_target_max_hp);
          v_tokens:=jsonb_set(v_tokens,ARRAY[(v_token_index-1)::text],v_token,false);
          v_cba_data:=coalesce(v_cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens);
          UPDATE public.campaigns SET cba_data=v_cba_data WHERE id=v_campaign_id;
        END IF;
      END IF;
    ELSE
      IF coalesce(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN
        RAISE EXCEPTION 'O token NPC/monstro precisa de maxHp válido para receber cura';
      END IF;
      v_target_max_hp:=(v_token->>'maxHp')::integer;
      IF v_target_max_hp>100000 THEN RAISE EXCEPTION 'maxHp do token excede o limite aceito'; END IF;
      IF COALESCE(v_token->>'hp','') ~ '^-?[0-9]{1,6}$' AND (v_token->>'hp')::integer<=-10 THEN
        RAISE EXCEPTION 'Criaturas mortas não podem receber cura comum.';
      END IF;
      IF EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc
        WHERE cc.campaign_id=v_campaign_id AND cc.target_kind='token'
          AND cc.target_id IN (v_token->>'id',v_target_key)
          AND cc.condition_id='dead' AND cc.active=true) THEN
        RAISE EXCEPTION 'Criaturas mortas não podem receber cura comum.';
      END IF;
      v_target_hp:=CASE WHEN coalesce(v_token->>'hp','') ~ '^-?[0-9]{1,6}$' THEN (v_token->>'hp')::integer ELSE v_target_max_hp END;
      v_target_hp:=least(v_target_max_hp,v_target_hp+v_healing);
      v_token:=v_token||jsonb_build_object('hp',v_target_hp,'maxHp',v_target_max_hp);
      v_tokens:=jsonb_set(v_tokens,ARRAY[(v_token_index-1)::text],v_token,false);
      v_cba_data:=coalesce(v_cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens);
      UPDATE public.campaigns SET cba_data=v_cba_data WHERE id=v_campaign_id;
      IF v_target_type='npc' AND NULLIF(v_token->>'sourceCharacterId','') IS NOT NULL THEN
        PERFORM priv.srd_sync_linked_npc_token_vitals(v_campaign_id,COALESCE(NULLIF(v_token->>'id',''),v_target_key),v_target_hp,v_target_max_hp,
          v_target_hp<0 AND EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc
            WHERE cc.campaign_id=v_campaign_id AND cc.target_kind='token'
              AND cc.target_id IN (v_token->>'id',v_target_key) AND cc.condition_id='stable' AND cc.active=true));
      END IF;
    END IF;
  END IF;

  v_state:=jsonb_build_object('version',1,'conhecidas',v_known,'preparadas',v_prepared,'dominio_preparadas',v_domain_prepared,'usos',v_usos);
  UPDATE public.srd_character_sheets SET magias_preparadas=v_state WHERE character_id::text=p_character_id;
  RETURN jsonb_build_object(
    'estado',v_state,'healing',v_healing,'pv_atual',v_target_hp,'cba_data',v_cba_data,
    'target_name',v_target_name,'target_token_key',v_target_key,
    'slot_level',p_slot_level,'slots_remaining',v_slots_remaining,'slots_total',v_slot_total,
    'domain_slot_used',v_domain_slot_used,'domain_id',CASE WHEN v_domain_slot_used THEN v_domain_id ELSE NULL END
  );
END
$function$
;

-- conjurar_magia_srd_manual(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text, p_roll_results integer[])
CREATE OR REPLACE FUNCTION public.conjurar_magia_srd_manual(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text DEFAULT NULL::text, p_roll_results integer[] DEFAULT NULL::integer[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_doc jsonb; v_class text; v_level integer; v_score integer;
  v_state jsonb; v_known jsonb; v_prepared jsonb; v_usos jsonb; v_spell record;
  v_domain_prepared jsonb; v_domain_idx integer; v_domain_circle integer; v_domain_id text;
  v_class_access boolean := false; v_domain_access boolean := false; v_domain_slot_used boolean := false;
  v_circle integer; v_spell_level integer; v_use_count integer; v_capacity integer; v_idx integer; v_new_prepared jsonb;
  v_campaign_id public.characters.campaign_id%TYPE; v_caster_name text;
  v_cba_data jsonb; v_tokens jsonb; v_token jsonb; v_token_index bigint; v_token_count integer;
  v_target_type text; v_target_name text; v_target_key text; v_target_character_id text;
  v_target_hp integer; v_target_max_hp integer; v_healing integer := 0;
  v_roll integer := 0; v_die_count integer; v_die_size integer; v_dice text;
  v_per_level integer := 0; v_max_level integer := 0; v_level_bonus integer;
  v_slot_total integer; v_slots_remaining integer;
  v_effect_target_kind text; v_effect_target_id text; v_effect_target_user_id uuid;
  v_engine_rule jsonb; v_effect_data jsonb; v_pending_id uuid; v_condition_id text; v_save_type text; v_save_dc integer; v_duration_rounds integer; v_effect_instance bigint; v_effect_kind text; v_scale jsonb; v_scaled_value integer;
  v_damage integer:=0; v_damage_expression text; v_damage_scale jsonb; v_damage_dice_count integer; v_damage_flat integer:=0; v_damage_type text; v_sr integer:=0; v_spell_resistance boolean:=false; v_willing_target boolean:=false; v_pending_type text; v_resolution jsonb;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória'; END IF;
  SELECT c.campaign_id,c.nome INTO v_campaign_id,v_caster_name
    FROM public.characters c
   WHERE c.id::text=p_character_id AND c.user_id=auth.uid()
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou sem autorização'; END IF;
  IF v_campaign_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM public.members m WHERE m.campaign_id=v_campaign_id AND m.user_id=auth.uid()
    UNION ALL SELECT 1 FROM public.campaigns c WHERE c.id=v_campaign_id AND c.owner_id=auth.uid()
  ) THEN RAISE EXCEPTION 'O personagem não pertence a uma campanha da qual você participa'; END IF;

  IF priv.srd_condition_has_flag(v_campaign_id,'character',BTRIM(p_character_id),'no_actions') OR priv.srd_condition_has_flag(v_campaign_id,'character',BTRIM(p_character_id),'cannot_cast') THEN RAISE EXCEPTION 'A condição atual impede conjurar magias.'; END IF;
  SELECT s.* INTO v_sheet FROM public.srd_character_sheets s
    WHERE s.character_id::text=p_character_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada'; END IF;
  v_doc:=to_jsonb(v_sheet);
  SELECT public._srd35_class_key(cl.nome) INTO v_class
    FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe SRD da ficha não encontrada ou incompatível'; END IF;
  v_level:=public._srd35_character_class_level(p_character_id,v_class,v_sheet.classe_id,v_sheet.nivel);
  IF v_level IS NULL OR v_level NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Nível de conjurador ausente ou inválido para a classe.'; END IF;
  v_score:=CASE v_class
    WHEN 'wizard' THEN public._srd35_attr(v_doc,ARRAY['INT','inteligencia','intelligence','int_score','score_inteligencia'])::integer
    WHEN 'sorcerer' THEN public._srd35_attr(v_doc,ARRAY['CAR','carisma','charisma','cha','cha_score','score_carisma'])::integer
    ELSE public._srd35_attr(v_doc,ARRAY['SAB','sabedoria','wisdom','wis','wis_score','score_sabedoria'])::integer END;
  v_score:=v_score+priv.srd_effective_modifier(v_campaign_id,'character',p_character_id,CASE v_class WHEN 'wizard' THEN 'intelligence' WHEN 'sorcerer' THEN 'charisma' WHEN 'bard' THEN 'charisma' WHEN 'paladin' THEN 'charisma' ELSE 'wisdom' END);
  IF v_score IS NULL OR v_score < 1 THEN RAISE EXCEPTION 'Atributo-chave ausente ou inválido'; END IF;
  IF p_slot_level IS NULL OR p_slot_level NOT BETWEEN 0 AND 9 THEN RAISE EXCEPTION 'slot_level deve estar entre 0 e 9'; END IF;
  SELECT id,circulo,classes,dados_tecnicos,nivel INTO v_spell FROM public.srd_spells WHERE id=p_spell_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Magia inexistente ou nível inválido'; END IF;
  v_spell_level:=public._srd35_spell_level_for_class(v_spell.nivel,v_class,v_spell.circulo);
  IF v_spell_level NOT BETWEEN 0 AND 9 THEN RAISE EXCEPTION 'Nível da magia incompatível com a classe.'; END IF;
  v_class_access:=public._srd35_spell_class_ok(v_spell.classes,v_class);
  IF v_class='cleric' THEN
    SELECT ds.domain_id,ds.spell_level INTO v_domain_id,v_domain_circle
      FROM public.srd_character_domain_choices choice
      JOIN public.srd_domain_spells ds USING (domain_id)
     WHERE choice.character_id::text=p_character_id AND ds.spell_id=v_spell.id
       AND ds.spell_level=p_slot_level
     ORDER BY choice.domain_slot LIMIT 1;
    v_domain_access:=FOUND;
  END IF;
  IF NOT v_class_access AND NOT v_domain_access THEN
    RAISE EXCEPTION 'Magia inexistente ou não disponível pela classe/domínio escolhido';
  END IF;
  v_circle:=CASE WHEN v_class_access THEN v_spell_level ELSE v_domain_circle END;
  IF v_class_access AND
     (coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_spell_level)::integer
                  FROM public.srd_spell_progressions WHERE class_key=v_class),0)>0
      AND v_score>=10+v_circle) THEN
    v_class_access:=true;
  ELSE
    v_class_access:=false;
  END IF;
  IF v_domain_access AND
     (coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_domain_circle)::integer
                  FROM public.srd_spell_progressions WHERE class_key='cleric'),0)>0
      AND v_score>=10+v_domain_circle) THEN
    v_domain_access:=true;
  ELSE
    v_domain_access:=false;
  END IF;
  IF NOT v_class_access AND NOT v_domain_access THEN
    RAISE EXCEPTION 'Nível de magia, espaço de domínio ou atributo insuficiente';
  END IF;
  v_circle:=CASE WHEN v_class_access THEN v_spell_level ELSE v_domain_circle END;
  IF v_class='sorcerer' AND p_slot_level<>v_circle THEN RAISE EXCEPTION 'Feiticeiro conjura a magia no próprio círculo'; END IF;
  IF v_class<>'sorcerer' AND p_slot_level<v_circle AND NOT v_domain_access THEN RAISE EXCEPTION 'Espaço menor que o círculo da magia'; END IF;

  v_state:=coalesce(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
  v_known:=coalesce(v_state->'conhecidas','[]'::jsonb);
  v_prepared:=coalesce(v_state->'preparadas','[]'::jsonb);
  v_usos:=coalesce(v_state->'usos','{}'::jsonb);
  v_domain_prepared:=coalesce(v_state->'dominio_preparadas','[]'::jsonb);
  IF v_class='sorcerer' THEN
    IF NOT (v_known ? p_spell_id) THEN RAISE EXCEPTION 'Feiticeiro só pode conjurar magias conhecidas'; END IF;
    v_capacity:=public._srd35_slots(v_class,v_level,v_score,v_circle);
    v_use_count:=coalesce((v_usos->>v_circle::text)::integer,0);
    IF v_use_count>=v_capacity THEN RAISE EXCEPTION 'Sem usos diários restantes para este círculo'; END IF;
    v_usos:=jsonb_set(v_usos,ARRAY[v_circle::text],to_jsonb(v_use_count+1),true);
    v_slot_total:=v_capacity; v_slots_remaining:=v_capacity-v_use_count-1;
  ELSE
    IF v_class='cleric' AND v_domain_access THEN
      SELECT (ord-1)::integer INTO v_domain_idx
        FROM jsonb_array_elements(v_domain_prepared) WITH ORDINALITY e(value,ord)
       WHERE value->>'spell_id'=p_spell_id AND value->>'domain_id'=v_domain_id
         AND (value->>'slot_level')::integer=p_slot_level
         AND coalesce((value->>'expended')::boolean,false)=false
       ORDER BY ord LIMIT 1;
    END IF;
    IF v_domain_idx IS NOT NULL THEN
      v_domain_prepared:=jsonb_set(v_domain_prepared,ARRAY[v_domain_idx::text,'expended'],'true'::jsonb,true);
      v_domain_slot_used:=true; v_slot_total:=1; v_slots_remaining:=0;
    ELSE
      IF NOT v_class_access THEN RAISE EXCEPTION 'Espaço de domínio não preparado ou já gasto'; END IF;
      SELECT (ord-1)::integer INTO v_idx FROM jsonb_array_elements(v_prepared) WITH ORDINALITY e(value,ord)
        WHERE value->>'spell_id'=p_spell_id AND (value->>'slot_level')::integer=p_slot_level
          AND coalesce((value->>'expended')::boolean,false)=false ORDER BY ord LIMIT 1;
      IF v_idx IS NULL THEN RAISE EXCEPTION 'Nenhum espaço preparado disponível para essa magia e círculo'; END IF;
      v_prepared:=jsonb_set(v_prepared,ARRAY[v_idx::text,'expended'],'true'::jsonb,true);
      v_slot_total:=public._srd35_slots(v_class,v_level,v_score,p_slot_level);
      SELECT count(*)::integer INTO v_slots_remaining FROM jsonb_array_elements(v_prepared) e(value)
        WHERE (value->>'slot_level')::integer=p_slot_level AND coalesce((value->>'expended')::boolean,false)=false;
    END IF;
  END IF;

  v_target_key:=NULLIF(btrim(p_target_token_key),'');
  IF v_target_key IS NOT NULL AND v_campaign_id IS NULL THEN
    RAISE EXCEPTION 'Um alvo por token exige que o conjurador esteja em uma campanha';
  END IF;
  IF v_target_key IS NOT NULL THEN
    IF coalesce(v_spell.dados_tecnicos->>'tipo_efeito','')='cura' THEN
      SELECT c.cba_data INTO v_cba_data FROM public.campaigns c WHERE c.id=v_campaign_id FOR UPDATE;
    ELSE
      SELECT c.cba_data INTO v_cba_data FROM public.campaigns c WHERE c.id=v_campaign_id;
    END IF;
    IF NOT FOUND THEN RAISE EXCEPTION 'Campanha do conjurador não encontrada'; END IF;
    v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array' THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;
    SELECT count(*)::integer,min(e.ordinality),min(e.token->>'nome')
      INTO v_token_count,v_token_index,v_target_name
      FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
      WHERE e.token->>'key'=v_target_key;
    IF v_token_count<>1 THEN RAISE EXCEPTION 'Token-alvo não encontrado ou duplicado nesta campanha'; END IF;
    v_token:=v_tokens->(v_token_index::integer-1);
    v_target_type:=v_token->>'tipo';
    IF v_target_type IS NULL OR v_target_type NOT IN ('player','npc','monstro') THEN RAISE EXCEPTION 'Tipo do token-alvo inválido'; END IF;
  ELSIF coalesce(v_spell.dados_tecnicos->>'tipo_efeito','')='cura' THEN
    v_target_type:='player'; v_target_name:=v_caster_name; v_target_character_id:=p_character_id;
    IF v_campaign_id IS NOT NULL THEN
      SELECT c.cba_data INTO v_cba_data FROM public.campaigns c WHERE c.id=v_campaign_id FOR UPDATE;
      IF NOT FOUND THEN RAISE EXCEPTION 'Campanha do conjurador não encontrada'; END IF;
      v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array' THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;
    END IF;
  END IF;

  IF coalesce(v_spell.dados_tecnicos->>'tipo_efeito','')='cura' THEN
    v_target_character_id:=CASE WHEN v_target_key IS NULL THEN p_character_id ELSE NULL END;
    IF v_target_key IS NOT NULL AND v_target_type='player' THEN
      v_target_character_id:=v_token->>'id';
      IF NOT EXISTS (
        SELECT 1 FROM public.characters ch
        JOIN public.members m ON m.campaign_id=ch.campaign_id AND m.user_id=ch.user_id AND m.role='PLAYER'
        WHERE ch.id::text=v_target_character_id AND ch.campaign_id=v_campaign_id
      ) THEN RAISE EXCEPTION 'O token player não corresponde a um personagem jogador desta campanha'; END IF;
    END IF;
    v_dice:=coalesce(v_spell.dados_tecnicos->'cura'->>'dados','');
    IF v_dice ~ '^[0-9]+d[0-9]+([+-][0-9]+)?$' THEN
      v_die_count:=split_part(v_dice,'d',1)::integer;
      v_die_size:=regexp_replace(split_part(v_dice,'d',2),'[+-].*$','')::integer;
      IF v_die_count<1 OR v_die_count>100 OR v_die_size<2 OR v_die_size>100000 THEN RAISE EXCEPTION 'Dados de cura inválidos'; END IF;
      IF p_roll_results IS NULL OR cardinality(p_roll_results)<>v_die_count
         OR EXISTS(SELECT 1 FROM unnest(p_roll_results) value WHERE value<1 OR value>v_die_size) THEN
        RAISE EXCEPTION 'A cura exige exatamente % resultado(s) manual(is) de d%.',v_die_count,v_die_size;
      END IF;
      SELECT coalesce(sum(value),0) INTO v_roll FROM unnest(p_roll_results) value;
      IF substring(v_dice from '([+-][0-9]+)$') IS NOT NULL THEN
        v_roll:=v_roll+substring(v_dice from '([+-][0-9]+)$')::integer;
      END IF;
    ELSIF v_dice ~ '^[0-9]+$' THEN
      IF p_roll_results IS NOT NULL AND cardinality(p_roll_results)>0 THEN RAISE EXCEPTION 'Esta cura não exige dados adicionais.'; END IF;
      v_roll:=v_dice::integer;
    ELSE
      RAISE EXCEPTION 'Expressão de cura inválida na magia';
    END IF;
    IF coalesce(v_spell.dados_tecnicos->'cura'->>'por_nivel','0') !~ '^-?[0-9]+$'
       OR coalesce(v_spell.dados_tecnicos->'cura'->>'max_nivel','0') !~ '^-?[0-9]+$' THEN
      RAISE EXCEPTION 'Parâmetros por_nivel/max_nivel inválidos na cura';
    END IF;
    v_per_level:=coalesce((v_spell.dados_tecnicos->'cura'->>'por_nivel')::integer,0);
    v_max_level:=coalesce((v_spell.dados_tecnicos->'cura'->>'max_nivel')::integer,0);
    IF v_per_level<0 OR v_max_level<0 THEN RAISE EXCEPTION 'Parâmetros de cura não podem ser negativos'; END IF;
    v_level_bonus:=CASE WHEN v_max_level>0 THEN least(v_level,v_max_level) ELSE v_level END;
    v_healing:=greatest(0,v_roll+v_per_level*v_level_bonus);
    IF v_target_character_id IS NOT NULL THEN
      v_healing:=GREATEST(0,v_healing+priv.srd_effective_modifier(v_campaign_id,'character',v_target_character_id,'healing_received'));
    ELSIF v_target_key IS NOT NULL THEN
      v_healing:=GREATEST(0,v_healing+priv.srd_effective_modifier(v_campaign_id,'token',v_target_key,'healing_received'));
    END IF;

    IF v_target_type='player' THEN
      IF v_target_key IS NULL THEN
        v_target_hp:=v_sheet.pv_atual; v_target_max_hp:=v_sheet.pv_max;
        IF v_target_max_hp IS NULL OR v_target_max_hp<0 THEN RAISE EXCEPTION 'PV máximo válido ausente na ficha do conjurador'; END IF;
        IF v_target_character_id IS NOT NULL AND priv.srd_condition_has_flag(v_campaign_id,'character',v_target_character_id,'no_healing') THEN v_healing:=0; END IF;
IF v_target_key IS NOT NULL AND v_target_character_id IS NULL AND priv.srd_condition_has_flag(v_campaign_id,'token',v_target_key,'no_healing') THEN v_healing:=0; END IF;
IF COALESCE(v_target_hp,0)<=-10 THEN v_healing:=0; END IF;
v_target_hp:=CASE WHEN COALESCE(v_target_hp,0)<=-10 THEN COALESCE(v_target_hp,0) ELSE LEAST(v_target_max_hp,COALESCE(v_target_hp,0)+v_healing) END;
        UPDATE public.srd_character_sheets SET pv_atual=v_target_hp WHERE character_id::text=p_character_id;
        PERFORM priv.srd_sync_character_vital_condition(p_character_id,v_target_hp,v_healing>0);
      ELSE
        SELECT sh.pv_atual,sh.pv_max,ch.id::text,coalesce(ch.nome,'Aventureiro')
          INTO v_target_hp,v_target_max_hp,v_target_character_id,v_target_name
          FROM public.characters ch JOIN public.srd_character_sheets sh ON sh.character_id::text=ch.id::text
         WHERE ch.id::text=v_target_character_id AND ch.campaign_id=v_campaign_id
         FOR UPDATE OF ch,sh;
        IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD do alvo player não encontrada nesta campanha'; END IF;
        IF v_target_max_hp IS NULL OR v_target_max_hp<0 THEN RAISE EXCEPTION 'PV máximo válido ausente na ficha do alvo'; END IF;
        IF v_target_character_id IS NOT NULL AND priv.srd_condition_has_flag(v_campaign_id,'character',v_target_character_id,'no_healing') THEN v_healing:=0; END IF;
IF v_target_key IS NOT NULL AND v_target_character_id IS NULL AND priv.srd_condition_has_flag(v_campaign_id,'token',v_target_key,'no_healing') THEN v_healing:=0; END IF;
IF COALESCE(v_target_hp,0)<=-10 THEN v_healing:=0; END IF;
v_target_hp:=CASE WHEN COALESCE(v_target_hp,0)<=-10 THEN COALESCE(v_target_hp,0) ELSE LEAST(v_target_max_hp,COALESCE(v_target_hp,0)+v_healing) END;
        UPDATE public.srd_character_sheets SET pv_atual=v_target_hp WHERE character_id::text=v_target_character_id;
        PERFORM priv.srd_sync_character_vital_condition(v_target_character_id,v_target_hp,v_healing>0);
      END IF;
      IF v_campaign_id IS NOT NULL THEN
        IF v_tokens IS NULL THEN
          v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array' THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;
        END IF;
        SELECT count(*)::integer,min(e.ordinality) INTO v_token_count,v_token_index
          FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
         WHERE e.token->>'id'=v_target_character_id AND e.token->>'tipo'='player';
        IF v_target_key IS NOT NULL AND v_token_count<>1 THEN RAISE EXCEPTION 'Token player do alvo ausente ou duplicado na cena'; END IF;
        IF v_token_count>1 THEN RAISE EXCEPTION 'Há tokens player duplicados para o personagem-alvo'; END IF;
        IF v_token_count=1 THEN
          v_token:=v_tokens->(v_token_index::integer-1);
          v_token:=v_token||jsonb_build_object('hp',v_target_hp,'maxHp',v_target_max_hp);
          v_tokens:=jsonb_set(v_tokens,ARRAY[(v_token_index-1)::text],v_token,false);
          v_cba_data:=coalesce(v_cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens);
          UPDATE public.campaigns SET cba_data=v_cba_data WHERE id=v_campaign_id;
        END IF;
      END IF;
    ELSE
      IF coalesce(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN
        RAISE EXCEPTION 'O token NPC/monstro precisa de maxHp válido para receber cura';
      END IF;
      v_target_max_hp:=(v_token->>'maxHp')::integer;
      IF v_target_max_hp>100000 THEN RAISE EXCEPTION 'maxHp do token excede o limite aceito'; END IF;
      IF COALESCE(v_token->>'hp','') ~ '^-?[0-9]{1,6}$' AND (v_token->>'hp')::integer<=-10 THEN
        RAISE EXCEPTION 'Criaturas mortas não podem receber cura comum.';
      END IF;
      IF EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc
        WHERE cc.campaign_id=v_campaign_id AND cc.target_kind='token'
          AND cc.target_id IN (v_token->>'id',v_target_key)
          AND cc.condition_id='dead' AND cc.active=true) THEN
        RAISE EXCEPTION 'Criaturas mortas não podem receber cura comum.';
      END IF;
      v_target_hp:=CASE WHEN coalesce(v_token->>'hp','') ~ '^-?[0-9]{1,6}$' THEN (v_token->>'hp')::integer ELSE v_target_max_hp END;
      v_target_hp:=least(v_target_max_hp,v_target_hp+v_healing);
      v_token:=v_token||jsonb_build_object('hp',v_target_hp,'maxHp',v_target_max_hp);
      v_tokens:=jsonb_set(v_tokens,ARRAY[(v_token_index-1)::text],v_token,false);
      v_cba_data:=coalesce(v_cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens);
      UPDATE public.campaigns SET cba_data=v_cba_data WHERE id=v_campaign_id;
      IF v_target_type='npc' AND NULLIF(v_token->>'sourceCharacterId','') IS NOT NULL THEN
        PERFORM priv.srd_sync_linked_npc_token_vitals(v_campaign_id,COALESCE(NULLIF(v_token->>'id',''),v_target_key),v_target_hp,v_target_max_hp,
          v_target_hp<0 AND EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc
            WHERE cc.campaign_id=v_campaign_id AND cc.target_kind='token'
              AND cc.target_id IN (v_token->>'id',v_target_key) AND cc.condition_id='stable' AND cc.active=true));
      END IF;
    END IF;
  END IF;


  IF v_campaign_id IS NOT NULL AND EXISTS(SELECT 1 FROM public.srd_spell_effects se WHERE se.spell_id=v_spell.id AND se.verification_status='verified_srd' AND se.parameters ? 'engine_rule') THEN
    SELECT se.parameters->'engine_rule' INTO v_engine_rule
    FROM public.srd_spell_effects se
    WHERE se.spell_id=v_spell.id AND se.verification_status='verified_srd'
    ORDER BY se.effect_index LIMIT 1;
    IF v_engine_rule IS NULL THEN RAISE EXCEPTION 'A regra automática desta magia não está validada.'; END IF;
    IF v_engine_rule->>'target_scope'='self_only' AND v_target_key IS NOT NULL THEN
      RAISE EXCEPTION 'Esta magia só pode ser aplicada automaticamente ao próprio conjurador nesta versão.';
    END IF;
    IF v_target_key IS NULL THEN
      v_effect_target_kind:='character'; v_effect_target_id:=p_character_id;
      v_target_character_id:=p_character_id; v_target_type:='player'; v_target_name:=v_caster_name;
    ELSIF v_target_type='player' THEN
      v_effect_target_kind:='character'; v_target_character_id:=v_token->>'id'; v_effect_target_id:=v_target_character_id;
    ELSE
      v_effect_target_kind:='token'; v_effect_target_id:=v_target_key;
    END IF;
    IF v_effect_target_kind='character' THEN
      SELECT ch.user_id INTO v_effect_target_user_id FROM public.characters ch
      WHERE ch.id::text=v_effect_target_id AND ch.campaign_id=v_campaign_id;
      IF NOT FOUND THEN RAISE EXCEPTION 'Personagem-alvo não pertence à campanha.'; END IF;
    END IF;
    v_effect_data:=COALESCE(v_engine_rule->'effect_data','{}'::jsonb);
    v_effect_kind:=COALESCE(v_engine_rule->>'effect_kind',CASE v_engine_rule->>'resolver' WHEN 'debuff' THEN 'debuff' ELSE 'buff' END);
    v_save_type:=NULLIF(v_engine_rule->>'save_type','');
    v_condition_id:=CASE
      WHEN v_spell.id='srd35_spell_blindness_deafness' AND p_roll_results IS NOT NULL AND p_roll_results[1]=2 THEN 'deafened'
      ELSE NULLIF(v_engine_rule->>'condition_id','') END;
    v_duration_rounds:=CASE
      WHEN v_engine_rule ? 'duration_rounds_per_caster_level' THEN v_level*(v_engine_rule->>'duration_rounds_per_caster_level')::integer
      WHEN v_engine_rule ? 'duration_rounds' THEN (v_engine_rule->>'duration_rounds')::integer
      ELSE NULL END;

    v_scale:=v_engine_rule->'level_scale';
    IF v_scale IS NOT NULL AND jsonb_typeof(v_scale)='object' AND jsonb_typeof(v_effect_data->'modifiers')='array' THEN
      v_scaled_value:=COALESCE((v_scale->>'base')::integer,0)
        +GREATEST(0,FLOOR((v_level-COALESCE((v_scale->>'start_level')::integer,1))::numeric/GREATEST(1,COALESCE((v_scale->>'every_levels')::integer,1)))::integer);
      IF v_scale ? 'cap' THEN v_scaled_value:=LEAST(v_scaled_value,(v_scale->>'cap')::integer); END IF;
      v_effect_data:=jsonb_set(v_effect_data,'{modifiers,0,value}',to_jsonb(v_scaled_value),true);
    END IF;

    v_willing_target:=COALESCE((v_engine_rule->>'willing_target')::boolean,false);
    v_spell_resistance:=COALESCE((v_engine_rule->>'spell_resistance')::boolean,false) AND NOT v_willing_target;

    IF v_engine_rule->>'resolver'='damage' THEN
      IF v_target_key IS NULL THEN RAISE EXCEPTION 'Esta magia exige um alvo selecionado.'; END IF;
      IF v_engine_rule->>'target_filter'='plant_creature' THEN
        IF v_target_type NOT IN ('npc','monstro')
           OR lower(COALESCE(v_token->'monsterStats'->>'type',v_token->'monsterStats'->>'tipo','')) NOT LIKE '%plant%' THEN
          RAISE EXCEPTION 'Esta magia só afeta criaturas do tipo Planta; o alvo selecionado não corresponde.';
        END IF;
      END IF;

      v_damage_expression:=COALESCE(v_engine_rule->>'damage_expression',v_effect_data->>'damage_expression');
      IF COALESCE(v_damage_expression,'') !~ '^[0-9]{1,3}d(2|3|4|6|8|10|12|20|100)([+-][0-9]{1,5})?$' THEN
        RAISE EXCEPTION 'Expressão de dano automática inválida para esta magia.';
      END IF;
      v_die_count:=split_part(v_damage_expression,'d',1)::integer;
      v_die_size:=regexp_replace(split_part(v_damage_expression,'d',2),'[+-].*$','')::integer;
      v_damage_flat:=COALESCE(substring(v_damage_expression from '([+-][0-9]+)$')::integer,0);
      v_damage_dice_count:=v_die_count;
      v_damage_scale:=v_engine_rule->'damage_scaling';
      IF v_damage_scale IS NOT NULL AND jsonb_typeof(v_damage_scale)='object' THEN
        v_damage_dice_count:=COALESCE((v_damage_scale->>'base_dice')::integer,v_die_count)
          +GREATEST(0,FLOOR((v_level-COALESCE((v_damage_scale->>'start_level')::integer,1))::numeric
          /GREATEST(1,COALESCE((v_damage_scale->>'every_levels')::integer,1)))::integer)
          *COALESCE((v_damage_scale->>'dice_per_level')::integer,0);
        IF v_damage_scale ? 'cap_dice' THEN v_damage_dice_count:=LEAST(v_damage_dice_count,(v_damage_scale->>'cap_dice')::integer); END IF;
      END IF;
      IF v_damage_dice_count<1 OR v_damage_dice_count>100 THEN RAISE EXCEPTION 'Quantidade de dados de dano fora do limite.'; END IF;
      IF p_roll_results IS NULL OR cardinality(p_roll_results)<>v_damage_dice_count
         OR EXISTS(SELECT 1 FROM unnest(p_roll_results) value WHERE value<1 OR value>v_die_size) THEN
        RAISE EXCEPTION 'Esta magia exige exatamente % resultado(s) manual(is) de d%.',v_damage_dice_count,v_die_size;
      END IF;
      SELECT COALESCE(SUM(value),0) INTO v_roll FROM unnest(p_roll_results) value;
      v_damage:=GREATEST(0,v_roll+v_damage_flat);
      v_damage_type:=COALESCE(NULLIF(v_engine_rule->>'damage_type',''),'untyped');
      IF v_damage_type !~ '^[a-z_]{1,24}$' THEN RAISE EXCEPTION 'Tipo de dano inválido.'; END IF;
      v_effect_data:=v_effect_data||jsonb_build_object(
        'damage',v_damage,'damage_type',v_damage_type,
        'save_result',COALESCE(v_engine_rule->>'save_result','none'),
        'damage_expression',v_damage_dice_count::text||'d'||v_die_size,
        'damage_components',v_engine_rule->'damage_components'
      );
      v_effect_kind:='damage';
      v_save_type:=NULLIF(v_engine_rule->>'save_type','');
      v_save_dc:=CASE WHEN v_save_type IS NOT NULL THEN 10+v_circle+FLOOR((v_score-10)::numeric/2)::integer+CASE WHEN v_sheet.raca_id='gnomo' AND lower(COALESCE(v_spell.escola,'') ) LIKE '%illusion%' THEN 1 ELSE 0 END ELSE NULL END;
      v_sr:=CASE WHEN v_spell_resistance THEN priv.srd_spell_resistance_value(v_campaign_id,v_effect_target_kind,v_effect_target_id) ELSE 0 END;

      INSERT INTO priv.srd_pending_spell_resolutions(
        campaign_id,caster_character_id,target_kind,target_id,target_user_id,spell_id,
        save_type,save_dc,condition_id,duration_rounds,effect_data,effect_kind,spell_resistance,caster_level,status
      ) VALUES (
        v_campaign_id,p_character_id,v_effect_target_kind,v_effect_target_id,v_effect_target_user_id,v_spell.id,
        v_save_type,v_save_dc,NULL,v_duration_rounds,v_effect_data,'damage',v_spell_resistance,v_level,
        CASE WHEN v_sr>0 THEN 'awaiting_spell_resistance' ELSE 'pending_save' END
      ) RETURNING pending_id INTO v_pending_id;

      IF v_sr>0 THEN
        v_pending_type:='spell_resistance';
        INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
        VALUES(v_campaign_id,'test_request','PUBLIC',jsonb_build_object(
          'tipo','Penetração de Resistência à Magia (D20)',
          'alvos',jsonb_build_array(p_character_id),'npc_alvos','[]'::jsonb,
          'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
          'resolution_type','spell_resistance','pending_id',v_pending_id,'spell_id',v_spell.id,
          'spell_resistance',v_sr,'caster_level',v_level
        ));
      ELSIF v_save_type IS NOT NULL THEN
        v_pending_type:='spell_save';
        INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
        VALUES(v_campaign_id,'test_request','PUBLIC',jsonb_build_object(
          'tipo','Resistência de '||CASE v_save_type WHEN 'fortitude' THEN 'Fortitude' WHEN 'reflex' THEN 'Reflexos' ELSE 'Vontade' END||' (D20)',
          'alvos',CASE WHEN v_effect_target_kind='character' THEN jsonb_build_array(v_effect_target_id) ELSE '[]'::jsonb END,
          'npc_alvos',CASE WHEN v_effect_target_kind='token' THEN jsonb_build_array(v_effect_target_id) ELSE '[]'::jsonb END,
          'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
          'resolution_type','spell_save','pending_id',v_pending_id,'spell_id',v_spell.id,'save_type',v_save_type,'save_dc',v_save_dc
        ));
      ELSE
        v_resolution:=priv.srd_apply_pending_spell_resolution(v_pending_id);
        v_damage:=COALESCE((v_resolution->>'damage')::integer,0);
        v_target_hp:=NULLIF(v_resolution->>'pv_atual','')::integer;
        v_target_max_hp:=NULLIF(v_resolution->>'pv_max','')::integer;
        v_target_name:=COALESCE(v_resolution->>'target_name',v_target_name);
        SELECT cba_data INTO v_cba_data FROM public.campaigns WHERE id=v_campaign_id;
      END IF;
    ELSE
      IF v_willing_target THEN v_save_type:=NULL; END IF;
      v_sr:=CASE WHEN v_spell_resistance THEN priv.srd_spell_resistance_value(v_campaign_id,v_effect_target_kind,v_effect_target_id) ELSE 0 END;
      IF v_sr>0 THEN
        v_pending_type:='spell_resistance';
        v_save_dc:=CASE WHEN v_save_type IS NOT NULL THEN 10+v_circle+FLOOR((v_score-10)::numeric/2)::integer+CASE WHEN v_sheet.raca_id='gnomo' AND lower(COALESCE(v_spell.escola,'') ) LIKE '%illusion%' THEN 1 ELSE 0 END ELSE NULL END;
        INSERT INTO priv.srd_pending_spell_resolutions(
          campaign_id,caster_character_id,target_kind,target_id,target_user_id,spell_id,
          save_type,save_dc,condition_id,duration_rounds,effect_data,effect_kind,spell_resistance,caster_level,status
        ) VALUES(
          v_campaign_id,p_character_id,v_effect_target_kind,v_effect_target_id,v_effect_target_user_id,v_spell.id,
          v_save_type,v_save_dc,v_condition_id,v_duration_rounds,v_effect_data,v_effect_kind,true,v_level,'awaiting_spell_resistance'
        ) RETURNING pending_id INTO v_pending_id;
        INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
        VALUES(v_campaign_id,'test_request','PUBLIC',jsonb_build_object(
          'tipo','Penetração de Resistência à Magia (D20)','alvos',jsonb_build_array(p_character_id),'npc_alvos','[]'::jsonb,
          'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
          'resolution_type','spell_resistance','pending_id',v_pending_id,'spell_id',v_spell.id,
          'spell_resistance',v_sr,'caster_level',v_level
        ));
      ELSIF v_engine_rule->>'resolver'='buff' OR (v_engine_rule->>'resolver'='debuff' AND v_save_type IS NULL) THEN
        v_effect_instance:=priv.srd_apply_campaign_effect(v_campaign_id,v_effect_target_kind,v_effect_target_id,v_effect_kind,
          v_effect_data,v_duration_rounds,v_spell.id,NULL);
      ELSIF v_engine_rule->>'resolver'='condition' AND v_save_type IS NULL THEN
        v_effect_instance:=priv.srd_apply_campaign_condition(v_campaign_id,v_effect_target_kind,v_effect_target_id,
          v_condition_id,v_duration_rounds,jsonb_build_object('source_spell_id',v_spell.id,'caster_character_id',p_character_id),v_spell.id);
      ELSE
        IF v_save_type IS NULL THEN RAISE EXCEPTION 'A regra automática da magia não possui uma resistência válida.'; END IF;
        v_save_dc:=10+v_circle+FLOOR((v_score-10)::numeric/2)::integer;
        v_pending_type:='spell_save';
        INSERT INTO priv.srd_pending_spell_resolutions(
          campaign_id,caster_character_id,target_kind,target_id,target_user_id,spell_id,
          save_type,save_dc,condition_id,duration_rounds,effect_data,effect_kind,spell_resistance,caster_level,status
        ) VALUES(
          v_campaign_id,p_character_id,v_effect_target_kind,v_effect_target_id,v_effect_target_user_id,v_spell.id,
          v_save_type,v_save_dc,v_condition_id,v_duration_rounds,v_effect_data,v_effect_kind,false,v_level,'pending_save'
        ) RETURNING pending_id INTO v_pending_id;
        INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
        VALUES(v_campaign_id,'test_request','PUBLIC',jsonb_build_object(
          'tipo','Resistência de '||CASE v_save_type WHEN 'fortitude' THEN 'Fortitude' WHEN 'reflex' THEN 'Reflexos' ELSE 'Vontade' END||' (D20)',
          'alvos',CASE WHEN v_effect_target_kind='character' THEN jsonb_build_array(v_effect_target_id) ELSE '[]'::jsonb END,
          'npc_alvos',CASE WHEN v_effect_target_kind='token' THEN jsonb_build_array(v_effect_target_id) ELSE '[]'::jsonb END,
          'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
          'resolution_type','spell_save','pending_id',v_pending_id,'spell_id',v_spell.id,'save_type',v_save_type,'save_dc',v_save_dc
        ));
      END IF;
    END IF;
  END IF;

  v_state:=jsonb_build_object('version',1,'conhecidas',v_known,'preparadas',v_prepared,'dominio_preparadas',v_domain_prepared,'usos',v_usos);
  UPDATE public.srd_character_sheets SET magias_preparadas=v_state WHERE character_id::text=p_character_id;
  RETURN jsonb_build_object(
    'estado',v_state,'healing',v_healing,'damage',v_damage,'pv_atual',v_target_hp,'pv_max',v_target_max_hp,'cba_data',v_cba_data,
    'target_name',v_target_name,'target_token_key',v_target_key,
    'slot_level',p_slot_level,'slots_remaining',v_slots_remaining,'slots_total',v_slot_total,
    'domain_slot_used',v_domain_slot_used,'domain_id',CASE WHEN v_domain_slot_used THEN v_domain_id ELSE NULL END,'pending_resolution_id',v_pending_id,'pending_resolution_type',v_pending_type,'effect_instance_id',v_effect_instance
  );
END
$function$
;

-- conjurar_magia_srd_multialvo(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])
CREATE OR REPLACE FUNCTION public.conjurar_magia_srd_multialvo(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_campaign_id bigint;
  v_spell record;
  v_result jsonb;
  v_targets jsonb := '[]'::jsonb;
  v_cba_data jsonb;
  v_tokens jsonb;
  v_token jsonb;
  v_token_index bigint;
  v_token_count integer;
  v_key text;
  v_target_type text;
  v_target_character_id text;
  v_hp integer;
  v_max_hp integer;
  v_healing integer;
  v_roll integer;
  v_die_count integer;
  v_die_size integer;
  v_dice text;
  v_per_level integer;
  v_max_level integer;
  v_level integer;
  v_idx integer;
  v_is_undead boolean;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória'; END IF;
  IF p_target_token_keys IS NULL
     OR cardinality(p_target_token_keys) < 1
     OR cardinality(p_target_token_keys) > 20
     OR EXISTS (
       SELECT 1 FROM unnest(p_target_token_keys) k
       WHERE NULLIF(btrim(k), '') IS NULL
     )
  THEN
    RAISE EXCEPTION 'Informe entre 1 e 20 tokens-alvo válidos';
  END IF;
  IF EXISTS (
    SELECT 1 FROM (
      SELECT btrim(k) AS key, count(*) AS n
      FROM unnest(p_target_token_keys) k
      GROUP BY btrim(k)
    ) d WHERE d.n > 1
  ) THEN
    RAISE EXCEPTION 'Cada token-alvo deve aparecer uma única vez';
  END IF;

  SELECT ch.campaign_id INTO v_campaign_id
  FROM public.characters ch
  WHERE ch.id::text=btrim(p_character_id) AND ch.user_id=auth.uid()
  FOR UPDATE;
  IF NOT FOUND OR v_campaign_id IS NULL THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem campanha autorizada';
  END IF;

  SELECT id,circulo,dados_tecnicos INTO v_spell
  FROM public.srd_spells WHERE id=p_spell_id;
  IF NOT FOUND
     OR coalesce(v_spell.dados_tecnicos->>'tipo_efeito','') <> 'cura'
     OR coalesce(v_spell.dados_tecnicos->>'target_mode','') <> 'multiple_targets_pending'
  THEN
    RAISE EXCEPTION 'A magia informada não é uma cura SRD de múltiplos alvos';
  END IF;
  IF p_slot_level IS NULL OR p_slot_level NOT BETWEEN 0 AND 9 THEN
    RAISE EXCEPTION 'slot_level deve estar entre 0 e 9';
  END IF;

  SELECT c.cba_data INTO v_cba_data
  FROM public.campaigns c WHERE c.id=v_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada'; END IF;
  v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array'
                 THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;

  -- Validate the first token before consuming the prepared slot.
  SELECT count(*)::integer,min(e.ordinality),min(e.token->>'tipo'),
         min(e.token->>'id'),bool_or(coalesce(e.token->'monsterStats'->>'tipo','') ILIKE '%undead%')
    INTO v_token_count,v_token_index,v_target_type,v_target_character_id,v_is_undead
  FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
  WHERE e.token->>'key'=btrim(p_target_token_keys[1]);
  IF v_token_count<>1 THEN RAISE EXCEPTION 'Primeiro token-alvo não encontrado ou duplicado'; END IF;
  IF coalesce(v_is_undead,false) THEN
    RAISE EXCEPTION 'Cura em massa contra mortos-vivos ainda requer o resolver de dano por energia positiva';
  END IF;

  v_result:=public.conjurar_magia_srd(
    p_character_id,p_spell_id,p_slot_level,btrim(p_target_token_keys[1])
  );
  v_targets:=v_targets||jsonb_build_array(jsonb_build_object(
    'token_key',btrim(p_target_token_keys[1]),
    'healing',coalesce((v_result->>'healing')::integer,0),
    'pv_atual',v_result->'pv_atual'
  ));

  v_dice:=coalesce(v_spell.dados_tecnicos->'cura'->>'dados','');
  IF v_dice ~ '^[0-9]+d[0-9]+([+-][0-9]+)?$' THEN
    v_die_count:=split_part(v_dice,'d',1)::integer;
    v_die_size:=regexp_replace(split_part(v_dice,'d',2),'[+-].*$','')::integer;
  ELSIF v_dice ~ '^[0-9]+$' THEN
    v_die_count:=0;
    v_die_size:=0;
  ELSE
    RAISE EXCEPTION 'Expressão de cura inválida na magia';
  END IF;
  v_per_level:=coalesce((v_spell.dados_tecnicos->'cura'->>'por_nivel')::integer,0);
  v_max_level:=coalesce((v_spell.dados_tecnicos->'cura'->>'max_nivel')::integer,0);
  SELECT nivel INTO v_level FROM public.srd_character_sheets
  WHERE character_id::text=btrim(p_character_id) FOR UPDATE;

  FOR v_idx IN 2..cardinality(p_target_token_keys) LOOP
    v_key:=btrim(p_target_token_keys[v_idx]);
    SELECT count(*)::integer,min(e.ordinality),min(e.token->>'tipo'),
           min(e.token->>'id'),bool_or(coalesce(e.token->'monsterStats'->>'tipo','') ILIKE '%undead%')
      INTO v_token_count,v_token_index,v_target_type,v_target_character_id,v_is_undead
    FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
    WHERE e.token->>'key'=v_key;
    SELECT e.token INTO v_token
    FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
    WHERE e.token->>'key'=v_key LIMIT 1;
    IF v_token_count<>1 THEN RAISE EXCEPTION 'Token-alvo não encontrado ou duplicado: %',v_key; END IF;
    IF coalesce(v_is_undead,false) THEN
      RAISE EXCEPTION 'Cura em massa contra mortos-vivos ainda requer o resolver de dano por energia positiva';
    END IF;

    IF v_die_count>0 THEN
      v_roll:=0;
      FOR v_idx IN 1..v_die_count LOOP
        v_roll:=v_roll+floor(random()*v_die_size)::integer+1;
      END LOOP;
      IF substring(v_dice from '([+-][0-9]+)$') IS NOT NULL THEN
        v_roll:=v_roll+substring(v_dice from '([+-][0-9]+)$')::integer;
      END IF;
    ELSE
      v_roll:=v_dice::integer;
    END IF;
    v_healing:=greatest(0,v_roll+v_per_level*CASE WHEN v_max_level>0 THEN least(v_level,v_max_level) ELSE v_level END);

    IF v_target_type='player' THEN
      SELECT sh.pv_atual,sh.pv_max INTO v_hp,v_max_hp
      FROM public.characters ch
      JOIN public.srd_character_sheets sh ON sh.character_id::text=ch.id::text
      WHERE ch.id::text=v_target_character_id AND ch.campaign_id=v_campaign_id
      FOR UPDATE OF sh;
      IF NOT FOUND THEN RAISE EXCEPTION 'Ficha do alvo player não encontrada: %',v_key; END IF;
      v_hp:=least(v_max_hp,greatest(0,coalesce(v_hp,0)+v_healing));
      UPDATE public.srd_character_sheets SET pv_atual=v_hp
      WHERE character_id::text=v_target_character_id;
    ELSE
      IF coalesce(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$'
         OR coalesce(v_token->>'hp','') !~ '^[0-9]{1,6}$'
      THEN
        RAISE EXCEPTION 'Token não possui HP válido: %',v_key;
      END IF;
      v_max_hp:=(v_token->>'maxHp')::integer;
      v_hp:=least(v_max_hp,greatest(0,(v_token->>'hp')::integer+v_healing));
    END IF;

    v_token:=v_token||jsonb_build_object('hp',v_hp,'maxHp',v_max_hp);
    v_tokens:=jsonb_set(v_tokens,ARRAY[(v_token_index-1)::text],v_token,false);
    v_targets:=v_targets||jsonb_build_array(jsonb_build_object(
      'token_key',v_key,'healing',v_healing,'pv_atual',v_hp
    ));
  END LOOP;

  v_cba_data:=coalesce(v_cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens);
  UPDATE public.campaigns SET cba_data=v_cba_data WHERE id=v_campaign_id;
  RETURN coalesce(v_result,'{}'::jsonb)||jsonb_build_object(
    'targets',v_targets,'target_count',cardinality(p_target_token_keys),
    'multiple_targets',true
  );
END;
$function$
;

-- conjurar_magia_srd_multialvo_v2(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])
CREATE OR REPLACE FUNCTION public.conjurar_magia_srd_multialvo_v2(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_spell record;
  v_campaign_id bigint;
  v_doc jsonb;
  v_state jsonb;
  v_prepared jsonb;
  v_class text;
  v_level integer;
  v_score integer;
  v_idx integer;
  v_capacity integer;
  v_slot_total integer;
  v_slots_remaining integer;
  v_prepared_idx integer;
  v_cba_data jsonb;
  v_tokens jsonb;
  v_token jsonb;
  v_token_count integer;
  v_token_index bigint;
  v_key text;
  v_target_type text;
  v_target_character_id text;
  v_hp integer;
  v_max_hp integer;
  v_healing integer;
  v_roll integer;
  v_die_count integer;
  v_die_size integer;
  v_dice text;
  v_per_level integer;
  v_max_level integer;
  v_is_undead boolean;
  v_targets jsonb := '[]'::jsonb;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória'; END IF;
  IF p_target_token_keys IS NULL OR cardinality(p_target_token_keys) NOT BETWEEN 1 AND 20 THEN
    RAISE EXCEPTION 'Informe entre 1 e 20 tokens-alvo';
  END IF;
  IF EXISTS (
    SELECT 1 FROM (
      SELECT btrim(k) AS key,count(*) AS n
      FROM unnest(p_target_token_keys) k
      GROUP BY btrim(k)
    ) d WHERE d.n>1 OR NULLIF(d.key,'') IS NULL
  ) THEN
    RAISE EXCEPTION 'Tokens-alvo inválidos ou duplicados';
  END IF;

  SELECT ch.campaign_id INTO v_campaign_id
  FROM public.characters ch
  WHERE ch.id::text=btrim(p_character_id) AND ch.user_id=auth.uid()
  FOR UPDATE;
  IF NOT FOUND OR v_campaign_id IS NULL THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem campanha autorizada';
  END IF;

  SELECT s.* INTO v_sheet
  FROM public.srd_character_sheets s
  WHERE s.character_id::text=btrim(p_character_id)
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada'; END IF;

  v_doc:=to_jsonb(v_sheet);
  SELECT public._srd35_class_key(cl.nome) INTO v_class
  FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe SRD incompatível'; END IF;
  v_level:=v_sheet.nivel;
  IF v_level IS NULL OR v_level NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Nível inválido'; END IF;
  v_score:=CASE v_class
    WHEN 'wizard' THEN public._srd35_attr(v_doc,ARRAY['INT','inteligencia','intelligence'])::integer
    WHEN 'sorcerer' THEN public._srd35_attr(v_doc,ARRAY['CAR','carisma','charisma','cha'])::integer
    ELSE public._srd35_attr(v_doc,ARRAY['SAB','sabedoria','wisdom','wis'])::integer
  END;
  IF v_score IS NULL OR v_score<1 THEN RAISE EXCEPTION 'Atributo-chave inválido'; END IF;

  SELECT sp.* INTO v_spell FROM public.srd_spells sp WHERE sp.id=p_spell_id;
  IF NOT FOUND OR coalesce(v_spell.dados_tecnicos->>'tipo_efeito','')<>'cura'
     OR coalesce(v_spell.dados_tecnicos->>'target_mode','')<>'multiple_targets_pending'
  THEN
    RAISE EXCEPTION 'Magia não é uma cura SRD de múltiplos alvos';
  END IF;
  IF p_slot_level IS NULL OR p_slot_level<>v_spell.circulo THEN
    RAISE EXCEPTION 'O espaço deve corresponder ao círculo da magia';
  END IF;
  IF NOT public._srd35_spell_class_ok(v_spell.classes,v_class) THEN
    RAISE EXCEPTION 'Magia não disponível para a classe';
  END IF;
  IF coalesce((SELECT (slots_by_level->(v_level-1)->>v_spell.circulo)::integer
               FROM public.srd_spell_progressions WHERE class_key=v_class),0)<=0
     OR v_score<10+v_spell.circulo
  THEN
    RAISE EXCEPTION 'Nível de magia, espaço ou atributo insuficiente';
  END IF;

  v_state:=coalesce(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
  v_prepared:=coalesce(v_state->'preparadas','[]'::jsonb);
  SELECT (e.ord-1)::integer INTO v_prepared_idx
  FROM jsonb_array_elements(v_prepared) WITH ORDINALITY e(value,ord)
  WHERE e.value->>'spell_id'=p_spell_id
    AND (e.value->>'slot_level')::integer=p_slot_level
    AND coalesce((e.value->>'expended')::boolean,false)=false
  ORDER BY e.ord LIMIT 1;
  IF v_prepared_idx IS NULL THEN RAISE EXCEPTION 'Nenhum espaço preparado disponível'; END IF;
  v_prepared:=jsonb_set(v_prepared,ARRAY[v_prepared_idx::text,'expended'],'true'::jsonb,true);
  SELECT count(*)::integer INTO v_slots_remaining
  FROM jsonb_array_elements(v_prepared) e(value)
  WHERE (e.value->>'slot_level')::integer=p_slot_level
    AND coalesce((e.value->>'expended')::boolean,false)=false;
  v_slot_total:=public._srd35_slots(v_class,v_level,v_score,p_slot_level);

  SELECT c.cba_data INTO v_cba_data FROM public.campaigns c WHERE c.id=v_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada'; END IF;
  v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array' THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;
  v_dice:=coalesce(v_spell.dados_tecnicos->'cura'->>'dados','');
  IF v_dice ~ '^[0-9]+d[0-9]+([+-][0-9]+)?$' THEN
    v_die_count:=split_part(v_dice,'d',1)::integer;
    v_die_size:=regexp_replace(split_part(v_dice,'d',2),'[+-].*$','')::integer;
  ELSIF v_dice ~ '^[0-9]+$' THEN
    v_die_count:=0; v_die_size:=0;
  ELSE RAISE EXCEPTION 'Expressão de cura inválida'; END IF;
  v_per_level:=coalesce((v_spell.dados_tecnicos->'cura'->>'por_nivel')::integer,0);
  v_max_level:=coalesce((v_spell.dados_tecnicos->'cura'->>'max_nivel')::integer,0);

  FOREACH v_key IN ARRAY p_target_token_keys LOOP
    SELECT count(*)::integer,min(e.ordinality),min(e.token->>'tipo'),
           min(e.token->>'id'),bool_or(coalesce(e.token->'monsterStats'->>'tipo','') ILIKE '%undead%')
      INTO v_token_count,v_token_index,v_target_type,v_target_character_id,v_is_undead
    FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
    WHERE e.token->>'key'=btrim(v_key);
    IF v_token_count<>1 THEN RAISE EXCEPTION 'Token-alvo não encontrado ou duplicado: %',v_key; END IF;
    SELECT e.token INTO v_token FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
    WHERE e.token->>'key'=btrim(v_key) LIMIT 1;

    IF v_die_count>0 THEN
      v_roll:=0;
      FOR v_idx IN 1..v_die_count LOOP v_roll:=v_roll+floor(random()*v_die_size)::integer+1; END LOOP;
      IF substring(v_dice from '([+-][0-9]+)$') IS NOT NULL THEN
        v_roll:=v_roll+substring(v_dice from '([+-][0-9]+)$')::integer;
      END IF;
    ELSE v_roll:=v_dice::integer; END IF;
    v_healing:=greatest(0,v_roll+v_per_level*CASE WHEN v_max_level>0 THEN least(v_level,v_max_level) ELSE v_level END);

    IF v_target_type='player' THEN
      IF v_is_undead THEN RAISE EXCEPTION 'Personagem jogador não pode ser classificado como morto-vivo'; END IF;
      SELECT sh.pv_atual,sh.pv_max INTO v_hp,v_max_hp
      FROM public.characters ch JOIN public.srd_character_sheets sh ON sh.character_id::text=ch.id::text
      WHERE ch.id::text=v_target_character_id AND ch.campaign_id=v_campaign_id
      FOR UPDATE OF sh;
      IF NOT FOUND THEN RAISE EXCEPTION 'Ficha do alvo não encontrada: %',v_key; END IF;
      v_hp:=least(v_max_hp,greatest(0,coalesce(v_hp,0)+v_healing));
      UPDATE public.srd_character_sheets SET pv_atual=v_hp WHERE character_id::text=v_target_character_id;
    ELSE
      IF coalesce(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$'
         OR coalesce(v_token->>'hp','') !~ '^[0-9]{1,6}$'
      THEN RAISE EXCEPTION 'Token sem HP válido: %',v_key; END IF;
      v_max_hp:=(v_token->>'maxHp')::integer;
      v_hp:=CASE WHEN v_is_undead
                 THEN greatest(0,(v_token->>'hp')::integer-v_healing)
                 ELSE least(v_max_hp,greatest(0,(v_token->>'hp')::integer+v_healing)) END;
    END IF;
    v_token:=v_token||jsonb_build_object('hp',v_hp,'maxHp',v_max_hp);
    v_tokens:=jsonb_set(v_tokens,ARRAY[(v_token_index-1)::text],v_token,false);
    v_targets:=v_targets||jsonb_build_array(jsonb_build_object(
      'token_key',btrim(v_key),
      'healing',CASE WHEN v_is_undead THEN -v_healing ELSE v_healing END,
      'pv_atual',v_hp,'undead',v_is_undead
    ));
  END LOOP;

  v_cba_data:=coalesce(v_cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens);
  UPDATE public.campaigns SET cba_data=v_cba_data WHERE id=v_campaign_id;
  v_state:=jsonb_build_object('version',1,'conhecidas',coalesce(v_state->'conhecidas','[]'::jsonb),
    'preparadas',v_prepared,'dominio_preparadas',coalesce(v_state->'dominio_preparadas','[]'::jsonb),'usos',coalesce(v_state->'usos','{}'::jsonb));
  UPDATE public.srd_character_sheets SET magias_preparadas=v_state WHERE character_id::text=btrim(p_character_id);
  RETURN jsonb_build_object('estado',v_state,'cba_data',v_cba_data,'targets',v_targets,
    'target_count',cardinality(p_target_token_keys),'multiple_targets',true,
    'slots_total',v_slot_total,'slots_remaining',v_slots_remaining);
END;
$function$
;

-- conjurar_magia_srd_multialvo_v3(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[])
CREATE OR REPLACE FUNCTION public.conjurar_magia_srd_multialvo_v3(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_spell record;
  v_campaign_id bigint;
  v_doc jsonb;
  v_state jsonb;
  v_prepared jsonb;
  v_class text;
  v_level integer;
  v_score integer;
  v_idx integer;
  v_capacity integer;
  v_slot_total integer;
  v_slots_remaining integer;
  v_prepared_idx integer;
  v_cba_data jsonb;
  v_tokens jsonb;
  v_token jsonb;
  v_token_count integer;
  v_token_index bigint;
  v_key text;
  v_target_type text;
  v_target_character_id text;
  v_hp integer;
  v_max_hp integer;
  v_healing integer;
  v_roll integer;
  v_die_count integer;
  v_die_size integer;
  v_dice text;
  v_per_level integer;
  v_max_level integer;
  v_is_undead boolean;
  v_targets jsonb := '[]'::jsonb;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória'; END IF;
  IF p_target_token_keys IS NULL OR cardinality(p_target_token_keys) NOT BETWEEN 1 AND 20 THEN
    RAISE EXCEPTION 'Informe entre 1 e 20 tokens-alvo';
  END IF;
  IF EXISTS (
    SELECT 1 FROM (
      SELECT btrim(k) AS key,count(*) AS n
      FROM unnest(p_target_token_keys) k
      GROUP BY btrim(k)
    ) d WHERE d.n>1 OR NULLIF(d.key,'') IS NULL
  ) THEN
    RAISE EXCEPTION 'Tokens-alvo inválidos ou duplicados';
  END IF;

  SELECT ch.campaign_id INTO v_campaign_id
  FROM public.characters ch
  WHERE ch.id::text=btrim(p_character_id) AND ch.user_id=auth.uid()
  FOR UPDATE;
  IF NOT FOUND OR v_campaign_id IS NULL THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem campanha autorizada';
  END IF;


  IF NOT EXISTS (
    SELECT 1 FROM public.members m
    WHERE m.campaign_id = v_campaign_id
      AND m.user_id = auth.uid()
    UNION ALL
    SELECT 1 FROM public.campaigns c
    WHERE c.id = v_campaign_id
      AND c.owner_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'O personagem não pertence a uma campanha da qual você participa.';
  END IF;

  SELECT s.* INTO v_sheet
  FROM public.srd_character_sheets s
  WHERE s.character_id::text=btrim(p_character_id)
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada'; END IF;

  v_doc:=to_jsonb(v_sheet);
  SELECT public._srd35_class_key(cl.nome) INTO v_class
  FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe SRD incompatível'; END IF;
  v_level:=v_sheet.nivel;
  IF v_level IS NULL OR v_level NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Nível inválido'; END IF;
  v_score:=CASE v_class
    WHEN 'wizard' THEN public._srd35_attr(v_doc,ARRAY['INT','inteligencia','intelligence'])::integer
    WHEN 'sorcerer' THEN public._srd35_attr(v_doc,ARRAY['CAR','carisma','charisma','cha'])::integer
    ELSE public._srd35_attr(v_doc,ARRAY['SAB','sabedoria','wisdom','wis'])::integer
  END;
  IF v_score IS NULL OR v_score<1 THEN RAISE EXCEPTION 'Atributo-chave inválido'; END IF;

  SELECT sp.* INTO v_spell FROM public.srd_spells sp WHERE sp.id=p_spell_id;
  IF NOT FOUND OR coalesce(v_spell.dados_tecnicos->>'tipo_efeito','')<>'cura'
     OR coalesce(v_spell.dados_tecnicos->>'target_mode','')<>'multiple_targets_pending'
  THEN
    RAISE EXCEPTION 'Magia não é uma cura SRD de múltiplos alvos';
  END IF;
  IF p_slot_level IS NULL OR p_slot_level<>v_spell.circulo THEN
    RAISE EXCEPTION 'O espaço deve corresponder ao círculo da magia';
  END IF;
  IF NOT public._srd35_spell_class_ok(v_spell.classes,v_class) THEN
    RAISE EXCEPTION 'Magia não disponível para a classe';
  END IF;
  IF coalesce((SELECT (slots_by_level->(v_level-1)->>v_spell.circulo)::integer
               FROM public.srd_spell_progressions WHERE class_key=v_class),0)<=0
     OR v_score<10+v_spell.circulo
  THEN
    RAISE EXCEPTION 'Nível de magia, espaço ou atributo insuficiente';
  END IF;

  v_state:=coalesce(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
  v_prepared:=coalesce(v_state->'preparadas','[]'::jsonb);
  SELECT (e.ord-1)::integer INTO v_prepared_idx
  FROM jsonb_array_elements(v_prepared) WITH ORDINALITY e(value,ord)
  WHERE e.value->>'spell_id'=p_spell_id
    AND (e.value->>'slot_level')::integer=p_slot_level
    AND coalesce((e.value->>'expended')::boolean,false)=false
  ORDER BY e.ord LIMIT 1;
  IF v_prepared_idx IS NULL THEN RAISE EXCEPTION 'Nenhum espaço preparado disponível'; END IF;
  v_prepared:=jsonb_set(v_prepared,ARRAY[v_prepared_idx::text,'expended'],'true'::jsonb,true);
  SELECT count(*)::integer INTO v_slots_remaining
  FROM jsonb_array_elements(v_prepared) e(value)
  WHERE (e.value->>'slot_level')::integer=p_slot_level
    AND coalesce((e.value->>'expended')::boolean,false)=false;
  v_slot_total:=public._srd35_slots(v_class,v_level,v_score,p_slot_level);

  SELECT c.cba_data INTO v_cba_data FROM public.campaigns c WHERE c.id=v_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada'; END IF;
  v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array' THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;
  v_dice:=coalesce(v_spell.dados_tecnicos->'cura'->>'dados','');
  IF v_dice ~ '^[0-9]+d[0-9]+([+-][0-9]+)?$' THEN
    v_die_count:=split_part(v_dice,'d',1)::integer;
    v_die_size:=regexp_replace(split_part(v_dice,'d',2),'[+-].*$','')::integer;
  ELSIF v_dice ~ '^[0-9]+$' THEN
    v_die_count:=0; v_die_size:=0;
  ELSE RAISE EXCEPTION 'Expressão de cura inválida'; END IF;
  v_per_level:=coalesce((v_spell.dados_tecnicos->'cura'->>'por_nivel')::integer,0);
  v_max_level:=coalesce((v_spell.dados_tecnicos->'cura'->>'max_nivel')::integer,0);

  FOREACH v_key IN ARRAY p_target_token_keys LOOP
    SELECT count(*)::integer,min(e.ordinality),min(e.token->>'tipo'),
           min(e.token->>'id'),bool_or(coalesce(e.token->'monsterStats'->>'tipo','') ILIKE '%undead%')
      INTO v_token_count,v_token_index,v_target_type,v_target_character_id,v_is_undead
    FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
    WHERE e.token->>'key'=btrim(v_key);
    IF v_token_count<>1 THEN RAISE EXCEPTION 'Token-alvo não encontrado ou duplicado: %',v_key; END IF;
    SELECT e.token INTO v_token FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
    WHERE e.token->>'key'=btrim(v_key) LIMIT 1;

    IF v_die_count>0 THEN
      IF p_roll_results IS NULL OR cardinality(p_roll_results)<>v_die_count
         OR EXISTS(SELECT 1 FROM unnest(p_roll_results) value WHERE value<1 OR value>v_die_size) THEN
        RAISE EXCEPTION 'A cura em massa exige exatamente % resultado(s) manual(is) de d%.',v_die_count,v_die_size;
      END IF;
      SELECT coalesce(sum(value),0) INTO v_roll FROM unnest(p_roll_results) value;
      IF substring(v_dice from '([+-][0-9]+)$') IS NOT NULL THEN
        v_roll:=v_roll+substring(v_dice from '([+-][0-9]+)$')::integer;
      END IF;
    ELSE
      IF p_roll_results IS NOT NULL AND cardinality(p_roll_results)>0 THEN RAISE EXCEPTION 'Esta cura não exige dados adicionais.'; END IF;
      v_roll:=v_dice::integer;
    END IF;
    v_healing:=greatest(0,v_roll+v_per_level*CASE WHEN v_max_level>0 THEN least(v_level,v_max_level) ELSE v_level END);

    IF v_target_type='player' THEN
      IF v_is_undead THEN RAISE EXCEPTION 'Personagem jogador não pode ser classificado como morto-vivo'; END IF;
      SELECT sh.pv_atual,sh.pv_max INTO v_hp,v_max_hp
      FROM public.characters ch JOIN public.srd_character_sheets sh ON sh.character_id::text=ch.id::text
      WHERE ch.id::text=v_target_character_id AND ch.campaign_id=v_campaign_id
      FOR UPDATE OF sh;
      IF NOT FOUND THEN RAISE EXCEPTION 'Ficha do alvo não encontrada: %',v_key; END IF;
      IF COALESCE(v_hp,0)<=-10 OR priv.srd_condition_has_flag(v_campaign_id,'character',BTRIM(v_target_character_id),'no_healing') THEN
        RAISE EXCEPTION 'Personagens mortos não podem receber cura comum.';
      END IF;
      v_hp:=LEAST(v_max_hp,COALESCE(v_hp,0)+v_healing);
      UPDATE public.srd_character_sheets SET pv_atual=v_hp WHERE character_id::text=v_target_character_id;
      PERFORM priv.srd_sync_character_vital_condition(BTRIM(v_target_character_id),v_hp,
        v_hp<0 AND EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc
          WHERE cc.campaign_id=v_campaign_id AND cc.target_kind='character'
            AND cc.target_id=BTRIM(v_target_character_id) AND cc.condition_id='stable' AND cc.active=true));
    ELSE
      IF coalesce(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$'
         OR coalesce(v_token->>'hp','') !~ '^-?[0-9]{1,6}$'
      THEN RAISE EXCEPTION 'Token sem HP válido: %',v_key; END IF;
      v_max_hp:=(v_token->>'maxHp')::integer;
      IF NOT v_is_undead AND ((v_token->>'hp')::integer<=-10 OR EXISTS(
        SELECT 1 FROM public.srd_campaign_conditions cc
        WHERE cc.campaign_id=v_campaign_id AND cc.target_kind='token'
          AND cc.target_id IN (v_token->>'id',v_key)
          AND cc.condition_id='dead' AND cc.active=true
      )) THEN RAISE EXCEPTION 'Criaturas mortas não podem receber cura comum.'; END IF;
      v_hp:=CASE
        WHEN v_is_undead THEN CASE WHEN (v_token->>'hp')::integer<=-10 THEN -10 ELSE GREATEST(-10,(v_token->>'hp')::integer-v_healing) END
        ELSE LEAST(v_max_hp,(v_token->>'hp')::integer+v_healing)
      END;
    END IF;
    v_token:=v_token||jsonb_build_object('hp',v_hp,'maxHp',v_max_hp);
    v_tokens:=jsonb_set(v_tokens,ARRAY[(v_token_index-1)::text],v_token,false);
    v_targets:=v_targets||jsonb_build_array(jsonb_build_object(
      'token_key',btrim(v_key),
      'healing',CASE WHEN v_is_undead THEN -v_healing ELSE v_healing END,
      'pv_atual',v_hp,'undead',v_is_undead
    ));
  END LOOP;

  v_cba_data:=coalesce(v_cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens);
  UPDATE public.campaigns SET cba_data=v_cba_data WHERE id=v_campaign_id;
  FOREACH v_key IN ARRAY p_target_token_keys LOOP
    SELECT e.token INTO v_token FROM jsonb_array_elements(v_tokens) e(token) WHERE e.token->>'key'=BTRIM(v_key) LIMIT 1;
    IF v_token->>'tipo'='npc' AND NULLIF(v_token->>'sourceCharacterId','') IS NOT NULL THEN
      PERFORM priv.srd_sync_linked_npc_token_vitals(v_campaign_id,COALESCE(NULLIF(v_token->>'id',''),BTRIM(v_key)),(v_token->>'hp')::integer,(v_token->>'maxHp')::integer,
        (v_token->>'hp')::integer<0 AND EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc WHERE cc.campaign_id=v_campaign_id AND cc.target_kind='token' AND cc.target_id IN (v_token->>'id',BTRIM(v_key)) AND cc.condition_id='stable' AND cc.active=true));
    END IF;
  END LOOP;
  v_state:=jsonb_build_object('version',1,'conhecidas',coalesce(v_state->'conhecidas','[]'::jsonb),
    'preparadas',v_prepared,'dominio_preparadas',coalesce(v_state->'dominio_preparadas','[]'::jsonb),'usos',coalesce(v_state->'usos','{}'::jsonb));
  UPDATE public.srd_character_sheets SET magias_preparadas=v_state WHERE character_id::text=btrim(p_character_id);
  RETURN jsonb_build_object('estado',v_state,'cba_data',v_cba_data,'targets',v_targets,
    'target_count',cardinality(p_target_token_keys),'multiple_targets',true,
    'slots_total',v_slot_total,'slots_remaining',v_slots_remaining);
END;
$function$
;

-- conjurar_missil_magico_srd(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text, p_damage integer)
CREATE OR REPLACE FUNCTION public.conjurar_missil_magico_srd(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text, p_damage integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
DECLARE
  v_character public.characters%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_cast JSONB;
  v_campaign public.campaigns%ROWTYPE;
  v_scene JSONB;
  v_tokens JSONB;
  v_token JSONB;
  v_index BIGINT;
  v_count INTEGER;
  v_type TEXT;
  v_missiles INTEGER;
  v_min INTEGER;
  v_max INTEGER;
  v_hp INTEGER;
  v_max_hp INTEGER;
  v_new_hp INTEGER;
  v_damage_final INTEGER; v_sr INTEGER; v_pending_id UUID; v_target_kind TEXT; v_target_id TEXT;
  v_name TEXT;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_spell_id IS DISTINCT FROM 'srd35_magic_missile' THEN RAISE EXCEPTION 'Esta resolução aceita somente Míssil Mágico.'; END IF;
  IF NULLIF(BTRIM(p_target_token_key),'') IS NULL THEN RAISE EXCEPTION 'Selecione um alvo.'; END IF;
  SELECT ch.* INTO v_character FROM public.characters ch
   WHERE ch.id::TEXT=BTRIM(p_character_id) AND ch.user_id=auth.uid() FOR UPDATE;
  IF NOT FOUND OR v_character.campaign_id IS NULL THEN RAISE EXCEPTION 'Ficha própria em campanha não encontrada.'; END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.members m
    WHERE m.campaign_id = v_character.campaign_id
      AND m.user_id = auth.uid()
    UNION ALL
    SELECT 1 FROM public.campaigns c
    WHERE c.id = v_character.campaign_id
      AND c.owner_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'O personagem não pertence a uma campanha da qual você participa.';
  END IF;

  SELECT sh.* INTO v_sheet FROM public.srd_character_sheets sh
   WHERE sh.character_id::TEXT=BTRIM(p_character_id) FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada.'; END IF;
  IF v_sheet.nivel IS NULL OR v_sheet.nivel<1 OR v_sheet.nivel>20 THEN RAISE EXCEPTION 'Nível de conjurador inválido.'; END IF;
  v_missiles:=LEAST(5,CEIL(v_sheet.nivel/2.0)::INTEGER);
  v_min:=2*v_missiles; v_max:=5*v_missiles;
  IF p_damage IS NULL OR p_damage<v_min OR p_damage>v_max THEN
    RAISE EXCEPTION 'Dano inválido para % míssil(is): esperado de % a %.',v_missiles,v_min,v_max;
  END IF;
  v_cast:=public.conjurar_magia_com_acao_srd(p_character_id,p_spell_id,p_slot_level,p_target_token_key);
  SELECT c.* INTO v_campaign FROM public.campaigns c
   WHERE c.id=v_character.campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  v_scene:=COALESCE(v_campaign.cba_data,'{}'::JSONB);
  v_tokens:=CASE WHEN jsonb_typeof(v_scene->'tokens')='array' THEN v_scene->'tokens' ELSE '[]'::JSONB END;
  SELECT count(*)::INTEGER,min(e.ordinality),min(e.token->>'tipo'),min(e.token->>'nome')
    INTO v_count,v_index,v_type,v_name
    FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
   WHERE e.token->>'key'=BTRIM(p_target_token_key);
  IF v_count<>1 THEN RAISE EXCEPTION 'Token-alvo ausente ou duplicado nesta campanha.'; END IF;

  v_token:=v_tokens->(v_index::INTEGER-1);
  IF v_type='player' THEN
    v_target_kind:='character'; v_target_id:=v_token->>'id';
    v_sr:=priv.srd_spell_resistance_value(v_character.campaign_id,'character',v_target_id);
  ELSIF v_type IN ('npc','monstro') THEN
    v_target_kind:='token'; v_target_id:=COALESCE(v_token->>'key',v_token->>'id',BTRIM(p_target_token_key));
    v_sr:=priv.srd_spell_resistance_value(v_character.campaign_id,'token',v_target_id);
  ELSE
    RAISE EXCEPTION 'Tipo de token incompatível com Míssil Mágico.';
  END IF;


  IF priv.srd_effect_has_flag(v_character.campaign_id,v_target_kind,v_target_id,'negates_magic_missile') THEN
    RETURN COALESCE(v_cast,'{}'::jsonb)||jsonb_build_object(
      'target_name',COALESCE(v_name,'Alvo'),'missiles',v_missiles,
      'spell_negated_by_shield',true,'damage',0
    );
  END IF;

  IF v_sr>0 THEN

    INSERT INTO priv.srd_pending_spell_resolutions(
      campaign_id,caster_character_id,target_kind,target_id,spell_id,save_type,save_dc,
      effect_data,spell_resistance,caster_level,status,effect_kind
    ) VALUES (
      v_character.campaign_id,BTRIM(p_character_id),v_target_kind,v_target_id,p_spell_id,
      NULL,NULL,jsonb_build_object('damage',p_damage,'damage_type','force'),true,v_sheet.nivel,
      'awaiting_spell_resistance','damage'
    ) RETURNING pending_id INTO v_pending_id;

    INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
    VALUES(v_character.campaign_id,'test_request','PUBLIC',
      jsonb_build_object('tipo','Penetração de Resistência à Magia (D20)',
        'alvos',jsonb_build_array(BTRIM(p_character_id)),'npc_alvos','[]'::jsonb,
        'mestre','Sistema','mestre_id',auth.uid(),'request_id',gen_random_uuid()::text,
        'resolution_type','spell_resistance','pending_id',v_pending_id,'spell_id',p_spell_id,
        'spell_resistance',v_sr,'caster_level',v_sheet.nivel));

    RETURN COALESCE(v_cast,'{}'::jsonb)||jsonb_build_object(
      'target_name',COALESCE(v_name,'Alvo'),'missiles',v_missiles,
      'spell_resistance_pending',true,'spell_resistance_pending_id',v_pending_id,
      'spell_resistance',v_sr,'damage_pending',p_damage
    );
  END IF;

  IF v_type='player' THEN
    SELECT sh.pv_atual,sh.pv_max INTO v_hp,v_max_hp
      FROM public.characters ch
      JOIN public.members m ON m.campaign_id=ch.campaign_id AND m.user_id=ch.user_id AND m.role='PLAYER'
      JOIN public.srd_character_sheets sh ON sh.character_id::TEXT=ch.id::TEXT
     WHERE ch.id::TEXT=v_token->>'id' AND ch.campaign_id=v_character.campaign_id
     FOR UPDATE OF sh;
    IF NOT FOUND OR v_max_hp IS NULL OR v_max_hp<1 THEN RAISE EXCEPTION 'Ficha do alvo jogador inválida.'; END IF;
    v_damage_final:=priv.srd_adjust_damage(v_character.campaign_id,'character',v_token->>'id','force',p_damage);
    v_new_hp:=GREATEST(-10,COALESCE(v_hp,v_max_hp)-v_damage_final);
    PERFORM priv.srd_sync_character_vital_condition(v_token->>'id',v_new_hp,false);
    UPDATE public.srd_character_sheets SET pv_atual=v_new_hp WHERE character_id::TEXT=v_token->>'id';
    v_tokens:=jsonb_set(v_tokens,ARRAY[(v_index-1)::TEXT],v_token||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp),FALSE);
  ELSIF v_type IN ('npc','monstro') THEN
    IF COALESCE(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN RAISE EXCEPTION 'O token precisa ter PV máximo cadastrado.'; END IF;
    v_max_hp:=(v_token->>'maxHp')::INTEGER;
    IF v_max_hp>100000 THEN RAISE EXCEPTION 'PV máximo do token excede o limite.'; END IF;
    v_hp:=CASE WHEN COALESCE(v_token->>'hp','') ~ '^-?[0-9]{1,6}$' THEN (v_token->>'hp')::INTEGER ELSE v_max_hp END;
    v_damage_final:=priv.srd_adjust_damage(v_character.campaign_id,'token',BTRIM(p_target_token_key),'force',p_damage);
    v_new_hp:=GREATEST(-10,v_hp-v_damage_final);
    v_tokens:=jsonb_set(v_tokens,ARRAY[(v_index-1)::TEXT],v_token||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp),FALSE);
  ELSE
    RAISE EXCEPTION 'Tipo de token incompatível com Míssil Mágico.';
  END IF;
  v_scene:=v_scene||jsonb_build_object('tokens',v_tokens);
  UPDATE public.campaigns SET cba_data=v_scene WHERE id=v_character.campaign_id;
  PERFORM priv.srd_sync_linked_npc_token_vitals(v_character.campaign_id,p_target_token_key,v_new_hp,v_max_hp);
  RETURN COALESCE(v_cast,'{}'::JSONB)||jsonb_build_object(
    'cba_data',v_scene,'target_name',COALESCE(v_name,'Alvo'),'damage',p_damage,
    'pv_atual',v_new_hp,'pv_max',v_max_hp,'missiles',v_missiles,'spell_resistance_pending',false
  );
END;
$function$
;

-- conjurar_missil_magico_srd_manual(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text, p_damage_rolls integer[])
CREATE OR REPLACE FUNCTION public.conjurar_missil_magico_srd_manual(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text, p_damage_rolls integer[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_character public.characters%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_missiles INTEGER;
  v_damage INTEGER;
  v_result JSONB;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_spell_id IS DISTINCT FROM 'srd35_magic_missile' THEN RAISE EXCEPTION 'Esta resolução aceita somente Míssil Mágico.'; END IF;
  IF NULLIF(BTRIM(p_target_token_key),'') IS NULL THEN RAISE EXCEPTION 'Selecione um alvo.'; END IF;

  SELECT ch.* INTO v_character
  FROM public.characters ch
  WHERE ch.id::TEXT=BTRIM(p_character_id) AND ch.user_id=auth.uid()
  FOR UPDATE;
  IF NOT FOUND OR v_character.campaign_id IS NULL THEN RAISE EXCEPTION 'Ficha própria em campanha não encontrada.'; END IF;

  SELECT sh.* INTO v_sheet
  FROM public.srd_character_sheets sh
  WHERE sh.character_id::TEXT=BTRIM(p_character_id)
  FOR UPDATE;
  IF NOT FOUND OR v_sheet.nivel IS NULL OR v_sheet.nivel<1 OR v_sheet.nivel>20 THEN
    RAISE EXCEPTION 'Ficha ou nível de conjurador inválido.';
  END IF;

  v_missiles:=LEAST(5,CEIL(v_sheet.nivel/2.0)::INTEGER);
  IF p_damage_rolls IS NULL OR cardinality(p_damage_rolls)<>v_missiles THEN
    RAISE EXCEPTION 'Míssil Mágico exige um resultado individual de D4 para cada míssil (%).',v_missiles;
  END IF;
  IF EXISTS(SELECT 1 FROM unnest(p_damage_rolls) r(value) WHERE r.value IS NULL OR r.value NOT BETWEEN 1 AND 4) THEN
    RAISE EXCEPTION 'Cada míssil causa 1d4+1; os resultados precisam estar entre 1 e 4.';
  END IF;
  SELECT COALESCE(sum(r.value),0)::INTEGER+v_missiles INTO v_damage
  FROM unnest(p_damage_rolls) r(value);

  v_result:=public.conjurar_missil_magico_srd(
    p_character_id,p_spell_id,p_slot_level,p_target_token_key,v_damage
  );
  RETURN COALESCE(v_result,'{}'::JSONB)||jsonb_build_object(
    'damage_rolls',to_jsonb(p_damage_rolls),
    'damage_formula',v_missiles||'d4+'||v_missiles
  );
END;
$function$
;

-- consultar_ataque_iterativo_npc_pendente_srd(p_campaign_id bigint, p_actor_token_id text)
CREATE OR REPLACE FUNCTION public.consultar_ataque_iterativo_npc_pendente_srd(p_campaign_id bigint, p_actor_token_id text)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO ''
AS $function$ select priv.npc_consultar_ataque_iterativo_pendente_impl($1,$2); $function$
;

-- consultar_ataque_iterativo_npc_srd(p_campaign_id bigint, p_token_id text, p_attack_type text)
CREATE OR REPLACE FUNCTION public.consultar_ataque_iterativo_npc_srd(p_campaign_id bigint, p_token_id text, p_attack_type text)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO ''
AS $function$ select priv.npc_consultar_ataque_iterativo_impl($1,$2,$3); $function$
;

-- consultar_furia_barbaro_npc_srd(p_campaign_id bigint, p_token_id text)
CREATE OR REPLACE FUNCTION public.consultar_furia_barbaro_npc_srd(p_campaign_id bigint, p_token_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
 v_campaign public.campaigns%ROWTYPE; v_token jsonb; v_token_count integer;
 v_character_id text; v_character public.characters%ROWTYPE; v_sheet public.srd_character_sheets%ROWTYPE;
 v_level integer:=0; v_uses_day integer:=0; v_uses_spent integer:=0; v_active boolean:=false;
 v_expiry integer; v_round integer:=1; v_order jsonb:='[]'::jsonb; v_turn integer:=-1;
 v_actor jsonb; v_can_start boolean:=false; v_can_end boolean:=false;
 v_fatigued boolean:=false; v_no_actions boolean:=false;
BEGIN
 IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
   RAISE EXCEPTION 'Somente o Mestre autenticado pode controlar habilidades de NPC.';
 END IF;
 SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id;
 IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
 SELECT count(*)::integer,(jsonb_agg(t.token)->0) INTO v_token_count,v_token
 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array'
   THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END) t(token)
 WHERE t.token->>'id'=BTRIM(p_token_id) AND t.token->>'tipo'='npc';
 IF v_token_count<>1 THEN RAISE EXCEPTION 'Token NPC não encontrado ou duplicado.'; END IF;
 v_character_id:=NULLIF(v_token->>'sourceCharacterId','');
 IF v_character_id IS NULL THEN RAISE EXCEPTION 'Este NPC não está vinculado a uma ficha de origem.'; END IF;
 SELECT * INTO v_character FROM public.characters WHERE id::text=v_character_id;
 IF NOT FOUND THEN RAISE EXCEPTION 'Ficha de origem não encontrada.'; END IF;
 SELECT * INTO v_sheet FROM public.srd_character_sheets WHERE character_id=v_character.id;
 IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD de origem não encontrada.'; END IF;
 SELECT COALESCE(MAX(cl.class_level) FILTER (WHERE cls.class_key='barbarian'),
   CASE WHEN NOT EXISTS(SELECT 1 FROM public.srd_character_class_levels lv WHERE lv.character_id=v_sheet.character_id)
     AND v_sheet.classe_id='barbaro' THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END)
 INTO v_level FROM public.srd_character_sheets sh
 LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
 LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
 WHERE sh.character_id=v_sheet.character_id GROUP BY sh.character_id,sh.classe_id,sh.nivel;
 v_level:=COALESCE(v_level,0);
 IF v_level<1 THEN RETURN jsonb_build_object('eligible',false,'barbarian_level',0,'active',false); END IF;
 v_uses_day:=1+FLOOR(v_level/4.0)::integer;
 SELECT COALESCE(uses_spent,0) INTO v_uses_spent FROM public.srd_character_feature_resources
 WHERE character_id=v_character.id AND feature_key='barbarian_rage';
 v_round:=CASE WHEN COALESCE(v_campaign.combat_data->>'round','') ~ '^[0-9]+$'
   THEN GREATEST(1,(v_campaign.combat_data->>'round')::integer) ELSE 1 END;
 v_order:=CASE WHEN jsonb_typeof(v_campaign.combat_data->'turn_order')='array'
   THEN v_campaign.combat_data->'turn_order' ELSE '[]'::jsonb END;
 IF COALESCE(v_campaign.combat_data->>'current_turn','') ~ '^[0-9]+$' THEN
   v_turn:=(v_campaign.combat_data->>'current_turn')::integer;
 END IF;
 IF v_turn>=0 AND v_turn<jsonb_array_length(v_order) THEN v_actor:=v_order->v_turn; END IF;
 SELECT EXISTS(SELECT 1 FROM public.srd_campaign_effects WHERE campaign_id=p_campaign_id
   AND target_kind='token' AND target_id=BTRIM(p_token_id) AND active
   AND effect_data->>'source_feature'='barbarian_rage'),
   (SELECT expires_round FROM public.srd_campaign_effects WHERE campaign_id=p_campaign_id
     AND target_kind='token' AND target_id=BTRIM(p_token_id) AND active
     AND effect_data->>'source_feature'='barbarian_rage' ORDER BY effect_instance_id DESC LIMIT 1)
 INTO v_active,v_expiry;
 v_fatigued:=EXISTS(SELECT 1 FROM public.srd_campaign_conditions WHERE campaign_id=p_campaign_id
   AND target_kind='token' AND target_id=BTRIM(p_token_id) AND active
   AND condition_id IN ('fatigued','exhausted'));
 v_no_actions:=priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'no_actions');
 v_can_start:=UPPER(COALESCE(v_campaign.state,''))='COMBATE'
   AND COALESCE(v_campaign.combat_data->>'active','false')='true'
   AND v_actor->>'id'=BTRIM(p_token_id) AND COALESCE(v_actor->>'is_monster','false')='true'
   AND NOT v_active AND NOT v_fatigued AND NOT v_no_actions
   AND COALESCE(v_uses_spent,0)<v_uses_day;
 v_can_end:=v_active AND (UPPER(COALESCE(v_campaign.state,''))<>'COMBATE'
   OR (COALESCE(v_campaign.combat_data->>'active','false')='true'
     AND v_actor->>'id'=BTRIM(p_token_id) AND COALESCE(v_actor->>'is_monster','false')='true'));
 RETURN jsonb_build_object('eligible',true,'barbarian_level',v_level,'uses_per_day',v_uses_day,
   'uses_spent',COALESCE(v_uses_spent,0),'uses_remaining',GREATEST(0,v_uses_day-COALESCE(v_uses_spent,0)),
   'active',v_active,'expires_round',v_expiry,
   'rounds_remaining',CASE WHEN v_active AND v_expiry IS NOT NULL THEN GREATEST(0,v_expiry-v_round) ELSE 0 END,
   'can_start',v_can_start,'can_end',v_can_end);
END;
$function$
;

-- consultar_furia_barbaro_srd(p_character_id text)
CREATE OR REPLACE FUNCTION public.consultar_furia_barbaro_srd(p_character_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_character public.characters%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_campaign public.campaigns%ROWTYPE;
  v_barbarian_level integer:=0;
  v_uses_per_day integer:=0;
  v_uses_spent integer:=0;
  v_active boolean:=false;
  v_expires_round integer;
  v_round integer:=0;
  v_current integer:=-1;
  v_order jsonb:='[]'::jsonb;
  v_actor jsonb;
  v_can_start boolean:=false;
  v_can_end boolean:=false;
  v_fatigued boolean:=false;
  v_no_actions boolean:=false;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  SELECT * INTO v_character FROM public.characters
   WHERE id::text=BTRIM(p_character_id)
     AND (user_id=auth.uid() OR (campaign_id IS NOT NULL AND public.my_role(campaign_id)='GM'));
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou sem acesso à campanha.'; END IF;
  SELECT * INTO v_sheet FROM public.srd_character_sheets
   WHERE character_id=v_character.id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD do personagem não encontrada.'; END IF;

  SELECT COALESCE(
    MAX(cl.class_level) FILTER (WHERE cls.class_key='barbarian'),
    CASE WHEN NOT EXISTS (
      SELECT 1 FROM public.srd_character_class_levels any_level
       WHERE any_level.character_id=v_sheet.character_id
    ) AND v_sheet.classe_id='barbaro'
    THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
  )
    INTO v_barbarian_level
    FROM public.srd_character_sheets sh
    LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
    LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
   WHERE sh.character_id=v_sheet.character_id
   GROUP BY sh.character_id,sh.classe_id,sh.nivel;

  v_barbarian_level:=COALESCE(v_barbarian_level,0);
  IF v_barbarian_level<1 THEN
    RETURN jsonb_build_object('eligible',false,'barbarian_level',0,'active',false);
  END IF;

  v_uses_per_day:=1+FLOOR(v_barbarian_level/4.0)::integer;
  SELECT COALESCE(uses_spent,0) INTO v_uses_spent
    FROM public.srd_character_feature_resources
   WHERE character_id=v_character.id AND feature_key='barbarian_rage';

  IF v_character.campaign_id IS NOT NULL THEN
    SELECT * INTO v_campaign FROM public.campaigns WHERE id=v_character.campaign_id;
    IF FOUND THEN
      v_round:=CASE WHEN COALESCE(v_campaign.combat_data->>'round','') ~ '^[0-9]+$'
                    THEN GREATEST(1,(v_campaign.combat_data->>'round')::integer) ELSE 1 END;
      v_order:=CASE WHEN jsonb_typeof(v_campaign.combat_data->'turn_order')='array'
                    THEN v_campaign.combat_data->'turn_order' ELSE '[]'::jsonb END;
      IF COALESCE(v_campaign.combat_data->>'current_turn','') ~ '^[0-9]+$' THEN
        v_current:=(v_campaign.combat_data->>'current_turn')::integer;
      END IF;
      IF v_current>=0 AND v_current<jsonb_array_length(v_order) THEN
        v_actor:=v_order->v_current;
      END IF;
      v_can_start:=UPPER(COALESCE(v_campaign.state,''))='COMBATE'
        AND COALESCE(v_campaign.combat_data->>'active','false')='true'
        AND v_actor->>'id'=v_character.id::text
        AND COALESCE(v_actor->>'is_monster','false')<>'true';
      v_can_end:=v_can_start OR UPPER(COALESCE(v_campaign.state,''))<>'COMBATE';
    END IF;
    SELECT EXISTS (
      SELECT 1 FROM public.srd_campaign_effects
       WHERE campaign_id=v_character.campaign_id AND target_kind='character'
         AND target_id=v_character.id::text AND active=true
         AND effect_data->>'source_feature'='barbarian_rage'
    ), (
      SELECT NULLIF(expires_round,0) FROM public.srd_campaign_effects
       WHERE campaign_id=v_character.campaign_id AND target_kind='character'
         AND target_id=v_character.id::text AND active=true
         AND effect_data->>'source_feature'='barbarian_rage'
       ORDER BY effect_instance_id DESC LIMIT 1
    ) INTO v_active,v_expires_round;
    v_fatigued:=EXISTS (
      SELECT 1 FROM public.srd_campaign_conditions
       WHERE campaign_id=v_character.campaign_id AND target_kind='character'
         AND target_id=v_character.id::text AND active=true
         AND condition_id IN ('fatigued','exhausted')
    );
    v_no_actions:=priv.srd_condition_has_flag(v_character.campaign_id,'character',v_character.id::text,'no_actions');
  END IF;

  v_can_start:=v_can_start AND NOT v_active AND NOT v_fatigued AND NOT v_no_actions
    AND COALESCE(v_uses_spent,0)<v_uses_per_day;
  v_can_end:=v_can_end AND v_active;

  RETURN jsonb_build_object(
    'eligible',true,
    'barbarian_level',v_barbarian_level,
    'uses_per_day',v_uses_per_day,
    'uses_spent',COALESCE(v_uses_spent,0),
    'uses_remaining',GREATEST(0,v_uses_per_day-COALESCE(v_uses_spent,0)),
    'active',v_active,
    'expires_round',v_expires_round,
    'rounds_remaining',CASE WHEN v_active AND v_expires_round IS NOT NULL THEN GREATEST(0,v_expires_round-v_round) ELSE 0 END,
    'can_start',v_can_start,
    'can_end',v_can_end,
    'tier',CASE WHEN v_barbarian_level>=20 THEN 'mighty' WHEN v_barbarian_level>=11 THEN 'greater' ELSE 'normal' END
  );
END;
$function$
;

-- consultar_inventario_npc_vinculado_srd(p_campaign_id bigint, p_token_id text)
CREATE OR REPLACE FUNCTION public.consultar_inventario_npc_vinculado_srd(p_campaign_id bigint, p_token_id text)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
  select private.consultar_inventario_npc_vinculado_impl(p_campaign_id,p_token_id);
$function$
;

-- consultar_sequencia_ataque_iterativo_pendente_srd(p_campaign_id bigint, p_character_id text)
CREATE OR REPLACE FUNCTION public.consultar_sequencia_ataque_iterativo_pendente_srd(p_campaign_id bigint, p_character_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare
  v_user uuid := auth.uid();
  v_sequence public.srd_attack_sequences%rowtype;
  v_attempts jsonb;
begin
  if v_user is null then
    raise exception 'É necessário estar autenticado.';
  end if;
  if p_campaign_id is null or coalesce(p_character_id,'') !~ '^[0-9]+$' then
    raise exception 'Campanha ou personagem inválido.';
  end if;

  if not exists (
    select 1
    from public.members m
    join public.characters ch
      on ch.campaign_id = m.campaign_id
     and ch.user_id = m.user_id
    where m.campaign_id = p_campaign_id
      and m.user_id = v_user
      and m.role = 'PLAYER'
      and ch.id::text = p_character_id
  ) then
    raise exception 'O personagem não pertence ao jogador autenticado nesta campanha.';
  end if;

  select s.* into v_sequence
  from public.srd_attack_sequences s
  where s.campaign_id = p_campaign_id
    and s.actor_character_id::text = p_character_id
    and s.created_by = v_user
    and s.status = 'active'
  order by s.created_at desc
  limit 1
  for update;

  if not found then
    return jsonb_build_object('active', false);
  end if;

  select coalesce(jsonb_agg(
    jsonb_build_object(
      'attempt_id', a.id,
      'attempt_index', a.attempt_index,
      'manual_d20', a.manual_d20,
      'iterative_penalty', a.iterative_penalty,
      'status', a.status,
      'resolution_data', a.resolution_data,
      'critical_confirmation_d20', a.critical_confirmation_d20,
      'is_critical', a.is_critical,
      'damage_rolls', a.damage_rolls,
      'damage_applied', a.damage_applied
    ) order by a.attempt_index
  ), '[]'::jsonb)
  into v_attempts
  from public.srd_attack_sequence_attempts a
  where a.sequence_id = v_sequence.id;

  return jsonb_build_object(
    'active', true,
    'sequence_id', v_sequence.id,
    'campaign_id', v_sequence.campaign_id,
    'character_id', v_sequence.actor_character_id,
    'target_token_id', v_sequence.target_token_id,
    'attack_type', v_sequence.attack_type,
    'weapon_instance_id', v_sequence.weapon_instance_id,
    'weapon_hand_slot', v_sequence.weapon_hand_slot,
    'weapon_end', v_sequence.weapon_end,
    'power_attack_penalty', v_sequence.power_attack_penalty,
    'round_number', v_sequence.round_number,
    'turn_index', v_sequence.turn_index,
    'base_attack_bonus', v_sequence.base_attack_bonus,
    'attacks_total', v_sequence.attacks_total,
    'next_attack_index', v_sequence.next_attack_index,
    'status', v_sequence.status,
    'attempts', v_attempts
  );
end;
$function$
;

-- consumir_acao_rodada_completa_srd(p_campaign_id bigint, p_actor_id text, p_actor_kind text)
CREATE OR REPLACE FUNCTION public.consumir_acao_rodada_completa_srd(p_campaign_id bigint, p_actor_id text, p_actor_kind text DEFAULT 'character'::text)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$ select priv.consumir_acao_rodada_completa_srd_impl(p_campaign_id,p_actor_id,p_actor_kind); $function$
;

-- consumir_acao_token_gm_srd(p_campaign_id bigint, p_token_id text, p_acao text)
CREATE OR REPLACE FUNCTION public.consumir_acao_token_gm_srd(p_campaign_id bigint, p_token_id text, p_acao text)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$ select priv.consumir_acao_token_gm_srd_impl(p_campaign_id,p_token_id,p_acao); $function$
;

-- consumir_acao_turno_srd(p_campaign_id bigint, p_character_id text, p_acao text)
CREATE OR REPLACE FUNCTION public.consumir_acao_turno_srd(p_campaign_id bigint, p_character_id text, p_acao text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_campaign public.campaigns%ROWTYPE;
  v_combat JSONB;
  v_order JSONB;
  v_actor JSONB;
  v_current_turn INTEGER;
  v_round INTEGER;
  v_action_state JSONB;
  v_by_character JSONB;
  v_character_actions JSONB;
  v_action TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF NULLIF(BTRIM(p_character_id), '') IS NULL THEN
    RAISE EXCEPTION 'O identificador do personagem é obrigatório.';
  END IF;
  v_action := LOWER(BTRIM(COALESCE(p_acao, '')));
  IF v_action NOT IN ('padrao', 'movimento', 'rapida') THEN
    RAISE EXCEPTION 'Ação inválida. Use padrao, movimento ou rapida.';
  END IF;

  SELECT c.* INTO v_campaign
    FROM public.campaigns AS c
   WHERE c.id = p_campaign_id
   FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  IF UPPER(COALESCE(v_campaign.state, '')) <> 'COMBATE' THEN
    RAISE EXCEPTION 'A economia de ações só está ativa durante o combate.';
  END IF;

  IF NOT EXISTS (
    SELECT 1
      FROM public.characters AS ch
      JOIN public.members AS m
        ON m.campaign_id = ch.campaign_id
       AND m.user_id = ch.user_id
       AND m.role = 'PLAYER'
     WHERE ch.id::TEXT = BTRIM(p_character_id)
       AND ch.campaign_id = p_campaign_id
       AND ch.user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'A ficha não pertence a este jogador nesta campanha.';
  END IF;

  IF priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_character_id),'no_actions') THEN RAISE EXCEPTION 'A condição atual impede qualquer ação.'; END IF;
  IF v_action<>'movimento' AND priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_character_id),'only_move_action') THEN RAISE EXCEPTION 'A condição atual permite somente uma ação de movimento.'; END IF;
  v_combat := COALESCE(v_campaign.combat_data, '{}'::JSONB);
  IF LOWER(COALESCE(v_combat->>'active', 'false')) <> 'true' THEN
    RAISE EXCEPTION 'Não há iniciativa ativa; o Mestre deve iniciar a ordem de combate.';
  END IF;
  v_order := CASE
    WHEN jsonb_typeof(v_combat->'turn_order') = 'array' THEN v_combat->'turn_order'
    ELSE '[]'::JSONB
  END;
  IF jsonb_array_length(v_order) = 0 THEN
    RAISE EXCEPTION 'A ordem de iniciativa está vazia.';
  END IF;
  IF COALESCE(v_combat->>'current_turn', '') !~ '^[0-9]+$' THEN
    RAISE EXCEPTION 'O índice do turno atual é inválido.';
  END IF;
  v_current_turn := (v_combat->>'current_turn')::INTEGER;
  IF v_current_turn < 0 OR v_current_turn >= jsonb_array_length(v_order) THEN
    RAISE EXCEPTION 'O índice do turno atual está fora da ordem de iniciativa.';
  END IF;
  v_actor := v_order->v_current_turn;
  PERFORM priv.srd_validate_surprise_action(p_campaign_id,BTRIM(p_character_id),v_action);
  IF COALESCE(LOWER(v_actor->>'is_monster'), 'false') = 'true'
     OR v_actor->>'id' IS DISTINCT FROM BTRIM(p_character_id) THEN
    RAISE EXCEPTION 'Apenas o personagem cujo turno está ativo pode gastar esta ação.';
  END IF;

  v_round := CASE
    WHEN COALESCE(v_combat->>'round', '') ~ '^[0-9]+$'
      THEN GREATEST(1, (v_combat->>'round')::INTEGER)
    ELSE 1
  END;
  v_action_state := v_combat->'action_economy';
  IF jsonb_typeof(v_action_state) = 'object'
     AND COALESCE(v_action_state->>'round', '') = v_round::TEXT
     AND jsonb_typeof(v_action_state->'by_character') = 'object' THEN
    v_by_character := v_action_state->'by_character';
  ELSE
    -- A mudança de rodada reinicia o registro sem depender de renderizações no navegador.
    v_by_character := '{}'::JSONB;
  END IF;

  v_character_actions := CASE
    WHEN jsonb_typeof(v_by_character->BTRIM(p_character_id)) = 'object'
      THEN v_by_character->BTRIM(p_character_id)
    ELSE '{}'::JSONB
  END;
  IF priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_character_id),'one_move_or_standard')
     AND (LOWER(COALESCE(v_character_actions->>'padrao','false'))='true' OR LOWER(COALESCE(v_character_actions->>'movimento','false'))='true') THEN
    RAISE EXCEPTION 'A condição permite apenas uma ação padrão ou de movimento por rodada.';
  END IF;
  IF LOWER(COALESCE(v_character_actions->>v_action, 'false')) = 'true' THEN
    RAISE EXCEPTION 'A ação % deste personagem já foi usada nesta rodada.', v_action;
  END IF;

  v_character_actions := v_character_actions || jsonb_build_object(v_action, TRUE);
  v_by_character := jsonb_set(
    v_by_character,
    ARRAY[BTRIM(p_character_id)],
    v_character_actions,
    TRUE
  );
  v_action_state := jsonb_build_object(
    'round', v_round,
    'by_character', v_by_character
  );
  v_combat := v_combat || jsonb_build_object('action_economy', v_action_state);

  IF v_action='padrao' AND priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_character_id),'strenuous_action_cost_1hp') THEN
    UPDATE public.srd_character_sheets SET pv_atual=-1 WHERE character_id::text=BTRIM(p_character_id) AND COALESCE(pv_atual,0)=0;
    IF FOUND THEN PERFORM priv.srd_sync_character_vital_condition(BTRIM(p_character_id),-1,false); END IF;
  END IF;
  UPDATE public.campaigns
     SET combat_data = v_combat
   WHERE id = p_campaign_id;

  RETURN jsonb_build_object(
    'combat_data', v_combat,
    'action_economy', v_action_state,
    'round', v_round,
    'character_id', BTRIM(p_character_id),
    'action', v_action
  );
END;
$function$
;

-- create_campaign(p_name text, p_code text, p_location bigint)
CREATE OR REPLACE FUNCTION public.create_campaign(p_name text, p_code text, p_location bigint DEFAULT NULL::bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_uid UUID := auth.uid();
  v_lock_key TEXT := 'create:' || COALESCE(auth.uid()::TEXT, '');
  v_campaign_id BIGINT;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Não autenticado.'; END IF;
  IF p_name IS NULL OR CHAR_LENGTH(BTRIM(p_name)) NOT BETWEEN 2 AND 60 THEN
    RAISE EXCEPTION 'Nome da mesa inválido.';
  END IF;
  IF p_code IS NULL OR p_code !~ '^[0-9]{4}$' THEN
    RAISE EXCEPTION 'O código deve ter 4 dígitos (0000–9999).';
  END IF;
  IF p_location IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM public.locations WHERE id = p_location AND tipo = 'cidade'
  ) THEN RAISE EXCEPTION 'Cidade inicial inválida.'; END IF;
  IF priv.locked(v_lock_key) THEN
    RETURN JSONB_BUILD_OBJECT('ok', FALSE, 'erro', 'Muitas tentativas. Aguarde.');
  END IF;

  BEGIN
    INSERT INTO public.campaigns (name, owner_id, location_id)
    VALUES (BTRIM(p_name), v_uid, p_location)
    RETURNING id INTO v_campaign_id;
    INSERT INTO public.campaign_codes (campaign_id, code) VALUES (v_campaign_id, p_code);
  EXCEPTION WHEN unique_violation THEN
    PERFORM priv.fail(v_lock_key);
    RETURN JSONB_BUILD_OBJECT('ok', FALSE, 'erro', 'Código indisponível.');
  END;

  INSERT INTO public.scenes (campaign_id) VALUES (v_campaign_id)
  ON CONFLICT (campaign_id) DO NOTHING;
  PERFORM priv.log(v_campaign_id, 'MESA_CRIADA', JSONB_BUILD_OBJECT('por', v_uid));
  PERFORM priv.clear(v_lock_key);
  RETURN JSONB_BUILD_OBJECT('ok', TRUE, 'id', v_campaign_id, 'code', p_code);
END
$function$
;

-- create_character(cid bigint, p_nome text)
CREATE OR REPLACE FUNCTION public.create_character(cid bigint, p_nome text)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare cid_new bigint;
begin
  if public.my_role(cid) is distinct from 'PLAYER' then raise exception 'Apenas jogadores criam personagem.'; end if;
  if p_nome is null or char_length(trim(p_nome)) not between 2 and 40 then raise exception 'Nome inválido.'; end if;
  begin insert into characters(campaign_id, user_id, nome) values (cid, auth.uid(), trim(p_nome)) returning id into cid_new;
  exception when unique_violation then raise exception 'Você já tem personagem nesta mesa.'; end;
  perform priv.log(cid, 'PERSONAGEM_CRIADO', jsonb_build_object('user', auth.uid()));
  return cid_new;
end $function$
;

-- criar_personagem_srd(p_nome text, p_raca_id text, p_classe_id text, p_atributos jsonb)
CREATE OR REPLACE FUNCTION public.criar_personagem_srd(p_nome text, p_raca_id text, p_classe_id text, p_atributos jsonb)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_character_id public.characters.id%TYPE;
  v_race public.srd_races%ROWTYPE;
  v_class public.srd_classes%ROWTYPE;
  v_adjustments JSONB;
  v_attributes JSONB;
  v_key TEXT;
  v_raw_score TEXT;
  v_score INTEGER;
  v_score_cost INTEGER;
  v_total_cost INTEGER := 0;
  v_con_mod INTEGER;
  v_pv INTEGER;
  v_nome TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  v_nome := NULLIF(BTRIM(p_nome), '');
  IF v_nome IS NULL THEN
    RAISE EXCEPTION 'Informe o nome do personagem.';
  END IF;
  IF CHAR_LENGTH(v_nome) > 60 THEN
    RAISE EXCEPTION 'O nome do personagem deve ter no máximo 60 caracteres.';
  END IF;

  SELECT * INTO v_race
  FROM public.srd_races
  WHERE id = NULLIF(BTRIM(p_raca_id), '');
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Raça SRD não encontrada.';
  END IF;

  SELECT * INTO v_class
  FROM public.srd_classes
  WHERE id = NULLIF(BTRIM(p_classe_id), '');
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Classe SRD não encontrada.';
  END IF;
  IF v_class.dado_vida IS NULL OR v_class.dado_vida < 1 THEN
    RAISE EXCEPTION 'A classe selecionada não possui um dado de vida válido.';
  END IF;

  IF p_atributos IS NULL OR jsonb_typeof(p_atributos) <> 'object' THEN
    RAISE EXCEPTION 'Distribuição de atributos inválida.';
  END IF;

  FOREACH v_key IN ARRAY ARRAY['FOR','DES','CON','INT','SAB','CAR'] LOOP
    v_raw_score := p_atributos->>v_key;
    IF v_raw_score IS NULL OR v_raw_score !~ '^(8|9|10|11|12|13|14|15|16|17|18)$' THEN
      RAISE EXCEPTION 'Cada atributo-base deve ser um inteiro entre 8 e 18.';
    END IF;
    v_score := v_raw_score::INTEGER;
    v_score_cost := CASE v_score
      WHEN 8 THEN 0 WHEN 9 THEN 1 WHEN 10 THEN 2 WHEN 11 THEN 3
      WHEN 12 THEN 4 WHEN 13 THEN 5 WHEN 14 THEN 6 WHEN 15 THEN 8
      WHEN 16 THEN 10 WHEN 17 THEN 13 WHEN 18 THEN 16
    END;
    v_total_cost := v_total_cost + v_score_cost;
  END LOOP;
  IF v_total_cost > 25 THEN
    RAISE EXCEPTION 'A distribuição usa % pontos; o limite é 25.', v_total_cost;
  END IF;

  v_adjustments := COALESCE(v_race.ajustes_atributos, '{}'::JSONB);
  v_attributes := jsonb_build_object(
    'FOR', (p_atributos->>'FOR')::INTEGER + COALESCE(NULLIF(v_adjustments->>'FOR', '')::INTEGER, 0),
    'DES', (p_atributos->>'DES')::INTEGER + COALESCE(NULLIF(v_adjustments->>'DES', '')::INTEGER, 0),
    'CON', (p_atributos->>'CON')::INTEGER + COALESCE(NULLIF(v_adjustments->>'CON', '')::INTEGER, 0),
    'INT', (p_atributos->>'INT')::INTEGER + COALESCE(NULLIF(v_adjustments->>'INT', '')::INTEGER, 0),
    'SAB', (p_atributos->>'SAB')::INTEGER + COALESCE(NULLIF(v_adjustments->>'SAB', '')::INTEGER, 0),
    'CAR', (p_atributos->>'CAR')::INTEGER + COALESCE(NULLIF(v_adjustments->>'CAR', '')::INTEGER, 0)
  );

  v_con_mod := FLOOR((((v_attributes->>'CON')::NUMERIC - 10) / 2))::INTEGER;
  v_pv := GREATEST(1, v_class.dado_vida + v_con_mod);

  INSERT INTO public.characters (
    user_id, nome, cultura, xp, ouro, retrato_url, campaign_id
  ) VALUES (
    auth.uid(), v_nome, 'Central', 0, 0, NULL, NULL
  )
  RETURNING id INTO v_character_id;

  INSERT INTO public.srd_character_sheets (
    character_id, classe_id, raca_id, nivel, atributos, pv_atual, pv_max, xp, ouro
  ) VALUES (
    v_character_id, v_class.id, v_race.id, 1, v_attributes, v_pv, v_pv, 0, 0
  );

  RETURN v_character_id::TEXT;
END;
$function$
;

-- criar_personagem_srd_completo(p_nome text, p_raca_id text, p_classe_id text, p_atributos jsonb, p_pericias jsonb, p_talentos jsonb)
CREATE OR REPLACE FUNCTION public.criar_personagem_srd_completo(p_nome text, p_raca_id text, p_classe_id text, p_atributos jsonb, p_pericias jsonb, p_talentos jsonb)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_character_id TEXT;
  v_class public.srd_classes%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_pick JSONB;
  v_feat public.srd_feats%ROWTYPE;
  v_skill_points_spent JSONB := '{}'::jsonb;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF p_talentos IS NULL OR jsonb_typeof(p_talentos)<>'array' THEN
    RAISE EXCEPTION 'Os talentos precisam ser enviados como uma lista.';
  END IF;
  SELECT cl.* INTO v_class FROM public.srd_classes cl WHERE cl.id=p_classe_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Classe SRD não encontrada.'; END IF;

  FOR v_pick IN SELECT value FROM jsonb_array_elements(p_talentos) LOOP
    IF jsonb_typeof(v_pick)<>'object' OR NULLIF(BTRIM(v_pick->>'id'),'') IS NULL THEN
      RAISE EXCEPTION 'Cada escolha de talento precisa de um ID válido.';
    END IF;
    SELECT f.* INTO v_feat FROM public.srd_feats f WHERE f.id=v_pick->>'id';
    IF NOT FOUND THEN RAISE EXCEPTION 'Talento não encontrado: %.',v_pick->>'id'; END IF;
    IF COALESCE(v_feat.requisitos->>'type','General')<>'General' THEN
      RAISE EXCEPTION '% não é um talento geral disponível na criação básica.',v_feat.nome;
    END IF;
  END LOOP;

  v_character_id:=public.criar_personagem_srd(p_nome,p_raca_id,p_classe_id,p_atributos);
  PERFORM public.salvar_pericias_srd(v_character_id,p_pericias);
  PERFORM public.salvar_talentos_srd(v_character_id,p_talentos);

  SELECT sh.* INTO v_sheet
    FROM public.srd_character_sheets sh
   WHERE sh.character_id::text=v_character_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'A ficha SRD foi criada, mas não pôde ser relida para registrar sua trilha de classe.'; END IF;

  SELECT COALESCE(
    jsonb_object_agg(
      skill.key,
      to_jsonb(
        (skill.value #>> '{}')::numeric *
        CASE
          WHEN skill.key='srd35_skill_speak_language' OR EXISTS (
            SELECT 1
              FROM jsonb_array_elements_text(COALESCE(v_class.pericias_classe,'[]'::jsonb)) AS class_skill(name)
             WHERE public.srd35_normalizar_parametro_talento(class_skill.name)=public.srd35_normalizar_parametro_talento(sk.nome)
                OR (
                  public.srd35_normalizar_parametro_talento(class_skill.name)='conhecimentoqualquer'
                  AND sk.nome ILIKE 'Conhecimento%'
                )
          ) THEN 1 ELSE 2
        END
      )
    ),
    '{}'::jsonb
  )
    INTO v_skill_points_spent
    FROM jsonb_each(
      CASE WHEN jsonb_typeof(v_sheet.pericias)='object'
           THEN v_sheet.pericias ELSE '{}'::jsonb END
    ) AS skill(key,value)
    JOIN public.srd_skills sk ON sk.id=skill.key
   WHERE jsonb_typeof(skill.value)='number';

  INSERT INTO public.srd_character_class_levels
    (character_id,class_id,class_level,taken_at_character_level,hit_points_gained,skill_points_spent)
  VALUES
    (v_sheet.character_id,v_class.id,GREATEST(1,COALESCE(v_sheet.nivel,1)),1,v_sheet.pv_max,v_skill_points_spent)
  ON CONFLICT (character_id,class_id) DO UPDATE
    SET class_level=EXCLUDED.class_level,
        taken_at_character_level=COALESCE(public.srd_character_class_levels.taken_at_character_level,1),
        hit_points_gained=EXCLUDED.hit_points_gained,
        skill_points_spent=EXCLUDED.skill_points_spent;

  RETURN v_character_id;
END;
$function$
;

-- criar_personagem_srd_completo(p_nome text, p_raca_id text, p_classe_id text, p_atributos jsonb, p_pericias jsonb, p_talentos jsonb, p_identidade jsonb)
CREATE OR REPLACE FUNCTION public.criar_personagem_srd_completo(p_nome text, p_raca_id text, p_classe_id text, p_atributos jsonb, p_pericias jsonb, p_talentos jsonb, p_identidade jsonb)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare
  v_id text;
  v_race public.srd_races%rowtype;
  v_class public.srd_classes%rowtype;
  v_sex text;
  v_age integer;
  v_height numeric;
  v_weight numeric;
  v_height_min numeric;
  v_height_max numeric;
  v_weight_min numeric;
  v_weight_max numeric;
  v_alignment text;
  v_min_age integer;
  v_age_dice integer;
  v_age_physical integer := 0;
  v_age_mental integer := 0;
  v_sheet public.srd_character_sheets%rowtype;
  v_attrs jsonb;
  v_pv integer;
  v_identity jsonb;
  v_pick jsonb;
  v_feat public.srd_feats%rowtype;
  v_skill_points_spent jsonb := '{}'::jsonb;
  v_skill_spent numeric := 0;
  v_skill_budget integer := 0;
  v_specialization text;
  v_prohibited jsonb;
  v_required_prohibited integer;
  v_deity public.srd_deities%rowtype;
  v_deity_id text;
  v_cause text;
  v_char_law integer;
  v_char_good integer;
  v_deity_law integer;
  v_deity_good integer;
  v_cleric_domains text[];
  v_druid_bond text;
  v_druid_animal text;
  v_druid_domains text[];
begin
  if auth.uid() is null then
    raise exception 'É necessário estar autenticado.';
  end if;
  if jsonb_typeof(p_identidade) <> 'object' then
    raise exception 'Informe as escolhas de identidade do personagem.';
  end if;
  v_identity := p_identidade;

  select * into v_race from public.srd_races where id = p_raca_id;
  if not found then raise exception 'Raça não encontrada.'; end if;
  select * into v_class from public.srd_classes where id = p_classe_id;
  if not found then raise exception 'Classe não encontrada.'; end if;

  v_sex := lower(coalesce(v_identity->>'sexo',''));
  if v_sex not in ('masculino','feminino') then
    raise exception 'Selecione masculino ou feminino para aplicar a tabela racial de altura e peso.';
  end if;
  v_age := nullif(v_identity->>'idade','')::integer;
  v_height := nullif(v_identity->>'altura_cm','')::numeric;
  v_weight := nullif(v_identity->>'peso_kg','')::numeric;
  v_alignment := nullif(btrim(v_identity->>'tendencia'),'');
  if v_age is null or v_age < 1 then raise exception 'Informe uma idade válida.'; end if;
  if p_raca_id='humano' and v_sex='masculino' then v_height_min:=165;v_height_max:=210;v_weight_min:=62;v_weight_max:=140;
  elsif p_raca_id='humano' then v_height_min:=150;v_height_max:=195;v_weight_min:=44;v_weight_max:=122;
  elsif p_raca_id='anao' and v_sex='masculino' then v_height_min:=130;v_height_max:=145;v_weight_min:=67;v_weight_max:=113;
  elsif p_raca_id='anao' then v_height_min:=125;v_height_max:=140;v_weight_min:=52;v_weight_max:=98;
  elsif p_raca_id='elfo' and v_sex='masculino' then v_height_min:=150;v_height_max:=175;v_weight_min:=43;v_weight_max:=78;
  elsif p_raca_id='elfo' then v_height_min:=150;v_height_max:=175;v_weight_min:=41;v_weight_max:=76;
  elsif p_raca_id='gnomo' and v_sex='masculino' then v_height_min:=95;v_height_max:=110;v_weight_min:=20.5;v_weight_max:=20.5;
  elsif p_raca_id='gnomo' then v_height_min:=90;v_height_max:=105;v_weight_min:=17.5;v_weight_max:=17.5;
  elsif p_raca_id='meio-elfo' and v_sex='masculino' then v_height_min:=160;v_height_max:=195;v_weight_min:=52;v_weight_max:=114;
  elsif p_raca_id='meio-elfo' then v_height_min:=150;v_height_max:=185;v_weight_min:=42;v_weight_max:=104;
  elsif p_raca_id='meio-orc' and v_sex='masculino' then v_height_min:=170;v_height_max:=215;v_weight_min:=67;v_weight_max:=145;
  elsif p_raca_id='meio-orc' then v_height_min:=150;v_height_max:=195;v_weight_min:=47;v_weight_max:=125;
  elsif p_raca_id='halfling' and v_sex='masculino' then v_height_min:=85;v_height_max:=100;v_weight_min:=15.5;v_weight_max:=15.5;
  elsif p_raca_id='halfling' then v_height_min:=80;v_height_max:=95;v_weight_min:=12.5;v_weight_max:=12.5;
  else raise exception 'Não há tabela física para esta combinação de raça e sexo.'; end if;
  if v_height is null or v_height < v_height_min or v_height > v_height_max then
    raise exception 'Altura fora do intervalo da tabela racial (% a % cm).',v_height_min,v_height_max;
  end if;
  if v_weight is null or v_weight < v_weight_min or v_weight > v_weight_max then
    raise exception 'Peso fora do intervalo da tabela racial (% a % kg).',v_weight_min,v_weight_max;
  end if;
  if v_alignment not in ('Leal e Bom','Neutro e Bom','Caótico e Bom','Leal e Neutro','Neutro','Caótico e Neutro','Leal e Mau','Neutro e Mau','Caótico e Mau') then
    raise exception 'Selecione uma tendência válida.';
  end if;

  v_age_dice := case
    when v_class.id in ('barbaro','ladino','feiticeiro') then
      case p_raca_id when 'humano' then 1 when 'anao' then 3 when 'elfo' then 4 when 'gnomo' then 4 when 'meio-elfo' then 1 when 'meio-orc' then 1 when 'halfling' then 2 end
    when v_class.id in ('bardo','guerreiro','paladino','ranger') then
      case p_raca_id when 'humano' then 1 when 'anao' then 5 when 'elfo' then 6 when 'gnomo' then 6 when 'meio-elfo' then 2 when 'meio-orc' then 1 when 'halfling' then 3 end
    else
      case p_raca_id when 'humano' then 2 when 'anao' then 7 when 'elfo' then 10 when 'gnomo' then 9 when 'meio-elfo' then 3 when 'meio-orc' then 2 when 'halfling' then 4 end
  end;
  if v_age_dice is null then
    raise exception 'Raça ou classe sem tabela de idade inicial SRD 3.5.';
  end if;
  v_min_age := case p_raca_id when 'humano' then 15 when 'anao' then 40 when 'elfo' then 110 when 'gnomo' then 40 when 'meio-elfo' then 20 when 'meio-orc' then 14 when 'halfling' then 20 end + v_age_dice;
  if v_age < v_min_age then
    raise exception 'A idade mínima para a raça % e classe % é % anos (idade adulta + %d6, resultado mínimo).',p_raca_id,v_class.nome,v_min_age,v_age_dice;
  end if;

  if v_class.id in ('barbaro','bardo') and left(v_alignment,4)='Leal' then
    raise exception 'A classe % não pode ser Leal.',v_class.nome;
  elsif v_class.id='druida' and v_alignment not in ('Neutro e Bom','Leal e Neutro','Neutro','Caótico e Neutro','Neutro e Mau') then
    raise exception 'O Druida deve possuir uma tendência neutra.';
  elsif v_class.id='monge' and left(v_alignment,4)<>'Leal' then
    raise exception 'O Monge deve possuir uma tendência Leal.';
  elsif v_class.id='paladino' and v_alignment<>'Leal e Bom' then
    raise exception 'O Paladino deve ser Leal e Bom.';
  end if;
  if v_class.id='ranger' then
    if coalesce(v_identity->>'ranger_favored_enemy','') not in (
      'aberration','animal','construct','dragon','elemental','fey','giant','magical_beast',
      'monstrous_humanoid','ooze','plant','undead','vermin',
      'humanoid_aquatic','humanoid_dwarf','humanoid_elf','humanoid_gnoll','humanoid_gnome',
      'humanoid_goblinoid','humanoid_halfling','humanoid_human','humanoid_orc','humanoid_reptilian',
      'outsider_air','outsider_chaotic','outsider_earth','outsider_evil','outsider_fire',
      'outsider_good','outsider_lawful','outsider_native','outsider_water'
    ) then
      raise exception 'Escolha um inimigo predileto válido para o Patrulheiro.';
    end if;
  else
    v_identity := jsonb_set(v_identity,'{ranger_favored_enemy}','""'::jsonb,true);
  end if;


  if v_class.id in ('mago','feiticeiro') then
    if coalesce(v_identity->>'familiar_id','') not in
      ('','snake_small_viper','cat','lizard','rat','badger','owl','raven','hawk','bat','toad') then
      raise exception 'Escolha um familiar básico válido para Mago ou Feiticeiro.';
    end if;
  else
    v_identity := jsonb_set(v_identity,'{familiar_id}','""'::jsonb,true);
  end if;

  if v_class.id='druida' then
    v_druid_bond := coalesce(nullif(v_identity->>'druid_nature_bond',''),'companion');
    v_druid_animal := nullif(v_identity->>'druid_animal_companion_id','');
    select array_agg(value order by ordinality) into v_druid_domains
      from jsonb_array_elements_text(coalesce(v_identity->'druid_domain_ids','[]'::jsonb)) with ordinality as x(value,ordinality);
    if v_druid_bond='companion' then
      if v_druid_animal is null or v_druid_animal not in ('badger','camel','dire_rat','dog','dog_riding','eagle','hawk','horse_light','owl','pony','snake_small_viper','snake_medium_viper','wolf') then
        raise exception 'Escolha um companheiro animal básico permitido para o Druida de 1º nível.';
      end if;
      if not exists(select 1 from public.srd_monsters where id=v_druid_animal and tipo='Animal' and source_status='verified_srd') then
        raise exception 'O companheiro animal escolhido não está disponível no catálogo verificado.';
      end if;
      if coalesce(cardinality(v_druid_domains),0)<>0 then raise exception 'O Druida que escolhe companheiro animal não recebe domínio inicial.'; end if;
      v_identity := jsonb_set(v_identity,'{druid_nature_bond}','"companion"'::jsonb,true);
      v_identity := jsonb_set(v_identity,'{druid_animal_companion_id}',to_jsonb(v_druid_animal),true);
      v_identity := jsonb_set(v_identity,'{druid_domain_ids}','[]'::jsonb,true);
    elsif v_druid_bond='domain' then
      if v_druid_animal is not null then raise exception 'A escolha de domínio substitui o companheiro animal inicial.'; end if;
      if coalesce(cardinality(v_druid_domains),0)<>1 or v_druid_domains[1] not in ('air','animal','earth','fire','plant','water') then
        raise exception 'Escolha exatamente um domínio druídico válido.';
      end if;
      v_identity := jsonb_set(v_identity,'{druid_nature_bond}','"domain"'::jsonb,true);
      v_identity := jsonb_set(v_identity,'{druid_animal_companion_id}','""'::jsonb,true);
      v_identity := jsonb_set(v_identity,'{druid_domain_ids}',to_jsonb(v_druid_domains),true);
    else
      raise exception 'Escolha companheiro animal ou domínio para o vínculo com a natureza.';
    end if;
  else
    v_identity := jsonb_set(v_identity,'{druid_nature_bond}','"none"'::jsonb,true);
    v_identity := jsonb_set(v_identity,'{druid_animal_companion_id}','""'::jsonb,true);
    v_identity := jsonb_set(v_identity,'{druid_domain_ids}','[]'::jsonb,true);
  end if;

  if v_class.id='clerigo' then
    select array_agg(value order by ordinality) into v_cleric_domains
      from jsonb_array_elements_text(coalesce(v_identity->'cleric_domain_ids','[]'::jsonb)) with ordinality as x(value,ordinality);
    if coalesce(cardinality(v_cleric_domains),0)<>2 or v_cleric_domains[1]=v_cleric_domains[2] then
      raise exception 'Escolha dois domínios diferentes para o Clérigo.';
    end if;
    if (select count(*) from public.srd_domains where domain_id=any(v_cleric_domains))<>2 then
      raise exception 'Um dos domínios escolhidos não existe no catálogo.';
    end if;
    v_deity_id := nullif(v_identity->>'cleric_deity_id','');
    v_cause := nullif(btrim(v_identity->>'cleric_cause'),'');
    if coalesce(v_identity->>'cleric_source','deity')='deity' then
      if v_deity_id is null then raise exception 'Escolha uma divindade para o Clérigo.'; end if;
      select * into v_deity from public.srd_deities where deity_id=v_deity_id;
      if not found then raise exception 'Divindade não encontrada no catálogo.'; end if;
      if cardinality(v_deity.racial_races)>0 and not (p_raca_id=any(v_deity.racial_races)) then
        raise exception 'Esta divindade racial não aceita clérigos da raça escolhida.';
      end if;
      if not (v_cleric_domains[1]=any(v_deity.domains) and v_cleric_domains[2]=any(v_deity.domains)) then
        raise exception 'Os domínios escolhidos não pertencem à divindade selecionada.';
      end if;
      v_char_law := case v_alignment when 'Leal e Bom' then 1 when 'Leal e Neutro' then 1 when 'Leal e Mau' then 1 when 'Caótico e Bom' then -1 when 'Caótico e Neutro' then -1 when 'Caótico e Mau' then -1 else 0 end;
      v_char_good := case v_alignment when 'Leal e Bom' then 1 when 'Neutro e Bom' then 1 when 'Caótico e Bom' then 1 when 'Leal e Mau' then -1 when 'Neutro e Mau' then -1 when 'Caótico e Mau' then -1 else 0 end;
      v_deity_law := case v_deity.alignment when 'Leal e Bom' then 1 when 'Leal e Neutro' then 1 when 'Leal e Mau' then 1 when 'Caótico e Bom' then -1 when 'Caótico e Neutro' then -1 when 'Caótico e Mau' then -1 else 0 end;
      v_deity_good := case v_deity.alignment when 'Leal e Bom' then 1 when 'Neutro e Bom' then 1 when 'Caótico e Bom' then 1 when 'Leal e Mau' then -1 when 'Neutro e Mau' then -1 when 'Caótico e Mau' then -1 else 0 end;
      if abs(v_char_law-v_deity_law)+abs(v_char_good-v_deity_good)>1 then
        raise exception 'A tendência do Clérigo deve ser igual ou estar a um passo da tendência da divindade.';
      end if;
      if v_deity_id='st_cuthbert' and v_alignment not in ('Leal e Bom','Leal e Neutro') then
        raise exception 'Clérigos de St. Cuthbert devem ser Leais e Bons ou Leais e Neutros.';
      end if;
      v_identity := jsonb_set(v_identity,'{cleric_source}','"deity"'::jsonb,true);
      v_identity := jsonb_set(v_identity,'{cleric_cause}','""'::jsonb,true);
    elsif coalesce(v_identity->>'cleric_source','')='cause' then
      if v_cause is null then raise exception 'Descreva a causa ou ideal que concede poder ao Clérigo.'; end if;
      v_identity := jsonb_set(v_identity,'{cleric_deity_id}','""'::jsonb,true);
    else
      raise exception 'Escolha uma divindade ou uma causa/ideal para o Clérigo.';
    end if;
  else
    v_identity := jsonb_set(v_identity,'{cleric_source}','"none"'::jsonb,true);
    v_identity := jsonb_set(v_identity,'{cleric_deity_id}','""'::jsonb,true);
    v_identity := jsonb_set(v_identity,'{cleric_cause}','""'::jsonb,true);
  end if;

  if v_age >= (case p_raca_id when 'humano' then 70 when 'anao' then 250 when 'elfo' then 350 when 'gnomo' then 200 when 'meio-elfo' then 125 when 'meio-orc' then 60 when 'halfling' then 100 end) then
    v_age_physical := -6; v_age_mental := 3;
  elsif v_age >= (case p_raca_id when 'humano' then 53 when 'anao' then 188 when 'elfo' then 263 when 'gnomo' then 150 when 'meio-elfo' then 93 when 'meio-orc' then 45 when 'halfling' then 75 end) then
    v_age_physical := -3; v_age_mental := 2;
  elsif v_age >= (case p_raca_id when 'humano' then 35 when 'anao' then 125 when 'elfo' then 175 when 'gnomo' then 100 when 'meio-elfo' then 62 when 'meio-orc' then 30 when 'halfling' then 50 end) then
    v_age_physical := -1; v_age_mental := 1;
  end if;

  if v_class.id='barbaro' then
    if jsonb_typeof(v_identity->'alfabetizado')<>'boolean' then
      raise exception 'Informe se o Bárbaro deseja gastar 2 pontos de perícia para aprender a ler e escrever.';
    end if;
  else
    v_identity := jsonb_set(v_identity,'{alfabetizado}','true'::jsonb,true);
  end if;

  if v_class.id='mago' then
    v_specialization := nullif(v_identity->>'wizard_specialization','');
    v_prohibited := coalesce(v_identity->'wizard_prohibited_schools','[]'::jsonb);
    if jsonb_typeof(v_prohibited)<>'array' then
      raise exception 'Informe a lista de escolas proibidas do Mago.';
    end if;
    if v_specialization='universalista' then
      if jsonb_array_length(v_prohibited)<>0 then raise exception 'O Mago Universalista não possui escolas proibidas.'; end if;
    elsif v_specialization in ('abjuration','conjuration','divination','enchantment','evocation','illusion','necromancy','transmutation') then
      v_required_prohibited := case when v_specialization='divination' then 1 else 2 end;
      if jsonb_array_length(v_prohibited)<>v_required_prohibited then
        raise exception 'A especialização escolhida exige % escola(s) proibida(s).',v_required_prohibited;
      end if;
      if exists (
        select 1 from jsonb_array_elements_text(v_prohibited) x(value)
         where x.value not in ('abjuration','conjuration','divination','enchantment','evocation','illusion','necromancy','transmutation')
            or x.value=v_specialization
      ) then raise exception 'Escola proibida inválida ou igual à escola de especialização.'; end if;
      if (select count(*) from jsonb_array_elements_text(v_prohibited)) <>
         (select count(distinct value) from jsonb_array_elements_text(v_prohibited) t(value)) then
        raise exception 'Não repita escolas proibidas.';
      end if;
    else
      raise exception 'Escolha a escola de especialização ou Universalista.';
    end if;
  else
    v_identity := jsonb_set(v_identity,'{wizard_specialization}','"universalista"'::jsonb,true);
    v_identity := jsonb_set(v_identity,'{wizard_prohibited_schools}','[]'::jsonb,true);
  end if;

  IF p_talentos IS NULL OR jsonb_typeof(p_talentos)<>'array' THEN
    RAISE EXCEPTION 'Os talentos precisam ser enviados como uma lista.';
  END IF;
  FOR v_pick IN SELECT value FROM jsonb_array_elements(p_talentos) LOOP
    IF jsonb_typeof(v_pick)<>'object' OR NULLIF(BTRIM(v_pick->>'id'),'') IS NULL THEN
      RAISE EXCEPTION 'Cada escolha de talento precisa de um ID válido.';
    END IF;
    SELECT f.* INTO v_feat FROM public.srd_feats f WHERE f.id=v_pick->>'id';
    IF NOT FOUND THEN RAISE EXCEPTION 'Talento não encontrado: %.',v_pick->>'id'; END IF;
    IF COALESCE(v_feat.requisitos->>'type','General')<>'General' THEN
      RAISE EXCEPTION '% não é um talento geral disponível na criação básica.',v_feat.nome;
    END IF;
  END LOOP;

  -- Cria apenas o registro-base. A idade é aplicada antes das validações
  -- de perícias e talentos, para que o servidor use os atributos finais.
  v_id := public.criar_personagem_srd(p_nome,p_raca_id,p_classe_id,p_atributos);
  SELECT * INTO v_sheet FROM public.srd_character_sheets
   WHERE character_id::text=v_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha recém-criada não encontrada.'; END IF;

  v_attrs := jsonb_build_object(
    'FOR', greatest(1,(v_sheet.atributos->>'FOR')::integer+v_age_physical),
    'DES', greatest(1,(v_sheet.atributos->>'DES')::integer+v_age_physical),
    'CON', greatest(1,(v_sheet.atributos->>'CON')::integer+v_age_physical),
    'INT', greatest(1,(v_sheet.atributos->>'INT')::integer+v_age_mental),
    'SAB', greatest(1,(v_sheet.atributos->>'SAB')::integer+v_age_mental),
    'CAR', greatest(1,(v_sheet.atributos->>'CAR')::integer+v_age_mental)
  );

  v_pv := greatest(1,v_class.dado_vida+floor((((v_attrs->>'CON')::numeric-10)/2))::integer);

  update public.srd_character_sheets
     set identidade = v_identity,
         atributos = v_attrs,
         pv_atual = v_pv,
         pv_max = v_pv
   where character_id=v_sheet.character_id;
  update public.characters set idade=v_age where id=v_sheet.character_id;

  -- Agora as regras consultam os atributos finais, já com idade e raça.
  PERFORM public.salvar_pericias_srd(v_id,p_pericias);
  PERFORM public.salvar_talentos_srd(v_id,p_talentos);

  SELECT * INTO v_sheet FROM public.srd_character_sheets
   WHERE character_id=v_sheet.character_id FOR UPDATE;

  SELECT COALESCE(
    jsonb_object_agg(
      skill.key,
      to_jsonb(
        (skill.value #>> '{}')::numeric *
        CASE
          WHEN skill.key='srd35_skill_speak_language' OR EXISTS (
            SELECT 1
              FROM jsonb_array_elements_text(COALESCE(v_class.pericias_classe,'[]'::jsonb)) AS class_skill(name)
             WHERE public.srd35_normalizar_parametro_talento(class_skill.name)=public.srd35_normalizar_parametro_talento(sk.nome)
                OR (
                  public.srd35_normalizar_parametro_talento(class_skill.name)='conhecimentoqualquer'
                  AND sk.nome ILIKE 'Conhecimento%'
                )
          ) THEN 1 ELSE 2
        END
      )
    ),
    '{}'::jsonb
  )
    INTO v_skill_points_spent
    FROM jsonb_each(
      CASE WHEN jsonb_typeof(v_sheet.pericias)='object'
           THEN v_sheet.pericias ELSE '{}'::jsonb END
    ) AS skill(key,value)
    JOIN public.srd_skills sk
      ON sk.id=skill.key
      OR (skill.key LIKE 'srd35_skill_oficio_%' AND sk.id='oficio')
      OR (skill.key LIKE 'srd35_skill_profissao_%' AND sk.id='profissao')
   WHERE jsonb_typeof(skill.value)='number';

  INSERT INTO public.srd_character_class_levels
    (character_id,class_id,class_level,taken_at_character_level,hit_points_gained,skill_points_spent)
  VALUES
    (v_sheet.character_id,v_class.id,GREATEST(1,COALESCE(v_sheet.nivel,1)),1,v_sheet.pv_max,v_skill_points_spent)
  ON CONFLICT (character_id,class_id) DO UPDATE
    SET class_level=EXCLUDED.class_level,
        taken_at_character_level=COALESCE(public.srd_character_class_levels.taken_at_character_level,1),
        hit_points_gained=EXCLUDED.hit_points_gained,
        skill_points_spent=EXCLUDED.skill_points_spent;

  IF v_class.id='barbaro' AND (v_identity->>'alfabetizado')::boolean THEN
    SELECT COALESCE(SUM((entry.value #>> '{}')::numeric),0)
      INTO v_skill_spent
      FROM public.srd_character_class_levels cl
      CROSS JOIN LATERAL jsonb_each(cl.skill_points_spent) entry
     WHERE cl.character_id=v_sheet.character_id AND cl.class_id=v_class.id;
    v_skill_budget := GREATEST(1,v_class.pericias_por_nivel+FLOOR((((v_attrs->>'INT')::numeric-10)/2))::integer)*4 + CASE WHEN v_race.id='humano' THEN 4 ELSE 0 END;
    IF v_skill_spent+2>v_skill_budget THEN
      RAISE EXCEPTION 'O Bárbaro precisa reservar 2 pontos para alfabetização; orçamento % e gasto em perícias %.',v_skill_budget,v_skill_spent;
    END IF;
  END IF;

  return v_id;
end;
$function$
;

-- descanso_longo_npc_vinculado_srd(p_campaign_id bigint, p_token_id text)
CREATE OR REPLACE FUNCTION public.descanso_longo_npc_vinculado_srd(p_campaign_id bigint, p_token_id text)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
 SELECT priv.descanso_longo_npc_vinculado_srd_impl(p_campaign_id,p_token_id);
$function$
;

-- descanso_longo_personagem_srd(p_campaign_id bigint, p_character_id text)
CREATE OR REPLACE FUNCTION public.descanso_longo_personagem_srd(p_campaign_id bigint, p_character_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
DECLARE
 v_owner UUID;
 v_campaign BIGINT;
 v_state TEXT;
 v_level INTEGER;
 v_hp INTEGER;
 v_max INTEGER;
 v_new_hp INTEGER;
 v_last_rest TIMESTAMPTZ;
 v_spell_state JSONB;
 v_conditions_removed INTEGER:=0;
BEGIN
 IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
 SELECT c.user_id,c.campaign_id INTO v_owner,v_campaign
   FROM public.characters c
  WHERE c.id::TEXT=BTRIM(p_character_id) FOR UPDATE;
 IF NOT FOUND OR v_campaign IS DISTINCT FROM p_campaign_id THEN
   RAISE EXCEPTION 'Personagem não encontrado nesta campanha.';
 END IF;
 IF v_owner IS DISTINCT FROM auth.uid() THEN
   RAISE EXCEPTION 'Somente o dono da ficha pode realizar descanso.';
 END IF;
 SELECT state INTO v_state FROM public.campaigns WHERE id=p_campaign_id;
 IF UPPER(COALESCE(v_state,''))='COMBATE' THEN
   RAISE EXCEPTION 'Não é possível descansar durante um combate.';
 END IF;
 SELECT s.nivel,s.pv_atual,s.pv_max,s.magias_descanso_em
   INTO v_level,v_hp,v_max,v_last_rest
   FROM public.srd_character_sheets s
  WHERE s.character_id::TEXT=BTRIM(p_character_id) FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada.'; END IF;
 IF v_last_rest IS NOT NULL AND v_last_rest>clock_timestamp()-INTERVAL '8 hours' THEN
   RAISE EXCEPTION 'O descanso longo exige 8 horas entre descansos.';
 END IF;
 v_level:=GREATEST(1,COALESCE(v_level,1));
 IF v_max IS NULL OR v_max<1 THEN RAISE EXCEPTION 'PV máximo inválido.'; END IF;
 IF COALESCE(v_hp,0)<=-10 OR priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_character_id),'no_healing') THEN
   RAISE EXCEPTION 'Personagens mortos não podem se beneficiar de descanso longo.';
 END IF;
 v_new_hp:=LEAST(v_max,COALESCE(v_hp,v_max)+v_level);
 PERFORM priv.srd_sync_character_vital_condition(BTRIM(p_character_id),v_new_hp,
   v_new_hp<0 AND EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc
     WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='character'
       AND cc.target_id=BTRIM(p_character_id) AND cc.condition_id='stable' AND cc.active=true));
 PERFORM public.repor_magias_srd(BTRIM(p_character_id));
 UPDATE public.srd_character_feature_resources
    SET uses_spent=0,resource_spent=0,last_reset_at=clock_timestamp()
  WHERE character_id=(SELECT id FROM public.characters WHERE id::text=BTRIM(p_character_id));
 UPDATE public.srd_character_sheets
    SET pv_atual=v_new_hp
  WHERE character_id::TEXT=BTRIM(p_character_id)
  RETURNING magias_preparadas INTO v_spell_state;

 -- Eight hours of complete rest removes fatigue and exhaustion (SRD 3.5).
 UPDATE public.srd_campaign_conditions
    SET active=false
  WHERE campaign_id=p_campaign_id AND target_kind='character'
    AND target_id=BTRIM(p_character_id) AND active
    AND condition_id IN ('fatigued','exhausted');
 GET DIAGNOSTICS v_conditions_removed=ROW_COUNT;

 RETURN jsonb_build_object(
   'character_id',BTRIM(p_character_id),
   'pv_atual',v_new_hp,'pv_max',v_max,
   'cura',v_new_hp-COALESCE(v_hp,v_max),
   'magias_repostas',TRUE,
   'recursos_classe_repostos',TRUE,
   'condicoes_removidas',v_conditions_removed,
   'descanso_em',clock_timestamp()
 );
END;
$function$
;

-- encumbrance(p_carga numeric, p_for integer)
CREATE OR REPLACE FUNCTION public.encumbrance(p_carga numeric, p_for integer)
 RETURNS jsonb
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  with c as (select public.capacity(p_for) as cap)
  select case
    when p_carga <= (select cap from c) then
      jsonb_build_object('nivel','NORMAL','penalidade_m',0,'capacidade',(select cap from c))
    when p_carga <= (select cap from c) * 1.25 then
      jsonb_build_object('nivel','LEVE','penalidade_m',1,'capacidade',(select cap from c))
    when p_carga <= (select cap from c) * 1.5 then
      jsonb_build_object('nivel','MEDIO','penalidade_m',2,'capacidade',(select cap from c))
    when p_carga <= (select cap from c) * 2 then
      jsonb_build_object('nivel','PESADO','penalidade_m',3,'capacidade',(select cap from c))
    else
      jsonb_build_object('nivel','BLOQUEADO','penalidade_m',99,'capacidade',(select cap from c))
  end
$function$
;

-- end_combat(cid bigint)
CREATE OR REPLACE FUNCTION public.end_combat(cid bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_rage record;
  v_rage_token record;
BEGIN
  PERFORM priv.need_gm(cid);
  FOR v_rage IN
    SELECT target_id FROM public.srd_campaign_effects
     WHERE campaign_id=cid AND target_kind='character'
       AND active=true AND effect_data->>'source_feature'='barbarian_rage'
     FOR UPDATE
  LOOP
    PERFORM priv.srd_end_barbarian_rage(cid,v_rage.target_id,false);
  END LOOP;

  -- End token-based NPC rage as well, restoring its pre-rage PV before leaving combat.
  FOR v_rage_token IN
    SELECT target_id FROM public.srd_campaign_effects
     WHERE campaign_id=cid AND target_kind='token'
       AND active=true AND effect_data->>'source_feature'='barbarian_rage'
     FOR UPDATE
  LOOP
    PERFORM priv.srd_end_barbarian_rage_token(cid,v_rage_token.target_id,false);
  END LOOP;

  UPDATE public.srd_campaign_conditions
     SET active=false
   WHERE campaign_id=cid AND active=true
     AND notes->>'source_feature'='barbarian_rage'
     AND condition_id IN ('fatigued','exhausted');
  UPDATE priv.srd_aoo_attacks a SET status='cancelled'
  WHERE a.pending_id IN (SELECT p.pending_id FROM priv.srd_aoo_pending_movements p
    WHERE p.campaign_id=cid AND p.status IN ('waiting_reactions','ready_to_commit'))
    AND a.status IN ('awaiting_attack_roll','awaiting_critical_confirmation','awaiting_damage');
  UPDATE priv.srd_aoo_pending_movements p
  SET status='expired',cancelled_at=now(),updated_at=now(),
    pending_reactions=coalesce((SELECT jsonb_agg(
      CASE WHEN r.value->>'status' IN ('waiting','reserved','attack_started','hit_pending_damage')
        THEN r.value||jsonb_build_object('status','skipped','skip_reason','combat_ended')
        ELSE r.value END ORDER BY r.ordinality)
      FROM jsonb_array_elements(p.pending_reactions) WITH ORDINALITY r(value,ordinality)),'[]'::jsonb)
  WHERE p.campaign_id=cid AND p.status IN ('waiting_reactions','ready_to_commit');
  PERFORM priv.srd_clear_combat_flatfooted_all(cid);
  UPDATE public.combat_state SET ativo=false,ordem='[]'::jsonb,iniciado_em=NULL WHERE campaign_id=cid;
  UPDATE public.campaigns SET state='EXPLORACAO' WHERE id=cid;
  PERFORM priv.log(cid,'COMBATE_ENCERRADO',jsonb_build_object('por',auth.uid()));
  RETURN jsonb_build_object('ok',true);
END;
$function$
;

-- end_turn(p_token bigint)
CREATE OR REPLACE FUNCTION public.end_turn(p_token bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
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
$function$
;

-- enforce_campaign_member_role()
CREATE OR REPLACE FUNCTION public.enforce_campaign_member_role()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_owner UUID;
BEGIN
  SELECT campaign.owner_id INTO v_owner
  FROM public.campaigns AS campaign
  WHERE campaign.id = NEW.campaign_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Mesa não encontrada.'; END IF;

  IF NEW.user_id = v_owner THEN
    NEW.role := 'GM';
  ELSIF NEW.role = 'GM' THEN
    NEW.role := 'PLAYER';
  END IF;
  RETURN NEW;
END
$function$
;

-- entrar_campanha_aberta(p_campaign_id bigint)
CREATE OR REPLACE FUNCTION public.entrar_campanha_aberta(p_campaign_id bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare
  v_uid uuid := auth.uid();
  v_owner uuid;
begin
  if v_uid is null then raise exception 'Não autenticado.'; end if;
  select owner_id into v_owner
  from public.campaigns
  where id = p_campaign_id and active
  for share;
  if v_owner is null then
    return jsonb_build_object('ok', false, 'erro', 'Mesa não encontrada ou indisponível.');
  end if;
  if exists(select 1 from public.campaign_codes where campaign_id = p_campaign_id) then
    return jsonb_build_object('ok', false, 'erro', 'code_required');
  end if;
  if v_owner <> v_uid then
    insert into public.members(campaign_id, user_id, role)
    values(p_campaign_id, v_uid, 'PLAYER')
    on conflict(campaign_id, user_id) do nothing;
  end if;
  return jsonb_build_object('ok', true, 'id', p_campaign_id, 'papel', case when v_owner = v_uid then 'GM' else 'PLAYER' end);
end;
$function$
;

-- entrar_campanha_com_codigo(p_campaign_id bigint, p_code text)
CREATE OR REPLACE FUNCTION public.entrar_campanha_com_codigo(p_campaign_id bigint, p_code text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare
  v_uid uuid := auth.uid();
  v_owner uuid;
  v_lock_key text := 'join:' || coalesce(auth.uid()::text, '');
begin
  if v_uid is null then raise exception 'Não autenticado.'; end if;
  if priv.locked(v_lock_key) then
    return jsonb_build_object('ok',false,'erro','Muitas tentativas. Aguarde 15 minutos.');
  end if;
  if p_code is null or p_code !~ '^[0-9]{4}$' then
    perform priv.fail(v_lock_key);
    return jsonb_build_object('ok',false,'erro','Informe um código válido de 4 números.');
  end if;
  select owner_id into v_owner
  from public.campaigns
  where id = p_campaign_id and active;
  if v_owner is null then
    return jsonb_build_object('ok',false,'erro','Mesa não encontrada ou indisponível.');
  end if;
  if not exists(select 1 from public.campaign_codes where campaign_id=p_campaign_id and code=p_code) then
    perform priv.fail(v_lock_key);
    return jsonb_build_object('ok',false,'erro','Código incorreto para esta mesa.');
  end if;
  perform priv.clear(v_lock_key);
  if v_owner <> v_uid then
    insert into public.members(campaign_id,user_id,role)
    values(p_campaign_id,v_uid,'PLAYER')
    on conflict(campaign_id,user_id) do nothing;
  end if;
  return jsonb_build_object('ok',true,'id',p_campaign_id,'papel',case when v_owner=v_uid then 'GM' else 'PLAYER' end);
end;
$function$
;

-- entregar_item_srd(p_campaign_id bigint, p_character_id text, p_equipment_id text, p_quantidade integer)
CREATE OR REPLACE FUNCTION public.entregar_item_srd(p_campaign_id bigint, p_character_id text, p_equipment_id text, p_quantidade integer DEFAULT 1)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_role TEXT; v_item public.srd_equipment%ROWTYPE; v_has_bag BOOLEAN; v_equipped BOOLEAN; v_slot TEXT;
BEGIN
  IF (SELECT auth.uid()) IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT member.role INTO v_role FROM public.members AS member
  WHERE member.campaign_id=p_campaign_id AND member.user_id=(SELECT auth.uid()) LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'Somente o Mestre pode entregar equipamento.'; END IF;
  IF p_quantidade IS NULL OR p_quantidade<1 OR p_quantidade>99 THEN RAISE EXCEPTION 'Quantidade inválida.'; END IF;
  SELECT * INTO v_item FROM public.srd_equipment WHERE id=p_equipment_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Equipamento não encontrado.'; END IF;
  IF NOT EXISTS(SELECT 1 FROM public.characters AS character JOIN public.members AS player
    ON player.campaign_id=character.campaign_id AND player.user_id=character.user_id AND player.role='PLAYER'
    WHERE character.id::TEXT=BTRIM(p_character_id) AND character.campaign_id=p_campaign_id) THEN
    RAISE EXCEPTION 'A ficha não pertence a um jogador desta campanha.';
  END IF;
  SELECT EXISTS(SELECT 1 FROM public.srd_character_equipment AS held JOIN public.srd_equipment AS gear ON gear.id=held.equipment_id
    WHERE held.character_id=BTRIM(p_character_id) AND held.quantidade>0
      AND (gear.categoria='mochila' OR gear.id='srd35_equipment_gear_backpack_empty')) INTO v_has_bag;
  v_slot:=public.srd35_equipment_slot(v_item.categoria,v_item.nome);
  v_equipped:=NOT v_has_bag AND v_slot<>'';
  IF v_equipped AND v_slot<>'acessorio' THEN
    UPDATE public.srd_character_equipment AS held SET equipado=FALSE FROM public.srd_equipment AS old
    WHERE held.character_id=BTRIM(p_character_id) AND held.equipment_id=old.id
      AND public.srd35_equipment_slot(old.categoria,old.nome)=v_slot;
  END IF;
  INSERT INTO public.srd_character_equipment(character_id,equipment_id,quantidade,equipado)
  VALUES(BTRIM(p_character_id),p_equipment_id,p_quantidade,v_equipped)
  ON CONFLICT(character_id,equipment_id) DO UPDATE SET quantidade=srd_character_equipment.quantidade+EXCLUDED.quantidade,
    equipado=srd_character_equipment.equipado OR EXCLUDED.equipado;
  RETURN jsonb_build_object('character_id',BTRIM(p_character_id),'equipment_id',p_equipment_id,'quantidade',p_quantidade,
    'equipado',v_equipped,'guardado_na_mochila',v_has_bag);
END; $function$
;

-- entregar_item_token_srd(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_quantidade integer)
CREATE OR REPLACE FUNCTION public.entregar_item_token_srd(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_quantidade integer DEFAULT 1)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_role TEXT; v_item public.srd_equipment%ROWTYPE; v_campaign public.campaigns%ROWTYPE;
  v_tokens JSONB; v_token JSONB; v_type TEXT; v_has_bag BOOLEAN; v_equipped BOOLEAN;
  v_slot TEXT; v_index BIGINT; v_base_ac NUMERIC; v_bonus INTEGER;
BEGIN
  IF (SELECT auth.uid()) IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT member.role INTO v_role FROM public.members AS member
  WHERE member.campaign_id=p_campaign_id AND member.user_id=(SELECT auth.uid()) LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'Somente o Mestre pode entregar equipamento.'; END IF;
  IF p_quantidade IS NULL OR p_quantidade<1 OR p_quantidade>99 THEN RAISE EXCEPTION 'Quantidade inválida.'; END IF;
  SELECT * INTO v_item FROM public.srd_equipment WHERE id=p_equipment_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Equipamento não encontrado.'; END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Mesa não encontrada.'; END IF;
  v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::JSONB END;
  SELECT t.value,t.ordinality INTO v_token,v_index FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(value,ordinality)
  WHERE t.value->>'id'=BTRIM(p_token_id) LIMIT 1;
  IF v_token IS NULL THEN RAISE EXCEPTION 'Token não encontrado nesta mesa.'; END IF;
  v_type:=v_token->>'tipo';
  IF v_type='player' THEN RAISE EXCEPTION 'Use a entrega de ficha para um token de jogador.'; END IF;
  IF v_type NOT IN ('npc','monstro') THEN RAISE EXCEPTION 'Tipo de token inválido.'; END IF;
  SELECT EXISTS(SELECT 1 FROM public.srd_cba_token_equipment AS bag JOIN public.srd_equipment AS gear ON gear.id=bag.equipment_id
    WHERE bag.campaign_id=p_campaign_id AND bag.token_id=BTRIM(p_token_id) AND bag.quantidade>0
      AND (gear.categoria='mochila' OR gear.id='srd35_equipment_gear_backpack_empty')) INTO v_has_bag;
  v_slot:=public.srd35_equipment_slot(v_item.categoria,v_item.nome);
  v_equipped:=NOT v_has_bag AND v_slot<>'';
  IF v_equipped AND v_slot<>'acessorio' THEN
    UPDATE public.srd_cba_token_equipment AS held SET equipado=FALSE FROM public.srd_equipment AS old
    WHERE held.campaign_id=p_campaign_id AND held.token_id=BTRIM(p_token_id) AND held.equipment_id=old.id
      AND public.srd35_equipment_slot(old.categoria,old.nome)=v_slot;
  END IF;
  INSERT INTO public.srd_cba_token_equipment(campaign_id,token_id,equipment_id,quantidade,equipado)
  VALUES(p_campaign_id,BTRIM(p_token_id),p_equipment_id,p_quantidade,v_equipped)
  ON CONFLICT(campaign_id,token_id,equipment_id) DO UPDATE SET quantidade=srd_cba_token_equipment.quantidade+EXCLUDED.quantidade,
    equipado=srd_cba_token_equipment.equipado OR EXCLUDED.equipado;
  IF v_equipped THEN
    SELECT COALESCE(SUM(public.srd35_equipment_ca_bonus(held.equipment_id)),0)::INTEGER INTO v_bonus
    FROM public.srd_cba_token_equipment AS held
    WHERE held.campaign_id=p_campaign_id AND held.token_id=BTRIM(p_token_id) AND held.equipado;
    v_base_ac:=COALESCE(NULLIF(v_token->>'baseAc','')::NUMERIC,NULLIF(v_token->>'ac','')::NUMERIC,
      NULLIF(v_token->'monsterStats'->>'ca','')::NUMERIC,10);
    v_token:=v_token||jsonb_build_object('baseAc',v_base_ac,'ac',v_base_ac+v_bonus);
    v_tokens:=jsonb_set(v_tokens,ARRAY[(v_index-1)::TEXT],v_token,FALSE);
    UPDATE public.campaigns SET cba_data=v_campaign.cba_data||jsonb_build_object('tokens',v_tokens) WHERE id=p_campaign_id;
  END IF;
  RETURN jsonb_build_object('campaign_id',p_campaign_id,'token_id',BTRIM(p_token_id),'equipment_id',p_equipment_id,
    'quantidade',p_quantidade,'equipado',v_equipped,'guardado_na_mochila',v_has_bag,
    'ac',CASE WHEN v_equipped THEN v_base_ac+v_bonus ELSE NULL END,
    'cba_data',CASE WHEN v_equipped THEN v_campaign.cba_data||jsonb_build_object('tokens',v_tokens) ELSE NULL END);
END; $function$
;

-- equipar_arma_instancia_npc_vinculado_srd(p_campaign_id bigint, p_token_id text, p_instance_id uuid, p_hand_slot text, p_equipado boolean)
CREATE OR REPLACE FUNCTION public.equipar_arma_instancia_npc_vinculado_srd(p_campaign_id bigint, p_token_id text, p_instance_id uuid, p_hand_slot text, p_equipado boolean)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'private'
AS $function$
  SELECT private.equipar_arma_instancia_npc_vinculado_impl(
    p_campaign_id, p_token_id, p_instance_id, p_hand_slot, p_equipado
  );
$function$
;

-- equipar_arma_instancia_personagem(p_character_id text, p_instance_id uuid, p_hand_slot text, p_equipado boolean)
CREATE OR REPLACE FUNCTION public.equipar_arma_instancia_personagem(p_character_id text, p_instance_id uuid, p_hand_slot text, p_equipado boolean)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'private'
AS $function$ SELECT private.equipar_arma_instancia_personagem_impl($1,$2,$3,$4); $function$
;

-- equipar_arma_instancia_token(p_campaign_id bigint, p_token_id text, p_instance_id uuid, p_hand_slot text, p_equipado boolean)
CREATE OR REPLACE FUNCTION public.equipar_arma_instancia_token(p_campaign_id bigint, p_token_id text, p_instance_id uuid, p_hand_slot text, p_equipado boolean)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'private'
AS $function$ SELECT private.equipar_arma_instancia_token_impl($1,$2,$3,$4,$5); $function$
;

-- equipar_item_npc_vinculado_srd(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_equipado boolean)
CREATE OR REPLACE FUNCTION public.equipar_item_npc_vinculado_srd(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_equipado boolean)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'private'
AS $function$
  SELECT private.equipar_item_npc_vinculado_impl(
    p_campaign_id, p_token_id, p_equipment_id, p_equipado
  );
$function$
;

-- equipar_item_srd(p_character_id text, p_equipment_id text, p_equipado boolean)
CREATE OR REPLACE FUNCTION public.equipar_item_srd(p_character_id text, p_equipment_id text, p_equipado boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'public'
AS $function$
declare
  v_campaign_id bigint;
  v_item public.srd_equipment%rowtype;
  v_slot text;
begin
  if auth.uid() is null then
    raise exception 'É necessário estar autenticado.';
  end if;

  select ch.campaign_id into v_campaign_id
  from public.characters ch
  where ch.id::text=btrim(p_character_id);
  if not found then raise exception 'Ficha não encontrada.'; end if;

  if not exists (
    select 1 from public.characters ch
    where ch.id::text=btrim(p_character_id)
      and (ch.user_id=auth.uid() or public.my_role(v_campaign_id)='GM')
  ) then
    raise exception 'Somente o dono da ficha ou o Mestre desta campanha pode alterar o equipamento.';
  end if;

  select * into v_item from public.srd_equipment where id=p_equipment_id;
  if not found then raise exception 'Equipamento não encontrado.'; end if;

  v_slot:=public.srd35_equipment_slot(v_item.categoria,v_item.nome);
  if v_slot is null or v_slot='' then
    raise exception 'Este item não pode ser equipado.';
  end if;

  if v_slot='arma' then
    return public.equipar_item_srd_maos(
      p_character_id,p_equipment_id,'main_hand',p_equipado
    );
  end if;

  if coalesce(p_equipado,false) then
    update public.srd_character_equipment held
       set equipado=false
      from public.srd_equipment old
     where held.character_id=btrim(p_character_id)
       and held.equipment_id=old.id
       and public.srd35_equipment_slot(old.categoria,old.nome)=v_slot;
  end if;

  update public.srd_character_equipment
     set equipado=coalesce(p_equipado,false)
   where character_id=btrim(p_character_id)
     and equipment_id=p_equipment_id;
  if not found then raise exception 'O item não está no inventário desta ficha.'; end if;

  return jsonb_build_object(
    'character_id',btrim(p_character_id),
    'equipment_id',p_equipment_id,
    'equipado',coalesce(p_equipado,false)
  );
end;
$function$
;

-- equipar_item_srd_maos(p_character_id text, p_equipment_id text, p_hand_slot text, p_equipado boolean)
CREATE OR REPLACE FUNCTION public.equipar_item_srd_maos(p_character_id text, p_equipment_id text, p_hand_slot text, p_equipado boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  v_campaign_id bigint;
  v_item public.srd_equipment%rowtype;
  v_instance_id uuid;
  v_count integer;
  v_equipped record;
  v_result jsonb;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  IF p_hand_slot IS NULL OR p_hand_slot NOT IN ('main_hand','off_hand') THEN
    RAISE EXCEPTION 'Mão inválida. Escolha mão principal ou secundária.';
  END IF;
  SELECT ch.campaign_id INTO v_campaign_id FROM public.characters ch WHERE ch.id::text=btrim(p_character_id);
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha não encontrada.'; END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.characters ch
    WHERE ch.id::text=btrim(p_character_id)
      AND (ch.user_id=auth.uid() OR public.my_role(v_campaign_id)='GM')
  ) THEN RAISE EXCEPTION 'Somente o dono da ficha ou o Mestre desta campanha pode alterar o equipamento.'; END IF;
  SELECT * INTO v_item FROM public.srd_equipment WHERE id=p_equipment_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Equipamento não encontrado.'; END IF;
  IF public.srd35_equipment_slot(v_item.categoria,v_item.nome)<>'arma' THEN
    RAISE EXCEPTION 'Somente armas podem ocupar uma das mãos.';
  END IF;
  SELECT count(*),(array_agg(instance_id ORDER BY created_at))[1]
    INTO v_count,v_instance_id
  FROM public.srd_character_weapon_instances
  WHERE character_id=btrim(p_character_id) AND equipment_id=p_equipment_id;
  IF v_count=0 THEN RAISE EXCEPTION 'Não existe instância desta arma vinculada à ficha.'; END IF;
  IF coalesce(p_equipado,false) THEN
    IF v_count<>1 THEN RAISE EXCEPTION 'Há múltiplas instâncias desta arma. Selecione a instância específica no inventário.'; END IF;
    RETURN public.equipar_arma_instancia_personagem(btrim(p_character_id),v_instance_id,p_hand_slot,true);
  END IF;
  FOR v_equipped IN
    SELECT instance_id,hand_slot FROM public.srd_character_weapon_instances
    WHERE character_id=btrim(p_character_id) AND equipment_id=p_equipment_id AND equipado=true
  LOOP
    v_result:=public.equipar_arma_instancia_personagem(btrim(p_character_id),v_equipped.instance_id,v_equipped.hand_slot,false);
  END LOOP;
  IF NOT FOUND THEN RAISE EXCEPTION 'Esta arma não está equipada.'; END IF;
  RETURN jsonb_build_object('character_id',btrim(p_character_id),'equipment_id',p_equipment_id,'hand_slot',p_hand_slot,'equipado',false);
END;
$function$
;

-- equipar_item_token_srd(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_equipado boolean)
CREATE OR REPLACE FUNCTION public.equipar_item_token_srd(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_equipado boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_role TEXT; v_item public.srd_equipment%ROWTYPE; v_campaign public.campaigns%ROWTYPE;
  v_tokens JSONB; v_token JSONB; v_index BIGINT; v_count INTEGER; v_slot TEXT; v_base_ac NUMERIC; v_bonus INTEGER;
BEGIN
  IF (SELECT auth.uid()) IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT member.role INTO v_role FROM public.members AS member
  WHERE member.campaign_id=p_campaign_id AND member.user_id=(SELECT auth.uid()) LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'Somente o Mestre pode alterar equipamento de NPCs e monstros.'; END IF;
  SELECT * INTO v_item FROM public.srd_equipment WHERE id=p_equipment_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Equipamento não encontrado.'; END IF;
  v_slot:=public.srd35_equipment_slot(v_item.categoria,v_item.nome);
  IF v_slot='' THEN RAISE EXCEPTION 'Este item não pode ser equipado.'; END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Mesa não encontrada.'; END IF;
  v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::JSONB END;
  SELECT t.value,t.ordinality INTO v_token,v_index FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(value,ordinality)
  WHERE t.value->>'id'=BTRIM(p_token_id) LIMIT 1;
  IF v_token IS NULL OR v_token->>'tipo' NOT IN ('npc','monstro') THEN RAISE EXCEPTION 'Token de NPC/monstro não encontrado.'; END IF;
  SELECT COUNT(*)::INTEGER INTO v_count FROM public.srd_cba_token_equipment
  WHERE campaign_id=p_campaign_id AND token_id=BTRIM(p_token_id) AND equipment_id=p_equipment_id;
  IF v_count=0 THEN RAISE EXCEPTION 'O item não está no inventário deste token.'; END IF;
  IF COALESCE(p_equipado,FALSE) AND v_slot<>'acessorio' THEN
    UPDATE public.srd_cba_token_equipment AS held SET equipado=FALSE FROM public.srd_equipment AS old
    WHERE held.campaign_id=p_campaign_id AND held.token_id=BTRIM(p_token_id) AND held.equipment_id=old.id
      AND public.srd35_equipment_slot(old.categoria,old.nome)=v_slot;
  END IF;
  UPDATE public.srd_cba_token_equipment SET equipado=COALESCE(p_equipado,FALSE)
  WHERE campaign_id=p_campaign_id AND token_id=BTRIM(p_token_id) AND equipment_id=p_equipment_id;
  SELECT COALESCE(SUM(public.srd35_equipment_ca_bonus(held.equipment_id)),0)::INTEGER INTO v_bonus
  FROM public.srd_cba_token_equipment AS held
  WHERE held.campaign_id=p_campaign_id AND held.token_id=BTRIM(p_token_id) AND held.equipado;
  v_base_ac:=COALESCE(NULLIF(v_token->>'baseAc','')::NUMERIC,NULLIF(v_token->>'ac','')::NUMERIC,
    NULLIF(v_token->'monsterStats'->>'ca','')::NUMERIC,10);
  v_token:=v_token||jsonb_build_object('baseAc',v_base_ac,'ac',v_base_ac+v_bonus);
  v_tokens:=jsonb_set(v_tokens,ARRAY[(v_index-1)::TEXT],v_token,FALSE);
  UPDATE public.campaigns SET cba_data=v_campaign.cba_data||jsonb_build_object('tokens',v_tokens) WHERE id=p_campaign_id;
  RETURN jsonb_build_object('campaign_id',p_campaign_id,'token_id',BTRIM(p_token_id),'equipment_id',p_equipment_id,
    'equipado',COALESCE(p_equipado,FALSE),'ac',v_base_ac+v_bonus,
    'cba_data',v_campaign.cba_data||jsonb_build_object('tokens',v_tokens));
END; $function$
;

-- equipar_item_token_srd_maos(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_hand_slot text, p_equipado boolean)
CREATE OR REPLACE FUNCTION public.equipar_item_token_srd_maos(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_hand_slot text, p_equipado boolean)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'private'
AS $function$
 SELECT private.equipar_item_token_srd_maos_impl($1,$2,$3,$4,$5);
$function$
;

-- excluir_ficha_propria(p_character_id text)
CREATE OR REPLACE FUNCTION public.excluir_ficha_propria(p_character_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
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
    SELECT c.combat_data
    INTO v_combat
    FROM public.campaigns AS c
    WHERE c.id = v_campaign_id
    FOR UPDATE;

    IF FOUND AND v_combat IS NOT NULL THEN
      v_order := CASE WHEN jsonb_typeof(v_combat->'turn_order') = 'array'
                      THEN v_combat->'turn_order' ELSE '[]'::JSONB END;
      v_expected := CASE WHEN jsonb_typeof(v_combat->'expected_character_ids') = 'array'
                         THEN v_combat->'expected_character_ids' ELSE '[]'::JSONB END;
      v_old_turn := GREATEST(0, COALESCE((v_combat->>'current_turn')::INTEGER, 0));

      SELECT current_entry.entry->>'id'
      INTO v_current_id
      FROM jsonb_array_elements(v_order) WITH ORDINALITY AS current_entry(entry, ordinality)
      WHERE current_entry.ordinality = v_old_turn + 1
      LIMIT 1;

      SELECT COALESCE(jsonb_agg(entry.entry ORDER BY entry.ordinality), '[]'::JSONB)
      INTO v_order_novo
      FROM jsonb_array_elements(v_order) WITH ORDINALITY AS entry(entry, ordinality)
      WHERE entry.entry->>'id' IS DISTINCT FROM v_character_id::TEXT;

      SELECT COALESCE(jsonb_agg(expected.character_id ORDER BY expected.ordinality), '[]'::JSONB)
      INTO v_expected_novo
      FROM jsonb_array_elements_text(v_expected) WITH ORDINALITY AS expected(character_id, ordinality)
      WHERE expected.character_id IS DISTINCT FROM v_character_id::TEXT;

      SELECT jsonb_array_length(v_order_novo) > 0
         AND NOT EXISTS (
           SELECT 1
           FROM jsonb_array_elements_text(v_expected_novo) AS expected(character_id)
           WHERE NOT EXISTS (
             SELECT 1
             FROM jsonb_array_elements(v_order_novo) AS ordered(entry)
             WHERE ordered.entry->>'id' = expected.character_id
           )
         )
      INTO v_active;

      IF v_active THEN
        SELECT ordered.ordinality - 1
        INTO v_new_turn
        FROM jsonb_array_elements(v_order_novo) WITH ORDINALITY AS ordered(entry, ordinality)
        WHERE ordered.entry->>'id' = v_current_id
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
$function$
;

-- finalizar_criacao_personagem_srd(p_nome text, p_raca_id text, p_classe_id text, p_atributos jsonb, p_pericias jsonb, p_talentos jsonb, p_identidade jsonb, p_idiomas jsonb, p_talentos_bonus jsonb, p_domain_ids text[], p_grimorio jsonb, p_equipamento_metodo text, p_equipamento_resultados jsonb, p_equipamento_itens jsonb)
CREATE OR REPLACE FUNCTION public.finalizar_criacao_personagem_srd(p_nome text, p_raca_id text, p_classe_id text, p_atributos jsonb, p_pericias jsonb, p_talentos jsonb, p_identidade jsonb, p_idiomas jsonb, p_talentos_bonus jsonb, p_domain_ids text[], p_grimorio jsonb, p_equipamento_metodo text, p_equipamento_resultados jsonb, p_equipamento_itens jsonb)
 RETURNS text
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_character_id text;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  -- A criação e todas as escolhas dependentes são uma única transação.
  v_character_id := public.criar_personagem_srd_completo(
    p_nome,
    p_raca_id,
    p_classe_id,
    p_atributos,
    p_pericias,
    p_talentos,
    p_identidade
  );

  PERFORM public.salvar_idiomas_personagem_srd(v_character_id, p_idiomas);
  PERFORM public.salvar_talentos_bonus_classe_inicial_srd(
    v_character_id,
    COALESCE(p_talentos_bonus, '[]'::jsonb)
  );

  IF COALESCE(array_length(p_domain_ids, 1), 0) > 0 THEN
    PERFORM public.salvar_dominios_personagem_srd(v_character_id, p_domain_ids);
  END IF;

  IF p_grimorio IS NOT NULL THEN
    PERFORM public.salvar_grimorio_srd(v_character_id, p_grimorio);
  END IF;

  PERFORM public.finalizar_equipamento_inicial_srd(
    v_character_id,
    p_equipamento_metodo,
    COALESCE(p_equipamento_resultados, '[]'::jsonb),
    COALESCE(p_equipamento_itens, '[]'::jsonb)
  );

  RETURN v_character_id;
END;
$function$
;

-- finalizar_equipamento_inicial_srd(p_character_id text, p_metodo text, p_resultados jsonb, p_itens jsonb)
CREATE OR REPLACE FUNCTION public.finalizar_equipamento_inicial_srd(p_character_id text, p_metodo text, p_resultados jsonb DEFAULT '[]'::jsonb, p_itens jsonb DEFAULT '[]'::jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_user UUID := auth.uid();
  v_character public.characters%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_package public.srd_starting_packages%ROWTYPE;
  v_items JSONB;
  v_item JSONB;
  v_equipment public.srd_equipment%ROWTYPE;
  v_class TEXT;
  v_dice INTEGER;
  v_multiplier NUMERIC;
  v_expected NUMERIC;
  v_roll_total INTEGER := 0;
  v_faces INTEGER[];
  v_qty INTEGER;
  v_cost NUMERIC := 0;
  v_remaining NUMERIC;
  v_slot TEXT;
  v_used_slots TEXT[] := ARRAY[]::TEXT[];
  v_equipped BOOLEAN;
  v_saved JSONB;
  v_face JSONB;
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT * INTO v_character FROM public.characters WHERE id::TEXT=BTRIM(p_character_id) AND user_id=v_user FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'A ficha não pertence a esta conta.'; END IF;
  SELECT * INTO v_sheet FROM public.srd_character_sheets WHERE character_id=v_character.id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'A ficha D&D 3.5 não existe.'; END IF;
  IF COALESCE(v_sheet.equipamento_inicial,'{}'::JSONB)->>'concluido'='true' THEN
    RETURN v_sheet.equipamento_inicial;
  END IF;

  v_class:=lower(COALESCE(v_sheet.classe_id,''));
  v_dice:=CASE WHEN v_class IN ('barbaro','bardo') THEN 4 WHEN v_class IN ('clerigo','ladino') THEN 5
    WHEN v_class='druida' THEN 2 WHEN v_class IN ('guerreiro','paladino','ranger','patrulheiro') THEN 6
    WHEN v_class='monge' THEN 5 WHEN v_class IN ('feiticeiro','sorcerer','mago','wizard') THEN 3 ELSE 0 END;
  v_multiplier:=CASE WHEN v_class='monge' THEN 1 ELSE 10 END;
  IF v_dice=0 THEN RAISE EXCEPTION 'A classe não possui regra de riqueza inicial cadastrada.'; END IF;
  v_expected:=v_dice*2.5*v_multiplier;

  IF p_metodo='pacote' THEN
    SELECT * INTO v_package FROM public.srd_starting_packages WHERE class_id=v_class;
    IF NOT FOUND THEN RAISE EXCEPTION 'Pacote da classe não cadastrado.'; END IF;
    v_items:=v_package.items;
  ELSIF p_metodo='ouro' THEN
    IF jsonb_typeof(COALESCE(p_resultados,'[]'::JSONB))<>'array'
      OR jsonb_array_length(COALESCE(p_resultados,'[]'::JSONB))<>v_dice THEN
      RAISE EXCEPTION 'A rolagem precisa conter % dados de quatro faces.',v_dice;
    END IF;
    FOR v_face IN SELECT value FROM jsonb_array_elements(p_resultados) LOOP
      IF COALESCE(v_face#>>'{}','') !~ '^[1-4]$' THEN RAISE EXCEPTION 'Cada resultado de d4 deve estar entre 1 e 4.'; END IF;
      v_roll_total:=v_roll_total+(v_face#>>'{}')::INTEGER;
    END LOOP;
    v_expected:=v_roll_total*v_multiplier;
    v_items:=COALESCE(p_itens,'[]'::JSONB);
  ELSE
    RAISE EXCEPTION 'Escolha o pacote da classe ou a compra com ouro.';
  END IF;

  IF jsonb_typeof(v_items)<>'array' THEN RAISE EXCEPTION 'Lista de itens inválida.'; END IF;
  IF jsonb_array_length(v_items)>60 THEN RAISE EXCEPTION 'A lista de itens excede o limite permitido.'; END IF;

  FOR v_item IN SELECT value FROM jsonb_array_elements(v_items) LOOP
    IF COALESCE(v_item->>'id','')='' OR COALESCE(v_item->>'quantidade','') !~ '^[1-9][0-9]{0,2}$' THEN
      RAISE EXCEPTION 'Um item inicial possui ID ou quantidade inválida.';
    END IF;
    v_qty:=(v_item->>'quantidade')::INTEGER;
    SELECT * INTO v_equipment FROM public.srd_equipment WHERE id=v_item->>'id';
    IF NOT FOUND THEN RAISE EXCEPTION 'Item inicial % não está no catálogo.',v_item->>'id'; END IF;
    IF lower(COALESCE(v_equipment.categoria,'')) IN ('rings','rods','staffs','wands','wondrous_items','potions_and_oils')
      OR lower(COALESCE(v_equipment.categoria,'')) LIKE 'specific_%'
      OR lower(COALESCE(v_equipment.categoria,''))='specific_cursed_items' THEN
      RAISE EXCEPTION 'Itens mágicos não fazem parte das compras iniciais de 1º nível.';
    END IF;
    IF COALESCE(v_equipment.custo_po,v_equipment.preco) IS NULL THEN
      RAISE EXCEPTION 'O item % está sem preço cadastrado.',v_equipment.nome;
    END IF;
    v_cost:=v_cost+COALESCE(v_equipment.custo_po,v_equipment.preco)*v_qty;
  END LOOP;

  IF v_cost>v_expected THEN
    RAISE EXCEPTION 'O pacote/compras custam % po, acima do limite de % po.',v_cost,v_expected;
  END IF;
  v_remaining:=GREATEST(0,v_expected-v_cost);
  FOREACH v_face IN ARRAY ARRAY[]::JSONB[] LOOP NULL; END LOOP;
  v_faces:=ARRAY[]::INTEGER[];
  IF p_metodo='ouro' THEN
    SELECT array_agg((value#>>'{}')::INTEGER ORDER BY ordinality) INTO v_faces
    FROM jsonb_array_elements(p_resultados) WITH ORDINALITY;
  END IF;

  FOR v_item IN SELECT value FROM jsonb_array_elements(v_items) LOOP
    SELECT * INTO v_equipment FROM public.srd_equipment WHERE id=v_item->>'id';
    -- Initial equipment always enters the backpack unequipped.
    -- The player decides which weapon, armor and shield to equip after creation.
    v_slot:=public.srd35_equipment_slot(v_equipment.categoria,v_equipment.nome);
    v_equipped:=FALSE;
    INSERT INTO public.srd_character_equipment(character_id,equipment_id,quantidade,equipado)
    VALUES(v_character.id::TEXT,v_equipment.id,(v_item->>'quantidade')::INTEGER,v_equipped)
    ON CONFLICT(character_id,equipment_id) DO UPDATE SET
      quantidade=public.srd_character_equipment.quantidade+EXCLUDED.quantidade,
      equipado=public.srd_character_equipment.equipado OR EXCLUDED.equipado;
  END LOOP;

  v_saved:=jsonb_build_object('concluido',TRUE,'metodo',p_metodo,'resultados',to_jsonb(v_faces),
    'ouro_inicial',v_expected,'valor_itens',v_cost,'ouro_restante',v_remaining,
    'pacote_id',CASE WHEN p_metodo='pacote' THEN v_class ELSE NULL END,'itens',v_items);
  UPDATE public.srd_character_sheets SET ouro=v_remaining,equipamento_inicial=v_saved
  WHERE character_id=v_character.id;
  UPDATE public.characters SET ouro=FLOOR(v_remaining)::INTEGER WHERE id=v_character.id;
  RETURN v_saved;
END;
$function$
;

-- finalizar_exclusao_campanha_propria(p_campaign_id bigint)
CREATE OR REPLACE FUNCTION public.finalizar_exclusao_campanha_propria(p_campaign_id bigint)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
  SELECT priv.finalizar_exclusao_campanha_propria(p_campaign_id);
$function$
;

-- forget_spell(p_char bigint, p_spell bigint)
CREATE OR REPLACE FUNCTION public.forget_spell(p_char bigint, p_spell bigint)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare c public.characters;
begin
  select * into c from public.characters where id = p_char;
  if not found then raise exception 'Personagem inexistente.'; end if;
  if c.user_id is distinct from auth.uid() and public.my_role(c.campaign_id) is distinct from 'GM' then
    raise exception 'Sem permissão.';
  end if;
  delete from public.character_spells where character_id = p_char and spell_id = p_spell;
end $function$
;

-- gm_get_code(cid bigint)
CREATE OR REPLACE FUNCTION public.gm_get_code(cid bigint)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
begin perform priv.need_gm(cid); return (select code from campaign_codes where campaign_id = cid); end $function$
;

-- gm_grant(cid bigint, p_char bigint, p_ouro integer, p_xp integer, p_item text, p_qtd integer)
CREATE OR REPLACE FUNCTION public.gm_grant(cid bigint, p_char bigint, p_ouro integer DEFAULT NULL::integer, p_xp integer DEFAULT NULL::integer, p_item text DEFAULT NULL::text, p_qtd integer DEFAULT 1)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare c characters;
begin
  perform priv.need_gm(cid);
  select * into c from characters where id = p_char and campaign_id = cid for update;
  if not found then raise exception 'Personagem não encontrado nesta mesa.'; end if;
  if p_ouro is null and p_xp is null and p_item is null then raise exception 'Nada a conceder.'; end if;
  if p_ouro is not null then
    if p_ouro = 0 or abs(p_ouro) > 1000000 or c.ouro + p_ouro < 0 then raise exception 'Quantia de ouro inválida (saldo não pode ficar negativo).'; end if;
    update characters set ouro = ouro + p_ouro where id = p_char;
    perform priv.log(cid, 'OURO_CONCEDIDO', jsonb_build_object('char', p_char, 'delta', p_ouro, 'por', auth.uid()));
  end if;
  if p_xp is not null then
    if p_xp < 1 or p_xp > 1000000 then raise exception 'XP deve ser um inteiro positivo.'; end if;
    update characters set xp = xp + p_xp where id = p_char;
    perform priv.log(cid, 'XP_CONCEDIDO', jsonb_build_object('char', p_char, 'xp', p_xp, 'por', auth.uid()));
  end if;
  if p_item is not null then
    if not exists (select 1 from items where id = p_item) or p_qtd not between 1 and 99 then raise exception 'Item ou quantidade inválidos.'; end if;
    insert into inventory values (p_char, p_item, p_qtd, false) on conflict (character_id, item_id) do update set qtd = inventory.qtd + excluded.qtd;
    perform priv.log(cid, 'ITEM_CONCEDIDO', jsonb_build_object('char', p_char, 'item', p_item, 'qtd', p_qtd, 'por', auth.uid()));
  end if;
end $function$
;

-- gm_kick(cid bigint, p_user uuid)
CREATE OR REPLACE FUNCTION public.gm_kick(cid bigint, p_user uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
begin
  perform priv.need_owner(cid);
  if p_user = auth.uid() then raise exception 'Você não pode se expulsar.'; end if;
  if not exists (select 1 from public.members where campaign_id = cid and user_id = p_user) then
    raise exception 'Esse usuário não está na mesa.';
  end if;
  delete from public.members where campaign_id = cid and user_id = p_user;
  perform priv.log(cid, 'GM_ACTION', jsonb_build_object('acao', 'expulsar', 'alvo', p_user, 'por', auth.uid()));
  return jsonb_build_object('ok', true);
end $function$
;

-- gm_reopen_sheet(p_char bigint, p_motivo text)
CREATE OR REPLACE FUNCTION public.gm_reopen_sheet(p_char bigint, p_motivo text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare c public.characters;
begin
  select * into c from public.characters where id = p_char;
  if not found then raise exception 'Personagem inexistente.'; end if;
  perform priv.need_gm(c.campaign_id);
  if char_length(coalesce(trim(p_motivo), '')) < 3 then raise exception 'Informe o motivo.'; end if;
  update public.character_sheets set ready = false, preserve_pv = true, updated_at = now()
    where character_id = p_char;
  perform priv.log(c.campaign_id, 'GM_ACTION',
    jsonb_build_object('acao', 'reabrir_ficha', 'personagem', p_char, 'motivo', trim(p_motivo), 'por', auth.uid()));
  return public.calc_sheet(p_char);
end $function$
;

-- gm_set_bonus(p_char bigint, p_ca integer, p_rm integer, p_motivo text)
CREATE OR REPLACE FUNCTION public.gm_set_bonus(p_char bigint, p_ca integer, p_rm integer, p_motivo text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare c public.characters;
begin
  select * into c from public.characters where id = p_char;
  if not found then raise exception 'Personagem inexistente.'; end if;
  perform priv.need_gm(c.campaign_id);
  if char_length(coalesce(trim(p_motivo), '')) < 3 then raise exception 'Informe o motivo.'; end if;
  if p_ca not between -10 and 10 or p_rm not between -10 and 10 then
    raise exception 'Bônus fora do limite (−10 a +10).'; end if;
  update public.character_sheets set bonus_ca = p_ca, bonus_rm = p_rm, updated_at = now()
    where character_id = p_char;
  perform priv.log(c.campaign_id, 'GM_ACTION',
    jsonb_build_object('acao', 'bonus_ca_rm', 'personagem', p_char, 'ca', p_ca, 'rm', p_rm, 'motivo', trim(p_motivo), 'por', auth.uid()));
  return public.calc_sheet(p_char);
end $function$
;

-- gm_set_code(cid bigint, p_code text)
CREATE OR REPLACE FUNCTION public.gm_set_code(cid bigint, p_code text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
begin
  perform priv.need_owner(cid);
  if p_code is null or p_code !~ '^[0-9]{4}$' then raise exception 'O código deve ter 4 dígitos.'; end if;
  begin update campaign_codes set code = p_code where campaign_id = cid;
  exception when unique_violation then raise exception 'Código indisponível.'; end;
  perform priv.log(cid, 'CODIGO_ALTERADO', jsonb_build_object('por', auth.uid()));
end $function$
;

-- gm_set_role(cid bigint, p_username text, p_role text)
CREATE OR REPLACE FUNCTION public.gm_set_role(cid bigint, p_username text, p_role text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare t uuid;
begin
  perform priv.need_owner(cid);
  if p_role not in ('PLAYER', 'OBSERVER') then raise exception 'Papel inválido.'; end if;
  select m.user_id into t from members m join profiles p on p.id = m.user_id where m.campaign_id = cid and lower(p.username) = lower(p_username);
  if t is null or t = auth.uid() then raise exception 'Participante inválido.'; end if;
  update members set role = p_role where campaign_id = cid and user_id = t;
  perform priv.log(cid, 'PAPEL_ALTERADO', jsonb_build_object('alvo', t, 'role', p_role));
end $function$
;

-- gm_transfer(cid bigint, p_username text, p_confirmar boolean)
CREATE OR REPLACE FUNCTION public.gm_transfer(cid bigint, p_username text, p_confirmar boolean)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare t uuid;
begin
  perform priv.need_owner(cid);
  if p_confirmar is not true then raise exception 'Confirmação explícita obrigatória.'; end if;
  select m.user_id into t from members m join profiles p on p.id = m.user_id where m.campaign_id = cid and lower(p.username) = lower(p_username);
  if t is null or t = auth.uid() then raise exception 'Participante inválido.'; end if;
  update members set role = 'PLAYER' where campaign_id = cid and user_id = auth.uid();
  update members set role = 'GM' where campaign_id = cid and user_id = t;
  update campaigns set owner_id = t where id = cid;
  perform priv.log(cid, 'PROPRIEDADE_TRANSFERIDA', jsonb_build_object('de', auth.uid(), 'para', t));
end $function$
;

-- handle_new_user()
CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
BEGIN
  -- Tenta inserir o perfil. Se falhar, o cadastro do usuário NÃO é cancelado.
  BEGIN
    INSERT INTO public.profiles (id, username)
    VALUES (
      new.id,
      -- Pega o 'username' passado no signUp options.data, ou usa o email como fallback
      COALESCE(new.raw_user_meta_data->>'username', split_part(new.email, '@', 1))
    );
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Erro ao criar perfil para %: %', new.id, SQLERRM;
  END;
  RETURN new;
END;
$function$
;

-- hex_cost(cid bigint, x1 integer, y1 integer, x2 integer, y2 integer)
CREATE OR REPLACE FUNCTION public.hex_cost(cid bigint, x1 integer, y1 integer, x2 integer, y2 integer)
 RETURNS integer
 LANGUAGE plpgsql
 STABLE
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare n int := public.hex_dist(x1, y1, x2, y2); i int; total int := 0; col int; lin int;
  px double precision := x1 - ((y1 - (y1 & 1)) / 2); pz double precision := y1; qx double precision := x2 - ((y2 - (y2 & 1)) / 2); qz double precision := y2;
  t double precision; fx double precision; fy double precision; fz double precision; rx double precision; ry double precision; rz double precision;
  dx double precision; dy double precision; dz double precision;
begin
  for i in 1..n loop
    t := i::double precision / n; fx := px + (qx - px) * t + 1e-6; fz := pz + (qz - pz) * t + 1e-6; fy := -fx - fz;
    rx := floor(fx + 0.5); ry := floor(fy + 0.5); rz := floor(fz + 0.5);
    dx := abs(rx - fx); dy := abs(ry - fy); dz := abs(rz - fz);
    if dx > dy and dx > dz then rx := -ry - rz; elsif dy > dz then ry := -rx - rz; else rz := -rx - ry; end if;
    lin := rz::int; col := rx::int + ((lin - (lin & 1)) / 2);
    total := total + case when exists (select 1 from terrain where campaign_id = cid and x = col and y = lin) then 2 else 1 end;
  end loop;
  return total;
end $function$
;

-- hex_dist(x1 integer, y1 integer, x2 integer, y2 integer)
CREATE OR REPLACE FUNCTION public.hex_dist(x1 integer, y1 integer, x2 integer, y2 integer)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  select greatest(abs((x1 - ((y1 - (y1 & 1)) / 2)) - (x2 - ((y2 - (y2 & 1)) / 2))),
                  abs((-(x1 - ((y1 - (y1 & 1)) / 2)) - y1) - (-(x2 - ((y2 - (y2 & 1)) / 2)) - y2)),
                  abs(y1 - y2)) $function$
;

-- iniciar_ataque_iterativo_npc_srd(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text)
CREATE OR REPLACE FUNCTION public.iniciar_ataque_iterativo_npc_srd(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO ''
AS $function$ select priv.npc_iniciar_ataque_iterativo_impl($1,$2,$3,$4,$5,$6,$7); $function$
;

-- iniciar_ataque_iterativo_npc_srd(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text, p_power_attack_penalty integer)
CREATE OR REPLACE FUNCTION public.iniciar_ataque_iterativo_npc_srd(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text, p_power_attack_penalty integer)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO ''
AS $function$ SELECT priv.npc_iniciar_ataque_iterativo_impl($1,$2,$3,$4,$5,$6,$7,$8); $function$
;

-- iniciar_iniciativa(p_campaign_id bigint, p_expected_character_ids text[])
CREATE OR REPLACE FUNCTION public.iniciar_iniciativa(p_campaign_id bigint, p_expected_character_ids text[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
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
$function$
;

-- iniciar_iniciativa_com_dados(p_campaign_id bigint, p_expected_character_ids text[], p_request_id text, p_gm_d20_results jsonb)
CREATE OR REPLACE FUNCTION public.iniciar_iniciativa_com_dados(p_campaign_id bigint, p_expected_character_ids text[], p_request_id text, p_gm_d20_results jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
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

  IF EXISTS (
    SELECT 1
    FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(v_scene->'tokens') = 'array'
           THEN v_scene->'tokens' ELSE '[]'::JSONB END
    ) AS linked(token)
    WHERE linked.token->>'tipo' = 'npc'
      AND NULLIF(BTRIM(linked.token->>'sourceCharacterId'), '') IS NOT NULL
      AND NOT EXISTS (
        SELECT 1
        FROM public.characters AS source_character
        JOIN public.srd_character_sheets AS source_sheet
          ON source_sheet.character_id = source_character.id
        WHERE source_character.id::TEXT = BTRIM(linked.token->>'sourceCharacterId')
          AND source_character.user_id = auth.uid()
      )
  ) THEN
    RAISE EXCEPTION 'A ficha de origem de um NPC vinculado não existe, não é SRD ou não pertence ao Mestre autenticado.';
  END IF;

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
      ON character.id::TEXT = CASE
        WHEN candidate.token->>'tipo' = 'npc'
         AND NULLIF(BTRIM(candidate.token->>'sourceCharacterId'), '') IS NOT NULL
          THEN BTRIM(candidate.token->>'sourceCharacterId')
        ELSE candidate.token->>'id'
      END
     AND (
       (candidate.token->>'tipo' = 'npc'
        AND NULLIF(BTRIM(candidate.token->>'sourceCharacterId'), '') IS NOT NULL
        AND character.user_id = auth.uid())
       OR
       ((candidate.token->>'tipo' <> 'npc'
         OR NULLIF(BTRIM(candidate.token->>'sourceCharacterId'), '') IS NULL)
        AND character.campaign_id = p_campaign_id)
     )
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
      FLOOR((
        COALESCE(
          NULLIF(token.linked_attributes->>'DES','')::NUMERIC,
          NULLIF(token.token->>'dexMod','')::NUMERIC,
          10
        ) - 10
      ) / 2)::INTEGER AS dex_mod,
      COALESCE(
        CASE WHEN token.token->>'bonusIniciativa' ~ '^-?[0-9]{1,2}$'
             THEN (token.token->>'bonusIniciativa')::INTEGER END,
        CASE WHEN token.token->>'bonus_iniciativa' ~ '^-?[0-9]{1,2}$'
             THEN (token.token->>'bonus_iniciativa')::INTEGER END,
        priv.srd_passive_feat_modifier(token.linked_character_id,'initiative'),
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
             calculated.dex_mod DESC, calculated.nome ASC, calculated.id ASC
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
  IF cardinality(v_expected) = 0 THEN
    PERFORM priv.srd_start_combat_flatfooted(p_campaign_id,v_order,0);
  END IF;

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
$function$
;

-- iniciar_iniciativa_com_pedido(p_campaign_id bigint, p_expected_character_ids text[], p_request_id text)
CREATE OR REPLACE FUNCTION public.iniciar_iniciativa_com_pedido(p_campaign_id bigint, p_expected_character_ids text[], p_request_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_expected TEXT[];
  v_combat JSONB;
  v_mestre TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  SELECT COALESCE(array_agg(DISTINCT BTRIM(requested.character_id) ORDER BY BTRIM(requested.character_id)), ARRAY[]::TEXT[])
  INTO v_expected
  FROM unnest(COALESCE(p_expected_character_ids, ARRAY[]::TEXT[])) AS requested(character_id)
  WHERE NULLIF(BTRIM(requested.character_id), '') IS NOT NULL;

  IF cardinality(v_expected) > 0 AND NULLIF(BTRIM(p_request_id), '') IS NULL THEN
    RAISE EXCEPTION 'O identificador do pedido de iniciativa é obrigatório.';
  END IF;

  -- Esta função valida o papel GM, a campanha, o estado COMBATE e as fichas.
  v_combat := public.iniciar_iniciativa(p_campaign_id, v_expected);

  IF cardinality(v_expected) > 0 THEN
    SELECT COALESCE(NULLIF(BTRIM(p.username), ''), 'Mestre')
    INTO v_mestre
    FROM public.profiles AS p
    WHERE p.id = auth.uid();
    v_mestre := COALESCE(v_mestre, 'Mestre');

    INSERT INTO public.campaign_log (campaign_id, type, visibilidade, data)
    VALUES (
      p_campaign_id,
      'test_request',
      'PUBLIC',
      jsonb_build_object(
        'tipo', 'Iniciativa (DES)',
        'alvos', to_jsonb(v_expected),
        'mestre', v_mestre,
        'mestre_id', auth.uid(),
        'request_id', BTRIM(p_request_id)
      )
    );
  END IF;

  RETURN v_combat;
END;
$function$
;

-- iniciar_sequencia_ataque_iterativo_srd(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid)
CREATE OR REPLACE FUNCTION public.iniciar_sequencia_ataque_iterativo_srd(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$ SELECT priv.iniciar_sequencia_ataque_iterativo_srd_5_impl(p_campaign_id,p_character_id,p_target_token_id,p_attack_type,p_weapon_instance_id); $function$
;

-- iniciar_sequencia_ataque_iterativo_srd(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text)
CREATE OR REPLACE FUNCTION public.iniciar_sequencia_ataque_iterativo_srd(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$ SELECT priv.iniciar_sequencia_ataque_iterativo_srd_7_impl(p_campaign_id,p_character_id,p_target_token_id,p_attack_type,p_weapon_instance_id,p_weapon_hand_slot,p_weapon_end); $function$
;

-- iniciar_sequencia_ataque_iterativo_srd(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text, p_power_attack_penalty integer)
CREATE OR REPLACE FUNCTION public.iniciar_sequencia_ataque_iterativo_srd(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text, p_power_attack_penalty integer)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$ SELECT priv.iniciar_sequencia_ataque_iterativo_srd_8_impl(p_campaign_id,p_character_id,p_target_token_id,p_attack_type,p_weapon_instance_id,p_weapon_hand_slot,p_weapon_end,p_power_attack_penalty); $function$
;

-- join_campaign(p_code text)
CREATE OR REPLACE FUNCTION public.join_campaign(p_code text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_uid UUID := auth.uid();
  v_lock_key TEXT := 'join:' || COALESCE(auth.uid()::TEXT, '');
  v_campaign_id BIGINT;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Não autenticado.'; END IF;
  IF p_code IS NULL OR p_code !~ '^[0-9]{4}$' THEN
    RETURN JSONB_BUILD_OBJECT('ok', FALSE, 'erro', 'Código inválido.');
  END IF;
  IF priv.locked(v_lock_key) THEN
    RETURN JSONB_BUILD_OBJECT('ok', FALSE, 'erro', 'Muitas tentativas. Aguarde 15 minutos.');
  END IF;
  SELECT cc.campaign_id INTO v_campaign_id
  FROM public.campaign_codes AS cc
  JOIN public.campaigns AS c ON c.id = cc.campaign_id
  WHERE cc.code = p_code AND c.active;
  IF v_campaign_id IS NULL THEN
    PERFORM priv.fail(v_lock_key);
    RETURN JSONB_BUILD_OBJECT('ok', FALSE, 'erro', 'Código inválido.');
  END IF;
  PERFORM priv.clear(v_lock_key);
  INSERT INTO public.members (campaign_id, user_id, role)
  VALUES (v_campaign_id, v_uid, 'PLAYER')
  ON CONFLICT (campaign_id, user_id) DO NOTHING;
  PERFORM priv.log(v_campaign_id, 'ENTRADA', JSONB_BUILD_OBJECT('user', v_uid));
  RETURN JSONB_BUILD_OBJECT('ok', TRUE, 'id', v_campaign_id, 'papel', public.my_role(v_campaign_id));
END
$function$
;

-- learn_abilities_for_level(p_char bigint, p_nivel integer)
CREATE OR REPLACE FUNCTION public.learn_abilities_for_level(p_char bigint, p_nivel integer)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  cls text;
  reg record;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.characters c
    WHERE c.id = p_char
      AND (c.user_id = auth.uid() OR public.my_role(c.campaign_id) = 'GM')
  ) THEN
    RAISE EXCEPTION 'Sem permissão para atualizar esta ficha.';
  END IF;

  SELECT classe INTO cls
  FROM public.character_sheets
  WHERE character_id = p_char;

  IF cls IS NULL THEN
    RETURN;
  END IF;

  FOR reg IN
    SELECT id, nivel
    FROM public.abilities
    WHERE classe = cls
      AND nivel <= p_nivel
      AND id NOT IN (
        SELECT ability_id
        FROM public.character_abilities
        WHERE character_id = p_char
      )
  LOOP
    INSERT INTO public.character_abilities(character_id, ability_id, aprendida_em_nivel)
    VALUES (p_char, reg.id, reg.nivel);
  END LOOP;
END;
$function$
;

-- learn_spell(p_char bigint, p_spell bigint)
CREATE OR REPLACE FUNCTION public.learn_spell(p_char bigint, p_spell bigint)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare s public.spells; c public.characters; sh public.character_sheets; cls text; nivel int; circ_max int;
begin
  select * into c from public.characters where id = p_char;
  if not found then raise exception 'Personagem inexistente.'; end if;
  if c.user_id is distinct from auth.uid() and public.my_role(c.campaign_id) is distinct from 'GM' then
    raise exception 'Sem permissão.';
  end if;
  select * into sh from public.character_sheets where character_id = p_char;
  if sh.classe is null then raise exception 'Personagem sem classe.'; end if;
  select * into s from public.spells where id = p_spell;
  if not found then raise exception 'Magia inexistente.'; end if;
  if not (sh.classe = any(s.classes)) then
    raise exception 'A classe % não conjura %.', sh.classe, s.nome;
  end if;
  nivel := public.level_from_xp(c.xp);
  circ_max := least(5, greatest(1, ceil(nivel::numeric / 4)::int));
  if s.circulo > circ_max then
    raise exception 'Círculo % indisponível no nível % (máx: %).', s.circulo, nivel, circ_max;
  end if;
  insert into public.character_spells(character_id, spell_id, aprendida_em_nivel)
  values (p_char, p_spell, nivel)
  on conflict do nothing;
  perform priv.log(c.campaign_id, 'MAGIA_APRENDIDA', jsonb_build_object('char', p_char, 'spell', p_spell, 'por', auth.uid()));
end $function$
;

-- leave_campaign(cid bigint)
CREATE OR REPLACE FUNCTION public.leave_campaign(cid bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare papel text;
begin
  papel := public.my_role(cid);
  if papel is null then raise exception 'Você não participa desta mesa.'; end if;
  if papel = 'GM' then raise exception 'O Mestre não pode sair; transfira a mesa antes.'; end if;
  delete from public.members where campaign_id = cid and user_id = auth.uid();
  perform priv.log(cid, 'SAIU', jsonb_build_object('user', auth.uid()));
  return jsonb_build_object('ok', true);
end $function$
;

-- level_from_xp(p_xp integer)
CREATE OR REPLACE FUNCTION public.level_from_xp(p_xp integer)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  select public.nivel_de_xp(p_xp)
$function$
;

-- limpar_ficha_srd_ao_excluir_personagem()
CREATE OR REPLACE FUNCTION public.limpar_ficha_srd_ao_excluir_personagem()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
BEGIN
  DELETE FROM public.srd_character_sheets
  WHERE character_id::TEXT = OLD.id::TEXT;
  RETURN OLD;
END;
$function$
;

-- limpar_inventario_srd_ao_excluir_personagem()
CREATE OR REPLACE FUNCTION public.limpar_inventario_srd_ao_excluir_personagem()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
BEGIN
  DELETE FROM public.srd_character_equipment WHERE character_id = OLD.id::TEXT;
  RETURN OLD;
END;
$function$
;

-- lobby_list()
CREATE OR REPLACE FUNCTION public.lobby_list()
 RETURNS TABLE(id bigint, name text, mestre text, cidade text, state text, participantes bigint, meu_papel text)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
  select c.id, c.name, p.username, l.nome, c.state, (select count(*) from members m where m.campaign_id = c.id),
         (select m.role from members m where m.campaign_id = c.id and m.user_id = auth.uid())
  from campaigns c join profiles p on p.id = c.owner_id left join locations l on l.id = c.location_id
  where auth.uid() is not null and c.active order by c.created_at desc $function$
;

-- lobby_list_v2()
CREATE OR REPLACE FUNCTION public.lobby_list_v2()
 RETURNS TABLE(id bigint, name text, mestre text, cidade text, state text, participantes bigint, meu_papel text, briefing text, capa_url text, codigo_convite text)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
  SELECT campaign.id, campaign.name, profile.username, location.nome, campaign.state,
         COUNT(DISTINCT member.user_id)::BIGINT,
         CASE WHEN current_member.user_id IS NULL THEN NULL
              WHEN current_member.user_id = campaign.owner_id THEN 'GM'
              ELSE 'PLAYER' END,
         campaign.briefing, campaign.capa_url,
         CASE WHEN current_member.user_id = campaign.owner_id THEN code.code ELSE NULL END
  FROM public.campaigns AS campaign
  LEFT JOIN public.profiles AS profile ON profile.id = campaign.owner_id
  LEFT JOIN public.locations AS location ON location.id = campaign.location_id
  LEFT JOIN public.members AS member ON member.campaign_id = campaign.id
  LEFT JOIN public.members AS current_member
    ON current_member.campaign_id = campaign.id AND current_member.user_id = (SELECT auth.uid())
  LEFT JOIN public.campaign_codes AS code ON code.campaign_id = campaign.id
  WHERE (SELECT auth.uid()) IS NOT NULL AND campaign.active
  GROUP BY campaign.id, campaign.name, profile.username, location.nome, campaign.state,
           current_member.user_id, campaign.owner_id, campaign.briefing, campaign.capa_url, code.code
  ORDER BY campaign.id DESC
$function$
;

-- long_rest(p_char bigint)
CREATE OR REPLACE FUNCTION public.long_rest(p_char bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare c public.characters; s public.character_sheets; pv_max int; pm_max int;
begin
  select * into c from public.characters where id = p_char;
  if not found then raise exception 'Personagem inexistente.'; end if;
  if c.user_id is distinct from auth.uid() and public.my_role(c.campaign_id) is distinct from 'GM' then raise exception 'Sem permissão.'; end if;
  select * into s from public.character_sheets where character_id = p_char for update;
  pv_max := public.calc_pv(s.classe, (s.atributos->>'CON')::int);
  pm_max := public.calc_pm(s.classe, (s.atributos->>'INT')::int);
  update public.character_sheets
    set pv_atual = pv_max, pm_atual = pm_max,
        death_state = '{"sucessos":0,"falhas":0,"estabilizado":false,"morto":false}'::jsonb
    where character_id = p_char;
  perform priv.log(c.campaign_id, 'DESCANSO_LONGO', jsonb_build_object('char', p_char));
  return jsonb_build_object('pv', pv_max, 'pm', pm_max);
end $function$
;

-- media_gc(cid bigint)
CREATE OR REPLACE FUNCTION public.media_gc(cid bigint)
 RETURNS text[]
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare paths text[];
begin
  perform priv.need_gm(cid);
  with d as (delete from media m where m.campaign_id = cid and not exists (select 1 from layers l where l.media_id = m.id) returning m.path) select coalesce(array_agg(path), '{}') into paths from d;
  return paths;   -- o navegador do Mestre remove estes arquivos do Storage
end $function$
;

-- move_token(p_token bigint, p_x integer, p_y integer)
CREATE OR REPLACE FUNCTION public.move_token(p_token bigint, p_x integer, p_y integer)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE t public.tokens; r text; owner_id uuid;
BEGIN
  SELECT * INTO t FROM public.tokens WHERE id=p_token FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Token inexistente.'; END IF;
  IF p_x IS NULL OR p_y IS NULL OR p_x<0 OR p_y<0 THEN RAISE EXCEPTION 'Posição inválida.'; END IF;
  r:=public.my_role(t.campaign_id);
  IF r IS NULL THEN RAISE EXCEPTION 'Você não participa desta mesa.'; END IF;
  IF r='PLAYER' THEN
    SELECT c.user_id INTO owner_id FROM public.characters c WHERE c.id=t.character_id;
    IF owner_id IS DISTINCT FROM auth.uid() THEN RAISE EXCEPTION 'Esse token não é seu.'; END IF;
  ELSIF r<>'GM' THEN
    RAISE EXCEPTION 'Observadores não movem tokens.';
  END IF;
  IF EXISTS (SELECT 1 FROM public.tokens x WHERE x.campaign_id=t.campaign_id AND x.col=p_x AND x.row=p_y AND x.id<>t.id) THEN
    RAISE EXCEPTION 'Casa ocupada.';
  END IF;
  UPDATE public.tokens SET col=p_x,row=p_y,updated_at=now() WHERE id=t.id;
END $function$
;

-- mover_combatente_iniciativa(p_campaign_id bigint, p_indice integer, p_direcao integer)
CREATE OR REPLACE FUNCTION public.mover_combatente_iniciativa(p_campaign_id bigint, p_indice integer, p_direcao integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
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
$function$
;

-- mover_token_gm_cba_srd(p_campaign_id bigint, p_token_id text, p_grid_x integer, p_grid_y integer)
CREATE OR REPLACE FUNCTION public.mover_token_gm_cba_srd(p_campaign_id bigint, p_token_id text, p_grid_x integer, p_grid_y integer)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$ select priv.mover_token_gm_cba_srd_impl(p_campaign_id,p_token_id,p_grid_x,p_grid_y); $function$
;

-- mover_token_player_cba(p_campaign_id bigint, p_character_id text, p_grid_x integer, p_grid_y integer)
CREATE OR REPLACE FUNCTION public.mover_token_player_cba(p_campaign_id bigint, p_character_id text, p_grid_x integer, p_grid_y integer)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$ SELECT priv.mover_token_player_cba_impl(p_campaign_id,p_character_id,p_grid_x,p_grid_y); $function$
;

-- my_role(cid bigint)
CREATE OR REPLACE FUNCTION public.my_role(cid bigint)
 RETURNS text
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$ select role from public.members where campaign_id = cid and user_id = auth.uid() $function$
;

-- nivel_de_xp(p_xp integer)
CREATE OR REPLACE FUNCTION public.nivel_de_xp(p_xp integer)
 RETURNS integer
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare n int := 1;
begin while n < 20 and p_xp >= 500 * (n + 1) * n loop n := n + 1; end loop; return n; end $function$
;

-- preparar_exclusao_campanha_propria(p_campaign_id bigint)
CREATE OR REPLACE FUNCTION public.preparar_exclusao_campanha_propria(p_campaign_id bigint)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
  SELECT priv.preparar_exclusao_campanha_propria(p_campaign_id);
$function$
;

-- registrar_iniciativa(p_campaign_id bigint, p_personagem_id text, p_nome text, p_valor integer)
CREATE OR REPLACE FUNCTION public.registrar_iniciativa(p_campaign_id bigint, p_personagem_id text, p_nome text, p_valor integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
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
  v_dex_mod INTEGER := 0;
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

  SELECT FLOOR((COALESCE(NULLIF(sheet.atributos->>'DES','')::NUMERIC,10)-10)/2)::INTEGER
    INTO v_dex_mod
    FROM public.srd_character_sheets AS sheet
   WHERE sheet.character_id::TEXT=p_personagem_id;
  v_dex_mod:=COALESCE(v_dex_mod,0);

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
  IF EXISTS (
    SELECT 1 FROM jsonb_array_elements(v_order) AS existing(entry)
    WHERE existing.entry->>'id'=p_personagem_id AND COALESCE((existing.entry->>'is_monster')::BOOLEAN,FALSE)=FALSE
  ) THEN
    SELECT existing.entry INTO v_entry
    FROM jsonb_array_elements(v_order) AS existing(entry)
    WHERE existing.entry->>'id'=p_personagem_id AND COALESCE((existing.entry->>'is_monster')::BOOLEAN,FALSE)=FALSE
    LIMIT 1;
    IF COALESCE(NULLIF(v_entry->>'valor','')::INTEGER,0)<>p_valor THEN
      RAISE EXCEPTION 'Esta ficha já registrou sua iniciativa nesta rodada; uma nova rolagem não é permitida.';
    END IF;
    RETURN v_data;
  END IF;
  v_round := CASE WHEN COALESCE(v_data->>'round','') ~ '^[0-9]+$' THEN GREATEST(1,(v_data->>'round')::INTEGER) ELSE 1 END;
  IF COALESCE((v_data->>'active')::BOOLEAN,FALSE) THEN
    SELECT old_order.entry->>'id' INTO v_current_id
    FROM jsonb_array_elements(v_order) WITH ORDINALITY AS old_order(entry, ordinality)
    WHERE old_order.ordinality = GREATEST(0,COALESCE((v_data->>'current_turn')::INTEGER,0))+1
    LIMIT 1;
  END IF;

  v_entry := jsonb_build_object('id',p_personagem_id,'nome',LEFT(COALESCE(NULLIF(p_nome,''),'Aventureiro'),120),
    'valor',p_valor,'dex_mod',v_dex_mod,'is_monster',FALSE);
  SELECT COALESCE(jsonb_agg(q.entry ORDER BY COALESCE(NULLIF(q.entry->>'valor','')::NUMERIC,0) DESC,
                            COALESCE(NULLIF(q.entry->>'dex_mod','')::NUMERIC,0) DESC,
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
  IF v_active AND NOT COALESCE((v_data->>'active')::boolean,false) THEN
   PERFORM priv.srd_start_combat_flatfooted(p_campaign_id,v_sorted,v_current_turn);
  END IF;
  RETURN v_next;
END;
$function$
;

-- registrar_iniciativa_d20(p_campaign_id bigint, p_personagem_id text, p_d20 integer)
CREATE OR REPLACE FUNCTION public.registrar_iniciativa_d20(p_campaign_id bigint, p_personagem_id text, p_d20 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_role TEXT;
  v_state TEXT;
  v_data JSONB;
  v_order JSONB;
  v_expected JSONB;
  v_name TEXT;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_dex INTEGER;
  v_dex_mod INTEGER;
  v_feat_bonus INTEGER := 0;
  v_effect_bonus INTEGER := 0;
  v_total INTEGER;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_d20 IS NULL OR p_d20 NOT BETWEEN 1 AND 20 THEN
    RAISE EXCEPTION 'A iniciativa exige o resultado manual de um D20 entre 1 e 20.';
  END IF;

  SELECT role INTO v_role FROM public.members
  WHERE campaign_id=p_campaign_id AND user_id=auth.uid() LIMIT 1;
  IF v_role IS DISTINCT FROM 'PLAYER' THEN RAISE EXCEPTION 'Somente um jogador pode registrar sua iniciativa.'; END IF;

  SELECT nome INTO v_name FROM public.characters
  WHERE id::TEXT=BTRIM(p_personagem_id) AND campaign_id=p_campaign_id AND user_id=auth.uid();
  IF NOT FOUND THEN RAISE EXCEPTION 'A ficha não pertence ao jogador autenticado.'; END IF;

  SELECT state,combat_data INTO v_state,v_data
  FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND OR UPPER(COALESCE(v_state,''))<>'COMBATE' OR v_data IS NULL THEN
    RAISE EXCEPTION 'Não há solicitação de iniciativa ativa nesta campanha.';
  END IF;
  v_expected:=CASE WHEN jsonb_typeof(v_data->'expected_character_ids')='array' THEN v_data->'expected_character_ids' ELSE '[]'::JSONB END;
  IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements_text(v_expected) e(id) WHERE e.id=BTRIM(p_personagem_id)) THEN
    RAISE EXCEPTION 'Esta ficha não faz parte da solicitação de iniciativa atual.';
  END IF;
  v_order:=CASE WHEN jsonb_typeof(v_data->'turn_order')='array' THEN v_data->'turn_order' ELSE '[]'::JSONB END;
  IF EXISTS(SELECT 1 FROM jsonb_array_elements(v_order) e(value)
    WHERE e.value->>'id'=BTRIM(p_personagem_id)
      AND COALESCE((e.value->>'is_monster')::BOOLEAN,FALSE)=FALSE) THEN
    RETURN v_data;
  END IF;

  SELECT * INTO v_sheet FROM public.srd_character_sheets
  WHERE character_id::TEXT=BTRIM(p_personagem_id) FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD necessária para calcular iniciativa.'; END IF;

  v_dex:=COALESCE(
    CASE WHEN COALESCE(v_sheet.atributos->>'DES','') ~ '^-?[0-9]{1,2}$' THEN (v_sheet.atributos->>'DES')::INTEGER END,
    CASE WHEN COALESCE(v_sheet.atributos->>'destreza','') ~ '^-?[0-9]{1,2}$' THEN (v_sheet.atributos->>'destreza')::INTEGER END,
    CASE WHEN COALESCE(v_sheet.atributos->>'dexterity','') ~ '^-?[0-9]{1,2}$' THEN (v_sheet.atributos->>'dexterity')::INTEGER END,
    CASE WHEN COALESCE(v_sheet.atributos->>'DEX','') ~ '^-?[0-9]{1,2}$' THEN (v_sheet.atributos->>'DEX')::INTEGER END
  );
  IF v_dex IS NULL OR v_dex NOT BETWEEN -20 AND 50 THEN RAISE EXCEPTION 'Destreza inválida na ficha.'; END IF;
  v_dex_mod:=CASE WHEN v_dex>=4 THEN FLOOR((v_dex-10)::NUMERIC/2)::INTEGER ELSE v_dex END;

  v_feat_bonus:=priv.srd_passive_feat_modifier(v_sheet.character_id,'initiative');

  v_effect_bonus:=COALESCE(priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_personagem_id),'initiative'),0);
  v_total:=p_d20+v_dex_mod+v_feat_bonus+v_effect_bonus;

  RETURN public.registrar_iniciativa(p_campaign_id,p_personagem_id,v_name,v_total);
END;
$function$
;

-- registrar_rolagem_ataque_iterativo_npc_srd(p_campaign_id bigint, p_sequence_id uuid, p_manual_d20 integer, p_idempotency_key uuid)
CREATE OR REPLACE FUNCTION public.registrar_rolagem_ataque_iterativo_npc_srd(p_campaign_id bigint, p_sequence_id uuid, p_manual_d20 integer, p_idempotency_key uuid)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO ''
AS $function$ select priv.npc_registrar_rolagem_ataque_iterativo_impl($1,$2,$3,$4); $function$
;

-- registrar_rolagem_ataque_iterativo_srd(p_campaign_id bigint, p_sequence_id uuid, p_manual_d20 integer, p_idempotency_key uuid)
CREATE OR REPLACE FUNCTION public.registrar_rolagem_ataque_iterativo_srd(p_campaign_id bigint, p_sequence_id uuid, p_manual_d20 integer, p_idempotency_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_user uuid := auth.uid();
  v_campaign public.campaigns%rowtype;
  v_sequence public.srd_attack_sequences%rowtype;
  v_attempt public.srd_attack_sequence_attempts%rowtype;
  v_pending public.srd_attack_sequence_attempts%rowtype;
  v_combat jsonb;
  v_turn integer;
  v_round integer;
  v_index integer;
  v_penalty integer;
begin
  if v_user is null then raise exception 'É necessário estar autenticado.'; end if;
  if p_manual_d20 is null or p_manual_d20 < 1 or p_manual_d20 > 20 or p_idempotency_key is null then
    raise exception 'A rolagem manual ou a chave de idempotência é inválida.';
  end if;
  select c.* into v_campaign from public.campaigns c where c.id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE' then
    raise exception 'A campanha não está em combate.';
  end if;
  select s.* into v_sequence from public.srd_attack_sequences s
  where s.id=p_sequence_id and s.campaign_id=p_campaign_id for update;
  if not found then raise exception 'Sequência de ataques não encontrada.'; end if;
  if v_sequence.created_by<>v_user then raise exception 'Somente quem iniciou a sequência pode registrar suas rolagens.'; end if;

  select a.* into v_attempt from public.srd_attack_sequence_attempts a where a.idempotency_key=p_idempotency_key;
  if found then
    if v_attempt.sequence_id<>p_sequence_id or v_attempt.manual_d20<>p_manual_d20 then
      raise exception 'A chave de idempotência já foi usada para outra rolagem.';
    end if;
    return jsonb_build_object('attempt_id',v_attempt.id,'sequence_id',v_attempt.sequence_id,
      'attempt_index',v_attempt.attempt_index,'manual_d20',v_attempt.manual_d20,
      'iterative_penalty',v_attempt.iterative_penalty,'status',v_attempt.status,'replayed',true);
  end if;
  if v_sequence.status<>'active' then raise exception 'Esta sequência não está ativa.'; end if;
  if v_sequence.next_attack_index>v_sequence.attacks_total then
    raise exception 'Todos os ataques desta sequência já receberam rolagem.';
  end if;
  select a.* into v_pending from public.srd_attack_sequence_attempts a
  where a.sequence_id=p_sequence_id
    and a.status in ('pending_resolution','critical_confirmation_pending','hit_pending_damage')
  order by a.attempt_index desc limit 1 for update;
  if found then
    raise exception 'Resolva completamente o ataque anterior antes de registrar o próximo.';
  end if;

  v_combat:=coalesce(v_campaign.combat_data,'{}'::jsonb);
  if lower(coalesce(v_combat->>'active','false'))<>'true'
    or coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$'
    or coalesce(v_combat->>'round','') !~ '^[0-9]+$' then
    raise exception 'A iniciativa não está ativa ou o turno mudou.';
  end if;
  v_turn:=(v_combat->>'current_turn')::integer;
  v_round:=greatest(1,(v_combat->>'round')::integer);
  if v_turn<>v_sequence.turn_index or v_round<>v_sequence.round_number then
    raise exception 'O turno ou a rodada mudou; a sequência não pode continuar.';
  end if;
  if not exists (
    select 1 from public.members m join public.characters ch
      on ch.campaign_id=m.campaign_id and ch.user_id=m.user_id
    where m.campaign_id=p_campaign_id and m.user_id=v_user and m.role='PLAYER'
      and ch.id=v_sequence.actor_character_id
  ) then raise exception 'A ficha da sequência não pertence ao jogador autenticado.'; end if;

  v_index:=v_sequence.next_attack_index;
  v_penalty:=(v_index-1)*5;
  insert into public.srd_attack_sequence_attempts(sequence_id,attempt_index,manual_d20,iterative_penalty,idempotency_key)
  values(p_sequence_id,v_index,p_manual_d20,v_penalty,p_idempotency_key) returning * into v_attempt;
  update public.srd_attack_sequences set next_attack_index=v_index+1 where id=p_sequence_id;
  return jsonb_build_object('attempt_id',v_attempt.id,'sequence_id',p_sequence_id,
    'attempt_index',v_index,'manual_d20',p_manual_d20,'iterative_penalty',v_penalty,
    'status',v_attempt.status,'attacks_total',v_sequence.attacks_total,'replayed',false);
end;
$function$
;

-- remove_condition(p_char bigint, p_condition text)
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
$function$
;

-- repor_magias_srd(p_character_id text)
CREATE OR REPLACE FUNCTION public.repor_magias_srd(p_character_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE v_sheet public.srd_character_sheets%ROWTYPE; v_doc jsonb; v_class text; v_state jsonb;
BEGIN
  IF auth.uid() IS NULL OR NOT EXISTS (SELECT 1 FROM public.characters c
       WHERE c.id::text=p_character_id AND c.user_id=auth.uid()) THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem autorização';
  END IF;
  SELECT s.* INTO v_sheet FROM public.srd_character_sheets s
    WHERE s.character_id::text=p_character_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada'; END IF;
  v_doc:=to_jsonb(v_sheet);
  SELECT COALESCE(NULLIF(cl.class_key,''),public._srd35_class_key(cl.nome)) INTO v_class FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe não resolvida na ficha'; END IF;
  v_state:=coalesce(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
  IF jsonb_typeof(v_state->'preparadas')<>'array' THEN RAISE EXCEPTION 'Estado de magias inválido'; END IF;
  SELECT jsonb_build_object('version',1,'conhecidas',coalesce(v_state->'conhecidas','[]'::jsonb),
      'preparadas',coalesce(jsonb_agg(jsonb_set(e.value,'{expended}','false'::jsonb,true) ORDER BY e.ord),'[]'::jsonb),
      'dominio_preparadas',coalesce((SELECT jsonb_agg(jsonb_set(d.value,'{expended}','false'::jsonb,true) ORDER BY d.ord)
        FROM jsonb_array_elements(coalesce(v_state->'dominio_preparadas','[]'::jsonb)) WITH ORDINALITY d(value,ord)),'[]'::jsonb),
      'usos',CASE WHEN v_class IN ('sorcerer','bard') THEN '{}'::jsonb ELSE coalesce(v_state->'usos','{}'::jsonb) END)
    INTO v_state FROM jsonb_array_elements(v_state->'preparadas') WITH ORDINALITY e(value,ord);
  UPDATE public.srd_character_sheets SET magias_preparadas=v_state,magias_descanso_em=clock_timestamp()
    WHERE character_id::text=p_character_id;
  RETURN v_state || jsonb_build_object('descanso_em',clock_timestamp());
END
$function$
;

-- resolver_ataque_iterativo_npc_srd(p_campaign_id bigint, p_attempt_id uuid)
CREATE OR REPLACE FUNCTION public.resolver_ataque_iterativo_npc_srd(p_campaign_id bigint, p_attempt_id uuid)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO ''
AS $function$ select priv.npc_resolver_ataque_iterativo_impl($1,$2); $function$
;

-- resolver_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid)
CREATE OR REPLACE FUNCTION public.resolver_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_user uuid := auth.uid();
  v_campaign public.campaigns%rowtype;
  v_seq public.srd_attack_sequences%rowtype;
  v_attempt public.srd_attack_sequence_attempts%rowtype;
  v_sheet public.srd_character_sheets%rowtype;
  v_class public.srd_classes%rowtype;
  v_race public.srd_races%rowtype;
  v_weapon public.srd_equipment%rowtype;
  v_instance public.srd_character_weapon_instances%rowtype;
  v_scene jsonb;
  v_tokens jsonb;
  v_actor jsonb;
  v_target jsonb;
  v_ca_text text;
  v_ca integer;
  v_turn integer;
  v_round integer;
  v_target_count integer;
  v_actor_count integer;
  v_target_ord bigint;
  v_actor_ord bigint;
  v_bab integer;
  v_level integer;
  v_score integer;
  v_ability_mod integer;
  v_size_mod integer := 0;
  v_focus integer := 0;
  v_proficiency_penalty integer := 0;
  v_racial_bonus integer := 0;
  v_range_penalty integer := 0;
  v_effect_attack integer := 0;
  v_effect_ac integer := 0;
  v_rogue_level integer := 0;
  v_sneak_dice integer := 0;
  v_target_denies_dex boolean := false;
  v_expected integer;
  v_total integer;
  v_attack_key text;
  v_weapon_name text;
  v_weapon_prof text;
  v_class_profs jsonb;
  v_proficient boolean := false;
  v_has_finesse boolean := false;
  v_target_traits text;
  v_target_race text;
  v_target_type text;
  v_critical_immune boolean := false;
  v_critical_immunity_text text;
  v_critical_special_text text;
  v_ax integer; v_ay integer; v_bx integer; v_by integer;
  v_dx integer; v_dy integer; v_dist integer;
  v_attacker_size integer := 1;
  v_target_size integer := 1;
  v_range_increment numeric;
  v_range_increments integer;
  v_max_range integer;
  v_crit_text text;
  v_crit_min integer := 20;
  v_crit_mult integer := 2;
  v_is_threat boolean := false;
  v_status text;
  v_end_meta jsonb;
  v_player_ac jsonb;
begin
  if v_user is null then raise exception 'É necessário estar autenticado.'; end if;

  select * into v_campaign from public.campaigns
  where id = p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,'')) <> 'COMBATE' then
    raise exception 'A campanha não está em combate.';
  end if;

  select * into v_seq from public.srd_attack_sequences
  where id = p_attempt_id and campaign_id = p_campaign_id;
  -- p_attempt_id is the attempt id; sequence is resolved below.
  select a.* into v_attempt from public.srd_attack_sequence_attempts a
  where a.id = p_attempt_id for update;
  if not found then raise exception 'Tentativa de ataque não encontrada.'; end if;

  select s.* into v_seq from public.srd_attack_sequences s
  where s.id = v_attempt.sequence_id and s.campaign_id = p_campaign_id
  for update;
  if not found then raise exception 'Sequência de ataque não encontrada.'; end if;

  if v_seq.created_by <> v_user then
    raise exception 'Somente quem iniciou a sequência pode resolver o ataque.';
  end if;
  if v_attempt.status <> 'pending_resolution' then
    return jsonb_build_object('attempt_id',v_attempt.id,'sequence_id',v_seq.id,
      'status',v_attempt.status,'resolution_data',v_attempt.resolution_data,'replayed',true);
  end if;
  if v_seq.status <> 'active' then raise exception 'A sequência não está ativa.'; end if;

  if not exists (
    select 1 from public.characters ch
    join public.members m on m.campaign_id=ch.campaign_id and m.user_id=ch.user_id
    where ch.id=v_seq.actor_character_id and ch.campaign_id=p_campaign_id
      and ch.user_id=v_user and m.role='PLAYER'
  ) then raise exception 'A ficha atacante não pertence ao jogador autenticado nesta campanha.'; end if;

  v_scene := coalesce(v_campaign.cba_data,'{}'::jsonb);
  v_tokens := case when jsonb_typeof(v_scene->'tokens')='array' then v_scene->'tokens' else '[]'::jsonb end;
  v_target_count := 0; v_actor_count := 0;
  select count(*)::integer,min(t.ordinality) into v_target_count,v_target_ord
  from jsonb_array_elements(v_tokens) with ordinality t(token,ordinality)
  where t.token->>'id'=v_seq.target_token_id and t.token->>'tipo' in ('npc','monstro','player');
  if v_target_count <> 1 then raise exception 'Alvo ausente ou duplicado na cena.'; end if;
  select count(*)::integer,min(t.ordinality) into v_actor_count,v_actor_ord
  from jsonb_array_elements(v_tokens) with ordinality t(token,ordinality)
  where t.token->>'id'=v_seq.actor_character_id::text and t.token->>'tipo'='player';
  if v_actor_count <> 1 then raise exception 'Token do personagem ausente ou duplicado.'; end if;
  v_target := v_tokens->(v_target_ord::integer-1);
  v_actor := v_tokens->(v_actor_ord::integer-1);

  v_turn := case when coalesce(v_campaign.combat_data->>'current_turn','') ~ '^[0-9]+$'
    then (v_campaign.combat_data->>'current_turn')::integer else -1 end;
  v_round := case when coalesce(v_campaign.combat_data->>'round','') ~ '^[0-9]+$'
    then greatest(1,(v_campaign.combat_data->>'round')::integer) else -1 end;
  if lower(coalesce(v_campaign.combat_data->>'active','false')) <> 'true'
     or v_turn <> v_seq.turn_index or v_round <> v_seq.round_number then
    raise exception 'A iniciativa, turno ou rodada mudou; ataque invalidado.';
  end if;
  if not exists (
    select 1 from jsonb_array_elements(coalesce(v_campaign.combat_data->'turn_order','[]'::jsonb)) e
    where e->>'id'=v_seq.actor_character_id::text and coalesce(e->>'is_monster','false')<>'true'
      and (select ordinality-1 from jsonb_array_elements(coalesce(v_campaign.combat_data->'turn_order','[]'::jsonb)) with ordinality x(e,ordinality) where x.e->>'id'=v_seq.actor_character_id::text limit 1)=v_turn
  ) then raise exception 'O personagem não é o ator do turno atual.'; end if;

  select sh.* into v_sheet from public.srd_character_sheets sh
  where sh.character_id=v_seq.actor_character_id;
  if not found then raise exception 'Ficha SRD não encontrada.'; end if;
  select cl.* into v_class from public.srd_classes cl where cl.id=v_sheet.classe_id;
  select r.* into v_race from public.srd_races r where r.id=v_sheet.raca_id;
  if v_class.id is null or v_race.id is null then raise exception 'Classe ou raça não encontrada.'; end if;

  select wi.* into v_instance from public.srd_character_weapon_instances wi
  where wi.instance_id=v_seq.weapon_instance_id
    and wi.character_id=v_seq.actor_character_id::text
    and wi.equipado is true and wi.hand_slot=v_seq.weapon_hand_slot
  for share;
  if not found then raise exception 'A instância de arma não está mais equipada na mão vinculada.'; end if;
  if not exists (
    select 1 from public.srd_character_equipment ce
    where ce.character_id=v_seq.actor_character_id::text
      and ce.equipment_id=v_instance.equipment_id and ce.equipado is true
      and ce.hand_slot=v_seq.weapon_hand_slot
  ) then raise exception 'O equipamento não corresponde à instância equipada.'; end if;
  select eq.* into v_weapon from public.srd_equipment eq where eq.id=v_instance.equipment_id;
  if not found then raise exception 'Arma do ataque não encontrada no catálogo.'; end if;

  v_end_meta := case when v_seq.weapon_end='off' then coalesce(v_weapon.detalhes->'weapon_end_off','{}'::jsonb)
    when v_seq.weapon_end='main' then coalesce(v_weapon.detalhes->'weapon_end_main','{}'::jsonb)
    else '{}'::jsonb end;
  if coalesce((v_weapon.detalhes->>'weapon_double')::boolean,false) and v_seq.weapon_end is null then
    raise exception 'A extremidade da arma dupla não foi vinculada.';
  end if;

  v_level := greatest(1,coalesce(v_sheet.nivel,1));
  select coalesce(sum(case lower(coalesce(clas.bab_progression,''))
    when 'good' then lv.class_level when 'bom' then lv.class_level
    when 'average' then floor(3*lv.class_level/4.0)::integer
    when 'medium' then floor(3*lv.class_level/4.0)::integer
    when 'medio' then floor(3*lv.class_level/4.0)::integer
    when 'poor' then floor(lv.class_level/2.0)::integer
    when 'ruim' then floor(lv.class_level/2.0)::integer else 0 end),0)::integer
  into v_bab
  from public.srd_character_class_levels lv
  join public.srd_classes clas on clas.id=lv.class_id
  where lv.character_id=v_seq.actor_character_id;
  if not exists(select 1 from public.srd_character_class_levels lv
      where lv.character_id=v_seq.actor_character_id) then
    v_bab := case lower(coalesce(v_class.bab_progression,''))
      when 'good' then v_level when 'bom' then v_level
      when 'average' then floor(3*v_level/4.0)::integer
      when 'medium' then floor(3*v_level/4.0)::integer
      when 'medio' then floor(3*v_level/4.0)::integer
      when 'poor' then floor(v_level/2.0)::integer
      when 'ruim' then floor(v_level/2.0)::integer else 0 end;
  end if;
  if v_bab <> v_seq.base_attack_bonus then
    raise exception 'O BBA da ficha mudou desde o início da sequência.';
  end if;

  v_weapon_name := coalesce(v_weapon.detalhes->>'weapon_proficiency_name',v_weapon.nome,'Ataque desarmado');
  v_weapon_prof := priv.srd_weapon_proficiency(v_weapon.detalhes,v_weapon_name);
  v_class_profs := coalesce(v_class.dados_tecnicos->'proficiencias'->'armas','[]'::jsonb);
  v_proficient := exists (
    select 1 from jsonb_array_elements_text(case when jsonb_typeof(v_class_profs)='array' then v_class_profs else '[]'::jsonb end) p
    where lower(btrim(p.value))='todas as armas simples e marciais' AND v_weapon_prof IN ('simple','martial')
      or public.srd35_normalizar_parametro_talento(p.value)=public.srd35_normalizar_parametro_talento(v_weapon_name)
      or (lower(btrim(p.value))='armas simples' and v_weapon_prof='simple')
  );
  if not v_proficient and v_weapon_prof='exotic' and v_sheet.raca_id='anao'
     and coalesce(v_weapon.detalhes->'weapon_familiarity_race_ids','[]'::jsonb) ? 'anao' then
    v_proficient := exists (
      select 1 from jsonb_array_elements_text(case when jsonb_typeof(v_class_profs)='array' then v_class_profs else '[]'::jsonb end) p
      where lower(btrim(p.value))='todas as armas simples e marciais'
    ) or exists (
      select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
      where f->>'id'='srd35_feat_martial_weapon_proficiency'
        and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name)
    );
  end if;
  if not v_proficient then
    v_proficient := exists (
      select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
      where (f->>'id'='srd35_feat_simple_weapon_proficiency' and v_weapon_prof='simple')
        or (f->>'id' in ('srd35_feat_martial_weapon_proficiency','srd35_feat_exotic_weapon_proficiency')
          and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name))
    );
  end if;
  if not v_proficient then v_proficiency_penalty := 4; end if;

  v_has_finesse := exists (
    select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
    where f->>'id'='srd35_feat_weapon_finesse'
  );
  if v_seq.attack_type='atk-dist' then
    if coalesce(v_weapon.detalhes->>'weapon_ranged','false')<>'true' then
      raise exception 'A arma vinculada não permite ataque à distância.';
    end if;
    v_attack_key := 'DES';
    v_score := coalesce(nullif(v_sheet.atributos->>'DES','')::integer,10);
  else
    if coalesce(v_weapon.detalhes->>'weapon_melee','true')='false' then
      raise exception 'A arma vinculada não permite ataque corpo a corpo.';
    end if;
    if v_has_finesse and coalesce(v_weapon.detalhes->>'weapon_finesse_eligible','false')='true' then
      v_attack_key := 'DES'; v_score := coalesce(nullif(v_sheet.atributos->>'DES','')::integer,10);
    else
      v_attack_key := 'FOR'; v_score := coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10);
    end if;
  end if;
  v_ability_mod := floor((v_score-10)::numeric/2)::integer;
  if lower(coalesce(v_race.tamanho,'')) in ('pequeno','small') then v_size_mod := 1;
  elsif lower(coalesce(v_race.tamanho,'')) in ('grande','large') then v_size_mod := -1; end if;

  v_focus := (case when exists (
    select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
    where f->>'id'='foco_em_arma' and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name)
  ) then 1 else 0 end) + (case when exists (
    select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
    where f->>'id'='srd35_feat_greater_weapon_focus' and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name)
  ) then 1 else 0 end);

  v_target_race:=lower(coalesce(nullif(v_target->>'raca_id',''),nullif(v_target->>'race_id',''),nullif(v_target->'monsterStats'->>'race_id','')));
  IF v_target->>'tipo'='player' THEN
    SELECT lower(sh.raca_id::text) INTO v_target_race
      FROM public.srd_character_sheets sh
      WHERE sh.character_id::text=v_seq.target_token_id;
  ELSIF v_target->>'tipo'='npc' AND NULLIF(v_target->>'sourceCharacterId','') IS NOT NULL THEN
    SELECT lower(sh.raca_id::text) INTO v_target_race
      FROM public.srd_character_sheets sh
      WHERE sh.character_id::text=v_target->>'sourceCharacterId';
  END IF;
  v_target_traits := lower(concat_ws(' ',v_target->>'nome',v_target->>'detalhe',
    v_target->'monsterStats'->>'tipo',v_target->'monsterStats'->>'subtipo',
    v_target->'monsterStats'->>'type',v_target->'monsterStats'->>'creature_type',
    v_target_race));
  if v_sheet.raca_id='anao' and v_target_traits ~ '(^|[^a-z])(orc|goblin|hobgoblin|bugbear|goblinoid(e)?)([^a-z]|$)' then v_racial_bonus := 1; end if;

  if coalesce(v_actor->>'gridX','') !~ '^-?[0-9]+$' or coalesce(v_actor->>'gridY','') !~ '^-?[0-9]+$'
    or coalesce(v_target->>'gridX','') !~ '^-?[0-9]+$' or coalesce(v_target->>'gridY','') !~ '^-?[0-9]+$' then
    raise exception 'Posição de token inválida para validar alcance.';
  end if;
  v_ax := (v_actor->>'gridX')::integer; v_ay := (v_actor->>'gridY')::integer;
  v_bx := (v_target->>'gridX')::integer; v_by := (v_target->>'gridY')::integer;
  v_dx := abs(v_bx-v_ax); v_dy := abs(v_by-v_ay);
  v_dist := greatest(v_dx,v_dy)+floor(least(v_dx,v_dy)::numeric/2)::integer;
  if v_seq.attack_type='atk-corpo' then
    if v_dist > 1 then raise exception 'Alvo fora do alcance corpo a corpo.'; end if;
  else
    v_range_increment := nullif(v_weapon.detalhes->>'range_increment_m','')::numeric;
    if v_range_increment is null then
      v_range_increment := nullif(regexp_replace(coalesce(v_weapon.detalhes->>'range_increment',''),'[^0-9.]','','g'),'')::numeric;
    end if;
    if v_range_increment is null or v_range_increment<=0 then raise exception 'Incremento de distância não cadastrado para a arma.'; end if;
    v_range_increments := greatest(1,ceil((v_dist*1.5)/v_range_increment)::integer);
    v_max_range := coalesce(nullif(v_weapon.detalhes->>'max_range_increments','')::integer,10);
    if v_range_increments>v_max_range then raise exception 'Alvo fora do alcance máximo da arma.'; end if;
    v_range_penalty := (v_range_increments-1)*2;
  end if;
  v_target_type:=lower(coalesce(nullif(v_target->'monsterStats'->>'creature_type',''),nullif(v_target->'monsterStats'->>'type',''),nullif(v_target->'monsterStats'->>'tipo',''),nullif(v_target->>'creature_type',''),nullif(v_target->>'tipo_criatura',''),nullif(v_target->>'tipo',''),''));
  v_critical_immunity_text:=translate(lower(concat_ws(' ',v_target_type,v_target->'monsterStats'->>'subtipo',v_target->'monsterStats'->>'subtype',v_target->'monsterStats'->>'subtypes')),'áàâãäéèêëíìîïóòôõöúùûüç','aaaaaeeeeiiiiooooouuuuc');
  v_critical_special_text:=translate(lower(concat_ws(' ',v_target->'monsterStats'->>'qualidades_especiais',v_target->'monsterStats'->>'special_qualities',v_target->'monsterStats'->>'specialQualities',v_target->'monsterStats'->>'immunities',v_target->'monsterStats'->>'imunidades',v_target->>'qualidades_especiais',v_target->>'special_qualities',v_target->>'immunities',v_target->>'imunidades')),'áàâãäéèêëíìîïóòôõöúùûüç','aaaaaeeeeiiiiooooouuuuc');
  v_critical_immune:=v_target_type in ('undead','morto-vivo','construct','construto','ooze','gosma','plant','planta','elemental','incorporeal','incorporeo') or v_critical_immunity_text ~ '(^|[^a-z])(undead|morto.vivo|construct|construto|ooze|gosma|plant|planta|elemental|incorporeal|incorporeo)([^a-z]|$)' or v_target->>'imune_critico'='true' or v_target->>'critical_immune'='true' or v_target->'monsterStats'->>'imune_critico'='true' or v_target->'monsterStats'->>'critical_immune'='true' or v_target->>'incorporeal'='true' or v_target->'monsterStats'->>'incorporeal'='true' or v_critical_special_text ~ '(immune to critical hits|immunity to critical hits|critical hit immunity|imune a acertos criticos|imunidade a acertos criticos|imune a criticos|imunidade a criticos)';
  v_target_denies_dex:=exists(select 1 from public.srd_campaign_conditions cc
    where cc.campaign_id=p_campaign_id and cc.target_kind='token'
      and cc.target_id in (v_seq.target_token_id,coalesce(v_target->>'key',v_seq.target_token_id))
      and cc.active is true and cc.condition_id in
        ('blinded','cowering','flatfooted','helpless','paralyzed','pinned','stunned','unconscious','dying','stable','dead'));
  select coalesce(max(lv.class_level),0) into v_rogue_level
    from public.srd_character_class_levels lv join public.srd_classes cls on cls.id=lv.class_id
    where lv.character_id=v_seq.actor_character_id and cls.class_key='rogue';
  if v_rogue_level=0 and not exists(select 1 from public.srd_character_class_levels lv
      where lv.character_id=v_seq.actor_character_id) and v_sheet.classe_id='ladino' then
    v_rogue_level:=greatest(1,coalesce(v_sheet.nivel,1));
  end if;
  if v_target_denies_dex and not v_critical_immune then
    v_sneak_dice:=least(10,floor((v_rogue_level+1)/2.0)::integer);
    if v_seq.attack_type='atk-dist' and v_dist>6 then v_sneak_dice:=0; end if;
  end if;

  v_effect_attack := priv.srd_effective_modifier(p_campaign_id,'character',v_seq.actor_character_id::text,'attack')
    + case when v_seq.attack_type='atk-corpo'
      then priv.srd_effective_modifier(p_campaign_id,'character',v_seq.actor_character_id::text,'attack_melee')
        + floor((coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)
          + priv.srd_effective_modifier(p_campaign_id,'character',v_seq.actor_character_id::text,'strength')-10)::numeric/2)::integer
        - floor((coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)-10)::numeric/2)::integer
      else priv.srd_effective_modifier(p_campaign_id,'character',v_seq.actor_character_id::text,'attack_ranged')
        + floor((coalesce(nullif(v_sheet.atributos->>'DES','')::integer,10)
          + priv.srd_effective_modifier(p_campaign_id,'character',v_seq.actor_character_id::text,'dexterity')-10)::numeric/2)::integer
        - floor((coalesce(nullif(v_sheet.atributos->>'DES','')::integer,10)-10)::numeric/2)::integer end;
  v_effect_ac := priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac')
    + case when v_seq.attack_type='atk-corpo'
      then priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac_melee')
      else priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac_ranged') end;

  if v_target->>'tipo'='player' OR (
       v_target->>'tipo'='npc' AND NULLIF(v_target->>'sourceCharacterId','') IS NOT NULL
     ) then
    v_player_ac:=priv.srd_calcular_ca_alvo_campanha_srd(
      p_campaign_id,
      CASE WHEN v_target->>'tipo'='player' THEN v_seq.target_token_id
           ELSE v_target->>'sourceCharacterId' END,
      'normal'
    );
    v_ca:=nullif(v_player_ac->>'final_ac','')::integer;
    if v_ca is null then raise exception 'Não foi possível calcular a CA atual da ficha SRD vinculada ao alvo.'; end if;
    v_ca:=v_ca+case when v_seq.attack_type='atk-corpo'
      then priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac_melee')
      else priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac_ranged') end;
  else
    v_ca_text := coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca');
    if coalesce(v_ca_text,'') !~ '^[0-9]{1,3}$' then raise exception 'O alvo não possui CA numérica válida.'; end if;
    v_ca := v_ca_text::integer + v_effect_ac;
  end if;
  v_expected := v_bab + v_ability_mod + v_size_mod + v_focus + v_racial_bonus
    - v_proficiency_penalty - v_range_penalty - v_attempt.iterative_penalty - v_seq.power_attack_penalty;
  v_total := v_attempt.manual_d20 + v_expected + v_effect_attack;

  v_crit_text := coalesce(v_end_meta->>'critical',v_weapon.detalhes->>'critical',v_weapon.critico,'x2');
  if v_crit_text ~ '^[0-9]{2}(-[0-9]{2})?/x[0-9]+$' then
    v_crit_min := split_part(v_crit_text,'-',1)::integer;
    if v_crit_min < 2 or v_crit_min > 20 then raise exception 'Faixa crítica cadastrada é inválida.'; end if;
  else
    v_crit_min := 20;
  end if;
  if v_attempt.manual_d20=20 or (v_attempt.manual_d20<>1 and v_total>=v_ca) then
    v_is_threat := v_attempt.manual_d20>=v_crit_min and not v_critical_immune;
    v_status := case when v_is_threat then 'critical_confirmation_pending' else 'hit_pending_damage' end;
  else
    v_status := 'miss';
  end if;

  update public.srd_attack_sequence_attempts
  set status=v_status, attack_total=v_total, target_ac=v_ca, is_critical=false,
      resolved_at=now(),
      resolution_data=jsonb_build_object(
        'attack_bonus_base',v_bab,'ability',v_attack_key,'ability_modifier',v_ability_mod,
        'size_modifier',v_size_mod,'weapon_focus',v_focus,'racial_bonus',v_racial_bonus,
        'proficiency_penalty',v_proficiency_penalty,'range_penalty',v_range_penalty,
        'iterative_penalty',v_attempt.iterative_penalty,'power_attack_penalty',v_seq.power_attack_penalty,'effect_attack_modifier',v_effect_attack,
        'attack_total',v_total,'target_ac',v_ca,'manual_d20',v_attempt.manual_d20,
        'critical_threat_minimum',v_crit_min,'critical_multiplier',coalesce(nullif(regexp_replace(v_crit_text,'^.*x',''),'')::integer,2),
        'critical_threat',v_is_threat,'critical_immune',v_critical_immune,'weapon_instance_id',v_seq.weapon_instance_id,
        'weapon_hand_slot',v_seq.weapon_hand_slot,'weapon_end',v_seq.weapon_end,'sneak_attack_dice',v_sneak_dice,'sneak_attack_eligible',(v_sneak_dice>0)
      )
  where id=v_attempt.id returning * into v_attempt;

  if v_status='miss' and v_attempt.attempt_index=v_seq.attacks_total then
    update public.srd_attack_sequences set status='completed',completed_at=now() where id=v_seq.id;
  end if;

  return jsonb_build_object('attempt_id',v_attempt.id,'sequence_id',v_seq.id,
    'attempt_index',v_attempt.attempt_index,'status',v_status,'attack_total',v_total,
    'target_ac',v_ca,'critical_threat',v_is_threat,'resolution_data',v_attempt.resolution_data,
    'replayed',false);
end;
$function$
;

-- roll_death_save(p_char bigint)
CREATE OR REPLACE FUNCTION public.roll_death_save(p_char bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare c public.characters; s public.character_sheets; st jsonb; d int; suc int; fal int; est bool; morto bool;
begin
  select * into c from public.characters where id = p_char;
  if not found then raise exception 'Personagem inexistente.'; end if;
  if c.user_id is distinct from auth.uid() and public.my_role(c.campaign_id) is distinct from 'GM' then
    raise exception 'Sem permissão.';
  end if;
  select * into s from public.character_sheets where character_id = p_char for update;
  if s.pv_atual > 0 then raise exception 'Personagem não está em 0 PV.'; end if;
  st := s.death_state;
  suc := coalesce((st->>'sucessos')::int, 0);
  fal := coalesce((st->>'falhas')::int, 0);
  est := coalesce((st->>'estabilizado')::boolean, false);
  morto := coalesce((st->>'morto')::boolean, false);

  d := priv.d20();
  if d = 20 then
    update public.character_sheets set pv_atual = 1,
      death_state = '{"sucessos":0,"falhas":0,"estabilizado":false,"morto":false}'::jsonb
      where character_id = p_char;
    perform priv.log(c.campaign_id, 'TESTE_MORTE', jsonb_build_object('char', p_char, 'd20', 20, 'resultado', 'REVIVE'));
    return jsonb_build_object('d20', d, 'resultado', 'REVIVE', 'pv', 1);
  elsif d = 1 then
    fal := fal + 2;
  elsif d >= 10 then
    suc := suc + 1;
  else
    fal := fal + 1;
  end if;

  if suc >= 3 then est := true; end if;
  if fal >= 3 then morto := true; end if;

  update public.character_sheets set death_state =
    jsonb_build_object('sucessos', suc, 'falhas', fal, 'estabilizado', est, 'morto', morto)
    where character_id = p_char;

  perform priv.log(c.campaign_id, 'TESTE_MORTE',
    jsonb_build_object('char', p_char, 'd20', d, 'sucessos', suc, 'falhas', fal, 'estabilizado', est, 'morto', morto));

  return jsonb_build_object('d20', d, 'sucessos', suc, 'falhas', fal, 'estabilizado', est, 'morto', morto);
end $function$
;

-- roll_dice(p_expr text, p_visibilidade text)
CREATE OR REPLACE FUNCTION public.roll_dice(p_expr text, p_visibilidade text DEFAULT 'PUBLIC'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare r jsonb; cid bigint;
begin
  if p_visibilidade not in ('PUBLIC','GM_ONLY','SELF_AND_GM') then
    raise exception 'Visibilidade inválida.';
  end if;
  r := priv.roll_dice_expr(p_expr);
  if r ? 'erro' then raise exception 'Expressão inválida. Use o formato NdS+M.'; end if;

  select campaign_id into cid from public.members where user_id = auth.uid() limit 1;
  if cid is not null then
    insert into public.campaign_log(campaign_id, type, data, visibilidade)
    values (cid, 'ROLL',
      jsonb_build_object('autor', auth.uid(),
                         'nome', (select username from public.profiles where id = auth.uid()),
                         'expressao', p_expr, 'resultado', r),
      p_visibilidade);
  end if;
  return r;
end $function$
;

-- salvar_cena_cba(p_campaign_id bigint, p_scene jsonb)
CREATE OR REPLACE FUNCTION public.salvar_cena_cba(p_campaign_id bigint, p_scene jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
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
$function$
;

-- salvar_dominios_personagem_srd(p_character_id text, p_domain_ids text[])
CREATE OR REPLACE FUNCTION public.salvar_dominios_personagem_srd(p_character_id text, p_domain_ids text[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_character_id public.characters.id%TYPE;
  v_class_key text;
  v_choices jsonb;
  v_identity jsonb;
  v_deity_id text;
  v_allowed_domains text[];
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória'; END IF;
  IF p_domain_ids IS NULL OR cardinality(p_domain_ids) NOT IN (1,2)
     OR p_domain_ids[1] IS NULL
     OR (cardinality(p_domain_ids)=2 AND (p_domain_ids[2] IS NULL OR p_domain_ids[1]=p_domain_ids[2])) THEN
    RAISE EXCEPTION 'A quantidade de domínios escolhida não é válida';
  END IF;
  SELECT c.id,public._srd35_class_key(cl.nome),sh.identidade
    INTO v_character_id,v_class_key,v_identity
    FROM public.characters c
    JOIN public.srd_character_sheets sh ON sh.character_id=c.id
    JOIN public.srd_classes cl ON cl.id=sh.classe_id
   WHERE c.id::text=p_character_id AND c.user_id=auth.uid()
   FOR UPDATE OF c,sh;
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou sem autorização'; END IF;
  IF v_class_key='cleric' AND cardinality(p_domain_ids)<>2 THEN
    RAISE EXCEPTION 'O Clérigo deve escolher dois domínios.';
  ELSIF v_class_key='druid' AND cardinality(p_domain_ids)<>1 THEN
    RAISE EXCEPTION 'O Druida deve escolher exatamente um domínio.';
  ELSIF v_class_key NOT IN ('cleric','druid') THEN
    RAISE EXCEPTION 'Somente Clérigos e Druidas podem salvar domínios nesta etapa.';
  END IF;
  IF v_class_key='druid' AND p_domain_ids[1] NOT IN ('air','animal','earth','fire','plant','water') THEN
    RAISE EXCEPTION 'Domínio não permitido para Druida.';
  END IF;
  IF v_class_key='druid' THEN
    IF coalesce(v_identity->>'druid_nature_bond','')<>'domain' THEN
      RAISE EXCEPTION 'Este Druida escolheu companheiro animal, não domínio.';
    END IF;
    IF NOT EXISTS (
      SELECT 1 FROM jsonb_array_elements_text(coalesce(v_identity->'druid_domain_ids','[]'::jsonb)) x(value)
       WHERE x.value=p_domain_ids[1]
    ) THEN
      RAISE EXCEPTION 'O domínio salvo não corresponde à escolha de vínculo registrada na ficha.';
    END IF;
  END IF;
  v_deity_id := nullif(v_identity->>'cleric_deity_id','');
  IF v_class_key='cleric' AND v_deity_id IS NOT NULL THEN
    SELECT domains INTO v_allowed_domains FROM public.srd_deities WHERE deity_id=v_deity_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Divindade do Clérigo não encontrada.'; END IF;
    IF NOT (p_domain_ids[1]=ANY(v_allowed_domains) AND p_domain_ids[2]=ANY(v_allowed_domains)) THEN
      RAISE EXCEPTION 'Os domínios escolhidos não pertencem à divindade selecionada.';
    END IF;
  END IF;
  IF (SELECT count(*) FROM public.srd_domains WHERE domain_id=ANY(p_domain_ids))<>cardinality(p_domain_ids) THEN
    RAISE EXCEPTION 'Um dos domínios não existe no catálogo SRD';
  END IF;
  DELETE FROM public.srd_character_domain_choices WHERE character_id=v_character_id;
  INSERT INTO public.srd_character_domain_choices(character_id,domain_slot,domain_id)
  SELECT v_character_id,ordinality::smallint,domain_id
    FROM unnest(p_domain_ids) WITH ORDINALITY AS picked(domain_id,ordinality);
  SELECT jsonb_agg(jsonb_build_object('domain_slot',domain_slot,'domain_id',domain_id) ORDER BY domain_slot)
    INTO v_choices FROM public.srd_character_domain_choices WHERE character_id=v_character_id;
  RETURN coalesce(v_choices,'[]'::jsonb);
END
$function$
;

-- salvar_grimorio_srd(p_character_id text, p_estado jsonb)
CREATE OR REPLACE FUNCTION public.salvar_grimorio_srd(p_character_id text, p_estado jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_doc jsonb; v_class text; v_level integer; v_score integer;
  v_known jsonb; v_prepared jsonb; v_usos jsonb; v_old jsonb;
  v_spell record; v_entry jsonb; v_spell_id text; v_circle integer; v_spell_level integer; v_slot integer;
  v_expended boolean; v_capacity integer; v_count integer; v_count_known integer;
  v_old_expended integer; v_new_ordinal integer; v_slot_key text; v_prepared_out jsonb := '[]'::jsonb;
  v_known_out jsonb := '[]'::jsonb; v_usos_out jsonb := '{}'::jsonb;
  v_key text; v_count_value integer; v_known_limits jsonb;
  v_domain_input jsonb; v_domain_out jsonb := '[]'::jsonb; v_domain_id text; v_domain_spell_id text;
  v_domain_level integer; v_domain_expended boolean; v_has_domain boolean;
  v_identity jsonb; v_specialization text; v_prohibited jsonb; v_base_capacity integer; v_specialized_count integer;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.characters c
                  WHERE c.id::text=p_character_id AND c.user_id=auth.uid()) THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem autorização';
  END IF;
  SELECT s.* INTO v_sheet FROM public.srd_character_sheets s
   WHERE s.character_id::text=p_character_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada'; END IF;
  v_old := coalesce(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
  IF p_estado IS NULL OR jsonb_typeof(p_estado) <> 'object' OR p_estado->>'version' <> '1'
     OR jsonb_typeof(p_estado->'conhecidas') <> 'array'
     OR jsonb_typeof(p_estado->'preparadas') <> 'array'
     OR jsonb_typeof(p_estado->'usos') <> 'object' THEN
    RAISE EXCEPTION 'Formato inválido; esperado {version:1, conhecidas:[], preparadas:[], usos:{}}';
  END IF;
  v_doc := to_jsonb(v_sheet);
  v_identity := coalesce(v_sheet.identidade,'{}'::jsonb);
  v_specialization := coalesce(v_identity->>'wizard_specialization','universalista');
  v_prohibited := coalesce(v_identity->'wizard_prohibited_schools','[]'::jsonb);
  SELECT public._srd35_class_key(cl.nome) INTO v_class FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe SRD referenciada por classe_id não encontrada ou incompatível'; END IF;
  v_level := public._srd35_character_class_level(p_character_id,v_class,v_sheet.classe_id,v_sheet.nivel);
  IF v_level IS NULL OR v_level NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Nível de conjurador ausente ou fora de 1..20'; END IF;
  v_score := CASE
    WHEN v_class='wizard' THEN public._srd35_attr(v_doc,ARRAY['INT','inteligencia','intelligence','int_score','score_inteligencia'])::integer
    WHEN v_class IN ('sorcerer','bard') THEN public._srd35_attr(v_doc,ARRAY['CAR','carisma','charisma','cha','cha_score','score_carisma'])::integer
    ELSE public._srd35_attr(v_doc,ARRAY['SAB','sabedoria','wisdom','wis','wis_score','score_sabedoria'])::integer END;
  IF v_score IS NULL OR v_score < 1 THEN RAISE EXCEPTION 'Atributo-chave ausente ou inválido'; END IF;
  v_known := p_estado->'conhecidas'; v_prepared := p_estado->'preparadas'; v_usos := p_estado->'usos';
  IF v_class='wizard' THEN
    IF EXISTS (
      SELECT 1 FROM public.srd_spells sp
      WHERE v_score>=10 AND public._srd35_spell_level_for_class(sp.nivel,v_class,sp.circulo)=0 AND public._srd35_spell_class_ok(sp.classes,'wizard')
        AND NOT (public._srd35_school_key(sp.escola)=ANY(ARRAY(SELECT jsonb_array_elements_text(v_prohibited))))
        AND NOT (v_known ? sp.id)
    ) THEN
      RAISE EXCEPTION 'O grimório inicial do Mago deve conter todos os truques (círculo 0) permitidos.';
    END IF;
    SELECT count(*)::integer INTO v_count_known
    FROM jsonb_array_elements_text(v_known) AS k(spell_id)
    JOIN public.srd_spells sp ON sp.id=k.spell_id
    WHERE public._srd35_spell_level_for_class(sp.nivel,v_class,sp.circulo)=1;
    v_capacity:=CASE WHEN v_score>=11 THEN greatest(0,3+floor((v_score-10)/2)::integer) ELSE 0 END;
    IF v_count_known<>v_capacity THEN
      RAISE EXCEPTION 'O grimório inicial do Mago deve conter exatamente % magia(s) de 1º círculo (3 + modificador de Inteligência, quando o atributo permite aprender).',v_capacity;
    END IF;
  END IF;
  v_domain_input := coalesce(p_estado->'dominio_preparadas',v_old->'dominio_preparadas','[]'::jsonb);
  IF EXISTS (SELECT 1 FROM jsonb_array_elements(v_known) AS x(value) WHERE jsonb_typeof(x.value) <> 'string')
     OR EXISTS (SELECT 1 FROM jsonb_array_elements(v_prepared) AS x(value) WHERE jsonb_typeof(x.value) <> 'object') THEN
    RAISE EXCEPTION 'Conhecidas deve conter IDs string e preparadas deve conter objetos';
  END IF;
  IF jsonb_typeof(v_domain_input)<>'array' THEN RAISE EXCEPTION 'dominio_preparadas deve ser uma lista'; END IF;
  IF v_class<>'cleric' AND jsonb_array_length(v_domain_input)>0 THEN RAISE EXCEPTION 'Somente clérigos têm espaços de domínio'; END IF;
  IF (SELECT count(*) FROM jsonb_array_elements_text(v_known)) <>
     (SELECT count(DISTINCT x) FROM jsonb_array_elements_text(v_known) AS t(x)) THEN
    RAISE EXCEPTION 'IDs duplicados em conhecidas';
  END IF;
  FOR v_spell_id IN SELECT x FROM jsonb_array_elements_text(v_known) AS t(x) LOOP
    SELECT id,circulo,classes,escola,nivel INTO v_spell FROM public.srd_spells WHERE id=v_spell_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Magia conhecida inexistente, nível inválido ou incompatível: %',v_spell_id; END IF;
    v_spell_level:=public._srd35_spell_level_for_class(v_spell.nivel,v_class,v_spell.circulo);
    IF v_spell_level NOT BETWEEN 0 AND 9 OR NOT public._srd35_spell_class_ok(v_spell.classes,v_class) THEN
      RAISE EXCEPTION 'Magia conhecida inexistente, nível inválido ou incompatível: %',v_spell_id;
    END IF;
    IF coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_spell_level)::integer
                   FROM public.srd_spell_progressions WHERE class_key=v_class),0)=0 THEN
      RAISE EXCEPTION 'Círculo não acessível neste nível: %',v_spell_id;
    END IF;
    IF v_score < 10+v_spell_level THEN RAISE EXCEPTION 'Atributo insuficiente para conhecer a magia: %',v_spell_id; END IF;
    IF v_class='wizard' AND public._srd35_school_key(v_spell.escola)=ANY(ARRAY(SELECT jsonb_array_elements_text(v_prohibited))) THEN
      RAISE EXCEPTION 'O Mago não pode conhecer magias de escola proibida: %',v_spell_id;
    END IF;
    v_known_out := v_known_out || to_jsonb(v_spell_id);
  END LOOP;
  IF v_class IN ('sorcerer','bard') THEN
    SELECT known_by_level -> (v_level-1) INTO v_known_limits
      FROM public.srd_spell_progressions WHERE class_key=v_class;
    FOR v_circle IN 0..9 LOOP
      SELECT count(*) INTO v_count_known
        FROM jsonb_array_elements_text(v_known) AS k(spell_id)
        JOIN public.srd_spells sp ON sp.id=k.spell_id WHERE public._srd35_spell_level_for_class(sp.nivel,v_class,sp.circulo)=v_circle;
      v_capacity := GREATEST(0,COALESCE((v_known_limits ->> v_circle)::integer,0));
      IF v_count_known > v_capacity THEN RAISE EXCEPTION 'Magias conhecidas excedem o limite do círculo %',v_circle; END IF;
    END LOOP;
  ELSIF v_usos <> '{}'::jsonb THEN
    RAISE EXCEPTION 'O mapa usos só é aceito para Bardo e Feiticeiro';
  END IF;
  IF v_class IN ('sorcerer','bard') AND ((SELECT count(*) FROM jsonb_object_keys(v_usos))>0 OR (SELECT count(*) FROM jsonb_object_keys(coalesce(v_old->'usos','{}'::jsonb)))>0) THEN
    FOR v_key,v_count_value IN
      SELECT k, greatest(coalesce((v_usos->>k)::integer,0),coalesce((v_old->'usos'->>k)::integer,0))
        FROM (SELECT key AS k FROM jsonb_each(v_usos)
              UNION SELECT key AS k FROM jsonb_each(coalesce(v_old->'usos','{}'::jsonb))) AS all_keys
    LOOP
      IF v_key !~ '^(0|[1-9])$' OR v_count_value<0 THEN RAISE EXCEPTION 'Usos deve mapear círculos 0..9 a inteiros não negativos'; END IF;
      v_circle := v_key::integer;
      IF coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_circle)::integer
                     FROM public.srd_spell_progressions WHERE class_key=v_class),0)=0
         OR v_count_value > GREATEST(0,public._srd35_slots(v_class,v_level,v_score,v_circle)) THEN
        RAISE EXCEPTION 'Usos excedem os espaços diários no círculo %',v_circle;
      END IF;
      v_usos_out := jsonb_set(v_usos_out,ARRAY[v_key],to_jsonb(v_count_value),true);
    END LOOP;
  END IF;
  FOR v_entry IN SELECT value FROM jsonb_array_elements(v_prepared) LOOP
    v_spell_id := v_entry->>'spell_id';
    IF v_spell_id IS NULL OR jsonb_typeof(v_entry->'slot_level') <> 'number'
       OR jsonb_typeof(v_entry->'expended') <> 'boolean' THEN
      RAISE EXCEPTION 'Cada preparado requer spell_id, slot_level inteiro e expended boolean';
    END IF;
    IF (v_entry->>'slot_level') !~ '^(0|[1-9])$' THEN RAISE EXCEPTION 'slot_level deve estar entre 0 e 9'; END IF;
    v_slot := (v_entry->>'slot_level')::integer;
    SELECT id,circulo,classes,escola,nivel INTO v_spell FROM public.srd_spells WHERE id=v_spell_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Magia preparada inexistente, nível/slot inválido ou incompatível: %',v_spell_id; END IF;
    v_spell_level:=public._srd35_spell_level_for_class(v_spell.nivel,v_class,v_spell.circulo);
    IF v_spell_level NOT BETWEEN 0 AND 9 OR v_slot < v_spell_level
       OR NOT public._srd35_spell_class_ok(v_spell.classes,v_class) THEN
      RAISE EXCEPTION 'Magia preparada inexistente, nível/slot inválido ou incompatível: %',v_spell_id;
    END IF;
    IF v_class IN ('sorcerer','bard') THEN RAISE EXCEPTION 'Bardo e Feiticeiro usam conhecidas/usos, não preparam magias'; END IF;
    IF v_class='wizard' AND NOT (v_known ? v_spell_id) THEN
      RAISE EXCEPTION 'Mago só pode preparar magias conhecidas/no grimório: %',v_spell_id;
    END IF;
    IF v_class='wizard' AND public._srd35_school_key(v_spell.escola)=ANY(ARRAY(SELECT jsonb_array_elements_text(v_prohibited))) THEN
      RAISE EXCEPTION 'O Mago não pode preparar magias de escola proibida: %',v_spell_id;
    END IF;
    IF coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_spell_level)::integer
                   FROM public.srd_spell_progressions WHERE class_key=v_class),0)=0 THEN
      RAISE EXCEPTION 'Círculo da magia não acessível neste nível: %',v_spell_id;
    END IF;
    IF v_score < 10+v_spell_level THEN RAISE EXCEPTION 'Atributo insuficiente para preparar a magia: %',v_spell_id; END IF;
    v_prepared_out := v_prepared_out || jsonb_build_array(jsonb_build_object(
      'spell_id',v_spell_id,'slot_level',v_slot,'expended',coalesce((v_entry->>'expended')::boolean,false)));
  END LOOP;
  -- Domain slots are a separate daily slot, one per accessible circle for clerics.
  IF v_class='cleric' THEN
    IF (SELECT count(*) FROM jsonb_array_elements(v_domain_input)) <>
       (SELECT count(DISTINCT (value->>'slot_level')::integer) FROM jsonb_array_elements(v_domain_input)) THEN
      RAISE EXCEPTION 'Há mais de uma preparação no mesmo espaço de domínio';
    END IF;
    FOR v_entry IN SELECT value FROM jsonb_array_elements(v_domain_input) LOOP
      v_domain_id:=v_entry->>'domain_id'; v_domain_spell_id:=v_entry->>'spell_id';
      IF v_domain_id IS NULL OR v_domain_spell_id IS NULL
         OR jsonb_typeof(v_entry->'slot_level')<>'number'
         OR jsonb_typeof(v_entry->'expended')<>'boolean'
         OR (v_entry->>'slot_level') !~ '^[1-9]$' THEN
        RAISE EXCEPTION 'Cada espaço de domínio requer domain_id, spell_id, círculo 1..9 e expended';
      END IF;
      v_domain_level:=(v_entry->>'slot_level')::integer;
      SELECT EXISTS (
        SELECT 1 FROM public.srd_character_domain_choices choice
        JOIN public.srd_domain_spells ds USING (domain_id)
        WHERE choice.character_id::text=p_character_id AND choice.domain_id=v_domain_id
          AND ds.spell_id=v_domain_spell_id AND ds.spell_level=v_domain_level
      ) INTO v_has_domain;
      IF NOT v_has_domain THEN RAISE EXCEPTION 'A magia não pertence a um domínio escolhido ou círculo informado'; END IF;
      IF coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_domain_level)::integer
                     FROM public.srd_spell_progressions WHERE class_key='cleric'),0)=0
         OR v_score < 10+v_domain_level THEN
        RAISE EXCEPTION 'O círculo de domínio não está acessível para este nível/atributo';
      END IF;
      v_domain_expended:=coalesce((v_entry->>'expended')::boolean,false);
      IF EXISTS (SELECT 1 FROM jsonb_array_elements(coalesce(v_old->'dominio_preparadas','[]'::jsonb)) old_slot
                   WHERE (old_slot->>'slot_level')::integer=v_domain_level
                     AND coalesce((old_slot->>'expended')::boolean,false)) THEN
        v_domain_expended:=true;
      END IF;
      v_domain_out:=v_domain_out||jsonb_build_array(jsonb_build_object(
        'domain_id',v_domain_id,'spell_id',v_domain_spell_id,'slot_level',v_domain_level,'expended',v_domain_expended));
    END LOOP;
    -- A spent domain slot cannot be restored by changing its spell; only a daily rest resets it.
    FOR v_entry IN SELECT value FROM jsonb_array_elements(coalesce(v_old->'dominio_preparadas','[]'::jsonb)) old_slot(value)
      WHERE coalesce((value->>'expended')::boolean,false) LOOP
      IF NOT EXISTS (SELECT 1 FROM jsonb_array_elements(v_domain_out) x(value)
                     WHERE (value->>'slot_level')::integer=(v_entry->>'slot_level')::integer) THEN
        v_domain_out:=v_domain_out||jsonb_build_array(v_entry);
      END IF;
    END LOOP;
  END IF;
  -- Preserve previously expended slots by occurrence of the same spell/slot pair.
  FOR v_count IN 0..jsonb_array_length(v_prepared_out)-1 LOOP
    v_entry := v_prepared_out -> v_count;
    v_spell_id := v_entry->>'spell_id'; v_slot := (v_entry->>'slot_level')::integer;
    v_slot_key := v_spell_id || ':' || v_slot::text;
    SELECT count(*) INTO v_new_ordinal FROM jsonb_array_elements(v_prepared_out) WITH ORDINALITY q(value,ord)
      WHERE value->>'spell_id'=v_spell_id AND (value->>'slot_level')::integer=v_slot AND ord<=v_count+1;
    SELECT count(*) INTO v_old_expended FROM jsonb_array_elements(coalesce(v_old->'preparadas','[]'::jsonb)) q(value)
      WHERE value->>'spell_id'=v_spell_id AND (value->>'slot_level')::integer=v_slot
        AND coalesce((value->>'expended')::boolean,false);
    IF v_new_ordinal<=v_old_expended THEN
      v_prepared_out := jsonb_set(v_prepared_out,ARRAY[v_count::text,'expended'],'true'::jsonb,true);
    END IF;
  END LOOP;
  -- Preserve previously expended slots even if the client submits a different spell list.
  FOR v_entry IN SELECT value FROM jsonb_array_elements(coalesce(v_old->'preparadas','[]'::jsonb)) q(value)
    WHERE coalesce((value->>'expended')::boolean,false)
  LOOP
    v_spell_id:=v_entry->>'spell_id'; v_slot:=(v_entry->>'slot_level')::integer;
    SELECT count(*) INTO v_old_expended FROM jsonb_array_elements(coalesce(v_old->'preparadas','[]'::jsonb)) q(value)
      WHERE value->>'spell_id'=v_spell_id AND (value->>'slot_level')::integer=v_slot
        AND coalesce((value->>'expended')::boolean,false);
    SELECT count(*) INTO v_new_ordinal FROM jsonb_array_elements(v_prepared_out) q(value)
      WHERE value->>'spell_id'=v_spell_id AND (value->>'slot_level')::integer=v_slot
        AND coalesce((value->>'expended')::boolean,false);
    IF v_new_ordinal<v_old_expended THEN
      v_prepared_out:=v_prepared_out||jsonb_build_array(jsonb_set(v_entry,'{expended}','true'::jsonb,true));
    END IF;
  END LOOP;
  FOR v_circle IN 0..9 LOOP
    SELECT count(*) INTO v_count FROM jsonb_array_elements(v_prepared_out) e
      WHERE (e->>'slot_level')::integer=v_circle;
    v_base_capacity := GREATEST(0,public._srd35_slots(v_class,v_level,v_score,v_circle));
    v_capacity := v_base_capacity;
    IF v_class='wizard' AND v_specialization<>'universalista' AND v_base_capacity>0 THEN v_capacity:=v_base_capacity+1; END IF;
    IF v_count>v_capacity THEN RAISE EXCEPTION 'Preparadas excedem espaços diários do círculo % (% > %)',v_circle,v_count,v_capacity; END IF;
    IF v_class='wizard' AND v_count>v_base_capacity THEN
      SELECT count(*) INTO v_specialized_count
        FROM jsonb_array_elements(v_prepared_out) prep(value)
        JOIN public.srd_spells sp ON sp.id=prep.value->>'spell_id'
       WHERE (prep.value->>'slot_level')::integer=v_circle
         AND public._srd35_school_key(sp.escola)=v_specialization;
      IF v_specialized_count<1 THEN
        RAISE EXCEPTION 'O espaço adicional do círculo % exige uma magia da escola especializada (%).',v_circle,v_specialization;
      END IF;
    END IF;
  END LOOP;
  UPDATE public.srd_character_sheets
     SET magias_preparadas=jsonb_build_object('version',1,'conhecidas',v_known_out,'preparadas',v_prepared_out,'dominio_preparadas',v_domain_out,'usos',v_usos_out)
   WHERE character_id::text=p_character_id;
  RETURN jsonb_build_object('version',1,'conhecidas',v_known_out,'preparadas',v_prepared_out,'dominio_preparadas',v_domain_out,'usos',v_usos_out);
END
$function$
;

-- salvar_idiomas_personagem_srd(p_character_id text, p_idiomas jsonb)
CREATE OR REPLACE FUNCTION public.salvar_idiomas_personagem_srd(p_character_id text, p_idiomas jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'auth', 'pg_temp'
AS $function$
DECLARE
  v_user UUID:=auth.uid();
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_race public.srd_races%ROWTYPE;
  v_class public.srd_classes%ROWTYPE;
  v_language_line TEXT;
  v_auto_text TEXT;
  v_bonus_text TEXT;
  v_auto_expected TEXT[]:=ARRAY[]::TEXT[];
  v_bonus_allowed TEXT[]:=ARRAY[]::TEXT[];
  v_auto_submitted TEXT[]:=ARRAY[]::TEXT[];
  v_bonus_submitted TEXT[]:=ARRAY[]::TEXT[];
  v_purchased_submitted TEXT[]:=ARRAY[]::TEXT[];
  v_all_submitted TEXT[]:=ARRAY[]::TEXT[];
  v_any_bonus BOOLEAN:=FALSE;
  v_int_mod INTEGER:=0;
  v_language_ranks INTEGER:=0;
  v_distinct_count INTEGER:=0;
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'Autenticação necessária.'; END IF;
  IF jsonb_typeof(p_idiomas)<>'object' THEN RAISE EXCEPTION 'Estrutura de idiomas inválida.'; END IF;
  IF jsonb_typeof(p_idiomas->'automaticos')<>'array'
     OR jsonb_typeof(p_idiomas->'bonus_inteligencia')<>'array'
     OR jsonb_typeof(p_idiomas->'comprados_falar_idioma')<>'array' THEN
    RAISE EXCEPTION 'As listas de idiomas precisam ser arrays.';
  END IF;

  SELECT sh.* INTO v_sheet
  FROM public.characters ch
  JOIN public.srd_character_sheets sh ON sh.character_id=ch.id
  WHERE ch.id::TEXT=BTRIM(p_character_id) AND ch.user_id=v_user;
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou sem permissão.'; END IF;

  SELECT * INTO v_race FROM public.srd_races WHERE id=v_sheet.raca_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Raça do personagem não encontrada.'; END IF;
  SELECT * INTO v_class FROM public.srd_classes WHERE id=v_sheet.classe_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Classe do personagem não encontrada.'; END IF;

  SELECT elem INTO v_language_line
  FROM jsonb_array_elements_text(v_race.habilidades_raciais) elem
  WHERE elem ILIKE '%idioma%automático%:%'
  LIMIT 1;
  IF v_language_line IS NULL THEN RAISE EXCEPTION 'A raça não possui regra de idiomas automáticos cadastrada.'; END IF;

  v_auto_text:=split_part(regexp_replace(v_language_line,'^.*idiomas? automáticos?:\s*','','i'),'.',1);
  v_auto_text:=regexp_replace(v_auto_text,'\s+e\s+',',','gi');
  SELECT COALESCE(array_agg(BTRIM(x)),ARRAY[]::TEXT[]) INTO v_auto_expected
  FROM unnest(string_to_array(v_auto_text,',')) x WHERE BTRIM(x)<>'';
  IF v_class.id='druida' AND NOT ('Druídico'=ANY(v_auto_expected)) THEN
    v_auto_expected:=array_append(v_auto_expected,'Druídico');
  END IF;

  v_any_bonus:=v_language_line ILIKE '%qualquer idioma%'
    OR v_language_line ILIKE '%pode escolher idiomas adicionais%';
  v_bonus_text:='';
  IF v_language_line ILIKE '%idiomas adicionais:%' THEN
    v_bonus_text:=split_part(regexp_replace(v_language_line,'^.*idiomas adicionais:\s*','','i'),'.',1);
  END IF;
  v_bonus_text:=regexp_replace(v_bonus_text,'\s+e\s+',',','gi');
  IF NOT v_any_bonus THEN
    SELECT COALESCE(array_agg(BTRIM(x)),ARRAY[]::TEXT[]) INTO v_bonus_allowed
    FROM unnest(string_to_array(v_bonus_text,',')) x WHERE BTRIM(x)<>'';
  END IF;

  SELECT COALESCE(array_agg(value),ARRAY[]::TEXT[]) INTO v_auto_submitted
  FROM jsonb_array_elements_text(p_idiomas->'automaticos') AS t(value);
  SELECT COALESCE(array_agg(value),ARRAY[]::TEXT[]) INTO v_bonus_submitted
  FROM jsonb_array_elements_text(p_idiomas->'bonus_inteligencia') AS t(value);
  SELECT COALESCE(array_agg(value),ARRAY[]::TEXT[]) INTO v_purchased_submitted
  FROM jsonb_array_elements_text(p_idiomas->'comprados_falar_idioma') AS t(value);

  IF cardinality(v_auto_submitted)<>cardinality(v_auto_expected)
     OR EXISTS(SELECT 1 FROM unnest(v_auto_expected) x WHERE NOT (x=ANY(v_auto_submitted))) THEN
    RAISE EXCEPTION 'Os idiomas automáticos não correspondem à raça e à classe.';
  END IF;

  v_int_mod:=GREATEST(0,FLOOR((COALESCE(NULLIF(v_sheet.atributos->>'INT','')::NUMERIC,10)-10)/2)::INTEGER);
  IF cardinality(v_bonus_submitted)>v_int_mod THEN
    RAISE EXCEPTION 'A quantidade de idiomas bônus excede o modificador de Inteligência.';
  END IF;
  IF NOT v_any_bonus AND EXISTS(SELECT 1 FROM unnest(v_bonus_submitted) x WHERE NOT (x=ANY(v_bonus_allowed))) THEN
    RAISE EXCEPTION 'Um dos idiomas bônus não pertence à lista permitida pela raça.';
  END IF;

  v_language_ranks:=CASE WHEN COALESCE(v_sheet.pericias->>'srd35_skill_speak_language','') ~ '^[0-9]+$'
    THEN (v_sheet.pericias->>'srd35_skill_speak_language')::INTEGER ELSE 0 END;
  IF cardinality(v_purchased_submitted)<>v_language_ranks THEN
    RAISE EXCEPTION 'A quantidade de idiomas comprados precisa corresponder aos pontos investidos em Falar Idioma.';
  END IF;

  IF EXISTS(
    SELECT 1 FROM unnest(v_auto_submitted) x
    WHERE NOT EXISTS(SELECT 1 FROM public.srd_languages l WHERE l.nome=x)
  ) THEN RAISE EXCEPTION 'Idioma automático ausente do catálogo.'; END IF;
  IF EXISTS(
    SELECT 1 FROM unnest(v_bonus_submitted||v_purchased_submitted) x
    WHERE NOT EXISTS(SELECT 1 FROM public.srd_languages l WHERE l.nome=x AND l.is_secret=FALSE)
  ) THEN RAISE EXCEPTION 'Idioma bônus ou comprado inválido ou secreto.'; END IF;

  v_all_submitted:=v_auto_submitted||v_bonus_submitted||v_purchased_submitted;
  SELECT COUNT(DISTINCT lower(x)) INTO v_distinct_count FROM unnest(v_all_submitted) x;
  IF v_distinct_count<>cardinality(v_all_submitted) THEN RAISE EXCEPTION 'O mesmo idioma não pode ser selecionado mais de uma vez.'; END IF;

  UPDATE public.srd_character_sheets
  SET idiomas_conhecidos=p_idiomas
  WHERE character_id=v_sheet.character_id;
  RETURN p_idiomas;
END;
$function$
;

-- salvar_pericias_srd(p_character_id text, p_pericias jsonb)
CREATE OR REPLACE FUNCTION public.salvar_pericias_srd(p_character_id text, p_pericias jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_class public.srd_classes%ROWTYPE;
  v_race public.srd_races%ROWTYPE;
  v_entry RECORD;
  v_skill public.srd_skills%ROWTYPE;
  v_rank NUMERIC;
  v_is_class_skill BOOLEAN;
  v_level INTEGER;
  v_int_mod INTEGER;
  v_budget NUMERIC;
  v_spent NUMERIC := 0;
  v_skill_specialization JSONB;
  v_skill_base_id TEXT;
  v_skill_specialization_name TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF p_character_id IS NULL OR BTRIM(p_character_id) = '' THEN
    RAISE EXCEPTION 'Identificador de personagem inválido.';
  END IF;
  IF p_pericias IS NULL OR jsonb_typeof(p_pericias) <> 'object' THEN
    RAISE EXCEPTION 'As perícias devem ser informadas como um objeto JSON.';
  END IF;

  SELECT sh.* INTO v_sheet
  FROM public.srd_character_sheets AS sh
  JOIN public.characters AS ch
    ON ch.id::TEXT = sh.character_id::TEXT
  WHERE sh.character_id::TEXT = BTRIM(p_character_id)
    AND ch.user_id = auth.uid();
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Ficha não encontrada ou não pertence ao usuário.';
  END IF;

  SELECT cl.* INTO v_class
  FROM public.srd_classes AS cl
  WHERE cl.id = v_sheet.classe_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Classe SRD da ficha não encontrada.';
  END IF;
  SELECT ra.* INTO v_race
  FROM public.srd_races AS ra
  WHERE ra.id = v_sheet.raca_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Raça SRD da ficha não encontrada.';
  END IF;

  v_level := v_sheet.nivel;
  IF v_level IS NULL OR v_level < 1 THEN
    RAISE EXCEPTION 'Nível da ficha inválido.';
  END IF;
  IF v_class.pericias_por_nivel IS NULL OR v_sheet.atributos IS NULL
     OR jsonb_typeof(v_sheet.atributos) <> 'object'
     OR (v_sheet.atributos->>'INT') IS NULL
     OR (v_sheet.atributos->>'INT') !~ '^-?[0-9]+$' THEN
    RAISE EXCEPTION 'A classe ou os atributos da ficha não permitem calcular o orçamento de perícias.';
  END IF;

  v_int_mod := FLOOR((((v_sheet.atributos->>'INT')::NUMERIC - 10) / 2))::INTEGER;
  v_budget := GREATEST(1, v_class.pericias_por_nivel + v_int_mod)::NUMERIC * (v_level + 3);
  IF v_race.id = 'humano' THEN
    v_budget := v_budget + 4 + GREATEST(v_level - 1, 0);
  END IF;

  -- A alfabetização do Bárbaro é um custo único de 2 pontos de perícia.
  -- A validação também precisa persistir ao editar perícias após a criação.
  IF v_class.id='barbaro' AND COALESCE(v_sheet.identidade->>'alfabetizado','false')='true' THEN
    v_budget:=GREATEST(0,v_budget-2);
  END IF;

  FOR v_entry IN SELECT key, value FROM jsonb_each(p_pericias)
  LOOP
    v_skill_specialization := NULL;
    v_skill_specialization_name := NULL;
    v_skill_base_id := NULL;
    IF v_entry.key ~ '^srd35_skill_(oficio|profissao)_[a-z0-9_]+$' THEN
      v_skill_base_id := CASE WHEN v_entry.key LIKE 'srd35_skill_oficio_%' THEN 'oficio' ELSE 'profissao' END;
      SELECT spec.value INTO v_skill_specialization
      FROM jsonb_array_elements(
        CASE WHEN jsonb_typeof(v_sheet.identidade->'skill_specializations')='array'
             THEN v_sheet.identidade->'skill_specializations' ELSE '[]'::jsonb END
      ) AS spec(value)
      WHERE spec.value->>'key'=v_entry.key
        AND spec.value->>'type'=v_skill_base_id;
      IF NOT FOUND THEN
        RAISE EXCEPTION 'Especialidade de perícia não cadastrada na identidade: %.',v_entry.key;
      END IF;
      v_skill_specialization_name := NULLIF(BTRIM(v_skill_specialization->>'name'),'');
      IF v_skill_specialization_name IS NULL OR length(v_skill_specialization_name)>60 THEN
        RAISE EXCEPTION 'Nome inválido para a especialidade %.',v_entry.key;
      END IF;
      SELECT sk.* INTO v_skill FROM public.srd_skills AS sk WHERE sk.id=v_skill_base_id;
    ELSE
      SELECT sk.* INTO v_skill FROM public.srd_skills AS sk WHERE sk.id=v_entry.key;
    END IF;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Perícia ou especialidade desconhecida: %.', v_entry.key;
    END IF;
    IF jsonb_typeof(v_entry.value) <> 'number'
       OR (v_entry.value #>> '{}') !~ '^(0|[1-9][0-9]*)(\.5)?$' THEN
      RAISE EXCEPTION 'Graduações inválidas para a perícia %; use zero ou valores em incrementos de 0,5.', v_entry.key;
    END IF;
    v_rank := (v_entry.value #>> '{}')::NUMERIC;
    v_is_class_skill := EXISTS (
      SELECT 1
      FROM jsonb_array_elements_text(COALESCE(v_class.pericias_classe, '[]'::JSONB)) AS class_skill(nome)
      WHERE regexp_replace(
              translate(LOWER(BTRIM(class_skill.nome)), 'áàâãäéèêëíìîïóòôõöúùûüç', 'aaaaaeeeeiiiiooooouuuuc'),
              '[^a-z0-9]+', ' ', 'g'
            ) = regexp_replace(
              translate(LOWER(BTRIM(v_skill.nome)), 'áàâãäéèêëíìîïóòôõöúùûüç', 'aaaaaeeeeiiiiooooouuuuc'),
              '[^a-z0-9]+', ' ', 'g'
            )
         OR (LOWER(BTRIM(class_skill.nome)) = 'fuga' AND v_skill.id = 'fuga')
         OR (
           regexp_replace(
             translate(LOWER(BTRIM(class_skill.nome)), 'áàâãäéèêëíìîïóòôõöúùûüç', 'aaaaaeeeeiiiiooooouuuuc'),
             '[^a-z0-9]+', ' ', 'g'
           ) = 'conhecimento qualquer'
           AND regexp_replace(
             translate(LOWER(BTRIM(v_skill.nome)), 'áàâãäéèêëíìîïóòôõöúùûüç', 'aaaaaeeeeiiiiooooouuuuc'),
             '[^a-z0-9]+', ' ', 'g'
           ) LIKE 'conhecimento %'
         )
         OR (
           v_skill.id IN ('oficio','profissao')
           AND regexp_replace(
             translate(LOWER(BTRIM(class_skill.nome)), 'áàâãäéèêëíìîïóòôõöúùûüç', 'aaaaaeeeeiiiiooooouuuuc'),
             '[^a-z0-9]+', ' ', 'g'
           ) LIKE (
             regexp_replace(
               translate(LOWER(BTRIM(v_skill.nome)), 'áàâãäéèêëíìîïóòôõöúùûüç', 'aaaaaeeeeiiiiooooouuuuc'),
               '[^a-z0-9]+', ' ', 'g'
             ) || ' %'
           )
         )
    );

    IF v_entry.key = 'srd35_skill_speak_language' THEN
      -- Falar Idioma não usa graduações nem limite de perícia: cada idioma
      -- adicional custa 1 ponto de perícia, independentemente da classe.
      IF v_rank <> TRUNC(v_rank) THEN
        RAISE EXCEPTION 'Falar Idioma exige pontos inteiros (um ponto por idioma).';
      END IF;
      v_spent := v_spent + v_rank;
    ELSIF v_is_class_skill THEN
      IF v_rank <> TRUNC(v_rank) THEN
        RAISE EXCEPTION 'Perícias de classe exigem graduações inteiras (%).', v_skill.nome;
      END IF;
      IF v_rank > v_level + 3 THEN
        RAISE EXCEPTION 'Graduações acima do limite de classe para % (máximo %).', v_skill.nome, v_level + 3;
      END IF;
      v_spent := v_spent + v_rank;
    ELSE
      IF v_rank * 2 <> TRUNC(v_rank * 2) THEN
        RAISE EXCEPTION 'Perícias cross-class exigem graduações em incrementos de 0,5 (%).', v_skill.nome;
      END IF;
      IF v_rank > (v_level + 3)::NUMERIC / 2 THEN
        RAISE EXCEPTION 'Graduações acima do limite cross-class para % (máximo %).', v_skill.nome, (v_level + 3)::NUMERIC / 2;
      END IF;
      v_spent := v_spent + (v_rank * 2);
    END IF;
  END LOOP;

  IF v_spent > v_budget THEN
    RAISE EXCEPTION 'Perícias usam % pontos; o orçamento disponível é %.', v_spent, v_budget;
  END IF;

  UPDATE public.srd_character_sheets AS sh
  SET pericias = p_pericias
  WHERE sh.character_id::TEXT = BTRIM(p_character_id);
  RETURN p_pericias;
END;
$function$
;

-- salvar_talentos_bonus_classe_inicial_srd(p_character_id text, p_talentos jsonb)
CREATE OR REPLACE FUNCTION public.salvar_talentos_bonus_classe_inicial_srd(p_character_id text, p_talentos jsonb DEFAULT '[]'::jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
DECLARE
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_character public.characters%ROWTYPE;
  v_class public.srd_classes%ROWTYPE;
  v_feat public.srd_feats%ROWTYPE;
  v_req JSONB;
  v_existing JSONB;
  v_updated JSONB;
  v_entry JSONB;
  v_feat_id TEXT;
  v_param TEXT;
  v_class_key TEXT;
  v_expected INTEGER := 0;
  v_bab INTEGER := 0;
  v_required INTEGER;
  v_stat_key TEXT;
  v_weapon_name TEXT;
  v_weapon_details JSONB;
  v_weapon_prof TEXT;
  v_has_prof BOOLEAN;
  v_owned TEXT[] := ARRAY[]::TEXT[];
  v_added TEXT[] := ARRAY[]::TEXT[];
  v_feature TEXT;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  IF NULLIF(BTRIM(p_character_id),'') IS NULL THEN RAISE EXCEPTION 'Personagem obrigatório.'; END IF;
  IF p_talentos IS NULL OR jsonb_typeof(p_talentos)<>'array' THEN
    RAISE EXCEPTION 'Talentos bônus precisam ser enviados como uma lista JSON.';
  END IF;

  SELECT ch.* INTO v_character
    FROM public.characters ch
   WHERE ch.id::text=BTRIM(p_character_id) AND ch.user_id=auth.uid()
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou sem autorização.'; END IF;

  SELECT sh.* INTO v_sheet
    FROM public.srd_character_sheets sh
   WHERE sh.character_id=v_character.id
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha D&D 3.5 não encontrada.'; END IF;
  IF COALESCE(v_sheet.nivel,1)<>1 THEN
    RAISE EXCEPTION 'Esta operação só concede características da criação de nível 1.';
  END IF;

  SELECT cl.* INTO v_class FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Classe SRD não encontrada.'; END IF;
  v_class_key:=COALESCE(v_class.class_key,'');
  v_expected:=CASE WHEN v_class_key IN ('fighter','monk') THEN 1 ELSE 0 END;
  IF jsonb_array_length(p_talentos)<>v_expected THEN
    RAISE EXCEPTION 'A classe exige % escolha(s) de talento bônus no nível 1.',v_expected;
  END IF;

  v_existing:=CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::jsonb END;
  SELECT COALESCE(array_agg(value->>'id'),'{}'::text[]) INTO v_owned
    FROM jsonb_array_elements(v_existing) AS current(value)
   WHERE value->>'id' IS NOT NULL;

  IF v_class_key IN ('fighter','monk') AND EXISTS (
    SELECT 1 FROM jsonb_array_elements(v_existing) AS saved(value)
     WHERE saved.value->>'origem'='class_bonus'
  ) THEN
    SELECT saved.value INTO v_entry
      FROM jsonb_array_elements(v_existing) AS saved(value)
     WHERE saved.value->>'origem'='class_bonus'
     LIMIT 1;
    IF jsonb_array_length(p_talentos)=1
       AND v_entry->>'id'=p_talentos->0->>'id'
       AND COALESCE(v_entry->>'parametro','')=COALESCE(p_talentos->0->>'parametro','') THEN
      RETURN jsonb_build_object('character_id',v_character.id::text,'class_key',v_class_key,'added','[]'::jsonb,'talentos',v_existing,'already_applied',true);
    END IF;
    RAISE EXCEPTION 'Já existe um talento bônus de classe gravado para este personagem.';
  END IF;

  IF v_class_key='fighter' THEN
    v_bab:=CASE
      WHEN v_class.bab_progression IN ('good','bom') THEN 1
      WHEN v_class.bab_progression IN ('average','medium','medio') THEN 0
      WHEN v_class.bab_progression IN ('poor','bad','ruim') THEN 0
      ELSE 0 END;

    v_entry:=p_talentos->0;
    IF jsonb_typeof(v_entry)<>'object' THEN RAISE EXCEPTION 'Escolha um talento bônus válido para Guerreiro.'; END IF;
    v_feat_id:=NULLIF(BTRIM(v_entry->>'id'),'');
    v_param:=BTRIM(COALESCE(v_entry->>'parametro',''));
    IF v_feat_id IS NULL THEN RAISE EXCEPTION 'Selecione o talento bônus do Guerreiro.'; END IF;
    IF v_feat_id NOT IN (
      'srd35_feat_blind_fight','srd35_feat_cleave','srd35_feat_combat_expertise',
      'srd35_feat_deflect_arrows','esquiva','srd35_feat_far_shot','srd35_feat_great_cleave',
      'srd35_feat_improved_bull_rush','srd35_feat_improved_critical','srd35_feat_improved_disarm',
      'srd35_feat_improved_feint','srd35_feat_improved_grapple','iniciativa_aprimorada',
      'srd35_feat_improved_overrun','srd35_feat_improved_precise_shot','srd35_feat_improved_shield_bash',
      'srd35_feat_improved_sunder','srd35_feat_improved_trip','srd35_feat_improved_two_weapon_fighting',
      'srd35_feat_manyshot','srd35_feat_mobility','srd35_feat_mounted_archery','srd35_feat_mounted_combat',
      'srd35_feat_point_blank_shot','ataque_poderoso','srd35_feat_precise_shot','srd35_feat_quick_draw',
      'srd35_feat_rapid_reload','srd35_feat_rapid_shot','srd35_feat_ride_by_attack',
      'srd35_feat_shot_on_the_run','srd35_feat_spring_attack','srd35_feat_spirited_charge',
      'srd35_feat_trample','srd35_feat_two_weapon_fighting','srd35_feat_weapon_finesse',
      'foco_em_arma','srd35_feat_weapon_specialization','srd35_feat_greater_weapon_focus',
      'srd35_feat_greater_weapon_specialization','srd35_feat_whirlwind_attack',
      'srd35_feat_improved_unarmed_strike','reflexos_de_combate','srd35_feat_stunning_fist'
    ) THEN RAISE EXCEPTION 'Este talento não faz parte da lista de bônus do Guerreiro.'; END IF;

    SELECT f.* INTO v_feat FROM public.srd_feats f WHERE f.id=v_feat_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Talento do catálogo não encontrado.'; END IF;
    v_req:=COALESCE(v_feat.requisitos,'{}'::jsonb);
    IF COALESCE(v_req->>'type','General')<>'General' THEN
      RAISE EXCEPTION 'O talento bônus do Guerreiro precisa ser geral.';
    END IF;
    IF v_feat.exige_parametro AND v_param='' THEN
      RAISE EXCEPTION 'Informe o parâmetro exigido por %.',v_feat.nome;
    ELSIF NOT COALESCE(v_feat.exige_parametro,false) AND v_param<>'' THEN
      RAISE EXCEPTION '% não aceita parâmetro.',v_feat.nome;
    END IF;
    IF v_feat_id=ANY(v_owned) THEN
      IF EXISTS (
        SELECT 1 FROM jsonb_array_elements(v_existing) AS saved(value)
         WHERE saved.value->>'id'=v_feat_id
           AND saved.value->>'origem'='class_bonus'
           AND COALESCE(saved.value->>'parametro','')=v_param
      ) THEN
        RETURN jsonb_build_object('character_id',v_character.id::text,'class_key',v_class_key,'added','[]'::jsonb,'talentos',v_existing,'already_applied',true);
      END IF;
      RAISE EXCEPTION 'O personagem já possui %.',v_feat.nome;
    END IF;

    FOR v_stat_key IN SELECT unnest(ARRAY['FOR','DES','CON','INT','SAB','CAR']) LOOP
      v_required:=COALESCE(NULLIF(v_req->>(lower(v_stat_key)||'_min'),'')::integer,0);
      IF COALESCE(NULLIF(v_sheet.atributos->>v_stat_key,'')::integer,10)<v_required THEN
        RAISE EXCEPTION '% exige % %.',v_feat.nome,v_stat_key,v_required;
      END IF;
    END LOOP;
    v_required:=COALESCE(NULLIF(v_req->>'bab_min','')::integer,0);
    IF v_bab<v_required THEN RAISE EXCEPTION '% exige BBA +%.',v_feat.nome,v_required; END IF;
    IF COALESCE(NULLIF(v_req->>'class_level_min','')::integer,0)>1
       OR (NULLIF(v_req->>'class_key_required','') IS NOT NULL AND v_req->>'class_key_required'<>'fighter') THEN
      RAISE EXCEPTION 'O nível de Guerreiro ainda não atende aos pré-requisitos de %.',v_feat.nome;
    END IF;
    FOR v_feature IN SELECT value FROM jsonb_array_elements_text(COALESCE(v_req->'feat_ids','[]'::jsonb)) AS prereq(value) LOOP
      IF NOT (v_feature=ANY(v_owned)) THEN
        RAISE EXCEPTION '% exige o talento prévio %.',v_feat.nome,v_feature;
      END IF;
    END LOOP;
    IF v_req ? 'skill_ranks' THEN
      FOR v_stat_key IN SELECT key FROM jsonb_each(v_req->'skill_ranks') LOOP
        IF COALESCE(NULLIF(v_sheet.pericias->>v_stat_key,'')::numeric,0)<COALESCE(NULLIF(v_req->'skill_ranks'->>v_stat_key,'')::numeric,0) THEN
          RAISE EXCEPTION '% exige mais graduações em %.',v_feat.nome,v_stat_key;
        END IF;
      END LOOP;
    END IF;
    IF v_param<>'' AND COALESCE(v_req->>'parameter_type','') IN ('weapon','weapon_martial','weapon_exotic','crossbow') THEN
      SELECT e.nome,e.detalhes INTO v_weapon_name,v_weapon_details
        FROM public.srd_equipment e
       WHERE public.srd35_equipment_slot(e.categoria,e.nome)='arma'
         AND public.srd35_normalizar_parametro_talento(e.nome)=public.srd35_normalizar_parametro_talento(v_param)
       LIMIT 1;
      IF NOT FOUND THEN RAISE EXCEPTION 'Arma escolhida não existe no catálogo SRD.'; END IF;
      v_weapon_prof:=priv.srd_weapon_proficiency(v_weapon_details,v_weapon_name);
      IF v_sheet.raca_id='anao' AND regexp_replace(lower(translate(v_weapon_name,'ã','a')),'[^a-z0-9]+','','g') IN ('waraxedwarven','dwarvenwaraxe','urgroshdwarven','dwarvenurgrosh','machadodeguerraanao','urgroshanao') THEN v_weapon_prof:='martial'; END IF;
      IF COALESCE(v_req->>'parameter_type','')='weapon_martial' AND v_weapon_prof<>'martial' THEN
        RAISE EXCEPTION 'Escolha uma arma marcial.';
      ELSIF COALESCE(v_req->>'parameter_type','')='weapon_exotic' AND v_weapon_prof<>'exotic' THEN
        RAISE EXCEPTION 'Escolha uma arma exótica.';
      END IF;
      IF COALESCE((v_req->>'weapon_proficiency_required')::boolean,false) THEN
        v_has_prof:=EXISTS(
          SELECT 1 FROM jsonb_array_elements_text(COALESCE(v_class.dados_tecnicos->'proficiencias'->'armas','[]'::jsonb)) AS prof(value)
           WHERE public.srd35_normalizar_parametro_talento(prof.value)=public.srd35_normalizar_parametro_talento(v_weapon_name)
              OR (public.srd35_normalizar_parametro_talento(prof.value)='armassimples' AND v_weapon_prof='simple')
              OR (public.srd35_normalizar_parametro_talento(prof.value)='todasasarmassimplesemarciais' AND v_weapon_prof IN ('simple','martial'))
        );
        IF NOT v_has_prof THEN RAISE EXCEPTION 'Guerreiro não é proficiente com %.',v_weapon_name; END IF;
      END IF;
    END IF;
    v_updated:=v_existing||jsonb_build_array(jsonb_build_object('id',v_feat_id,'parametro',NULLIF(v_param,''),'origem','class_bonus'));
    v_added:=array_append(v_added,v_feat_id);

  ELSIF v_class_key='monk' THEN
    v_entry:=p_talentos->0;
    IF jsonb_typeof(v_entry)<>'object' THEN RAISE EXCEPTION 'Escolha um talento bônus válido para Monge.'; END IF;
    v_feat_id:=NULLIF(BTRIM(v_entry->>'id'),'');
    IF v_feat_id NOT IN ('srd35_feat_improved_grapple','srd35_feat_stunning_fist') THEN
      RAISE EXCEPTION 'No nível 1, Monge escolhe Agarrar Aprimorado ou Ataque Atordoante.';
    END IF;
    IF v_feat_id=ANY(v_owned) THEN
      IF EXISTS (
        SELECT 1 FROM jsonb_array_elements(v_existing) AS saved(value)
         WHERE saved.value->>'id'=v_feat_id AND saved.value->>'origem'='class_bonus'
      ) THEN
        RETURN jsonb_build_object('character_id',v_character.id::text,'class_key',v_class_key,'added','[]'::jsonb,'talentos',v_existing,'already_applied',true);
      END IF;
      RAISE EXCEPTION 'O personagem já possui esse talento.';
    END IF;
    IF NOT ('srd35_feat_improved_unarmed_strike'=ANY(v_owned)) THEN
      v_updated:=v_existing||jsonb_build_array(jsonb_build_object('id','srd35_feat_improved_unarmed_strike','parametro',null,'origem','class_feature'));
      v_added:=array_append(v_added,'srd35_feat_improved_unarmed_strike');
    ELSE
      v_updated:=v_existing;
    END IF;
    v_updated:=v_updated||jsonb_build_array(jsonb_build_object('id',v_feat_id,'parametro',null,'origem','class_bonus'));
    v_added:=array_append(v_added,v_feat_id);

  ELSIF v_class_key='wizard' THEN
    IF jsonb_array_length(p_talentos)<>0 THEN RAISE EXCEPTION 'Mago recebe Escrever Pergaminho automaticamente; não escolha talento de classe aqui.'; END IF;
    IF NOT ('srd35_feat_scribe_scroll'=ANY(v_owned)) THEN
      v_updated:=v_existing||jsonb_build_array(jsonb_build_object('id','srd35_feat_scribe_scroll','parametro',null,'origem','class_feature'));
      v_added:=array_append(v_added,'srd35_feat_scribe_scroll');
    ELSE
      v_updated:=v_existing;
    END IF;
  ELSE
    IF jsonb_array_length(p_talentos)<>0 THEN RAISE EXCEPTION 'Esta classe não recebe uma escolha de talento bônus no nível 1.'; END IF;
    v_updated:=v_existing;
  END IF;

  UPDATE public.srd_character_sheets
     SET talentos=v_updated
   WHERE character_id=v_character.id;

  RETURN jsonb_build_object('character_id',v_character.id::text,'class_key',v_class_key,'added',to_jsonb(v_added),'talentos',v_updated);
END;
$function$
;

-- salvar_talentos_srd(p_character_id text, p_talentos jsonb)
CREATE OR REPLACE FUNCTION public.salvar_talentos_srd(p_character_id text, p_talentos jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_class public.srd_classes%ROWTYPE;
  v_race public.srd_races%ROWTYPE;
  v_entry JSONB;
  v_feat public.srd_feats%ROWTYPE;
  v_req JSONB;
  v_pair RECORD;
  v_feat_id TEXT;
  v_prereq_id TEXT;
  v_parameter TEXT;
  v_prereq_parameter TEXT;
  v_parameter_norm TEXT;
  v_prereq_norm TEXT;
  v_value_text TEXT;
  v_required INTEGER;
  v_bab INTEGER;
  v_level INTEGER;
  v_caster_level INTEGER;
  v_count INTEGER;
  v_skill_id TEXT;
  v_skill_required NUMERIC;
  v_skill_value NUMERIC;
  v_feature TEXT;
  v_has_prerequisite BOOLEAN;
  v_stat_key TEXT;
  v_parameter_source TEXT;
  v_normalized_parameter TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF p_character_id IS NULL OR BTRIM(p_character_id) = '' THEN
    RAISE EXCEPTION 'Identificador de personagem inválido.';
  END IF;
  IF p_talentos IS NULL OR jsonb_typeof(p_talentos) <> 'array' THEN
    RAISE EXCEPTION 'Os talentos devem ser informados como um array JSON.';
  END IF;

  SELECT sh.* INTO v_sheet
  FROM public.srd_character_sheets AS sh
  JOIN public.characters AS ch ON ch.id::TEXT = sh.character_id::TEXT
  WHERE sh.character_id::TEXT = BTRIM(p_character_id)
    AND ch.user_id = auth.uid();
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Ficha não encontrada ou não pertence ao usuário.';
  END IF;

  SELECT cl.* INTO v_class FROM public.srd_classes AS cl WHERE cl.id = v_sheet.classe_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Classe SRD da ficha não encontrada.'; END IF;
  SELECT ra.* INTO v_race FROM public.srd_races AS ra WHERE ra.id = v_sheet.raca_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Raça SRD da ficha não encontrada.'; END IF;

  v_level := v_sheet.nivel;
  IF v_level IS NULL OR v_level < 1 THEN RAISE EXCEPTION 'Nível da ficha inválido.'; END IF;
  v_count := jsonb_array_length(p_talentos);
  IF v_count <> (CASE WHEN v_race.id = 'humano' THEN 2 ELSE 1 END) THEN
    RAISE EXCEPTION 'A ficha deve possuir exatamente % talento(s).',
      CASE WHEN v_race.id = 'humano' THEN 2 ELSE 1 END;
  END IF;
  IF EXISTS (
    SELECT 1 FROM jsonb_array_elements(p_talentos) AS picked(value)
    JOIN public.srd_feats AS feat ON feat.id=picked.value->>'id'
    GROUP BY feat.id,COALESCE((feat.requisitos->>'repeatable')::boolean,false)
    HAVING COUNT(*)>1 AND NOT COALESCE((feat.requisitos->>'repeatable')::boolean,false)
  ) THEN
    RAISE EXCEPTION 'Este talento não pode ser escolhido mais de uma vez.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM jsonb_array_elements(p_talentos) AS picked(value)
    JOIN public.srd_feats AS feat ON feat.id=picked.value->>'id'
    WHERE COALESCE((feat.requisitos->>'repeatable')::boolean,false)
      AND feat.requisitos->>'repeatable_mode'='different_parameter'
    GROUP BY feat.id,public.srd35_normalizar_parametro_talento(COALESCE(picked.value->>'parametro',''))
    HAVING COUNT(*)>1
  ) THEN
    RAISE EXCEPTION 'Um talento repetível exige uma escolha diferente em cada aquisição.';
  END IF;

  CASE LOWER(COALESCE(v_class.bab_progression, ''))
    WHEN 'good' THEN v_bab := v_level;
    WHEN 'average' THEN v_bab := FLOOR((3 * v_level)::NUMERIC / 4)::INTEGER;
    WHEN 'medium' THEN v_bab := FLOOR((3 * v_level)::NUMERIC / 4)::INTEGER;
    WHEN 'poor' THEN v_bab := FLOOR(v_level::NUMERIC / 2)::INTEGER;
    ELSE RAISE EXCEPTION 'Progressão de BBA desconhecida para a classe.';
  END CASE;

  v_caster_level := CASE COALESCE(v_class.class_key, '')
    WHEN 'wizard' THEN v_level
    WHEN 'sorcerer' THEN v_level
    WHEN 'cleric' THEN v_level
    WHEN 'druid' THEN v_level
    WHEN 'bard' THEN v_level
    WHEN 'paladin' THEN GREATEST(v_level - 3, 0)
    WHEN 'ranger' THEN GREATEST(v_level - 3, 0)
    ELSE 0
  END;

  FOR v_entry IN SELECT value FROM jsonb_array_elements(p_talentos)
  LOOP
    IF jsonb_typeof(v_entry) <> 'object' OR jsonb_typeof(v_entry->'id') <> 'string' THEN
      RAISE EXCEPTION 'Cada talento deve ser um objeto com um identificador id.';
    END IF;
    v_feat_id := NULLIF(BTRIM(v_entry->>'id'), '');
    IF v_feat_id IS NULL THEN RAISE EXCEPTION 'Identificador de talento inválido.'; END IF;

    SELECT f.* INTO v_feat FROM public.srd_feats AS f WHERE f.id = v_feat_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Talento desconhecido: %.', v_feat_id; END IF;
    v_req := COALESCE(v_feat.requisitos, '{}'::JSONB);
    v_parameter := NULLIF(BTRIM(v_entry->>'parametro'), '');

    IF v_feat.exige_parametro AND v_parameter IS NULL THEN
      RAISE EXCEPTION 'O talento % exige um parâmetro (por exemplo, a escolha indicada na ficha).', v_feat.nome;
    END IF;
    IF NOT COALESCE(v_feat.exige_parametro, false)
       AND v_parameter IS NOT NULL
       AND v_feat.id <> 'srd35_feat_spell_mastery' THEN
      RAISE EXCEPTION 'O talento % não aceita parâmetro.', v_feat.nome;
    END IF;

    FOREACH v_stat_key IN ARRAY ARRAY['FOR','DES','CON','INT','SAB','CAR']
    LOOP
      IF v_req ? (LOWER(v_stat_key) || '_min') THEN
        v_value_text := v_sheet.atributos->>v_stat_key;
        IF v_value_text IS NULL OR v_value_text !~ '^-?[0-9]+$' THEN
          RAISE EXCEPTION 'A ficha não possui um valor % válido.', v_stat_key;
        END IF;
        v_required := (v_req->>(LOWER(v_stat_key) || '_min'))::INTEGER;
        IF v_value_text::INTEGER < v_required THEN
          RAISE EXCEPTION 'O talento % exige % %.', v_feat.nome, v_stat_key, v_required;
        END IF;
      END IF;
    END LOOP;

    IF v_req ? 'bab_min' THEN
      v_required := (v_req->>'bab_min')::INTEGER;
      IF v_bab < v_required THEN RAISE EXCEPTION 'O talento % exige BBA +%.', v_feat.nome, v_required; END IF;
    END IF;
    IF v_req ? 'character_level_min' THEN
      v_required := (v_req->>'character_level_min')::INTEGER;
      IF v_level < v_required THEN RAISE EXCEPTION 'O talento % exige nível de personagem %.', v_feat.nome, v_required; END IF;
    END IF;
    IF v_req ? 'class_level_min' THEN
      v_required := (v_req->>'class_level_min')::INTEGER;
      IF (v_req ? 'class_key_required' AND COALESCE(v_req->>'class_key_required','') <> COALESCE(v_class.class_key,''))
         OR v_level < v_required THEN
        RAISE EXCEPTION 'O talento % exige nível % na classe indicada.', v_feat.nome, v_required;
      END IF;
    END IF;
    IF v_req ? 'caster_level_min' THEN
      v_required := (v_req->>'caster_level_min')::INTEGER;
      IF v_caster_level < v_required THEN
        RAISE EXCEPTION 'O talento % exige nível de conjurador %.', v_feat.nome, v_required;
      END IF;
    END IF;

    IF jsonb_typeof(v_req->'skill_ranks') = 'object' THEN
      FOR v_pair IN SELECT key, value FROM jsonb_each(v_req->'skill_ranks')
      LOOP
        v_skill_id := v_pair.key;
        v_skill_required := CASE WHEN jsonb_typeof(v_pair.value)='number' THEN (v_pair.value::TEXT)::NUMERIC ELSE (v_pair.value#>>'{}')::NUMERIC END;
        v_value_text := COALESCE(v_sheet.pericias,'{}'::JSONB)->>v_skill_id;
        IF v_value_text IS NULL OR v_value_text !~ '^-?[0-9]+([.][0-9]+)?$' THEN
          v_skill_value := 0;
        ELSE
          v_skill_value := v_value_text::NUMERIC;
        END IF;
        IF v_skill_value < v_skill_required THEN
          RAISE EXCEPTION 'O talento % exige % graduação(ões) na perícia %.', v_feat.nome, v_skill_required, v_skill_id;
        END IF;
      END LOOP;
    END IF;

    IF jsonb_typeof(v_req->'feat_ids') = 'array' THEN
      FOR v_prereq_id IN SELECT jsonb_array_elements_text(v_req->'feat_ids')
      LOOP
        IF v_prereq_id = v_feat_id THEN RAISE EXCEPTION 'Pré-requisito circular no talento %.',v_feat.nome; END IF;
        v_has_prerequisite :=
          EXISTS (SELECT 1 FROM jsonb_array_elements(p_talentos) AS picked(value) WHERE picked.value->>'id'=v_prereq_id)
          OR EXISTS (SELECT 1 FROM jsonb_array_elements(COALESCE(v_sheet.talentos,'[]'::JSONB)) AS saved(value) WHERE saved.value->>'id'=v_prereq_id);
        IF NOT v_has_prerequisite THEN
          SELECT nome INTO v_value_text FROM public.srd_feats WHERE id=v_prereq_id;
          RAISE EXCEPTION 'O talento % exige o talento %.',v_feat.nome,COALESCE(v_value_text,v_prereq_id);
        END IF;
      END LOOP;
    END IF;

    IF jsonb_typeof(v_req->'feat_parameters')='object' THEN
      FOR v_pair IN SELECT key, value FROM jsonb_each_text(v_req->'feat_parameters')
      LOOP
        v_prereq_id := v_pair.key;
        IF NOT EXISTS (
          SELECT 1
            FROM (
              SELECT picked.value FROM jsonb_array_elements(p_talentos) AS picked(value)
              UNION ALL
              SELECT saved.value FROM jsonb_array_elements(COALESCE(v_sheet.talentos,'[]'::JSONB)) AS saved(value)
            ) AS owned(value)
           WHERE owned.value->>'id'=v_prereq_id
             AND public.srd35_normalizar_parametro_talento(COALESCE(owned.value->>'parametro',''))
                 = public.srd35_normalizar_parametro_talento(v_pair.value)
        ) THEN
          RAISE EXCEPTION 'O talento % exige o talento % com o parâmetro %.',v_feat.nome,v_prereq_id,v_pair.value;
        END IF;
      END LOOP;
    END IF;

    IF jsonb_typeof(v_req->'feat_parameter_matches')='array' THEN
      FOR v_prereq_id IN SELECT jsonb_array_elements_text(v_req->'feat_parameter_matches')
      LOOP
        IF NOT EXISTS (
          SELECT 1
            FROM (
              SELECT picked.value FROM jsonb_array_elements(p_talentos) AS picked(value)
              UNION ALL
              SELECT saved.value FROM jsonb_array_elements(COALESCE(v_sheet.talentos,'[]'::JSONB)) AS saved(value)
            ) AS owned(value)
           WHERE owned.value->>'id'=v_prereq_id
             AND public.srd35_normalizar_parametro_talento(COALESCE(owned.value->>'parametro',''))
                 = public.srd35_normalizar_parametro_talento(v_parameter)
             AND public.srd35_normalizar_parametro_talento(v_parameter)<>''
        ) THEN
          RAISE EXCEPTION 'O talento % exige a mesma arma ou escola do talento pré-requisito %.',v_feat.nome,v_prereq_id;
        END IF;
      END LOOP;
    END IF;

    IF jsonb_typeof(v_req->'conditional_ability_min')='object' THEN
      FOR v_pair IN SELECT key, value FROM jsonb_each(v_req->'conditional_ability_min')
      LOOP
        v_stat_key := v_pair.key;
        v_required := (v_pair.value->>'minimum')::INTEGER;
        IF EXISTS (
          SELECT 1 FROM jsonb_array_elements_text(COALESCE(v_pair.value->'parameters','[]'::JSONB)) AS parameter(value)
          WHERE public.srd35_normalizar_parametro_talento(parameter.value)
              = public.srd35_normalizar_parametro_talento(v_parameter)
        ) THEN
          v_value_text := v_sheet.atributos->>v_stat_key;
          IF v_value_text IS NULL OR v_value_text !~ '^-?[0-9]+$' OR v_value_text::INTEGER < v_required THEN
            RAISE EXCEPTION 'O parâmetro escolhido para % exige % %.',v_feat.nome,v_stat_key,v_required;
          END IF;
        END IF;
      END LOOP;
    END IF;

    IF jsonb_typeof(v_req->'special_ability_required')='string' THEN
      v_feature := v_req->>'special_ability_required';
      IF v_feature='wild_shape' AND NOT (v_class.class_key='druid' AND v_level>=5) THEN
        RAISE EXCEPTION 'O talento % exige Forma Selvagem, disponível na progressão básica de druida a partir do nível 5.',v_feat.nome;
      ELSIF v_feature='turn_or_rebuke_creatures' AND NOT ((v_class.class_key='cleric' AND v_level>=1) OR (v_class.class_key='paladin' AND v_level>=4)) THEN
        RAISE EXCEPTION 'O talento % exige habilidade de expulsar ou fascinar mortos-vivos.',v_feat.nome;
      ELSIF v_feature='familiar' AND NOT (v_class.class_key IN ('wizard','sorcerer') AND v_level>=1) THEN
        RAISE EXCEPTION 'O talento % exige uma classe com habilidade de adquirir familiar.',v_feat.nome;
      ELSIF v_feature NOT IN ('wild_shape','turn_or_rebuke_creatures','familiar') THEN
        RAISE EXCEPTION 'Não foi possível validar o pré-requisito especial % do talento %.',v_feature,v_feat.nome;
      END IF;
    END IF;
  END LOOP;

  UPDATE public.srd_character_sheets AS sh
  SET talentos = p_talentos
  WHERE sh.character_id::TEXT = BTRIM(p_character_id);
  RETURN p_talentos;
END;
$function$
;

-- save_sheet(p_char bigint, p_dados jsonb, p_motivo text)
CREATE OR REPLACE FUNCTION public.save_sheet(p_char bigint, p_dados jsonb, p_motivo text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare
  c public.characters; s public.character_sheets; papel text; gm boolean; st text;
  nivel int; atr jsonb; k text; v int; soma int := 0; mx int; cls text; cult text;
  arm text; esc text; it public.items; per jsonb; npericias int;
  chaves text[] := array['FOR','DES','CON','INT','SAB','CAR'];
begin
  select * into c from public.characters where id = p_char;
  if not found then raise exception 'Personagem inexistente.'; end if;
  papel := public.my_role(c.campaign_id); gm := papel = 'GM';
  if not gm and (papel is distinct from 'PLAYER' or c.user_id is distinct from auth.uid()) then
    raise exception 'Você só edita a sua própria ficha.'; end if;
  select state into st from public.campaigns where id = c.campaign_id;
  if not gm and st = 'COMBATE' then raise exception 'Fichas só podem ser editadas fora de combate.'; end if;
  if gm and c.user_id is distinct from auth.uid()
     and char_length(coalesce(trim(p_motivo), '')) < 3 then
    raise exception 'Informe o motivo da edição (Mestre editando ficha de jogador).'; end if;
  select * into s from public.character_sheets where character_id = p_char for update;
  if not found then insert into public.character_sheets(character_id) values (p_char) returning * into s; end if;
  nivel := public.level_from_xp(c.xp); mx := public.attr_max(nivel);
  cls  := case when p_dados ? 'classe'  then nullif(p_dados->>'classe',  '') else s.classe  end;
  cult := case when p_dados ? 'cultura' then nullif(p_dados->>'cultura', '') else s.cultura end;
  if cls  is not null and not exists (select 1 from public.classes    where id = cls)  then raise exception 'Classe inválida.';   end if;
  if cult is not null and not exists (select 1 from public.continents where id = cult) then raise exception 'Cultura inválida.'; end if;
  if s.ready and not gm and (cls is distinct from s.classe or cult is distinct from s.cultura) then
    raise exception 'Classe e cultura estão trancadas (ficha confirmada). Peça ao Mestre para reabrir.'; end if;
  atr := coalesce(p_dados->'atributos', s.atributos);
  if jsonb_typeof(atr) <> 'object' or (select count(*) from jsonb_object_keys(atr)) <> 6 then
    raise exception 'Atributos inválidos (use FOR, DES, CON, INT, SAB e CAR).'; end if;
  foreach k in array chaves loop
    if atr->>k is null or atr->>k !~ '^[0-9]{1,2}$' then raise exception 'Atributo % ausente ou inválido.', k; end if;
    v := (atr->>k)::int;
    if v < 1 or v > mx then raise exception 'Atributo % fora do limite (1 a %).', k, mx; end if;
    if s.ready and not gm and v < (s.atributos->>k)::int then
      raise exception 'Atributos não podem diminuir após confirmar a ficha.'; end if;
    soma := soma + v;
  end loop;
  if soma > public.attr_points(nivel) then
    raise exception 'Pontos de atributo excedidos (% de %).', soma, public.attr_points(nivel); end if;
  per := s.pericias;
  if p_dados ? 'pericias' then
    if jsonb_typeof(p_dados->'pericias') <> 'object' then raise exception 'Perícias inválidas.'; end if;
    if not gm then
      if priv.pericias_completas(p_dados->'pericias') is distinct from priv.pericias_completas(s.pericias) then
        raise exception 'Somente o Mestre define bônus de perícia.'; end if;
    else
      select count(*) into npericias from public.skills;
      if (select count(*) from jsonb_object_keys(p_dados->'pericias')) <> npericias then
        raise exception 'Envie todas as % perícias.', npericias; end if;
      for k in select jsonb_object_keys(p_dados->'pericias') loop
        if not exists (select 1 from public.skills where nome = k) then raise exception 'Perícia inexistente: %.', k; end if;
        if p_dados->'pericias'->>k !~ '^[0-4]$' then raise exception 'Bônus de perícia vai de 0 a 4 (%).', k; end if;
      end loop;
      per := p_dados->'pericias';
    end if;
  end if;
  arm := case when p_dados ? 'armadura' then nullif(p_dados->>'armadura', '') else s.armadura end;
  esc := case when p_dados ? 'escudo'   then nullif(p_dados->>'escudo',   '') else s.escudo   end;
  if arm is not null then
    select * into it from public.items where id = arm;
    if not found or it.categoria <> 'armadura' then raise exception 'Armadura inválida.'; end if;
    if not exists (select 1 from public.inventory where character_id = p_char and item_id = arm and qtd > 0) then
      raise exception 'Você não possui % no inventário.', it.nome; end if;
    if (atr->>'FOR')::int < coalesce((it.requisitos->>'FOR')::int, 0) then
      raise exception 'Exige FOR % para usar %.', it.requisitos->>'FOR', it.nome; end if;
  end if;
  if esc is not null then
    select * into it from public.items where id = esc;
    if not found or it.categoria <> 'escudo' then raise exception 'Escudo inválido.'; end if;
    if not exists (select 1 from public.inventory where character_id = p_char and item_id = esc and qtd > 0) then
      raise exception 'Você não possui % no inventário.', it.nome; end if;
    if (atr->>'FOR')::int < coalesce((it.requisitos->>'FOR')::int, 0) then
      raise exception 'Exige FOR % para usar %.', it.requisitos->>'FOR', it.nome; end if;
  end if;
  -- NÃO mexe em preserve_pv: só gm_reopen_sheet (liga) e confirm_sheet (desliga)
  update public.character_sheets
     set classe = cls, cultura = cult, atributos = atr, pericias = per,
         armadura = arm, escudo = esc, updated_at = now()
   where character_id = p_char;
  update public.inventory set equipado = coalesce(item_id = arm, false)
    where character_id = p_char and item_id in (select id from public.items where categoria = 'armadura');
  update public.inventory set equipado = coalesce(item_id = esc, false)
    where character_id = p_char and item_id in (select id from public.items where categoria = 'escudo');
  if gm and c.user_id is distinct from auth.uid() then
    perform priv.log(c.campaign_id, 'GM_ACTION',
      jsonb_build_object('acao', 'editar_ficha', 'personagem', p_char, 'motivo', trim(p_motivo), 'por', auth.uid()));
  end if;
  return public.calc_sheet(p_char);
end $function$
;

-- scene_config(cid bigint, p_state text, p_cols integer, p_rows integer)
CREATE OR REPLACE FUNCTION public.scene_config(cid bigint, p_state text DEFAULT NULL::text, p_cols integer DEFAULT NULL::integer, p_rows integer DEFAULT NULL::integer)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare st text;
begin
  perform priv.need_gm(cid);
  st := coalesce(p_state, (select state from campaigns where id = cid));
  if st not in ('EXPLORACAO', 'COMBATE', 'PAUSA') or p_cols not between 8 and 300 or p_rows not between 8 and 300 then raise exception 'Configuração inválida.'; end if;
  update scenes set cols = coalesce(p_cols, cols), rows = coalesce(p_rows, rows), manual = manual or p_cols is not null or p_rows is not null,
    active_token = case when st = 'COMBATE' then active_token else null end where campaign_id = cid;
  update campaigns set state = st where id = cid;
  perform priv.log(cid, 'CENA_CONFIG', jsonb_build_object('estado', st, 'cols', p_cols, 'rows', p_rows, 'por', auth.uid()));
end $function$
;

-- sell_price(p_item text)
CREATE OR REPLACE FUNCTION public.sell_price(p_item text)
 RETURNS integer
 LANGUAGE sql
 STABLE
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  select coalesce((select floor(preco_ou * 0.5)::int from public.items where id = p_item), 0)
$function$
;

-- send_chat(cid bigint, p_texto text, p_visibilidade text)
CREATE OR REPLACE FUNCTION public.send_chat(cid bigint, p_texto text, p_visibilidade text DEFAULT 'PUBLIC'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare papel text;
begin
  papel := public.my_role(cid);
  if papel is null then raise exception 'Você não participa desta mesa.'; end if;
  if p_visibilidade not in ('PUBLIC','GM_ONLY','SELF_AND_GM') then
    raise exception 'Visibilidade inválida.';
  end if;
  if papel <> 'GM' and p_visibilidade = 'GM_ONLY' then
    raise exception 'Só o Mestre envia mensagens GM_ONLY.';
  end if;
  if p_texto is null or char_length(trim(p_texto)) < 1 or char_length(p_texto) > 500 then
    raise exception 'Mensagem entre 1 e 500 caracteres.';
  end if;
  insert into public.campaign_log(campaign_id, type, data, visibilidade)
  values (cid, 'CHAT',
    jsonb_build_object('autor', auth.uid(), 'nome', (select username from public.profiles where id = auth.uid()), 'texto', trim(p_texto)),
    p_visibilidade);
  return jsonb_build_object('ok', true);
end $function$
;

-- sentar_personagem_na_mesa(p_campaign_id bigint, p_character_id text)
CREATE OR REPLACE FUNCTION public.sentar_personagem_na_mesa(p_campaign_id bigint, p_character_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_user UUID := auth.uid();
  v_role TEXT;
  v_character public.characters%ROWTYPE;
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'Não autenticado.'; END IF;
  SELECT member.role INTO v_role
  FROM public.members AS member
  WHERE member.campaign_id = p_campaign_id AND member.user_id = v_user;
  IF v_role IS DISTINCT FROM 'PLAYER' THEN
    RAISE EXCEPTION 'Somente um jogador pode sentar na mesa com sua ficha.';
  END IF;

  SELECT character.* INTO v_character
  FROM public.characters AS character
  WHERE character.id::TEXT = BTRIM(p_character_id) AND character.user_id = v_user
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'A ficha não pertence à sua conta.'; END IF;
  UPDATE public.characters SET campaign_id = p_campaign_id
  WHERE id::TEXT = BTRIM(p_character_id) AND user_id = v_user;
  RETURN JSONB_BUILD_OBJECT('ok', TRUE, 'campaign_id', p_campaign_id,
                            'character_id', p_character_id);
END
$function$
;

-- set_turn(cid bigint, p_token bigint)
CREATE OR REPLACE FUNCTION public.set_turn(cid bigint, p_token bigint)
 RETURNS void
 LANGUAGE plpgsql
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
$function$
;

-- short_rest(p_char bigint)
CREATE OR REPLACE FUNCTION public.short_rest(p_char bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare c public.characters; s public.character_sheets; pm_max int; ganho int;
begin
  select * into c from public.characters where id = p_char;
  if not found then raise exception 'Personagem inexistente.'; end if;
  if c.user_id is distinct from auth.uid() and public.my_role(c.campaign_id) is distinct from 'GM' then raise exception 'Sem permissão.'; end if;
  select * into s from public.character_sheets where character_id = p_char for update;
  pm_max := public.calc_pm(s.classe, (s.atributos->>'INT')::int);
  ganho := floor(pm_max * 0.25)::int;
  update public.character_sheets set pm_atual = least(pm_max, pm_atual + ganho) where character_id = p_char;
  perform priv.log(c.campaign_id, 'DESCANSO_CURTO', jsonb_build_object('char', p_char, 'pm_ganho', ganho));
  return jsonb_build_object('pm_ganho', ganho);
end $function$
;

-- sou_membro(cid bigint)
CREATE OR REPLACE FUNCTION public.sou_membro(cid bigint)
 RETURNS boolean
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
  select exists(
    select 1 from members
    where campaign_id = cid and user_id = auth.uid()
  );
$function$
;

-- spell_dc(p_int integer, p_circulo integer)
CREATE OR REPLACE FUNCTION public.spell_dc(p_int integer, p_circulo integer)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$ select 10 + p_int + (p_circulo - 1) $function$
;

-- srd35_deslocamento_personagem(p_character_id text, p_base_speed_m numeric)
CREATE OR REPLACE FUNCTION public.srd35_deslocamento_personagem(p_character_id text, p_base_speed_m numeric)
 RETURNS numeric
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_attrs JSONB;
  v_character_owner uuid;
  v_character_campaign_id bigint;
  v_race_id TEXT;
  v_race_name TEXT;
  v_size TEXT;
  v_barbarian_level INTEGER := 0;
  v_monk_level INTEGER := 0;
  v_gold NUMERIC := 0;
  v_strength INTEGER := 10;
  v_base_speed NUMERIC := COALESCE(p_base_speed_m,9);
  v_speed NUMERIC;
  v_weight_kg NUMERIC := 0;
  v_heavy_armor BOOLEAN := FALSE;
  v_medium_heavy_armor BOOLEAN := FALSE;
  v_any_armor BOOLEAN := FALSE;
  v_is_dwarf BOOLEAN := FALSE;
  v_heavy_table NUMERIC[] := ARRAY[5,10,15,20,25,30,35,40,45,50,57.5,65,75,87.5,100,115,130,150,175,200,230,260,300,350,400,460,520,600,700]::NUMERIC[];
  v_table_strength INTEGER;
  v_decades INTEGER := 0;
  v_heavy_max NUMERIC;
  v_light_max NUMERIC;
  v_medium_max NUMERIC;
  v_size_multiplier NUMERIC := 1;
  v_load TEXT := 'light';
  v_size_normalized TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Autenticação obrigatória.';
  END IF;
  SELECT ch.user_id,ch.campaign_id
    INTO v_character_owner,v_character_campaign_id
    FROM public.characters ch
   WHERE ch.id::text=BTRIM(p_character_id);
  IF NOT FOUND THEN RETURN v_base_speed; END IF;
  IF v_character_owner IS DISTINCT FROM auth.uid()
     AND NOT (v_character_campaign_id IS NOT NULL
       AND public.my_role(v_character_campaign_id) IN ('GM','PLAYER'))
     AND NOT EXISTS (
       SELECT 1
         FROM public.campaigns camp
         JOIN public.members member ON member.campaign_id=camp.id
        CROSS JOIN LATERAL jsonb_array_elements(
          CASE WHEN jsonb_typeof(camp.cba_data->'tokens')='array'
               THEN camp.cba_data->'tokens' ELSE '[]'::jsonb END
        ) tok(value)
        WHERE member.user_id=auth.uid()
          AND tok.value->>'tipo'='npc'
          AND tok.value->>'sourceCharacterId'=BTRIM(p_character_id)
     ) THEN
    RAISE EXCEPTION 'Você não tem acesso ao deslocamento desta ficha.';
  END IF;
  SELECT sh.atributos,sh.raca_id,COALESCE(sh.ouro,0),race.nome,race.tamanho
    INTO v_attrs,v_race_id,v_gold,v_race_name,v_size
    FROM public.srd_character_sheets sh
    LEFT JOIN public.srd_races race ON race.id::TEXT=sh.raca_id::TEXT
   WHERE sh.character_id::TEXT=BTRIM(p_character_id);
  IF NOT FOUND THEN RETURN v_base_speed; END IF;

  -- Prefer the normalized per-class ledger. Fall back to the sheet's total
  -- level only for legacy single-class characters that have no ledger rows.
  SELECT
    COALESCE(
      MAX(cl.class_level) FILTER (WHERE class.class_key='barbarian'),
      CASE WHEN NOT EXISTS (
        SELECT 1 FROM public.srd_character_class_levels any_level
         WHERE any_level.character_id=sh.character_id
      ) AND primary_class.class_key='barbarian'
      THEN GREATEST(1,COALESCE(sh.nivel,1)) ELSE 0 END
    ),
    COALESCE(
      MAX(cl.class_level) FILTER (WHERE class.class_key='monk'),
      CASE WHEN NOT EXISTS (
        SELECT 1 FROM public.srd_character_class_levels any_level
         WHERE any_level.character_id=sh.character_id
      ) AND primary_class.class_key='monk'
      THEN GREATEST(1,COALESCE(sh.nivel,1)) ELSE 0 END
    )
    INTO v_barbarian_level,v_monk_level
    FROM public.srd_character_sheets sh
    LEFT JOIN public.srd_classes primary_class ON primary_class.id=sh.classe_id
    LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
    LEFT JOIN public.srd_classes class ON class.id=cl.class_id
   WHERE sh.character_id::TEXT=BTRIM(p_character_id)
   GROUP BY sh.character_id,sh.nivel,primary_class.class_key;

  v_strength:=GREATEST(1,COALESCE((v_attrs->>'FOR')::INTEGER,10));
  v_is_dwarf:=v_race_id='anao' OR public.srd35_normalizar_parametro_talento(COALESCE(v_race_name,''))='anao';
  v_size_normalized:=public.srd35_normalizar_parametro_talento(COALESCE(v_size,'medio'));

  -- Imported SRD weights are pounds; legacy Portuguese entries are kilograms.
  SELECT
    COALESCE(SUM(COALESCE(eq.peso,0)*
      CASE WHEN eq.detalhes ? 'weight_lb'
             OR POSITION('lb' IN LOWER(COALESCE(eq.detalhes->>'weight',''))) > 0
             OR POSITION('lb' IN LOWER(COALESCE(eq.detalhes->>'weight_text',''))) > 0
             OR eq.detalhes->>'source_dataset'='olimot/srd-v3.5-md'
           THEN 0.5 ELSE 1 END*GREATEST(1,ce.quantidade)),0),
    COALESCE(BOOL_OR(ce.equipado AND armor.kind='heavyarmor'),FALSE),
    COALESCE(BOOL_OR(ce.equipado AND armor.kind IN ('mediumarmor','heavyarmor')),FALSE),
    COALESCE(BOOL_OR(ce.equipado AND armor.kind IN ('lightarmor','mediumarmor','heavyarmor','shield')),FALSE)
    INTO v_weight_kg,v_heavy_armor,v_medium_heavy_armor,v_any_armor
    FROM public.srd_character_equipment ce
    JOIN public.srd_equipment eq ON eq.id=ce.equipment_id
    CROSS JOIN LATERAL (
      SELECT CASE
        WHEN public.srd35_normalizar_parametro_talento(COALESCE(eq.categoria,'')) IN ('armadura','armor') THEN
          CASE
            WHEN COALESCE(eq.bonus_max_des,eq.max_des,NULLIF(eq.detalhes->>'max_dex_bonus','')::NUMERIC,99)<=1 THEN 'heavyarmor'
            WHEN COALESCE(eq.bonus_max_des,eq.max_des,NULLIF(eq.detalhes->>'max_dex_bonus','')::NUMERIC,99)<=3 THEN 'mediumarmor'
            ELSE 'lightarmor'
          END
        WHEN public.srd35_normalizar_parametro_talento(COALESCE(eq.categoria,'')) IN ('escudo','shield') THEN 'shield'
        ELSE public.srd35_normalizar_parametro_talento(COALESCE(eq.detalhes->>'category',eq.categoria,''))
      END AS kind
    ) armor
   WHERE ce.character_id=BTRIM(p_character_id);

  -- 500 PO weigh 5 kg.
  v_weight_kg:=v_weight_kg+(v_gold/100.0);

  v_size_multiplier:=CASE
    WHEN v_size_normalized IN ('minusculo','fine') THEN 0.125
    WHEN v_size_normalized IN ('diminuto','diminutive') THEN 0.25
    WHEN v_size_normalized IN ('miudo','tiny') THEN 0.5
    WHEN v_size_normalized IN ('pequeno','small') THEN 0.75
    WHEN v_size_normalized IN ('grande','large') THEN 2
    WHEN v_size_normalized IN ('enorme','huge') THEN 4
    WHEN v_size_normalized IN ('imenso','gargantuan') THEN 8
    WHEN v_size_normalized='colossal' THEN 16
    ELSE 1
  END;

  IF v_strength>=30 THEN
    v_decades:=FLOOR((v_strength-20)/10.0)::INTEGER;
    v_table_strength:=v_strength-(10*v_decades);
  ELSE
    v_table_strength:=v_strength;
  END IF;
  v_table_strength:=GREATEST(1,LEAST(29,v_table_strength));
  v_heavy_max:=v_heavy_table[v_table_strength]*POWER(4::NUMERIC,v_decades)*v_size_multiplier;
  v_light_max:=FLOOR((v_heavy_max/3.0)*2.0)/2.0;
  v_medium_max:=FLOOR((v_heavy_max*2.0/3.0)*2.0)/2.0;

  IF v_weight_kg>v_medium_max THEN
    v_load:='heavy';
  ELSIF v_weight_kg>v_light_max THEN
    v_load:='medium';
  ELSE
    v_load:='light';
  END IF;

  v_speed:=v_base_speed;

  -- Barbarian Fast Movement: +3 m with no/light/medium armor; medium load is
  -- allowed; heavy armor and heavy load suppress the bonus.
  IF v_barbarian_level>=1 AND NOT v_heavy_armor AND v_load<>'heavy' THEN
    v_speed:=v_speed+3;
  -- Monk Fast Movement: +3 m per three monk levels, unarmored and lightly loaded.
  ELSIF v_monk_level>=3 AND NOT v_any_armor AND v_load='light' THEN
    v_speed:=v_speed+(3*FLOOR(v_monk_level/3.0));
  END IF;

  -- Dwarves ignore speed reductions from medium/heavy armor and loads.
  IF NOT v_is_dwarf AND (v_medium_heavy_armor OR v_load IN ('medium','heavy')) THEN
    IF v_speed>=12 THEN
      v_speed:=9;
    ELSIF v_speed>=9 THEN
      v_speed:=6;
    ELSIF v_speed>=6 THEN
      v_speed:=4.5;
    ELSE
      v_speed:=GREATEST(1.5,FLOOR((v_speed*0.75)/1.5)*1.5);
    END IF;
  END IF;

  RETURN ROUND(v_speed,2);
END;
$function$
;

-- srd35_equipment_ca_bonus(p_equipment_id text)
CREATE OR REPLACE FUNCTION public.srd35_equipment_ca_bonus(p_equipment_id text)
 RETURNS integer
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$
  SELECT COALESCE(
    NULLIF(gear.bonus_ca,0),
    NULLIF(gear.ca_bonus,0),
    CASE WHEN lower(COALESCE(gear.categoria,''))='armor_and_shields'
               AND gear.nome ~ '\+[0-9]+'
         THEN substring(gear.nome FROM '\+([0-9]+)')::INTEGER END,
    0
  )::INTEGER
  FROM public.srd_equipment AS gear WHERE gear.id=p_equipment_id;
$function$
;

-- srd35_equipment_slot(p_categoria text, p_nome text)
CREATE OR REPLACE FUNCTION public.srd35_equipment_slot(p_categoria text, p_nome text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO ''
AS $function$
  SELECT CASE
    WHEN lower(btrim(COALESCE(p_categoria,''))) IN ('arma','weapon','specific_weapons')
      OR lower(COALESCE(p_categoria,'')) LIKE '%weapon%'
      THEN 'arma'
    WHEN lower(btrim(COALESCE(p_categoria,''))) IN ('armadura','light armor','medium armor','heavy armor','specific_armors')
      THEN 'armadura'
    WHEN lower(btrim(COALESCE(p_categoria,''))) IN ('escudo','shields','specific_shields')
      THEN 'escudo'
    WHEN lower(btrim(COALESCE(p_categoria,'')))='armor_and_shields'
      THEN CASE WHEN lower(COALESCE(p_nome,'')) LIKE '%shield%' THEN 'escudo' ELSE 'armadura' END
    WHEN lower(btrim(COALESCE(p_categoria,''))) IN ('acessorio','rings','rods','staffs','wands','wondrous_items')
      THEN 'acessorio'
    ELSE ''
  END;
$function$
;

-- srd35_normalizar_parametro_talento(p_text text)
CREATE OR REPLACE FUNCTION public.srd35_normalizar_parametro_talento(p_text text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE PARALLEL SAFE
 SET search_path TO 'public', 'pg_temp'
AS $function$
  WITH n AS (
    SELECT regexp_replace(
      lower(translate(COALESCE(p_text,''),'ÁÀÂÃÉÊÍÓÔÕÚÜÇáàâãéêíóôõúüç','AAAAEEIOOOUUCaaaaeeiooouuc')),
      '[^a-z0-9]+','','g'
    ) AS value
  )
  SELECT CASE value
    WHEN 'conjuracao' THEN 'conjuration'
    WHEN 'conjuration' THEN 'conjuration'
    WHEN 'abjuracao' THEN 'abjuration'
    WHEN 'abjuration' THEN 'abjuration'
    WHEN 'adivinhacao' THEN 'divination'
    WHEN 'divination' THEN 'divination'
    WHEN 'encantamento' THEN 'enchantment'
    WHEN 'enchantment' THEN 'enchantment'
    WHEN 'invocacao' THEN 'evocation'
    WHEN 'evocation' THEN 'evocation'
    WHEN 'ilusao' THEN 'illusion'
    WHEN 'illusion' THEN 'illusion'
    WHEN 'necromancia' THEN 'necromancy'
    WHEN 'necromancy' THEN 'necromancy'
    WHEN 'transmutacao' THEN 'transmutation'
    WHEN 'transmutation' THEN 'transmutation'
    WHEN 'espadabastarda' THEN 'bastardsword'
    WHEN 'bastardsword' THEN 'bastardsword'
    WHEN 'machadodeguerraaanao' THEN 'dwarvenwaraxe'
    WHEN 'machadodeguerraanao' THEN 'dwarvenwaraxe'
    WHEN 'dwarvenwaraxe' THEN 'dwarvenwaraxe'
    WHEN 'waraxedwarven' THEN 'dwarvenwaraxe'
    WHEN 'urgroshdwarven' THEN 'dwarvenurgrosh'
    WHEN 'dwarvenurgrosh' THEN 'dwarvenurgrosh'
    WHEN 'urgroshanao' THEN 'dwarvenurgrosh'
    WHEN 'espada longa' THEN 'longsword'
    WHEN 'espadalonga' THEN 'longsword'
    WHEN 'longsword' THEN 'longsword'
    ELSE value
  END
  FROM n
$function$
;

-- srd_aplicar_dano_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_attack_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)
CREATE OR REPLACE FUNCTION public.srd_aplicar_dano_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_attack_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_attack priv.srd_aoo_attacks%rowtype;
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_target jsonb;
  v_tokens jsonb;
  v_scene jsonb;
  v_idx bigint;
  v_count integer;
  v_expr text;
  v_dice integer;
  v_faces integer;
  v_flat integer:=0;
  v_mult integer:=1;
  v_roll integer:=0;
  v_raw integer;
  v_final integer;
  v_hp integer;
  v_max integer;
  v_new_hp integer;
  v_type text;
  i integer;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then raise exception 'Somente o Mestre pode aplicar dano.'; end if;
  if p_idempotency_key is null or p_damage_rolls is null or cardinality(p_damage_rolls)<1
    or cardinality(p_damage_rolls)>30 or array_position(p_damage_rolls,null) is not null
    or exists(select 1 from unnest(p_damage_rolls) x where x<1 or x>1000) then
    raise exception 'Resultados de dano inválidos.';
  end if;
  select * into v_attack from priv.srd_aoo_attacks
  where campaign_id=p_campaign_id and attack_id=p_attack_id for update;
  if not found or v_attack.created_by<>auth.uid() or v_attack.actor_character_id is not null then
    raise exception 'Ataque natural não encontrado ou sem autorização.';
  end if;
  if v_attack.status='damage_applied' and v_attack.damage_idempotency_key=p_idempotency_key then
    return jsonb_build_object('attack_id',p_attack_id,'status','damage_applied','damage_applied',v_attack.damage_applied,'replayed',true);
  end if;
  if v_attack.status<>'awaiting_damage' then raise exception 'Ataque natural não está pronto para receber dano.'; end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where pending_id=v_attack.pending_id and campaign_id=p_campaign_id for update;
  if not found or v_pending.status<>'waiting_reactions' then raise exception 'Movimento pendente não está ativo.'; end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
    or coalesce(v_campaign.combat_data->>'active','false')<>'true'
    or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
    or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'A iniciativa mudou antes do dano.';
  end if;
  v_expr:=coalesce(v_attack.resolution_data->>'damage_expression',v_attack.resolution_data->>'weapon_damage');
  if v_expr !~ '^[0-9]+d[0-9]+([+-][0-9]+)?$' then raise exception 'Expressão de dano natural inválida: %.',v_expr; end if;
  v_dice:=substring(v_expr from '^([0-9]+)d')::integer;
  v_faces:=substring(v_expr from 'd([0-9]+)')::integer;
  v_flat:=coalesce(nullif(substring(v_expr from 'd[0-9]+([+-][0-9]+)$'),'')::integer,0);
  v_mult:=case when v_attack.is_critical then coalesce(nullif(v_attack.resolution_data->>'critical_multiplier','')::integer,2) else 1 end;
  if v_dice<1 or v_dice>10 or v_faces<2 or v_faces>100 or v_mult<1 or v_mult>5
    or cardinality(p_damage_rolls)<>v_dice*v_mult then raise exception 'Quantidade de dados não corresponde ao dano natural.'; end if;
  for i in 1..cardinality(p_damage_rolls) loop
    if p_damage_rolls[i]>v_faces then raise exception 'Resultado excede d%.',v_faces; end if;
    v_roll:=v_roll+p_damage_rolls[i];
  end loop;
  v_raw:=greatest(0,v_roll+v_flat+priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'damage')
    +v_flat*greatest(0,v_mult-1));
  v_type:=lower(coalesce(v_attack.resolution_data->>'damage_type','physical'));
  v_type:=case v_type when 'cortante' then 'slashing' when 'perfurante' then 'piercing'
    when 'impacto' then 'bludgeoning' else v_type end;

  select count(*)::integer,min(t.ordinality) into v_count,v_idx
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) with ordinality t(token,ordinality)
  where t.token->>'id'=v_attack.target_token_id and t.token->>'tipo' in ('player','npc','monstro');
  if v_count<>1 then raise exception 'Alvo ausente ou duplicado.'; end if;
  v_tokens:=case when jsonb_typeof(v_campaign.cba_data->'tokens')='array' then v_campaign.cba_data->'tokens' else '[]'::jsonb end;
  v_target:=v_tokens->(v_idx::integer-1);
  if v_target->>'tipo'='player' then
    select pv_atual,pv_max into v_hp,v_max from public.srd_character_sheets
    where character_id::text=v_attack.target_token_id for update;
    if not found or v_max is null or v_max<1 then raise exception 'PV do alvo inválidos.'; end if;
    v_final:=priv.srd_adjust_damage(p_campaign_id,'character',v_attack.target_token_id,v_type,v_raw);
    v_new_hp:=greatest(-10,least(v_max,coalesce(v_hp,v_max)-v_final));
    update public.srd_character_sheets set pv_atual=v_new_hp where character_id::text=v_attack.target_token_id;
    perform priv.srd_sync_character_vital_condition(v_attack.target_token_id,v_new_hp,false);
  else
    if coalesce(v_target->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' then raise exception 'PV máximo do alvo inválido.'; end if;
    v_max:=(v_target->>'maxHp')::integer;
    v_hp:=case when coalesce(v_target->>'hp','') ~ '^-?[0-9]{1,6}$' then (v_target->>'hp')::integer else v_max end;
    v_final:=priv.srd_adjust_damage(p_campaign_id,'token',v_attack.target_token_id,v_type,v_raw);
    v_new_hp:=greatest(-10,least(v_max,v_hp-v_final));
  end if;
  v_target:=v_target||jsonb_build_object('hp',v_new_hp,'maxHp',v_max);
  v_scene:=coalesce(v_campaign.cba_data,'{}'::jsonb)||jsonb_build_object('tokens',jsonb_set(v_tokens,ARRAY[(v_idx-1)::text],v_target,false));
  update public.campaigns set cba_data=v_scene where id=p_campaign_id;
  perform priv.srd_sync_linked_npc_token_vitals(p_campaign_id,v_attack.target_token_id,v_new_hp,v_max);
  update priv.srd_aoo_attacks set status='damage_applied',damage_rolls=p_damage_rolls,
    damage_applied=v_final,damage_idempotency_key=p_idempotency_key,damage_applied_at=now(),
    resolution_data=resolution_data||jsonb_build_object('damage_roll_sum',v_roll,'damage_raw',v_raw,
      'damage_final',v_final,'critical_multiplier_applied',v_mult)
  where attack_id=p_attack_id returning * into v_attack;
  update priv.srd_aoo_pending_movements p
  set pending_reactions=jsonb_set(p.pending_reactions,ARRAY[
    (select (e.ordinality-1)::text from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
     where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1)
  ],(
    select e.value||jsonb_build_object('status','damage_applied','damage_applied',v_final)
    from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
    where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1
  ),false),updated_at=now() where p.pending_id=v_attack.pending_id;
  return jsonb_build_object('attack_id',p_attack_id,'status','damage_applied','damage_applied',v_final,
    'target_hp',v_new_hp,'target_max_hp',v_max,'damage_expression',v_expr,'damage_rolls',p_damage_rolls,
    'critical',v_attack.is_critical,'critical_multiplier',v_mult,'replayed',false);
end;
$function$
;

-- srd_aplicar_dano_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)
CREATE OR REPLACE FUNCTION public.srd_aplicar_dano_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_attack priv.srd_aoo_attacks%rowtype;
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_sheet public.srd_character_sheets%rowtype;
  v_race public.srd_races%rowtype;
  v_weapon public.srd_equipment%rowtype;
  v_target jsonb;
  v_tokens jsonb;
  v_scene jsonb;
  v_target_idx bigint;
  v_target_count integer;
  v_expr text;
  v_dice integer;
  v_faces integer;
  v_mult integer:=1;
  v_roll_sum integer:=0;
  v_str_bonus integer:=0;
  v_damage_bonus integer:=0;
  v_critical_static integer:=0;
  v_specialization integer:=0;
  v_raw integer:=0;
  v_final integer:=0;
  v_damage_type text;
  v_hp integer;
  v_max_hp integer;
  v_new_hp integer;
  v_idem uuid;
  i integer;
  v_end_meta jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode aplicar dano de ataque de oportunidade.';
  end if;
  if p_idempotency_key is null or p_damage_rolls is null
     or cardinality(p_damage_rolls)<1 or cardinality(p_damage_rolls)>30
     or array_position(p_damage_rolls,null) is not null
     or exists(select 1 from unnest(p_damage_rolls) x where x<1 or x>1000) then
    raise exception 'Resultados de dano inválidos.';
  end if;
  select * into v_attack from priv.srd_aoo_attacks
  where attack_id=p_attack_id and campaign_id=p_campaign_id for update;
  if not found or v_attack.created_by<>auth.uid() then raise exception 'Ataque não encontrado ou sem autorização.'; end if;
  if v_attack.damage_idempotency_key=p_idempotency_key and v_attack.status='damage_applied' then
    return jsonb_build_object('attack_id',p_attack_id,'status','damage_applied',
      'damage_applied',v_attack.damage_applied,'replayed',true);
  end if;
  if v_attack.status<>'awaiting_damage' then raise exception 'Ataque ainda não está pronto para receber dano.'; end if;

  select * into v_pending from priv.srd_aoo_pending_movements
  where pending_id=v_attack.pending_id and campaign_id=p_campaign_id for update;
  if not found or v_pending.status<>'waiting_reactions' then raise exception 'Movimento pendente não está ativo.'; end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
     or coalesce(v_campaign.combat_data->>'active','false')<>'true'
     or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
     or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'A iniciativa mudou antes da aplicação do dano.';
  end if;

  select * into v_sheet from public.srd_character_sheets where character_id=v_attack.actor_character_id;
  select * into v_race from public.srd_races where id=v_sheet.raca_id;
  select * into v_weapon from public.srd_equipment eq
  join public.srd_character_weapon_instances wi on wi.equipment_id=eq.id
  where wi.instance_id=v_attack.weapon_instance_id
    and wi.character_id=v_attack.actor_character_id::text
    and wi.equipado is true and wi.hand_slot=v_attack.weapon_hand_slot;
  if not found then raise exception 'Arma não está mais equipada.'; end if;

  v_end_meta:=case when v_attack.weapon_end='off' then coalesce(v_weapon.detalhes->'weapon_end_off','{}'::jsonb)
    when v_attack.weapon_end='main' then coalesce(v_weapon.detalhes->'weapon_end_main','{}'::jsonb)
    else '{}'::jsonb end;
  v_expr:=coalesce(
    case when lower(coalesce(v_race.tamanho,'')) in ('pequeno','small')
      then v_end_meta->>'damage_small' else v_end_meta->>'damage_medium' end,
    case when lower(coalesce(v_race.tamanho,'')) in ('pequeno','small')
      then v_weapon.detalhes->>'damage_small' else v_weapon.detalhes->>'damage_medium' end,
    v_weapon.dano
  );
  if v_expr !~ '^[0-9]+d[0-9]+$' then
    raise exception 'Expressão de dano não normalizada: %.',coalesce(v_expr,'vazia');
  end if;
  v_dice:=split_part(v_expr,'d',1)::integer;
  v_faces:=split_part(v_expr,'d',2)::integer;
  if v_dice<1 or v_dice>10 or v_faces<2 or v_faces>100 then
    raise exception 'Expressão de dano fora dos limites suportados.';
  end if;
  v_mult:=case when v_attack.is_critical
    then coalesce(nullif(v_attack.resolution_data->>'critical_multiplier','')::integer,2) else 1 end;
  if v_mult<1 or v_mult>5 then raise exception 'Multiplicador crítico inválido.'; end if;
  if cardinality(p_damage_rolls)<>v_dice*v_mult then
    raise exception 'A arma exige % resultados de dano (% dados x multiplicador %).',v_dice*v_mult,v_dice,v_mult;
  end if;
  for i in 1..cardinality(p_damage_rolls) loop
    if p_damage_rolls[i]>v_faces then raise exception 'Resultado excede o dado d%.',v_faces; end if;
    v_roll_sum:=v_roll_sum+p_damage_rolls[i];
  end loop;

  v_damage_bonus:=priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'damage');
  v_str_bonus:=floor((coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)
    +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'strength')-10)::numeric/2)::integer;
  if v_attack.weapon_hand_slot='off_hand' then
    v_str_bonus:=floor(v_str_bonus/2.0)::integer;
  elsif coalesce((v_weapon.detalhes->>'weapon_two_handed')::boolean,false)
    and not coalesce((v_weapon.detalhes->>'weapon_double')::boolean,false) then
    v_str_bonus:=floor(v_str_bonus*1.5)::integer;
  end if;
  v_damage_bonus:=v_damage_bonus+v_str_bonus;
  v_critical_static:=v_str_bonus;
  select coalesce(sum(case f->>'id'
    when 'srd35_feat_weapon_specialization' then 2
    when 'srd35_feat_greater_weapon_specialization' then 2 else 0 end),0)::integer
  into v_specialization
  from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
  where f->>'id' in ('srd35_feat_weapon_specialization','srd35_feat_greater_weapon_specialization')
    and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))
      =public.srd35_normalizar_parametro_talento(v_weapon.nome);
  v_damage_bonus:=v_damage_bonus+v_specialization;
  v_critical_static:=v_critical_static+v_specialization;

  v_raw:=greatest(0,v_roll_sum+v_damage_bonus+(v_critical_static*greatest(0,v_mult-1)));
  v_damage_type:=lower(coalesce(v_end_meta->>'damage_type',v_weapon.tipo_dano,'bludgeoning'));
  v_damage_type:=case v_damage_type when 'cortante' then 'slashing'
    when 'perfurante' then 'piercing' when 'impacto' then 'bludgeoning'
    when 'cortante/perfurante' then 'physical' when 'impacto/perfurante' then 'physical'
    else v_damage_type end;

  select count(*)::integer,min(t.ordinality) into v_target_count,v_target_idx
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) with ordinality t(token,ordinality)
  where t.token->>'id'=v_attack.target_token_id and t.token->>'tipo' in ('player','npc','monstro');
  if v_target_count<>1 then raise exception 'Alvo ausente ou duplicado na cena.'; end if;
  v_tokens:=case when jsonb_typeof(v_campaign.cba_data->'tokens')='array' then v_campaign.cba_data->'tokens' else '[]'::jsonb end;
  v_target:=v_tokens->(v_target_idx::integer-1);
  if v_target->>'tipo'='player' then
    select sh.pv_atual,sh.pv_max into v_hp,v_max_hp
    from public.srd_character_sheets sh where sh.character_id::text=v_attack.target_token_id for update;
    if not found or v_max_hp is null or v_max_hp<1 then raise exception 'Ficha alvo sem PV válidos.'; end if;
    v_final:=priv.srd_adjust_damage(p_campaign_id,'character',v_attack.target_token_id,v_damage_type,v_raw);
    v_new_hp:=greatest(-10,least(v_max_hp,coalesce(v_hp,v_max_hp)-v_final));
    update public.srd_character_sheets set pv_atual=v_new_hp where character_id::text=v_attack.target_token_id;
    perform priv.srd_sync_character_vital_condition(v_attack.target_token_id,v_new_hp,false);
  else
    if coalesce(v_target->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' then raise exception 'PV máximo do alvo inválido.'; end if;
    v_max_hp:=(v_target->>'maxHp')::integer;
    v_hp:=case when coalesce(v_target->>'hp','') ~ '^-?[0-9]{1,6}$' then (v_target->>'hp')::integer else v_max_hp end;
    v_final:=priv.srd_adjust_damage(p_campaign_id,'token',v_attack.target_token_id,v_damage_type,v_raw);
    v_new_hp:=greatest(-10,least(v_max_hp,v_hp-v_final));
  end if;
  v_target:=v_target||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp);
  v_scene:=coalesce(v_campaign.cba_data,'{}'::jsonb)||jsonb_build_object(
    'tokens',jsonb_set(v_tokens,ARRAY[(v_target_idx-1)::text],v_target,false));
  update public.campaigns set cba_data=v_scene where id=p_campaign_id;
  perform priv.srd_sync_linked_npc_token_vitals(p_campaign_id,v_attack.target_token_id,v_new_hp,v_max_hp);

  update priv.srd_aoo_attacks set status='damage_applied',damage_rolls=p_damage_rolls,
    damage_applied=v_final,damage_idempotency_key=p_idempotency_key,damage_applied_at=now(),
    resolution_data=resolution_data||jsonb_build_object('damage_expression',v_expr,
      'damage_roll_sum',v_roll_sum,'damage_bonus',v_damage_bonus,'damage_raw',v_raw,
      'damage_final',v_final,'critical_multiplier_applied',v_mult,'damage_type',v_damage_type)
  where attack_id=p_attack_id returning * into v_attack;

  update priv.srd_aoo_pending_movements p
  set pending_reactions=jsonb_set(p.pending_reactions,ARRAY[
    (select (e.ordinality-1)::text from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
     where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1)
  ],(
    select e.value||jsonb_build_object('status','damage_applied','damage_applied',v_final)
    from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
    where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1
  ),false),updated_at=now()
  where p.pending_id=v_attack.pending_id;

  return jsonb_build_object('attack_id',p_attack_id,'status','damage_applied',
    'damage_applied',v_final,'target_hp',v_new_hp,'target_max_hp',v_max_hp,
    'damage_expression',v_expr,'damage_rolls',p_damage_rolls,
    'critical',v_attack.is_critical,'critical_multiplier',v_mult,'replayed',false);
end;
$function$
;

-- srd_apply_campaign_condition(p_campaign_id bigint, p_target_kind text, p_target_id text, p_condition_id text, p_duration_rounds integer, p_notes jsonb)
CREATE OR REPLACE FUNCTION public.srd_apply_campaign_condition(p_campaign_id bigint, p_target_kind text, p_target_id text, p_condition_id text, p_duration_rounds integer DEFAULT NULL::integer, p_notes jsonb DEFAULT '{}'::jsonb)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode administrar condições diretamente.';
  END IF;
  RETURN priv.srd_apply_campaign_condition(
    p_campaign_id,p_target_kind,p_target_id,p_condition_id,
    p_duration_rounds,COALESCE(p_notes,'{}'::jsonb),NULL
  );
END;
$function$
;

-- srd_apply_campaign_effect(p_campaign_id bigint, p_target_kind text, p_target_id text, p_effect_kind text, p_effect_data jsonb, p_duration_rounds integer, p_source_spell_id text, p_concentration_actor_id text)
CREATE OR REPLACE FUNCTION public.srd_apply_campaign_effect(p_campaign_id bigint, p_target_kind text, p_target_id text, p_effect_kind text, p_effect_data jsonb, p_duration_rounds integer DEFAULT NULL::integer, p_source_spell_id text DEFAULT NULL::text, p_concentration_actor_id text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
DECLARE v_id bigint; v_expiry integer;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode administrar efeitos diretamente.';
  END IF;
  v_id:=priv.srd_apply_campaign_effect(
    p_campaign_id,p_target_kind,p_target_id,p_effect_kind,p_effect_data,
    p_duration_rounds,p_source_spell_id,p_concentration_actor_id
  );
  SELECT expires_round INTO v_expiry
    FROM public.srd_campaign_effects WHERE effect_instance_id=v_id;
  RETURN jsonb_build_object('effect_instance_id',v_id,'expires_round',v_expiry,'active',true);
END;
$function$
;

-- srd_apply_toughness_hp_delta()
CREATE OR REPLACE FUNCTION public.srd_apply_toughness_hp_delta()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
DECLARE
  v_old_count integer := 0;
  v_new_count integer := 0;
  v_delta integer := 0;
  v_new_max integer := 0;
  v_new_current integer := 0;
BEGIN
  IF TG_OP='UPDATE' THEN
    SELECT count(*)::integer INTO v_old_count
      FROM jsonb_array_elements(
        CASE WHEN jsonb_typeof(OLD.talentos)='array' THEN OLD.talentos ELSE '[]'::jsonb END
      ) AS feat(value)
     WHERE COALESCE(feat.value->>'id',feat.value #>> '{}')='tenacidade';
  END IF;

  SELECT count(*)::integer INTO v_new_count
    FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(NEW.talentos)='array' THEN NEW.talentos ELSE '[]'::jsonb END
    ) AS feat(value)
   WHERE COALESCE(feat.value->>'id',feat.value #>> '{}')='tenacidade';

  v_delta := (v_new_count-v_old_count)*3;
  IF v_delta=0 THEN RETURN NEW; END IF;

  v_new_max := COALESCE(NEW.pv_max,CASE WHEN TG_OP='UPDATE' THEN OLD.pv_max END,0);
  v_new_current := COALESCE(
    NEW.pv_atual,
    CASE WHEN TG_OP='UPDATE' THEN OLD.pv_atual END,
    v_new_max
  );

  NEW.pv_max := GREATEST(1,v_new_max+v_delta);
  NEW.pv_atual := GREATEST(0,LEAST(NEW.pv_max,v_new_current+v_delta));
  RETURN NEW;
END;
$function$
;

-- srd_calcular_ca_personagem_srd(p_campaign_id bigint, p_character_id text, p_attack_context text)
CREATE OR REPLACE FUNCTION public.srd_calcular_ca_personagem_srd(p_campaign_id bigint, p_character_id text, p_attack_context text DEFAULT 'normal'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_character public.characters%ROWTYPE;
  v_context text:=lower(COALESCE(NULLIF(BTRIM(p_attack_context),''),'normal'));
  v_barbarian_level integer:=0;
  v_rogue_level integer:=0;
  v_armor_bonus integer:=0;
  v_shield_bonus integer:=0;
  v_max_dex integer:=99;
  v_dex_score integer:=10;
  v_dex_modifier integer:=0;
  v_dex_applied integer:=0;
  v_size_modifier integer:=0;
  v_effect_modifier integer:=0;
  v_trap_sense_bonus integer:=0;
  v_flatfooted boolean:=false;
  v_other_dex_loss boolean:=false;
  v_uncanny_dodge boolean:=false;
  v_improved_uncanny_dodge boolean:=false;
  v_lose_dex boolean:=false;
  v_final_ac integer:=10;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF v_context NOT IN ('normal','flatfooted','invisible','trap') THEN
    RAISE EXCEPTION 'Contexto de ataque inválido.';
  END IF;

  SELECT * INTO v_character
    FROM public.characters
   WHERE id::text=BTRIM(p_character_id)
     AND campaign_id=p_campaign_id
     AND (user_id=auth.uid() OR public.my_role(p_campaign_id)='GM');
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou sem acesso à campanha.'; END IF;

  SELECT * INTO v_sheet
    FROM public.srd_character_sheets
   WHERE character_id=v_character.id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD do personagem não encontrada.'; END IF;

  SELECT COALESCE(
    MAX(cl.class_level) FILTER (WHERE cls.class_key='barbarian'),
    CASE WHEN NOT EXISTS (
      SELECT 1 FROM public.srd_character_class_levels any_level
       WHERE any_level.character_id=v_sheet.character_id
    ) AND v_sheet.classe_id='barbaro'
    THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
  ), COALESCE(
    MAX(cl.class_level) FILTER (WHERE cls.class_key='rogue'),
    CASE WHEN NOT EXISTS (
      SELECT 1 FROM public.srd_character_class_levels any_level
       WHERE any_level.character_id=v_sheet.character_id
    ) AND v_sheet.classe_id='ladino'
    THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
  )
    INTO v_barbarian_level,v_rogue_level
    FROM public.srd_character_sheets sh
    LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
    LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
   WHERE sh.character_id=v_sheet.character_id
   GROUP BY sh.character_id,sh.classe_id,sh.nivel;

  v_uncanny_dodge:=COALESCE(v_barbarian_level,0)>=2 OR COALESCE(v_rogue_level,0)>=4;
  v_improved_uncanny_dodge:=COALESCE(v_barbarian_level,0)>=5 OR COALESCE(v_rogue_level,0)>=8;

  WITH equipped AS (
    SELECT eq.id,
           lower(COALESCE(eq.detalhes->>'category',eq.categoria,'')) AS category,
           lower(COALESCE(eq.tipo,'')) AS item_type,
           lower(COALESCE(eq.nome,'')) AS item_name,
           COALESCE(eq.bonus_max_des,eq.max_des) AS max_dex,
           public.srd35_equipment_ca_bonus(eq.id) AS ca_bonus
      FROM public.srd_character_equipment ce
      JOIN public.srd_equipment eq ON eq.id=ce.equipment_id
     WHERE ce.character_id=v_character.id::text AND ce.equipado=true
  ), classified AS (
    SELECT *,
      CASE
        WHEN category='armor_and_shields' THEN
          CASE WHEN item_name LIKE '%shield%' THEN 'shield' ELSE 'armor' END
        WHEN category LIKE '%shield%' OR category LIKE '%escudo%'
          OR item_type LIKE '%shield%' OR item_type LIKE '%escudo%' THEN 'shield'
        WHEN category LIKE '%armor%' OR category LIKE '%armadura%'
          OR item_type LIKE '%armor%' OR item_type LIKE '%armadura%' THEN 'armor'
        ELSE 'other'
      END AS equipment_kind
    FROM equipped
  )
  SELECT
    COALESCE(SUM(ca_bonus) FILTER (WHERE equipment_kind='armor'),0)::integer,
    COALESCE(SUM(ca_bonus) FILTER (WHERE equipment_kind='shield'),0)::integer,
    COALESCE(MIN(max_dex) FILTER (WHERE equipment_kind='armor' AND max_dex IS NOT NULL),99)::integer
    INTO v_armor_bonus,v_shield_bonus,v_max_dex
    FROM classified;

  v_dex_score:=GREATEST(0,COALESCE(NULLIF(v_sheet.atributos->>'DES','')::integer,10)
    +priv.srd_effective_modifier(p_campaign_id,'character',v_character.id::text,'dexterity'));
  v_dex_modifier:=FLOOR((v_dex_score-10)::numeric/2)::integer;

  SELECT EXISTS (
    SELECT 1 FROM public.srd_campaign_conditions
     WHERE campaign_id=p_campaign_id AND target_kind='character'
       AND target_id=v_character.id::text AND active=true AND condition_id='flatfooted'
  ) INTO v_flatfooted;

  SELECT EXISTS (
    SELECT 1
      FROM public.srd_campaign_conditions cc
      JOIN priv.srd_condition_engine_rules r ON r.condition_id=cc.condition_id AND r.enabled
     WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='character'
       AND cc.target_id=v_character.id::text AND cc.active=true
       AND COALESCE(r.flags->>'loses_dex_ac','false')='true'
       AND cc.condition_id<>'flatfooted'
  ) INTO v_other_dex_loss;

  v_lose_dex:=v_other_dex_loss
    OR ((v_flatfooted OR v_context IN ('flatfooted','invisible')) AND NOT v_uncanny_dodge);
  IF NOT v_lose_dex THEN
    v_dex_applied:=LEAST(v_dex_modifier,v_max_dex);
  END IF;

  SELECT CASE translate(lower(COALESCE(race.tamanho,'medio')),
      'áéíóúãõâêôç','aeiouaoaeoc')
    WHEN 'minusculo' THEN 8 WHEN 'fine' THEN 8
    WHEN 'diminuto' THEN 4 WHEN 'diminutive' THEN 4
    WHEN 'miudo' THEN 2 WHEN 'tiny' THEN 2
    WHEN 'pequeno' THEN 1 WHEN 'small' THEN 1
    WHEN 'grande' THEN -1 WHEN 'large' THEN -1
    WHEN 'enorme' THEN -2 WHEN 'huge' THEN -2
    WHEN 'imenso' THEN -4 WHEN 'gargantuan' THEN -4
    WHEN 'colossal' THEN -8
    ELSE 0 END
    INTO v_size_modifier
    FROM public.srd_races race
   WHERE race.id::text=v_sheet.raca_id::text;
  v_size_modifier:=COALESCE(v_size_modifier,0);

  v_effect_modifier:=priv.srd_effective_modifier(
    p_campaign_id,'character',v_character.id::text,'ac'
  );
  -- Trap Sense é bônus de esquiva: não se aplica quando o personagem está
  -- desprevenido ou perde Destreza na CA por uma condição incapacitante.
  IF v_context='trap' AND NOT v_flatfooted AND NOT v_other_dex_loss THEN
    -- Sentido para Armadilhas de Bárbaro e Ladino não acumula entre si.
    v_trap_sense_bonus:=GREATEST(
      FLOOR(COALESCE(v_barbarian_level,0)/3.0)::integer,
      FLOOR(COALESCE(v_rogue_level,0)/3.0)::integer
    );
  END IF;

  v_final_ac:=GREATEST(1,10+v_armor_bonus+v_shield_bonus+v_dex_applied
    +v_size_modifier+v_effect_modifier+v_trap_sense_bonus);

  RETURN jsonb_build_object(
    'character_id',v_character.id::text,
    'base_ac',10,
    'armor_bonus',v_armor_bonus,
    'shield_bonus',v_shield_bonus,
    'dexterity_modifier',v_dex_modifier,
    'dexterity_applied',v_dex_applied,
    'dexterity_lost',v_lose_dex,
    'max_dexterity_bonus',v_max_dex,
    'size_modifier',v_size_modifier,
    'effect_modifier',v_effect_modifier,
    'trap_sense_bonus',v_trap_sense_bonus,
    'barbarian_level',COALESCE(v_barbarian_level,0),
    'rogue_level',COALESCE(v_rogue_level,0),
    'uncanny_dodge',v_uncanny_dodge,
    'improved_uncanny_dodge',v_improved_uncanny_dodge,
    'flatfooted',v_flatfooted,
    'final_ac',v_final_ac,
    'attack_context',v_context
  );
END;
$function$
;

-- srd_calcular_ca_personagem_srd(p_campaign_id bigint, p_character_id text, p_attack_context text, p_attacker_is_giant boolean)
CREATE OR REPLACE FUNCTION public.srd_calcular_ca_personagem_srd(p_campaign_id bigint, p_character_id text, p_attack_context text, p_attacker_is_giant boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  DECLARE v_result jsonb; v_race_id text; v_final_ac integer;
  BEGIN
    IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
    IF public.my_role(p_campaign_id)='GM' AND EXISTS (
      SELECT 1 FROM public.characters ch
      JOIN public.members gm ON gm.campaign_id=p_campaign_id
        AND gm.user_id=ch.user_id AND gm.role='GM'
      JOIN public.campaigns camp ON camp.id=p_campaign_id
      CROSS JOIN LATERAL jsonb_array_elements(
        CASE WHEN jsonb_typeof(camp.cba_data->'tokens')='array'
             THEN camp.cba_data->'tokens' ELSE '[]'::jsonb END
      ) tok
      WHERE ch.id::text=BTRIM(p_character_id)
        AND tok->>'tipo'='npc'
        AND tok->>'sourceCharacterId'=ch.id::text
    ) THEN
      v_result:=priv.srd_calcular_ca_alvo_campanha_srd(p_campaign_id,p_character_id,p_attack_context);
    ELSE
      v_result:=public.srd_calcular_ca_personagem_srd(p_campaign_id,p_character_id,p_attack_context);
    END IF;
    IF COALESCE(p_attacker_is_giant,false) THEN
      SELECT sh.raca_id::text INTO v_race_id FROM public.srd_character_sheets sh
      WHERE sh.character_id::text=BTRIM(p_character_id);
      IF v_race_id IN ('anao','gnomo')
         AND NOT COALESCE((v_result->>'dexterity_lost')::boolean,false) THEN
        v_final_ac:=COALESCE(NULLIF(v_result->>'final_ac','')::integer,10)+4;
        v_result:=v_result||jsonb_build_object('racial_giant_dodge_bonus',4,'final_ac',v_final_ac);
      END IF;
    END IF;
    RETURN v_result;
  END;
  $function$
;

-- srd_cancelar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)
CREATE OR REPLACE FUNCTION public.srd_cancelar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$ select priv.srd_cancelar_movimento_aoo_pendente_impl(p_campaign_id,p_pending_id); $function$
;

-- srd_configurar_perfil_combate_token_srd(p_campaign_id bigint, p_token_id text, p_combat_faction text, p_melee_reach_ft integer)
CREATE OR REPLACE FUNCTION public.srd_configurar_perfil_combate_token_srd(p_campaign_id bigint, p_token_id text, p_combat_faction text, p_melee_reach_ft integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
declare
  v_campaign public.campaigns%rowtype;
  v_tokens jsonb;
  v_token jsonb;
  v_count integer;
  v_index bigint;
  v_faction text;
  v_reach integer;
  v_new_token jsonb;
  v_new_scene jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode configurar o perfil de combate dos tokens.';
  end if;
  if nullif(btrim(p_token_id),'') is null then
    raise exception 'O identificador do token é obrigatório.';
  end if;

  v_faction := lower(btrim(coalesce(p_combat_faction,'')));
  if v_faction not in ('ally','hostile','neutral') then
    raise exception 'Facção inválida. Use ally, hostile ou neutral.';
  end if;
  if p_melee_reach_ft is null or p_melee_reach_ft < 0 or p_melee_reach_ft > 100 then
    raise exception 'O alcance corpo a corpo deve estar entre 0 e 100 pés.';
  end if;

  select * into v_campaign
  from public.campaigns
  where id=p_campaign_id
  for update;
  if not found then raise exception 'Campanha não encontrada.'; end if;

  v_tokens := case when jsonb_typeof(v_campaign.cba_data->'tokens')='array'
    then v_campaign.cba_data->'tokens' else '[]'::jsonb end;
  select count(*)::integer, min(x.ordinality), (array_agg(x.token))[1]
    into v_count, v_index, v_token
  from jsonb_array_elements(v_tokens) with ordinality x(token,ordinality)
  where x.token->>'id'=btrim(p_token_id) or x.token->>'key'=btrim(p_token_id);

  if v_count <> 1 then
    raise exception 'Token inexistente ou duplicado na cena.';
  end if;

  v_new_token := v_token || jsonb_build_object(
    'combat_faction',v_faction,
    'melee_reach_ft',p_melee_reach_ft,
    'combat_profile_configured',true
  );
  v_new_scene := coalesce(v_campaign.cba_data,'{}'::jsonb) ||
    jsonb_build_object('tokens',jsonb_set(v_tokens,array[(v_index-1)::text],v_new_token,false));

  update public.campaigns set cba_data=v_new_scene where id=p_campaign_id;

  return jsonb_build_object(
    'token_id',v_token->>'id',
    'combat_faction',v_faction,
    'melee_reach_ft',p_melee_reach_ft,
    'combat_profile_configured',true,
    'cba_data',v_new_scene
  );
end;
$function$
;

-- srd_configurar_rodada_surpresa_srd(p_campaign_id bigint, p_aware_ids text[])
CREATE OR REPLACE FUNCTION public.srd_configurar_rodada_surpresa_srd(p_campaign_id bigint, p_aware_ids text[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE v_campaign public.campaigns%rowtype; v_order jsonb; v_aware text[]; v_indices jsonb; v_first integer; v_surprise jsonb; v_first_actor jsonb;
BEGIN
 IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
   RAISE EXCEPTION 'Somente o Mestre autenticado pode configurar a rodada surpresa.';
 END IF;
 SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
 IF NOT FOUND OR upper(coalesce(v_campaign.state,''))<>'COMBATE' THEN RAISE EXCEPTION 'A campanha não está em combate.'; END IF;
 IF coalesce((v_campaign.combat_data->>'active')::boolean,false) IS NOT TRUE THEN RAISE EXCEPTION 'A iniciativa precisa estar concluída antes de configurar a rodada surpresa.'; END IF;
 IF coalesce(v_campaign.combat_data->'surprise'->>'phase','') NOT IN ('','not_started') THEN RAISE EXCEPTION 'A rodada surpresa já foi configurada.'; END IF;
 v_order:=CASE WHEN jsonb_typeof(v_campaign.combat_data->'turn_order')='array' THEN v_campaign.combat_data->'turn_order' ELSE '[]'::jsonb END;
 IF jsonb_array_length(v_order)=0 THEN RAISE EXCEPTION 'A ordem de iniciativa está vazia.'; END IF;
 SELECT coalesce(array_agg(distinct btrim(x) order by btrim(x)),ARRAY[]::text[]) INTO v_aware
 FROM unnest(coalesce(p_aware_ids,ARRAY[]::text[])) x WHERE nullif(btrim(x),'') IS NOT NULL;
 IF EXISTS(SELECT 1 FROM unnest(v_aware) a(id) WHERE NOT EXISTS(
   SELECT 1 FROM jsonb_array_elements(v_order) e(entry) WHERE e.entry->>'id'=a.id
 )) THEN RAISE EXCEPTION 'A lista de participantes conscientes contém alguém fora da iniciativa.'; END IF;
 SELECT coalesce(jsonb_agg(e.ordinality-1 ORDER BY e.ordinality),'[]'::jsonb)
 INTO v_indices
 FROM jsonb_array_elements(v_order) WITH ORDINALITY e(entry,ordinality)
 WHERE e.entry->>'id'=ANY(v_aware);
 PERFORM priv.srd_restore_surprised_flatfooted(p_campaign_id,v_order,v_aware);
 v_first:=CASE WHEN jsonb_array_length(v_indices)>0 THEN (v_indices->>0)::integer ELSE 0 END;
 v_surprise:=jsonb_build_object(
   'phase',CASE WHEN cardinality(v_aware)>0 THEN 'surprise_round' ELSE 'normal' END,
   'aware_ids',to_jsonb(v_aware),
   'order_indices',v_indices,
   'cursor',0,
   'actions_used','{}'::jsonb,
   'configured_by',auth.uid(),
   'configured_at',now()
 );
 IF cardinality(v_aware)>0 THEN
   UPDATE public.campaigns SET combat_data=combat_data||
     jsonb_build_object('surprise',v_surprise,'current_turn',v_first,'round',0)
   WHERE id=p_campaign_id RETURNING combat_data INTO v_campaign.combat_data;
   v_first_actor:=v_order->v_first;
   PERFORM priv.srd_clear_combat_flatfooted_actor(p_campaign_id,v_first_actor);
 ELSE
   -- Sem participantes conscientes, a rodada surpresa é ignorada; todos permanecem desprevenidos.
   v_first_actor:=v_order->0;
   IF NOT EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc
     WHERE cc.campaign_id=p_campaign_id AND cc.target_kind=
       CASE WHEN coalesce((v_first_actor->>'is_monster')::boolean,false) THEN 'token' ELSE 'character' END
       AND cc.target_id=v_first_actor->>'id' AND cc.condition_id='flatfooted'
       AND cc.active=true AND cc.notes->>'source_feature'='combat_flatfooted') THEN
     INSERT INTO public.srd_campaign_conditions(campaign_id,target_kind,target_id,condition_id,started_round,active,notes)
     VALUES(p_campaign_id,CASE WHEN coalesce((v_first_actor->>'is_monster')::boolean,false) THEN 'token' ELSE 'character' END,
       v_first_actor->>'id','flatfooted',1,true,jsonb_build_object('source_feature','combat_flatfooted','rule','until_first_turn'));
   END IF;
   UPDATE public.campaigns SET combat_data=combat_data||
     jsonb_build_object('surprise',v_surprise,'current_turn',0,'round',1)
   WHERE id=p_campaign_id RETURNING combat_data INTO v_campaign.combat_data;
 END IF;
 RETURN v_campaign.combat_data;
END;
$function$
;

-- srd_confirmar_critico_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_confirmation_d20 integer)
CREATE OR REPLACE FUNCTION public.srd_confirmar_critico_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_confirmation_d20 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_attack priv.srd_aoo_attacks%rowtype;
  v_bonus integer;
  v_total integer;
  v_confirmed boolean;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode confirmar o crítico.';
  end if;
  if p_confirmation_d20 not between 1 and 20 then raise exception 'Confirmação crítica exige d20 físico válido.'; end if;
  select * into v_attack from priv.srd_aoo_attacks
  where attack_id=p_attack_id and campaign_id=p_campaign_id for update;
  if not found or v_attack.created_by<>auth.uid() then raise exception 'Ataque não encontrado ou sem autorização.'; end if;
  if v_attack.status<>'awaiting_critical_confirmation' then
    if v_attack.resolution_data ? 'critical_confirmation_d20'
       and (v_attack.resolution_data->>'critical_confirmation_d20')::integer=p_confirmation_d20 then
      return jsonb_build_object('attack_id',p_attack_id,'status',v_attack.status,
        'is_critical',v_attack.is_critical,'replayed',true);
    end if;
    raise exception 'Este ataque não aguarda confirmação crítica ou recebeu outra rolagem.';
  end if;
  v_bonus:=v_attack.attack_total-v_attack.manual_d20;
  v_total:=p_confirmation_d20+v_bonus;
  v_confirmed:=p_confirmation_d20=20 or (p_confirmation_d20<>1 and v_total>=v_attack.target_ac);
  update priv.srd_aoo_attacks set
    critical_confirmation_d20=p_confirmation_d20,is_critical=v_confirmed,
    status='awaiting_damage',
    resolution_data=resolution_data||jsonb_build_object(
      'critical_confirmation_d20',p_confirmation_d20,
      'critical_confirmation_total',v_total,'critical_confirmed',v_confirmed
    )
  where attack_id=p_attack_id returning * into v_attack;
  update priv.srd_aoo_pending_movements p
  set pending_reactions=jsonb_set(p.pending_reactions,ARRAY[
    (select (e.ordinality-1)::text from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
     where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1)
  ],(
    select e.value||jsonb_build_object('status','hit_pending_damage','critical',v_confirmed)
    from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
    where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1
  ),false),updated_at=now()
  where p.pending_id=v_attack.pending_id;
  return jsonb_build_object('attack_id',p_attack_id,'status','awaiting_damage',
    'critical_confirmed',v_confirmed,'confirmation_total',v_total,
    'damage_expression',v_attack.resolution_data->>'weapon_damage');
end;
$function$
;

-- srd_consultar_armas_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)
CREATE OR REPLACE FUNCTION public.srd_consultar_armas_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_reaction jsonb;
  v_profile jsonb;
  v_character_id bigint;
  v_weapons jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode consultar armas para a reação.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id;
  if not found or v_pending.status<>'waiting_reactions' then
    raise exception 'Movimento pendente não encontrado ou encerrado.';
  end if;
  select value into v_reaction
  from jsonb_array_elements(v_pending.pending_reactions)
  where value->>'reactor_token_id'=btrim(p_reactor_token_id)
    and value->>'status'='reserved'
  limit 1;
  if v_reaction is null then raise exception 'O combatente ainda não possui reação reservada.'; end if;
  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_reactor_token_id));
  v_character_id:=nullif(v_profile->>'character_id','')::bigint;
  if v_character_id is null then
    return jsonb_build_object('eligible_for_automated_attack',false,
      'reason','unlinked_creature_requires_gm_adjudication','weapons','[]'::jsonb);
  end if;
  select coalesce(jsonb_agg(jsonb_build_object(
    'instance_id',wi.instance_id,'equipment_id',eq.id,
    'name',eq.nome,'hand_slot',wi.hand_slot,'damage',eq.dano,
    'critical',coalesce(eq.detalhes->>'critical',eq.critico,'x2'),
    'weapon_end_main',eq.detalhes->'weapon_end_main',
    'weapon_end_off',eq.detalhes->'weapon_end_off',
    'weapon_double',coalesce((eq.detalhes->>'weapon_double')::boolean,false),
    'weapon_reach_ft',coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5),
    'weapon_threat_min_ft',coalesce(nullif(eq.detalhes->>'threat_min_ft','')::integer,5),
    'weapon_threatens_squares',coalesce((eq.detalhes->>'threatens_squares')::boolean,true),
    'damage_type',eq.tipo_dano
  ) order by case wi.hand_slot when 'main_hand' then 1 else 2 end,eq.nome),'[]'::jsonb)
  into v_weapons
  from public.srd_character_weapon_instances wi
  join public.srd_equipment eq on eq.id=wi.equipment_id
  join public.srd_character_equipment ce
    on ce.character_id=v_character_id::text and ce.equipment_id=wi.equipment_id
    and ce.equipado is true and ce.hand_slot=wi.hand_slot
  where wi.character_id=v_character_id::text and wi.equipado is true
    and wi.hand_slot in ('main_hand','off_hand')
    and coalesce(eq.detalhes->>'weapon_melee','true')<>'false'
    and coalesce((eq.detalhes->>'threatens_squares')::boolean,true) IS TRUE;
  return jsonb_build_object('eligible_for_automated_attack',jsonb_array_length(v_weapons)>0,
    'character_id',v_character_id,'weapons',v_weapons,
    'note',case when jsonb_array_length(v_weapons)=0
      then 'Sem arma corpo a corpo equipada; a resolução manual pelo Mestre ainda é necessária.'
      else null end);
end;
$function$
;

-- srd_consultar_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid)
CREATE OR REPLACE FUNCTION public.srd_consultar_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare v_attack priv.srd_aoo_attacks%rowtype;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode consultar ataques de oportunidade.';
  end if;
  select * into v_attack from priv.srd_aoo_attacks
  where campaign_id=p_campaign_id and attack_id=p_attack_id;
  if not found then raise exception 'Ataque de oportunidade não encontrado.'; end if;
  return jsonb_build_object(
    'attack_id',v_attack.attack_id,'pending_id',v_attack.pending_id,
    'reaction_id',v_attack.reaction_id,
    'actor_token_id',v_attack.actor_token_id,'target_token_id',v_attack.target_token_id,
    'weapon_instance_id',v_attack.weapon_instance_id,
    'weapon_hand_slot',v_attack.weapon_hand_slot,'weapon_end',v_attack.weapon_end,
    'status',v_attack.status,'manual_d20',v_attack.manual_d20,
    'attack_total',v_attack.attack_total,'target_ac',v_attack.target_ac,
    'critical_confirmation_d20',v_attack.critical_confirmation_d20,
    'is_critical',v_attack.is_critical,'damage_rolls',v_attack.damage_rolls,
    'damage_applied',v_attack.damage_applied,
    'resolution_data',v_attack.resolution_data,
    'created_at',v_attack.created_at,'resolved_at',v_attack.resolved_at,
    'damage_applied_at',v_attack.damage_applied_at
  );
end;
$function$
;

-- srd_consultar_modificadores_manobra_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_maneuver text, p_defender_firm_ground boolean)
CREATE OR REPLACE FUNCTION public.srd_consultar_modificadores_manobra_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_maneuver text, p_defender_firm_ground boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_attacker jsonb;
  v_defender jsonb;
  v_maneuver text:=lower(btrim(coalesce(p_maneuver,'')));
  v_size_difference integer;
  v_stability integer:=0;
  v_attacker_modifier integer;
  v_defender_modifier integer;
  v_attacker_feats jsonb:='[]'::jsonb;
  v_defender_feats jsonb:='[]'::jsonb;
  v_improved_trip boolean:=false;
  v_improved_bull_rush boolean:=false;
  v_feat_bonus integer:=0;
  v_aoo_status text;
  v_aoo_source text;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode consultar os modificadores de manobra.';
  END IF;
  IF v_maneuver NOT IN ('bull_rush','trip') THEN
    RAISE EXCEPTION 'Manobra não suportada nesta etapa. Use bull_rush ou trip.';
  END IF;
  IF p_attacker_token_id IS NULL OR p_defender_token_id IS NULL
     OR p_attacker_token_id=p_defender_token_id THEN
    RAISE EXCEPTION 'Selecione dois tokens diferentes.';
  END IF;

  v_attacker:=priv.srd35_maneuver_profile(p_campaign_id,p_attacker_token_id);
  v_defender:=priv.srd35_maneuver_profile(p_campaign_id,p_defender_token_id);
  v_size_difference:=4*((v_attacker->>'size_rank')::integer-(v_defender->>'size_rank')::integer);

  IF v_maneuver IN ('bull_rush','trip')
     AND v_defender->>'race_id'='anao'
     AND coalesce(p_defender_firm_ground,false) THEN
    v_stability:=4;
  END IF;

  IF v_attacker->>'character_id' IS NOT NULL THEN
    SELECT coalesce(talentos,'[]'::jsonb) INTO v_attacker_feats
    FROM public.srd_character_sheets
    WHERE character_id=(v_attacker->>'character_id')::bigint;
  END IF;
  IF v_defender->>'character_id' IS NOT NULL THEN
    SELECT coalesce(talentos,'[]'::jsonb) INTO v_defender_feats
    FROM public.srd_character_sheets
    WHERE character_id=(v_defender->>'character_id')::bigint;
  END IF;

  v_improved_trip:=EXISTS(
    SELECT 1 FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(v_attacker_feats)='array' THEN v_attacker_feats ELSE '[]'::jsonb END
    ) f
    WHERE lower(coalesce(f->>'id','')) IN ('srd35_feat_improved_trip','improved_trip','derrubar_aprimorado')
  );
  v_improved_bull_rush:=EXISTS(
    SELECT 1 FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(v_attacker_feats)='array' THEN v_attacker_feats ELSE '[]'::jsonb END
    ) f
    WHERE lower(coalesce(f->>'id','')) IN ('srd35_feat_improved_bull_rush','improved_bull_rush','encontrao_aprimorado')
  );

  v_attacker_modifier:=(v_attacker->>'strength_modifier')::integer+v_size_difference;
  v_defender_modifier:=CASE WHEN v_maneuver='trip'
    THEN greatest((v_defender->>'strength_modifier')::integer,
                  (v_defender->>'dexterity_modifier')::integer)
    ELSE (v_defender->>'strength_modifier')::integer END
    -v_size_difference+v_stability;

  IF v_maneuver='trip' THEN
    v_feat_bonus:=CASE WHEN v_improved_trip THEN 4 ELSE 0 END;
    v_attacker_modifier:=v_attacker_modifier+v_feat_bonus;
    v_aoo_status:='requires_weapon_context';
    v_aoo_source:='defender';
  ELSE
    v_feat_bonus:=CASE WHEN v_improved_bull_rush THEN 4 ELSE 0 END;
    v_attacker_modifier:=v_attacker_modifier+v_feat_bonus;
    v_aoo_status:=CASE WHEN v_improved_bull_rush THEN 'suppressed_by_feat' ELSE 'provokes' END;
    v_aoo_source:='defender';
  END IF;

  RETURN jsonb_build_object(
    'maneuver',v_maneuver,
    'attacker',v_attacker,
    'defender',v_defender,
    'attacker_check','strength',
    'defender_check',CASE WHEN v_maneuver='trip' THEN 'strength_or_dexterity' ELSE 'strength' END,
    'attacker_modifier',v_attacker_modifier,
    'defender_modifier',v_defender_modifier,
    'dwarf_stability_bonus',v_stability,
    'dwarf_stability_applied',v_stability=4,
    'size_difference_modifier',v_size_difference,
    'attacker_feat_bonus',v_feat_bonus,
    'improved_trip',v_improved_trip,
    'improved_bull_rush',v_improved_bull_rush,
    'aoo_status',v_aoo_status,
    'aoo_source',v_aoo_source,
    'aoo_requires_weapon_context',v_maneuver='trip',
    'resolved',false,
    'note',CASE WHEN v_maneuver='trip'
      THEN 'Derrubar: confirmar se o atacante está desarmado ou usa arma apropriada antes de decidir o ataque de oportunidade. Derrubar Aprimorado só suprime o ataque quando a tentativa é desarmada.'
      WHEN v_improved_bull_rush
      THEN 'Encontrão Aprimorado concede +4 no teste e impede o ataque de oportunidade do defensor.'
      ELSE 'Encontrão provoca ataque de oportunidade do defensor antes da resolução; este retorno não executa o ataque nem consome ações.'
    END
  );
END;
$function$
;

-- srd_consultar_modificadores_manobra_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_maneuver text, p_defender_firm_ground boolean, p_trip_using_weapon boolean)
CREATE OR REPLACE FUNCTION public.srd_consultar_modificadores_manobra_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_maneuver text, p_defender_firm_ground boolean, p_trip_using_weapon boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_result jsonb;
  v_maneuver text := lower(btrim(coalesce(p_maneuver,'')));
  v_campaign public.campaigns%ROWTYPE;
  v_attacker jsonb;
  v_defender jsonb;
  v_profile jsonb;
  v_character_id text;
  v_distance integer;
  v_reach integer := 5;
  v_trip_weapon_count integer := 0;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode consultar os modificadores de manobra.';
  END IF;

  v_result := public.srd_consultar_modificadores_manobra_srd(
    p_campaign_id,p_attacker_token_id,p_defender_token_id,
    p_maneuver,p_defender_firm_ground
  );

  IF v_maneuver='trip' THEN
    SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;

    SELECT t INTO v_attacker
      FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
     WHERE t->>'id'=btrim(p_attacker_token_id) OR t->>'key'=btrim(p_attacker_token_id)
     LIMIT 1;
    SELECT t INTO v_defender
      FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
     WHERE t->>'id'=btrim(p_defender_token_id) OR t->>'key'=btrim(p_defender_token_id)
     LIMIT 1;

    IF v_attacker IS NULL OR v_defender IS NULL THEN
      RAISE EXCEPTION 'Atacante ou defensor não está na cena.';
    END IF;
    IF coalesce(v_attacker->>'gridX','') !~ '^[0-9]{1,3}$'
       OR coalesce(v_attacker->>'gridY','') !~ '^[0-9]{1,3}$'
       OR coalesce(v_defender->>'gridX','') !~ '^[0-9]{1,3}$'
       OR coalesce(v_defender->>'gridY','') !~ '^[0-9]{1,3}$' THEN
      RAISE EXCEPTION 'Posição inválida para validar o alcance de Derrubar.';
    END IF;

    v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_attacker_token_id));
    v_character_id:=v_profile->>'character_id';

    IF coalesce(p_trip_using_weapon,false) THEN
      IF v_character_id IS NULL THEN
        RAISE EXCEPTION 'Não foi possível confirmar uma arma apropriada equipada para Derrubar.';
      END IF;
      SELECT count(*),
             coalesce(max(CASE WHEN eq.detalhes->>'reach_ft' ~ '^[0-9]{1,3}$'
                               THEN (eq.detalhes->>'reach_ft')::integer END),5)
        INTO v_trip_weapon_count,v_reach
        FROM public.srd_character_weapon_instances wi
        JOIN public.srd_equipment eq ON eq.id=wi.equipment_id
        JOIN public.srd_character_equipment ce
          ON ce.character_id=wi.character_id
         AND ce.equipment_id=wi.equipment_id
         AND ce.equipado IS TRUE
         AND ce.hand_slot=wi.hand_slot
       WHERE wi.character_id=v_character_id
         AND wi.equipado IS TRUE
         AND wi.hand_slot IN ('main_hand','off_hand')
         AND coalesce(eq.detalhes->>'weapon_melee','true')='true'
         AND coalesce((eq.detalhes->>'trip')::boolean,false) IS TRUE;
      IF v_trip_weapon_count=0 THEN
        RAISE EXCEPTION 'A arma equipada não possui a propriedade de Derrubar. Use uma arma apropriada ou tente desarmado.';
      END IF;
    END IF;

    v_distance:=priv.srd_grid_footprint_distance_ft(
      (v_attacker->>'gridX')::integer,(v_attacker->>'gridY')::integer,
      priv.srd_token_grid_footprint(p_campaign_id,p_attacker_token_id),
      (v_defender->>'gridX')::integer,(v_defender->>'gridY')::integer,
      priv.srd_token_grid_footprint(p_campaign_id,p_defender_token_id)
    );

    IF v_distance>v_reach THEN
      RAISE EXCEPTION 'Derrubar fora do alcance: distância de % pés; alcance da arma equipada de % pés.',v_distance,v_reach;
    END IF;

    IF coalesce(p_trip_using_weapon,false) THEN
      v_result:=v_result||jsonb_build_object(
        'trip_using_weapon',true,'trip_reach_ft',v_reach,
        'aoo_status','not_provoked_by_armed_trip',
        'aoo_source','none',
        'note','Arma equipada com propriedade de Derrubar confirmada pelo catálogo; a tentativa não provoca ataque de oportunidade.'
      );
    ELSE
      v_result:=v_result||jsonb_build_object('trip_using_weapon',false,'trip_reach_ft',5);
      IF coalesce((v_result->>'improved_trip')::boolean,false) THEN
        v_result:=v_result||jsonb_build_object(
          'aoo_status','suppressed_by_feat','aoo_source','defender',
          'note','Tentativa desarmada: Derrubar Aprimorado concede +4 no teste e impede o ataque de oportunidade.'
        );
      ELSE
        v_result:=v_result||jsonb_build_object(
          'aoo_status','provokes','aoo_source','defender',
          'note','Tentativa desarmada: o defensor pode realizar ataque de oportunidade antes do teste resistido.'
        );
      END IF;
    END IF;
  END IF;
  RETURN v_result;
END;
$function$
;

-- srd_consultar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)
CREATE OR REPLACE FUNCTION public.srd_consultar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare v_pending priv.srd_aoo_pending_movements%rowtype;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode consultar movimentos aguardando ataques de oportunidade.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id;
  if not found then raise exception 'Movimento pendente não encontrado.'; end if;
  return jsonb_build_object(
    'pending_id',v_pending.pending_id,'status',v_pending.status,
    'mover_token_id',v_pending.mover_token_id,
    'movement_controller',v_pending.movement_controller,
    'origin',jsonb_build_array(v_pending.origin_x,v_pending.origin_y),
    'destination',jsonb_build_array(v_pending.destination_x,v_pending.destination_y),
    'round',v_pending.combat_round,'current_turn',v_pending.current_turn,
    'turn_actor_id',v_pending.turn_actor_id,
    'threats',v_pending.threats,'pending_reactions',v_pending.pending_reactions,
    'created_at',v_pending.created_at
  );
end;
$function$
;

-- srd_detectar_saida_alcance_ameacado_srd(p_campaign_id bigint, p_mover_token_id text, p_destination_x integer, p_destination_y integer)
CREATE OR REPLACE FUNCTION public.srd_detectar_saida_alcance_ameacado_srd(p_campaign_id bigint, p_mover_token_id text, p_destination_x integer, p_destination_y integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_campaign public.campaigns%rowtype;
  v_tokens jsonb;
  v_mover jsonb;
  v_count integer;
  v_mover_type text;
  v_faction text;
  v_size_text text;
  v_size integer := 1;
  v_old_x integer;
  v_old_y integer;
  v_is_gm boolean;
  v_threats jsonb := '[]'::jsonb;
begin
  if auth.uid() is null then raise exception 'É necessário estar autenticado.'; end if;
  if p_destination_x is null or p_destination_y is null
     or p_destination_x < 0 or p_destination_y < 0
     or p_destination_x > 199 or p_destination_y > 199 then
    raise exception 'Destino inválido na grade.';
  end if;
  v_is_gm := public.my_role(p_campaign_id) = 'GM';
  select * into v_campaign from public.campaigns where id=p_campaign_id;
  if not found then raise exception 'Campanha não encontrada.'; end if;
  v_tokens := case when jsonb_typeof(v_campaign.cba_data->'tokens')='array'
    then v_campaign.cba_data->'tokens' else '[]'::jsonb end;

  select count(*)::integer, (array_agg(x.token))[1]
    into v_count, v_mover
  from jsonb_array_elements(v_tokens) x(token)
  where x.token->>'id'=btrim(p_mover_token_id) or x.token->>'key'=btrim(p_mover_token_id);
  if v_count<>1 then raise exception 'Token de movimento inexistente ou duplicado.'; end if;

  v_mover_type:=v_mover->>'tipo';
  if not v_is_gm and (v_mover_type<>'player' or not exists(
    select 1 from public.characters c where c.id::text=btrim(p_mover_token_id)
      and c.campaign_id=p_campaign_id and c.user_id=auth.uid()
  )) then raise exception 'Você só pode consultar ameaças para seu próprio personagem.'; end if;
  if coalesce(v_mover->>'gridX','') !~ '^[0-9]{1,3}$'
     or coalesce(v_mover->>'gridY','') !~ '^[0-9]{1,3}$' then
    raise exception 'A posição atual do token é inválida.';
  end if;
  v_old_x:=(v_mover->>'gridX')::integer;
  v_old_y:=(v_mover->>'gridY')::integer;
  v_faction:=lower(coalesce(v_mover->>'combat_faction',''));
  if v_faction not in ('ally','hostile') then
    return jsonb_build_object('detected',false,'reason','mover_faction_not_configured',
      'mover_token_id',p_mover_token_id,'from',jsonb_build_array(v_old_x,v_old_y),
      'to',jsonb_build_array(p_destination_x,p_destination_y),'threats','[]'::jsonb,
      'movement_committed',false,'reaction_reserved',false);
  end if;

  select coalesce(
    nullif(v_mover->'monsterStats'->>'tamanho',''),
    nullif(v_mover->'monsterStats'->>'size',''),
    nullif(v_mover->>'tamanho',''),
    race.tamanho,
    'Médio'
  ) into v_size_text
  from (select 1) seed
  left join lateral (
    select r.tamanho
    from public.srd_character_sheets sh
    join public.srd_races r on r.id::text=sh.raca_id::text
    where sh.character_id::text=coalesce(
      nullif(v_mover->>'sourceCharacterId',''),
      case when v_mover_type='player' then v_mover->>'id' end
    )
    limit 1
  ) race on true;

  v_size:=case
    when public.srd35_normalizar_parametro_talento(coalesce(v_size_text,'')) like 'colossal%' then 6
    when public.srd35_normalizar_parametro_talento(coalesce(v_size_text,'')) like 'gargantuan%'
      or public.srd35_normalizar_parametro_talento(coalesce(v_size_text,'')) like 'imenso%' then 4
    when public.srd35_normalizar_parametro_talento(coalesce(v_size_text,'')) like 'huge%'
      or public.srd35_normalizar_parametro_talento(coalesce(v_size_text,'')) like 'enorme%' then 3
    when public.srd35_normalizar_parametro_talento(coalesce(v_size_text,'')) like 'large%'
      or public.srd35_normalizar_parametro_talento(coalesce(v_size_text,'')) like 'grande%' then 2
    else 1 end;

  with enemies as (
    select t,
      case
        when public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho',race.tamanho,'Médio')) like 'colossal%' then 6
        when public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho',race.tamanho,'Médio')) like 'gargantuan%'
          or public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho',race.tamanho,'Médio')) like 'imenso%' then 4
        when public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho',race.tamanho,'Médio')) like 'huge%'
          or public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho',race.tamanho,'Médio')) like 'enorme%' then 3
        when public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho',race.tamanho,'Médio')) like 'large%'
          or public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho',race.tamanho,'Médio')) like 'grande%' then 2
        else 1 end as footprint,
      case when coalesce(t->>'gridX','') ~ '^[0-9]{1,3}$' then (t->>'gridX')::integer else -1 end as gx,
      case when coalesce(t->>'gridY','') ~ '^[0-9]{1,3}$' then (t->>'gridY')::integer else -1 end as gy,
      lower(coalesce(t->>'combat_faction','')) as faction,
      coalesce(profile.threat_ranges,'[]'::jsonb) as threat_ranges
    from jsonb_array_elements(v_tokens) t
    left join lateral (
      select r.tamanho from public.srd_character_sheets sh
      join public.srd_races r on r.id::text=sh.raca_id::text
      where sh.character_id::text=coalesce(nullif(t->>'sourceCharacterId',''),case when t->>'tipo'='player' then t->>'id' end)
      limit 1
    ) race on true
    left join lateral (
      select jsonb_agg(jsonb_build_object('min_ft',r.min_ft,'max_ft',r.max_ft,'source',r.source)) as threat_ranges
      from (
        select 5::integer min_ft,greatest(5,(t->>'melee_reach_ft')::integer) max_ft,'token_melee_reach'::text source
        where coalesce(t->>'melee_reach_ft','') ~ '^[0-9]{1,3}$' and (t->>'melee_reach_ft')::integer>0
        union all
        select
          case when coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5)>5 and sz.footprint>1
            then sz.base_reach+5 else greatest(5,coalesce(nullif(eq.detalhes->>'threat_min_ft','')::integer,5)) end,
          case when coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5)>5 and sz.footprint>1
            then coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5)*greatest(1,sz.base_reach/5)
            else greatest(coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5),sz.base_reach) end,
          'equipped_weapon'
        from public.srd_character_weapon_instances wi
        join public.srd_equipment eq on eq.id=wi.equipment_id
        join public.srd_character_equipment ce on ce.character_id=wi.character_id and ce.equipment_id=wi.equipment_id
          and ce.equipado is true and ce.hand_slot=wi.hand_slot
        cross join lateral (
          select
            case
              when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'colossal%' then 6
              when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'gargantuan%'
                or public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'imenso%' then 4
              when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'huge%'
                or public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'enorme%' then 3
              when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'large%'
                or public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'grande%' then 2 else 1 end footprint,
            case
              when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'colossal%' then 30
              when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'gargantuan%'
                or public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'imenso%' then 20
              when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'huge%'
                or public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'enorme%' then 15
              when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'large%'
                or public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'grande%' then 10 else 5 end base_reach
        ) sz
        where wi.character_id::text=coalesce(nullif(t->>'sourceCharacterId',''),case when t->>'tipo'='player' then t->>'id' end)
          and wi.equipado is true and wi.hand_slot in ('main_hand','off_hand')
          and coalesce(eq.detalhes->>'weapon_melee','true')<>'false'
          and coalesce((eq.detalhes->>'threatens_squares')::boolean,true) is true
        union all
        select 5,
          coalesce(
            (regexp_match(coalesce(t->'monsterStats'->>'espaco_alcance',t->'monsterStats'->'dados_tecnicos'->'statblock'->>'space_reach',''),
              '/[[:space:]]*([0-9]+)[[:space:]]*ft'))[1]::integer,
            case
              when public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho','')) like 'colossal%' then 30
              when public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho','')) like 'gargantuan%'
                or public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho','')) like 'imenso%' then 20
              when public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho','')) like 'huge%'
                or public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho','')) like 'enorme%' then 15
              when public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho','')) like 'large%'
                or public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho','')) like 'grande%' then 10 else 5 end),
          'natural_attack'
        where nullif(t->>'sourceCharacterId','') is null
          and coalesce(t->>'tipo','') in ('monstro','monster','npc')
          and coalesce(t->'monsterStats'->>'ataques',t->'monsterStats'->>'full_attack','') ~* '(melee|corpo a corpo|claw|bite|slam|tentacle|gore|tail|sting|hoof)'
        union all
        select 5,
          case
            when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'colossal%' then 30
            when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'gargantuan%'
              or public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'imenso%' then 20
            when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'huge%'
              or public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'enorme%' then 15
            when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'large%'
              or public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'grande%' then 10 else 5 end,
          'unarmed_strike'
        where exists (
          select 1 from public.srd_character_sheets sh join public.srd_classes cl on cl.id=sh.classe_id
          where sh.character_id::text=coalesce(nullif(t->>'sourceCharacterId',''),case when t->>'tipo'='player' then t->>'id' end)
            and (cl.class_key='monk' or exists (
              select 1 from jsonb_array_elements(case when jsonb_typeof(sh.talentos)='array' then sh.talentos else '[]'::jsonb end) feat
              where lower(concat_ws(' ',feat->>'id',feat->>'nome',feat->>'name')) ~
                '(ataque_desarmado_aprimorado|srd35_feat_improved_unarmed_strike|improved_unarmed_strike|ataque desarmado aprimorado|improved unarmed strike)'
            ))
        )
      ) r where r.max_ft>=r.min_ft
    ) profile on true
    where t->>'id' is distinct from p_mover_token_id
      and t->>'key' is distinct from p_mover_token_id
  ), path as (
    select i,
      case when greatest(abs(p_destination_x-v_old_x),abs(p_destination_y-v_old_y))=0 then v_old_x
        else round(v_old_x+(p_destination_x-v_old_x)::numeric*i/greatest(abs(p_destination_x-v_old_x),abs(p_destination_y-v_old_y)))::integer end as px,
      case when greatest(abs(p_destination_x-v_old_x),abs(p_destination_y-v_old_y))=0 then v_old_y
        else round(v_old_y+(p_destination_y-v_old_y)::numeric*i/greatest(abs(p_destination_x-v_old_x),abs(p_destination_y-v_old_y)))::integer end as py
    from generate_series(0,greatest(abs(p_destination_x-v_old_x),abs(p_destination_y-v_old_y))) i
  ), evaluated as (
    select e.t,
      coalesce((select max((r->>'max_ft')::integer) from jsonb_array_elements(e.threat_ranges) r),0) reach_ft,
      e.threat_ranges,e.faction,e.gx,e.gy,e.footprint,
      min(path.i) filter (where exists (
        select 1 from jsonb_array_elements(e.threat_ranges) r
        where priv.srd_grid_footprint_distance_ft(path.px,path.py,v_size,e.gx,e.gy,e.footprint)
          between (r->>'min_ft')::integer and (r->>'max_ft')::integer
      )) first_threatened_step,
      max(path.i) filter (where exists (
        select 1 from jsonb_array_elements(e.threat_ranges) r
        where priv.srd_grid_footprint_distance_ft(path.px,path.py,v_size,e.gx,e.gy,e.footprint)
          between (r->>'min_ft')::integer and (r->>'max_ft')::integer
      )) last_threatened_step,
      max(path.i) final_step
    from enemies e cross join path
    where e.gx>=0 and e.gy>=0 and jsonb_array_length(e.threat_ranges)>0
      and e.faction=case when v_faction='ally' then 'hostile' else 'ally' end
    group by e.t,e.threat_ranges,e.faction,e.gx,e.gy,e.footprint
  )
  select coalesce(jsonb_agg(jsonb_build_object(
    'token_id',t->>'id','token_key',t->>'key',
    'name',coalesce(t->>'nome',t->>'name','Criatura'),
    'reach_ft',reach_ft,'reach_squares',ceil(reach_ft/5.0)::integer,
    'threat_ranges',threat_ranges,
    'reach_distance_rule','D&D 3.5 diagonal 5-10-5',
    'first_threatened_step',first_threatened_step,
    'last_threatened_step',last_threatened_step,
    'leaving_threatened_area',true,'combat_faction',faction
  ) order by first_threatened_step),'[]'::jsonb)
  into v_threats
  from evaluated
  where first_threatened_step is not null
    and last_threatened_step < final_step;

  return jsonb_build_object(
    'detected',jsonb_array_length(v_threats)>0,
    'reason',case when jsonb_array_length(v_threats)>0 then 'leaving_threatened_area' else 'no_threatened_area_exit' end,
    'mover_token_id',p_mover_token_id,'mover_faction',v_faction,
    'from',jsonb_build_array(v_old_x,v_old_y),
    'to',jsonb_build_array(p_destination_x,p_destination_y),
    'mover_footprint',v_size,
    'threats',v_threats,'movement_committed',false,'reaction_reserved',false
  );
end;
$function$
;

-- srd_effective_modifier(p_campaign_id bigint, p_target_kind text, p_target_id text, p_stat text)
CREATE OR REPLACE FUNCTION public.srd_effective_modifier(p_campaign_id bigint, p_target_kind text, p_target_id text, p_stat text)
 RETURNS integer
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
BEGIN
  IF auth.uid() IS NULL OR (
    public.my_role(p_campaign_id) IS NULL AND NOT EXISTS (
      SELECT 1 FROM public.campaigns c WHERE c.id=p_campaign_id AND c.owner_id=auth.uid()
    )
  ) THEN RAISE EXCEPTION 'Sem acesso à campanha.'; END IF;
  IF p_stat IS NULL OR p_stat !~ '^[a-z][a-z0-9_:.]{0,47}$' THEN
    RAISE EXCEPTION 'Atributo inválido.';
  END IF;
  RETURN priv.srd_effective_modifier(p_campaign_id,p_target_kind,p_target_id,p_stat);
END;
$function$
;

-- srd_encerrar_reacao_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_cancel_attack boolean)
CREATE OR REPLACE FUNCTION public.srd_encerrar_reacao_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_cancel_attack boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$ select priv.srd_encerrar_reacao_aoo_pendente_impl(p_campaign_id,p_pending_id,p_reactor_token_id,p_cancel_attack); $function$
;

-- srd_expire_campaign_conditions(p_campaign_id bigint)
CREATE OR REPLACE FUNCTION public.srd_expire_campaign_conditions(p_campaign_id bigint)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
 v_round integer; v_count integer:=0; v_effect_count integer:=0; v_rage_count integer:=0;
 v_rage record; v_result jsonb;
BEGIN
 IF auth.uid() IS NULL OR (public.my_role(p_campaign_id) IS NULL AND NOT EXISTS(
   SELECT 1 FROM public.campaigns c WHERE c.id=p_campaign_id AND c.owner_id=auth.uid()
 )) THEN RAISE EXCEPTION 'Sem acesso à campanha.'; END IF;
 SELECT COALESCE(NULLIF(combat_data->>'round','')::integer,0) INTO v_round
 FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
 IF NOT FOUND OR v_round<1 THEN RETURN 0; END IF;
 FOR v_rage IN SELECT e.target_id FROM public.srd_campaign_effects e
   WHERE e.campaign_id=p_campaign_id AND e.target_kind='character' AND e.active
     AND e.expires_round IS NOT NULL AND e.expires_round<=v_round
     AND e.effect_data->>'source_feature'='barbarian_rage' FOR UPDATE
 LOOP
   PERFORM priv.srd_end_barbarian_rage(p_campaign_id,v_rage.target_id,true);
   v_rage_count:=v_rage_count+1;
 END LOOP;
 FOR v_rage IN SELECT e.target_id,e.effect_instance_id FROM public.srd_campaign_effects e
   WHERE e.campaign_id=p_campaign_id AND e.target_kind='token' AND e.active
     AND e.expires_round IS NOT NULL AND e.expires_round<=v_round
     AND e.effect_data->>'source_feature'='barbarian_rage' FOR UPDATE
 LOOP
   v_result:=priv.srd_end_barbarian_rage_token(p_campaign_id,v_rage.target_id,true);
   IF COALESCE((v_result->>'ended')::boolean,false) THEN
     v_rage_count:=v_rage_count+1;
     PERFORM priv.log(p_campaign_id,'CLASS_FEATURE',jsonb_build_object(
       'feature_key','barbarian_rage','action','expire','token_id',v_rage.target_id,
       'effect_instance_id',v_rage.effect_instance_id,'round',v_round,
       'rage_hp_removed',v_result->'rage_hp_removed','fatigue_applied',v_result->'fatigue_applied'));
   END IF;
 END LOOP;
 UPDATE public.srd_campaign_conditions SET active=false
 WHERE campaign_id=p_campaign_id AND active AND expires_round IS NOT NULL AND expires_round<=v_round;
 GET DIAGNOSTICS v_count=ROW_COUNT;
 UPDATE public.srd_campaign_effects SET active=false
 WHERE campaign_id=p_campaign_id AND active AND expires_round IS NOT NULL AND expires_round<=v_round;
 GET DIAGNOSTICS v_effect_count=ROW_COUNT;
 RETURN v_count+v_effect_count+v_rage_count;
END;
$function$
;

-- srd_finalizar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)
CREATE OR REPLACE FUNCTION public.srd_finalizar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_preview jsonb;
  v_remaining integer;
  v_user uuid:=auth.uid();
begin
  if v_user is null then raise exception 'É necessário estar autenticado.'; end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then raise exception 'Movimento pendente não está ativo.'; end if;

  if public.my_role(p_campaign_id) is distinct from 'GM'
     and (v_pending.movement_controller='gm' or v_user<>v_pending.created_by) then
    raise exception 'Somente o Mestre ou o jogador que solicitou o movimento pode concluí-lo.';
  end if;

  if exists(
    select 1 from jsonb_array_elements(v_pending.pending_reactions) r
    where coalesce(r->>'status','') not in ('ineligible','skipped','miss','damage_applied')
  ) then
    raise exception 'Ainda existem reações de oportunidade sem estado terminal válido.';
  end if;

  if exists(
    select 1 from priv.srd_aoo_attacks a
    where a.pending_id=p_pending_id and a.campaign_id=p_campaign_id
      and a.status not in ('miss','damage_applied','cancelled')
  ) then
    raise exception 'Ainda existe um ataque de oportunidade sem resolução completa.';
  end if;

  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
     or coalesce(v_campaign.combat_data->>'active','false')<>'true'
     or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
     or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'O combate avançou; solicite uma nova movimentação.';
  end if;
  if not exists(select 1 from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
    where (t->>'id'=v_pending.mover_token_id or t->>'key'=v_pending.mover_token_id)
      and coalesce(t->>'gridX','')=v_pending.origin_x::text
      and coalesce(t->>'gridY','')=v_pending.origin_y::text) then
    raise exception 'A posição original do token mudou; movimento não pode ser concluído.';
  end if;

  perform set_config('app.srd_aoo_pending_commit',p_pending_id::text,true);
  if v_pending.movement_controller='player' and v_user=v_pending.created_by
     and public.my_role(p_campaign_id) is distinct from 'GM' then
    v_preview:=public.mover_token_player_cba(
      p_campaign_id,v_pending.mover_token_id,v_pending.destination_x,v_pending.destination_y);
  else
    v_preview:=public.mover_token_gm_cba_srd(
      p_campaign_id,v_pending.mover_token_id,v_pending.destination_x,v_pending.destination_y);
  end if;

  update priv.srd_aoo_pending_movements set status='committed',
    committed_at=now(),updated_at=now() where pending_id=p_pending_id;
  perform set_config('app.srd_aoo_pending_commit','',true);
  return jsonb_build_object('committed',true,'pending_id',p_pending_id,
    'mover_token_id',v_pending.mover_token_id,
    'destination',jsonb_build_array(v_pending.destination_x,v_pending.destination_y),
    'movement_result',v_preview);
end;
$function$
;

-- srd_iniciar_ataque_oportunidade_desarmado_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid)
CREATE OR REPLACE FUNCTION public.srd_iniciar_ataque_oportunidade_desarmado_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_reaction jsonb;
  v_index bigint;
  v_ledger priv.srd_aoo_reaction_ledger%rowtype;
  v_profile jsonb;
  v_token jsonb;
  v_target jsonb;
  v_count integer;
  v_character_id bigint;
  v_sheet public.srd_character_sheets%rowtype;
  v_class public.srd_classes%rowtype;
  v_race public.srd_races%rowtype;
  v_level integer;
  v_bab integer:=0;
  v_str integer;
  v_str_mod integer;
  v_size text;
  v_size_mod integer:=0;
  v_damage_dice text:='1d3';
  v_damage_expr text;
  v_attack_bonus integer;
  v_racial_bonus integer:=0;
  v_target_traits text;
  v_reach integer;
  v_steps integer;
  v_step integer;
  v_tx integer;
  v_ty integer;
  v_dx integer;
  v_dy integer;
  v_distance integer;
  v_attack_id uuid;
  v_has_improved_unarmed boolean:=false;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode iniciar um ataque desarmado de oportunidade.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then raise exception 'Movimento não está aguardando reações.'; end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
    or coalesce(v_campaign.combat_data->>'active','false')<>'true'
    or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
    or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'O combate ou turno mudou desde a solicitação do movimento.';
  end if;
  select ordinality,value into v_index,v_reaction
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality
  where value->>'reactor_token_id'=btrim(p_reactor_token_id) limit 1;
  if v_reaction is null or v_reaction->>'status'<>'reserved'
    or v_reaction->>'reservation_id' is distinct from p_reaction_id::text then
    raise exception 'O combatente não possui reação reservada para este movimento.';
  end if;
  select * into v_ledger from priv.srd_aoo_reaction_ledger
  where reaction_id=p_reaction_id and campaign_id=p_campaign_id
    and actor_token_id=btrim(p_reactor_token_id) and combat_round=v_pending.combat_round for update;
  if not found then raise exception 'Reserva de reação não encontrada.'; end if;

  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_reactor_token_id));
  v_character_id:=nullif(v_profile->>'character_id','')::bigint;
  if v_character_id is null then raise exception 'Ataque desarmado automatizado exige ficha SRD vinculada.'; end if;
  select * into v_sheet from public.srd_character_sheets where character_id=v_character_id;
  if not found then raise exception 'Ficha SRD do combatente não encontrada.'; end if;
  select * into v_class from public.srd_classes where id=v_sheet.classe_id;
  select * into v_race from public.srd_races where id=v_sheet.raca_id;
  if not found then raise exception 'Raça do combatente não encontrada.'; end if;

  SELECT coalesce(v_class.class_key='monk',false) OR EXISTS (
    SELECT 1
    FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::jsonb END
    ) feat
    WHERE lower(concat_ws(' ',feat->>'id',feat->>'nome',feat->>'name')) ~
      '(ataque_desarmado_aprimorado|srd35_feat_improved_unarmed_strike|improved_unarmed_strike|ataque desarmado aprimorado|improved unarmed strike)'
  ) INTO v_has_improved_unarmed;

  IF NOT v_has_improved_unarmed THEN
    RAISE EXCEPTION 'Ataque de Oportunidade desarmado exige Ataque Desarmado Aprimorado ou níveis de Monge.';
  END IF;
  if priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'no_actions')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'helpless')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stunned')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'unconscious')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dying')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stable')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dead')
    or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id::text,'no_actions')
    or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id::text,'helpless')
    or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id::text,'stunned')
    or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id::text,'unconscious')
    or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id::text,'dying')
    or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id::text,'stable')
    or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id::text,'dead') then
    raise exception 'A condição atual impede o ataque desarmado.';
  end if;

  v_level:=greatest(1,coalesce(v_sheet.nivel,1));
  select coalesce(sum(case lower(coalesce(cl.bab_progression,''))
    when 'good' then lv.class_level when 'bom' then lv.class_level
    when 'average' then floor(3*lv.class_level/4.0)::integer
    when 'medium' then floor(3*lv.class_level/4.0)::integer
    when 'medio' then floor(3*lv.class_level/4.0)::integer
    when 'poor' then floor(lv.class_level/2.0)::integer
    when 'ruim' then floor(lv.class_level/2.0)::integer else 0 end),0)::integer
  into v_bab from public.srd_character_class_levels lv
  join public.srd_classes cl on cl.id=lv.class_id where lv.character_id=v_character_id;
  if not exists(select 1 from public.srd_character_class_levels lv where lv.character_id=v_character_id) then
    v_bab:=case lower(coalesce(v_class.bab_progression,''))
      when 'good' then v_level when 'bom' then v_level
      when 'average' then floor(3*v_level/4.0)::integer
      when 'medium' then floor(3*v_level/4.0)::integer
      when 'medio' then floor(3*v_level/4.0)::integer
      when 'poor' then floor(v_level/2.0)::integer
      when 'ruim' then floor(v_level/2.0)::integer else 0 end;
  end if;

  v_str:=coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)
    +priv.srd_effective_modifier(p_campaign_id,'token',btrim(p_reactor_token_id),'strength');
  v_str_mod:=floor((v_str-10)::numeric/2)::integer;
  v_size:=lower(public.srd35_normalizar_parametro_talento(coalesce(v_race.tamanho,'medio')));
  v_size_mod:=case when v_size like 'fine%' or v_size like 'minusculo%' then 8
    when v_size like 'diminutive%' or v_size like 'diminuto%' then 4
    when v_size like 'tiny%' or v_size like 'miudo%' then 2
    when v_size like 'small%' or v_size like 'pequeno%' then 1
    when v_size like 'large%' or v_size like 'grande%' then -1
    when v_size like 'huge%' or v_size like 'enorme%' then -2
    when v_size like 'gargantuan%' or v_size like 'imenso%' then -4
    when v_size like 'colossal%' then -8 else 0 end;
  v_damage_dice:=case when v_size like 'fine%' or v_size like 'diminutive%' or v_size like 'tiny%'
      or v_size like 'minusculo%' or v_size like 'diminuto%' or v_size like 'miudo%' then '1d2'
    when v_size like 'small%' or v_size like 'pequeno%' then '1d2'
    when v_size like 'large%' or v_size like 'grande%' then '1d4'
    when v_size like 'huge%' or v_size like 'enorme%' then '1d6'
    when v_size like 'gargantuan%' or v_size like 'imenso%' then '1d8'
    when v_size like 'colossal%' then '2d6' else '1d3' end;
  v_damage_expr:=v_damage_dice||case when v_str_mod>0 then '+'||v_str_mod::text when v_str_mod<0 then v_str_mod::text else '' end;
  select count(*)::integer,(array_agg(t))[1] into v_count,v_token
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id);
  if v_count<>1 then raise exception 'Token atacante ausente ou duplicado.'; end if;
  select count(*)::integer,(array_agg(t))[1] into v_count,v_target
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=v_pending.mover_token_id or t->>'key'=v_pending.mover_token_id;
  if v_count<>1 then raise exception 'Alvo do movimento ausente ou duplicado.'; end if;
  v_target_traits:=lower(concat_ws(' ',v_target->>'nome',v_target->>'detalhe',
    v_target->'monsterStats'->>'tipo',v_target->'monsterStats'->>'subtipo',
    v_target->'monsterStats'->>'type',v_target->'monsterStats'->>'creature_type',
    (SELECT lower(sh.raca_id::text) FROM public.srd_character_sheets sh
      WHERE sh.character_id::text=CASE
        WHEN v_target->>'tipo'='player' THEN v_target->>'id'
        WHEN v_target->>'tipo'='npc' THEN v_target->>'sourceCharacterId'
        ELSE NULL END LIMIT 1)));
  if v_race.id='anao' and v_target_traits ~ '(^|[^a-z])(orc|goblin|hobgoblin|bugbear|goblinoid(e)?)([^a-z]|$)' then v_racial_bonus:=1; end if;
  v_attack_bonus:=v_bab+v_str_mod+v_size_mod+v_racial_bonus;

  v_steps:=greatest(abs(v_pending.destination_x-v_pending.origin_x),abs(v_pending.destination_y-v_pending.origin_y));
  v_step:=greatest(0,coalesce(nullif(v_reaction->'threat'->>'last_threatened_step','')::integer,0));
  v_tx:=case when v_steps=0 then v_pending.origin_x else round(v_pending.origin_x+(v_pending.destination_x-v_pending.origin_x)::numeric*v_step/v_steps)::integer end;
  v_ty:=case when v_steps=0 then v_pending.origin_y else round(v_pending.origin_y+(v_pending.destination_y-v_pending.origin_y)::numeric*v_step/v_steps)::integer end;
  if coalesce(v_token->>'gridX','') !~ '^[0-9]{1,3}$' or coalesce(v_token->>'gridY','') !~ '^[0-9]{1,3}$' then
    raise exception 'Posição do atacante inválida.';
  end if;
  v_distance:=priv.srd_grid_footprint_distance_ft(
    (v_token->>'gridX')::integer,(v_token->>'gridY')::integer,
    priv.srd_token_grid_footprint(p_campaign_id,p_reactor_token_id),
    v_tx,v_ty,priv.srd_token_grid_footprint(p_campaign_id,v_pending.mover_token_id));
  v_reach:=coalesce(nullif(v_token->>'melee_reach_ft','')::integer,5);
  if v_distance>v_reach then raise exception 'O alvo está fora do alcance do ataque desarmado.'; end if;

  insert into priv.srd_aoo_attacks(campaign_id,pending_id,reaction_id,actor_token_id,target_token_id,
    actor_character_id,weapon_instance_id,weapon_hand_slot,created_by,resolution_data)
  values(p_campaign_id,p_pending_id,p_reaction_id,btrim(p_reactor_token_id),v_pending.mover_token_id,
    null,null,'natural',auth.uid(),jsonb_build_object(
      'weapon_name','Ataque desarmado','weapon_damage',v_damage_expr,'damage_expression',v_damage_expr,
      'monster_attack_bonus',v_attack_bonus,'critical_threat_minimum',20,'critical_multiplier',2,
      'damage_type','bludgeoning','source_character_id',v_character_id,
      'base_attack_bonus',v_bab,'strength_modifier',v_str_mod,'size_modifier',v_size_mod,
      'racial_bonus',v_racial_bonus,'trigger_x',v_tx,'trigger_y',v_ty
    )) returning attack_id into v_attack_id;
  update priv.srd_aoo_pending_movements
  set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],
    v_reaction||jsonb_build_object('status','attack_started','attack_id',v_attack_id),false),updated_at=now()
  where pending_id=p_pending_id;
  return jsonb_build_object('started',true,'attack_id',v_attack_id,'weapon_name','Ataque desarmado',
    'damage_expression',v_damage_expr,'attack_bonus',v_attack_bonus,'awaiting_manual_d20',true,'action_economy_cost',0);
end;
$function$
;

-- srd_iniciar_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid)
CREATE OR REPLACE FUNCTION public.srd_iniciar_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_reaction jsonb;
  v_index bigint;
  v_ledger priv.srd_aoo_reaction_ledger%rowtype;
  v_profile jsonb;
  v_token jsonb;
  v_target jsonb;
  v_count integer;
  v_attack_text text;
  v_match text[];
  v_bonus integer;
  v_damage_expr text;
  v_damage_type text;
  v_reach integer;
  v_steps integer;
  v_step integer;
  v_tx integer;
  v_ty integer;
  v_dx integer;
  v_dy integer;
  v_distance integer;
  v_attack_id uuid;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode iniciar um ataque natural de oportunidade.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then raise exception 'Movimento não está aguardando reações.'; end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
    or coalesce(v_campaign.combat_data->>'active','false')<>'true'
    or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
    or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'O combate ou turno mudou desde a solicitação do movimento.';
  end if;
  select ordinality,value into v_index,v_reaction
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality
  where value->>'reactor_token_id'=btrim(p_reactor_token_id) limit 1;
  if v_reaction is null or v_reaction->>'status'<>'reserved'
    or v_reaction->>'reservation_id' is distinct from p_reaction_id::text then
    raise exception 'O combatente não possui reação reservada para este movimento.';
  end if;
  select * into v_ledger from priv.srd_aoo_reaction_ledger
  where reaction_id=p_reaction_id and campaign_id=p_campaign_id
    and actor_token_id=btrim(p_reactor_token_id) and combat_round=v_pending.combat_round for update;
  if not found then raise exception 'Reserva de reação não encontrada.'; end if;

  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_reactor_token_id));
  if nullif(v_profile->>'character_id','') is not null then
    raise exception 'Este combatente possui ficha vinculada; use o fluxo de arma equipada.';
  end if;
  select count(*)::integer,(array_agg(t))[1] into v_count,v_token
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id);
  if v_count<>1 or v_token->>'tipo' not in ('monstro','npc') then
    raise exception 'O fluxo natural é exclusivo de NPCs e monstros sem ficha SRD vinculada.';
  end if;
  if priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'no_actions')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'helpless')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stunned')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'unconscious')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dying')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stable')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dead') then
    raise exception 'A condição atual impede o ataque de oportunidade.';
  end if;
  v_attack_text:=coalesce(nullif(v_token->'monsterStats'->>'ataques',''),
    nullif(v_token->'monsterStats'->'dados_tecnicos'->'statblock'->>'attack',''),
    nullif(v_token->'monsterStats'->>'full_attack',''),
    nullif(v_token->'monsterStats'->'dados_tecnicos'->>'full_attack',''));
  v_match:=regexp_match(coalesce(v_attack_text,''),
    '([+-]?[0-9]+)[[:space:]]+melee[[:space:]]+\(([0-9]+d[0-9]+)([+-][0-9]+)?\)','i');
  if v_match is null then raise exception 'O bloco de estatísticas não contém ataque corpo a corpo legível.'; end if;
  v_bonus:=v_match[1]::integer;
  v_damage_expr:=v_match[2]||coalesce(v_match[3],'');
  v_damage_type:=lower(coalesce(v_token->'monsterStats'->>'tipo_dano','physical'));
  v_match:=regexp_match(coalesce(v_token->>'melee_reach_ft',v_token->'monsterStats'->>'espaco_alcance',
    v_token->'monsterStats'->'dados_tecnicos'->'statblock'->>'space_reach',''),'([0-9]+)[[:space:]]*ft\.?/[[:space:]]*([0-9]+)','i');
  v_reach:=coalesce(nullif(v_token->>'melee_reach_ft','')::integer,
    case when v_match is not null then v_match[2]::integer end,5);

  v_steps:=greatest(abs(v_pending.destination_x-v_pending.origin_x),abs(v_pending.destination_y-v_pending.origin_y));
  v_step:=greatest(0,coalesce(nullif(v_reaction->'threat'->>'last_threatened_step','')::integer,0));
  v_tx:=case when v_steps=0 then v_pending.origin_x else round(v_pending.origin_x+(v_pending.destination_x-v_pending.origin_x)::numeric*v_step/v_steps)::integer end;
  v_ty:=case when v_steps=0 then v_pending.origin_y else round(v_pending.origin_y+(v_pending.destination_y-v_pending.origin_y)::numeric*v_step/v_steps)::integer end;
  select count(*)::integer,(array_agg(t))[1] into v_count,v_target
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=v_pending.mover_token_id or t->>'key'=v_pending.mover_token_id;
  if v_count<>1 then raise exception 'Alvo do movimento não existe ou está duplicado.'; end if;
  if coalesce(v_token->>'gridX','') !~ '^[0-9]{1,3}$' or coalesce(v_token->>'gridY','') !~ '^[0-9]{1,3}$' then
    raise exception 'Posição do atacante inválida.';
  end if;
  v_distance:=priv.srd_grid_footprint_distance_ft(
    (v_token->>'gridX')::integer,(v_token->>'gridY')::integer,
    priv.srd_token_grid_footprint(p_campaign_id,p_reactor_token_id),
    v_tx,v_ty,priv.srd_token_grid_footprint(p_campaign_id,v_pending.mover_token_id));
  if v_distance>v_reach then raise exception 'O alvo está fora do alcance do ataque natural.'; end if;

  insert into priv.srd_aoo_attacks(campaign_id,pending_id,reaction_id,actor_token_id,target_token_id,
    actor_character_id,weapon_instance_id,weapon_hand_slot,created_by,resolution_data)
  values(p_campaign_id,p_pending_id,p_reaction_id,btrim(p_reactor_token_id),v_pending.mover_token_id,
    null,null,'natural',auth.uid(),jsonb_build_object(
      'weapon_name','Ataque natural','weapon_damage',v_damage_expr,'damage_expression',v_damage_expr,
      'monster_attack_bonus',v_bonus,'critical_threat_minimum',20,'critical_multiplier',2,
      'damage_type',v_damage_type,'source_attack_text',v_attack_text,'trigger_x',v_tx,'trigger_y',v_ty
    )) returning attack_id into v_attack_id;
  update priv.srd_aoo_pending_movements
  set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],
    v_reaction||jsonb_build_object('status','attack_started','attack_id',v_attack_id),false),updated_at=now()
  where pending_id=p_pending_id;
  return jsonb_build_object('started',true,'attack_id',v_attack_id,'weapon_name','Ataque natural',
    'damage_expression',v_damage_expr,'attack_bonus',v_bonus,'awaiting_manual_d20',true,'action_economy_cost',0);
end;
$function$
;

-- srd_iniciar_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid, p_natural_attack_index integer)
CREATE OR REPLACE FUNCTION public.srd_iniciar_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid, p_natural_attack_index integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_catalog jsonb; v_selected jsonb; v_started jsonb; v_attack_id uuid;
  v_damage_type text; v_attack_text text;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode iniciar um ataque natural de oportunidade.';
  end if;
  if p_natural_attack_index is null or p_natural_attack_index<1 then
    raise exception 'Selecione um grupo de ataque natural válido.';
  end if;
  v_catalog:=public.srd_listar_ataques_naturais_oportunidade_srd(p_campaign_id,btrim(p_reactor_token_id));
  if coalesce((v_catalog->>'available')::boolean,false) is not true then
    raise exception 'O token não possui ataques naturais catalogados: %',
      coalesce(v_catalog->>'reason','sem ataque natural válido');
  end if;
  select a.value into v_selected from jsonb_array_elements(coalesce(v_catalog->'attacks','[]'::jsonb)) a(value)
  where (a.value->>'index')::integer=p_natural_attack_index
    and coalesce((a.value->>'parse_supported')::boolean,false)
    and coalesce((a.value->>'is_natural')::boolean,false) limit 1;
  if v_selected is null then raise exception 'O grupo selecionado não existe ou não é um ataque natural suportado.'; end if;
  v_started:=public.srd_iniciar_ataque_oportunidade_monstro_srd(
    p_campaign_id,p_pending_id,p_reactor_token_id,p_reaction_id);
  v_attack_id:=nullif(v_started->>'attack_id','')::uuid;
  if v_attack_id is null then raise exception 'O fluxo legado não retornou um ataque válido.'; end if;
  v_attack_text:=v_catalog->>'source_text';
  select lower(coalesce(t->'monsterStats'->>'tipo_dano','physical')) into v_damage_type
  from public.campaigns c,lateral jsonb_array_elements(coalesce(c.cba_data->'tokens','[]'::jsonb)) t
  where c.id=p_campaign_id and (t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id))
  limit 1;
  update priv.srd_aoo_attacks
  set resolution_data=resolution_data||jsonb_build_object(
    'weapon_name',v_selected->>'name','natural_attack_index',p_natural_attack_index,
    'natural_attack_count',coalesce(nullif(v_selected->>'count','')::integer,1),
    'weapon_damage',v_selected->>'damage_expression','damage_expression',v_selected->>'damage_expression',
    'monster_attack_bonus',coalesce(nullif(v_selected->>'attack_bonus','')::integer,0),
    'natural_attack_bonus_progression',v_selected->>'attack_bonus_progression',
    'natural_attack_group_text',v_selected->>'attack_group_text',
    'natural_attack_additional_effect',v_selected->>'additional_effect',
    'natural_attack_source_text',v_attack_text,'natural_attack_selected',true,
    'damage_type',coalesce(v_damage_type,'physical'),
    'critical_threat_minimum',coalesce(nullif(v_selected->>'critical_threat_minimum','')::integer,20),
    'critical_multiplier',coalesce(nullif(v_selected->>'critical_multiplier','')::integer,2)
  )
  where attack_id=v_attack_id and campaign_id=p_campaign_id and created_by=auth.uid()
    and status='awaiting_attack_roll';
  if not found then raise exception 'Ataque não está mais aguardando rolagem manual.'; end if;
  return v_started||jsonb_build_object(
    'attack_id',v_attack_id,'weapon_name',v_selected->>'name',
    'natural_attack_index',p_natural_attack_index,
    'natural_attack_count',coalesce(nullif(v_selected->>'count','')::integer,1),
    'damage_expression',v_selected->>'damage_expression',
    'attack_bonus',coalesce(nullif(v_selected->>'attack_bonus','')::integer,0),
    'critical_threat_minimum',coalesce(nullif(v_selected->>'critical_threat_minimum','')::integer,20),
    'critical_multiplier',coalesce(nullif(v_selected->>'critical_multiplier','')::integer,2),
    'additional_effect',v_selected->>'additional_effect',
    'selected_natural_attack',v_selected,'awaiting_manual_d20',true
  );
end;
$function$
;

-- srd_iniciar_ataque_oportunidade_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text)
CREATE OR REPLACE FUNCTION public.srd_iniciar_ataque_oportunidade_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_reaction jsonb;
  v_reaction_index bigint;
  v_ledger priv.srd_aoo_reaction_ledger%rowtype;
  v_token jsonb;
  v_token_count integer;
  v_profile jsonb;
  v_character_id bigint;
  v_sheet public.srd_character_sheets%rowtype;
  v_instance public.srd_character_weapon_instances%rowtype;
  v_weapon public.srd_equipment%rowtype;
  v_attack_id uuid;
  v_reach integer;
  v_steps integer;
  v_step integer;
  v_trigger_x integer;
  v_trigger_y integer;
  v_dx integer;
  v_dy integer;
  v_distance integer;
  v_size_rank integer:=4;
  v_base_reach integer:=5;
  v_min_reach integer:=5;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode iniciar um ataque de oportunidade.';
  end if;
  if p_weapon_hand_slot not in ('main_hand','off_hand') then
    raise exception 'Mão da arma inválida.';
  end if;
  if p_weapon_end is not null and p_weapon_end not in ('main','off') then
    raise exception 'Extremidade da arma inválida.';
  end if;

  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then
    raise exception 'Movimento não está aguardando reação.';
  end if;

  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
    or coalesce(v_campaign.combat_data->>'active','false')<>'true'
    or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
    or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'O combate ou turno mudou desde a solicitação do movimento.';
  end if;

  select ordinality,value into v_reaction_index,v_reaction
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality
  where coalesce(value->>'reactor_token_id','')=btrim(p_reactor_token_id)
  limit 1;
  if v_reaction is null or v_reaction->>'status'<>'reserved'
     or v_reaction->>'reservation_id' is distinct from p_reaction_id::text then
    raise exception 'O combatente não possui reação reservada para este movimento.';
  end if;

  select * into v_ledger from priv.srd_aoo_reaction_ledger
  where reaction_id=p_reaction_id and campaign_id=p_campaign_id
    and actor_token_id=btrim(p_reactor_token_id)
    and combat_round=v_pending.combat_round for update;
  if not found then raise exception 'Reserva de reação não encontrada no ledger.'; end if;

  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_reactor_token_id));
  v_character_id:=nullif(v_profile->>'character_id','')::bigint;
  v_size_rank:=coalesce(nullif(v_profile->>'size_rank','')::integer,4);
  v_base_reach:=CASE
    WHEN v_size_rank>=8 THEN 30
    WHEN v_size_rank=7 THEN 20
    WHEN v_size_rank=6 THEN 15
    WHEN v_size_rank=5 THEN 10
    ELSE 5
  END;
  if v_character_id is null then
    raise exception 'Ataque de oportunidade automatizado requer ficha SRD vinculada. Criaturas sem ficha vinculada ainda precisam de resolução manual do Mestre.';
  end if;
  select * into v_sheet from public.srd_character_sheets
  where character_id=v_character_id;
  if not found then raise exception 'Ficha SRD do combatente não encontrada.'; end if;

  if priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'no_actions')
     or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'helpless')
     or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stunned')
     or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'unconscious')
     or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dying')
     or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stable')
     or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dead') then
    raise exception 'O combatente não pode realizar ataques de oportunidade devido à sua condição.';
  end if;

  select count(*)::integer,(array_agg(t))[1] into v_token_count,v_token
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id);
  if v_token_count<>1 then raise exception 'Token reator ausente ou duplicado.'; end if;

  select * into v_instance from public.srd_character_weapon_instances
  where instance_id=p_weapon_instance_id and character_id=v_character_id::text
    and equipado is true and hand_slot=p_weapon_hand_slot for share;
  if not found then raise exception 'A arma não está equipada na mão informada.'; end if;
  if not exists(select 1 from public.srd_character_equipment ce
    where ce.character_id=v_character_id::text and ce.equipment_id=v_instance.equipment_id
      and ce.equipado is true and ce.hand_slot=p_weapon_hand_slot) then
    raise exception 'A instância e o inventário da arma estão inconsistentes.';
  end if;
  select * into v_weapon from public.srd_equipment where id=v_instance.equipment_id;
  if not found or coalesce(v_weapon.detalhes->>'weapon_melee','true')='false' then
    raise exception 'A arma selecionada não é uma arma corpo a corpo válida.';
  end if;
  if coalesce((v_weapon.detalhes->>'weapon_double')::boolean,false) and p_weapon_end is null then
    raise exception 'Selecione a extremidade da arma dupla.';
  end if;

  v_steps:=greatest(abs(v_pending.destination_x-v_pending.origin_x),
                    abs(v_pending.destination_y-v_pending.origin_y));
  v_step:=greatest(0,coalesce(nullif(v_reaction->'threat'->>'last_threatened_step','')::integer,0));
  v_trigger_x:=case when v_steps=0 then v_pending.origin_x
    else round(v_pending.origin_x+(v_pending.destination_x-v_pending.origin_x)::numeric*v_step/v_steps)::integer end;
  v_trigger_y:=case when v_steps=0 then v_pending.origin_y
    else round(v_pending.origin_y+(v_pending.destination_y-v_pending.origin_y)::numeric*v_step/v_steps)::integer end;
  v_distance:=priv.srd_grid_footprint_distance_ft(
    (v_token->>'gridX')::integer,(v_token->>'gridY')::integer,
    priv.srd_token_grid_footprint(p_campaign_id,p_reactor_token_id),
    v_trigger_x,v_trigger_y,priv.srd_token_grid_footprint(p_campaign_id,v_pending.mover_token_id));

  IF coalesce(nullif(v_weapon.detalhes->>'reach_ft','')::integer,5)>5 AND v_size_rank>4 THEN
    v_min_reach:=v_base_reach+5;
    v_reach:=coalesce(nullif(v_weapon.detalhes->>'reach_ft','')::integer,5)*greatest(1,v_base_reach/5);
  ELSE
    v_min_reach:=greatest(5,coalesce(nullif(v_weapon.detalhes->>'threat_min_ft','')::integer,5));
    v_reach:=greatest(v_base_reach,coalesce(nullif(v_weapon.detalhes->>'reach_ft','')::integer,
      nullif(v_token->>'melee_reach_ft','')::integer,5));
  END IF;
  if coalesce((v_weapon.detalhes->>'threatens_squares')::boolean,true) IS NOT TRUE THEN
    raise exception 'A arma selecionada não ameaça quadrados e não pode realizar ataques de oportunidade.';
  end if;
  if v_distance < v_min_reach
     OR v_distance>v_reach then
    raise exception 'O alvo não está em um quadrado ameaçado pela arma selecionada.';
  end if;

  insert into priv.srd_aoo_attacks(
    campaign_id,pending_id,reaction_id,actor_token_id,target_token_id,
    actor_character_id,weapon_instance_id,weapon_hand_slot,weapon_end,created_by,
    resolution_data
  ) values (
    p_campaign_id,p_pending_id,p_reaction_id,btrim(p_reactor_token_id),
    v_pending.mover_token_id,v_character_id,p_weapon_instance_id,
    p_weapon_hand_slot,p_weapon_end,auth.uid(),
    jsonb_build_object('trigger_x',v_trigger_x,'trigger_y',v_trigger_y,
      'weapon_name',v_weapon.nome,'weapon_damage',v_weapon.dano,
      'weapon_critical',coalesce(v_weapon.detalhes->>'critical',v_weapon.critico,'x2'),
      'weapon_details',v_weapon.detalhes)
  ) returning attack_id into v_attack_id;

  update priv.srd_aoo_pending_movements
  set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_reaction_index-1)::text],
    v_reaction||jsonb_build_object('status','attack_started','attack_id',v_attack_id),
    false),updated_at=now()
  where pending_id=p_pending_id;

  return jsonb_build_object('started',true,'attack_id',v_attack_id,
    'pending_id',p_pending_id,'reactor_token_id',p_reactor_token_id,
    'target_token_id',v_pending.mover_token_id,'weapon_name',v_weapon.nome,
    'weapon_damage',v_weapon.dano,'trigger_position',jsonb_build_array(v_trigger_x,v_trigger_y),
    'awaiting_manual_d20',true,'action_economy_cost',0);
end;
$function$
;

-- srd_iniciar_derrubar_com_aoo_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_defender_firm_ground boolean, p_trip_using_weapon boolean)
CREATE OR REPLACE FUNCTION public.srd_iniciar_derrubar_com_aoo_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_defender_firm_ground boolean DEFAULT false, p_trip_using_weapon boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
  SELECT priv.srd_iniciar_derrubar_com_aoo_srd(
    p_campaign_id,p_attacker_token_id,p_defender_token_id,
    p_defender_firm_ground,p_trip_using_weapon
  );
$function$
;

-- srd_iniciar_encontrao_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text)
CREATE OR REPLACE FUNCTION public.srd_iniciar_encontrao_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$ select priv.srd_iniciar_encontrao_srd($1,$2,$3) $function$
;

-- srd_iniciar_levantar_caido_srd(p_campaign_id bigint, p_token_id text)
CREATE OR REPLACE FUNCTION public.srd_iniciar_levantar_caido_srd(p_campaign_id bigint, p_token_id text)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$ SELECT priv.srd_iniciar_levantar_caido_srd(p_campaign_id,p_token_id); $function$
;

-- srd_listar_ataques_naturais_oportunidade_srd(p_campaign_id bigint, p_reactor_token_id text)
CREATE OR REPLACE FUNCTION public.srd_listar_ataques_naturais_oportunidade_srd(p_campaign_id bigint, p_reactor_token_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_campaign public.campaigns%rowtype;
  v_token jsonb;
  v_count integer;
  v_profile jsonb;
  v_attack_text text;
  v_all jsonb;
  v_attacks jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode consultar ataques naturais de oportunidade.';
  end if;
  if nullif(btrim(p_reactor_token_id),'') is null then raise exception 'Token atacante obrigatório.'; end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id;
  if not found then raise exception 'Campanha não encontrada.'; end if;
  select count(*)::integer,(array_agg(t))[1] into v_count,v_token
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id);
  if v_count<>1 then raise exception 'Token ausente ou duplicado na cena.'; end if;
  if v_token->>'tipo' not in ('npc','monstro') then raise exception 'A consulta é destinada a NPCs e monstros.'; end if;
  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_reactor_token_id));
  if nullif(v_profile->>'character_id','') is not null then
    return jsonb_build_object('available',false,'reason','linked_character_requires_character_attack_catalog',
      'source_character_id',v_profile->>'character_id','attacks','[]'::jsonb);
  end if;
  v_attack_text:=coalesce(
    nullif(v_token->'monsterStats'->>'ataques',''),
    nullif(v_token->'monsterStats'->'dados_tecnicos'->'statblock'->>'full_attack',''),
    nullif(v_token->'monsterStats'->>'full_attack',''),
    nullif(v_token->'monsterStats'->'dados_tecnicos'->'statblock'->>'attack',''),
    nullif(v_token->'monsterStats'->>'attack',''));
  v_all:=priv.srd_parse_natural_attack_list(v_attack_text);
  select coalesce(jsonb_agg(a.value order by (a.value->>'index')::integer),'[]'::jsonb)
    into v_attacks from jsonb_array_elements(v_all) a(value)
    where coalesce((a.value->>'is_natural')::boolean,false);
  return jsonb_build_object('available',jsonb_array_length(v_attacks)>0,
    'token_id',btrim(p_reactor_token_id),'source','monsterStats','source_text',v_attack_text,
    'attacks',v_attacks,'selection_required',jsonb_array_length(v_attacks)>1);
end;
$function$
;

-- srd_listar_movimentos_aoo_pendentes_srd(p_campaign_id bigint)
CREATE OR REPLACE FUNCTION public.srd_listar_movimentos_aoo_pendentes_srd(p_campaign_id bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare v_rows jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode listar movimentos aguardando ataques de oportunidade.';
  end if;
  select coalesce(jsonb_agg(jsonb_build_object(
    'pending_id',p.pending_id,'mover_token_id',p.mover_token_id,
    'movement_controller',p.movement_controller,
    'origin',jsonb_build_array(p.origin_x,p.origin_y),
    'destination',jsonb_build_array(p.destination_x,p.destination_y),
    'round',p.combat_round,'current_turn',p.current_turn,
    'status',p.status,'threats',p.threats,
    'pending_reactions',p.pending_reactions,
    'created_at',p.created_at
  ) order by p.created_at),'[]'::jsonb)
  into v_rows
  from priv.srd_aoo_pending_movements p
  where p.campaign_id=p_campaign_id
    and p.status in ('waiting_reactions','ready_to_commit');
  return jsonb_build_object('pending_movements',v_rows);
end;
$function$
;

-- srd_registrar_ocultacao_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_manual_d100 integer)
CREATE OR REPLACE FUNCTION public.srd_registrar_ocultacao_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_manual_d100 integer)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  select priv.srd_registrar_ocultacao_ataque_oportunidade_impl(
    p_campaign_id,p_attack_id,p_manual_d100
  );
$function$
;

-- srd_registrar_rolagem_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_manual_d20 integer, p_idempotency_key uuid)
CREATE OR REPLACE FUNCTION public.srd_registrar_rolagem_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_manual_d20 integer, p_idempotency_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_attack priv.srd_aoo_attacks%rowtype;
  v_existing priv.srd_aoo_attacks%rowtype;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode registrar a rolagem do ataque de oportunidade.';
  end if;
  if p_manual_d20 not between 1 and 20 or p_idempotency_key is null then
    raise exception 'A rolagem exige d20 físico válido e chave de idempotência.';
  end if;
  select * into v_attack from priv.srd_aoo_attacks
  where attack_id=p_attack_id and campaign_id=p_campaign_id for update;
  if not found or v_attack.created_by<>auth.uid() then
    raise exception 'Ataque não encontrado ou sem autorização.';
  end if;
  select * into v_existing from priv.srd_aoo_attacks
  where attack_roll_idempotency_key=p_idempotency_key;
  if found then
    if v_existing.attack_id<>p_attack_id or v_existing.manual_d20<>p_manual_d20 then
      raise exception 'Chave de idempotência já utilizada em outra rolagem.';
    end if;
    return jsonb_build_object('attack_id',p_attack_id,'manual_d20',v_existing.manual_d20,'replayed',true);
  end if;
  if v_attack.status<>'awaiting_attack_roll' then
    if v_attack.manual_d20=p_manual_d20 then
      return jsonb_build_object('attack_id',p_attack_id,'manual_d20',v_attack.manual_d20,'replayed',true);
    end if;
    raise exception 'Este ataque já recebeu uma rolagem diferente.';
  end if;
  update priv.srd_aoo_attacks
  set manual_d20=p_manual_d20,attack_roll_idempotency_key=p_idempotency_key
  where attack_id=p_attack_id;
  return jsonb_build_object('attack_id',p_attack_id,'manual_d20',p_manual_d20,
    'ready_to_resolve',true,'replayed',false);
end;
$function$
;

-- srd_remove_campaign_condition(p_campaign_id bigint, p_target_kind text, p_target_id text, p_condition_id text)
CREATE OR REPLACE FUNCTION public.srd_remove_campaign_condition(p_campaign_id bigint, p_target_kind text, p_target_id text, p_condition_id text)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare v_count integer;
begin
  if auth.uid() is null then raise exception 'É necessário estar autenticado.'; end if;
  if public.my_role(p_campaign_id) is distinct from 'GM' then raise exception 'Somente o Mestre pode administrar condições.'; end if;
  update public.srd_campaign_conditions
     set active=false
   where campaign_id=p_campaign_id
     and target_kind=p_target_kind
     and target_id=p_target_id
     and condition_id=p_condition_id
     and active=true;
  get diagnostics v_count = row_count;
  return v_count;
end;
$function$
;

-- srd_remove_campaign_effect(p_campaign_id bigint, p_effect_instance_id bigint)
CREATE OR REPLACE FUNCTION public.srd_remove_campaign_effect(p_campaign_id bigint, p_effect_instance_id bigint)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
DECLARE v_count integer;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode remover efeitos diretamente.';
  END IF;
  UPDATE public.srd_campaign_effects
     SET active=false
   WHERE campaign_id=p_campaign_id
     AND effect_instance_id=p_effect_instance_id
     AND active=true;
  GET DIAGNOSTICS v_count=ROW_COUNT;
  RETURN v_count=1;
END;
$function$
;

-- srd_reservar_ataque_oportunidade_srd(p_campaign_id bigint, p_actor_token_id text, p_trigger_key text, p_actor_flat_footed boolean)
CREATE OR REPLACE FUNCTION public.srd_reservar_ataque_oportunidade_srd(p_campaign_id bigint, p_actor_token_id text, p_trigger_key text, p_actor_flat_footed boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
 select priv.srd_reservar_ataque_oportunidade_impl(
   p_campaign_id,p_actor_token_id,p_trigger_key,p_actor_flat_footed
 );
$function$
;

-- srd_reservar_reacao_movimento_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)
CREATE OR REPLACE FUNCTION public.srd_reservar_reacao_movimento_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
 select priv.srd_reservar_reacao_movimento_aoo_impl(
   p_campaign_id,p_pending_id,p_reactor_token_id
 );
$function$
;

-- srd_resolve_confusion_turn_srd(p_campaign_id bigint, p_target_kind text, p_target_id text, p_request_id uuid, p_manual_d100 integer)
CREATE OR REPLACE FUNCTION public.srd_resolve_confusion_turn_srd(p_campaign_id bigint, p_target_kind text, p_target_id text, p_request_id uuid, p_manual_d100 integer)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
 select priv.srd_resolve_confusion_turn_impl(
   p_campaign_id,p_target_kind,p_target_id,p_request_id,p_manual_d100
 );
$function$
;

-- srd_resolve_dying_round(p_campaign_id bigint, p_character_id text, p_d100 integer)
CREATE OR REPLACE FUNCTION public.srd_resolve_dying_round(p_campaign_id bigint, p_character_id text, p_d100 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_character public.characters%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_round integer;
  v_condition public.srd_campaign_conditions%ROWTYPE;
  v_new_hp integer;
  v_status text;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_d100 IS NULL OR p_d100 NOT BETWEEN 1 AND 100 THEN
    RAISE EXCEPTION 'A rolagem de estabilização exige um resultado manual de 1 a 100.';
  END IF;

  SELECT ch.* INTO v_character
  FROM public.characters ch
  WHERE ch.id::text=BTRIM(p_character_id)
    AND ch.campaign_id=p_campaign_id
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado nesta campanha.'; END IF;

  IF v_character.user_id IS DISTINCT FROM auth.uid()
     AND public.my_role(p_campaign_id) IS DISTINCT FROM 'GM'
     AND NOT EXISTS (
       SELECT 1 FROM public.campaigns c
       WHERE c.id=p_campaign_id AND c.owner_id=auth.uid()
     ) THEN
    RAISE EXCEPTION 'Somente o jogador dono da ficha ou o Mestre pode registrar esta rolagem.';
  END IF;

  SELECT sh.* INTO v_sheet
  FROM public.srd_character_sheets sh
  WHERE sh.character_id=v_character.id
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD do personagem não encontrada.'; END IF;
  IF COALESCE(v_sheet.pv_atual,0) NOT BETWEEN -9 AND -1 THEN
    RAISE EXCEPTION 'O personagem não está na faixa de PV morrendo (-1 a -9).';
  END IF;

  SELECT GREATEST(1,COALESCE(NULLIF(c.combat_data->>'round','')::integer,1))
    INTO v_round
    FROM public.campaigns c
   WHERE c.id=p_campaign_id
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;

  SELECT cc.* INTO v_condition
  FROM public.srd_campaign_conditions cc
  WHERE cc.campaign_id=p_campaign_id
    AND cc.target_kind='character'
    AND cc.target_id=BTRIM(p_character_id)
    AND cc.condition_id='dying'
    AND cc.active=true
  ORDER BY cc.condition_instance_id DESC
  LIMIT 1
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'A condição Morrendo não está ativa.'; END IF;

  IF COALESCE(NULLIF(v_condition.notes->>'last_resolved_round','')::integer,0)>=v_round THEN
    RAISE EXCEPTION 'A rolagem de estabilização desta rodada já foi resolvida.';
  END IF;

  IF p_d100<=10 THEN
    PERFORM priv.srd_sync_character_vital_condition(BTRIM(p_character_id),v_sheet.pv_atual,true);
    v_status:='stable';
    v_new_hp:=v_sheet.pv_atual;
  ELSE
    v_new_hp:=GREATEST(-10,COALESCE(v_sheet.pv_atual,0)-1);
    UPDATE public.srd_character_sheets
       SET pv_atual=v_new_hp
     WHERE character_id=v_character.id;
    PERFORM priv.srd_sync_character_vital_condition(BTRIM(p_character_id),v_new_hp,false);
    v_status:=CASE WHEN v_new_hp<=-10 THEN 'dead' ELSE 'dying' END;
    IF v_status='dying' THEN
      UPDATE public.srd_campaign_conditions
         SET notes=COALESCE(notes,'{}'::jsonb)||jsonb_build_object('last_resolved_round',v_round)
       WHERE campaign_id=p_campaign_id
         AND target_kind='character'
         AND target_id=BTRIM(p_character_id)
         AND condition_id='dying'
         AND active=true;
    END IF;
  END IF;

  PERFORM priv.log(
    p_campaign_id,
    'ESTABILIZACAO_RESOLVIDA',
    jsonb_build_object(
      'character_id',BTRIM(p_character_id),
      'd100',p_d100,
      'round',v_round,
      'pv_atual',v_new_hp,
      'status',v_status
    )
  );

  RETURN jsonb_build_object(
    'character_id',BTRIM(p_character_id),
    'd100',p_d100,
    'round',v_round,
    'pv_atual',v_new_hp,
    'condition',v_status,
    'stabilized',v_status='stable',
    'dead',v_status='dead'
  );
END;
$function$
;

-- srd_resolve_npc_dying_round(p_campaign_id bigint, p_token_id text, p_d100 integer)
CREATE OR REPLACE FUNCTION public.srd_resolve_npc_dying_round(p_campaign_id bigint, p_token_id text, p_d100 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_campaign public.campaigns%ROWTYPE; v_tokens jsonb; v_token jsonb; v_index bigint;
  v_count integer; v_actual_id text; v_source_id text; v_hp integer; v_max_hp integer;
  v_round integer; v_condition public.srd_campaign_conditions%ROWTYPE; v_new_hp integer;
  v_state text; v_result jsonb;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_d100 IS NULL OR p_d100 NOT BETWEEN 1 AND 100 THEN RAISE EXCEPTION 'A estabilização exige uma rolagem manual de D100 entre 1 e 100.'; END IF;
  IF public.my_role(p_campaign_id) IS DISTINCT FROM 'GM'
     AND NOT EXISTS(SELECT 1 FROM public.campaigns c WHERE c.id=p_campaign_id AND c.owner_id=auth.uid()) THEN
    RAISE EXCEPTION 'Somente o Mestre pode resolver a estabilização de um NPC.';
  END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END;
  SELECT count(*)::integer,min(t.ordinality),(array_agg(t.token ORDER BY t.ordinality))[1]
    INTO v_count,v_index,v_token
  FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality)
  WHERE (t.token->>'id'=BTRIM(p_token_id) OR t.token->>'key'=BTRIM(p_token_id)) AND t.token->>'tipo'='npc';
  IF v_count IS DISTINCT FROM 1 THEN RAISE EXCEPTION 'NPC ausente ou duplicado no tabuleiro.'; END IF;
  v_actual_id:=NULLIF(BTRIM(v_token->>'id'),'');
  v_source_id:=NULLIF(BTRIM(v_token->>'sourceCharacterId'),'');
  IF v_source_id IS NULL THEN RAISE EXCEPTION 'A estabilização exige NPC vinculado a uma ficha de origem.'; END IF;
  IF COALESCE(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN RAISE EXCEPTION 'PV máximo do NPC inválido.'; END IF;
  v_max_hp:=(v_token->>'maxHp')::integer;
  IF COALESCE(v_token->>'hp','') !~ '^-?[0-9]{1,6}$' THEN RAISE EXCEPTION 'PV atuais do NPC inválidos.'; END IF;
  v_hp:=(v_token->>'hp')::integer;
  IF v_hp<=-10 THEN RAISE EXCEPTION 'O NPC já está morto.'; END IF;
  IF v_hp NOT BETWEEN -9 AND -1 THEN RAISE EXCEPTION 'O NPC precisa estar entre -1 e -9 PV para estabilização.'; END IF;

  IF EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc
    WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='token'
      AND cc.target_id IN (v_actual_id,COALESCE(NULLIF(v_token->>'key',''),v_actual_id))
      AND cc.condition_id='stable' AND cc.active=true) THEN
    RAISE EXCEPTION 'Este NPC já está estabilizado e não precisa de nova rolagem D100.';
  END IF;
  PERFORM priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,v_hp,v_max_hp,false);
  SELECT * INTO v_condition FROM public.srd_campaign_conditions cc
  WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='token' AND cc.target_id=v_actual_id
    AND cc.condition_id='dying' AND cc.active=true
  ORDER BY cc.condition_instance_id DESC LIMIT 1 FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Condição Morrendo não foi registrada para este NPC.'; END IF;
  v_round:=GREATEST(1,COALESCE(NULLIF(v_campaign.combat_data->>'round','')::integer,1));
  IF UPPER(COALESCE(v_campaign.state,''))='COMBATE'
     AND COALESCE(v_campaign.combat_data->>'active','false')='true'
     AND COALESCE(NULLIF(v_condition.notes->>'last_resolved_round','')::integer,0)>=v_round THEN
    RAISE EXCEPTION 'A estabilização deste NPC já foi resolvida nesta rodada.';
  END IF;
  IF p_d100<=10 THEN
    v_new_hp:=v_hp; v_state:='stable';
    v_result:=priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,v_new_hp,v_max_hp,true);
  ELSE
    v_new_hp:=GREATEST(-10,v_hp-1);
    v_state:=CASE WHEN v_new_hp<=-10 THEN 'dead' ELSE 'dying' END;
    v_result:=priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,v_new_hp,v_max_hp,false);
    IF v_state='dying' THEN
      UPDATE public.srd_campaign_conditions SET notes=COALESCE(notes,'{}'::jsonb)||jsonb_build_object('last_resolved_round',v_round)
      WHERE campaign_id=p_campaign_id AND target_kind='token' AND target_id=v_actual_id AND condition_id='dying' AND active=true;
    END IF;
  END IF;
  INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
  VALUES(p_campaign_id,'ESTABILIZACAO_NPC_RESOLVIDA','PUBLIC',
    jsonb_build_object('token_id',v_actual_id,'source_character_id',v_source_id,'d100',p_d100,'round',v_round,'pv_atual',v_new_hp,'status',v_state));
  RETURN jsonb_build_object('token_id',v_actual_id,'d100',p_d100,'round',v_round,'pv_atual',v_new_hp,
    'condition',v_state,'stabilized',v_state='stable','dead',v_state='dead','sync',v_result);
END;
$function$
;

-- srd_resolve_pending_spell_resistance(p_pending_id uuid, p_d20 integer)
CREATE OR REPLACE FUNCTION public.srd_resolve_pending_spell_resistance(p_pending_id uuid, p_d20 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE v_pending priv.srd_pending_spell_resolutions%ROWTYPE; v_user uuid; v_sr integer; v_total integer; v_feat_bonus integer:=0; v_effect_bonus integer:=0;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_d20 IS NULL OR p_d20 NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'A penetração exige uma rolagem manual de D20.'; END IF;
  SELECT * INTO v_pending FROM priv.srd_pending_spell_resolutions WHERE pending_id=p_pending_id FOR UPDATE;
  IF NOT FOUND OR v_pending.status<>'awaiting_spell_resistance' OR v_pending.expires_at<now() THEN RAISE EXCEPTION 'Pedido de resistência à magia inválido ou expirado.'; END IF;
  SELECT user_id INTO v_user FROM public.characters WHERE id::text=v_pending.caster_character_id AND campaign_id=v_pending.campaign_id;
  IF v_user IS DISTINCT FROM auth.uid() AND public.my_role(v_pending.campaign_id) IS DISTINCT FROM 'GM'
     AND NOT EXISTS(SELECT 1 FROM public.campaigns c WHERE c.id=v_pending.campaign_id AND c.owner_id=auth.uid()) THEN
    RAISE EXCEPTION 'Somente o conjurador ou o Mestre pode registrar a penetração.';
  END IF;
  v_sr:=priv.srd_spell_resistance_value(v_pending.campaign_id,v_pending.target_kind,v_pending.target_id);
  v_feat_bonus:=priv.srd_spell_penetration_feat_bonus(v_pending.caster_character_id);
  v_effect_bonus:=priv.srd_effective_modifier(v_pending.campaign_id,'character',v_pending.caster_character_id,'spell_penetration');
  v_total:=p_d20+v_pending.caster_level+v_feat_bonus+v_effect_bonus;
  IF v_total<v_sr THEN
    UPDATE priv.srd_pending_spell_resolutions SET status='resisted',resolved_at=now() WHERE pending_id=p_pending_id;
    RETURN jsonb_build_object('pending_id',p_pending_id,'status','resisted','total',v_total,'spell_resistance',v_sr,'caster_level',v_pending.caster_level,'feat_bonus',v_feat_bonus,'effect_bonus',v_effect_bonus);
  END IF;
  IF v_pending.save_type IS NOT NULL THEN
    UPDATE priv.srd_pending_spell_resolutions SET status='pending_save' WHERE pending_id=p_pending_id;
    INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
    VALUES(v_pending.campaign_id,'test_request','PUBLIC',jsonb_build_object(
      'tipo','Resistência de '||CASE v_pending.save_type WHEN 'fortitude' THEN 'Fortitude' WHEN 'reflex' THEN 'Reflexos' ELSE 'Vontade' END||' (D20)',
      'alvos',CASE WHEN v_pending.target_kind='character' THEN jsonb_build_array(v_pending.target_id) ELSE '[]'::jsonb END,
      'npc_alvos',CASE WHEN v_pending.target_kind='token' THEN jsonb_build_array(v_pending.target_id) ELSE '[]'::jsonb END,
      'mestre','Sistema','mestre_id',auth.uid(),'request_id',p_pending_id::text,
      'resolution_type','spell_save','pending_id',p_pending_id,'spell_id',v_pending.spell_id,
      'save_type',v_pending.save_type,'save_dc',v_pending.save_dc
    ));
    RETURN jsonb_build_object('pending_id',p_pending_id,'status','penetrated','requires_save',true,
      'total',v_total,'spell_resistance',v_sr,'save_type',v_pending.save_type,'save_dc',v_pending.save_dc);
  END IF;
  RETURN priv.srd_apply_pending_spell_resolution(p_pending_id)||jsonb_build_object('status','penetrated','total',v_total,'spell_resistance',v_sr,'caster_level',v_pending.caster_level,'feat_bonus',v_feat_bonus,'effect_bonus',v_effect_bonus);
END;
$function$
;

-- srd_resolve_pending_spell_save(p_pending_id uuid, p_d20 integer)
CREATE OR REPLACE FUNCTION public.srd_resolve_pending_spell_save(p_pending_id uuid, p_d20 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE v_pending priv.srd_pending_spell_resolutions%ROWTYPE; v_user_id uuid; v_bonus integer; v_total integer; v_sr integer; v_caster_user uuid; v_round integer; v_school text; v_context text; v_rogue_level integer:=0; v_monk_level integer:=0; v_ranger_level integer:=0; v_evasion boolean:=false; v_improved_evasion boolean:=false; v_medium_or_heavy_armor boolean:=false;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_d20 IS NULL OR p_d20 NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'A resistência exige uma rolagem manual de D20.'; END IF;
  SELECT * INTO v_pending FROM priv.srd_pending_spell_resolutions WHERE pending_id=p_pending_id FOR UPDATE;
  IF NOT FOUND OR v_pending.status<>'pending_save' OR v_pending.expires_at<now() THEN RAISE EXCEPTION 'Pedido de resistência inválido ou expirado.'; END IF;
  IF v_pending.target_kind='character' THEN
    SELECT user_id INTO v_user_id FROM public.characters WHERE id::text=v_pending.target_id AND campaign_id=v_pending.campaign_id;
    IF v_user_id IS DISTINCT FROM auth.uid() AND public.my_role(v_pending.campaign_id) IS DISTINCT FROM 'GM'
       AND NOT EXISTS(SELECT 1 FROM public.campaigns c WHERE c.id=v_pending.campaign_id AND c.owner_id=auth.uid()) THEN
      RAISE EXCEPTION 'Somente o jogador-alvo ou o Mestre pode registrar esta resistência.';
    END IF;
  ELSIF public.my_role(v_pending.campaign_id) IS DISTINCT FROM 'GM'
        AND NOT EXISTS(SELECT 1 FROM public.campaigns c WHERE c.id=v_pending.campaign_id AND c.owner_id=auth.uid()) THEN
    RAISE EXCEPTION 'Somente o Mestre pode registrar a resistência de um NPC ou monstro.';
  END IF;
  SELECT lower(COALESCE(escola,'')) INTO v_school
    FROM public.srd_spells WHERE id=v_pending.spell_id;
  v_context:=concat_ws(',',
    'spell',
    CASE WHEN v_pending.spell_id='srd35_spell_bane' THEN 'fear' END,
    CASE WHEN COALESCE(v_school,'') LIKE '%enchant%' THEN 'enchantment' END,
    CASE WHEN COALESCE(v_school,'') LIKE '%illusion%' THEN 'illusion' END
  );
  v_bonus:=priv.srd_saving_throw_bonus(
    v_pending.campaign_id,v_pending.target_kind,v_pending.target_id,v_pending.save_type,NULLIF(v_context,'')
  );
  v_total:=p_d20+v_bonus;

  IF v_pending.target_kind='character'
     AND v_pending.save_type='reflex'
     AND v_pending.effect_kind='damage'
     AND v_pending.effect_data->>'save_result'='half' THEN
    SELECT COALESCE(MAX(cl.class_level) FILTER (WHERE cls.class_key='rogue'),
             CASE WHEN NOT EXISTS (SELECT 1 FROM public.srd_character_class_levels any_level WHERE any_level.character_id=sh.character_id)
                       AND sh.classe_id='ladino' THEN GREATEST(1,COALESCE(sh.nivel,1)) ELSE 0 END),
           COALESCE(MAX(cl.class_level) FILTER (WHERE cls.class_key='monk'),
             CASE WHEN NOT EXISTS (SELECT 1 FROM public.srd_character_class_levels any_level WHERE any_level.character_id=sh.character_id)
                       AND sh.classe_id='monge' THEN GREATEST(1,COALESCE(sh.nivel,1)) ELSE 0 END),
           COALESCE(MAX(cl.class_level) FILTER (WHERE cls.class_key='ranger'),
             CASE WHEN NOT EXISTS (SELECT 1 FROM public.srd_character_class_levels any_level WHERE any_level.character_id=sh.character_id)
                       AND sh.classe_id='ranger' THEN GREATEST(1,COALESCE(sh.nivel,1)) ELSE 0 END)
      INTO v_rogue_level,v_monk_level,v_ranger_level
      FROM public.srd_character_sheets sh
      LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
      LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
     WHERE sh.character_id::text=v_pending.target_id
     GROUP BY sh.character_id,sh.classe_id,sh.nivel;

    SELECT EXISTS (
      SELECT 1
        FROM public.srd_character_equipment ce
        JOIN public.srd_equipment eq ON eq.id=ce.equipment_id
       WHERE ce.character_id::text=v_pending.target_id
         AND ce.equipado=true
         AND (
           lower(COALESCE(eq.detalhes->>'category',eq.categoria,'')) LIKE '%medium armor%'
           OR lower(COALESCE(eq.detalhes->>'category',eq.categoria,'')) LIKE '%heavy armor%'
           OR lower(COALESCE(eq.categoria,'')) IN ('armadura','armor','armor_and_shields')
              AND lower(COALESCE(eq.nome,'')) NOT LIKE '%shield%'
              AND (
                COALESCE(eq.bonus_max_des,eq.max_des,0)<=3
                OR lower(COALESCE(eq.nome,'')) LIKE '%peles%'
              )
         )
    ) INTO v_medium_or_heavy_armor;

    v_evasion:=NOT v_medium_or_heavy_armor
      AND (COALESCE(v_rogue_level,0)>=2 OR COALESCE(v_monk_level,0)>=2 OR COALESCE(v_ranger_level,0)>=9);
    v_improved_evasion:=NOT v_medium_or_heavy_armor AND COALESCE(v_monk_level,0)>=9;
  END IF;

  IF v_pending.condition_break THEN
    SELECT GREATEST(1,COALESCE(NULLIF(c.combat_data->>'round','')::integer,1))
      INTO v_round FROM public.campaigns c WHERE c.id=v_pending.campaign_id;
    IF (p_d20=20 OR (p_d20<>1 AND v_total>=v_pending.save_dc)) THEN
      UPDATE public.srd_campaign_conditions
         SET active=false,
             notes=COALESCE(notes,'{}'::jsonb)||jsonb_build_object('ended_by_save',true,'last_save_round',v_round)
       WHERE condition_instance_id=v_pending.condition_break_instance_id
         AND campaign_id=v_pending.campaign_id AND active=true;
      UPDATE priv.srd_pending_spell_resolutions SET status='saved',resolved_at=now() WHERE pending_id=p_pending_id;
      RETURN jsonb_build_object('pending_id',p_pending_id,'saved',true,'condition_ended',true,
        'total',v_total,'bonus',v_bonus,'dc',v_pending.save_dc,'status','condition_ended');
    ELSE
      UPDATE public.srd_campaign_conditions
         SET notes=COALESCE(notes,'{}'::jsonb)||jsonb_build_object('last_save_round',v_round)
       WHERE condition_instance_id=v_pending.condition_break_instance_id
         AND campaign_id=v_pending.campaign_id AND active=true;
      UPDATE priv.srd_pending_spell_resolutions SET status='resolved',resolved_at=now() WHERE pending_id=p_pending_id;
      RETURN jsonb_build_object('pending_id',p_pending_id,'saved',false,'condition_ended',false,
        'total',v_total,'bonus',v_bonus,'dc',v_pending.save_dc,'status','condition_persists');
    END IF;
  END IF;

  IF (p_d20=20 OR (p_d20<>1 AND v_total>=v_pending.save_dc)) THEN
    IF v_pending.effect_kind='damage' AND v_pending.effect_data->>'save_result' IN ('half','damage_unaffected') THEN
      UPDATE priv.srd_pending_spell_resolutions
         SET effect_data=(
           CASE
             WHEN effect_data->>'save_result'='half' AND v_evasion THEN
               jsonb_set(effect_data,'{damage}',to_jsonb(0),true)
             WHEN effect_data->>'save_result'='half' THEN
               jsonb_set(effect_data,'{damage}',
                 to_jsonb(GREATEST(0,FLOOR(COALESCE(NULLIF(effect_data->>'damage','')::numeric,0)/2)::integer)),true)
             ELSE effect_data
           END
         )||jsonb_build_object('apply_secondary_condition',false)
       WHERE pending_id=p_pending_id;
      RETURN priv.srd_apply_pending_spell_resolution(p_pending_id)
        ||jsonb_build_object('saved',true,'save_total',v_total,'save_bonus',v_bonus,'save_dc',v_pending.save_dc,
          'save_result',v_pending.effect_data->>'save_result','evasion',v_evasion,
          'improved_evasion',v_improved_evasion,'evasion_armor_blocked',v_medium_or_heavy_armor);
    END IF;
    UPDATE priv.srd_pending_spell_resolutions SET status='saved',resolved_at=now() WHERE pending_id=p_pending_id;
    RETURN jsonb_build_object('pending_id',p_pending_id,'saved',true,'total',v_total,'bonus',v_bonus,'dc',v_pending.save_dc,'status','saved');
  END IF;
  IF v_pending.effect_kind='damage' AND v_pending.effect_data->>'save_result'='half' AND v_improved_evasion THEN
    UPDATE priv.srd_pending_spell_resolutions
       SET effect_data=jsonb_set(effect_data,'{damage}',
         to_jsonb(GREATEST(0,FLOOR(COALESCE(NULLIF(effect_data->>'damage','')::numeric,0)/2)::integer)),true)
     WHERE pending_id=p_pending_id;
    RETURN priv.srd_apply_pending_spell_resolution(p_pending_id)
      || jsonb_build_object('saved',false,'save_total',v_total,'save_bonus',v_bonus,'save_dc',v_pending.save_dc,
        'evasion',true,'improved_evasion',true,'evasion_armor_blocked',false);
  END IF;
  RETURN priv.srd_apply_pending_spell_resolution(p_pending_id)
    || jsonb_build_object('saved',false,'save_total',v_total,'save_bonus',v_bonus,'save_dc',v_pending.save_dc,
      'evasion',v_evasion,'improved_evasion',v_improved_evasion,'evasion_armor_blocked',v_medium_or_heavy_armor);
END;
$function$
;

-- srd_resolve_requested_saving_throw_srd(p_campaign_id bigint, p_character_id text, p_request_id text, p_d20 integer)
CREATE OR REPLACE FUNCTION public.srd_resolve_requested_saving_throw_srd(p_campaign_id bigint, p_character_id text, p_request_id text, p_d20 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_character public.characters%ROWTYPE;
  v_request public.campaign_log%ROWTYPE;
  v_save_type text;
  v_context text;
  v_dc integer;
  v_bonus integer;
  v_base_bonus integer;
  v_total integer;
  v_result jsonb;
  v_master uuid;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_d20 IS NULL OR p_d20 NOT BETWEEN 1 AND 20 THEN
    RAISE EXCEPTION 'Resultado de d20 inválido.';
  END IF;
  IF NULLIF(BTRIM(p_request_id),'') IS NULL THEN
    RAISE EXCEPTION 'Pedido de teste inválido.';
  END IF;

  SELECT * INTO v_character
    FROM public.characters
   WHERE id::text=BTRIM(p_character_id)
     AND campaign_id=p_campaign_id
     AND user_id=auth.uid();
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou não pertence ao jogador.'; END IF;

  SELECT * INTO v_request
    FROM public.campaign_log
   WHERE campaign_id=p_campaign_id
     AND type='test_request'
     AND data->>'request_id'=BTRIM(p_request_id)
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Pedido de resistência não encontrado ou expirado.'; END IF;
  IF v_request.data->>'resolution_type'<>'saving_throw' THEN
    RAISE EXCEPTION 'Este pedido não é um teste de resistência SRD.';
  END IF;
  IF NOT COALESCE(v_request.data->'alvos' @> jsonb_build_array(v_character.id::text),false) THEN
    RAISE EXCEPTION 'Este pedido não foi direcionado ao personagem.';
  END IF;
  IF COALESCE(v_request.data->'results','{}'::jsonb) ? v_character.id::text THEN
    RAISE EXCEPTION 'Este teste já foi respondido por este personagem.';
  END IF;

  v_master:=NULLIF(v_request.data->>'mestre_id','')::uuid;
  IF v_master IS NULL OR NOT EXISTS (
    SELECT 1 FROM public.members m
     WHERE m.campaign_id=p_campaign_id AND m.user_id=v_master AND upper(m.role)='GM'
  ) THEN
    RAISE EXCEPTION 'O pedido não foi emitido por um Mestre autorizado.';
  END IF;

  v_save_type:=lower(COALESCE(v_request.data->>'save_type',''));
  IF v_save_type NOT IN ('fortitude','reflex','will') THEN
    RAISE EXCEPTION 'Tipo de resistência inválido no pedido.';
  END IF;
  v_context:=lower(COALESCE(v_request.data->>'context',''));
  IF v_context<>'' AND NOT (string_to_array(v_context,',') <@ ARRAY['trap','poison','spell','enchantment','fear','illusion']) THEN
    RAISE EXCEPTION 'Contexto de resistência inválido no pedido.';
  END IF;
  v_dc:=CASE WHEN COALESCE(v_request.data->>'dc','') ~ '^[0-9]{1,3}$'
             THEN (v_request.data->>'dc')::integer ELSE NULL END;
  IF v_dc IS NOT NULL AND v_dc NOT BETWEEN 1 AND 100 THEN
    RAISE EXCEPTION 'Classe de dificuldade inválida.';
  END IF;

  v_bonus:=priv.srd_saving_throw_bonus(
    p_campaign_id,'character',v_character.id::text,v_save_type,NULLIF(v_context,'')
  );
  v_base_bonus:=priv.srd_saving_throw_bonus(
    p_campaign_id,'character',v_character.id::text,v_save_type,NULL
  );
  v_total:=p_d20+v_bonus;
  v_result:=jsonb_build_object(
    'request_id',p_request_id,
    'character_id',v_character.id::text,
    'character_name',v_character.nome,
    'save_type',v_save_type,
    'context',NULLIF(v_context,''),
    'd20',p_d20,
    'bonus',v_bonus,
    'total',v_total,
    'dc',v_dc,
    'success',CASE WHEN v_dc IS NULL THEN NULL WHEN p_d20=1 THEN false WHEN p_d20=20 THEN true ELSE v_total>=v_dc END,
    'natural_1',p_d20=1,
    'natural_20',p_d20=20,
    'trap_sense_bonus',CASE WHEN v_context='trap' AND v_save_type='reflex' THEN v_bonus-v_base_bonus ELSE 0 END
  );

  UPDATE public.campaign_log
     SET data=jsonb_set(
       jsonb_set(COALESCE(data,'{}'::jsonb),'{results}',COALESCE(data->'results','{}'::jsonb),true),
       ARRAY['results',v_character.id::text],v_result,true
     )
   WHERE id=v_request.id;

  RETURN v_result;
END;
$function$
;

-- srd_resolver_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid)
CREATE OR REPLACE FUNCTION public.srd_resolver_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_attack priv.srd_aoo_attacks%rowtype;
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_actor_token jsonb;
  v_target jsonb;
  v_sheet public.srd_character_sheets%rowtype;
  v_class public.srd_classes%rowtype;
  v_race public.srd_races%rowtype;
  v_weapon public.srd_equipment%rowtype;
  v_instance public.srd_character_weapon_instances%rowtype;
  v_target_ac integer;
  v_target_ac_data jsonb;
  v_bab integer:=0;
  v_level integer:=1;
  v_score integer:=10;
  v_ability_mod integer:=0;
  v_size_mod integer:=0;
  v_focus integer:=0;
  v_prof_penalty integer:=0;
  v_racial_bonus integer:=0;
  v_effect_attack integer:=0;
  v_expected integer;
  v_total integer;
  v_attack_key text;
  v_weapon_name text;
  v_weapon_prof text;
  v_profs jsonb;
  v_proficient boolean:=false;
  v_finesse boolean:=false;
  v_target_traits text;
  v_crit_text text;
  v_crit_min integer:=20;
  v_crit_mult integer:=2;
  v_is_threat boolean:=false;
  v_status text;
  v_target_type text;
  v_actor_is_giant boolean:=false;
  v_target_race text;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode resolver ataques de oportunidade.';
  end if;
  select * into v_attack from priv.srd_aoo_attacks
  where attack_id=p_attack_id and campaign_id=p_campaign_id for update;
  if not found then raise exception 'Ataque de oportunidade não encontrado.'; end if;
  if v_attack.created_by<>auth.uid() then raise exception 'Somente o Mestre que iniciou o ataque pode resolvê-lo.'; end if;
  if v_attack.status<>'awaiting_attack_roll' or v_attack.manual_d20 is null then
    if v_attack.status in ('awaiting_critical_confirmation','awaiting_damage','miss','damage_applied') then
      return jsonb_build_object('attack_id',p_attack_id,'status',v_attack.status,
        'attack_total',v_attack.attack_total,'target_ac',v_attack.target_ac,
        'is_critical',v_attack.is_critical,'resolution_data',v_attack.resolution_data,'replayed',true);
    end if;
    raise exception 'Registre primeiro a rolagem manual do d20.';
  end if;

  select * into v_pending from priv.srd_aoo_pending_movements
  where pending_id=v_attack.pending_id and campaign_id=p_campaign_id for update;
  if not found or v_pending.status<>'waiting_reactions' then raise exception 'Movimento pendente não está mais ativo.'; end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
    or coalesce(v_campaign.combat_data->>'active','false')<>'true'
    or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
    or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'O combate mudou antes da resolução do ataque.';
  end if;

  select t into v_actor_token from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=v_attack.actor_token_id or t->>'key'=v_attack.actor_token_id limit 1;
  select t into v_target from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=v_attack.target_token_id or t->>'key'=v_attack.target_token_id limit 1;
  if v_actor_token is null or v_target is null then raise exception 'Atacante ou alvo saiu da cena.'; end if;

  if v_attack.actor_character_id is null then
    v_actor_is_giant:=lower(concat_ws(' ',v_actor_token->>'creature_type',
      v_actor_token->'monsterStats'->>'type',v_actor_token->'monsterStats'->>'tipo',
      v_actor_token->'monsterStats'->>'creature_type',v_actor_token->'monsterStats'->>'subtype')) ~ '(giant|gigante)';
    if v_target->>'tipo'='player' then
      v_target_ac_data:=public.srd_calcular_ca_personagem_srd(p_campaign_id,v_attack.target_token_id,'normal',v_actor_is_giant);
      v_target_ac:=nullif(v_target_ac_data->>'final_ac','')::integer
        +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
    elsif v_target->>'tipo'='npc' AND NULLIF(v_target->>'sourceCharacterId','') IS NOT NULL then
      v_target_ac_data:=priv.srd_calcular_ca_alvo_campanha_srd(
        p_campaign_id,v_target->>'sourceCharacterId','normal'
      );
      v_target_ac:=nullif(v_target_ac_data->>'final_ac','')::integer
        +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
      if v_actor_is_giant then
        select lower(sh.raca_id::text) into v_target_race
          from public.srd_character_sheets sh
         where sh.character_id::text=v_target->>'sourceCharacterId';
        if v_target_race in ('anao','gnomo')
           and not coalesce((v_target_ac_data->>'dexterity_lost')::boolean,false) then
          v_target_ac:=v_target_ac+4;
        end if;
      end if;
    else
      if coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca','') !~ '^[0-9]{1,3}$' then
        raise exception 'O alvo não possui CA numérica válida.';
      end if;
      v_target_ac:=(coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca'))::integer
        +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac')
        +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
    end if;
    v_expected:=coalesce(nullif(v_attack.resolution_data->>'monster_attack_bonus','')::integer,0)
      +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'attack')
      +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'attack_melee');
    v_total:=v_attack.manual_d20+v_expected;
    v_crit_min:=coalesce(nullif(v_attack.resolution_data->>'critical_threat_minimum','')::integer,20);
    v_crit_mult:=coalesce(nullif(v_attack.resolution_data->>'critical_multiplier','')::integer,2);
    v_is_threat:=v_attack.manual_d20>=v_crit_min
      and (v_attack.manual_d20=20 or (v_attack.manual_d20<>1 and v_total>=v_target_ac));
    v_status:=case when v_attack.manual_d20=20 or (v_attack.manual_d20<>1 and v_total>=v_target_ac)
      then case when v_is_threat then 'awaiting_critical_confirmation' else 'awaiting_damage' end
      else 'miss' end;
    update priv.srd_aoo_attacks set status=v_status,attack_total=v_total,target_ac=v_target_ac,
      resolution_data=resolution_data||jsonb_build_object('attack_total',v_total,'target_ac',v_target_ac,
        'monster_attack_bonus',v_expected,'critical_threat',v_is_threat,'critical_threat_minimum',v_crit_min,
        'critical_multiplier',v_crit_mult,'manual_d20',v_attack.manual_d20),resolved_at=now()
    where attack_id=p_attack_id returning * into v_attack;
    update priv.srd_aoo_pending_movements p
    set pending_reactions=jsonb_set(p.pending_reactions,ARRAY[
      (select (e.ordinality-1)::text from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
       where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1)
    ],(
      select e.value||jsonb_build_object('status',case when v_status='miss' then 'miss' else 'hit_pending_damage' end)
      from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
      where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1
    ),false),updated_at=now()
    where p.pending_id=v_attack.pending_id;
    return jsonb_build_object('attack_id',p_attack_id,'status',v_status,
      'manual_d20',v_attack.manual_d20,'attack_total',v_total,'target_ac',v_target_ac,
      'critical_threat',v_is_threat,'critical_multiplier',v_crit_mult,
      'damage_expression',v_attack.resolution_data->>'damage_expression',
      'resolution_data',v_attack.resolution_data,'action_economy_cost',0);
  end if;

  select * into v_sheet from public.srd_character_sheets where character_id=v_attack.actor_character_id;
  select * into v_class from public.srd_classes where id=v_sheet.classe_id;
  select * into v_race from public.srd_races where id=v_sheet.raca_id;
  select * into v_instance from public.srd_character_weapon_instances
  where instance_id=v_attack.weapon_instance_id and character_id=v_attack.actor_character_id::text
    and equipado is true and hand_slot=v_attack.weapon_hand_slot;
  if not found or not exists(select 1 from public.srd_character_equipment ce
    where ce.character_id=v_attack.actor_character_id::text and ce.equipment_id=v_instance.equipment_id
      and ce.equipado is true and ce.hand_slot=v_attack.weapon_hand_slot) then
    raise exception 'A arma deixou de estar equipada corretamente.';
  end if;
  select * into v_weapon from public.srd_equipment where id=v_instance.equipment_id;

  v_level:=greatest(1,coalesce(v_sheet.nivel,1));
  select coalesce(sum(case lower(coalesce(cl.bab_progression,''))
    when 'good' then lv.class_level when 'bom' then lv.class_level
    when 'average' then floor(3*lv.class_level/4.0)::integer
    when 'medium' then floor(3*lv.class_level/4.0)::integer
    when 'medio' then floor(3*lv.class_level/4.0)::integer
    when 'poor' then floor(lv.class_level/2.0)::integer
    when 'ruim' then floor(lv.class_level/2.0)::integer else 0 end),0)::integer
  into v_bab from public.srd_character_class_levels lv
  join public.srd_classes cl on cl.id=lv.class_id where lv.character_id=v_attack.actor_character_id;
  if not exists(select 1 from public.srd_character_class_levels lv where lv.character_id=v_attack.actor_character_id) then
    v_bab:=case lower(coalesce(v_class.bab_progression,''))
      when 'good' then v_level when 'bom' then v_level
      when 'average' then floor(3*v_level/4.0)::integer
      when 'medium' then floor(3*v_level/4.0)::integer
      when 'medio' then floor(3*v_level/4.0)::integer
      when 'poor' then floor(v_level/2.0)::integer
      when 'ruim' then floor(v_level/2.0)::integer else 0 end;
  end if;

  v_weapon_name:=coalesce(v_weapon.detalhes->>'weapon_proficiency_name',v_weapon.nome);
  v_weapon_prof:=priv.srd_weapon_proficiency(v_weapon.detalhes,v_weapon_name);
  v_profs:=coalesce(v_class.dados_tecnicos->'proficiencias'->'armas','[]'::jsonb);
  v_proficient:=exists(select 1 from jsonb_array_elements_text(case when jsonb_typeof(v_profs)='array' then v_profs else '[]'::jsonb end) p
    where lower(btrim(p.value))='todas as armas simples e marciais' AND v_weapon_prof IN ('simple','martial')
      or public.srd35_normalizar_parametro_talento(p.value)=public.srd35_normalizar_parametro_talento(v_weapon_name)
      or (lower(btrim(p.value))='armas simples' and v_weapon_prof='simple'));
  -- Para Anões, armas com familiaridade racial são tratadas como marciais.
  if not v_proficient and v_race.id='anao' and v_weapon_prof='exotic'
     and coalesce(v_weapon.detalhes->'weapon_familiarity_race_ids','[]'::jsonb) ? 'anao' then
    v_proficient:=exists(select 1 from jsonb_array_elements_text(case when jsonb_typeof(v_profs)='array' then v_profs else '[]'::jsonb end) p
      where lower(btrim(p.value))='todas as armas simples e marciais');
  end if;
  if not v_proficient then
    v_proficient:=exists(select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
      where (f->>'id'='srd35_feat_simple_weapon_proficiency' and v_weapon_prof='simple')
        or (f->>'id' in ('srd35_feat_martial_weapon_proficiency','srd35_feat_exotic_weapon_proficiency')
          and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name)));
  end if;
  if not v_proficient then v_prof_penalty:=4; end if;

  v_finesse:=exists(select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
    where f->>'id'='srd35_feat_weapon_finesse');
  if v_finesse and coalesce(v_weapon.detalhes->>'weapon_finesse_eligible','false')='true' then
    v_attack_key:='DES'; v_score:=coalesce(nullif(v_sheet.atributos->>'DES','')::integer,10);
  else
    v_attack_key:='FOR'; v_score:=coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10);
  end if;
  v_ability_mod:=floor((v_score-10)::numeric/2)::integer;
  if lower(coalesce(v_race.tamanho,'')) in ('pequeno','small') then v_size_mod:=1;
  elsif lower(coalesce(v_race.tamanho,'')) in ('grande','large') then v_size_mod:=-1; end if;

  v_focus:=(case when exists(select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
      where f->>'id'='foco_em_arma' and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name)) then 1 else 0 end)
    +(case when exists(select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
      where f->>'id'='srd35_feat_greater_weapon_focus' and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name)) then 1 else 0 end);

  v_target_race:=lower(coalesce(nullif(v_target->>'raca_id',''),
    nullif(v_target->>'race_id',''),nullif(v_target->'monsterStats'->>'race_id','')));
  if v_target->>'tipo'='player' then
    select lower(sh.raca_id::text) into v_target_race
      from public.srd_character_sheets sh
     where sh.character_id::text=v_attack.target_token_id;
  elsif v_target->>'tipo'='npc' and nullif(v_target->>'sourceCharacterId','') is not null then
    select lower(sh.raca_id::text) into v_target_race
      from public.srd_character_sheets sh
     where sh.character_id::text=v_target->>'sourceCharacterId';
  end if;
  v_target_traits:=lower(concat_ws(' ',v_target->>'nome',v_target->>'detalhe',
    v_target->'monsterStats'->>'tipo',v_target->'monsterStats'->>'subtipo',
    v_target->'monsterStats'->>'type',v_target->'monsterStats'->>'creature_type',
    v_target_race));
  if v_race.id='anao' and v_target_traits ~ '(^|[^a-z])(orc|goblin|hobgoblin|bugbear|goblinoid(e)?)([^a-z]|$)' then v_racial_bonus:=1; end if;

  v_effect_attack:=priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'attack')
    +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'attack_melee')
    +floor((coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)
      +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'strength')-10)::numeric/2)::integer
    -floor((coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)-10)::numeric/2)::integer;

  v_actor_is_giant:=lower(concat_ws(' ',v_actor_token->>'creature_type',v_actor_token->'monsterStats'->>'type',v_actor_token->'monsterStats'->>'tipo',v_actor_token->'monsterStats'->>'creature_type',v_actor_token->'monsterStats'->>'subtype',v_actor_token->'monsterStats'->>'subtypes')) ~ '(giant|gigante)';
  if v_target->>'tipo'='player' then
    v_target_ac_data:=public.srd_calcular_ca_personagem_srd(p_campaign_id,v_attack.target_token_id,'normal',v_actor_is_giant);
    v_target_ac:=nullif(v_target_ac_data->>'final_ac','')::integer
      +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
  elsif v_target->>'tipo'='npc' AND NULLIF(v_target->>'sourceCharacterId','') IS NOT NULL then
    v_target_ac_data:=priv.srd_calcular_ca_alvo_campanha_srd(
      p_campaign_id,v_target->>'sourceCharacterId','normal'
    );
    v_target_ac:=nullif(v_target_ac_data->>'final_ac','')::integer
      +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
    if v_actor_is_giant then
      select lower(sh.raca_id::text) into v_target_race
        from public.srd_character_sheets sh
       where sh.character_id::text=v_target->>'sourceCharacterId';
      if v_target_race in ('anao','gnomo')
         and not coalesce((v_target_ac_data->>'dexterity_lost')::boolean,false) then
        v_target_ac:=v_target_ac+4;
      end if;
    end if;
  else
    if coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca','') !~ '^[0-9]{1,3}$' then
      raise exception 'O alvo não possui CA numérica válida.';
    end if;
    v_target_ac:=(coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca'))::integer
      +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac')
      +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
  end if;
  if v_target_ac is null then raise exception 'Não foi possível calcular a CA do alvo.'; end if;

  v_expected:=v_bab+v_ability_mod+v_size_mod+v_focus+v_racial_bonus-v_prof_penalty;
  v_total:=v_attack.manual_d20+v_expected+v_effect_attack;
  v_crit_text:=coalesce(v_attack.resolution_data->>'weapon_critical',v_weapon.critico,'x2');
  if v_crit_text ~ '^[0-9]{2}(-[0-9]{2})?/x[0-9]+$' then
    v_crit_min:=split_part(v_crit_text,'-',1)::integer;
  else
    v_crit_min:=20;
  end if;
  if v_crit_min<2 or v_crit_min>20 then v_crit_min:=20; end if;
  v_crit_mult:=coalesce(nullif(regexp_replace(v_crit_text,'^.*x',''),'')::integer,2);
  if v_crit_mult<2 or v_crit_mult>5 then v_crit_mult:=2; end if;

  if v_attack.manual_d20=20 or (v_attack.manual_d20<>1 and v_total>=v_target_ac) then
    v_is_threat:=v_attack.manual_d20>=v_crit_min;
    v_status:=case when v_is_threat then 'awaiting_critical_confirmation' else 'awaiting_damage' end;
  else
    v_status:='miss';
  end if;

  update priv.srd_aoo_attacks set
    status=v_status,attack_total=v_total,target_ac=v_target_ac,
    resolution_data=resolution_data||jsonb_build_object(
      'base_attack_bonus',v_bab,'ability',v_attack_key,'ability_modifier',v_ability_mod,
      'size_modifier',v_size_mod,'weapon_focus',v_focus,'racial_bonus',v_racial_bonus,
      'proficiency_penalty',v_prof_penalty,'effect_attack_modifier',v_effect_attack,
      'attack_total',v_total,'target_ac',v_target_ac,'manual_d20',v_attack.manual_d20,
      'critical_threat_minimum',v_crit_min,'critical_multiplier',v_crit_mult,
      'critical_threat',v_is_threat
    ),resolved_at=now()
  where attack_id=p_attack_id returning * into v_attack;

  update priv.srd_aoo_pending_movements p
  set pending_reactions=jsonb_set(p.pending_reactions,ARRAY[
    (select (e.ordinality-1)::text from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
     where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1)
  ],(
    select e.value||jsonb_build_object('status',case when v_status='miss' then 'miss' else 'hit_pending_damage' end)
    from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
    where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1
  ),false),updated_at=now()
  where p.pending_id=v_attack.pending_id;

  return jsonb_build_object('attack_id',p_attack_id,'status',v_status,
    'manual_d20',v_attack.manual_d20,'attack_total',v_total,'target_ac',v_target_ac,
    'critical_threat',v_is_threat,'critical_multiplier',v_crit_mult,
    'damage_expression',v_weapon.dano,'resolution_data',v_attack.resolution_data,
    'action_economy_cost',0);
end;
$function$
;

-- srd_resolver_derrubar_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_defender_firm_ground boolean)
CREATE OR REPLACE FUNCTION public.srd_resolver_derrubar_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_defender_firm_ground boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
  SELECT priv.srd_resolver_derrubar_apos_aoo_srd(
    p_campaign_id,p_pending_id,p_attacker_d20,p_defender_d20,p_defender_firm_ground
  );
$function$
;

-- srd_resolver_derrubar_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_attacker_d20 integer, p_defender_d20 integer, p_defender_uses_dex boolean, p_defender_firm_ground boolean, p_trip_using_weapon boolean)
CREATE OR REPLACE FUNCTION public.srd_resolver_derrubar_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_attacker_d20 integer, p_defender_d20 integer, p_defender_uses_dex boolean DEFAULT false, p_defender_firm_ground boolean DEFAULT false, p_trip_using_weapon boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'public', 'pg_temp'
AS $function$
  SELECT priv.srd_resolver_derrubar_srd_api(
    p_campaign_id,p_attacker_token_id,p_defender_token_id,
    p_attacker_d20,p_defender_d20,p_defender_firm_ground,p_trip_using_weapon
  );
$function$
;

-- srd_resolver_encontrao_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_follow boolean)
CREATE OR REPLACE FUNCTION public.srd_resolver_encontrao_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_follow boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$ select priv.srd_resolver_encontrao_srd($1,$2,$3,$4,$5) $function$
;

-- srd_resolver_levantar_caido_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid)
CREATE OR REPLACE FUNCTION public.srd_resolver_levantar_caido_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$ SELECT priv.srd_resolver_levantar_caido_apos_aoo_srd(p_campaign_id,p_pending_id); $function$
;

-- srd_resolver_teste_resistencia_token_srd(p_campaign_id bigint, p_token_id text, p_save_type text, p_context text, p_d20 integer, p_dc integer)
CREATE OR REPLACE FUNCTION public.srd_resolver_teste_resistencia_token_srd(p_campaign_id bigint, p_token_id text, p_save_type text, p_context text, p_d20 integer, p_dc integer DEFAULT NULL::integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_campaign public.campaigns%ROWTYPE;
  v_token jsonb;
  v_token_count integer;
  v_source_id text;
  v_owner uuid;
  v_save_type text:=lower(btrim(coalesce(p_save_type,'')));
  v_context text:=lower(btrim(coalesce(p_context,'')));
  v_bonus integer;
  v_base_bonus integer;
  v_total integer;
  v_success boolean;
  v_result jsonb;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Autenticação obrigatória.';
  END IF;
  IF public.my_role(p_campaign_id) IS DISTINCT FROM 'GM'
     AND NOT EXISTS(SELECT 1 FROM public.campaigns c WHERE c.id=p_campaign_id AND c.owner_id=auth.uid()) THEN
    RAISE EXCEPTION 'Somente o Mestre pode registrar resistência de NPC ou monstro.';
  END IF;
  IF p_d20 IS NULL OR p_d20 NOT BETWEEN 1 AND 20 THEN
    RAISE EXCEPTION 'A resistência exige uma rolagem manual de D20 entre 1 e 20.';
  END IF;
  IF v_save_type NOT IN ('fortitude','reflex','will') THEN
    RAISE EXCEPTION 'Tipo de resistência inválido.';
  END IF;
  IF v_context<>'' AND NOT (string_to_array(v_context,',') <@ ARRAY['trap','poison','spell','enchantment','fear','illusion']) THEN
    RAISE EXCEPTION 'Contexto de resistência inválido.';
  END IF;
  IF p_dc IS NOT NULL AND p_dc NOT BETWEEN 1 AND 100 THEN
    RAISE EXCEPTION 'A CD deve estar entre 1 e 100.';
  END IF;
  IF NULLIF(btrim(p_token_id),'') IS NULL THEN
    RAISE EXCEPTION 'Token-alvo inválido.';
  END IF;

  SELECT * INTO v_campaign
    FROM public.campaigns
   WHERE id=p_campaign_id
   FOR SHARE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;

  SELECT count(*)::integer, min(t.value)
    INTO v_token_count, v_token
    FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array'
        THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END
    ) t(value)
   WHERE t.value->>'id'=btrim(p_token_id)
     AND t.value->>'tipo' IN ('npc','monstro');
  IF v_token_count<>1 THEN
    RAISE EXCEPTION 'Token NPC/monstro não encontrado ou duplicado.';
  END IF;

  v_source_id:=NULLIF(btrim(v_token->>'sourceCharacterId'),'');
  IF v_source_id IS NOT NULL THEN
    SELECT ch.user_id INTO v_owner
      FROM public.characters ch
     WHERE ch.id::text=v_source_id;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Ficha de origem do NPC não encontrada.';
    END IF;
    IF v_owner IS DISTINCT FROM auth.uid() THEN
      RAISE EXCEPTION 'O Mestre só pode consultar resistências de NPCs vinculados a fichas que pertencem à sua própria conta.';
    END IF;
  END IF;

  v_bonus:=priv.srd_saving_throw_bonus(
    p_campaign_id,'token',btrim(p_token_id),v_save_type,NULLIF(v_context,'')
  );
  v_base_bonus:=priv.srd_saving_throw_bonus(
    p_campaign_id,'token',btrim(p_token_id),v_save_type,NULL
  );
  v_total:=p_d20+v_bonus;
  v_success:=CASE
    WHEN p_dc IS NULL THEN NULL
    WHEN p_d20=1 THEN false
    WHEN p_d20=20 THEN true
    ELSE v_total>=p_dc
  END;

  v_result:=jsonb_build_object(
    'campaign_id',p_campaign_id,
    'token_id',btrim(p_token_id),
    'source_character_id',v_source_id,
    'target_name',coalesce(v_token->>'nome','Alvo'),
    'target_type',v_token->>'tipo',
    'save_type',v_save_type,
    'context',NULLIF(v_context,''),
    'd20',p_d20,
    'base_bonus',v_base_bonus,
    'situational_bonus',v_bonus-v_base_bonus,
    'bonus',v_bonus,
    'total',v_total,
    'dc',p_dc,
    'success',v_success,
    'natural_1',p_d20=1,
    'natural_20',p_d20=20
  );

  PERFORM priv.log(p_campaign_id,'NPC_SAVING_THROW',v_result);
  RETURN v_result;
END;
$function$
;

-- srd_solicitar_movimento_com_aoo_srd(p_campaign_id bigint, p_mover_token_id text, p_destination_x integer, p_destination_y integer, p_controller text)
CREATE OR REPLACE FUNCTION public.srd_solicitar_movimento_com_aoo_srd(p_campaign_id bigint, p_mover_token_id text, p_destination_x integer, p_destination_y integer, p_controller text DEFAULT 'player'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_campaign public.campaigns%rowtype;
  v_combat jsonb;
  v_order jsonb;
  v_round integer;
  v_turn integer;
  v_actor_id text;
  v_token jsonb;
  v_token_type text;
  v_pos_x integer;
  v_pos_y integer;
  v_detection jsonb;
  v_pending_id uuid;
  v_reactions jsonb;
begin
  if auth.uid() is null then raise exception 'É necessário estar autenticado.'; end if;
  if p_controller not in ('player','gm') then raise exception 'Controlador de movimento inválido.'; end if;
  if p_controller='gm' and public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode solicitar movimento de token sob seu controle.';
  end if;

  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found then raise exception 'Campanha não encontrada.'; end if;
  v_combat:=coalesce(v_campaign.combat_data,'{}'::jsonb);
  if upper(coalesce(v_campaign.state,''))<>'COMBATE'
     or coalesce(v_combat->>'active','false')<>'true' then
    return jsonb_build_object('pending',false,'requires_aoo',false,
      'reason','combat_not_active','continue_with_existing_movement_rpc',true);
  end if;
  if coalesce(v_combat->>'round','') !~ '^[0-9]+$'
     or coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$' then
    raise exception 'Rodada ou turno de combate inválido.';
  end if;
  v_round:=greatest(1,(v_combat->>'round')::integer);
  v_turn:=(v_combat->>'current_turn')::integer;
  v_order:=case when jsonb_typeof(v_combat->'turn_order')='array'
    then v_combat->'turn_order' else '[]'::jsonb end;
  if v_turn<0 or v_turn>=jsonb_array_length(v_order) then
    raise exception 'Índice do turno atual inválido.';
  end if;
  v_actor_id:=v_order->v_turn->>'id';

  select t into v_token
  from jsonb_array_elements(case when jsonb_typeof(v_campaign.cba_data->'tokens')='array'
    then v_campaign.cba_data->'tokens' else '[]'::jsonb end) t
  where t->>'id'=btrim(p_mover_token_id) or t->>'key'=btrim(p_mover_token_id)
  limit 1;
  if v_token is null then raise exception 'Token não encontrado na cena.'; end if;
  v_token_type:=v_token->>'tipo';
  if coalesce(v_token->>'gridX','') !~ '^[0-9]{1,3}$'
     or coalesce(v_token->>'gridY','') !~ '^[0-9]{1,3}$' then
    raise exception 'Posição atual do token inválida.';
  end if;
  v_pos_x:=(v_token->>'gridX')::integer;
  v_pos_y:=(v_token->>'gridY')::integer;

  if p_controller='player' then
    if v_token_type<>'player'
       or v_actor_id is distinct from btrim(p_mover_token_id)
       or not exists(select 1 from public.characters c
         where c.id::text=btrim(p_mover_token_id)
           and c.campaign_id=p_campaign_id and c.user_id=auth.uid()) then
      raise exception 'O personagem não é seu ou não está no turno ativo.';
    end if;
  else
    if v_actor_id is distinct from btrim(p_mover_token_id)
       or v_token_type not in ('npc','monstro','player') then
      raise exception 'O token não está no turno ativo ou não pode ser controlado pelo Mestre.';
    end if;
  end if;

  v_detection:=public.srd_detectar_saida_alcance_ameacado_srd(
    p_campaign_id,btrim(p_mover_token_id),p_destination_x,p_destination_y);
  if coalesce((v_detection->>'detected')::boolean,false) is not true then
    return jsonb_build_object('pending',false,'requires_aoo',false,
      'reason',coalesce(v_detection->>'reason','no_threat_detected'),
      'detection',v_detection,'continue_with_existing_movement_rpc',true);
  end if;

  if exists(select 1 from priv.srd_aoo_pending_movements
    where campaign_id=p_campaign_id and status in ('waiting_reactions','ready_to_commit')) then
    raise exception 'Já existe um movimento aguardando resolução de ataques de oportunidade nesta campanha.';
  end if;

  v_reactions:=(
    select coalesce(jsonb_agg(jsonb_build_object(
      'reactor_token_id',coalesce(x->>'token_id',x->>'token_key'),
      'trigger_key',concat('move:',p_mover_token_id,':',v_round,':',p_destination_x,':',p_destination_y,':',coalesce(x->>'token_id',x->>'token_key')),
      'status','waiting',
      'threat',x
    )),'[]'::jsonb)
    from jsonb_array_elements(coalesce(v_detection->'threats','[]'::jsonb)) x
  );
  insert into priv.srd_aoo_pending_movements(
    campaign_id,mover_token_id,movement_controller,destination_x,destination_y,
    origin_x,origin_y,combat_round,current_turn,turn_actor_id,threats,
    pending_reactions,created_by
  ) values (
    p_campaign_id,btrim(p_mover_token_id),p_controller,p_destination_x,p_destination_y,
    v_pos_x,v_pos_y,v_round,v_turn,v_actor_id,
    coalesce(v_detection->'threats','[]'::jsonb),v_reactions,auth.uid()
  ) returning pending_id into v_pending_id;

  return jsonb_build_object('pending',true,'requires_aoo',true,
    'pending_id',v_pending_id,'status','waiting_reactions',
    'round',v_round,'current_turn',v_turn,'mover_token_id',p_mover_token_id,
    'from',jsonb_build_array(v_pos_x,v_pos_y),
    'to',jsonb_build_array(p_destination_x,p_destination_y),
    'pending_reactions',v_reactions,
    'movement_committed',false);
end;
$function$
;

-- srd_validar_uso_pericia_srd(p_character_id text, p_skill_id text)
CREATE OR REPLACE FUNCTION public.srd_validar_uso_pericia_srd(p_character_id text, p_skill_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
declare
  v_character public.characters%rowtype;
  v_skill public.srd_skills%rowtype;
  v_rage_active boolean:=false;
  v_blocked boolean:=false;
  v_reason text;
  v_rogue_level integer:=0;
  v_trapfinding boolean:=false;
  v_linked_campaign_ids bigint[]:='{}'::bigint[];
  v_linked_token_ids text[]:='{}'::text[];
begin
  if auth.uid() is null then raise exception 'Autenticação obrigatória.'; end if;
  if nullif(btrim(p_character_id),'') is null or nullif(btrim(p_skill_id),'') is null then
    raise exception 'Personagem e perícia são obrigatórios.';
  end if;
  select * into v_character from public.characters
   where id::text=btrim(p_character_id) and user_id=auth.uid();
  if not found then raise exception 'Personagem não encontrado ou não pertence ao usuário.'; end if;
  select * into v_skill from public.srd_skills
   where id=btrim(p_skill_id) and source_status is distinct from 'excluded';
  if not found then raise exception 'Perícia não encontrada ou indisponível no catálogo.'; end if;

  select coalesce(
    max(cl.class_level) filter(where cls.class_key='rogue'),
    case when not exists(select 1 from public.srd_character_class_levels lv where lv.character_id=v_character.id)
      and sh.classe_id='ladino' then greatest(1,coalesce(sh.nivel,1)) else 0 end
  ) into v_rogue_level
  from public.srd_character_sheets sh
  left join public.srd_character_class_levels cl on cl.character_id=sh.character_id
  left join public.srd_classes cls on cls.id=cl.class_id
  where sh.character_id=v_character.id
  group by sh.character_id,sh.classe_id,sh.nivel;
  v_trapfinding:=coalesce(v_rogue_level,0)>=1;

  select coalesce(array_agg(distinct c.id),'{}'::bigint[]),
         coalesce(array_agg(distinct tok.value->>'id') filter(where tok.value->>'id' is not null),'{}'::text[])
    into v_linked_campaign_ids,v_linked_token_ids
  from public.campaigns c
  join public.members gm on gm.campaign_id=c.id and gm.user_id=auth.uid() and gm.role='GM'
  cross join lateral jsonb_array_elements(
    case when jsonb_typeof(c.cba_data->'tokens')='array' then c.cba_data->'tokens' else '[]'::jsonb end
  ) tok(value)
  where tok.value->>'tipo'='npc' and tok.value->>'sourceCharacterId'=v_character.id::text;

  select exists(
    select 1 from public.srd_campaign_effects e
    where e.active=true and e.effect_data->>'source_feature'='barbarian_rage'
      and (
        (v_character.campaign_id is not null and e.campaign_id=v_character.campaign_id
          and e.target_kind='character' and e.target_id=v_character.id::text)
        or (e.campaign_id=any(v_linked_campaign_ids) and e.target_kind='token'
          and e.target_id=any(v_linked_token_ids))
      )
  ) into v_rage_active;

  if v_rage_active then
    v_blocked:=v_skill.id='concentracao'
      or (upper(coalesce(v_skill.atributo,'')) in ('INT','DES','CAR')
        and v_skill.id not in ('srd35_skill_balance','fuga','intimidacao','cavalgar'));
    if v_blocked then
      v_reason:=case when v_skill.id='concentracao'
        then 'Não é possível usar Concentração enquanto estiver em Fúria.'
        else 'Durante a Fúria, não é possível usar perícias de Inteligência, Destreza ou Carisma, exceto Equilíbrio, Arte da Fuga, Intimidação e Cavalgar.' end;
      return jsonb_build_object('allowed',false,'rage_active',true,'skill_id',v_skill.id,
        'skill_name',v_skill.nome,'ability',v_skill.atributo,'reason',v_reason,
        'trapfinding',v_trapfinding,'trapfinding_search_dc_over_20',v_trapfinding,
        'trapfinding_magic_search_dc','25 + nível da magia','trapfinding_disarm_magic',v_trapfinding);
    end if;
  end if;
  return jsonb_build_object('allowed',true,'rage_active',v_rage_active,'skill_id',v_skill.id,
    'skill_name',v_skill.nome,'ability',v_skill.atributo,'trapfinding',v_trapfinding,
    'trapfinding_search_dc_over_20',v_trapfinding,'trapfinding_magic_search_dc','25 + nível da magia',
    'trapfinding_disarm_magic',v_trapfinding);
end;
$function$
;

-- start_combat(cid bigint)
CREATE OR REPLACE FUNCTION public.start_combat(cid bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  ordem jsonb;
BEGIN
  PERFORM priv.need_gm(cid);

  IF (SELECT coalesce(ativo,false) FROM public.combat_state WHERE campaign_id=cid) THEN
    RAISE EXCEPTION 'Combate já está ativo.';
  END IF;

  WITH ordenado AS (
    SELECT t.id,
      CASE
        WHEN t.character_id IS NOT NULL THEN
          10 + floor((coalesce(NULLIF(public._srd35_attr(cs.atributos,ARRAY['DES','DEX']::text[]),'')::integer,10)-10)::numeric/2)::integer
        ELSE coalesce((regexp_match(sm.iniciativa,'[-+]?[0-9]+'))[1]::integer,0)
      END AS ini
    FROM public.tokens t
    LEFT JOIN public.srd_character_sheets cs ON cs.character_id=t.character_id
    LEFT JOIN public.monster_instances mi ON mi.id=t.monster_instance_id
    LEFT JOIN public.srd_monsters sm ON sm.id=mi.monster_id
    WHERE t.campaign_id=cid
      AND (
        (t.character_id IS NOT NULL AND coalesce(cs.pv_atual,0)>0)
        OR
        (t.monster_instance_id IS NOT NULL AND coalesce(mi.hp_atual,0)>0)
      )
    ORDER BY ini DESC,t.id ASC
  )
  SELECT coalesce(jsonb_agg(id),'[]'::jsonb) INTO ordem FROM ordenado;

  IF jsonb_array_length(ordem)=0 THEN
    RAISE EXCEPTION 'Nenhum token vivo com ficha SRD ou instância de monstro.';
  END IF;

  INSERT INTO public.combat_state(campaign_id,ativo,rodada,turno_index,ordem,iniciado_em)
  VALUES (cid,true,1,0,ordem,now())
  ON CONFLICT (campaign_id) DO UPDATE SET
    ativo=true,rodada=1,turno_index=0,ordem=excluded.ordem,iniciado_em=now();

  UPDATE public.campaigns SET state='COMBATE' WHERE id=cid;
  PERFORM priv.log(cid,'COMBATE_INICIADO',jsonb_build_object('ordem',ordem,'por',auth.uid()));

  RETURN jsonb_build_object('ok',true,'ordem',ordem);
END;
$function$
;

-- usar_furia_barbaro_npc_srd(p_campaign_id bigint, p_token_id text, p_action text)
CREATE OR REPLACE FUNCTION public.usar_furia_barbaro_npc_srd(p_campaign_id bigint, p_token_id text, p_action text DEFAULT 'start'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_campaign public.campaigns%ROWTYPE;
  v_token jsonb;
  v_tokens jsonb;
  v_token_count integer;
  v_token_index bigint;
  v_character_id text;
  v_character public.characters%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_level integer:=0;
  v_uses_day integer:=0;
  v_uses_spent integer:=0;
  v_str_bonus integer:=4;
  v_con_bonus integer:=4;
  v_will_bonus integer:=2;
  v_con integer:=10;
  v_duration integer:=1;
  v_hp_bonus integer:=0;
  v_hp integer;
  v_max_hp integer;
  v_round integer:=1;
  v_order jsonb:='[]'::jsonb;
  v_turn integer:=-1;
  v_actor jsonb;
  v_effect_id bigint;
  v_result jsonb;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre autenticado pode controlar habilidades de NPC.';
  END IF;
  IF LOWER(BTRIM(COALESCE(p_action,'start'))) NOT IN ('start','end') THEN
    RAISE EXCEPTION 'Ação inválida. Use start ou end.';
  END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;

  v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array'
    THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END;
  SELECT count(*)::integer,min(t.ordinality) INTO v_token_count,v_token_index
    FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality)
   WHERE t.token->>'id'=BTRIM(p_token_id) AND t.token->>'tipo'='npc';
  IF v_token_count<>1 THEN RAISE EXCEPTION 'Token NPC não encontrado ou duplicado.'; END IF;
  v_token:=v_tokens->(v_token_index::integer-1);
  v_character_id:=NULLIF(v_token->>'sourceCharacterId','');
  IF v_character_id IS NULL THEN RAISE EXCEPTION 'Este NPC não está vinculado a uma ficha de origem.'; END IF;
  SELECT * INTO v_character FROM public.characters WHERE id::text=v_character_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha de origem não encontrada.'; END IF;
  IF v_character.user_id IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'O Mestre só pode controlar recursos da ficha NPC que pertence à sua própria conta.';
  END IF;
  SELECT * INTO v_sheet FROM public.srd_character_sheets WHERE character_id=v_character.id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD de origem não encontrada.'; END IF;

  SELECT COALESCE(
    MAX(cl.class_level) FILTER (WHERE cls.class_key='barbarian'),
    CASE WHEN NOT EXISTS(SELECT 1 FROM public.srd_character_class_levels lv WHERE lv.character_id=v_sheet.character_id)
      AND v_sheet.classe_id='barbaro' THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
  ) INTO v_level
  FROM public.srd_character_sheets sh
  LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
  LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
  WHERE sh.character_id=v_sheet.character_id
  GROUP BY sh.character_id,sh.classe_id,sh.nivel;
  v_level:=COALESCE(v_level,0);
  IF v_level<1 THEN RAISE EXCEPTION 'Fúria exige pelo menos 1 nível efetivo de Bárbaro.'; END IF;

  v_round:=CASE WHEN COALESCE(v_campaign.combat_data->>'round','') ~ '^[0-9]+$'
    THEN GREATEST(1,(v_campaign.combat_data->>'round')::integer) ELSE 1 END;
  v_order:=CASE WHEN jsonb_typeof(v_campaign.combat_data->'turn_order')='array'
    THEN v_campaign.combat_data->'turn_order' ELSE '[]'::jsonb END;
  IF COALESCE(v_campaign.combat_data->>'current_turn','') ~ '^[0-9]+$' THEN
    v_turn:=(v_campaign.combat_data->>'current_turn')::integer;
  END IF;
  IF v_turn>=0 AND v_turn<jsonb_array_length(v_order) THEN v_actor:=v_order->v_turn; END IF;

  IF LOWER(BTRIM(p_action))='end' THEN
    IF UPPER(COALESCE(v_campaign.state,''))='COMBATE'
       AND NOT (COALESCE(v_campaign.combat_data->>'active','false')='true'
         AND v_actor->>'id'=BTRIM(p_token_id)
         AND COALESCE(v_actor->>'is_monster','false')='true') THEN
      RAISE EXCEPTION 'A Fúria só pode ser encerrada no turno do NPC durante o combate.';
    END IF;
    v_result:=priv.srd_end_barbarian_rage_token(
      p_campaign_id,BTRIM(p_token_id),UPPER(COALESCE(v_campaign.state,''))='COMBATE'
    );
    IF COALESCE((v_result->>'ended')::boolean,false) IS NOT TRUE THEN
      RAISE EXCEPTION 'O NPC não está em Fúria.';
    END IF;
    PERFORM priv.log(p_campaign_id,'CLASS_FEATURE',jsonb_build_object(
      'feature_key','barbarian_rage','action','end','token_id',BTRIM(p_token_id),
      'character_id',v_character_id,'character_name',v_token->>'nome',
      'rage_hp_removed',v_result->'rage_hp_removed','fatigue_applied',v_result->'fatigue_applied'
    ));
    RETURN v_result||jsonb_build_object('feature_key','barbarian_rage','action','end','action_cost','free');
  END IF;

  IF UPPER(COALESCE(v_campaign.state,''))<>'COMBATE'
     OR COALESCE(v_campaign.combat_data->>'active','false')<>'true'
     OR v_actor->>'id' IS DISTINCT FROM BTRIM(p_token_id)
     OR COALESCE(v_actor->>'is_monster','false')<>'true' THEN
    RAISE EXCEPTION 'A Fúria só pode ser iniciada no turno do NPC em combate ativo.';
  END IF;
  IF priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'no_actions') THEN
    RAISE EXCEPTION 'A condição atual impede iniciar a Fúria.';
  END IF;
  IF EXISTS(SELECT 1 FROM public.srd_campaign_conditions
    WHERE campaign_id=p_campaign_id AND target_kind='token' AND target_id=BTRIM(p_token_id)
      AND active AND condition_id IN ('fatigued','exhausted')) THEN
    RAISE EXCEPTION 'Um NPC fatigado ou exausto não pode entrar em Fúria.';
  END IF;
  IF EXISTS(SELECT 1 FROM public.srd_campaign_effects
    WHERE campaign_id=p_campaign_id AND target_kind='token' AND target_id=BTRIM(p_token_id)
      AND active AND effect_data->>'source_feature'='barbarian_rage') THEN
    RAISE EXCEPTION 'O NPC já está em Fúria.';
  END IF;

  v_uses_day:=1+FLOOR(v_level/4.0)::integer;
  INSERT INTO public.srd_character_feature_resources(character_id,feature_key)
  VALUES(v_character.id,'barbarian_rage') ON CONFLICT(character_id,feature_key) DO NOTHING;
  SELECT uses_spent INTO v_uses_spent FROM public.srd_character_feature_resources
   WHERE character_id=v_character.id AND feature_key='barbarian_rage' FOR UPDATE;
  v_uses_spent:=COALESCE(v_uses_spent,0);
  IF v_uses_spent>=v_uses_day THEN RAISE EXCEPTION 'Fúria esgotada: % de % usos diários.',v_uses_spent,v_uses_day; END IF;

  IF COALESCE(v_sheet.atributos->>'CON','') ~ '^[0-9]{1,3}$' THEN
    v_con:=(v_sheet.atributos->>'CON')::integer;
  END IF;
  IF v_level>=20 THEN v_str_bonus:=8;v_con_bonus:=8;v_will_bonus:=4;
  ELSIF v_level>=11 THEN v_str_bonus:=6;v_con_bonus:=6;v_will_bonus:=3; END IF;
  v_duration:=GREATEST(1,3+FLOOR((v_con+v_con_bonus-10)::numeric/2)::integer);
  v_hp_bonus:=GREATEST(0,COALESCE(v_sheet.nivel,1)*(v_con_bonus/2));

  IF COALESCE(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$'
     OR COALESCE(v_token->>'hp','') !~ '^[0-9]{1,6}$' THEN
    RAISE EXCEPTION 'O token NPC precisa ter PV atuais e máximos válidos.';
  END IF;
  v_max_hp:=(v_token->>'maxHp')::integer;
  v_hp:=(v_token->>'hp')::integer;
  IF v_max_hp+v_hp_bonus>999999 THEN RAISE EXCEPTION 'PV temporários excedem o limite suportado.'; END IF;

  v_effect_id:=priv.srd_apply_campaign_effect(
    p_campaign_id,'token',BTRIM(p_token_id),'buff',
    jsonb_build_object(
      'source_feature','barbarian_rage','feature_key','barbarian_rage',
      'source_character_id',v_character_id,'rage_hp_bonus',v_hp_bonus,
      'rage_level',v_level,'duration_rounds',v_duration,
      'flags',jsonb_build_object('rage_active',true,'cannot_cast',true,
        'cannot_use_int_dex_cha_skills',true,'cannot_concentrate',true),
      'modifiers',jsonb_build_array(
        jsonb_build_object('stat','strength','value',v_str_bonus,'bonus_type','morale'),
        jsonb_build_object('stat','constitution','value',v_con_bonus,'bonus_type','morale'),
        jsonb_build_object('stat','will','value',v_will_bonus,'bonus_type','morale'),
        jsonb_build_object('stat','ac','value',-2,'bonus_type','untyped')
      )
    ),v_duration,NULL,NULL
  );

  v_token:=v_token||jsonb_build_object('hp',LEAST(v_max_hp+v_hp_bonus,v_hp+v_hp_bonus),
    'maxHp',v_max_hp+v_hp_bonus);
  v_tokens:=jsonb_set(v_tokens,ARRAY[(v_token_index-1)::text],v_token,false);
  UPDATE public.campaigns SET cba_data=COALESCE(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens)
   WHERE id=p_campaign_id;

  UPDATE public.srd_character_feature_resources
     SET uses_spent=v_uses_spent+1,last_reset_at=clock_timestamp(),
         payload=COALESCE(payload,'{}'::jsonb)||jsonb_build_object(
           'last_use_effect_id',v_effect_id,'last_use_round',v_round,
           'last_use_barbarian_level',v_level)
   WHERE character_id=v_character.id AND feature_key='barbarian_rage';

  PERFORM priv.log(p_campaign_id,'CLASS_FEATURE',jsonb_build_object(
    'feature_key','barbarian_rage','action','start','token_id',BTRIM(p_token_id),
    'character_id',v_character_id,'character_name',v_token->>'nome',
    'round',v_round,'duration_rounds',v_duration,'uses_remaining',v_uses_day-v_uses_spent-1,
    'strength_bonus',v_str_bonus,'constitution_bonus',v_con_bonus));
  RETURN jsonb_build_object('feature_key','barbarian_rage','action','start',
    'action_cost','free','effect_instance_id',v_effect_id,'barbarian_level',v_level,
    'uses_per_day',v_uses_day,'uses_spent',v_uses_spent+1,'uses_remaining',v_uses_day-v_uses_spent-1,
    'strength_bonus',v_str_bonus,'constitution_bonus',v_con_bonus,'will_bonus',v_will_bonus,
    'armor_class_penalty',-2,'rage_hp_bonus',v_hp_bonus,'duration_rounds',v_duration,
    'expires_round',v_round+v_duration,'cba_data',COALESCE((SELECT cba_data FROM public.campaigns WHERE id=p_campaign_id),'{}'::jsonb));
END;
$function$
;

-- usar_furia_barbaro_srd(p_character_id text, p_action text)
CREATE OR REPLACE FUNCTION public.usar_furia_barbaro_srd(p_character_id text, p_action text DEFAULT 'start'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_character public.characters%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_campaign public.campaigns%ROWTYPE;
  v_barbarian_level integer := 0;
  v_uses_per_day integer := 0;
  v_uses_spent integer := 0;
  v_strength_bonus integer := 4;
  v_constitution_bonus integer := 4;
  v_will_bonus integer := 2;
  v_con_score integer := 10;
  v_con_mod integer := 0;
  v_duration integer := 1;
  v_hp_bonus integer := 0;
  v_round integer := 1;
  v_current integer := 0;
  v_order jsonb := '[]'::jsonb;
  v_actor jsonb;
  v_effect_id bigint;
  v_result jsonb;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF NULLIF(BTRIM(p_character_id),'') IS NULL THEN RAISE EXCEPTION 'Personagem inválido.'; END IF;
  IF LOWER(BTRIM(COALESCE(p_action,'start'))) NOT IN ('start','end') THEN
    RAISE EXCEPTION 'Ação inválida. Use start ou end.';
  END IF;

  SELECT * INTO v_character
    FROM public.characters
   WHERE id::text=BTRIM(p_character_id)
     AND (user_id=auth.uid() OR (campaign_id IS NOT NULL AND public.my_role(campaign_id)='GM'))
   FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem permissão na campanha.';
  END IF;
  IF v_character.campaign_id IS NULL THEN
    RAISE EXCEPTION 'O personagem precisa estar em uma campanha para usar Fúria.';
  END IF;

  SELECT * INTO v_sheet
    FROM public.srd_character_sheets
   WHERE character_id=v_character.id
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD do personagem não encontrada.'; END IF;

  SELECT COALESCE(
      MAX(cl.class_level) FILTER (WHERE cls.class_key='barbarian'),
      CASE WHEN NOT EXISTS (
        SELECT 1 FROM public.srd_character_class_levels any_level
         WHERE any_level.character_id=v_sheet.character_id
      ) AND v_sheet.classe_id='barbaro'
      THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
    )
      INTO v_barbarian_level
      FROM public.srd_character_sheets sh
      LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
      LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
     WHERE sh.character_id=v_sheet.character_id
     GROUP BY sh.character_id,sh.classe_id,sh.nivel;

  IF COALESCE(v_barbarian_level,0)<1 THEN
    RAISE EXCEPTION 'Fúria exige pelo menos 1 nível efetivo de Bárbaro.';
  END IF;

  SELECT * INTO v_campaign
    FROM public.campaigns
   WHERE id=v_character.campaign_id
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha do personagem não encontrada.'; END IF;

  IF LOWER(BTRIM(p_action))='end' THEN
    IF UPPER(COALESCE(v_campaign.state,''))='COMBATE' THEN
      IF COALESCE(v_campaign.combat_data->>'active','false')<>'true'
         OR COALESCE(v_campaign.combat_data->>'current_turn','') !~ '^[0-9]+$' THEN
        RAISE EXCEPTION 'A iniciativa não está ativa.';
      END IF;
      v_order:=CASE WHEN jsonb_typeof(v_campaign.combat_data->'turn_order')='array'
                    THEN v_campaign.combat_data->'turn_order' ELSE '[]'::jsonb END;
      v_current:=(v_campaign.combat_data->>'current_turn')::integer;
      IF v_current<0 OR v_current>=jsonb_array_length(v_order) THEN
        RAISE EXCEPTION 'Índice de turno inválido.';
      END IF;
      v_actor:=v_order->v_current;
      IF v_actor->>'id' IS DISTINCT FROM BTRIM(p_character_id)
         OR COALESCE(v_actor->>'is_monster','false')='true' THEN
        RAISE EXCEPTION 'Apenas no próprio turno é possível encerrar a Fúria.';
      END IF;
    END IF;
    v_result:=priv.srd_end_barbarian_rage(
      v_character.campaign_id,v_character.id::text,
      UPPER(COALESCE(v_campaign.state,''))='COMBATE'
    );
    IF COALESCE((v_result->>'ended')::boolean,false) IS NOT TRUE THEN
      RAISE EXCEPTION 'O personagem não está em Fúria.';
    END IF;
    PERFORM priv.log(v_character.campaign_id,'CLASS_FEATURE',jsonb_build_object(
      'feature_key','barbarian_rage','action','end','character_id',v_character.id::text,
      'character_name',v_character.nome,'rage_hp_removed',v_result->'rage_hp_removed',
      'fatigue_applied',v_result->'fatigue_applied'
    ));
    RETURN v_result || jsonb_build_object('feature_key','barbarian_rage','action','end','action_cost','free');
  END IF;

  IF UPPER(COALESCE(v_campaign.state,''))<>'COMBATE'
     OR COALESCE(v_campaign.combat_data->>'active','false')<>'true'
     OR COALESCE(v_campaign.combat_data->>'current_turn','') !~ '^[0-9]+$' THEN
    RAISE EXCEPTION 'A Fúria só pode ser iniciada durante um combate com iniciativa ativa.';
  END IF;

  v_order:=CASE WHEN jsonb_typeof(v_campaign.combat_data->'turn_order')='array'
                THEN v_campaign.combat_data->'turn_order' ELSE '[]'::jsonb END;
  v_current:=(v_campaign.combat_data->>'current_turn')::integer;
  IF v_current<0 OR v_current>=jsonb_array_length(v_order) THEN
    RAISE EXCEPTION 'Índice de turno inválido.';
  END IF;
  v_actor:=v_order->v_current;
  IF v_actor->>'id' IS DISTINCT FROM BTRIM(p_character_id)
     OR COALESCE(v_actor->>'is_monster','false')='true' THEN
    RAISE EXCEPTION 'A Fúria só pode ser iniciada no turno do próprio personagem.';
  END IF;

  IF priv.srd_condition_has_flag(v_character.campaign_id,'character',v_character.id::text,'no_actions') THEN
    RAISE EXCEPTION 'A condição atual impede iniciar a Fúria.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM public.srd_campaign_conditions
     WHERE campaign_id=v_character.campaign_id AND target_kind='character'
       AND target_id=v_character.id::text AND active=true
       AND condition_id IN ('fatigued','exhausted')
  ) THEN
    RAISE EXCEPTION 'Um personagem fatigado ou exausto não pode entrar em Fúria.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM public.srd_campaign_effects
     WHERE campaign_id=v_character.campaign_id AND target_kind='character'
       AND target_id=v_character.id::text AND active=true
       AND effect_data->>'source_feature'='barbarian_rage'
  ) THEN
    RAISE EXCEPTION 'O personagem já está em Fúria.';
  END IF;

  v_uses_per_day:=1+FLOOR(v_barbarian_level/4.0)::integer;
  INSERT INTO public.srd_character_feature_resources(character_id,feature_key)
  VALUES(v_character.id,'barbarian_rage')
  ON CONFLICT(character_id,feature_key) DO NOTHING;

  SELECT uses_spent INTO v_uses_spent
    FROM public.srd_character_feature_resources
   WHERE character_id=v_character.id AND feature_key='barbarian_rage'
   FOR UPDATE;
  v_uses_spent:=COALESCE(v_uses_spent,0);
  IF v_uses_spent>=v_uses_per_day THEN
    RAISE EXCEPTION 'Fúria esgotada: % de % usos diários já foram consumidos.',v_uses_spent,v_uses_per_day;
  END IF;

  IF COALESCE(v_sheet.atributos->>'CON','') ~ '^[0-9]{1,3}$' THEN
    v_con_score:=(v_sheet.atributos->>'CON')::integer;
  END IF;
  v_con_mod:=FLOOR((v_con_score-10)::numeric/2)::integer;

  IF v_barbarian_level>=20 THEN
    v_strength_bonus:=8; v_constitution_bonus:=8; v_will_bonus:=4;
  ELSIF v_barbarian_level>=11 THEN
    v_strength_bonus:=6; v_constitution_bonus:=6; v_will_bonus:=3;
  END IF;

  -- Rage duration uses the Constitution modifier after the rage increase.
  v_duration:=GREATEST(1,3+FLOOR((v_con_score+v_constitution_bonus-10)::numeric/2)::integer);

  IF v_sheet.pv_max IS NULL OR v_sheet.pv_max<1 THEN
    RAISE EXCEPTION 'A ficha precisa ter PV máximo válido para iniciar a Fúria.';
  END IF;
  v_hp_bonus:=GREATEST(0,COALESCE(v_sheet.nivel,1)*(v_constitution_bonus/2));

  v_round:=CASE WHEN COALESCE(v_campaign.combat_data->>'round','') ~ '^[0-9]+$'
                THEN GREATEST(1,(v_campaign.combat_data->>'round')::integer) ELSE 1 END;

  v_effect_id:=priv.srd_apply_campaign_effect(
    v_character.campaign_id,'character',v_character.id::text,'buff',
    jsonb_build_object(
      'source_feature','barbarian_rage',
      'feature_key','barbarian_rage',
      'rage_hp_bonus',v_hp_bonus,
      'rage_level',v_barbarian_level,
      'duration_rounds',v_duration,
      'flags',jsonb_build_object('rage_active',true,'cannot_cast',true,'cannot_use_int_dex_cha_skills',true,'cannot_concentrate',true),
      'modifiers',jsonb_build_array(
        jsonb_build_object('stat','strength','value',v_strength_bonus,'bonus_type','morale'),
        jsonb_build_object('stat','constitution','value',v_constitution_bonus,'bonus_type','morale'),
        jsonb_build_object('stat','will','value',v_will_bonus,'bonus_type','morale'),
        jsonb_build_object('stat','ac','value',-2,'bonus_type','untyped')
      )
    ),
    v_duration,NULL,NULL
  );

  UPDATE public.srd_character_sheets
     SET pv_max=pv_max+v_hp_bonus,
         pv_atual=LEAST(pv_max+v_hp_bonus,COALESCE(pv_atual,pv_max)+v_hp_bonus)
   WHERE character_id=v_character.id;

  UPDATE public.srd_character_feature_resources
     SET uses_spent=v_uses_spent+1,last_reset_at=clock_timestamp(),
         payload=COALESCE(payload,'{}'::jsonb)||jsonb_build_object(
           'last_use_effect_id',v_effect_id,
           'last_use_round',v_round,
           'last_use_barbarian_level',v_barbarian_level
         )
   WHERE character_id=v_character.id AND feature_key='barbarian_rage';

  PERFORM priv.log(v_character.campaign_id,'CLASS_FEATURE',jsonb_build_object(
    'feature_key','barbarian_rage','action','start','character_id',v_character.id::text,
    'character_name',v_character.nome,'round',v_round,'duration_rounds',v_duration,
    'uses_remaining',v_uses_per_day-v_uses_spent-1,
    'strength_bonus',v_strength_bonus,'constitution_bonus',v_constitution_bonus
  ));
  RETURN jsonb_build_object(
    'feature_key','barbarian_rage',
    'action','start',
    'action_cost','free',
    'effect_instance_id',v_effect_id,
    'barbarian_level',v_barbarian_level,
    'uses_per_day',v_uses_per_day,
    'uses_spent',v_uses_spent+1,
    'uses_remaining',v_uses_per_day-v_uses_spent-1,
    'strength_bonus',v_strength_bonus,
    'constitution_bonus',v_constitution_bonus,
    'will_bonus',v_will_bonus,
    'armor_class_penalty',-2,
    'rage_hp_bonus',v_hp_bonus,
    'duration_rounds',v_duration,
    'expires_round',v_round+v_duration
  );
END;
$function$
;

-- usar_habilidade_classe_srd(p_character_id text, p_feature_key text, p_target_token_key text, p_amount integer)
CREATE OR REPLACE FUNCTION public.usar_habilidade_classe_srd(p_character_id text, p_feature_key text, p_target_token_key text DEFAULT NULL::text, p_amount integer DEFAULT NULL::integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_character public.characters%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_target_sheet public.srd_character_sheets%ROWTYPE;
  v_campaign public.campaigns%ROWTYPE;
  v_token jsonb;
  v_tokens jsonb;
  v_token_index bigint;
  v_token_count integer;
  v_paladin_level integer:=0;
  v_charisma integer:=10;
  v_charisma_mod integer:=0;
  v_pool integer:=0;
  v_spent integer:=0;
  v_remaining integer:=0;
  v_requested integer:=0;
  v_healing integer:=0;
  v_hp integer:=0;
  v_max_hp integer:=0;
  v_target_kind text:='character';
  v_target_id text;
  v_target_name text;
  v_scene jsonb;
  v_feature public.srd_character_feature_resources%ROWTYPE;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF NULLIF(BTRIM(p_character_id),'') IS NULL THEN RAISE EXCEPTION 'Personagem inválido.'; END IF;
  IF p_feature_key IS DISTINCT FROM 'lay_on_hands' THEN
    RAISE EXCEPTION 'Habilidade de classe ainda não disponível no motor: %.',p_feature_key;
  END IF;

  SELECT * INTO v_character
  FROM public.characters
  WHERE id::text=BTRIM(p_character_id) AND user_id=auth.uid()
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou não pertence ao usuário.'; END IF;

  SELECT * INTO v_sheet
  FROM public.srd_character_sheets
  WHERE character_id=v_character.id
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD do personagem não encontrada.'; END IF;

  SELECT COALESCE(
    MAX(cl.class_level) FILTER (WHERE cl.class_id='paladino'),
    CASE WHEN v_sheet.classe_id='paladino' THEN v_sheet.nivel ELSE 0 END
  )
  INTO v_paladin_level
  FROM public.srd_character_class_levels cl
  WHERE cl.character_id=v_sheet.character_id;
  IF COALESCE(v_paladin_level,0)<2 THEN
    RAISE EXCEPTION 'Imposição das Mãos exige pelo menos 2 níveis de Paladino.';
  END IF;

  v_charisma:=COALESCE(NULLIF(v_sheet.atributos->>'CAR','')::integer,10);
  v_charisma_mod:=FLOOR((v_charisma-10)::numeric/2)::integer;
  v_pool:=v_paladin_level*GREATEST(0,v_charisma_mod);
  IF v_pool<=0 THEN RAISE EXCEPTION 'O modificador de Carisma não concede pontos para Imposição das Mãos.'; END IF;

  INSERT INTO public.srd_character_feature_resources(character_id,feature_key)
  VALUES(v_sheet.character_id,'lay_on_hands')
  ON CONFLICT(character_id,feature_key) DO NOTHING;

  SELECT * INTO v_feature
  FROM public.srd_character_feature_resources
  WHERE character_id=v_sheet.character_id AND feature_key='lay_on_hands'
  FOR UPDATE;

  v_spent:=COALESCE(v_feature.resource_spent,0);
  v_remaining:=GREATEST(0,v_pool-v_spent);
  IF v_remaining<=0 THEN RAISE EXCEPTION 'Todos os pontos diários de Imposição das Mãos já foram usados.'; END IF;
  v_requested:=COALESCE(p_amount,v_remaining);
  IF v_requested<1 OR v_requested>v_remaining THEN
    RAISE EXCEPTION 'Quantidade inválida. Restam % pontos de cura hoje.',v_remaining;
  END IF;

  v_target_id:=v_character.id::text;
  v_target_name:=v_character.nome;
  IF NULLIF(BTRIM(p_target_token_key),'') IS NOT NULL THEN
    IF v_character.campaign_id IS NULL THEN RAISE EXCEPTION 'O personagem precisa estar em uma campanha para escolher outro alvo.'; END IF;
    SELECT * INTO v_campaign FROM public.campaigns WHERE id=v_character.campaign_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Campanha do personagem não encontrada.'; END IF;

    v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END;
    SELECT COUNT(*)::integer,MIN(t.ordinality),(array_agg(t.token ORDER BY t.ordinality))[1]
      INTO v_token_count,v_token_index,v_token
    FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(token,ordinality)
    WHERE t.token->>'id'=BTRIM(p_target_token_key) OR t.token->>'key'=BTRIM(p_target_token_key);
    IF v_token_count<>1 THEN RAISE EXCEPTION 'Alvo ausente ou duplicado no campo de batalha.'; END IF;

    v_target_name:=COALESCE(v_token->>'nome',v_token->>'name','Alvo');
    IF v_token->>'tipo'='player' THEN
      v_target_kind:='character';
      v_target_id:=v_token->>'id';
      SELECT sh.* INTO v_target_sheet
      FROM public.characters ch
      JOIN public.srd_character_sheets sh ON sh.character_id=ch.id
      WHERE ch.id::text=v_target_id AND ch.campaign_id=v_character.campaign_id
      FOR UPDATE OF sh;
      IF NOT FOUND THEN RAISE EXCEPTION 'Ficha do personagem-alvo não encontrada nesta campanha.'; END IF;
      v_hp:=COALESCE(v_target_sheet.pv_atual,v_target_sheet.pv_max);
      v_max_hp:=v_target_sheet.pv_max;
    ELSIF v_token->>'tipo' IN ('npc','monstro') THEN
      IF lower(COALESCE(v_token->'monsterStats'->>'tipo',v_token->'monsterStats'->>'type','')) LIKE '%undead%' THEN
        RAISE EXCEPTION 'Imposição das Mãos não cura mortos-vivos; o uso ofensivo exige uma rolagem de ataque e ainda não está implementado.';
      END IF;
      v_target_kind:='token';
      v_target_id:=COALESCE(v_token->>'key',v_token->>'id');
      IF COALESCE(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN RAISE EXCEPTION 'Alvo sem PV máximo válido.'; END IF;
      v_max_hp:=(v_token->>'maxHp')::integer;
      v_hp:=CASE WHEN COALESCE(v_token->>'hp','') ~ '^-?[0-9]{1,6}$' THEN (v_token->>'hp')::integer ELSE v_max_hp END;
      IF v_hp<=-10 OR EXISTS (SELECT 1 FROM public.srd_campaign_conditions cc WHERE cc.campaign_id=v_character.campaign_id AND cc.target_kind='token' AND cc.target_id IN (v_token->>'id',v_token->>'key') AND cc.condition_id='dead' AND cc.active=true) THEN RAISE EXCEPTION 'Imposição das Mãos não pode recuperar uma criatura morta.'; END IF;
    ELSE
      RAISE EXCEPTION 'Tipo de alvo inválido para Imposição das Mãos.';
    END IF;
  ELSE
    v_hp:=COALESCE(v_sheet.pv_atual,v_sheet.pv_max);
    v_max_hp:=v_sheet.pv_max;
  END IF;

  IF v_max_hp IS NULL OR v_max_hp<1 THEN RAISE EXCEPTION 'PV máximo do alvo inválido.'; END IF;
  IF v_hp>=v_max_hp THEN RAISE EXCEPTION 'O alvo já está com PV máximo.'; END IF;
  v_healing:=LEAST(v_requested,v_max_hp-v_hp);
  IF v_healing<=0 THEN RAISE EXCEPTION 'Não há PV a recuperar neste alvo.'; END IF;

  IF v_character.campaign_id IS NOT NULL THEN
    SELECT * INTO v_campaign FROM public.campaigns WHERE id=v_character.campaign_id FOR UPDATE;
    IF UPPER(COALESCE(v_campaign.state,''))='COMBATE' THEN
      PERFORM public.consumir_acao_turno_srd(v_character.campaign_id,v_character.id::text,'padrao');
    END IF;
  END IF;

  IF v_target_kind='character' THEN
    UPDATE public.srd_character_sheets
       SET pv_atual=LEAST(pv_max,GREATEST(-10,COALESCE(pv_atual,pv_max)+v_healing))
     WHERE character_id::text=v_target_id
     RETURNING pv_atual,pv_max INTO v_hp,v_max_hp;
    PERFORM priv.srd_sync_character_vital_condition(v_target_id,v_hp,false);
  ELSE
    v_token:=v_token||jsonb_build_object('hp',LEAST(v_max_hp,v_hp+v_healing),'maxHp',v_max_hp);
    v_tokens:=jsonb_set(v_tokens,ARRAY[(v_token_index-1)::text],v_token,false);
    UPDATE public.campaigns
       SET cba_data=COALESCE(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens)
     WHERE id=v_character.campaign_id
     RETURNING cba_data INTO v_scene;
    v_hp:=LEAST(v_max_hp,v_hp+v_healing);
    PERFORM priv.srd_sync_linked_npc_token_vitals(v_character.campaign_id,p_target_token_key,v_hp,v_max_hp,(v_hp<0 AND EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc WHERE cc.campaign_id=v_character.campaign_id AND cc.target_kind='token' AND cc.target_id IN (v_token->>'id',v_token->>'key') AND cc.condition_id='stable' AND cc.active=true)));
  END IF;

  UPDATE public.srd_character_feature_resources
     SET resource_spent=v_spent+v_healing,last_reset_at=COALESCE(last_reset_at,now())
   WHERE character_id=v_sheet.character_id AND feature_key='lay_on_hands';

  RETURN jsonb_build_object(
    'feature_key','lay_on_hands',
    'character_id',v_character.id,
    'target_kind',v_target_kind,
    'target_id',v_target_id,
    'target_name',v_target_name,
    'healing',v_healing,
    'pv_atual',v_hp,
    'pv_max',v_max_hp,
    'resource_pool',v_pool,
    'resource_spent',v_spent+v_healing,
    'resource_remaining',v_pool-v_spent-v_healing,
    'cba_data',v_scene
  );
END;
$function$
;

-- usar_imposicao_maos_mortos_vivos_srd(p_character_id text, p_target_token_key text, p_d20 integer, p_amount integer)
CREATE OR REPLACE FUNCTION public.usar_imposicao_maos_mortos_vivos_srd(p_character_id text, p_target_token_key text, p_d20 integer, p_amount integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_character public.characters%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_campaign public.campaigns%ROWTYPE;
  v_scene jsonb;
  v_tokens jsonb;
  v_target jsonb;
  v_attacker jsonb;
  v_target_index bigint;
  v_target_count integer;
  v_attacker_count integer;
  v_touch_text text;
  v_touch_ac integer;
  v_paladin_level integer:=0;
  v_charisma integer:=10;
  v_charisma_mod integer:=0;
  v_pool integer:=0;
  v_spent integer:=0;
  v_remaining integer:=0;
  v_bab integer:=0;
  v_strength_score integer:=10;
  v_strength_mod integer:=0;
  v_size_modifier integer:=0;
  v_attacker_size integer:=1;
  v_target_size integer:=1;
  v_ax integer; v_ay integer; v_bx integer; v_by integer;
  v_dx integer; v_dy integer; v_distance_squares integer;
  v_attack_bonus integer:=0;
  v_attack_total integer:=0;
  v_hit boolean:=false;
  v_hp integer; v_max_hp integer; v_new_hp integer;
  v_target_name text;
  v_resource public.srd_character_feature_resources%ROWTYPE;
  v_action_result jsonb;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF NULLIF(BTRIM(p_character_id),'') IS NULL OR NULLIF(BTRIM(p_target_token_key),'') IS NULL THEN
    RAISE EXCEPTION 'Personagem e alvo são obrigatórios.';
  END IF;
  IF p_d20 IS NULL OR p_d20 NOT BETWEEN 1 AND 20 THEN
    RAISE EXCEPTION 'O ataque de toque exige um resultado manual de d20 entre 1 e 20.';
  END IF;
  IF p_amount IS NULL OR p_amount<1 OR p_amount>1000 THEN
    RAISE EXCEPTION 'Informe uma quantidade válida de pontos de Imposição das Mãos.';
  END IF;

  SELECT * INTO v_character
    FROM public.characters
   WHERE id::text=BTRIM(p_character_id) AND user_id=auth.uid()
   FOR UPDATE;
  IF NOT FOUND OR v_character.campaign_id IS NULL THEN
    RAISE EXCEPTION 'Personagem não encontrado ou não está em uma campanha.';
  END IF;
  SELECT * INTO v_sheet FROM public.srd_character_sheets
   WHERE character_id=v_character.id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD do Paladino não encontrada.'; END IF;

  SELECT COALESCE(
    MAX(cl.class_level) FILTER (WHERE cl.class_id='paladino'),
    CASE WHEN NOT EXISTS (
      SELECT 1 FROM public.srd_character_class_levels any_level
       WHERE any_level.character_id=v_sheet.character_id
    ) AND v_sheet.classe_id='paladino'
    THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
  )
    INTO v_paladin_level
    FROM public.srd_character_class_levels cl
   WHERE cl.character_id=v_sheet.character_id;
  IF COALESCE(v_paladin_level,0)<2 THEN
    RAISE EXCEPTION 'Imposição das Mãos exige pelo menos 2 níveis de Paladino.';
  END IF;

  v_charisma:=COALESCE(NULLIF(v_sheet.atributos->>'CAR','')::integer,10);
  v_charisma_mod:=FLOOR((v_charisma-10)::numeric/2)::integer;
  v_pool:=v_paladin_level*GREATEST(0,v_charisma_mod);
  IF v_pool<=0 THEN RAISE EXCEPTION 'O modificador de Carisma não concede pontos para Imposição das Mãos.'; END IF;

  INSERT INTO public.srd_character_feature_resources(character_id,feature_key)
  VALUES(v_sheet.character_id,'lay_on_hands')
  ON CONFLICT(character_id,feature_key) DO NOTHING;
  SELECT * INTO v_resource FROM public.srd_character_feature_resources
   WHERE character_id=v_sheet.character_id AND feature_key='lay_on_hands'
   FOR UPDATE;
  v_spent:=COALESCE(v_resource.resource_spent,0);
  v_remaining:=GREATEST(0,v_pool-v_spent);
  IF p_amount>v_remaining THEN
    RAISE EXCEPTION 'Você solicitou % pontos, mas restam apenas % na reserva diária.',p_amount,v_remaining;
  END IF;

  SELECT * INTO v_campaign FROM public.campaigns
   WHERE id=v_character.campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha do Paladino não encontrada.'; END IF;
  v_scene:=COALESCE(v_campaign.cba_data,'{}'::jsonb);
  v_tokens:=CASE WHEN jsonb_typeof(v_scene->'tokens')='array' THEN v_scene->'tokens' ELSE '[]'::jsonb END;

  SELECT count(*)::integer,min(t.ordinality),(array_agg(t.token ORDER BY t.ordinality))[1]
    INTO v_target_count,v_target_index,v_target
    FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(token,ordinality)
   WHERE (t.token->>'id'=BTRIM(p_target_token_key) OR t.token->>'key'=BTRIM(p_target_token_key))
     AND t.token->>'tipo' IN ('npc','monstro');
  IF v_target_count<>1 THEN RAISE EXCEPTION 'O alvo deve ser um único token de NPC ou monstro.'; END IF;

  IF lower(COALESCE(v_target->'monsterStats'->>'tipo',v_target->'monsterStats'->>'type',v_target->>'tipo_criatura',''))
       NOT LIKE '%undead%'
     AND lower(COALESCE(v_target->'monsterStats'->>'tipo',v_target->'monsterStats'->>'type',v_target->>'tipo_criatura',''))
       NOT LIKE '%morto-vivo%' THEN
    RAISE EXCEPTION 'Imposição das Mãos ofensiva só pode atingir criaturas do tipo morto-vivo.';
  END IF;

  v_touch_text:=COALESCE(
    NULLIF(v_target->>'touchAc',''),
    NULLIF(v_target->>'ca_toque',''),
    NULLIF(v_target->'monsterStats'->>'ca_touch',''),
    NULLIF(v_target->'monsterStats'->>'touch_ac',''),
    (regexp_match(COALESCE(v_target->'monsterStats'->>'ca',v_target->>'ca',v_target->>'ac',''),'(?i)touch[[:space:]]+([0-9]{1,3})'))[1]
  );
  IF COALESCE(v_touch_text,'') !~ '^[0-9]{1,3}$' THEN
    RAISE EXCEPTION 'A ficha do morto-vivo não possui CA de toque cadastrada. Atualize a ficha da criatura antes de tentar o ataque.';
  END IF;
  v_touch_ac:=v_touch_text::integer;

  IF COALESCE(v_target->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN
    RAISE EXCEPTION 'O alvo não possui PV máximo válido.';
  END IF;
  v_max_hp:=(v_target->>'maxHp')::integer;
  v_hp:=CASE WHEN COALESCE(v_target->>'hp','') ~ '^[0-9]{1,6}$' THEN (v_target->>'hp')::integer ELSE v_max_hp END;
  IF v_hp<=0 THEN RAISE EXCEPTION 'O morto-vivo já está derrotado.'; END IF;

  SELECT count(*)::integer,(array_agg(t.token ORDER BY t.ordinality))[1]
    INTO v_attacker_count,v_attacker
    FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(token,ordinality)
   WHERE t.token->>'id'=v_character.id::text AND t.token->>'tipo'='player';
  IF v_attacker_count<>1 THEN RAISE EXCEPTION 'O token do Paladino não foi encontrado ou está duplicado no campo de batalha.'; END IF;
  IF COALESCE(v_attacker->>'gridX','') !~ '^-?[0-9]+$'
     OR COALESCE(v_attacker->>'gridY','') !~ '^-?[0-9]+$'
     OR COALESCE(v_target->>'gridX','') !~ '^-?[0-9]+$'
     OR COALESCE(v_target->>'gridY','') !~ '^-?[0-9]+$' THEN
    RAISE EXCEPTION 'Posição dos tokens inválida para confirmar o alcance do toque.';
  END IF;

  SELECT CASE translate(lower(COALESCE(r.tamanho,'medio')),'áéíóúãõâêôç','aeiouaoaeoc')
    WHEN 'minusculo' THEN 8 WHEN 'fine' THEN 8
    WHEN 'diminuto' THEN 4 WHEN 'diminutive' THEN 4
    WHEN 'miudo' THEN 2 WHEN 'tiny' THEN 2
    WHEN 'pequeno' THEN 1 WHEN 'small' THEN 1
    WHEN 'grande' THEN -1 WHEN 'large' THEN -1
    WHEN 'enorme' THEN -2 WHEN 'huge' THEN -2
    WHEN 'imenso' THEN -4 WHEN 'gargantuan' THEN -4
    WHEN 'colossal' THEN -8 ELSE 0 END
    INTO v_size_modifier
    FROM public.srd_races r WHERE r.id=v_sheet.raca_id;
  v_size_modifier:=COALESCE(v_size_modifier,0);
  v_attacker_size:=CASE
    WHEN lower(COALESCE((SELECT tamanho FROM public.srd_races WHERE id=v_sheet.raca_id),'')) LIKE 'large%' OR lower(COALESCE((SELECT tamanho FROM public.srd_races WHERE id=v_sheet.raca_id),'')) LIKE 'grande%' THEN 2
    WHEN lower(COALESCE((SELECT tamanho FROM public.srd_races WHERE id=v_sheet.raca_id),'')) LIKE 'huge%' OR lower(COALESCE((SELECT tamanho FROM public.srd_races WHERE id=v_sheet.raca_id),'')) LIKE 'enorme%' THEN 3
    WHEN lower(COALESCE((SELECT tamanho FROM public.srd_races WHERE id=v_sheet.raca_id),'')) LIKE 'gargantuan%' OR lower(COALESCE((SELECT tamanho FROM public.srd_races WHERE id=v_sheet.raca_id),'')) LIKE 'imenso%' THEN 4
    WHEN lower(COALESCE((SELECT tamanho FROM public.srd_races WHERE id=v_sheet.raca_id),'')) LIKE 'colossal%' THEN 5 ELSE 1 END;
  v_target_size:=CASE
    WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'large%' OR lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'grande%' THEN 2
    WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'huge%' OR lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'enorme%' THEN 3
    WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'gargantuan%' OR lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'imenso%' THEN 4
    WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'colossal%' THEN 5 ELSE 1 END;
  v_ax:=(v_attacker->>'gridX')::integer; v_ay:=(v_attacker->>'gridY')::integer;
  v_bx:=(v_target->>'gridX')::integer; v_by:=(v_target->>'gridY')::integer;
  v_dx:=GREATEST(0,v_bx-(v_ax+v_attacker_size-1),v_ax-(v_bx+v_target_size-1));
  v_dy:=GREATEST(0,v_by-(v_ay+v_attacker_size-1),v_ay-(v_by+v_target_size-1));
  v_distance_squares:=GREATEST(v_dx,v_dy)+FLOOR(LEAST(v_dx,v_dy)::numeric/2)::integer;
  IF v_distance_squares>GREATEST(1,v_attacker_size) THEN
    RAISE EXCEPTION 'O morto-vivo está fora do alcance de toque corpo a corpo.';
  END IF;

  SELECT COALESCE(SUM(x.base_attack_bonus),0)::integer INTO v_bab
    FROM (
      SELECT DISTINCT ON (cl.class_id) pr.base_attack_bonus
        FROM public.srd_character_class_levels cl
        JOIN public.srd_class_level_progressions pr
          ON pr.class_id=cl.class_id AND pr.class_level=cl.class_level
       WHERE cl.character_id=v_sheet.character_id
       ORDER BY cl.class_id,cl.class_level DESC
    ) x;
  IF NOT EXISTS (SELECT 1 FROM public.srd_character_class_levels WHERE character_id=v_sheet.character_id) THEN
    SELECT COALESCE(pr.base_attack_bonus,0)::integer INTO v_bab
      FROM public.srd_class_level_progressions pr
     WHERE pr.class_id=v_sheet.classe_id AND pr.class_level=GREATEST(1,v_sheet.nivel)
     LIMIT 1;
  END IF;
  v_strength_score:=COALESCE(NULLIF(v_sheet.atributos->>'FOR','')::integer,10);
  v_strength_mod:=FLOOR((v_strength_score+priv.srd_effective_modifier(v_character.campaign_id,'character',v_character.id::text,'strength')-10)::numeric/2)::integer;
  v_attack_bonus:=COALESCE(v_bab,0)+v_strength_mod+v_size_modifier
    +priv.srd_effective_modifier(v_character.campaign_id,'character',v_character.id::text,'attack')
    +priv.srd_effective_modifier(v_character.campaign_id,'character',v_character.id::text,'attack_melee');
  IF priv.srd_condition_has_flag(v_character.campaign_id,'character',v_character.id::text,'no_actions')
     OR priv.srd_condition_has_flag(v_character.campaign_id,'character',v_character.id::text,'cannot_attack') THEN
    RAISE EXCEPTION 'A condição atual impede o ataque de toque.';
  END IF;

  IF UPPER(COALESCE(v_campaign.state,''))='COMBATE' THEN
    v_action_result:=public.consumir_acao_turno_srd(v_character.campaign_id,v_character.id::text,'padrao');
  END IF;

  v_attack_total:=p_d20+v_attack_bonus;
  v_hit:=p_d20=20 OR (p_d20<>1 AND v_attack_total>=v_touch_ac);
  IF NOT v_hit THEN
    RETURN jsonb_build_object(
      'feature_key','lay_on_hands','action','harm_undead','hit',false,
      'd20',p_d20,'attack_bonus',v_attack_bonus,'attack_total',v_attack_total,
      'touch_ac',v_touch_ac,'damage',0,'resource_spent',v_spent,
      'resource_remaining',v_remaining,'action_cost','standard','cba_data',v_scene
    );
  END IF;

  v_new_hp:=GREATEST(0,v_hp-p_amount);
  v_target:=v_target||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp);
  SELECT min(t.ordinality) INTO v_target_index
    FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(token,ordinality)
   WHERE (t.token->>'id'=BTRIM(p_target_token_key) OR t.token->>'key'=BTRIM(p_target_token_key))
     AND t.token->>'tipo' IN ('npc','monstro');
  v_tokens:=jsonb_set(v_tokens,ARRAY[(v_target_index-1)::text],v_target,false);
  v_scene:=v_scene||jsonb_build_object('tokens',v_tokens);
  UPDATE public.campaigns SET cba_data=v_scene WHERE id=v_character.campaign_id;

  UPDATE public.srd_character_feature_resources
     SET resource_spent=v_spent+p_amount,last_reset_at=COALESCE(last_reset_at,now())
   WHERE character_id=v_sheet.character_id AND feature_key='lay_on_hands';
  PERFORM priv.log(v_character.campaign_id,'CLASS_FEATURE',jsonb_build_object(
    'feature_key','lay_on_hands','action','harm_undead','character_id',v_character.id::text,
    'character_name',v_character.nome,'target_id',BTRIM(p_target_token_key),
    'target_name',COALESCE(v_target->>'nome',v_target->>'name','Morto-vivo'),
    'd20',p_d20,'attack_bonus',v_attack_bonus,'attack_total',v_attack_total,
    'touch_ac',v_touch_ac,'damage',p_amount,'target_hp',v_new_hp,
    'resource_remaining',v_remaining-p_amount
  ));

  RETURN jsonb_build_object(
    'feature_key','lay_on_hands','action','harm_undead','hit',true,
    'd20',p_d20,'attack_bonus',v_attack_bonus,'attack_total',v_attack_total,
    'touch_ac',v_touch_ac,'damage',p_amount,'hp',v_new_hp,'max_hp',v_max_hp,
    'target_id',BTRIM(p_target_token_key),'target_name',COALESCE(v_target->>'nome',v_target->>'name','Morto-vivo'),
    'resource_spent',v_spent+p_amount,'resource_remaining',v_remaining-p_amount,
    'action_cost','standard','cba_data',v_scene
  );
END;
$function$
;

-- usar_pocao_cura_srd(p_character_id text, p_equipment_id text)
CREATE OR REPLACE FUNCTION public.usar_pocao_cura_srd(p_character_id text, p_equipment_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_count INTEGER;
  v_current_hp INTEGER;
  v_max_hp INTEGER;
  v_dice INTEGER;
  v_flat INTEGER;
  v_healing INTEGER;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.characters
    WHERE id::TEXT = BTRIM(p_character_id) AND user_id = auth.uid()
  ) THEN RAISE EXCEPTION 'A ficha não pertence à sua conta.'; END IF;

  CASE p_equipment_id
    WHEN 'pocao_cura_lig' THEN v_dice := 1; v_flat := 1;
    WHEN 'pocao_cura_mod' THEN v_dice := 2; v_flat := 3;
    WHEN 'pocao_cura_grav' THEN v_dice := 3; v_flat := 5;
    ELSE RAISE EXCEPTION 'Esta poção não tem efeito de cura automatizado.';
  END CASE;

  SELECT quantidade INTO v_count
  FROM public.srd_character_equipment
  WHERE character_id = BTRIM(p_character_id)
    AND equipment_id = p_equipment_id
    AND quantidade > 0
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Poção não encontrada na mochila.'; END IF;

  SELECT pv_atual, pv_max INTO v_current_hp, v_max_hp
  FROM public.srd_character_sheets
  WHERE character_id::TEXT = BTRIM(p_character_id)
  FOR UPDATE;
  IF NOT FOUND OR v_max_hp IS NULL THEN RAISE EXCEPTION 'Ficha SRD sem PV máximo.'; END IF;
  IF COALESCE(v_current_hp,0)<=-10 OR EXISTS(
    SELECT 1 FROM public.characters ch
    JOIN public.srd_campaign_conditions cc ON cc.campaign_id=ch.campaign_id
    WHERE ch.id::text=BTRIM(p_character_id) AND cc.target_kind='character'
      AND cc.target_id=BTRIM(p_character_id) AND cc.condition_id='dead' AND cc.active=true
  ) THEN RAISE EXCEPTION 'Personagens mortos não podem receber cura comum.'; END IF;

  SELECT v_flat + COALESCE(SUM(1 + FLOOR(random() * 8)::INTEGER),0)
  INTO v_healing
  FROM generate_series(1,v_dice);

  UPDATE public.srd_character_sheets
  SET pv_atual = LEAST(v_max_hp,COALESCE(v_current_hp,0)+v_healing)
  WHERE character_id::TEXT = BTRIM(p_character_id)
  RETURNING pv_atual INTO v_current_hp;
  PERFORM priv.srd_sync_character_vital_condition(BTRIM(p_character_id),v_current_hp,
    v_current_hp<0 AND EXISTS(SELECT 1 FROM public.characters ch JOIN public.srd_campaign_conditions cc
      ON cc.campaign_id=ch.campaign_id WHERE ch.id::text=BTRIM(p_character_id)
        AND cc.target_kind='character' AND cc.target_id=BTRIM(p_character_id)
        AND cc.condition_id='stable' AND cc.active=true));

  IF v_count = 1 THEN
    DELETE FROM public.srd_character_equipment
    WHERE character_id = BTRIM(p_character_id) AND equipment_id = p_equipment_id;
  ELSE
    UPDATE public.srd_character_equipment
    SET quantidade = quantidade - 1
    WHERE character_id = BTRIM(p_character_id) AND equipment_id = p_equipment_id;
  END IF;

  RETURN jsonb_build_object(
    'character_id', BTRIM(p_character_id),
    'healing_rolled', v_healing,
    'pv_atual', v_current_hp,
    'pv_max', v_max_hp,
    'quantidade_restante', GREATEST(v_count - 1,0)
  );
END;
$function$
;

-- usar_pocao_cura_srd_manual(p_character_id text, p_equipment_id text, p_roll_results integer[])
CREATE OR REPLACE FUNCTION public.usar_pocao_cura_srd_manual(p_character_id text, p_equipment_id text, p_roll_results integer[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE v_count integer;v_current_hp integer;v_max_hp integer;v_dice integer;v_flat integer;v_healing integer;v_campaign_id bigint;v_campaign_state text;
BEGIN
 IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.';END IF;
 IF NOT EXISTS(SELECT 1 FROM public.characters WHERE id::TEXT=BTRIM(p_character_id) AND user_id=auth.uid()) THEN RAISE EXCEPTION 'A ficha não pertence à sua conta.';END IF;
 CASE p_equipment_id
  WHEN 'pocao_cura_lig' THEN v_dice:=1;v_flat:=1;
  WHEN 'pocao_cura_mod' THEN v_dice:=2;v_flat:=3;
  WHEN 'pocao_cura_grav' THEN v_dice:=3;v_flat:=5;
  ELSE RAISE EXCEPTION 'Esta poção não tem efeito de cura automatizado.';
 END CASE;
 IF p_roll_results IS NULL OR cardinality(p_roll_results)<>v_dice OR EXISTS(SELECT 1 FROM unnest(p_roll_results) value WHERE value<1 OR value>8)
 THEN RAISE EXCEPTION 'A poção exige exatamente % resultado(s) manual(is) de d8.',v_dice;END IF;
 SELECT campaign_id INTO v_campaign_id FROM public.characters WHERE id::TEXT=BTRIM(p_character_id) AND user_id=auth.uid();
 IF v_campaign_id IS NOT NULL THEN
  SELECT state INTO v_campaign_state FROM public.campaigns WHERE id=v_campaign_id;
  IF upper(coalesce(v_campaign_state,''))='COMBATE' THEN PERFORM public.consumir_acao_turno_srd(v_campaign_id,p_character_id,'padrao');END IF;
 END IF;
 SELECT quantidade INTO v_count FROM public.srd_character_equipment WHERE character_id=BTRIM(p_character_id) AND equipment_id=p_equipment_id AND quantidade>0 FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Poção não encontrada na mochila.';END IF;
 SELECT pv_atual,pv_max INTO v_current_hp,v_max_hp FROM public.srd_character_sheets WHERE character_id::TEXT=BTRIM(p_character_id) FOR UPDATE;
 IF NOT FOUND OR v_max_hp IS NULL THEN RAISE EXCEPTION 'Ficha SRD sem PV máximo.';END IF;
 SELECT v_flat+sum(value) INTO v_healing FROM unnest(p_roll_results) value;
 v_healing:=GREATEST(0,v_healing+priv.srd_effective_modifier(v_campaign_id,'character',BTRIM(p_character_id),'healing_received'));
 IF priv.srd_condition_has_flag(v_campaign_id,'character',BTRIM(p_character_id),'no_healing') THEN RAISE EXCEPTION 'Este alvo não pode receber cura.'; END IF;
 IF COALESCE(v_current_hp,0)<=-10 THEN RAISE EXCEPTION 'Personagens mortos não podem receber cura comum.'; END IF;
 UPDATE public.srd_character_sheets SET pv_atual=LEAST(v_max_hp,COALESCE(v_current_hp,0)+v_healing) WHERE character_id::TEXT=BTRIM(p_character_id) RETURNING pv_atual INTO v_current_hp;
 PERFORM priv.srd_sync_character_vital_condition(BTRIM(p_character_id),v_current_hp,v_healing>0);

 IF v_count=1 THEN DELETE FROM public.srd_character_equipment WHERE character_id=BTRIM(p_character_id) AND equipment_id=p_equipment_id;
 ELSE UPDATE public.srd_character_equipment SET quantidade=quantidade-1 WHERE character_id=BTRIM(p_character_id) AND equipment_id=p_equipment_id;END IF;
 RETURN jsonb_build_object('character_id',BTRIM(p_character_id),'healing_rolled',v_healing,'roll_results',to_jsonb(p_roll_results),'pv_atual',v_current_hp,'pv_max',v_max_hp,'quantidade_restante',GREATEST(v_count-1,0));
END;$function$
;

-- xp_to_next(p_xp integer)
CREATE OR REPLACE FUNCTION public.xp_to_next(p_xp integer)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  select case when public.nivel_de_xp(p_xp) >= 20 then null
              else 500 * (public.nivel_de_xp(p_xp) + 1) * public.nivel_de_xp(p_xp) - p_xp end
$function$
;

