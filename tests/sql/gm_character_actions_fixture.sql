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
DELETE FROM public.characters WHERE campaign_id=987654333;
DELETE FROM public.members WHERE campaign_id=987654333;
DELETE FROM public.campaigns WHERE id=987654333;
INSERT INTO public.campaigns(id,name,owner_id) VALUES(987654333,'GM character actions fixture','00000000-0000-0000-0000-000000000001');
INSERT INTO public.members(campaign_id,user_id,role) VALUES
 (987654333,'00000000-0000-0000-0000-000000000001','GM'),
 (987654333,'00000000-0000-0000-0000-000000000002','PLAYER'),
 (987654333,'00000000-0000-0000-0000-000000000003','PLAYER');
INSERT INTO public.characters(id,campaign_id,user_id) VALUES('gm-control-pc-actions',987654333,'00000000-0000-0000-0000-000000000002');

CREATE OR REPLACE FUNCTION public.srd_resolve_requested_saving_throw_srd(p_campaign_id bigint,p_character_id text,p_request_id text,p_d20 integer)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,priv,pg_temp AS $save$
DECLARE v_character public.characters%rowtype;
BEGIN
 SELECT * INTO v_character FROM public.characters WHERE id::text=BTRIM(p_character_id) AND campaign_id=p_campaign_id AND user_id=auth.uid();
 IF NOT FOUND THEN RAISE EXCEPTION 'Owner only'; END IF;
 RETURN jsonb_build_object('allowed',true);
END
$save$;
CREATE OR REPLACE FUNCTION public.srd_validar_uso_pericia_srd(p_character_id text,p_skill_id text)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,priv,pg_temp AS $skill$
DECLARE v_character public.characters%rowtype;
BEGIN
 SELECT * INTO v_character FROM public.characters WHERE id::text=BTRIM(p_character_id) AND user_id=auth.uid();
 IF NOT FOUND THEN RAISE EXCEPTION 'Owner only'; END IF;
 RETURN jsonb_build_object('allowed',true);
END
$skill$;
CREATE OR REPLACE FUNCTION public.usar_habilidade_classe_srd(p_character_id text,p_feature_key text,p_target_token_key text,p_amount integer)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,priv,pg_temp AS $feature$
DECLARE v_character public.characters%rowtype;
BEGIN
 SELECT * INTO v_character FROM public.characters WHERE id::text=BTRIM(p_character_id) AND user_id=auth.uid() FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Owner only'; END IF;
 RETURN jsonb_build_object('allowed',true);
END
$feature$;
CREATE OR REPLACE FUNCTION public.usar_imposicao_maos_mortos_vivos_srd(p_character_id text,p_target_token_key text,p_d20 integer,p_amount integer)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,priv,pg_temp AS $lay$
DECLARE v_character public.characters%rowtype;
BEGIN
 SELECT * INTO v_character FROM public.characters WHERE id::text=BTRIM(p_character_id) AND user_id=auth.uid() FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Owner only'; END IF;
 RETURN jsonb_build_object('allowed',true);
END
$lay$;
CREATE OR REPLACE FUNCTION public.usar_pocao_cura_srd_manual(p_character_id text,p_equipment_id text,p_roll_results integer[])
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,priv,pg_temp AS $potion$
DECLARE v_campaign_id bigint;
BEGIN
 IF NOT EXISTS(SELECT 1 FROM public.characters WHERE id::text=BTRIM(p_character_id) AND user_id=auth.uid()) THEN RAISE EXCEPTION 'Owner only'; END IF;
 SELECT campaign_id INTO v_campaign_id FROM public.characters WHERE id::text=BTRIM(p_character_id) AND user_id=auth.uid();
 RETURN jsonb_build_object('allowed',true,'campaign_id',v_campaign_id);
END
$potion$;

