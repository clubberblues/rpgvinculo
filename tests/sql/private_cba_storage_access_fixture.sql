-- Disposable PostgreSQL test for CBA private Storage authorization.
\set ON_ERROR_STOP on
CREATE ROLE authenticated NOLOGIN;
CREATE ROLE anon NOLOGIN;
CREATE SCHEMA auth;
CREATE SCHEMA storage;
CREATE SCHEMA priv;
CREATE TABLE public.campaigns(id bigint PRIMARY KEY, owner_id uuid NOT NULL);
CREATE TABLE public.members(campaign_id bigint NOT NULL,user_id uuid NOT NULL,role text NOT NULL);
CREATE TABLE priv.campaign_deletion_cleanup(campaign_id bigint PRIMARY KEY);
CREATE TABLE storage.objects(bucket_id text NOT NULL,name text NOT NULL);
GRANT USAGE ON SCHEMA public,auth,storage,priv TO authenticated,anon;
GRANT SELECT ON public.campaigns,public.members TO authenticated,anon;
GRANT SELECT,INSERT,UPDATE,DELETE ON storage.objects TO authenticated;
GRANT SELECT ON priv.campaign_deletion_cleanup TO authenticated,anon;

CREATE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS
$$ SELECT NULLIF(current_setting('request.jwt.claim.sub',true),'')::uuid $$;
CREATE FUNCTION storage.foldername(p_name text) RETURNS text[] LANGUAGE sql IMMUTABLE AS
$$ SELECT string_to_array(regexp_replace(p_name,'/[^/]+$',''),'/') $$;

INSERT INTO public.campaigns(id,owner_id,cba_data) VALUES
 (41,'11111111-1111-1111-1111-111111111111',
  '{"backgroundPath":"campaigns/41/cba-map.png","tokens":[{"imagemPath":"campaigns/41/tokens/visible.png","visivel":true},{"imagemPath":"campaigns/41/tokens/hidden.png"}]}'::jsonb),
 (42,'22222222-2222-2222-2222-222222222222',
  '{"backgroundPath":"campaigns/42/cba-map.png","tokens":[]}'::jsonb);
INSERT INTO public.members VALUES
 (41,'33333333-3333-3333-3333-333333333333','PLAYER'),
 (41,'44444444-4444-4444-4444-444444444444','GM');

ALTER DEFAULT PRIVILEGES FOR ROLE postgres REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv REVOKE ALL ON TABLES FROM authenticated,anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv REVOKE ALL ON SEQUENCES FROM authenticated,anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv REVOKE EXECUTE ON FUNCTIONS FROM authenticated,anon;

\i supabase/migrations/20261112130000_fix_private_cba_storage_access.sql
\i supabase/verification/verify_private_cba_storage_access.sql

-- A player may read campaign assets, but cannot write or delete.
SET ROLE authenticated;
SET request.jwt.claim.sub='33333333-3333-3333-3333-333333333333';
DO $player$
BEGIN
  IF NOT priv.cba_media_campaign_access('campaigns/41/tokens/player.png',false) THEN
    RAISE EXCEPTION 'Campaign player was denied a published campaign asset.';
  END IF;
  IF priv.cba_media_campaign_access('campaigns/41/tokens/player.png',true) THEN
    RAISE EXCEPTION 'Campaign player was allowed to write a private CBA asset.';
  END IF;
  IF priv.cba_media_campaign_access('campaigns/42/tokens/other.png',false) THEN
    RAISE EXCEPTION 'Cross-campaign read was allowed.';
  END IF;
  IF priv.cba_media_campaign_access('campaigns/41/../secret.png',false)
     OR priv.cba_media_campaign_access('campaigns/41//secret.png',false)
     OR priv.cba_media_campaign_access('41/secret.png',false) THEN
    RAISE EXCEPTION 'Malformed or traversal path was accepted.';
  END IF;
END
$player$;
RESET ROLE;

SET ROLE authenticated;
SET request.jwt.claim.sub='44444444-4444-4444-4444-444444444444';
DO $gm$
BEGIN
  IF NOT priv.cba_media_campaign_access('campaigns/41/cba-map.png',true) THEN
    RAISE EXCEPTION 'Campaign GM was denied write access.';
  END IF;
END
$gm$;
RESET ROLE;

INSERT INTO priv.campaign_deletion_cleanup VALUES (41);
SET ROLE authenticated;
SET request.jwt.claim.sub='11111111-1111-1111-1111-111111111111';
DO $cleanup$
BEGIN
  IF priv.cba_media_campaign_access('campaigns/41/cba-map.png',false)
     OR priv.cba_media_campaign_access('campaigns/41/cba-map.png',true) THEN
    RAISE EXCEPTION 'Campaign asset access remained open during cleanup.';
  END IF;
END
$cleanup$;
RESET ROLE;
SELECT 'private CBA Storage fixture passed' AS result;
