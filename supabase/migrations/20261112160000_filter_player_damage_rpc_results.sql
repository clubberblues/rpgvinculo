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

-- Extend the same filtered-result boundary to other authenticated CBA mutations.
ALTER FUNCTION public.alterar_pv_token_cba(bigint,text,integer,integer) SET SCHEMA priv;
REVOKE ALL ON FUNCTION priv.alterar_pv_token_cba(bigint,text,integer,integer) FROM PUBLIC, anon, authenticated;
ALTER FUNCTION public.equipar_item_token_srd(bigint,text,text,boolean) SET SCHEMA priv;
REVOKE ALL ON FUNCTION priv.equipar_item_token_srd(bigint,text,text,boolean) FROM PUBLIC, anon, authenticated;
ALTER FUNCTION public.srd_configurar_perfil_combate_token_srd(bigint,text,text,integer) SET SCHEMA priv;
REVOKE ALL ON FUNCTION priv.srd_configurar_perfil_combate_token_srd(bigint,text,text,integer) FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.alterar_pv_token_cba(p_campaign_id bigint, p_token_id text, p_variacao integer, p_pv_max integer)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, auth
AS $wrapper$
DECLARE
  v_result jsonb;
BEGIN
  v_result := priv.alterar_pv_token_cba(p_campaign_id,p_token_id,p_variacao,p_pv_max);
  RETURN priv.cba_filter_rpc_result(v_result,p_campaign_id);
END
$wrapper$;

