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
  RETURN v_next;
END;
$function$
;
