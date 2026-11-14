CREATE OR REPLACE FUNCTION public.consumir_acao_token_gm_srd(
 p_campaign_id bigint, p_token_id text, p_acao text
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public','priv','pg_temp'
AS $function$
DECLARE
 v_user uuid:=auth.uid();
 v_campaign public.campaigns%ROWTYPE;
 v_combat jsonb;
 v_order jsonb;
 v_actor jsonb;
 v_action_state jsonb;
 v_by_token jsonb;
 v_token_actions jsonb;
 v_action text:=lower(btrim(coalesce(p_acao,'')));
 v_round integer;
BEGIN
 IF v_user IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.members WHERE campaign_id=p_campaign_id AND user_id=v_user AND role='GM') THEN
  RAISE EXCEPTION 'Somente o Mestre pode coordenar os tokens controlados por ele.';
 END IF;
 IF v_action NOT IN ('padrao','movimento','rapida') THEN RAISE EXCEPTION 'Ação inválida.'; END IF;
 SELECT c.* INTO v_campaign FROM public.campaigns c WHERE c.id=p_campaign_id FOR UPDATE;
 IF NOT FOUND OR upper(coalesce(v_campaign.state,''))<>'COMBATE' THEN RAISE EXCEPTION 'A campanha não está em combate.'; END IF;
 v_combat:=coalesce(v_campaign.combat_data,'{}'::jsonb);
 IF coalesce(v_combat->>'active','false')<>'true' THEN RAISE EXCEPTION 'A iniciativa não está ativa.'; END IF;
 v_order:=CASE WHEN jsonb_typeof(v_combat->'turn_order')='array' THEN v_combat->'turn_order' ELSE '[]'::jsonb END;
 IF coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$' THEN RAISE EXCEPTION 'O turno atual é inválido.'; END IF;
 v_actor:=v_order->(v_combat->>'current_turn')::integer;
 IF v_actor->>'id' IS DISTINCT FROM btrim(p_token_id) OR coalesce(v_actor->>'is_monster','false')<>'true' THEN RAISE EXCEPTION 'O token não está no turno ativo do Mestre.'; END IF;
 IF NOT EXISTS(
  SELECT 1 FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t(token)
  WHERE t.token->>'id'=btrim(p_token_id)
   AND (t.token->>'tipo' IN ('npc','monstro') OR
    (t.token->>'tipo'='player' AND EXISTS(
      SELECT 1 FROM public.characters ch WHERE ch.id::text=btrim(p_token_id)
       AND ch.user_id=v_user AND ch.campaign_id=p_campaign_id
    )))
 ) THEN RAISE EXCEPTION 'Este token não é controlado pelo Mestre.'; END IF;
 IF priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'no_actions') THEN
  RAISE EXCEPTION 'A condição atual impede qualquer ação.';
 END IF;
 IF v_action<>'movimento' AND priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'only_move_action') THEN
  RAISE EXCEPTION 'A condição atual permite somente uma ação de movimento.';
 END IF;
 v_round:=CASE WHEN coalesce(v_combat->>'round','') ~ '^[0-9]+$' THEN greatest(1,(v_combat->>'round')::integer) ELSE 1 END;
 v_action_state:=v_combat->'action_economy';
 IF jsonb_typeof(v_action_state)='object' AND coalesce(v_action_state->>'round','')=v_round::text AND jsonb_typeof(v_action_state->'by_character')='object' THEN
  v_by_token:=v_action_state->'by_character';
 ELSE v_by_token:='{}'::jsonb; END IF;
 v_token_actions:=CASE WHEN jsonb_typeof(v_by_token->btrim(p_token_id))='object' THEN v_by_token->btrim(p_token_id) ELSE '{}'::jsonb END;
 IF priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'one_move_or_standard')
    AND v_action IN ('padrao','movimento')
    AND (coalesce(v_token_actions->>'padrao','false')='true' OR coalesce(v_token_actions->>'movimento','false')='true') THEN
  RAISE EXCEPTION 'A condição permite apenas uma ação padrão ou de movimento por rodada.';
 END IF;
 IF coalesce(v_token_actions->>v_action,'false')='true' THEN RAISE EXCEPTION 'Esta ação do token já foi usada nesta rodada.'; END IF;
 v_token_actions:=v_token_actions||jsonb_build_object(v_action,true);
 v_by_token:=jsonb_set(v_by_token,ARRAY[btrim(p_token_id)],v_token_actions,true);
 v_action_state:=jsonb_build_object('round',v_round,'by_character',v_by_token);
 v_combat:=v_combat||jsonb_build_object('action_economy',v_action_state);
 UPDATE public.campaigns SET combat_data=v_combat WHERE id=p_campaign_id;
 RETURN jsonb_build_object('combat_data',v_combat,'token_id',btrim(p_token_id),'action',v_action,'round',v_round);
END;
$function$;