REVOKE ALL ON FUNCTION public.alterar_pv_token_cba(bigint,text,integer,integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.alterar_pv_token_cba(bigint,text,integer,integer) TO authenticated;

CREATE OR REPLACE FUNCTION public.equipar_item_token_srd(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_equipado boolean)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, auth
AS $wrapper$
DECLARE
  v_result jsonb;
BEGIN
  v_result := priv.equipar_item_token_srd(p_campaign_id,p_token_id,p_equipment_id,p_equipado);
  RETURN priv.cba_filter_rpc_result(v_result,p_campaign_id);
END
$wrapper$;

REVOKE ALL ON FUNCTION public.equipar_item_token_srd(bigint,text,text,boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.equipar_item_token_srd(bigint,text,text,boolean) TO authenticated;

CREATE OR REPLACE FUNCTION public.srd_configurar_perfil_combate_token_srd(p_campaign_id bigint, p_token_id text, p_combat_faction text, p_melee_reach_ft integer)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, auth
AS $wrapper$
DECLARE
  v_result jsonb;
BEGIN
  v_result := priv.srd_configurar_perfil_combate_token_srd(p_campaign_id,p_token_id,p_combat_faction,p_melee_reach_ft);
  RETURN priv.cba_filter_rpc_result(v_result,p_campaign_id);
END
$wrapper$;

REVOKE ALL ON FUNCTION public.srd_configurar_perfil_combate_token_srd(bigint,text,text,integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_configurar_perfil_combate_token_srd(bigint,text,text,integer) TO authenticated;

-- Character-scoped mutation RPCs resolve their campaign from the owned character.
ALTER FUNCTION public.conjurar_magia_dano_multialvo_srd(text,text,smallint,text[],integer[]) SET SCHEMA priv;
REVOKE ALL ON FUNCTION priv.conjurar_magia_dano_multialvo_srd(text,text,smallint,text[],integer[]) FROM PUBLIC, anon, authenticated;
ALTER FUNCTION public.usar_habilidade_classe_srd(text,text,text,integer) SET SCHEMA priv;
REVOKE ALL ON FUNCTION priv.usar_habilidade_classe_srd(text,text,text,integer) FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.conjurar_magia_dano_multialvo_srd(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[])
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, auth
AS $wrapper$
DECLARE
  v_campaign_id bigint;
  v_result jsonb;
BEGIN
  SELECT campaign_id INTO v_campaign_id
    FROM public.characters
   WHERE id::text = p_character_id;
  v_result := priv.conjurar_magia_dano_multialvo_srd(p_character_id,p_spell_id,p_slot_level,p_target_token_keys,p_roll_results);
  RETURN priv.cba_filter_rpc_result(v_result,v_campaign_id);
END
$wrapper$;

REVOKE ALL ON FUNCTION public.conjurar_magia_dano_multialvo_srd(text,text,smallint,text[],integer[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.conjurar_magia_dano_multialvo_srd(text,text,smallint,text[],integer[]) TO authenticated;

CREATE OR REPLACE FUNCTION public.usar_habilidade_classe_srd(p_character_id text, p_feature_key text, p_target_token_key text, p_amount integer)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, auth
AS $wrapper$
DECLARE
  v_campaign_id bigint;
  v_result jsonb;
BEGIN
  SELECT campaign_id INTO v_campaign_id
    FROM public.characters
   WHERE id::text = p_character_id;
  v_result := priv.usar_habilidade_classe_srd(p_character_id,p_feature_key,p_target_token_key,p_amount);
  RETURN priv.cba_filter_rpc_result(v_result,v_campaign_id);
END
$wrapper$;

REVOKE ALL ON FUNCTION public.usar_habilidade_classe_srd(text,text,text,integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.usar_habilidade_classe_srd(text,text,text,integer) TO authenticated;

-- Player-owned action RPCs also return full combat/scene JSON. Move their
-- implementations behind the same response filter so players never receive
-- hidden actors or private campaign state in mutation responses.
ALTER FUNCTION public.consumir_acao_turno_srd(bigint,text,text) SET SCHEMA priv;
REVOKE ALL ON FUNCTION priv.consumir_acao_turno_srd(bigint,text,text) FROM PUBLIC, anon, authenticated;
ALTER FUNCTION public.conjurar_magia_com_acao_srd_manual(text,text,smallint,text,integer[]) SET SCHEMA priv;
REVOKE ALL ON FUNCTION priv.conjurar_magia_com_acao_srd_manual(text,text,smallint,text,integer[]) FROM PUBLIC, anon, authenticated;
ALTER FUNCTION public.conjurar_magia_com_acao_srd_multialvo_v3(text,text,smallint,text[],integer[]) SET SCHEMA priv;
REVOKE ALL ON FUNCTION priv.conjurar_magia_com_acao_srd_multialvo_v3(text,text,smallint,text[],integer[]) FROM PUBLIC, anon, authenticated;
ALTER FUNCTION public.usar_imposicao_maos_mortos_vivos_srd(text,text,integer,integer) SET SCHEMA priv;
REVOKE ALL ON FUNCTION priv.usar_imposicao_maos_mortos_vivos_srd(text,text,integer,integer) FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.consumir_acao_turno_srd(
  p_campaign_id bigint, p_character_id text, p_acao text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, auth
AS $wrapper$
DECLARE
  v_result jsonb;
BEGIN
  v_result := priv.consumir_acao_turno_srd(p_campaign_id,p_character_id,p_acao);
  RETURN priv.cba_filter_rpc_result(v_result,p_campaign_id);
END
$wrapper$;
REVOKE ALL ON FUNCTION public.consumir_acao_turno_srd(bigint,text,text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.consumir_acao_turno_srd(bigint,text,text) TO authenticated;

CREATE OR REPLACE FUNCTION public.conjurar_magia_com_acao_srd_manual(
  p_character_id text,
  p_spell_id text,
  p_slot_level smallint,
  p_target_token_key text DEFAULT NULL::text,
  p_roll_results integer[] DEFAULT NULL::integer[]
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, auth
AS $wrapper$
DECLARE
  v_campaign_id bigint;
  v_result jsonb;
BEGIN
  SELECT ch.campaign_id INTO v_campaign_id
    FROM public.characters AS ch
   WHERE ch.id::text = p_character_id;
  v_result := priv.conjurar_magia_com_acao_srd_manual(
    p_character_id,p_spell_id,p_slot_level,p_target_token_key,p_roll_results
  );
  RETURN priv.cba_filter_rpc_result(v_result,v_campaign_id);
END
$wrapper$;
REVOKE ALL ON FUNCTION public.conjurar_magia_com_acao_srd_manual(text,text,smallint,text,integer[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.conjurar_magia_com_acao_srd_manual(text,text,smallint,text,integer[]) TO authenticated;

CREATE OR REPLACE FUNCTION public.conjurar_magia_com_acao_srd_multialvo_v3(
  p_character_id text,
  p_spell_id text,
  p_slot_level smallint,
  p_target_token_keys text[],
  p_roll_results integer[]
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, auth
AS $wrapper$
DECLARE
  v_campaign_id bigint;
  v_result jsonb;
BEGIN
  SELECT ch.campaign_id INTO v_campaign_id
    FROM public.characters AS ch
   WHERE ch.id::text = p_character_id;
  v_result := priv.conjurar_magia_com_acao_srd_multialvo_v3(
    p_character_id,p_spell_id,p_slot_level,p_target_token_keys,p_roll_results
  );
  RETURN priv.cba_filter_rpc_result(v_result,v_campaign_id);
END
$wrapper$;
REVOKE ALL ON FUNCTION public.conjurar_magia_com_acao_srd_multialvo_v3(text,text,smallint,text[],integer[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.conjurar_magia_com_acao_srd_multialvo_v3(text,text,smallint,text[],integer[]) TO authenticated;

CREATE OR REPLACE FUNCTION public.usar_imposicao_maos_mortos_vivos_srd(
  p_character_id text, p_target_token_key text, p_d20 integer, p_amount integer
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, auth
AS $wrapper$
DECLARE
  v_campaign_id bigint;
  v_result jsonb;
BEGIN
  SELECT ch.campaign_id INTO v_campaign_id
    FROM public.characters AS ch
   WHERE ch.id::text = p_character_id;
  v_result := priv.usar_imposicao_maos_mortos_vivos_srd(
    p_character_id,p_target_token_key,p_d20,p_amount
  );
  RETURN priv.cba_filter_rpc_result(v_result,v_campaign_id);
END
$wrapper$;
REVOKE ALL ON FUNCTION public.usar_imposicao_maos_mortos_vivos_srd(text,text,integer,integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.usar_imposicao_maos_mortos_vivos_srd(text,text,integer,integer) TO authenticated;

-- Pending-movement completion nests the mover RPC result; the recursive
-- filter protects private scene/combat JSON even when nested in movement_result.
ALTER FUNCTION public.srd_finalizar_movimento_aoo_pendente_srd(bigint,uuid) SET SCHEMA priv;
REVOKE ALL ON FUNCTION priv.srd_finalizar_movimento_aoo_pendente_srd(bigint,uuid) FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.srd_finalizar_movimento_aoo_pendente_srd(
  p_campaign_id bigint, p_pending_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, auth
AS $wrapper$
DECLARE
  v_result jsonb;
BEGIN
  v_result := priv.srd_finalizar_movimento_aoo_pendente_srd(p_campaign_id,p_pending_id);
  RETURN priv.cba_filter_rpc_result(v_result,p_campaign_id);
END
$wrapper$;

REVOKE ALL ON FUNCTION public.srd_finalizar_movimento_aoo_pendente_srd(bigint,uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_finalizar_movimento_aoo_pendente_srd(bigint,uuid) TO authenticated;


-- Turn advancement is callable by any active campaign member and returns
-- the full combat_data object. Route it through the same role projection.
ALTER FUNCTION public.avancar_turno(bigint) SET SCHEMA priv;
REVOKE ALL ON FUNCTION priv.avancar_turno(bigint) FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.avancar_turno(p_campaign_id bigint)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, auth
AS $wrapper$
DECLARE
  v_result jsonb;
BEGIN
  v_result := priv.avancar_turno(p_campaign_id);
  -- This legacy RPC returns combat_data as the top-level JSON object rather
  -- than under a "combat_data" key; wrap it for filtering, then unwrap it.
  RETURN priv.cba_filter_rpc_result(
    jsonb_build_object('combat_data',v_result),p_campaign_id
  )->'combat_data';
END
$wrapper$;

REVOKE ALL ON FUNCTION public.avancar_turno(bigint) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.avancar_turno(bigint) TO authenticated;


-- Player initiative submission also returns the complete combat_data object.
-- Keep the owner/PLAYER guard in the original implementation and filter its
-- response before it reaches the player client.
ALTER FUNCTION public.registrar_iniciativa_d20(bigint,text,integer) SET SCHEMA priv;
REVOKE ALL ON FUNCTION priv.registrar_iniciativa_d20(bigint,text,integer) FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.registrar_iniciativa_d20(
  p_campaign_id bigint, p_personagem_id text, p_d20 integer
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, auth
AS $wrapper$
DECLARE
  v_result jsonb;
BEGIN
  v_result := priv.registrar_iniciativa_d20(p_campaign_id,p_personagem_id,p_d20);
  RETURN priv.cba_filter_rpc_result(v_result,p_campaign_id);
END
$wrapper$;
REVOKE ALL ON FUNCTION public.registrar_iniciativa_d20(bigint,text,integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.registrar_iniciativa_d20(bigint,text,integer) TO authenticated;

COMMIT;
