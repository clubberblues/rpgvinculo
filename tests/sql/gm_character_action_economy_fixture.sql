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

DELETE FROM public.characters WHERE campaign_id = 987654330;
DELETE FROM public.members WHERE campaign_id = 987654330;
DELETE FROM public.campaigns WHERE id = 987654330;

INSERT INTO public.campaigns(id, name, owner_id)
VALUES (987654330, 'GM action-economy fixture', '00000000-0000-0000-0000-000000000001');

INSERT INTO public.members(campaign_id, user_id, role) VALUES
  (987654330, '00000000-0000-0000-0000-000000000001', 'GM'),
  (987654330, '00000000-0000-0000-0000-000000000002', 'PLAYER'),
  (987654330, '00000000-0000-0000-0000-000000000003', 'PLAYER');

INSERT INTO public.characters(id, campaign_id, user_id)
VALUES ('gm-control-pc-1', 987654330, '00000000-0000-0000-0000-000000000002');

CREATE OR REPLACE FUNCTION priv.consumir_acao_turno_srd(
  p_campaign_id bigint,
  p_character_id text,
  p_acao text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, priv, pg_temp
AS $action_impl$
BEGIN
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

  RETURN jsonb_build_object('allowed', true, 'character_id', p_character_id);
END
$action_impl$;

CREATE OR REPLACE FUNCTION public.consumir_acao_turno_srd(
  p_campaign_id bigint,
  p_character_id text,
  p_acao text
)
RETURNS jsonb
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, priv, pg_temp
AS $action_wrapper$
  SELECT priv.consumir_acao_turno_srd(p_campaign_id, p_character_id, p_acao)
$action_wrapper$;

GRANT EXECUTE ON FUNCTION public.consumir_acao_turno_srd(bigint, text, text)
  TO authenticated;

\ir ../../supabase/migrations/20261114190000_allow_gm_character_action_economy.sql

SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-000000000002';
DO $owner$
DECLARE r jsonb;
BEGIN
  r := public.consumir_acao_turno_srd(987654330, 'gm-control-pc-1', 'padrao');
  IF r->>'allowed' IS DISTINCT FROM 'true' THEN
    RAISE EXCEPTION 'Character owner lost action-economy permission.';
  END IF;
END
$owner$;
RESET ROLE;

SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-000000000001';
DO $gm$
DECLARE r jsonb;
BEGIN
  r := public.consumir_acao_turno_srd(987654330, 'gm-control-pc-1', 'padrao');
  IF r->>'allowed' IS DISTINCT FROM 'true' THEN
    RAISE EXCEPTION 'Campaign GM could not operate the player character action economy.';
  END IF;
END
$gm$;
RESET ROLE;

SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-000000000003';
DO $other$
DECLARE v_denied boolean := false;
BEGIN
  BEGIN
    PERFORM public.consumir_acao_turno_srd(987654330, 'gm-control-pc-1', 'padrao');
  EXCEPTION WHEN OTHERS THEN
    v_denied := true;
  END;
  IF NOT v_denied THEN
    RAISE EXCEPTION 'Another player was allowed to operate a character they do not own.';
  END IF;
END
$other$;
RESET ROLE;

SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-000000000004';
DO $outsider$
DECLARE v_denied boolean := false;
BEGIN
  BEGIN
    PERFORM public.consumir_acao_turno_srd(987654330, 'gm-control-pc-1', 'padrao');
  EXCEPTION WHEN OTHERS THEN
    v_denied := true;
  END;
  IF NOT v_denied THEN
    RAISE EXCEPTION 'An external user was allowed to operate a campaign character.';
  END IF;
END
$outsider$;
RESET ROLE;

DO $ownership$
DECLARE v_owner uuid;
BEGIN
  SELECT user_id INTO v_owner
    FROM public.characters
   WHERE id::text = 'gm-control-pc-1';
  IF v_owner IS DISTINCT FROM '00000000-0000-0000-0000-000000000002'::uuid THEN
    RAISE EXCEPTION 'GM control changed character ownership.';
  END IF;
END
$ownership$;

DELETE FROM public.characters WHERE campaign_id = 987654330;
DELETE FROM public.members WHERE campaign_id = 987654330;
DELETE FROM public.campaigns WHERE id = 987654330;

SELECT 'GM action-economy control fixture passed' AS result;
