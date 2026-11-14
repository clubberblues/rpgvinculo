\set ON_ERROR_STOP on

CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS priv;

CREATE OR REPLACE FUNCTION auth.uid()
RETURNS uuid
LANGUAGE sql
STABLE
AS $uid$
  SELECT NULLIF(current_setting('request.jwt.claim.sub', true), '')::uuid
$uid$;

CREATE OR REPLACE FUNCTION public.my_role(cid bigint)
RETURNS text
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $role_fixture$
  SELECT m.role
    FROM public.members m
   WHERE m.campaign_id = cid
     AND m.user_id = auth.uid()
   LIMIT 1
$role_fixture$;

DELETE FROM public.characters WHERE campaign_id = 987654331;
DELETE FROM public.members WHERE campaign_id = 987654331;
DELETE FROM public.campaigns WHERE id = 987654331;

INSERT INTO public.campaigns(id, name, owner_id)
VALUES (987654331, 'GM iterative attack fixture', '00000000-0000-0000-0000-000000000001');

INSERT INTO public.members(campaign_id, user_id, role) VALUES
  (987654331, '00000000-0000-0000-0000-000000000001', 'GM'),
  (987654331, '00000000-0000-0000-0000-000000000002', 'PLAYER'),
  (987654331, '00000000-0000-0000-0000-000000000003', 'PLAYER');

INSERT INTO public.characters(id, campaign_id, user_id)
VALUES ('gm-control-pc-attack', 987654331, '00000000-0000-0000-0000-000000000002');

