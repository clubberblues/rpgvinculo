\set ON_ERROR_STOP on

-- The previous snapshot fixture has installed the real role-filtering helper
-- and the shared synthetic campaigns/members tables in this isolated DB.
CREATE OR REPLACE FUNCTION public.aplicar_dano_token_ataque_srd_v2(
  p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer,
  p_bonus_ataque integer, p_dano integer, p_weapon_id text, p_attack_type text,
  p_power_penalty integer
)
RETURNS jsonb LANGUAGE sql SECURITY DEFINER SET search_path=public,pg_temp
AS $$ SELECT jsonb_build_object(
  'cba_data',(SELECT cba_data FROM public.campaigns WHERE id=p_campaign_id),
  'combat_data',(SELECT combat_data FROM public.campaigns WHERE id=p_campaign_id),
  'damage',p_dano
) $$;

CREATE OR REPLACE FUNCTION public.aplicar_dano_token_ataque_srd_v2(
  p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer,
  p_bonus_ataque integer, p_dano integer, p_weapon_id text, p_attack_type text,
  p_power_penalty integer, p_sneak_attack_dice integer, p_sneak_attack_damage integer
)
RETURNS jsonb LANGUAGE sql SECURITY DEFINER SET search_path=public,pg_temp
AS $$ SELECT jsonb_build_object(
  'cba_data',(SELECT cba_data FROM public.campaigns WHERE id=p_campaign_id),
  'combat_data',(SELECT combat_data FROM public.campaigns WHERE id=p_campaign_id),
  'damage',p_dano+coalesce(p_sneak_attack_damage,0)
) $$;

DELETE FROM public.campaigns WHERE id=987654323;
DELETE FROM public.members WHERE campaign_id=987654323;
INSERT INTO public.campaigns(id,name,owner_id,state,active,cba_data,combat_data)
VALUES(987654323,'RPC result fixture','00000000-0000-0000-0000-000000000001','COMBATE',true,
'{"tokens":[{"id":"pc-1","sourceCharacterId":"pc-1"},{"id":"hidden","visivel":false},{"id":"visible","visivel":true}]}',
'{"active":true,"round":1,"current_turn":0,"turn_order":[{"id":"pc-1"},{"id":"hidden"},{"id":"visible"}],"pending_reactions":[{"secret":"private"}]}');
INSERT INTO public.members VALUES(987654323,'00000000-0000-0000-0000-000000000002','PLAYER');
INSERT INTO public.characters(id,campaign_id,user_id) VALUES('pc-1',987654323,'00000000-0000-0000-0000-000000000002');

CREATE OR REPLACE FUNCTION public.alterar_pv_token_cba(p_campaign_id bigint,p_token_id text,p_variacao integer,p_pv_max integer)
RETURNS jsonb LANGUAGE sql SECURITY DEFINER SET search_path=public,pg_temp
AS $$ SELECT jsonb_build_object('cba_data',(SELECT cba_data FROM public.campaigns WHERE id=p_campaign_id),'combat_data',(SELECT combat_data FROM public.campaigns WHERE id=p_campaign_id),'ok',true) $$;
CREATE OR REPLACE FUNCTION public.equipar_item_token_srd(p_campaign_id bigint,p_token_id text,p_equipment_id text,p_equipado boolean)
RETURNS jsonb LANGUAGE sql SECURITY DEFINER SET search_path=public,pg_temp
AS $$ SELECT jsonb_build_object('cba_data',(SELECT cba_data FROM public.campaigns WHERE id=p_campaign_id),'combat_data',(SELECT combat_data FROM public.campaigns WHERE id=p_campaign_id),'ok',true) $$;
CREATE OR REPLACE FUNCTION public.srd_configurar_perfil_combate_token_srd(p_campaign_id bigint,p_token_id text,p_combat_faction text,p_melee_reach_ft integer)
RETURNS jsonb LANGUAGE sql SECURITY DEFINER SET search_path=public,pg_temp
AS $$ SELECT jsonb_build_object('cba_data',(SELECT cba_data FROM public.campaigns WHERE id=p_campaign_id),'combat_data',(SELECT combat_data FROM public.campaigns WHERE id=p_campaign_id),'ok',true) $$;

