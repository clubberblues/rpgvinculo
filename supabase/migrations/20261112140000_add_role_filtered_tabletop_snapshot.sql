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

  SELECT EXISTS (
    SELECT 1 FROM public.members m
     WHERE m.campaign_id = p_campaign_id AND m.user_id = v_user
  ) INTO v_is_gm;

  IF v_campaign.owner_id = v_user THEN
    v_is_gm := true;
  ELSE
    IF NOT v_is_gm THEN
      RAISE EXCEPTION 'Você não participa desta campanha.' USING ERRCODE = '42501';
    END IF;
    SELECT EXISTS (
      SELECT 1 FROM public.members m
       WHERE m.campaign_id = p_campaign_id
         AND m.user_id = v_user
         AND upper(coalesce(m.role,'')) = 'GM'
    ) INTO v_is_gm;
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

    SELECT coalesce(jsonb_agg(t.value ORDER BY t.ordinality), '[]'::jsonb)
      INTO v_order
      FROM jsonb_array_elements(
        CASE WHEN jsonb_typeof(v_scene->'tokens') = 'array'
             THEN v_scene->'tokens' ELSE '[]'::jsonb END
      ) WITH ORDINALITY AS t(value, ordinality)
     WHERE coalesce(t.value->>'visivel','false') = 'true'
        OR t.value->>'sourceCharacterId' = ANY(v_owned_ids)
        OR t.value->>'id' = ANY(v_owned_ids);

    v_scene := v_scene || jsonb_build_object('tokens', v_order);
    -- Until revealed tiles/crops are persisted, never hand a fog-enabled full map to players.
    IF lower(coalesce(v_scene->>'fogEnabled','false')) = 'true' THEN
      v_scene := v_scene - 'backgroundPath' - 'background' - 'backgroundUrl';
    END IF;

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
        v_order := v_order || jsonb_build_array(v_item);
      ELSIF v_index = v_current THEN
        v_new_current := 0;
      END IF;
      v_index := v_index + 1;
    END LOOP;

    v_combat := jsonb_build_object(
      'active', lower(coalesce(v_combat->>'active','false')) IN ('true','t','1'),
      'round', CASE WHEN coalesce(v_combat->>'round','') ~ '^[0-9]+
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
      'location_id', v_campaign.location_id,
      'briefing', v_campaign.briefing,
      'capa_url', v_campaign.capa_url,
      'capa_transform', v_campaign.capa_transform
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
 THEN greatest(1, (v_combat->>'round')::integer) ELSE 1 END,
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
      'location_id', v_campaign.location_id,
      'briefing', v_campaign.briefing,
      'capa_url', v_campaign.capa_url,
      'capa_transform', v_campaign.capa_transform
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
 THEN greatest(1, (v_combat->>'round')::integer) ELSE 1 END,
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
      'location_id', v_campaign.location_id,
      'briefing', v_campaign.briefing,
      'capa_url', v_campaign.capa_url,
      'capa_transform', v_campaign.capa_transform
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
 THEN greatest(1, (v_combat->>'round')::integer) ELSE 1 END,
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
      'location_id', v_campaign.location_id,
      'briefing', v_campaign.briefing,
      'capa_url', v_campaign.capa_url,
      'capa_transform', v_campaign.capa_transform
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
