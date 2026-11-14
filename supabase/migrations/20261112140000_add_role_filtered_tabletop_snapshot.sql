-- Server-authoritative, role-filtered read model for the live tabletop.
-- Players receive only visible tokens, their own character state, and public initiative data.
-- This is a transition endpoint: legacy direct reads and unfiltered RPC payloads must
-- be removed before direct access to campaigns.cba_data/combat_data is revoked.
-- Fog of war is intentionally out of scope; the map background remains visible to players.
BEGIN;

GRANT USAGE ON SCHEMA priv TO authenticated;

CREATE OR REPLACE FUNCTION priv.cba_visible_tabletop_snapshot(p_campaign_id bigint)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  v_user uuid := auth.uid();
  v_campaign public.campaigns%ROWTYPE;
  v_is_gm boolean := false;
  v_owned_ids text[] := ARRAY[]::text[];
  v_visible_ids text[] := ARRAY[]::text[];
  v_scene jsonb;
  v_combat jsonb;
  v_scene_tokens jsonb := '[]'::jsonb;
  v_player_turn_order jsonb := '[]'::jsonb;
  v_player_actions jsonb := '{}'::jsonb;
  v_player_action_economy jsonb := '{}'::jsonb;
  v_player_movement jsonb := '{}'::jsonb;
  v_expected_ids jsonb := '[]'::jsonb;
  v_current integer := 0;
  v_new_current integer := 0;
  v_index integer := 0;
  v_item jsonb;
