CREATE OR REPLACE FUNCTION priv.consumir_acao_token_gm_srd_impl(p_campaign_id bigint, p_token_id text, p_acao text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
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
 v_round integer; v_tokens jsonb; v_token jsonb; v_token_index bigint; v_linked_character_id text; v_token_count integer; v_hp integer; v_max_hp integer;
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
 PERFORM priv.srd_validate_surprise_action(p_campaign_id,btrim(p_token_id),v_action);
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
 v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END;
 SELECT t.token INTO v_token FROM jsonb_array_elements(v_tokens) t(token)
 WHERE t.token->>'id'=btrim(p_token_id) LIMIT 1;
 v_linked_character_id:=nullif(v_token->>'sourceCharacterId','');
 IF priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'no_actions')
    OR (v_linked_character_id IS NOT NULL AND priv.srd_condition_has_flag(p_campaign_id,'character',v_linked_character_id,'no_actions')) THEN
  RAISE EXCEPTION 'A condição atual impede qualquer ação.';
 END IF;
 IF v_action<>'movimento' AND (
    priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'only_move_action')
    OR (v_linked_character_id IS NOT NULL AND priv.srd_condition_has_flag(p_campaign_id,'character',v_linked_character_id,'only_move_action'))
 ) THEN
  RAISE EXCEPTION 'A condição atual permite somente uma ação de movimento.';
 END IF;
 v_round:=CASE WHEN coalesce(v_combat->>'round','') ~ '^[0-9]+$' THEN greatest(1,(v_combat->>'round')::integer) ELSE 1 END;
 v_action_state:=v_combat->'action_economy';
 IF jsonb_typeof(v_action_state)='object' AND coalesce(v_action_state->>'round','')=v_round::text AND jsonb_typeof(v_action_state->'by_character')='object' THEN
  v_by_token:=v_action_state->'by_character';
 ELSE v_by_token:='{}'::jsonb; END IF;
 v_token_actions:=CASE WHEN jsonb_typeof(v_by_token->btrim(p_token_id))='object' THEN v_by_token->btrim(p_token_id) ELSE '{}'::jsonb END;
 IF (priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'one_move_or_standard')
     OR (v_linked_character_id IS NOT NULL AND priv.srd_condition_has_flag(p_campaign_id,'character',v_linked_character_id,'one_move_or_standard')))
    AND v_action IN ('padrao','movimento')
    AND (coalesce(v_token_actions->>'padrao','false')='true' OR coalesce(v_token_actions->>'movimento','false')='true') THEN
  RAISE EXCEPTION 'A condição permite apenas uma ação padrão ou de movimento por rodada.';
 END IF;
 IF coalesce(v_token_actions->>v_action,'false')='true' THEN RAISE EXCEPTION 'Esta ação do token já foi usada nesta rodada.'; END IF;
 v_token_actions:=v_token_actions||jsonb_build_object(v_action,true);
 v_by_token:=jsonb_set(v_by_token,ARRAY[btrim(p_token_id)],v_token_actions,true);
 v_action_state:=jsonb_build_object('round',v_round,'by_character',v_by_token);
 v_combat:=v_combat||jsonb_build_object('action_economy',v_action_state);
 IF v_action='padrao' AND priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'strenuous_action_cost_1hp') THEN
  v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END;
  SELECT count(*)::integer,min(t.ordinality),(array_agg(t.token ORDER BY t.ordinality))[1]
    INTO v_token_count,v_token_index,v_token FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality)
   WHERE t.token->>'id'=btrim(p_token_id) AND t.token->>'tipo'='npc';
  IF v_token_count=1 AND COALESCE(v_token->>'hp','') ~ '^[0-9]{1,6}$' AND (v_token->>'hp')::integer=0 THEN
   v_hp:=-1; v_max_hp:=NULLIF(v_token->>'maxHp','')::integer;
   v_token:=v_token||jsonb_build_object('hp',v_hp);
   SELECT COALESCE(jsonb_agg(CASE WHEN t.ordinality=v_token_index THEN v_token ELSE t.token END ORDER BY t.ordinality),'[]'::jsonb) INTO v_tokens
     FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality);
   UPDATE public.campaigns SET cba_data=COALESCE(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens) WHERE id=p_campaign_id;
   IF v_max_hp IS NOT NULL AND v_max_hp>0 AND NULLIF(BTRIM(v_token->>'sourceCharacterId'),'') IS NOT NULL THEN
    PERFORM priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,v_hp,v_max_hp,false);
   END IF;
  END IF;
 END IF;
 UPDATE public.campaigns SET combat_data=v_combat WHERE id=p_campaign_id;
 RETURN jsonb_build_object('combat_data',v_combat,'token_id',btrim(p_token_id),'action',v_action,'round',v_round);
