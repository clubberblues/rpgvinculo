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
DELETE FROM public.characters WHERE campaign_id=987654334;
DELETE FROM public.members WHERE campaign_id=987654334;
DELETE FROM public.campaigns WHERE id=987654334;
INSERT INTO public.campaigns(id,name,owner_id) VALUES(987654334,'GM spellcasting fixture','00000000-0000-0000-0000-000000000001');
INSERT INTO public.members(campaign_id,user_id,role) VALUES
 (987654334,'00000000-0000-0000-0000-000000000001','GM'),
 (987654334,'00000000-0000-0000-0000-000000000002','PLAYER'),
 (987654334,'00000000-0000-0000-0000-000000000003','PLAYER');
INSERT INTO public.characters(id,campaign_id,user_id) VALUES('gm-control-pc-spells',987654334,'00000000-0000-0000-0000-000000000002');

DROP FUNCTION IF EXISTS public.conjurar_magia_com_acao_srd_manual(text,text,smallint,text,integer[]) CASCADE;
DROP FUNCTION IF EXISTS public.conjurar_magia_com_acao_srd_multialvo_v3(text,text,smallint,text[],integer[]) CASCADE;
DROP FUNCTION IF EXISTS public.conjurar_magia_dano_multialvo_srd(text,text,smallint,text[],integer[]) CASCADE;
DROP FUNCTION IF EXISTS public.conjurar_magia_efeitos_multialvo(text,text,smallint,text[]) CASCADE;
DROP FUNCTION IF EXISTS public.conjurar_magia_srd_manual(text,text,smallint,text,integer[]) CASCADE;
DROP FUNCTION IF EXISTS public.conjurar_magia_srd_multialvo_v3(text,text,smallint,text[],integer[]) CASCADE;
DROP FUNCTION IF EXISTS public.conjurar_missil_magico_srd_manual(text,text,smallint,text,integer[]) CASCADE;
DROP FUNCTION IF EXISTS priv.conjurar_missil_magico_srd_manual(text,text,smallint,text,integer[]) CASCADE;

CREATE OR REPLACE FUNCTION public.conjurar_magia_com_acao_srd_manual(p_character_id text,p_spell_id text,p_slot_level smallint,p_target_token_key text,p_roll_results integer[])
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,priv,pg_temp AS $s1$
DECLARE v_campaign_id bigint;
BEGIN SELECT ch.campaign_id INTO v_campaign_id FROM public.characters ch WHERE ch.id::text=BTRIM(p_character_id) AND ch.user_id=auth.uid() FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Owner only'; END IF; RETURN jsonb_build_object('allowed',true); END
$s1$;
CREATE OR REPLACE FUNCTION public.conjurar_magia_com_acao_srd_multialvo_v3(p_character_id text,p_spell_id text,p_slot_level smallint,p_target_token_keys text[],p_roll_results integer[])
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,priv,pg_temp AS $s2$
DECLARE v_campaign_id bigint;
BEGIN SELECT ch.campaign_id INTO v_campaign_id FROM public.characters ch WHERE ch.id::text=BTRIM(p_character_id) AND ch.user_id=auth.uid() FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Owner only'; END IF; RETURN jsonb_build_object('allowed',true); END
$s2$;
CREATE OR REPLACE FUNCTION public.conjurar_magia_dano_multialvo_srd(p_character_id text,p_spell_id text,p_slot_level smallint,p_target_token_keys text[],p_roll_results integer[])
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,priv,pg_temp AS $s3$
DECLARE v_campaign_id bigint;
BEGIN SELECT ch.campaign_id INTO v_campaign_id FROM public.characters ch WHERE ch.id::text=BTRIM(p_character_id) AND ch.user_id=auth.uid() FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Owner only'; END IF; RETURN jsonb_build_object('allowed',true); END
$s3$;
CREATE OR REPLACE FUNCTION public.conjurar_magia_efeitos_multialvo(p_character_id text,p_spell_id text,p_slot_level smallint,p_target_token_keys text[])
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,priv,pg_temp AS $s4$
DECLARE v_campaign_id bigint;
BEGIN SELECT ch.campaign_id INTO v_campaign_id FROM public.characters ch WHERE ch.id::text=BTRIM(p_character_id) AND ch.user_id=auth.uid() FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Owner only'; END IF; RETURN jsonb_build_object('allowed',true); END
$s4$;
CREATE OR REPLACE FUNCTION public.conjurar_magia_srd_manual(p_character_id text,p_spell_id text,p_slot_level smallint,p_target_token_key text,p_roll_results integer[])
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,priv,pg_temp AS $s5$
DECLARE v_campaign_id bigint;
BEGIN SELECT c.campaign_id INTO v_campaign_id FROM public.characters c WHERE c.id::text=p_character_id AND c.user_id=auth.uid() FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Owner only'; END IF; RETURN jsonb_build_object('allowed',true); END
$s5$;
CREATE OR REPLACE FUNCTION public.conjurar_magia_srd_multialvo_v3(p_character_id text,p_spell_id text,p_slot_level smallint,p_target_token_keys text[],p_roll_results integer[])
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,priv,pg_temp AS $s6$
DECLARE v_campaign_id bigint;
BEGIN SELECT ch.campaign_id INTO v_campaign_id FROM public.characters ch WHERE ch.id::text=BTRIM(p_character_id) AND ch.user_id=auth.uid() FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Owner only'; END IF; RETURN jsonb_build_object('allowed',true); END
$s6$;

