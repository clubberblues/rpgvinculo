\set ON_ERROR_STOP on
DO $role$ BEGIN CREATE ROLE authenticated; EXCEPTION WHEN duplicate_object THEN NULL; END $role$;
DO $role$ BEGIN CREATE ROLE anon; EXCEPTION WHEN duplicate_object THEN NULL; END $role$;
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS priv;
CREATE OR REPLACE FUNCTION auth.uid() RETURNS uuid
LANGUAGE sql STABLE
AS $$ SELECT nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;

CREATE TABLE IF NOT EXISTS public.campaigns (id bigint PRIMARY KEY, cba_data jsonb);
ALTER TABLE public.campaigns ADD COLUMN IF NOT EXISTS name text;
ALTER TABLE public.campaigns ADD COLUMN IF NOT EXISTS owner_id uuid;
ALTER TABLE public.campaigns ADD COLUMN IF NOT EXISTS state text;
ALTER TABLE public.campaigns ADD COLUMN IF NOT EXISTS active boolean;
ALTER TABLE public.campaigns ADD COLUMN IF NOT EXISTS location_id bigint;
ALTER TABLE public.campaigns ADD COLUMN IF NOT EXISTS briefing text;
ALTER TABLE public.campaigns ADD COLUMN IF NOT EXISTS capa_url text;
ALTER TABLE public.campaigns ADD COLUMN IF NOT EXISTS capa_transform jsonb;
ALTER TABLE public.campaigns ADD COLUMN IF NOT EXISTS combat_data jsonb;
CREATE TABLE IF NOT EXISTS public.members(campaign_id bigint, user_id uuid, role text);
CREATE TABLE IF NOT EXISTS public.characters(id text, campaign_id bigint, user_id uuid);
ALTER TABLE public.characters ADD COLUMN IF NOT EXISTS campaign_id bigint;
ALTER TABLE public.characters ADD COLUMN IF NOT EXISTS user_id uuid;

DELETE FROM public.characters WHERE campaign_id=987654321;
DELETE FROM public.members WHERE campaign_id=987654321;
DELETE FROM public.campaigns WHERE id=987654321;
INSERT INTO public.campaigns(id,name,owner_id,briefing,cba_data,combat_data)
VALUES (987654321,'Fixture','00000000-0000-0000-0000-000000000001','GM-only briefing',
'{"backgroundPath":"campaigns/987654321/map.png","fogEnabled":true,"gm_secret":"only-for-gm","tokens":[
 {"id":"pc-1","sourceCharacterId":"pc-1","nome":"Meu herói"},
 {"id":"enemy-hidden","nome":"Inimigo oculto","visivel":false},
 {"id":"npc-visible","nome":"Aliado visível","visivel":true,"internal_token_secret":"only-for-gm"}
]}',
'{"active":true,"round":2,"current_turn":1,
 "turn_order":[{"id":"pc-1"},{"id":"enemy-hidden","secret":"hidden"},{"id":"npc-visible","nome":"Aliado visível","valor":12,"secret":"visible-actor-secret"}],
 "expected_character_ids":["pc-1","enemy-hidden"],
 "action_economy":{"round":2,"by_character":{"pc-1":{"padrao":true},"enemy-hidden":{"rapida":true}}},
 "movement_usage":{"character_id":"pc-1","round":2,"current_turn":0,"moved_squares":2},
 "pending_reactions":[{"secret":"private"}],"private_engine_state":{"secret":"private"}}');
INSERT INTO public.members VALUES
 (987654321,'00000000-0000-0000-0000-000000000001','GM'),
 (987654321,'00000000-0000-0000-0000-000000000002','PLAYER');
INSERT INTO public.characters(id,campaign_id,user_id) VALUES ('pc-1',987654321,'00000000-0000-0000-0000-000000000002');

GRANT USAGE ON SCHEMA public, priv, auth TO authenticated;
GRANT SELECT ON public.campaigns, public.members, public.characters TO postgres;
GRANT EXECUTE ON FUNCTION auth.uid() TO authenticated;

\ir ../../supabase/migrations/20261112140000_add_role_filtered_tabletop_snapshot.sql

DO $privilege$
BEGIN
  IF has_function_privilege('anon','public.obter_snapshot_seguro_mesa(bigint)','EXECUTE') THEN
    RAISE EXCEPTION 'anon can execute the tabletop snapshot RPC';
  END IF;
END
$privilege$;