END;
$function$
;
create or replace function public.consumir_acao_token_gm_srd(p_campaign_id bigint,p_token_id text,p_acao text)
returns jsonb language sql security invoker
set search_path=pg_catalog,public,priv,pg_temp
as $wrapper$ select priv.consumir_acao_token_gm_srd_impl(p_campaign_id,p_token_id,p_acao); $wrapper$;
revoke all on function priv.consumir_acao_token_gm_srd_impl(bigint,text,text) from public,anon;
grant execute on function priv.consumir_acao_token_gm_srd_impl(bigint,text,text) to authenticated;
revoke all on function public.consumir_acao_token_gm_srd(bigint,text,text) from public,anon;
grant execute on function public.consumir_acao_token_gm_srd(bigint,text,text) to authenticated;
CREATE OR REPLACE FUNCTION priv.consumir_acao_rodada_completa_srd_impl(p_campaign_id bigint, p_actor_id text, p_actor_kind text DEFAULT 'character'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_user uuid := auth.uid();
  v_campaign public.campaigns%rowtype;
  v_combat jsonb;
  v_order jsonb;
  v_actor jsonb;
  v_current_turn integer;
  v_round integer;
  v_kind text := lower(btrim(coalesce(p_actor_kind, 'character')));
  v_target_kind text;
  v_linked_character_id text;
  v_action_state jsonb;
  v_by_actor jsonb;
  v_actor_actions jsonb;
  v_movement jsonb;
begin
  if v_user is null then
    raise exception 'É necessário estar autenticado.';
  end if;
  if nullif(btrim(p_actor_id), '') is null then
    raise exception 'O identificador do ator é obrigatório.';
  end if;
  if v_kind not in ('character', 'token') then
    raise exception 'Tipo de ator inválido.';
  end if;

  select c.* into v_campaign
  from public.campaigns c
  where c.id = p_campaign_id
  for update;
  if not found or upper(coalesce(v_campaign.state, '')) <> 'COMBATE' then
    raise exception 'A campanha não está em combate.';
  end if;

  v_combat := coalesce(v_campaign.combat_data, '{}'::jsonb);
  if lower(coalesce(v_combat->>'active', 'false')) <> 'true' then
    raise exception 'A iniciativa não está ativa.';
  end if;
  v_order := case when jsonb_typeof(v_combat->'turn_order') = 'array'
    then v_combat->'turn_order' else '[]'::jsonb end;
  if jsonb_array_length(v_order) = 0
     or coalesce(v_combat->>'current_turn', '') !~ '^[0-9]+$' then
    raise exception 'A ordem de iniciativa ou o turno atual é inválido.';
  end if;
  v_current_turn := (v_combat->>'current_turn')::integer;
  if v_current_turn < 0 or v_current_turn >= jsonb_array_length(v_order) then
    raise exception 'O índice do turno atual está fora da ordem de iniciativa.';
  end if;
  v_actor := v_order->v_current_turn;
  PERFORM priv.srd_validate_surprise_action(p_campaign_id,BTRIM(p_actor_id),'rodada_completa');
  if v_actor->>'id' is distinct from btrim(p_actor_id) then
    raise exception 'Somente o ator cujo turno está ativo pode executar uma ação de rodada completa.';
  end if;

  if v_kind = 'character' then
    v_target_kind := 'character';
    if coalesce(lower(v_actor->>'is_monster'), 'false') = 'true'
       or not exists (
         select 1 from public.characters ch
         join public.members m on m.campaign_id = ch.campaign_id
           and m.user_id = ch.user_id and m.role = 'PLAYER'
         where ch.id::text = btrim(p_actor_id)
           and ch.campaign_id = p_campaign_id
           and ch.user_id = v_user
       ) then
      raise exception 'A ficha não pertence a este jogador ou não está no turno dele.';
    end if;
  else
    v_target_kind := 'token';
    if not exists (
      select 1 from public.members m
      where m.campaign_id = p_campaign_id and m.user_id = v_user and m.role = 'GM'
    ) then
      raise exception 'Somente o Mestre pode coordenar tokens controlados por ele.';
    end if;
    if coalesce(lower(v_actor->>'is_monster'), 'false') <> 'true' then
      raise exception 'O token não está registrado como ator do Mestre na iniciativa.';
    end if;
    if not exists (
      select 1
      from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens', '[]'::jsonb)) t(token)
      where t.token->>'id' = btrim(p_actor_id)
        and (
          t.token->>'tipo' in ('npc', 'monstro')
          or (
            t.token->>'tipo' = 'player'
            and exists (
              select 1 from public.characters ch
              where ch.id::text = btrim(p_actor_id)
                and ch.user_id = v_user and ch.campaign_id = p_campaign_id
            )
          )
        )
    ) then
      raise exception 'Este token não é controlado pelo Mestre.';
    end if;
    select nullif(t.token->>'sourceCharacterId','') into v_linked_character_id
    from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t(token)
    where t.token->>'id'=btrim(p_actor_id) and t.token->>'tipo'='npc'
    limit 1;
  end if;

  if priv.srd_condition_has_flag(p_campaign_id, v_target_kind, btrim(p_actor_id), 'no_actions')
     or (v_linked_character_id is not null and priv.srd_condition_has_flag(p_campaign_id,'character',v_linked_character_id,'no_actions')) then
    raise exception 'A condição atual impede qualquer ação.';
  end if;
  if priv.srd_condition_has_flag(p_campaign_id, v_target_kind, btrim(p_actor_id), 'no_full_round')
     or (v_linked_character_id is not null and priv.srd_condition_has_flag(p_campaign_id,'character',v_linked_character_id,'no_full_round')) then
    raise exception 'A condição atual impede ações de rodada completa.';
  end if;
  if priv.srd_condition_has_flag(p_campaign_id, v_target_kind, btrim(p_actor_id), 'only_move_action')
     or priv.srd_condition_has_flag(p_campaign_id, v_target_kind, btrim(p_actor_id), 'one_move_or_standard')
     or (v_linked_character_id is not null and (
       priv.srd_condition_has_flag(p_campaign_id,'character',v_linked_character_id,'only_move_action')
       or priv.srd_condition_has_flag(p_campaign_id,'character',v_linked_character_id,'one_move_or_standard')
     )) then
    raise exception 'A condição atual não permite uma ação de rodada completa.';
  end if;

  v_round := case when coalesce(v_combat->>'round', '') ~ '^[0-9]+$'
    then greatest(1, (v_combat->>'round')::integer) else 1 end;
  v_action_state := v_combat->'action_economy';
  if jsonb_typeof(v_action_state) = 'object'
     and coalesce(v_action_state->>'round', '') = v_round::text
     and jsonb_typeof(v_action_state->'by_character') = 'object' then
    v_by_actor := v_action_state->'by_character';
  else
    v_by_actor := '{}'::jsonb;
  end if;
  v_actor_actions := case when jsonb_typeof(v_by_actor->btrim(p_actor_id)) = 'object'
    then v_by_actor->btrim(p_actor_id) else '{}'::jsonb end;

  if coalesce(v_actor_actions->>'padrao', 'false') = 'true'
     or coalesce(v_actor_actions->>'movimento', 'false') = 'true'
     or coalesce(v_actor_actions->>'ataque_total', 'false') = 'true' then
    raise exception 'A ação padrão ou de movimento já foi usada; a ação de rodada completa não está disponível.';
  end if;

  v_movement := v_combat->'movement_usage';
  if jsonb_typeof(v_movement) = 'object'
     and v_movement->>'character_id' = btrim(p_actor_id)
     and v_movement->>'round' = v_round::text
     and v_movement->>'current_turn' = v_current_turn::text
     and coalesce(v_movement->>'moved_squares', '0') ~ '^[0-9]+$'
     and (v_movement->>'moved_squares')::integer > 0 then
    raise exception 'O ator já se movimentou nesta rodada; não pode iniciar uma ação de rodada completa.';
  end if;

  v_actor_actions := v_actor_actions || jsonb_build_object(
    'padrao', true,
    'movimento', true,
    'ataque_total', true
  );
  v_by_actor := jsonb_set(v_by_actor, array[btrim(p_actor_id)], v_actor_actions, true);
  v_action_state := jsonb_build_object('round', v_round, 'by_character', v_by_actor);
  v_combat := v_combat || jsonb_build_object('action_economy', v_action_state);

  if v_kind = 'character'
     and priv.srd_condition_has_flag(p_campaign_id, 'character', btrim(p_actor_id), 'strenuous_action_cost_1hp') then
    update public.srd_character_sheets
       set pv_atual = -1
     where character_id::text = btrim(p_actor_id)
       and coalesce(pv_atual, 0) = 0;
    if found then
      perform priv.srd_sync_character_vital_condition(btrim(p_actor_id), -1, false);
    end if;
  end if;

  update public.campaigns set combat_data = v_combat where id = p_campaign_id;
  return jsonb_build_object(
    'combat_data', v_combat,
    'action_economy', v_action_state,
    'round', v_round,
    'actor_id', btrim(p_actor_id),
    'actor_kind', v_kind,
    'action', 'ataque_total'
  );
end;
$function$
;
create or replace function public.consumir_acao_rodada_completa_srd(p_campaign_id bigint,p_actor_id text,p_actor_kind text DEFAULT 'character')
returns jsonb language sql security invoker
set search_path=pg_catalog,public,priv,pg_temp
as $wrapper$ select priv.consumir_acao_rodada_completa_srd_impl(p_campaign_id,p_actor_id,p_actor_kind); $wrapper$;
revoke all on function priv.consumir_acao_rodada_completa_srd_impl(bigint,text,text) from public,anon;
grant execute on function priv.consumir_acao_rodada_completa_srd_impl(bigint,text,text) to authenticated;
revoke all on function public.consumir_acao_rodada_completa_srd(bigint,text,text) from public,anon;
grant execute on function public.consumir_acao_rodada_completa_srd(bigint,text,text) to authenticated;