GRANT EXECUTE ON FUNCTION public.conjurar_magia_com_acao_srd_manual(text,text,smallint,text,integer[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.conjurar_magia_com_acao_srd_multialvo_v3(text,text,smallint,text[],integer[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.conjurar_magia_dano_multialvo_srd(text,text,smallint,text[],integer[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.conjurar_magia_efeitos_multialvo(text,text,smallint,text[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.conjurar_magia_srd_manual(text,text,smallint,text,integer[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.conjurar_magia_srd_multialvo_v3(text,text,smallint,text[],integer[]) TO authenticated;
CREATE OR REPLACE FUNCTION priv.conjurar_missil_magico_srd_manual(p_character_id text,p_spell_id text,p_slot_level smallint,p_target_token_key text,p_damage_rolls integer[])
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,priv,pg_temp AS $s7$
DECLARE v_campaign_id bigint;
BEGIN SELECT ch.campaign_id INTO v_campaign_id FROM public.characters ch WHERE ch.id::text=BTRIM(p_character_id) AND ch.user_id=auth.uid();
 IF NOT FOUND THEN RAISE EXCEPTION 'Owner only'; END IF; RETURN jsonb_build_object('allowed',true); END
$s7$;
REVOKE ALL ON FUNCTION priv.conjurar_missil_magico_srd_manual(text,text,smallint,text,integer[]) FROM PUBLIC,anon,authenticated;
CREATE OR REPLACE FUNCTION public.conjurar_missil_magico_srd_manual(p_character_id text,p_spell_id text,p_slot_level smallint,p_target_token_key text,p_damage_rolls integer[])
RETURNS jsonb LANGUAGE sql SECURITY DEFINER SET search_path=pg_catalog,public,priv,pg_temp AS $s8$
 SELECT priv.conjurar_missil_magico_srd_manual($1,$2,$3,$4,$5)
$s8$;
GRANT EXECUTE ON FUNCTION public.conjurar_missil_magico_srd_manual(text,text,smallint,text,integer[]) TO authenticated;
CREATE OR REPLACE FUNCTION public.fixture_assert_gm_spell(p_sql text,p_allow boolean)
RETURNS void LANGUAGE plpgsql SECURITY INVOKER AS $assert$
DECLARE denied boolean:=false; v_error text;
BEGIN BEGIN EXECUTE p_sql; EXCEPTION WHEN OTHERS THEN denied:=true; v_error:=SQLERRM; END;
 IF p_allow AND denied THEN RAISE EXCEPTION 'Expected allow: %; actual error: %',p_sql,v_error; END IF;
 IF NOT p_allow AND NOT denied THEN RAISE EXCEPTION 'Expected deny: %',p_sql; END IF;
END
$assert$;
GRANT EXECUTE ON FUNCTION public.fixture_assert_gm_spell(text,boolean) TO authenticated;
\ir ../../supabase/migrations/20261114220000_character_control_helper.sql
\ir ../../supabase/migrations/20261114230000_allow_gm_pc_spellcasting.sql

SET ROLE authenticated;
SET request.jwt.claim.sub='00000000-0000-0000-0000-000000000002';
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_com_acao_srd_manual(''gm-control-pc-spells'',''spell'',1::smallint,NULL,NULL)',true);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_com_acao_srd_multialvo_v3(''gm-control-pc-spells'',''spell'',1::smallint,ARRAY[]::text[],NULL)',true);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_dano_multialvo_srd(''gm-control-pc-spells'',''spell'',1::smallint,ARRAY[]::text[],NULL)',true);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_efeitos_multialvo(''gm-control-pc-spells'',''spell'',1::smallint,ARRAY[]::text[])',true);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_srd_manual(''gm-control-pc-spells'',''spell'',1::smallint,NULL,NULL)',true);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_srd_multialvo_v3(''gm-control-pc-spells'',''spell'',1::smallint,ARRAY[]::text[],NULL)',true);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_missil_magico_srd_manual(''gm-control-pc-spells'',''spell'',1::smallint,NULL,ARRAY[4])',true);
RESET ROLE;

SET ROLE authenticated;
SET request.jwt.claim.sub='00000000-0000-0000-0000-000000000001';
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_com_acao_srd_manual(''gm-control-pc-spells'',''spell'',1::smallint,NULL,NULL)',true);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_com_acao_srd_multialvo_v3(''gm-control-pc-spells'',''spell'',1::smallint,ARRAY[]::text[],NULL)',true);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_dano_multialvo_srd(''gm-control-pc-spells'',''spell'',1::smallint,ARRAY[]::text[],NULL)',true);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_efeitos_multialvo(''gm-control-pc-spells'',''spell'',1::smallint,ARRAY[]::text[])',true);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_srd_manual(''gm-control-pc-spells'',''spell'',1::smallint,NULL,NULL)',true);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_srd_multialvo_v3(''gm-control-pc-spells'',''spell'',1::smallint,ARRAY[]::text[],NULL)',true);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_missil_magico_srd_manual(''gm-control-pc-spells'',''spell'',1::smallint,NULL,ARRAY[4])',true);
RESET ROLE;

SET ROLE authenticated;
SET request.jwt.claim.sub='00000000-0000-0000-0000-000000000003';
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_com_acao_srd_manual(''gm-control-pc-spells'',''spell'',1::smallint,NULL,NULL)',false);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_com_acao_srd_multialvo_v3(''gm-control-pc-spells'',''spell'',1::smallint,ARRAY[]::text[],NULL)',false);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_dano_multialvo_srd(''gm-control-pc-spells'',''spell'',1::smallint,ARRAY[]::text[],NULL)',false);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_efeitos_multialvo(''gm-control-pc-spells'',''spell'',1::smallint,ARRAY[]::text[])',false);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_srd_manual(''gm-control-pc-spells'',''spell'',1::smallint,NULL,NULL)',false);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_srd_multialvo_v3(''gm-control-pc-spells'',''spell'',1::smallint,ARRAY[]::text[],NULL)',false);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_missil_magico_srd_manual(''gm-control-pc-spells'',''spell'',1::smallint,NULL,ARRAY[4])',false);
RESET ROLE;

SET ROLE authenticated;
SET request.jwt.claim.sub='00000000-0000-0000-0000-000000000004';
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_com_acao_srd_manual(''gm-control-pc-spells'',''spell'',1::smallint,NULL,NULL)',false);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_com_acao_srd_multialvo_v3(''gm-control-pc-spells'',''spell'',1::smallint,ARRAY[]::text[],NULL)',false);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_dano_multialvo_srd(''gm-control-pc-spells'',''spell'',1::smallint,ARRAY[]::text[],NULL)',false);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_efeitos_multialvo(''gm-control-pc-spells'',''spell'',1::smallint,ARRAY[]::text[])',false);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_srd_manual(''gm-control-pc-spells'',''spell'',1::smallint,NULL,NULL)',false);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_magia_srd_multialvo_v3(''gm-control-pc-spells'',''spell'',1::smallint,ARRAY[]::text[],NULL)',false);
SELECT public.fixture_assert_gm_spell('SELECT public.conjurar_missil_magico_srd_manual(''gm-control-pc-spells'',''spell'',1::smallint,NULL,ARRAY[4])',false);
RESET ROLE;

