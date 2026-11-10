
create or replace function public.srd_consultar_movimento_aoo_pendente_srd(
  p_campaign_id bigint,
  p_pending_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, priv, pg_temp
as $function$
declare v_pending priv.srd_aoo_pending_movements%rowtype;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode consultar movimentos aguardando ataques de oportunidade.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id;
  if not found then raise exception 'Movimento pendente não encontrado.'; end if;
  return jsonb_build_object(
    'pending_id',v_pending.pending_id,'status',v_pending.status,
    'mover_token_id',v_pending.mover_token_id,
    'movement_controller',v_pending.movement_controller,
    'origin',jsonb_build_array(v_pending.origin_x,v_pending.origin_y),
    'destination',jsonb_build_array(v_pending.destination_x,v_pending.destination_y),
    'round',v_pending.combat_round,'current_turn',v_pending.current_turn,
    'turn_actor_id',v_pending.turn_actor_id,
    'threats',v_pending.threats,'pending_reactions',v_pending.pending_reactions,
    'created_at',v_pending.created_at
  );
end;
$function$;

create or replace function public.srd_reservar_reacao_movimento_aoo_srd(
  p_campaign_id bigint,
  p_pending_id uuid,
  p_reactor_token_id text
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, priv, pg_temp
as $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_profile jsonb;
  v_character_id text;
  v_token_type text;
  v_flat_footed boolean:=false;
  v_disabled boolean:=false;
  v_index bigint;
  v_reaction jsonb;
  v_trigger text;
  v_reservation jsonb;
  v_updated jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode autorizar a reação.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id
  for update;
  if not found or v_pending.status<>'waiting_reactions' then
    raise exception 'Movimento não está aguardando reações.';
  end if;

  select * into v_campaign from public.campaigns
  where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
     or coalesce(v_campaign.combat_data->>'active','false')<>'true'
     or coalesce(v_campaign.combat_data->>'round','') !~ '^[0-9]+$'
     or greatest(1,(v_campaign.combat_data->>'round')::integer)<>v_pending.combat_round
     or coalesce(v_campaign.combat_data->>'current_turn','') !~ '^[0-9]+$'
     or (v_campaign.combat_data->>'current_turn')::integer<>v_pending.current_turn then
    raise exception 'O combate avançou desde a solicitação; o movimento precisa ser reavaliado.';
  end if;

  select ordinality, value into v_index,v_reaction
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality
  where coalesce(value->>'reactor_token_id','')=btrim(p_reactor_token_id)
  limit 1;
  if v_reaction is null then raise exception 'Este token não está entre os combatentes ameaçadores detectados.'; end if;
  if v_reaction->>'status'='reserved' then
    return jsonb_build_object('reserved',true,'duplicate',true,
      'reservation_id',v_reaction->>'reservation_id',
      'pending_id',p_pending_id,'reactor_token_id',p_reactor_token_id);
  end if;
  if v_reaction->>'status'<>'waiting' then raise exception 'Esta reação já foi processada.'; end if;

  select t->>'tipo' into v_token_type
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id)
  limit 1;
  if v_token_type is null then raise exception 'Token reator não existe mais na cena.'; end if;
  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_reactor_token_id));
  v_character_id:=v_profile->>'character_id';

  v_disabled :=
    priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'no_actions')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'helpless')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stunned')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'unconscious')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dying')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stable')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dead');
  if v_character_id is not null then
    v_disabled:=v_disabled
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_actions')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'helpless')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'stunned')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'unconscious')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'dying')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'stable')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'dead');
  end if;
  if v_disabled then
    update priv.srd_aoo_pending_movements
    set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],
      v_reaction||jsonb_build_object('status','ineligible','reason','reactor_cannot_take_actions'),
      false),updated_at=now()
    where pending_id=p_pending_id;
    return jsonb_build_object('reserved',false,'ineligible',true,
      'reason','reactor_cannot_take_actions','reactor_token_id',p_reactor_token_id);
  end if;

  v_flat_footed:=priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'loses_dex_ac');
  if v_character_id is not null then
    v_flat_footed:=v_flat_footed
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'loses_dex_ac');
  end if;

  v_trigger:=v_reaction->>'trigger_key';
  v_reservation:=public.srd_reservar_ataque_oportunidade_srd(
    p_campaign_id,btrim(p_reactor_token_id),v_trigger,v_flat_footed
  );
  v_updated:=v_reaction||jsonb_build_object(
    'status','reserved',
    'reservation_id',v_reservation->>'reaction_id',
    'reservation_number',v_reservation->'used',
    'reservation_limit',v_reservation->'limit',
    'flat_footed',v_flat_footed
  );
  update priv.srd_aoo_pending_movements
  set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],v_updated,false),
      updated_at=now()
  where pending_id=p_pending_id;
  return jsonb_build_object('reserved',true,'duplicate',coalesce((v_reservation->>'duplicate')::boolean,false),
    'reservation',v_reservation,'pending_id',p_pending_id,
    'reactor_token_id',p_reactor_token_id,'reaction',v_updated);
end;
$function$;

revoke all on function public.srd_consultar_movimento_aoo_pendente_srd(bigint,uuid) from public,anon;
grant execute on function public.srd_consultar_movimento_aoo_pendente_srd(bigint,uuid) to authenticated;
revoke all on function public.srd_reservar_reacao_movimento_aoo_srd(bigint,uuid,text) from public,anon;
grant execute on function public.srd_reservar_reacao_movimento_aoo_srd(bigint,uuid,text) to authenticated;