CREATE OR REPLACE FUNCTION public.conjurar_magia_dano_multialvo_srd(p_character_id text,p_spell_id text,p_slot_level smallint,p_target_token_keys text[],p_roll_results integer[])
RETURNS jsonb LANGUAGE sql SECURITY DEFINER SET search_path=public,pg_temp
AS $$ SELECT jsonb_build_object('cba_data',(SELECT cba_data FROM public.campaigns c JOIN public.characters ch ON ch.campaign_id=c.id WHERE ch.id::text=p_character_id),'combat_data',(SELECT combat_data FROM public.campaigns c JOIN public.characters ch ON ch.campaign_id=c.id WHERE ch.id::text=p_character_id),'spell_id',p_spell_id) $$;
CREATE OR REPLACE FUNCTION public.usar_habilidade_classe_srd(p_character_id text,p_feature_key text,p_target_token_key text,p_amount integer)
RETURNS jsonb LANGUAGE sql SECURITY DEFINER SET search_path=public,pg_temp
AS $$ SELECT jsonb_build_object('cba_data',(SELECT cba_data FROM public.campaigns c JOIN public.characters ch ON ch.campaign_id=c.id WHERE ch.id::text=p_character_id),'combat_data',(SELECT combat_data FROM public.campaigns c JOIN public.characters ch ON ch.campaign_id=c.id WHERE ch.id::text=p_character_id),'feature_key',p_feature_key) $$;

-- The production RPC returns combat_data as a top-level JSON object.
-- This fixture stub preserves that contract for the filtered wrapper test.
CREATE OR REPLACE FUNCTION public.avancar_turno(p_campaign_id bigint)
RETURNS jsonb
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $turnadvance$
  SELECT coalesce(c.combat_data, '{}'::jsonb)
    FROM public.campaigns AS c
   WHERE c.id = p_campaign_id
$turnadvance$;

CREATE OR REPLACE FUNCTION public.consumir_acao_turno_srd(p_campaign_id bigint,p_character_id text,p_acao text)
RETURNS jsonb LANGUAGE sql SECURITY DEFINER SET search_path=public,pg_temp
AS $consume_fixture$
  SELECT jsonb_build_object('combat_data',(SELECT combat_data FROM public.campaigns WHERE id=p_campaign_id),'action',p_acao)
$consume_fixture$;

CREATE OR REPLACE FUNCTION public.conjurar_magia_com_acao_srd_manual(
  p_character_id text,p_spell_id text,p_slot_level smallint,
  p_target_token_key text DEFAULT NULL::text,p_roll_results integer[] DEFAULT NULL::integer[]
)
RETURNS jsonb LANGUAGE sql SECURITY DEFINER SET search_path=public,pg_temp
AS $spell_fixture$
  SELECT jsonb_build_object(
    'combat_data',(SELECT c.combat_data FROM public.campaigns c JOIN public.characters ch ON ch.campaign_id=c.id WHERE ch.id::text=p_character_id),
    'spell_id',p_spell_id
  )
$spell_fixture$;

CREATE OR REPLACE FUNCTION public.conjurar_magia_com_acao_srd_multialvo_v3(
  p_character_id text,p_spell_id text,p_slot_level smallint,
  p_target_token_keys text[],p_roll_results integer[]
)
RETURNS jsonb LANGUAGE sql SECURITY DEFINER SET search_path=public,pg_temp
AS $multi_spell_fixture$
  SELECT jsonb_build_object(
    'combat_data',(SELECT c.combat_data FROM public.campaigns c JOIN public.characters ch ON ch.campaign_id=c.id WHERE ch.id::text=p_character_id),
    'spell_id',p_spell_id
  )