CREATE OR REPLACE FUNCTION priv.iniciar_sequencia_ataque_iterativo_srd_5_impl(
  p_campaign_id bigint,
  p_character_id text,
  p_target_token_id text,
  p_attack_type text,
  p_weapon_instance_id uuid DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, priv, pg_temp
AS $start_impl$
DECLARE v_user uuid := auth.uid();
BEGIN
  IF NOT EXISTS (
    SELECT 1
      FROM public.characters ch
      JOIN public.members m
        ON m.campaign_id = ch.campaign_id
       AND m.user_id = ch.user_id
     WHERE ch.id::text = btrim(p_character_id)
       AND ch.campaign_id = p_campaign_id
       AND ch.user_id = v_user
       AND m.role = 'PLAYER'
  ) THEN
    RAISE EXCEPTION 'A ficha atacante não pertence ao jogador nesta campanha.';
  END IF;
  RETURN jsonb_build_object('allowed', true);
END
$start_impl$;

CREATE OR REPLACE FUNCTION public.consultar_sequencia_ataque_iterativo_pendente_srd(
  p_campaign_id bigint,
  p_character_id text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, priv, pg_temp
AS $pending$
DECLARE v_user uuid := auth.uid();
BEGIN
  IF NOT EXISTS (
    SELECT 1
      FROM public.members m
      JOIN public.characters ch
        ON ch.campaign_id = m.campaign_id
       AND ch.user_id = m.user_id
     WHERE m.campaign_id = p_campaign_id
       AND m.user_id = v_user
       AND m.role = 'PLAYER'
       AND ch.id::text = p_character_id
  ) THEN
    RAISE EXCEPTION 'O personagem não pertence ao jogador autenticado nesta campanha.';
  END IF;
  RETURN jsonb_build_object('allowed', true);
END
$pending$;

CREATE OR REPLACE FUNCTION public.registrar_rolagem_ataque_iterativo_srd(
  p_campaign_id bigint,
  p_sequence_id uuid,
  p_manual_d20 integer,
  p_idempotency_key uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, priv, pg_temp
AS $register$
DECLARE v_user uuid := auth.uid(); v_actor_character_id text := 'gm-control-pc-attack';
BEGIN
  IF NOT EXISTS (
    SELECT 1
      FROM public.members m
      JOIN public.characters ch
        ON ch.campaign_id = m.campaign_id
       AND ch.user_id = m.user_id
     WHERE m.campaign_id = p_campaign_id
       AND m.user_id = v_user
       AND m.role = 'PLAYER'
       AND ch.id::text = v_actor_character_id
  ) THEN
    RAISE EXCEPTION 'A ficha da sequência não pertence ao jogador autenticado.';
  END IF;
  RETURN jsonb_build_object('allowed', true);
END
$register$;

CREATE OR REPLACE FUNCTION public.resolver_ataque_iterativo_srd(
  p_campaign_id bigint,
  p_attempt_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, priv, pg_temp
AS $resolve$
DECLARE v_user uuid := auth.uid(); v_actor_character_id text := 'gm-control-pc-attack';
BEGIN
  IF NOT EXISTS (
    SELECT 1
      FROM public.characters ch
      JOIN public.members m
        ON m.campaign_id = ch.campaign_id
       AND m.user_id = ch.user_id
     WHERE ch.id::text = v_actor_character_id
       AND ch.campaign_id = p_campaign_id
       AND ch.user_id = v_user
       AND m.role = 'PLAYER'
  ) THEN
    RAISE EXCEPTION 'A ficha atacante não pertence ao jogador autenticado nesta campanha.';
  END IF;
  RETURN jsonb_build_object('allowed', true);
END
$resolve$;

CREATE OR REPLACE FUNCTION public.confirmar_critico_ataque_iterativo_srd(
  p_campaign_id bigint,
  p_attempt_id uuid,
  p_confirmation_d20 integer
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, priv, pg_temp
AS $critical$
DECLARE v_user uuid := auth.uid(); v_actor_character_id text := 'gm-control-pc-attack';
BEGIN
  IF NOT EXISTS (
    SELECT 1
      FROM public.characters ch
      JOIN public.members m
        ON m.campaign_id = ch.campaign_id
       AND m.user_id = ch.user_id
     WHERE ch.id::text = v_actor_character_id
       AND ch.campaign_id = p_campaign_id
       AND ch.user_id = v_user
       AND m.role = 'PLAYER'
  ) THEN
    RAISE EXCEPTION 'Personagem não pertence ao jogador autenticado.';
  END IF;
  RETURN jsonb_build_object('allowed', true);
END
$critical$;

CREATE OR REPLACE FUNCTION public.aplicar_dano_ataque_iterativo_srd(
  p_campaign_id bigint,
  p_attempt_id uuid,
  p_damage_rolls integer[],
  p_idempotency_key uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, priv, pg_temp
AS $damage4$
DECLARE v_user uuid := auth.uid(); v_actor_character_id text := 'gm-control-pc-attack';
BEGIN
  IF NOT EXISTS (
    SELECT 1
      FROM public.characters ch
      JOIN public.members m
        ON m.campaign_id = ch.campaign_id
       AND m.user_id = ch.user_id
     WHERE ch.id::text = v_actor_character_id
       AND ch.campaign_id = p_campaign_id
       AND ch.user_id = v_user
       AND m.role = 'PLAYER'
  ) THEN
    RAISE EXCEPTION 'Personagem não pertence ao jogador autenticado.';
  END IF;
  RETURN jsonb_build_object('allowed', true);
END
$damage4$;

CREATE OR REPLACE FUNCTION public.aplicar_dano_ataque_iterativo_srd(
  p_campaign_id bigint,
  p_attempt_id uuid,
  p_damage_rolls integer[],
  p_idempotency_key uuid,
  p_sneak_damage_rolls integer[]
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, priv, pg_temp
AS $damage5$
DECLARE v_user uuid := auth.uid(); v_actor_character_id text := 'gm-control-pc-attack';
BEGIN
  IF NOT EXISTS (
    SELECT 1
      FROM public.characters ch
      JOIN public.members m
        ON m.campaign_id = ch.campaign_id
       AND m.user_id = ch.user_id
     WHERE ch.id::text = v_actor_character_id
       AND ch.campaign_id = p_campaign_id
       AND ch.user_id = v_user
       AND m.role = 'PLAYER'
  ) THEN
    RAISE EXCEPTION 'Personagem não pertence ao jogador autenticado.';
  END IF;
  RETURN jsonb_build_object('allowed', true);
END
$damage5$;

GRANT USAGE ON SCHEMA priv TO authenticated;
GRANT EXECUTE ON FUNCTION priv.iniciar_sequencia_ataque_iterativo_srd_5_impl(bigint,text,text,text,uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.consultar_sequencia_ataque_iterativo_pendente_srd(bigint,text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.registrar_rolagem_ataque_iterativo_srd(bigint,uuid,integer,uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.resolver_ataque_iterativo_srd(bigint,uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.confirmar_critico_ataque_iterativo_srd(bigint,uuid,integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid,integer[]) TO authenticated;

CREATE OR REPLACE FUNCTION public.fixture_assert_gm_attack_access(p_sql text, p_should_allow boolean)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER
AS $assert$
DECLARE v_denied boolean := false;
BEGIN
  BEGIN
    EXECUTE p_sql;
  EXCEPTION WHEN OTHERS THEN
    v_denied := true;
  END;
  IF p_should_allow AND v_denied THEN
    RAISE EXCEPTION 'Expected action to be allowed, but it was denied: %', p_sql;
  ELSIF NOT p_should_allow AND NOT v_denied THEN
    RAISE EXCEPTION 'Expected action to be denied, but it was allowed: %', p_sql;
  END IF;
END
$assert$;

GRANT EXECUTE ON FUNCTION public.fixture_assert_gm_attack_access(text, boolean)
  TO authenticated;

\ir ../../supabase/migrations/20261114200000_allow_gm_controlled_iterative_attacks.sql

SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-000000000002';
SELECT public.fixture_assert_gm_attack_access('SELECT priv.iniciar_sequencia_ataque_iterativo_srd_5_impl(987654331,''gm-control-pc-attack'',''target'',''melee'',NULL)', true);
SELECT public.fixture_assert_gm_attack_access('SELECT public.consultar_sequencia_ataque_iterativo_pendente_srd(987654331,''gm-control-pc-attack'')', true);
SELECT public.fixture_assert_gm_attack_access('SELECT public.registrar_rolagem_ataque_iterativo_srd(987654331,''00000000-0000-0000-0000-000000000010'',12,''00000000-0000-0000-0000-000000000011'')', true);
SELECT public.fixture_assert_gm_attack_access('SELECT public.resolver_ataque_iterativo_srd(987654331,''00000000-0000-0000-0000-000000000010'')', true);
SELECT public.fixture_assert_gm_attack_access('SELECT public.confirmar_critico_ataque_iterativo_srd(987654331,''00000000-0000-0000-0000-000000000010'',15)', true);
SELECT public.fixture_assert_gm_attack_access('SELECT public.aplicar_dano_ataque_iterativo_srd(987654331,''00000000-0000-0000-0000-000000000010'',ARRAY[4],''00000000-0000-0000-0000-000000000011'')', true);
SELECT public.fixture_assert_gm_attack_access('SELECT public.aplicar_dano_ataque_iterativo_srd(987654331,''00000000-0000-0000-0000-000000000010'',ARRAY[4],''00000000-0000-0000-0000-000000000011'',ARRAY[2])', true);
RESET ROLE;

SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-000000000001';
SELECT public.fixture_assert_gm_attack_access('SELECT priv.iniciar_sequencia_ataque_iterativo_srd_5_impl(987654331,''gm-control-pc-attack'',''target'',''melee'',NULL)', true);
SELECT public.fixture_assert_gm_attack_access('SELECT public.consultar_sequencia_ataque_iterativo_pendente_srd(987654331,''gm-control-pc-attack'')', true);
SELECT public.fixture_assert_gm_attack_access('SELECT public.registrar_rolagem_ataque_iterativo_srd(987654331,''00000000-0000-0000-0000-000000000010'',12,''00000000-0000-0000-0000-000000000011'')', true);
SELECT public.fixture_assert_gm_attack_access('SELECT public.resolver_ataque_iterativo_srd(987654331,''00000000-0000-0000-0000-000000000010'')', true);
SELECT public.fixture_assert_gm_attack_access('SELECT public.confirmar_critico_ataque_iterativo_srd(987654331,''00000000-0000-0000-0000-000000000010'',15)', true);
SELECT public.fixture_assert_gm_attack_access('SELECT public.aplicar_dano_ataque_iterativo_srd(987654331,''00000000-0000-0000-0000-000000000010'',ARRAY[4],''00000000-0000-0000-0000-000000000011'')', true);
SELECT public.fixture_assert_gm_attack_access('SELECT public.aplicar_dano_ataque_iterativo_srd(987654331,''00000000-0000-0000-0000-000000000010'',ARRAY[4],''00000000-0000-0000-0000-000000000011'',ARRAY[2])', true);
RESET ROLE;

SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-000000000003';
SELECT public.fixture_assert_gm_attack_access('SELECT priv.iniciar_sequencia_ataque_iterativo_srd_5_impl(987654331,''gm-control-pc-attack'',''target'',''melee'',NULL)', false);
SELECT public.fixture_assert_gm_attack_access('SELECT public.consultar_sequencia_ataque_iterativo_pendente_srd(987654331,''gm-control-pc-attack'')', false);
SELECT public.fixture_assert_gm_attack_access('SELECT public.registrar_rolagem_ataque_iterativo_srd(987654331,''00000000-0000-0000-0000-000000000010'',12,''00000000-0000-0000-0000-000000000011'')', false);
SELECT public.fixture_assert_gm_attack_access('SELECT public.resolver_ataque_iterativo_srd(987654331,''00000000-0000-0000-0000-000000000010'')', false);
SELECT public.fixture_assert_gm_attack_access('SELECT public.confirmar_critico_ataque_iterativo_srd(987654331,''00000000-0000-0000-0000-000000000010'',15)', false);
SELECT public.fixture_assert_gm_attack_access('SELECT public.aplicar_dano_ataque_iterativo_srd(987654331,''00000000-0000-0000-0000-000000000010'',ARRAY[4],''00000000-0000-0000-0000-000000000011'')', false);
SELECT public.fixture_assert_gm_attack_access('SELECT public.aplicar_dano_ataque_iterativo_srd(987654331,''00000000-0000-0000-0000-000000000010'',ARRAY[4],''00000000-0000-0000-0000-000000000011'',ARRAY[2])', false);
RESET ROLE;

SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-000000000004';
SELECT public.fixture_assert_gm_attack_access('SELECT priv.iniciar_sequencia_ataque_iterativo_srd_5_impl(987654331,''gm-control-pc-attack'',''target'',''melee'',NULL)', false);
SELECT public.fixture_assert_gm_attack_access('SELECT public.consultar_sequencia_ataque_iterativo_pendente_srd(987654331,''gm-control-pc-attack'')', false);
SELECT public.fixture_assert_gm_attack_access('SELECT public.registrar_rolagem_ataque_iterativo_srd(987654331,''00000000-0000-0000-0000-000000000010'',12,''00000000-0000-0000-0000-000000000011'')', false);
SELECT public.fixture_assert_gm_attack_access('SELECT public.resolver_ataque_iterativo_srd(987654331,''00000000-0000-0000-0000-000000000010'')', false);
SELECT public.fixture_assert_gm_attack_access('SELECT public.confirmar_critico_ataque_iterativo_srd(987654331,''00000000-0000-0000-0000-000000000010'',15)', false);
SELECT public.fixture_assert_gm_attack_access('SELECT public.aplicar_dano_ataque_iterativo_srd(987654331,''00000000-0000-0000-0000-000000000010'',ARRAY[4],''00000000-0000-0000-0000-000000000011'')', false);
SELECT public.fixture_assert_gm_attack_access('SELECT public.aplicar_dano_ataque_iterativo_srd(987654331,''00000000-0000-0000-0000-000000000010'',ARRAY[4],''00000000-0000-0000-0000-000000000011'',ARRAY[2])', false);
RESET ROLE;

DO $ownership$
DECLARE v_owner uuid;
BEGIN
  SELECT user_id INTO v_owner
    FROM public.characters
   WHERE id::text = 'gm-control-pc-attack';
  IF v_owner IS DISTINCT FROM '00000000-0000-0000-0000-000000000002'::uuid THEN
    RAISE EXCEPTION 'GM attack control changed character ownership.';
  END IF;
END
$ownership$;

DROP FUNCTION public.fixture_assert_gm_attack_access(text, boolean);
DROP FUNCTION public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid,integer[]);
DROP FUNCTION public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid);
DROP FUNCTION public.confirmar_critico_ataque_iterativo_srd(bigint,uuid,integer);
DROP FUNCTION public.resolver_ataque_iterativo_srd(bigint,uuid);
DROP FUNCTION public.registrar_rolagem_ataque_iterativo_srd(bigint,uuid,integer,uuid);
DROP FUNCTION public.consultar_sequencia_ataque_iterativo_pendente_srd(bigint,text);
DROP FUNCTION priv.iniciar_sequencia_ataque_iterativo_srd_5_impl(bigint,text,text,text,uuid);
DROP FUNCTION priv.srd_can_control_campaign_character(bigint,text);

DELETE FROM public.characters WHERE campaign_id = 987654331;
DELETE FROM public.members WHERE campaign_id = 987654331;
DELETE FROM public.campaigns WHERE id = 987654331;

SELECT 'GM iterative attack control fixture passed' AS result;