DO $ownership$
DECLARE v_owner uuid;
BEGIN SELECT user_id INTO v_owner FROM public.characters WHERE id='gm-control-pc-spells';
 IF v_owner IS DISTINCT FROM '00000000-0000-0000-0000-000000000002'::uuid THEN RAISE EXCEPTION 'GM changed PC ownership'; END IF;
END
$ownership$;

DROP FUNCTION public.fixture_assert_gm_spell(text,boolean);
DROP FUNCTION public.conjurar_missil_magico_srd_manual(text,text,smallint,text,integer[]);
DROP FUNCTION priv.conjurar_missil_magico_srd_manual(text,text,smallint,text,integer[]);
DROP FUNCTION public.conjurar_magia_srd_multialvo_v3(text,text,smallint,text[],integer[]);
DROP FUNCTION public.conjurar_magia_srd_manual(text,text,smallint,text,integer[]);
DROP FUNCTION public.conjurar_magia_efeitos_multialvo(text,text,smallint,text[]);
DROP FUNCTION public.conjurar_magia_dano_multialvo_srd(text,text,smallint,text[],integer[]);
DROP FUNCTION public.conjurar_magia_com_acao_srd_multialvo_v3(text,text,smallint,text[],integer[]);
DROP FUNCTION public.conjurar_magia_com_acao_srd_manual(text,text,smallint,text,integer[]);
DROP FUNCTION priv.srd_can_control_character(text);
DELETE FROM public.characters WHERE campaign_id=987654334;
DELETE FROM public.members WHERE campaign_id=987654334;
DELETE FROM public.campaigns WHERE id=987654334;
SELECT 'GM spellcasting fixture passed' AS result;