BEGIN
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'Autenticação obrigatória.' USING ERRCODE = '42501';
  END IF;

  SELECT c.*
    INTO v_campaign
    FROM public.campaigns AS c
   WHERE c.id = p_campaign_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.' USING ERRCODE = 'P0002';
  END IF;

  IF v_campaign.owner_id = v_user THEN
    v_is_gm := true;
  ELSE
    IF NOT EXISTS (
      SELECT 1
        FROM public.members AS m
       WHERE m.campaign_id = p_campaign_id
         AND m.user_id = v_user
    ) THEN
      RAISE EXCEPTION 'Você não participa desta campanha.' USING ERRCODE = '42501';
    END IF;
    -- The active mesa client treats campaigns.owner_id as the GM authority.
    -- A legacy members.role='GM' value must not disclose hidden state.
    v_is_gm := false;
  END IF;

  SELECT coalesce(array_agg(ch.id::text), ARRAY[]::text[])
    INTO v_owned_ids
    FROM public.characters AS ch
   WHERE ch.campaign_id = p_campaign_id
     AND ch.user_id = v_user;

  v_scene := coalesce(v_campaign.cba_data, '{}'::jsonb);
  v_combat := coalesce(v_campaign.combat_data, '{}'::jsonb);

  IF jsonb_typeof(v_scene) <> 'object' THEN
    v_scene := '{}'::jsonb;
  END IF;
  IF jsonb_typeof(v_combat) <> 'object' THEN
    v_combat := '{}'::jsonb;
  END IF;

  IF NOT v_is_gm THEN
    -- Token visibility is independent from fog of war: visible tokens and the
    -- player's own character token are included; the map itself is not obscured.
    SELECT coalesce(array_agg(t.value->>'id'), ARRAY[]::text[])
      INTO v_visible_ids
      FROM jsonb_array_elements(
        CASE
          WHEN jsonb_typeof(v_scene->'tokens') = 'array' THEN v_scene->'tokens'
          ELSE '[]'::jsonb
        END
      ) AS t(value)
     WHERE coalesce(t.value->>'visivel', 'false') = 'true'
        OR t.value->>'sourceCharacterId' = ANY(v_owned_ids)
        OR t.value->>'id' = ANY(v_owned_ids);

    -- Project each visible token through an explicit allowlist.
    SELECT coalesce(
             jsonb_agg(
               jsonb_build_object(
                 'key', t.value->'key',
                 'id', t.value->'id',
                 'nome', t.value->'nome',
                 'imagem', t.value->'imagem',
                 'imagemPath', t.value->'imagemPath',
                 'tipo', t.value->'tipo',
                 'detalhe', t.value->'detalhe',
                 'hp', t.value->'hp',
                 'maxHp', t.value->'maxHp',
                 'dexMod', t.value->'dexMod',
                 'bonusIniciativa', t.value->'bonusIniciativa',
                 'monsterId', t.value->'monsterId',
                 'ac', t.value->'ac',
                 'baseAc', t.value->'baseAc',
                 'sourceCharacterId', t.value->'sourceCharacterId',
                 'attackBonus', t.value->'attackBonus',
                 'damageDice', t.value->'damageDice',
                 'spellState', t.value->'spellState',
                 'monsterStats', t.value->'monsterStats',
                 'srdSourceUrl', t.value->'srdSourceUrl',
                 'gridX', t.value->'gridX',
                 'gridY', t.value->'gridY',
                 'visivel', t.value->'visivel'
               )
               ORDER BY t.ordinality
             ),
             '[]'::jsonb
           )
      INTO v_scene_tokens
      FROM jsonb_array_elements(
        CASE
          WHEN jsonb_typeof(v_scene->'tokens') = 'array' THEN v_scene->'tokens'
          ELSE '[]'::jsonb
        END
      ) WITH ORDINALITY AS t(value, ordinality)
     WHERE coalesce(t.value->>'visivel', 'false') = 'true'
        OR t.value->>'sourceCharacterId' = ANY(v_owned_ids)
        OR t.value->>'id' = ANY(v_owned_ids);

    -- Only the current player's action-economy flags are returned.
    SELECT coalesce(jsonb_object_agg(e.key, e.value), '{}'::jsonb)
      INTO v_player_actions
      FROM jsonb_each(
        CASE
          WHEN jsonb_typeof(v_combat->'action_economy'->'by_character') = 'object'
            THEN v_combat->'action_economy'->'by_character'
          ELSE '{}'::jsonb
        END
      ) AS e(key, value)
     WHERE e.key = ANY(v_owned_ids)
       AND v_combat->'action_economy'->>'round' = v_combat->>'round';

    v_player_action_economy := jsonb_build_object(
      'round',
      CASE
        WHEN coalesce(v_combat->>'round', '') ~ '^[0-9]{1,6}$'
          THEN greatest(1, (v_combat->>'round')::integer)
        ELSE 1
      END,
      'by_character', v_player_actions
    );

    -- Movement preview is returned only for a character owned by this player.
    IF v_combat->'movement_usage'->>'character_id' = ANY(v_owned_ids) THEN
      v_player_movement := jsonb_build_object(
        'character_id', v_combat->'movement_usage'->'character_id',
        'round', v_combat->'movement_usage'->'round',
        'current_turn', v_combat->'movement_usage'->'current_turn',
        'moved_squares',
        CASE
          WHEN coalesce(v_combat->'movement_usage'->>'moved_squares', '') ~ '^[0-9]{1,5}$'
            THEN (v_combat->'movement_usage'->>'moved_squares')::integer
          ELSE 0
        END
      );
    END IF;

    -- Pending initiative requests are private to the owning character.
    SELECT coalesce(jsonb_agg(to_jsonb(e.value)), '[]'::jsonb)
      INTO v_expected_ids
      FROM jsonb_array_elements_text(
        CASE
          WHEN jsonb_typeof(v_combat->'expected_character_ids') = 'array'
            THEN v_combat->'expected_character_ids'
          ELSE '[]'::jsonb
        END
      ) AS e(value)
     WHERE e.value = ANY(v_owned_ids);

    -- Preserve the uploaded map and grid for all participants. No fog flag,
    -- map masking, reveal tiles, or fog-of-war state is part of this contract.
    v_scene := jsonb_build_object(
      'version', coalesce(v_scene->'version', '1'::jsonb),
      'background', coalesce(v_scene->'background', '""'::jsonb),
      'backgroundPath', coalesce(v_scene->'backgroundPath', '""'::jsonb),
      'imgScale', coalesce(v_scene->'imgScale', '1'::jsonb),
      'gridSize', coalesce(v_scene->'gridSize', '50'::jsonb),
      'gridRatio', v_scene->'gridRatio',
      'gridOpacity', coalesce(v_scene->'gridOpacity', '0.3'::jsonb),
      'tokens', v_scene_tokens
    );

    -- Initiative is projected to visible/owned combatants only.
    IF coalesce(v_combat->>'current_turn', '') ~ '^[0-9]{1,6}$' THEN
      v_current := (v_combat->>'current_turn')::integer;
    END IF;

    FOR v_item IN
      SELECT e.value
        FROM jsonb_array_elements(
          CASE
            WHEN jsonb_typeof(v_combat->'turn_order') = 'array'
              THEN v_combat->'turn_order'
            ELSE '[]'::jsonb
          END
        ) WITH ORDINALITY AS e(value, ordinality)
       ORDER BY e.ordinality
    LOOP
      IF v_item->>'id' = ANY(v_visible_ids)
         OR v_item->>'id' = ANY(v_owned_ids)
         OR v_item->>'character_id' = ANY(v_owned_ids) THEN
        IF v_index = v_current THEN
          v_new_current := jsonb_array_length(v_player_turn_order);
        END IF;

        v_player_turn_order := v_player_turn_order || jsonb_build_array(
          jsonb_build_object(
            'id', v_item->'id',
            'nome', v_item->'nome',
            'tipo', v_item->'tipo',
            'is_monster', v_item->'is_monster',
            'valor', v_item->'valor',
            'd20', v_item->'d20',
            'dex_mod', v_item->'dex_mod'
          )
        );
      ELSIF v_index = v_current THEN
        -- Do not reveal the identity of the hidden current actor.
        v_new_current := 0;
      END IF;

      v_index := v_index + 1;
    END LOOP;

    v_combat := jsonb_build_object(
      'active', lower(coalesce(v_combat->>'active', 'false')) IN ('true', 't', '1'),
      'round',
      CASE
        WHEN coalesce(v_combat->>'round', '') ~ '^[0-9]{1,6}$'
          THEN greatest(1, (v_combat->>'round')::integer)
        ELSE 1
      END,
      'current_turn', v_new_current,
      'turn_order', v_player_turn_order,
      'expected_character_ids', v_expected_ids,
      'action_economy', v_player_action_economy,
      'movement_usage', v_player_movement
    );
  END IF;

  RETURN jsonb_build_object(
    'campaign', jsonb_build_object(
      'id', v_campaign.id,
      'name', v_campaign.name,
      'owner_id', v_campaign.owner_id,
      'state', v_campaign.state,
      'active', v_campaign.active
    ),
    'cba_data', v_scene,
    'combat_data', v_combat,
    'viewer_is_gm', v_is_gm
  );
END
$function$;

REVOKE ALL ON FUNCTION priv.cba_visible_tabletop_snapshot(bigint) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION priv.cba_visible_tabletop_snapshot(bigint) TO authenticated;

CREATE OR REPLACE FUNCTION public.obter_snapshot_seguro_mesa(p_campaign_id bigint)
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = ''
AS $function$
  SELECT priv.cba_visible_tabletop_snapshot(p_campaign_id)
$function$;

REVOKE ALL ON FUNCTION public.obter_snapshot_seguro_mesa(bigint) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.obter_snapshot_seguro_mesa(bigint) TO authenticated;

COMMIT;
