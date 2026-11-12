\set ON_ERROR_STOP on
BEGIN;

CREATE SCHEMA IF NOT EXISTS auth;
CREATE OR REPLACE FUNCTION auth.uid() RETURNS uuid
LANGUAGE sql STABLE
AS $$ SELECT nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;

CREATE TABLE public.campaigns (
  id bigint PRIMARY KEY, name text NOT NULL, owner_id uuid NOT NULL,
  state text NOT NULL DEFAULT 'EXPLORACAO', active boolean NOT NULL DEFAULT true,
  location_id bigint, briefing text, capa_url text, capa_transform jsonb,
  cba_data jsonb, combat_data jsonb
);
CREATE TABLE public.members(campaign_id bigint, user_id uuid, role text);
CREATE TABLE public.characters(id text, campaign_id bigint, user_id uuid);

INSERT INTO public.campaigns(id,name,owner_id,cba_data,combat_data)
VALUES (1,'Fixture','00000000-0000-0000-0000-000000000001',
'{"backgroundPath":"campaigns/1/map.png","tokens":[
 {"id":"pc-1","sourceCharacterId":"pc-1","nome":"Meu herói"},
 {"id":"enemy-hidden","nome":"Inimigo oculto","visivel":false},
 {"id":"npc-visible","nome":"Aliado visível","visivel":true}
]}',
'{"active":true,"round":2,"current_turn":1,
 "turn_order":[{"id":"pc-1"},{"id":"enemy-hidden","secret":"hidden"},{"id":"npc-visible"}],
 "pending_reactions":[{"secret":"private"}],"action_economy":{"secret":"private"}}');
INSERT INTO public.members VALUES
 (1,'00000000-0000-0000-0000-000000000001','GM'),
 (1,'00000000-0000-0000-0000-000000000002','PLAYER');
INSERT INTO public.characters VALUES ('pc-1',1,'00000000-0000-0000-0000-000000000002');

GRANT USAGE ON SCHEMA public, priv, auth TO authenticated;
GRANT SELECT ON public.campaigns, public.members, public.characters TO postgres;
GRANT EXECUTE ON FUNCTION auth.uid() TO authenticated;

\ir ../../supabase/migrations/20261112140000_add_role_filtered_tabletop_snapshot.sql

SET ROLE authenticated;
SELECT set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000002',true);
DO $$
DECLARE s jsonb;
BEGIN
  s := public.obter_snapshot_seguro_mesa(1);
  IF s->>'viewer_is_gm' <> 'false' THEN RAISE EXCEPTION 'player incorrectly classified as GM'; END IF;
  IF s->'cba_data'->'tokens' @> '[{"id":"enemy-hidden"}]'::jsonb THEN RAISE EXCEPTION 'hidden token leaked'; END IF;
  IF NOT (s->'cba_data'->'tokens' @> '[{"id":"pc-1"}]'::jsonb) THEN RAISE EXCEPTION 'owned token missing'; END IF;
  IF NOT (s->'cba_data'->'tokens' @> '[{"id":"npc-visible"}]'::jsonb) THEN RAISE EXCEPTION 'visible token missing'; END IF;
  IF s->'combat_data' ? 'pending_reactions' OR s->'combat_data' ? 'action_economy' THEN RAISE EXCEPTION 'private combat internals leaked'; END IF;
  IF s->'combat_data'->'turn_order' @> '[{"id":"enemy-hidden"}]'::jsonb THEN RAISE EXCEPTION 'hidden initiative actor leaked'; END IF;
END $$;
RESET ROLE;

SET ROLE authenticated;
SELECT set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000001',true);
DO $$
DECLARE s jsonb;
BEGIN
  s := public.obter_snapshot_seguro_mesa(1);
  IF s->>'viewer_is_gm' <> 'true' THEN RAISE EXCEPTION 'owner should receive GM snapshot'; END IF;
  IF NOT (s->'cba_data'->'tokens' @> '[{"id":"enemy-hidden"}]'::jsonb) THEN RAISE EXCEPTION 'GM snapshot lost hidden token'; END IF;
  IF NOT (s->'combat_data' ? 'pending_reactions') THEN RAISE EXCEPTION 'GM snapshot lost private combat data'; END IF;
END $$;
RESET ROLE;

ROLLBACK;
