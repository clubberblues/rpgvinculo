\set ON_ERROR_STOP on

DO $role$ BEGIN CREATE ROLE authenticated; EXCEPTION WHEN duplicate_object THEN NULL; END $role$;
DO $role$ BEGIN CREATE ROLE anon; EXCEPTION WHEN duplicate_object THEN NULL; END $role$;
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS priv;
CREATE SCHEMA IF NOT EXISTS realtime;

CREATE TABLE IF NOT EXISTS realtime.messages(
  id bigserial PRIMARY KEY,
  topic text NOT NULL,
  extension text NOT NULL,
  payload jsonb,
  event text,
  private boolean DEFAULT false
);
ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;
GRANT USAGE ON SCHEMA realtime,auth,priv TO authenticated,anon;
GRANT SELECT ON realtime.messages TO authenticated;

CREATE OR REPLACE FUNCTION realtime.topic() RETURNS text
LANGUAGE sql STABLE
AS $$ SELECT current_setting('realtime.topic',true) $$;
CREATE OR REPLACE FUNCTION realtime.send(payload jsonb,event text,topic text,private boolean)
RETURNS void LANGUAGE sql SECURITY INVOKER
AS $$ INSERT INTO realtime.messages(topic,extension,payload,event,private)
      VALUES ($3,'broadcast',$1,$2,$4) $$;
CREATE OR REPLACE FUNCTION public.sou_membro(cid bigint) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path=pg_catalog,public,auth
AS $$ SELECT EXISTS(SELECT 1 FROM public.members m WHERE m.campaign_id=cid AND m.user_id=auth.uid()) $$;
GRANT EXECUTE ON FUNCTION auth.uid() TO authenticated;
GRANT EXECUTE ON FUNCTION realtime.topic() TO authenticated;
GRANT EXECUTE ON FUNCTION public.sou_membro(bigint) TO authenticated;

DELETE FROM public.campaigns WHERE id=987654322;
DELETE FROM public.members WHERE campaign_id=987654322;
INSERT INTO public.campaigns(id,name,owner_id,state,active,cba_data,combat_data)
VALUES(987654322,'Broadcast fixture','00000000-0000-0000-0000-000000000001','EXPLORACAO',true,'{"tokens":[]}','{}');
INSERT INTO public.members VALUES(987654322,'00000000-0000-0000-0000-000000000002','PLAYER');

\ir ../../supabase/migrations/20261112150000_broadcast_campaign_refresh.sql

UPDATE public.campaigns SET cba_data='{"tokens":[{"id":"hidden","secret":"must-not-broadcast"}]}',
 combat_data='{"action_economy":{"secret":"must-not-broadcast"}}' WHERE id=987654322;

DO $assert$
DECLARE m realtime.messages%ROWTYPE;
BEGIN
  SELECT * INTO m FROM realtime.messages WHERE topic='campaign:987654322' AND event='campaign_refresh';
  IF NOT FOUND THEN RAISE EXCEPTION 'campaign refresh broadcast was not written'; END IF;
  IF m.private IS DISTINCT FROM true THEN RAISE EXCEPTION 'campaign refresh channel is not private'; END IF;
  IF m.payload <> jsonb_build_object('campaign_id',987654322) THEN
    RAISE EXCEPTION 'broadcast leaked state beyond campaign id: %',m.payload;
  END IF;
  IF m.payload ? 'cba_data' OR m.payload ? 'combat_data' THEN
    RAISE EXCEPTION 'private campaign JSON leaked into broadcast payload';
  END IF;
END
$assert$;

SET ROLE authenticated;
SET request.jwt.claim.sub='00000000-0000-0000-0000-000000000002';
SET realtime.topic='campaign:987654322';
DO $player$
BEGIN
  IF (SELECT count(*) FROM realtime.messages WHERE topic='campaign:987654322') <> 1 THEN
    RAISE EXCEPTION 'campaign member cannot receive private refresh broadcast';
  END IF;
END
$player$;
RESET ROLE;

SET ROLE authenticated;
SET request.jwt.claim.sub='00000000-0000-0000-0000-000000000003';
SET realtime.topic='campaign:987654322';
DO $external$
BEGIN
  IF (SELECT count(*) FROM realtime.messages WHERE topic='campaign:987654322') <> 0 THEN
    RAISE EXCEPTION 'external user can receive campaign refresh broadcast';
  END IF;
END
$external$;
RESET ROLE;

DELETE FROM public.members WHERE campaign_id=987654322;
DELETE FROM public.campaigns WHERE id=987654322;
