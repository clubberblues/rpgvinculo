create or replace function public.consumir_acao_rodada_completa_srd(
  p_campaign_id bigint,
  p_actor_id text,
  p_actor_kind text default 'character'
)
returns jsonb
language plpgsql
security definer
set search_path = public, priv, pg_temp
as $function$
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
  end if;

  if priv.srd_condition_has_flag(p_campaign_id, v_target_kind, btrim(p_actor_id), 'no_actions') then
    raise exception 'A condição atual impede qualquer ação.';
  end if;
  if priv.srd_condition_has_flag(p_campaign_id, v_target_kind, btrim(p_actor_id), 'no_full_round') then
    raise exception 'A condição atual impede ações de rodada completa.';
  end if;
  if priv.srd_condition_has_flag(p_campaign_id, v_target_kind, btrim(p_actor_id), 'only_move_action')
     or priv.srd_condition_has_flag(p_campaign_id, v_target_kind, btrim(p_actor_id), 'one_move_or_standard') then
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
$function$;

revoke all on function public.consumir_acao_rodada_completa_srd(bigint, text, text) from public;
grant execute on function public.consumir_acao_rodada_completa_srd(bigint, text, text) to authenticated;