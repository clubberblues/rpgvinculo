\set ON_ERROR_STOP on
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS priv;
CREATE OR REPLACE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS $uid$
 SELECT NULLIF(current_setting('request.jwt.claim.sub',true),'')::uuid
$uid$;
CREATE OR REPLACE FUNCTION public.my_role(cid bigint) RETURNS text LANGUAGE sql STABLE SECURITY DEFINER
SET search_path=public,pg_temp AS $role$
 SELECT m.role FROM public.members m WHERE m.campaign_id=cid AND m.user_id=auth.uid() LIMIT 1
$role$;
CREATE OR REPLACE FUNCTION priv.srd_can_control_campaign_character(p_campaign_id bigint,p_character_id text)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO 'pg_catalog','public','priv','pg_temp' AS $control$
 SELECT p_campaign_id IS NOT NULL AND NULLIF(BTRIM(p_character_id),'') IS NOT NULL
 AND EXISTS(SELECT 1 FROM public.characters ch WHERE ch.campaign_id=p_campaign_id AND ch.id::text=BTRIM(p_character_id)
 AND ((ch.user_id=auth.uid() AND UPPER(COALESCE(public.my_role(p_campaign_id),''))='PLAYER')
 OR UPPER(COALESCE(public.my_role(p_campaign_id),''))='GM'
 OR EXISTS(SELECT 1 FROM public.campaigns c WHERE c.id=p_campaign_id AND c.owner_id=auth.uid())))
$control$;
GRANT USAGE ON SCHEMA priv TO authenticated;
DELETE FROM public.characters WHERE campaign_id=987654332;
DELETE FROM public.members WHERE campaign_id=987654332;
DELETE FROM public.campaigns WHERE id=987654332;
INSERT INTO public.campaigns(id,name,owner_id) VALUES(987654332,'GM direct attack fixture','00000000-0000-0000-0000-000000000001');
INSERT INTO public.members(campaign_id,user_id,role) VALUES
 (987654332,'00000000-0000-0000-0000-000000000001','GM'),
 (987654332,'00000000-0000-0000-0000-000000000002','PLAYER'),
 (987654332,'00000000-0000-0000-0000-000000000003','PLAYER');
