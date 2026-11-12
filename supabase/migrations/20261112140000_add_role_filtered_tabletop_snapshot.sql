-- Server-authoritative, role-filtered read model for the live tabletop.
-- This is a transition endpoint: legacy direct reads and RPC payloads must be
-- removed before column-level access to campaigns.cba_data/combat_data is revoked.
BEGIN;

GRANT USAGE ON SCHEMA priv TO authenticated;

CREATE OR REPLACE FUNCTION priv.cba_visible_tabletop_snapshot(p_campaign_id bigint)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, auth
AS $function$
DECLARE
  v_user uuid := auth.uid();
  v_campaign public.campaigns%ROWTYPE;
  v_is_gm boolean := false;
  v_owned_ids text[] := ARRAY[]::text[];
  v_visible_ids text[] := ARRAY[]::text[];
  v_scene jsonb;
  v_combat jsonb;
  v_order jsonb := '[]'::jsonb;
  v_actor jsonb;
  v_current integer := 0;
  v_new_current integer := 0;
  v_index integer := 0;
  v_item jsonb;
BEGIN
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'Autenticação obrigatória.' USING ERRCODE = '42501';
  END IF;

  SELECT c.* INTO v_campaign
    FROM public.campaigns AS c
   WHERE c.id = p_campaign_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.' USING ERRCODE = 'P0002';
  END IF;

  IF v_campaign.owner_id = v_user THEN
    v_is_gm := true;
  ELSE
    IF NOT EXISTS (
      SELECT 1 FROM public.members m
       WHERE m.campaign_id = p_campaign_id AND m.user_id = v_user
    ) THEN
      RAISE EXCEPTION 'Você não participa desta campanha.' USING ERRCODE = '42501';
    END IF;
    -- The active mesa client treats only campaigns.owner_id as the GM.
    -- Legacy members.role='GM' must not disclose hidden state.
    v_is_gm := false;
  END IF;

  SELECT coalesce(array_agg(ch.id::text), ARRAY[]::text[])
    INTO v_owned_ids
    FROM public.characters ch
   WHERE ch.campaign_id = p_campaign_id
     AND ch.user_id = v_user;

  v_scene := coalesce(v_campaign.cba_data, '{}'::jsonb);
  v_combat := coalesce(v_campaign.combat_data, '{}'::jsonb);
  IF jsonb_typeof(v_scene) <> 'object' THEN v_scene := '{}'::jsonb; END IF;
  IF jsonb_typeof(v_combat) <> 'object' THEN v_combat := '{}'::jsonb; END IF;

  IF NOT v_is_gm THEN
    SELECT coalesce(array_agg(t.value->>'id'), ARRAY[]::text[])
      INTO v_visible_ids
      FROM jsonb_array_elements(
        CASE WHEN jsonb_typeof(v_scene->'tokens') = 'array'
             THEN v_scene->'tokens' ELSE '[]'::jsonb END
      ) AS t(value)
     WHERE coalesce(t.value->>'visivel','false') = 'true'
        OR t.value->>'sourceCharacterId' = ANY(v_owned_ids)
        OR t.value->>'id' = ANY(v_owned_ids);

    -- Project visible tokens onto the exact client contract. Do not pass
    -- unknown GM-only metadata through merely because a token is visible.
    SELECT coalesce(jsonb_agg(jsonb_build_object(
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
      ) ORDER BY t.ordinality), '[]'::jsonb)
      INTO v_order
      FROM jsonb_array_elements(
        CASE WHEN jsonb_typeof(v_scene->'tokens') = 'array'
             THEN v_scene->'tokens' ELSE '[]'::jsonb END
      ) WITH ORDINALITY AS t(value, ordinality)
     WHERE coalesce(t.value->>'visivel','false') = 'true'
        OR t.value->>'sourceCharacterId' = ANY(v_owned_ids)
        OR t.value->>'id' = ANY(v_owned_ids);

    -- The player scene is an allowlist, not a copy of the full GM JSONB.
    -- Until revealed tiles/crops are persisted, a fog-enabled scene gets no
    -- background URL/path at all; unknown scene metadata is always withheld.
    v_scene := jsonb_build_object(
      'version', coalesce(v_scene->'version', '1'::jsonb),
      'background', CASE WHEN lower(coalesce(v_scene->>'fogEnabled','false')) = 'true'
                         THEN '""'::jsonb ELSE coalesce(v_scene->'background','""'::jsonb) END,
      'backgroundPath', CASE WHEN lower(coalesce(v_scene->>'fogEnabled','false')) = 'true'
                             THEN '""'::jsonb ELSE coalesce(v_scene->'backgroundPath','""'::jsonb) END,
      'fogEnabled', lower(coalesce(v_scene->>'fogEnabled','false')) = 'true',
      'imgScale', coalesce(v_scene->'imgScale', '1'::jsonb),
      'gridSize', coalesce(v_scene->'gridSize', '50'::jsonb),
      'gridRatio', v_scene->'gridRatio',
      'gridOpacity', coalesce(v_scene->'gridOpacity', '0.3'::jsonb),
      'tokens', v_order
    );

    -- Initiative is projected to visible/owned combatants only. Private
    -- pending reactions, hidden actor metadata and action-economy internals
    -- are deliberately withheld from players.
    v_order := '[]'::jsonb;
    IF coalesce(v_combat->>'current_turn','') ~ '^[0-9]+$' THEN
      v_current := (v_combat->>'current_turn')::integer;
    END IF;
    FOR v_item IN
      SELECT e.value
        FROM jsonb_array_elements(
          CASE WHEN jsonb_typeof(v_combat->'turn_order') = 'array'
               THEN v_combat->'turn_order' ELSE '[]'::jsonb END
        ) WITH ORDINALITY AS e(value, ordinality)
       ORDER BY e.ordinality
    LOOP
      IF v_item->>'id' = ANY(v_visible_ids)
         OR v_item->>'id' = ANY(v_owned_ids)
         OR v_item->>'character_id' = ANY(v_owned_ids) THEN
        IF v_index = v_current THEN
          v_new_current := jsonb_array_length(v_order);
        END IF;
        -- Initiative entries are also projected: a visible actor must not
        -- carry arbitrary hidden metadata into a player's response.
        v_order := v_order || jsonb_build_array(jsonb_build_object(
          'id', v_item->'id',
          'nome', v_item->'nome',
          'tipo', v_item->'tipo',
          'is_monster', v_item->'is_monster',
          'valor', v_item->'valor',
          'd20', v_item->'d20',
          'dex_mod', v_item->'dex_mod'
        ));
      ELSIF v_index = v_current THEN
        v_new_current := 0;
      END IF;
      v_index := v_index + 1;
    END LOOP;

    v_combat := jsonb_build_object(
      'active', lower(coalesce(v_combat->>'active','false')) IN ('true','t','1'),
      'round', CASE WHEN coalesce(v_combat->>'round','') ~ '^[0-9]+$' THEN greatest(1, (v_combat->>'round')::integer) ELSE 1 END,
      'current_turn', v_new_current,
      'turn_order', v_order
    );
  END IF;

  RETURN jsonb_build_object(
    'campaign', jsonb_build_object(
      'id', v_campaign.id,
      'name', v_campaign.name,
      'owner_id', v_campaign.owner_id,
      'state', v_campaign.state,
      'active', v_campaign.active,
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
SET search_path = pg_catalog, public, priv
AS $function$
  SELECT priv.cba_visible_tabletop_snapshot(p_campaign_id)
$function$;

REVOKE ALL ON FUNCTION public.obter_snapshot_seguro_mesa(bigint) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.obter_snapshot_seguro_mesa(bigint) TO authenticated;

COMMIT;
