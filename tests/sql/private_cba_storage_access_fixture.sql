-- Disposable PostgreSQL test for CBA private Storage authorization.
\set ON_ERROR_STOP on

DO $roles$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='authenticated') THEN CREATE ROLE authenticated NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='anon') THEN CREATE ROLE anon NOLOGIN; END IF;
END
$roles$;

CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS storage;
CREATE SCHEMA IF NOT EXISTS priv;
CREATE TABLE IF NOT EXISTS public.campaigns(
  id bigint PRIMARY KEY,
  owner_id uuid,
  cba_data jsonb
);
ALTER TABLE public.campaigns ADD COLUMN IF NOT EXISTS owner_id uuid;
ALTER TABLE public.campaigns ADD COLUMN IF NOT EXISTS cba_data jsonb;
CREATE TABLE IF NOT EXISTS public.members(
  campaign_id bigint NOT NULL,
  user_id uuid NOT NULL,
  role text NOT NULL
);
CREATE TABLE IF NOT EXISTS priv.campaign_deletion_cleanup(campaign_id bigint PRIMARY KEY);
CREATE TABLE IF NOT EXISTS storage.objects(bucket_id text NOT NULL,name text NOT NULL);
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

GRANT USAGE ON SCHEMA public,auth,storage,priv TO authenticated,anon;
GRANT SELECT ON public.campaigns,public.members TO authenticated,anon;
GRANT SELECT,INSERT,UPDATE,DELETE ON storage.objects TO authenticated;
GRANT SELECT ON priv.campaign_deletion_cleanup TO authenticated,anon;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv REVOKE ALL ON TABLES FROM authenticated,anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv REVOKE ALL ON SEQUENCES FROM authenticated,anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv REVOKE EXECUTE ON FUNCTIONS FROM authenticated,anon;

CREATE OR REPLACE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS
$$ SELECT NULLIF(current_setting('request.jwt.claim.sub',true),'')::uuid $$;
CREATE OR REPLACE FUNCTION storage.foldername(p_name text) RETURNS text[] LANGUAGE sql IMMUTABLE AS
$$ SELECT string_to_array(regexp_replace(p_name,'/[^/]+$',''),'/') $$;

INSERT INTO public.campaigns(id,owner_id,cba_data) VALUES
 (41,'11111111-1111-1111-1111-111111111111',
  '{"backgroundPath":"campaigns/41/cba-map.png","tokens":[{"imagemPath":"campaigns/41/tokens/visible.png","visivel":true},{"imagemPath":"campaigns/41/tokens/hidden.png"}]}'::jsonb),
 (42,'22222222-2222-2222-2222-222222222222',
  '{"backgroundPath":"campaigns/42/cba-map.png","tokens":[]}'::jsonb)
ON CONFLICT (id) DO UPDATE SET owner_id=EXCLUDED.owner_id,cba_data=EXCLUDED.cba_data;

INSERT INTO public.members VALUES
 (41,'33333333-3333-3333-3333-333333333333','PLAYER'),
 (41,'44444444-4444-4444-4444-444444444444','GM');

\i supabase/migrations/20261112130000_fix_private_cba_storage_access.sql
\i supabase/verification/verify_private_cba_storage_access.sql

INSERT INTO storage.objects(bucket_id,name) VALUES
 ('mesa-media','campaigns/41/cba-map.png'),
 ('mesa-media','campaigns/41/tokens/visible.png'),
 ('mesa-media','campaigns/41/tokens/hidden.png');

