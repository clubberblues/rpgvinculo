
create or replace function public.consumir_acao_completa_token_gm_srd(
  p_campaign_id bigint,
  p_token_id text
) returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, pg_temp
as $function$
declare
  v_user uuid := auth.uid();
  v_campaign public.campaigns%rowtype;
  v_combat jsonb;
  v_order jsonb;
  v_actor jsonb;
  v_action_state jsonb;
  v_by_token jsonb;
  v_token_actions jsonb;
  v_token_count integer;
  v_round integer;
  v_current integer;
begin
  if v_user is null then
    raise exception 'É necessário estar autenticado.';
  end if;
  if coalesce(btrim(p_token_id),'')='' then
    raise exception 'Token inválido.';
  end if;
  if not exists (
    select 1 from public.members m
    where m.campaign_id=p_campaign_id and m.user_id=v_user and m.role='GM'
  ) then
    raise exception 'Somente o Mestre pode consumir ações de tokens controlados por ele.';
  end if;

  select c.* into v_campaign
  from public.campaigns c
  where c.id=p_campaign_id
  for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE' then
    raise exception 'A campanha não está em combate.';
  end if;

  v_combat:=coalesce(v_campaign.combat_data,'{}'::jsonb);
  if coalesce(v_combat->>'active','false')<>'true'
     or coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$' then
    raise exception 'A iniciativa não está ativa ou o turno atual é inválido.';
  end if;
  v_order:=case when jsonb_typeof(v_combat->'turn_order')='array'
    then v_combat->'turn_order' else '[]'::jsonb end;
  v_current:=(v_combat->>'current_turn')::integer;
  if v_current<0 or v_current>=jsonb_array_length(v_order) then
    raise exception 'Índice do turno atual fora da ordem de iniciativa.';
  end if;
  v_actor:=v_order->v_current;
  if v_actor->>'id' is distinct from btrim(p_token_id)
     or coalesce(v_actor->>'is_monster','false')<>'true' then
    raise exception 'O token não pertence ao turno ativo do Mestre.';
  end if;

  select count(*)::integer into v_token_count
  from jsonb_array_elements(case when jsonb_typeof(v_campaign.cba_data->'tokens')='array'
    then v_campaign.cba_data->'tokens' else '[]'::jsonb end) t(token)
  where t.token->>'id'=btrim(p_token_id)
    and coalesce(t.token->>'tipo','') in ('npc','monstro');
  if v_token_count<>1 then
    raise exception 'Token NPC/monstro ausente ou duplicado na cena.';
  end if;

  v_round:=case when coalesce(v_combat->>'round','') ~ '^[0-9]+$'
    then greatest(1,(v_combat->>'round')::integer) else 1 end;
  v_action_state:=v_combat->'action_economy';
  if jsonb_typeof(v_action_state)='object'
     and coalesce(v_action_state->>'round','')=v_round::text
     and jsonb_typeof(v_action_state->'by_character')='object' then
    v_by_token:=v_action_state->'by_character';
  else
    v_by_token:='{}'::jsonb;
  end if;
  v_token_actions:=case when jsonb_typeof(v_by_token->btrim(p_token_id))='object'
    then v_by_token->btrim(p_token_id) else '{}'::jsonb end;

  if coalesce(v_token_actions->>'completa','false')='true'
     or coalesce(v_token_actions->>'padrao','false')='true'
     or coalesce(v_token_actions->>'movimento','false')='true' then
    raise exception 'A ação completa exige que as ações padrão e de movimento ainda estejam disponíveis.';
  end if;

  v_token_actions:=v_token_actions||jsonb_build_object(
    'completa',true,'padrao',true,'movimento',true
  );
  v_by_token:=jsonb_set(v_by_token,array[btrim(p_token_id)],v_token_actions,true);
  v_action_state:=jsonb_build_object('round',v_round,'by_character',v_by_token);
  v_combat:=v_combat||jsonb_build_object('action_economy',v_action_state);

  update public.campaigns set combat_data=v_combat where id=p_campaign_id;

  return jsonb_build_object(
    'campaign_id',p_campaign_id,'token_id',btrim(p_token_id),
    'action','completa','round',v_round,'combat_data',v_combat
  );
end;
$function$;

revoke all on function public.consumir_acao_completa_token_gm_srd(bigint,text) from public, anon;
grant execute on function public.consumir_acao_completa_token_gm_srd(bigint,text) to authenticated;