INSERT INTO public.characters(id,campaign_id,user_id) VALUES('gm-control-pc-direct',987654332,'00000000-0000-0000-0000-000000000002');
CREATE OR REPLACE FUNCTION public.aplicar_dano_token_ataque_srd_v2(
 p_campaign_id bigint,p_character_id text,p_token_id text,p_d20 integer,p_bonus_ataque integer,p_dano integer,p_weapon_id text,p_attack_type text,p_power_penalty integer
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,priv,pg_temp AS $d9$
DECLARE v_user uuid:=auth.uid();
BEGIN
 IF NOT EXISTS(SELECT 1 FROM public.characters ch JOIN public.members m ON m.campaign_id=ch.campaign_id AND m.user_id=ch.user_id AND m.role='PLAYER'
 WHERE ch.id::text=p_character_id AND ch.campaign_id=p_campaign_id AND ch.user_id=v_user) THEN RAISE EXCEPTION 'Owner only'; END IF;
 PERFORM 1 FROM public.characters ch WHERE ch.id::text=p_character_id AND ch.campaign_id=p_campaign_id AND ch.user_id=v_user;
 RETURN jsonb_build_object('allowed',true);
END
$d9$;
CREATE OR REPLACE FUNCTION public.aplicar_dano_token_ataque_srd_v2(
 p_campaign_id bigint,p_character_id text,p_token_id text,p_d20 integer,p_bonus_ataque integer,p_dano integer,p_weapon_id text,p_attack_type text,p_power_penalty integer,p_sneak_attack_dice integer,p_sneak_attack_damage integer
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,priv,pg_temp AS $d11$
DECLARE v_user uuid:=auth.uid();
BEGIN
 IF NOT EXISTS(SELECT 1 FROM public.characters ch JOIN public.members m ON m.campaign_id=ch.campaign_id AND m.user_id=ch.user_id AND m.role='PLAYER'
 WHERE ch.id::text=p_character_id AND ch.campaign_id=p_campaign_id AND ch.user_id=v_user) THEN RAISE EXCEPTION 'Owner only'; END IF;
 PERFORM 1 FROM public.characters ch WHERE ch.id::text=p_character_id AND ch.campaign_id=p_campaign_id AND ch.user_id=v_user;
 RETURN jsonb_build_object('allowed',true);
END
$d11$;
GRANT EXECUTE ON FUNCTION public.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer,integer,integer) TO authenticated;
CREATE OR REPLACE FUNCTION public.fixture_assert_gm_direct_attack(p_sql text,p_allow boolean)
RETURNS void LANGUAGE plpgsql SECURITY INVOKER AS $assert$
DECLARE denied boolean:=false;
BEGIN BEGIN EXECUTE p_sql; EXCEPTION WHEN OTHERS THEN denied:=true; END;
 IF p_allow AND denied THEN RAISE EXCEPTION 'Expected allow: %',p_sql; END IF;
 IF NOT p_allow AND NOT denied THEN RAISE EXCEPTION 'Expected deny: %',p_sql; END IF;
END
$assert$;
GRANT EXECUTE ON FUNCTION public.fixture_assert_gm_direct_attack(text,boolean) TO authenticated;
\ir ../../supabase/migrations/20261114210000_allow_gm_pc_direct_attacks.sql
SET ROLE authenticated;
SET request.jwt.claim.sub='00000000-0000-0000-0000-000000000002';
SELECT public.fixture_assert_gm_direct_attack('SELECT public.aplicar_dano_token_ataque_srd_v2(987654332,''gm-control-pc-direct'',''target'',12,0,4,NULL,''melee'',0)',true);
SELECT public.fixture_assert_gm_direct_attack('SELECT public.aplicar_dano_token_ataque_srd_v2(987654332,''gm-control-pc-direct'',''target'',12,0,4,NULL,''melee'',0,0,0)',true);
RESET ROLE;
SET ROLE authenticated;
SET request.jwt.claim.sub='00000000-0000-0000-0000-000000000001';
SELECT public.fixture_assert_gm_direct_attack('SELECT public.aplicar_dano_token_ataque_srd_v2(987654332,''gm-control-pc-direct'',''target'',12,0,4,NULL,''melee'',0)',true);
SELECT public.fixture_assert_gm_direct_attack('SELECT public.aplicar_dano_token_ataque_srd_v2(987654332,''gm-control-pc-direct'',''target'',12,0,4,NULL,''melee'',0,0,0)',true);
RESET ROLE;
SET ROLE authenticated;
SET request.jwt.claim.sub='00000000-0000-0000-0000-000000000003';
SELECT public.fixture_assert_gm_direct_attack('SELECT public.aplicar_dano_token_ataque_srd_v2(987654332,''gm-control-pc-direct'',''target'',12,0,4,NULL,''melee'',0)',false);
SELECT public.fixture_assert_gm_direct_attack('SELECT public.aplicar_dano_token_ataque_srd_v2(987654332,''gm-control-pc-direct'',''target'',12,0,4,NULL,''melee'',0,0,0)',false);
RESET ROLE;
SET ROLE authenticated;
SET request.jwt.claim.sub='00000000-0000-0000-0000-000000000004';
SELECT public.fixture_assert_gm_direct_attack('SELECT public.aplicar_dano_token_ataque_srd_v2(987654332,''gm-control-pc-direct'',''target'',12,0,4,NULL,''melee'',0)',false);
SELECT public.fixture_assert_gm_direct_attack('SELECT public.aplicar_dano_token_ataque_srd_v2(987654332,''gm-control-pc-direct'',''target'',12,0,4,NULL,''melee'',0,0,0)',false);
RESET ROLE;
DO $ownership$
DECLARE v_owner uuid;
BEGIN SELECT user_id INTO v_owner FROM public.characters WHERE id='gm-control-pc-direct';
 IF v_owner IS DISTINCT FROM '00000000-0000-0000-0000-000000000002'::uuid THEN RAISE EXCEPTION 'GM changed ownership'; END IF;
END
$ownership$;
DROP FUNCTION public.fixture_assert_gm_direct_attack(text,boolean);
DROP FUNCTION public.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer,integer,integer);
DROP FUNCTION public.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer);
DROP FUNCTION priv.srd_can_control_campaign_character(bigint,text);
DELETE FROM public.characters WHERE campaign_id=987654332;
DELETE FROM public.members WHERE campaign_id=987654332;
DELETE FROM public.campaigns WHERE id=987654332;
SELECT 'GM direct PC attack control fixture passed' AS result;
