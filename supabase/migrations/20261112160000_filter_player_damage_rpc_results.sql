-- Move player-facing damage RPC implementations behind private wrappers.
-- The wrappers replace any raw campaign JSON in the result with a role-filtered snapshot.
BEGIN;

CREATE OR REPLACE FUNCTION priv.cba_filter_rpc_json(p_value jsonb, p_snapshot jsonb)
RETURNS jsonb
LANGUAGE plpgsql
IMMUTABLE
SET search_path = pg_catalog, priv
AS $function$
DECLARE
  v_out jsonb;
  v_key text;
  v_value jsonb;
BEGIN
  IF p_value IS NULL THEN RETURN NULL; END IF;

  IF jsonb_typeof(p_value) = 'object' THEN
    v_out := '{}'::jsonb;
    FOR v_key, v_value IN SELECT key, value FROM jsonb_each(p_value)
    LOOP
      IF v_key = 'cba_data' THEN
        IF p_snapshot IS NOT NULL THEN
          v_out := v_out || jsonb_build_object(v_key, p_snapshot->'cba_data');
        END IF;
      ELSIF v_key = 'combat_data' THEN
        IF p_snapshot IS NOT NULL THEN
          v_out := v_out || jsonb_build_object(v_key, p_snapshot->'combat_data');
        END IF;
      ELSE
        v_out := v_out || jsonb_build_object(v_key, priv.cba_filter_rpc_json(v_value, p_snapshot));
      END IF;
    END LOOP;
    RETURN v_out;
  ELSIF jsonb_typeof(p_value) = 'array' THEN
    SELECT coalesce(
      jsonb_agg(priv.cba_filter_rpc_json(e.value, p_snapshot) ORDER BY e.ordinality),
      '[]'::jsonb
    )
    INTO v_out
    FROM jsonb_array_elements(p_value) WITH ORDINALITY AS e(value, ordinality);
    RETURN v_out;
  END IF;

  RETURN p_value;
END
$function$;

CREATE OR REPLACE FUNCTION priv.cba_filter_rpc_result(p_result jsonb, p_campaign_id bigint)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, auth
AS $function$
DECLARE
  v_snapshot jsonb;
BEGIN
  IF p_campaign_id IS NOT NULL THEN
    BEGIN
      v_snapshot := priv.cba_visible_tabletop_snapshot(p_campaign_id);
    EXCEPTION WHEN OTHERS THEN
      -- Fail closed: if the caller cannot obtain an authorized snapshot,
      -- remove private JSON fields rather than returning the raw mutation result.
      v_snapshot := NULL;
    END;
  END IF;
  RETURN priv.cba_filter_rpc_json(p_result, v_snapshot);
END
$function$;

REVOKE ALL ON FUNCTION priv.cba_filter_rpc_json(jsonb,jsonb) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION priv.cba_filter_rpc_result(jsonb,bigint) FROM PUBLIC, anon, authenticated;

-- Move the original implementations into the non-exposed schema. PostgreSQL
-- keeps their OIDs/dependencies intact; public callers use the wrappers below.
ALTER FUNCTION public.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer)
  SET SCHEMA priv;
ALTER FUNCTION public.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer,integer,integer)
  SET SCHEMA priv;

REVOKE ALL ON FUNCTION priv.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer)
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION priv.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer,integer,integer)
  FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.aplicar_dano_token_ataque_srd_v2(
  p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer,
  p_bonus_ataque integer, p_dano integer, p_weapon_id text, p_attack_type text,
  p_power_penalty integer
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, auth
AS $wrapper$
DECLARE
  v_result jsonb;
BEGIN
  v_result := priv.aplicar_dano_token_ataque_srd_v2(
    p_campaign_id,p_character_id,p_token_id,p_d20,p_bonus_ataque,p_dano,
    p_weapon_id,p_attack_type,p_power_penalty
  );
  RETURN priv.cba_filter_rpc_result(v_result,p_campaign_id);
END
$wrapper$;

CREATE OR REPLACE FUNCTION public.aplicar_dano_token_ataque_srd_v2(
  p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer,
  p_bonus_ataque integer, p_dano integer, p_weapon_id text, p_attack_type text,
  p_power_penalty integer, p_sneak_attack_dice integer, p_sneak_attack_damage integer
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, auth
AS $wrapper$
DECLARE
  v_result jsonb;
BEGIN
  v_result := priv.aplicar_dano_token_ataque_srd_v2(
    p_campaign_id,p_character_id,p_token_id,p_d20,p_bonus_ataque,p_dano,
    p_weapon_id,p_attack_type,p_power_penalty,p_sneak_attack_dice,p_sneak_attack_damage
  );
  RETURN priv.cba_filter_rpc_result(v_result,p_campaign_id);
END
$wrapper$;

REVOKE ALL ON FUNCTION public.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer)
  FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer,integer,integer)
  FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer)
  TO authenticated;
GRANT EXECUTE ON FUNCTION public.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer,integer,integer)
  TO authenticated;

COMMIT;