SET ROLE authenticated;
SET request.jwt.claim.sub='00000000-0000-0000-0000-000000000002';
DO $$
DECLARE s jsonb;
BEGIN
  s := public.obter_snapshot_seguro_mesa(987654321);
  IF s->>'viewer_is_gm' <> 'false' THEN RAISE EXCEPTION 'player incorrectly classified as GM'; END IF;
  IF s->'cba_data'->'tokens' @> '[{"id":"enemy-hidden"}]'::jsonb THEN RAISE EXCEPTION 'hidden token leaked'; END IF;
  IF NOT (s->'cba_data'->'tokens' @> '[{"id":"pc-1"}]'::jsonb) THEN RAISE EXCEPTION 'owned token missing'; END IF;
  IF NOT (s->'cba_data'->'tokens' @> '[{"id":"npc-visible"}]'::jsonb) THEN RAISE EXCEPTION 'visible token missing'; END IF;
  IF s->'cba_data' ? 'backgroundPath' THEN RAISE EXCEPTION 'full fogged map path leaked to player'; END IF;
  IF s->'cba_data' ? 'gm_secret' THEN RAISE EXCEPTION 'unknown GM-only scene metadata leaked'; END IF;
  IF s->'campaign' ? 'briefing' THEN RAISE EXCEPTION 'GM-only campaign briefing leaked'; END IF;
  IF (s->'combat_data'->'turn_order'->1) ? 'secret' THEN RAISE EXCEPTION 'unknown initiative metadata leaked'; END IF;
  IF (s->'cba_data'->'tokens'->1) ? 'internal_token_secret' THEN RAISE EXCEPTION 'unknown GM-only token metadata leaked'; END IF;
  IF s->'combat_data' ? 'pending_reactions' OR s->'combat_data' ? 'private_engine_state' THEN RAISE EXCEPTION 'private combat internals leaked'; END IF;
  IF s->'combat_data'->'action_economy'->'by_character' ? 'enemy-hidden' THEN RAISE EXCEPTION 'another character action flags leaked'; END IF;
  IF NOT (s->'combat_data'->'action_economy'->'by_character' ? 'pc-1') THEN RAISE EXCEPTION 'owned character action flags missing'; END IF;
  IF s->'combat_data'->'expected_character_ids' @> '["enemy-hidden"]'::jsonb THEN RAISE EXCEPTION 'another character initiative request leaked'; END IF;
  IF NOT (s->'combat_data'->'expected_character_ids' @> '["pc-1"]'::jsonb) THEN RAISE EXCEPTION 'owned initiative request missing'; END IF;
  IF s->'combat_data'->'movement_usage'->>'character_id' <> 'pc-1' OR s->'combat_data'->'movement_usage'->>'moved_squares' <> '2' THEN RAISE EXCEPTION 'owned movement preview missing'; END IF;
  IF s->'combat_data'->'turn_order' @> '[{"id":"enemy-hidden"}]'::jsonb THEN RAISE EXCEPTION 'hidden initiative actor leaked'; END IF;
END $$;
RESET ROLE;

SET ROLE authenticated;
SET request.jwt.claim.sub='00000000-0000-0000-0000-000000000001';
DO $$
DECLARE s jsonb;
BEGIN
  s := public.obter_snapshot_seguro_mesa(987654321);
  IF s->>'viewer_is_gm' <> 'true' THEN RAISE EXCEPTION 'owner should receive GM snapshot'; END IF;
  IF NOT (s->'cba_data'->'tokens' @> '[{"id":"enemy-hidden"}]'::jsonb) THEN RAISE EXCEPTION 'GM snapshot lost hidden token'; END IF;
  IF s->'cba_data'->>'gm_secret' <> 'only-for-gm' THEN RAISE EXCEPTION 'GM snapshot lost private scene metadata'; END IF;
  IF NOT (s->'cba_data'->'tokens' @> '[{"id":"npc-visible","internal_token_secret":"only-for-gm"}]'::jsonb) THEN RAISE EXCEPTION 'GM snapshot lost private token metadata'; END IF;
  IF s->'cba_data'->>'backgroundPath' <> 'campaigns/987654321/map.png' THEN RAISE EXCEPTION 'GM snapshot lost map path'; END IF;
  IF NOT (s->'combat_data' ? 'pending_reactions') THEN RAISE EXCEPTION 'GM snapshot lost private combat data'; END IF;
  IF NOT (s->'combat_data'->'action_economy'->'by_character' ? 'enemy-hidden') THEN RAISE EXCEPTION 'GM snapshot lost other character action flags'; END IF;
END $$;
RESET ROLE;

DELETE FROM public.characters WHERE campaign_id=987654321;
DELETE FROM public.members WHERE campaign_id=987654321;
DELETE FROM public.campaigns WHERE id=987654321;
