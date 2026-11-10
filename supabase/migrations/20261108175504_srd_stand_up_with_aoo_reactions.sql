
CREATE OR REPLACE FUNCTION priv.srd_iniciar_levantar_caido_srd(
  p_campaign_id bigint,p_token_id text
) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path=pg_catalog,public,priv,pg_temp
AS $fn$
DECLARE
  v_campaign public.campaigns%ROWTYPE;
  v_token jsonb;
  v_tokens jsonb;
  v_count integer;
  v_x integer; v_y integer; v_round integer; v_turn integer;
  v_order jsonb; v_actor jsonb;
  v_faction text;
  v_reach integer;
  v_reactions jsonb;
  v_threats jsonb;
  v_pending uuid:=gen_random_uuid();
  v_token_id text;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode coordenar o levantamento nesta versão.';
  END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND OR upper(coalesce(v_campaign.state,''))<>'COMBATE'
     OR coalesce(v_campaign.combat_data->>'active','false')<>'true' THEN
    RAISE EXCEPTION 'Levantar-se durante o combate exige iniciativa ativa.';
  END IF;
  IF coalesce(v_campaign.combat_data->'surprise'->>'phase','normal')='surprise_round' THEN
    RAISE EXCEPTION 'Levantar-se não pode ser executado durante a rodada surpresa.';
  END IF;
  IF coalesce(v_campaign.combat_data->>'current_turn','') !~ '^[0-9]+$'
     OR coalesce(v_campaign.combat_data->>'round','') !~ '^[0-9]+$' THEN
    RAISE EXCEPTION 'Turno ou rodada inválidos.';
  END IF;
  v_turn:=(v_campaign.combat_data->>'current_turn')::integer;
  v_round:=greatest(1,(v_campaign.combat_data->>'round')::integer);
  v_order:=CASE WHEN jsonb_typeof(v_campaign.combat_data->'turn_order')='array'
    THEN v_campaign.combat_data->'turn_order' ELSE '[]'::jsonb END;
  v_actor:=v_order->v_turn;
  IF v_actor IS NULL OR v_actor->>'id' IS DISTINCT FROM btrim(p_token_id) THEN
    RAISE EXCEPTION 'O personagem precisa estar no turno ativo.';
  END IF;
  SELECT count(*)::integer,(array_agg(t))[1] INTO v_count,v_token
  FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  WHERE t->>'id'=btrim(p_token_id) OR t->>'key'=btrim(p_token_id);
  IF v_count<>1 THEN RAISE EXCEPTION 'Token ausente ou duplicado.'; END IF;
  v_token_id:=coalesce(v_token->>'key',v_token->>'id');
  IF coalesce(v_token->>'gridX','') !~ '^[0-9]{1,3}$'
     OR coalesce(v_token->>'gridY','') !~ '^[0-9]{1,3}$' THEN
    RAISE EXCEPTION 'Posição do token inválida.';
  END IF;
  v_x:=(v_token->>'gridX')::integer; v_y:=(v_token->>'gridY')::integer;
  IF NOT EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc
    WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='token'
      AND cc.target_id IN (btrim(p_token_id),v_token_id)
      AND cc.condition_id='prone' AND cc.active=true) THEN
    RAISE EXCEPTION 'Este combatente não está Caído.';
  END IF;
  IF priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'no_actions')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'no_move')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'helpless')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'unconscious')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'dying')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'stable')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'dead') THEN
    RAISE EXCEPTION 'A condição atual impede levantar-se.';
  END IF;
  IF EXISTS(SELECT 1 FROM priv.srd_aoo_pending_movements
    WHERE campaign_id=p_campaign_id AND status IN ('waiting_reactions','ready_to_commit')) THEN
    RAISE EXCEPTION 'Outra reação de oportunidade já está pendente nesta campanha.';
  END IF;
  v_faction:=lower(coalesce(v_token->>'combat_faction',''));
  IF v_faction NOT IN ('ally','hostile') THEN
    RAISE EXCEPTION 'Configure primeiro a facção do token para identificar inimigos que ameacem seu espaço.';
  END IF;
  IF EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc
    WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='token'
      AND cc.target_id IN (btrim(p_token_id),v_token_id)
      AND cc.condition_id='prone' AND cc.active=true
      AND cc.notes->>'source'='standing_pending') THEN
    RAISE EXCEPTION 'Este levantamento já está pendente.';
  END IF;

  WITH enemies AS (
    SELECT t,
      CASE WHEN coalesce(t->>'melee_reach_ft','') ~ '^[0-9]{1,3}$'
        THEN (t->>'melee_reach_ft')::integer ELSE 5 END reach_ft
    FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
    WHERE (t->>'combat_faction')=CASE WHEN v_faction='ally' THEN 'hostile' ELSE 'ally' END
      AND (t->>'id' IS DISTINCT FROM btrim(p_token_id))
      AND (t->>'key' IS DISTINCT FROM btrim(p_token_id))
      AND coalesce(t->>'gridX','') ~ '^[0-9]{1,3}$'
      AND coalesce(t->>'gridY','') ~ '^[0-9]{1,3}$'
      AND coalesce(t->>'tipo','') IN ('player','npc','monstro')
  ), threatening AS (
    SELECT t,reach_ft,
      priv.srd_grid_footprint_distance_ft(
        (t->>'gridX')::integer,(t->>'gridY')::integer,
        priv.srd_token_grid_footprint(p_campaign_id,coalesce(t->>'key',t->>'id')),
        v_x,v_y,priv.srd_token_grid_footprint(p_campaign_id,p_token_id)
      ) distance_ft
    FROM enemies
  )
  SELECT coalesce(jsonb_agg(jsonb_build_object(
    'token_id',t->>'id','token_key',t->>'key',
    'name',coalesce(t->>'nome',t->>'name','Inimigo'),
    'reach_ft',reach_ft,'distance_ft',distance_ft,
    'last_threatened_step',0,'standing_event',true
  ) ORDER BY distance_ft),'[]'::jsonb)
  INTO v_threats FROM threatening WHERE distance_ft<=reach_ft;

  SELECT coalesce(jsonb_agg(jsonb_build_object(
    'reactor_token_id',coalesce(x->>'token_id',x->>'token_key'),
    'trigger_key','stand:'||v_pending::text||':'||coalesce(x->>'token_id',x->>'token_key'),
    'status','waiting',
    'threat',x
  ) ORDER BY x->>'token_id'),'[]'::jsonb)
  INTO v_reactions FROM jsonb_array_elements(v_threats) x;

  INSERT INTO priv.srd_aoo_pending_movements(
    pending_id,campaign_id,mover_token_id,movement_controller,destination_x,destination_y,
    origin_x,origin_y,combat_round,current_turn,turn_actor_id,threats,pending_reactions,status,created_by
  ) VALUES (
    v_pending,p_campaign_id,btrim(p_token_id),'gm',v_x,v_y,v_x,v_y,
    v_round,v_turn,btrim(p_token_id),
    jsonb_build_array(jsonb_build_object('standing_event','stand_up','token_id',btrim(p_token_id))),
    coalesce(v_reactions,'[]'::jsonb),'waiting_reactions',auth.uid()
  );
  RETURN jsonb_build_object('pending',true,'pending_id',v_pending,'event','stand_up',
    'token_id',btrim(p_token_id),'threats',v_threats,'pending_reactions',v_reactions,
    'requires_reactions',jsonb_array_length(coalesce(v_reactions,'[]'::jsonb))>0);