-- A player can read the map and explicitly visible token assets, but not hidden assets.
SET ROLE authenticated;
SET request.jwt.claim.sub='33333333-3333-3333-3333-333333333333';
DO $player$
BEGIN
  IF NOT priv.cba_media_campaign_access('campaigns/41/cba-map.png',false) THEN
    RAISE EXCEPTION 'Campaign player was denied the active map.';
  END IF;
  IF NOT priv.cba_media_campaign_access('campaigns/41/tokens/visible.png',false) THEN
    RAISE EXCEPTION 'Explicitly visible token asset was denied.';
  END IF;
  IF priv.cba_media_campaign_access('campaigns/41/tokens/hidden.png',false) THEN
    RAISE EXCEPTION 'Hidden token asset was exposed to a campaign player.';
  END IF;
  IF priv.cba_media_campaign_access('campaigns/41/tokens/player.png',true) THEN
    RAISE EXCEPTION 'Campaign player was allowed to write a private CBA asset.';
  END IF;
  IF priv.cba_media_campaign_access('campaigns/42/cba-map.png',false) THEN
    RAISE EXCEPTION 'Cross-campaign read was allowed.';
  END IF;
  IF priv.cba_media_campaign_access('campaigns/41/../secret.png',false)
     OR priv.cba_media_campaign_access('campaigns/41//secret.png',false)
     OR priv.cba_media_campaign_access('41/secret.png',false)
     OR priv.cba_media_campaign_access('campaigns/41/folder/',false) THEN
    RAISE EXCEPTION 'Malformed or traversal path was accepted.';
  END IF;
  IF (SELECT count(*) FROM storage.objects WHERE bucket_id='mesa-media') <> 2 THEN
    RAISE EXCEPTION 'RLS did not limit player reads to the map and explicitly visible token asset.';
  END IF;
END
$player$;
RESET ROLE;

-- GM can read all campaign assets and upload.
SET ROLE authenticated;
SET request.jwt.claim.sub='44444444-4444-4444-4444-444444444444';
DO $gm$
BEGIN
  IF NOT priv.cba_media_campaign_access('campaigns/41/tokens/hidden.png',false)
     OR NOT priv.cba_media_campaign_access('campaigns/41/cba-map.png',true) THEN
    RAISE EXCEPTION 'Campaign GM was denied authorized access.';
  END IF;
END
$gm$;
INSERT INTO storage.objects(bucket_id,name)
VALUES ('mesa-media','campaigns/41/tokens/gm-upload.png');
RESET ROLE;

-- Cleanup marker blocks reads and new writes, but GM deletion remains possible.
INSERT INTO priv.campaign_deletion_cleanup VALUES (41);
SET ROLE authenticated;
SET request.jwt.claim.sub='33333333-3333-3333-3333-333333333333';
DO $cleanup_player$
BEGIN
  IF priv.cba_media_campaign_access('campaigns/41/cba-map.png',false) THEN
    RAISE EXCEPTION 'Player retained read access during cleanup.';
  END IF;
END
$cleanup_player$;
RESET ROLE;

SET ROLE authenticated;
SET request.jwt.claim.sub='11111111-1111-1111-1111-111111111111';
DO $cleanup_owner$
BEGIN
  IF NOT priv.cba_media_campaign_access('campaigns/41/cba-map.png',false) THEN
    RAISE EXCEPTION 'Owner lost read access needed to enumerate assets during cleanup.';
  END IF;
  IF priv.cba_media_campaign_access('campaigns/41/cba-map.png',true,false) THEN
    RAISE EXCEPTION 'Owner was allowed a new upload during cleanup.';
  END IF;
  IF NOT priv.cba_media_campaign_access('campaigns/41/cba-map.png',true,true) THEN
    RAISE EXCEPTION 'Campaign owner could not delete assets during cleanup.';
  END IF;
END
$cleanup_owner$;
RESET ROLE;

SET ROLE authenticated;
SET request.jwt.claim.sub='44444444-4444-4444-4444-444444444444';
DELETE FROM storage.objects WHERE name='campaigns/41/tokens/hidden.png';
RESET ROLE;
DO $deleted$
BEGIN
  IF EXISTS (SELECT 1 FROM storage.objects WHERE name='campaigns/41/tokens/hidden.png') THEN
    RAISE EXCEPTION 'GM could not delete hidden asset during cleanup.';
  END IF;
END
$deleted$;

SELECT 'private CBA Storage fixture passed' AS result;