$multi_spell_fixture$;

CREATE OR REPLACE FUNCTION public.usar_imposicao_maos_mortos_vivos_srd(
  p_character_id text,p_target_token_key text,p_d20 integer,p_amount integer
)
RETURNS jsonb LANGUAGE sql SECURITY DEFINER SET search_path=public,pg_temp
AS $lay_hands_fixture$
  SELECT jsonb_build_object(
    'cba_data',(SELECT c.cba_data FROM public.campaigns c JOIN public.characters ch ON ch.campaign_id=c.id WHERE ch.id::text=p_character_id),
    'damage',p_amount
  )
$lay_hands_fixture$;

CREATE OR REPLACE FUNCTION public.srd_finalizar_movimento_aoo_pendente_srd(p_campaign_id bigint,p_pending_id uuid)
RETURNS jsonb LANGUAGE sql SECURITY DEFINER SET search_path=public,pg_temp
AS $$ SELECT jsonb_build_object('committed',true,'movement_result',jsonb_build_object(
  'cba_data',(SELECT cba_data FROM public.campaigns WHERE id=p_campaign_id),
  'combat_data',(SELECT combat_data FROM public.campaigns WHERE id=p_campaign_id)
)) $$;

DROP FUNCTION IF EXISTS public.registrar_iniciativa_d20(bigint,text,integer) CASCADE;
CREATE OR REPLACE FUNCTION public.registrar_iniciativa_d20(p_campaign_id bigint,p_personagem_id text,p_d20 integer)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,pg_temp AS $initiative$
BEGIN
  IF auth.uid() IS NULL OR NOT EXISTS(
    SELECT 1 FROM public.members m JOIN public.characters ch
      ON ch.campaign_id=m.campaign_id AND ch.user_id=m.user_id
     WHERE m.campaign_id=p_campaign_id AND m.user_id=auth.uid()
       AND m.role='PLAYER' AND ch.id::text=p_personagem_id
  ) THEN RAISE EXCEPTION 'Player initiative only'; END IF;
  RETURN (SELECT combat_data FROM public.campaigns WHERE id=p_campaign_id);
END
$initiative$;

\ir ../../supabase/migrations/20261112160000_filter_player_damage_rpc_results.sql
\ir ../../supabase/verification/verify_cba_rpc_response_isolation.sql