END;
$fn$;
REVOKE ALL ON FUNCTION priv.srd_iniciar_levantar_caido_srd(bigint,text) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION priv.srd_iniciar_levantar_caido_srd(bigint,text) TO authenticated;

CREATE OR REPLACE FUNCTION priv.srd_resolver_levantar_caido_apos_aoo_srd(
  p_campaign_id bigint,p_pending_id uuid
) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path=pg_catalog,public,priv,pg_temp
AS $fn$
DECLARE
  v_pending priv.srd_aoo_pending_movements%ROWTYPE;
  v_campaign public.campaigns%ROWTYPE;
  v_token jsonb; v_count integer;
  v_round integer; v_actions jsonb; v_by jsonb; v_token_actions jsonb;
  v_key text; v_condition_count integer;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode concluir o levantamento.';
  END IF;
  SELECT * INTO v_pending FROM priv.srd_aoo_pending_movements
  WHERE campaign_id=p_campaign_id AND pending_id=p_pending_id FOR UPDATE;
  IF NOT FOUND OR v_pending.status<>'waiting_reactions'
     OR NOT (v_pending.threats @> '[{"standing_event":"stand_up"}]'::jsonb) THEN
    RAISE EXCEPTION 'Levantamento pendente não encontrado.';
  END IF;
  IF EXISTS(SELECT 1 FROM jsonb_array_elements(v_pending.pending_reactions) r
    WHERE r->>'status' IN ('waiting','reserved','attack_started','hit_pending_damage')) THEN
    RAISE EXCEPTION 'Resolva todas as reações de oportunidade antes de concluir o levantamento.';
  END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND OR upper(coalesce(v_campaign.state,''))<>'COMBATE'
     OR coalesce(v_campaign.combat_data->>'active','false')<>'true'
     OR greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
     OR coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn THEN
    RAISE EXCEPTION 'O combate avançou; o levantamento precisa ser reavaliado.';
  END IF;
  SELECT count(*)::integer,(array_agg(t))[1] INTO v_count,v_token
  FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  WHERE t->>'id'=v_pending.mover_token_id OR t->>'key'=v_pending.mover_token_id;
  IF v_count<>1 THEN RAISE EXCEPTION 'Token do levantamento ausente ou duplicado.'; END IF;
  IF priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'no_actions')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'no_move')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'dying')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'stable')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'dead')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'unconscious') THEN
    RAISE EXCEPTION 'O alvo não pode levantar-se após as reações.';
  END IF;
  IF NOT EXISTS(SELECT 1 FROM public.srd_campaign_conditions
    WHERE campaign_id=p_campaign_id AND target_kind='token'
      AND target_id IN (v_pending.mover_token_id,coalesce(v_token->>'key',v_token->>'id'))
      AND condition_id='prone' AND active=true) THEN
    RAISE EXCEPTION 'O alvo não está mais Caído.';
  END IF;

  v_round:=v_pending.combat_round;
  v_actions:=v_campaign.combat_data->'action_economy';
  IF jsonb_typeof(v_actions)='object' AND coalesce(v_actions->>'round','')=v_round::text
     AND jsonb_typeof(v_actions->'by_character')='object' THEN
    v_by:=v_actions->'by_character';
  ELSE v_by:='{}'::jsonb; END IF;
  v_key:=v_pending.mover_token_id;
  v_token_actions:=CASE WHEN jsonb_typeof(v_by->v_key)='object' THEN v_by->v_key ELSE '{}'::jsonb END;
  IF coalesce((v_token_actions->>'movimento')::boolean,false) THEN
    RAISE EXCEPTION 'A ação de movimento deste combatente já foi usada.';
  END IF;
  IF priv.srd_condition_has_flag(p_campaign_id,'token',v_key,'one_move_or_standard')
     AND coalesce((v_token_actions->>'padrao')::boolean,false) THEN
    RAISE EXCEPTION 'As condições impedem gastar movimento depois de uma ação padrão.';
  END IF;
  v_token_actions:=v_token_actions||jsonb_build_object('movimento',true);
  v_by:=jsonb_set(v_by,ARRAY[v_key],v_token_actions,true);
  v_actions:=jsonb_build_object('round',v_round,'by_character',v_by);
  UPDATE public.campaigns SET combat_data=coalesce(combat_data,'{}'::jsonb)||
    jsonb_build_object('action_economy',v_actions) WHERE id=p_campaign_id;

  UPDATE public.srd_campaign_conditions SET active=false
  WHERE campaign_id=p_campaign_id AND target_kind='token'
    AND target_id IN (v_pending.mover_token_id,coalesce(v_token->>'key',v_token->>'id'))
    AND condition_id='prone' AND active=true;
  UPDATE priv.srd_aoo_pending_movements SET status='committed',committed_at=now(),updated_at=now()
  WHERE pending_id=p_pending_id AND campaign_id=p_campaign_id;
  PERFORM priv.log(p_campaign_id,'COMBAT_CONDITION',jsonb_build_object(
    'condition','prone','action','removed','reason','stand_up',
    'token_id',v_pending.mover_token_id,'action_consumed','movimento',
    'round',v_round,'reactions',v_pending.pending_reactions
  ));
  RETURN jsonb_build_object('ok',true,'stood_up',true,'token_id',v_pending.mover_token_id,
    'action_consumed','movimento','round',v_round,'reactions',v_pending.pending_reactions);
