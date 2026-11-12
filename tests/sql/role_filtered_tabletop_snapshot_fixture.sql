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
INSERT INTO public.campaigns(id,name,owner_id,cba_data,combat_data)
VALUES (987654321,'Fixture','00000000-0000-0000-0000-000000000001',
'{"backgroundPath":"campaigns/1/map.png","tokens":[
 {"id":"pc-1","sourceCharacterId":"pc-1","nome":"Meu herói"},
 {"id":"enemy-hidden","nome":"Inimigo oculto","visivel":false},
 {"id":"npc-visible","nome":"Aliado visível","visivel":true}
]}',
'{"active":true,"round":2,"current_turn":1,
 "turn_order":[{"id":"pc-1"},{"id":"enemy-hidden","secret":"hidden"},{"id":"npc-visible"}],
 "pending_reactions":[{"secret":"private"}],"action_economy":{"secret":"private"}}');
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
SELECT set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000002',true);
DO $$
DECLARE s jsonb;
BEGIN
  s := public.obter_snapshot_seguro_mesa(987654321);
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
  s := public.obter_snapshot_seguro_mesa(987654321);
  IF s->>'viewer_is_gm' <> 'true' THEN RAISE EXCEPTION 'owner should receive GM snapshot'; END IF;
  IF NOT (s->'cba_data'->'tokens' @> '[{"id":"enemy-hidden"}]'::jsonb) THEN RAISE EXCEPTION 'GM snapshot lost hidden token'; END IF;
  IF NOT (s->'combat_data' ? 'pending_reactions') THEN RAISE EXCEPTION 'GM snapshot lost private combat data'; END IF;
END $$;
RESET ROLE;

DELETE FROM public.characters WHERE campaign_id=987654321;
DELETE FROM public.members WHERE campaign_id=987654321;
DELETE FROM public.campaigns WHERE id=987654321;