GRANT EXECUTE ON FUNCTION public.srd_resolve_requested_saving_throw_srd(bigint,text,text,integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.srd_validar_uso_pericia_srd(text,text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.usar_habilidade_classe_srd(text,text,text,integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.usar_imposicao_maos_mortos_vivos_srd(text,text,integer,integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.usar_pocao_cura_srd_manual(text,text,integer[]) TO authenticated;
CREATE OR REPLACE FUNCTION public.fixture_assert_gm_character_action(p_sql text,p_allow boolean)
RETURNS void LANGUAGE plpgsql SECURITY INVOKER AS $assert$
DECLARE denied boolean:=false;
BEGIN BEGIN EXECUTE p_sql; EXCEPTION WHEN OTHERS THEN denied:=true; END;
 IF p_allow AND denied THEN RAISE EXCEPTION 'Expected allow: %',p_sql; END IF;
 IF NOT p_allow AND NOT denied THEN RAISE EXCEPTION 'Expected deny: %',p_sql; END IF;
END
$assert$;
GRANT EXECUTE ON FUNCTION public.fixture_assert_gm_character_action(text,boolean) TO authenticated;

\ir ../../supabase/migrations/20261114220000_character_control_helper.sql
\ir ../../supabase/migrations/20261114221000_allow_gm_character_actions.sql

SET ROLE authenticated;
SET request.jwt.claim.sub='00000000-0000-0000-0000-000000000002';
SELECT public.fixture_assert_gm_character_action('SELECT public.srd_resolve_requested_saving_throw_srd(987654333,''gm-control-pc-actions'',''request'',12)',true);
SELECT public.fixture_assert_gm_character_action('SELECT public.srd_validar_uso_pericia_srd(''gm-control-pc-actions'',''climb'')',true);
SELECT public.fixture_assert_gm_character_action('SELECT public.usar_habilidade_classe_srd(''gm-control-pc-actions'',''lay_on_hands'',NULL,1)',true);
SELECT public.fixture_assert_gm_character_action('SELECT public.usar_imposicao_maos_mortos_vivos_srd(''gm-control-pc-actions'',''target'',12,1)',true);
SELECT public.fixture_assert_gm_character_action('SELECT public.usar_pocao_cura_srd_manual(''gm-control-pc-actions'',''pocao_cura_lig'',ARRAY[4])',true);
RESET ROLE;

SET ROLE authenticated;
SET request.jwt.claim.sub='00000000-0000-0000-0000-000000000001';
SELECT public.fixture_assert_gm_character_action('SELECT public.srd_resolve_requested_saving_throw_srd(987654333,''gm-control-pc-actions'',''request'',12)',true);
SELECT public.fixture_assert_gm_character_action('SELECT public.srd_validar_uso_pericia_srd(''gm-control-pc-actions'',''climb'')',true);
SELECT public.fixture_assert_gm_character_action('SELECT public.usar_habilidade_classe_srd(''gm-control-pc-actions'',''lay_on_hands'',NULL,1)',true);
SELECT public.fixture_assert_gm_character_action('SELECT public.usar_imposicao_maos_mortos_vivos_srd(''gm-control-pc-actions'',''target'',12,1)',true);
SELECT public.fixture_assert_gm_character_action('SELECT public.usar_pocao_cura_srd_manual(''gm-control-pc-actions'',''pocao_cura_lig'',ARRAY[4])',true);
RESET ROLE;

SET ROLE authenticated;
SET request.jwt.claim.sub='00000000-0000-0000-0000-000000000003';
SELECT public.fixture_assert_gm_character_action('SELECT public.srd_resolve_requested_saving_throw_srd(987654333,''gm-control-pc-actions'',''request'',12)',false);
SELECT public.fixture_assert_gm_character_action('SELECT public.srd_validar_uso_pericia_srd(''gm-control-pc-actions'',''climb'')',false);
SELECT public.fixture_assert_gm_character_action('SELECT public.usar_habilidade_classe_srd(''gm-control-pc-actions'',''lay_on_hands'',NULL,1)',false);
SELECT public.fixture_assert_gm_character_action('SELECT public.usar_imposicao_maos_mortos_vivos_srd(''gm-control-pc-actions'',''target'',12,1)',false);
SELECT public.fixture_assert_gm_character_action('SELECT public.usar_pocao_cura_srd_manual(''gm-control-pc-actions'',''pocao_cura_lig'',ARRAY[4])',false);
RESET ROLE;

SET ROLE authenticated;
SET request.jwt.claim.sub='00000000-0000-0000-0000-000000000004';
SELECT public.fixture_assert_gm_character_action('SELECT public.srd_resolve_requested_saving_throw_srd(987654333,''gm-control-pc-actions'',''request'',12)',false);
SELECT public.fixture_assert_gm_character_action('SELECT public.srd_validar_uso_pericia_srd(''gm-control-pc-actions'',''climb'')',false);
SELECT public.fixture_assert_gm_character_action('SELECT public.usar_habilidade_classe_srd(''gm-control-pc-actions'',''lay_on_hands'',NULL,1)',false);
SELECT public.fixture_assert_gm_character_action('SELECT public.usar_imposicao_maos_mortos_vivos_srd(''gm-control-pc-actions'',''target'',12,1)',false);
SELECT public.fixture_assert_gm_character_action('SELECT public.usar_pocao_cura_srd_manual(''gm-control-pc-actions'',''pocao_cura_lig'',ARRAY[4])',false);
RESET ROLE;

DO $ownership$
DECLARE v_owner uuid;
BEGIN SELECT user_id INTO v_owner FROM public.characters WHERE id='gm-control-pc-actions';
 IF v_owner IS DISTINCT FROM '00000000-0000-0000-0000-000000000002'::uuid THEN RAISE EXCEPTION 'GM changed character ownership'; END IF;
END
$ownership$;

DROP FUNCTION public.fixture_assert_gm_character_action(text,boolean);
DROP FUNCTION public.usar_pocao_cura_srd_manual(text,text,integer[]);
DROP FUNCTION public.usar_imposicao_maos_mortos_vivos_srd(text,text,integer,integer);
DROP FUNCTION public.usar_habilidade_classe_srd(text,text,text,integer);
DROP FUNCTION public.srd_validar_uso_pericia_srd(text,text);
DROP FUNCTION public.srd_resolve_requested_saving_throw_srd(bigint,text,text,integer);
DROP FUNCTION priv.srd_can_control_character(text);
DELETE FROM public.characters WHERE campaign_id=987654333;
DELETE FROM public.members WHERE campaign_id=987654333;
DELETE FROM public.campaigns WHERE id=987654333;
SELECT 'GM character actions fixture passed' AS result;
