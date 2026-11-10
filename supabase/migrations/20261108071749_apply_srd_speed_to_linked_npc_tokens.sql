DO $migration$
DECLARE
  v_definition text;
  v_start integer;
  v_end integer;
  v_new text := $new$
IF v_token_type='npc' AND NULLIF(BTRIM(v_token->>'sourceCharacterId'),'') IS NOT NULL THEN
    SELECT race.deslocamento INTO v_speed_m
      FROM public.srd_character_sheets AS sheet
      JOIN public.srd_races AS race ON race.id::TEXT=sheet.raca_id::TEXT
     WHERE sheet.character_id::TEXT=BTRIM(v_token->>'sourceCharacterId');
    IF NOT FOUND OR v_speed_m IS NULL THEN
      RAISE EXCEPTION 'Não foi possível obter o deslocamento racial da ficha vinculada a %.',v_token->>'nome';
    END IF;
    v_speed_m:=public.srd35_deslocamento_personagem(BTRIM(v_token->>'sourceCharacterId'),v_speed_m);
    IF priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'no_move') THEN
      RAISE EXCEPTION 'A condição atual impede movimentação.';
    END IF;
    v_speed_m:=v_speed_m*priv.srd_condition_speed_multiplier(p_campaign_id,'token',BTRIM(p_token_id));
  ELSE
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
    IF v_token_type<>'player' THEN
      IF priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'no_move') THEN
        RAISE EXCEPTION 'A condição atual impede movimentação.';
      END IF;
      v_speed_m:=v_speed_m*priv.srd_condition_speed_multiplier(p_campaign_id,'token',BTRIM(p_token_id));
    END IF;
    IF v_token_type='player' THEN
      IF priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_token_id),'no_move') THEN
        RAISE EXCEPTION 'A condição atual impede movimentação.';
      END IF;
      v_speed_m:=public.srd35_deslocamento_personagem(BTRIM(p_token_id),v_speed_m);
      v_speed_m:=v_speed_m*priv.srd_condition_speed_multiplier(p_campaign_id,'character',BTRIM(p_token_id));
    END IF;
  END IF;

$new$;
BEGIN
  v_definition:=pg_get_functiondef('public.mover_token_gm_cba_srd(bigint,text,integer,integer)'::regprocedure);
  v_start:=position('v_speed_text :=' in v_definition);
  v_end:=position('  -- D&D 3.5: permite dividir a ação de movimento' in v_definition);
  IF v_start=0 OR v_end=0 OR v_end<=v_start THEN
    RAISE EXCEPTION 'Bloco de deslocamento não encontrado; nenhuma alteração aplicada.';
  END IF;
  v_definition:=substring(v_definition from 1 for v_start-1)||v_new||substring(v_definition from v_end);
  EXECUTE v_definition;
END
$migration$;