END;
$fn$;
REVOKE ALL ON FUNCTION priv.srd_resolver_levantar_caido_apos_aoo_srd(bigint,uuid) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION priv.srd_resolver_levantar_caido_apos_aoo_srd(bigint,uuid) TO authenticated;

CREATE OR REPLACE FUNCTION public.srd_iniciar_levantar_caido_srd(p_campaign_id bigint,p_token_id text)
RETURNS jsonb LANGUAGE sql SECURITY INVOKER SET search_path=public,priv,pg_temp
AS $fn$ SELECT priv.srd_iniciar_levantar_caido_srd(p_campaign_id,p_token_id); $fn$;
REVOKE ALL ON FUNCTION public.srd_iniciar_levantar_caido_srd(bigint,text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.srd_iniciar_levantar_caido_srd(bigint,text) TO authenticated;

CREATE OR REPLACE FUNCTION public.srd_resolver_levantar_caido_apos_aoo_srd(p_campaign_id bigint,p_pending_id uuid)
RETURNS jsonb LANGUAGE sql SECURITY INVOKER SET search_path=public,priv,pg_temp
AS $fn$ SELECT priv.srd_resolver_levantar_caido_apos_aoo_srd(p_campaign_id,p_pending_id); $fn$;
REVOKE ALL ON FUNCTION public.srd_resolver_levantar_caido_apos_aoo_srd(bigint,uuid) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.srd_resolver_levantar_caido_apos_aoo_srd(bigint,uuid) TO authenticated;