SET ROLE authenticated;
SET request.jwt.claim.sub='00000000-0000-0000-0000-000000000002';
DO $player$
DECLARE r jsonb;
BEGIN
  r:=public.aplicar_dano_token_ataque_srd_v2(987654323,'pc-1','hidden',10,1,4,'w','atk-corpo',0);
  IF r->'cba_data'->'tokens' @> '[{"id":"hidden"}]'::jsonb THEN RAISE EXCEPTION 'Player received hidden token through RPC result.'; END IF;
  IF NOT (r->'cba_data'->'tokens' @> '[{"id":"pc-1"}]'::jsonb) THEN RAISE EXCEPTION 'Player result lost owned token.'; END IF;
  IF NOT (r->'cba_data'->'tokens' @> '[{"id":"visible"}]'::jsonb) THEN RAISE EXCEPTION 'Player result lost visible token.'; END IF;
  IF r->'combat_data' ? 'pending_reactions' THEN RAISE EXCEPTION 'Player received private combat internals through RPC result.'; END IF;
  IF r->>'damage'<>'4' THEN RAISE EXCEPTION 'RPC business result fields were not preserved.'; END IF;
  r:=public.alterar_pv_token_cba(987654323,'hidden',1,10);
  IF r->'cba_data'->'tokens' @> '[{"id":"hidden"}]'::jsonb THEN RAISE EXCEPTION 'PV RPC leaked hidden token.'; END IF;
  r:=public.equipar_item_token_srd(987654323,'hidden','sword',true);
  IF r->'cba_data'->'tokens' @> '[{"id":"hidden"}]'::jsonb THEN RAISE EXCEPTION 'Equipment RPC leaked hidden token.'; END IF;
  r:=public.srd_configurar_perfil_combate_token_srd(987654323,'hidden','hostile',5);
  IF r->'cba_data'->'tokens' @> '[{"id":"hidden"}]'::jsonb THEN RAISE EXCEPTION 'Combat profile RPC leaked hidden token.'; END IF;
  r:=public.conjurar_magia_dano_multialvo_srd('pc-1','spell',1::smallint,ARRAY['hidden'],ARRAY[4]);
  IF r->'cba_data'->'tokens' @> '[{"id":"hidden"}]'::jsonb THEN RAISE EXCEPTION 'Spell damage RPC leaked hidden token.'; END IF;
  r:=public.usar_habilidade_classe_srd('pc-1','lay_on_hands','hidden',4);
  IF r->'cba_data'->'tokens' @> '[{"id":"hidden"}]'::jsonb THEN RAISE EXCEPTION 'Class feature RPC leaked hidden token.'; END IF;
  r:=public.avancar_turno(987654323);
  IF r ? 'pending_reactions' THEN RAISE EXCEPTION 'Turn advancement leaked private reactions.'; END IF;
  IF r->'turn_order' @> '[{"id":"hidden"}]'::jsonb THEN RAISE EXCEPTION 'Turn advancement leaked hidden initiative actor.'; END IF;
  IF NOT (r->'turn_order' @> '[{"id":"pc-1"}]'::jsonb) THEN RAISE EXCEPTION 'Turn advancement lost owned actor.'; END IF;
  r:=public.srd_finalizar_movimento_aoo_pendente_srd(987654323,'00000000-0000-0000-0000-000000000123');
  IF r->'movement_result'->'cba_data'->'tokens' @> '[{"id":"hidden"}]'::jsonb THEN RAISE EXCEPTION 'Nested movement RPC leaked hidden token.'; END IF;
  IF r->'movement_result'->'combat_data' ? 'pending_reactions' THEN RAISE EXCEPTION 'Nested movement RPC leaked private combat state.'; END IF;
  r:=public.consumir_acao_turno_srd(987654323,'pc-1','padrao');
  IF r->'combat_data' ? 'pending_reactions' THEN RAISE EXCEPTION 'Action-economy RPC leaked private combat state.'; END IF;
  IF r->'combat_data'->'turn_order' @> '[{"id":"hidden"}]'::jsonb THEN RAISE EXCEPTION 'Action-economy RPC leaked hidden initiative actor.'; END IF;
  r:=public.conjurar_magia_com_acao_srd_manual('pc-1','spell',1::smallint,'visible',ARRAY[11]);
  IF r->'combat_data' ? 'pending_reactions' THEN RAISE EXCEPTION 'Single-target spell RPC leaked private combat state.'; END IF;
  r:=public.registrar_iniciativa_d20(987654323,'pc-1',12);
  IF r ? 'pending_reactions' THEN RAISE EXCEPTION 'Player initiative RPC leaked private combat state.'; END IF;
  IF r->'turn_order' @> '[{"id":"hidden"}]'::jsonb THEN RAISE EXCEPTION 'Player initiative RPC leaked hidden initiative actor.'; END IF;
  IF NOT (r->'turn_order' @> '[{"id":"pc-1"}]'::jsonb) THEN RAISE EXCEPTION 'Player initiative RPC lost own actor.'; END IF;
  r:=public.conjurar_magia_com_acao_srd_multialvo_v3('pc-1','spell',1::smallint,ARRAY['visible'],ARRAY[11]);
  IF r->'combat_data' ? 'pending_reactions' THEN RAISE EXCEPTION 'Multi-target spell RPC leaked private combat state.'; END IF;
  r:=public.usar_imposicao_maos_mortos_vivos_srd('pc-1','visible',12,3);
  IF r->'cba_data'->'tokens' @> '[{"id":"hidden"}]'::jsonb THEN RAISE EXCEPTION 'Lay on Hands RPC leaked hidden token.'; END IF;
