\set ON_ERROR_STOP on

CREATE OR REPLACE FUNCTION public.my_role(p_campaign_id bigint)
RETURNS text
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $role_fixture$
  SELECT m.role
    FROM public.members m
   WHERE m.campaign_id=p_campaign_id
     AND m.user_id=auth.uid()
   LIMIT 1
$role_fixture$;

DELETE FROM public.characters WHERE campaign_id=987654329;
DELETE FROM public.members WHERE campaign_id=987654329;
DELETE FROM public.campaigns WHERE id=987654329;

INSERT INTO public.campaigns(id,name,owner_id)
VALUES (987654329,'GM long-rest fixture','00000000-0000-0000-0000-000000000001');
INSERT INTO public.members(campaign_id,user_id,role) VALUES
  (987654329,'00000000-0000-0000-0000-000000000001','GM'),
  (987654329,'00000000-0000-0000-0000-000000000002','PLAYER'),
  (987654329,'00000000-0000-0000-0000-000000000003','PLAYER');
INSERT INTO public.characters(id,campaign_id,user_id)
VALUES ('rest-pc-1',987654329,'00000000-0000-0000-0000-000000000002');

CREATE OR REPLACE FUNCTION public.descanso_longo_personagem_srd(
  p_campaign_id bigint,
  p_character_id text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $rest_fixture$
DECLARE
  v_owner uuid;
  v_campaign bigint;
BEGIN
  SELECT c.user_id,c.campaign_id INTO v_owner,v_campaign
    FROM public.characters c
   WHERE c.id::text=BTRIM(p_character_id)
   FOR UPDATE;
  IF NOT FOUND OR v_campaign IS DISTINCT FROM p_campaign_id THEN
    RAISE EXCEPTION 'Personagem não encontrado nesta campanha.';
  END IF;
  IF v_owner IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'Somente o dono da ficha pode realizar descanso.';
  END IF;
  RETURN jsonb_build_object('rested',true,'campaign_id',p_campaign_id,'character_id',p_character_id);
END
$rest_fixture$;

\ir ../../supabase/migrations/20261112170000_allow_gm_controlled_character_rest.sql

SET ROLE authenticated;
SET request.jwt.claim.sub='00000000-0000-0000-0000-000000000001';
DO $gm$
DECLARE r jsonb;
BEGIN
  r:=public.descanso_longo_personagem_srd(987654329,'rest-pc-1');
  IF r->>'rested' IS DISTINCT FROM 'true' THEN
    RAISE EXCEPTION 'Campaign GM could not administer long rest for a player character.';
  END IF;
END
$gm$;
RESET ROLE;

SET ROLE authenticated;
SET request.jwt.claim.sub='00000000-0000-0000-0000-000000000002';
DO $owner$
DECLARE r jsonb;
BEGIN
  r:=public.descanso_longo_personagem_srd(987654329,'rest-pc-1');
  IF r->>'rested' IS DISTINCT FROM 'true' THEN
    RAISE EXCEPTION 'Character owner lost long-rest permission.';
  END IF;
END
$owner$;
RESET ROLE;

SET ROLE authenticated;
SET request.jwt.claim.sub='00000000-0000-0000-0000-000000000003';
DO $other$
DECLARE v_denied boolean:=false;
BEGIN
  BEGIN
    PERFORM public.descanso_longo_personagem_srd(987654329,'rest-pc-1');
  EXCEPTION WHEN OTHERS THEN
    v_denied:=true;
  END;
  IF NOT v_denied THEN
    RAISE EXCEPTION 'Another player was allowed to administer long rest for a character they do not own.';
  END IF;
END
$other$;
RESET ROLE;

SET ROLE authenticated;
SET request.jwt.claim.sub='00000000-0000-0000-0000-000000000004';
DO $outsider$
DECLARE v_denied boolean:=false;
BEGIN
  BEGIN
    PERFORM public.descanso_longo_personagem_srd(987654329,'rest-pc-1');
  EXCEPTION WHEN OTHERS THEN
    v_denied:=true;
  END;
  IF NOT v_denied THEN
    RAISE EXCEPTION 'Non-member was allowed to administer long rest.';
  END IF;
END
$outsider$;
RESET ROLE;

DELETE FROM public.characters WHERE campaign_id=987654329;
DELETE FROM public.members WHERE campaign_id=987654329;
DELETE FROM public.campaigns WHERE id=987654329;

SELECT 'GM long-rest control fixture passed' AS result;
