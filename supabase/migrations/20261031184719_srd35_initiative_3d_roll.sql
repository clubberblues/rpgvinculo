-- The GM's NPC/monster initiative must come from the existing 3D dice.
-- This RPC assigns each supplied d20 exactly once to one GM-controlled combatant.
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
  LEFT JOIN public.characters AS ch
    ON ch.campaign_id = p_campaign_id
   AND ch.id::TEXT = candidate.token->>'id'
  WHERE candidate.token->>'tipo' IN ('npc', 'monstro')
     OR (candidate.token->>'tipo' = 'player' AND ch.user_id = auth.uid());

  IF jsonb_array_length(p_gm_d20_results) <> v_gm_count THEN
    RAISE EXCEPTION 'O Mestre precisa rolar exatamente % d20 para os tokens que controla; recebeu %.',
      v_gm_count, jsonb_array_length(p_gm_d20_results);
  END IF;
  IF cardinality(v_expected) = 0 AND v_gm_count = 0 THEN
    RAISE EXCEPTION 'Adicione participantes ao combate antes de iniciar a iniciativa.';
  END IF;

  WITH gm_tokens AS (
    SELECT candidate.token,
           ch.id AS linked_character_id,
           sheet.atributos AS linked_attributes,
           sheet.talentos AS linked_feats
    FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(v_scene->'tokens') = 'array'
           THEN v_scene->'tokens' ELSE '[]'::JSONB END
    ) AS candidate(token)
    LEFT JOIN public.characters AS ch
      ON ch.campaign_id = p_campaign_id
     AND ch.id::TEXT = candidate.token->>'id'
    LEFT JOIN public.srd_character_sheets AS sheet
      ON sheet.character_id = ch.id
    WHERE candidate.token->>'tipo' IN ('npc', 'monstro')
       OR (candidate.token->>'tipo' = 'player' AND ch.user_id = auth.uid())
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

-- Prevent older clients from silently bypassing the 3D die and rolling on the server.
REVOKE ALL ON FUNCTION public.iniciar_iniciativa(BIGINT, TEXT[]) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.iniciar_iniciativa_com_pedido(BIGINT, TEXT[], TEXT) FROM PUBLIC, anon, authenticated;