END
$player$;
RESET ROLE;

SET ROLE authenticated;
SET request.jwt.claim.sub='00000000-0000-0000-0000-000000000001';
DO $owner$
DECLARE r jsonb;
BEGIN
  r:=public.aplicar_dano_token_ataque_srd_v2(987654323,'pc-1','hidden',10,1,4,'w','atk-corpo',0);
  IF NOT (r->'cba_data'->'tokens' @> '[{"id":"hidden"}]'::jsonb) THEN RAISE EXCEPTION 'Owner lost hidden token in RPC result.'; END IF;
  IF NOT (r->'combat_data' ? 'pending_reactions') THEN RAISE EXCEPTION 'Owner lost private combat state in RPC result.'; END IF;
  r:=public.avancar_turno(987654323);
  IF NOT (r ? 'pending_reactions') THEN RAISE EXCEPTION 'Owner lost private combat state through turn advancement.'; END IF;
  r:=public.consumir_acao_turno_srd(987654323,'pc-1','padrao');
  IF NOT (r->'combat_data' ? 'pending_reactions') THEN RAISE EXCEPTION 'Owner lost private state through action-economy RPC.'; END IF;
  r:=public.conjurar_magia_com_acao_srd_manual('pc-1','spell',1::smallint,'visible',ARRAY[11]);
  IF NOT (r->'combat_data' ? 'pending_reactions') THEN RAISE EXCEPTION 'Owner lost private state through single-target spell RPC.'; END IF;
  r:=public.conjurar_magia_com_acao_srd_multialvo_v3('pc-1','spell',1::smallint,ARRAY['visible'],ARRAY[11]);
  IF NOT (r->'combat_data' ? 'pending_reactions') THEN RAISE EXCEPTION 'Owner lost private state through multi-target spell RPC.'; END IF;
  r:=public.usar_imposicao_maos_mortos_vivos_srd('pc-1','visible',12,3);
  IF NOT (r->'cba_data'->'tokens' @> '[{"id":"hidden"}]'::jsonb) THEN RAISE EXCEPTION 'Owner lost hidden token through Lay on Hands RPC.'; END IF;
END
$owner$;
RESET ROLE;

DO $acl$
BEGIN
  IF has_function_privilege('authenticated','priv.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer)','EXECUTE') THEN
    RAISE EXCEPTION 'Authenticated can bypass the filtered damage RPC wrapper.';
  END IF;
  IF NOT has_function_privilege('authenticated','public.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer)','EXECUTE') THEN
    RAISE EXCEPTION 'Authenticated cannot execute filtered damage RPC wrapper.';
  END IF;
  IF has_function_privilege('authenticated','priv.consumir_acao_turno_srd(bigint,text,text)','EXECUTE')
     OR has_function_privilege('authenticated','priv.conjurar_magia_com_acao_srd_manual(text,text,smallint,text,integer[])','EXECUTE')
     OR has_function_privilege('authenticated','priv.conjurar_magia_com_acao_srd_multialvo_v3(text,text,smallint,text[],integer[])','EXECUTE')
     OR has_function_privilege('authenticated','priv.usar_imposicao_maos_mortos_vivos_srd(text,text,integer,integer)','EXECUTE') THEN
    RAISE EXCEPTION 'Authenticated can bypass a filtered player action/spell RPC wrapper.';
  END IF;
END
$acl$;

DELETE FROM public.characters WHERE campaign_id=987654323;
DELETE FROM public.members WHERE campaign_id=987654323;
DELETE FROM public.campaigns WHERE id=987654323;
