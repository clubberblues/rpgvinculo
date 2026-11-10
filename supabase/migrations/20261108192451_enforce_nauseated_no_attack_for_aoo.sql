
create or replace function public.srd_reservar_reacao_movimento_aoo_srd(
  p_campaign_id bigint,p_pending_id uuid,p_reactor_token_id text
) returns jsonb
language plpgsql
security definer
set search_path=pg_catalog,public,priv,pg_temp
as $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_profile jsonb;
  v_character_id text;
  v_token_type text;
  v_flat_footed boolean:=false;
  v_has_combat_reflexes boolean:=false;
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
  where campaign_id=p_campaign_id and pending_id=p_pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then
    raise exception 'Movimento não está aguardando reações.';
  end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
    or coalesce(v_campaign.combat_data->>'active','false')<>'true'
    or coalesce(v_campaign.combat_data->>'round','') !~ '^[0-9]+$'
    or greatest(1,(v_campaign.combat_data->>'round')::integer)<>v_pending.combat_round
    or coalesce(v_campaign.combat_data->>'current_turn','') !~ '^[0-9]+$'
    or (v_campaign.combat_data->>'current_turn')::integer<>v_pending.current_turn then
    raise exception 'O combate avançou desde a solicitação; o movimento precisa ser reavaliado.';
  end if;
  select ordinality,value into v_index,v_reaction
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality
  where coalesce(value->>'reactor_token_id','')=btrim(p_reactor_token_id) limit 1;
  if v_reaction is null then raise exception 'Este token não está entre os combatentes ameaçadores detectados.'; end if;
  if v_reaction->>'status'='reserved' then
    return jsonb_build_object('reserved',true,'duplicate',true,
      'reservation_id',v_reaction->>'reservation_id','pending_id',p_pending_id,
      'reactor_token_id',p_reactor_token_id);
  end if;
  if v_reaction->>'status'<>'waiting' then raise exception 'Esta reação já foi processada.'; end if;
  select t->>'tipo' into v_token_type
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id) limit 1;
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
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dead')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'no_threaten_squares')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'cannot_attack');
  if v_character_id is not null then
    v_disabled:=v_disabled
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_actions')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'helpless')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'stunned')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'unconscious')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'dying')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'stable')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'dead')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_threaten_squares')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'cannot_attack');
  end if;
  if v_disabled then
    update priv.srd_aoo_pending_movements
    set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],
      v_reaction||jsonb_build_object('status','ineligible','reason','reactor_condition_prevents_aoo'),
      false),updated_at=now()
    where pending_id=p_pending_id;
    return jsonb_build_object('reserved',false,'ineligible',true,
      'reason','reactor_condition_prevents_aoo','reactor_token_id',p_reactor_token_id);
  end if;

  v_flat_footed:=priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'no_aoo');
  if v_character_id is not null then
    v_flat_footed:=v_flat_footed
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_aoo');
  end if;
  if v_flat_footed then
    select exists(
      select 1 from public.srd_character_sheets sh
      cross join lateral jsonb_array_elements(
        case when jsonb_typeof(sh.talentos)='array' then sh.talentos else '[]'::jsonb end
      ) feat
      where sh.character_id::text=v_character_id
        and (lower(coalesce(feat->>'id','')) in
          ('reflexos_de_combate','combat_reflexes','srd35_feat_combat_reflexes')
          or lower(coalesce(feat->>'nome','')) in ('reflexos de combate','combat reflexes'))
    ) into v_has_combat_reflexes;
    if not v_has_combat_reflexes and v_character_id is null then
      select t into v_reaction
      from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
      where t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id) limit 1;
      v_has_combat_reflexes:=concat_ws(',',
        v_reaction->'monsterStats'->>'feats',
        v_reaction->'monsterStats'->>'talentos',
        v_reaction->'monsterStats'->'dados_tecnicos'->'statblock'->>'feats',
        v_reaction->'monsterStats'->'dados_tecnicos'->>'feats'
      ) ~* '(^|[,;[:space:]])combat[[:space:]]+reflexesb?([,;[:space:]]|$)';
    end if;
    if not v_has_combat_reflexes then
      update priv.srd_aoo_pending_movements
      set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],
        v_reaction||jsonb_build_object('status','ineligible',
          'reason','flat_footed_without_combat_reflexes'),false),updated_at=now()
      where pending_id=p_pending_id;
      return jsonb_build_object('reserved',false,'ineligible',true,
        'reason','flat_footed_without_combat_reflexes','reactor_token_id',p_reactor_token_id);
    end if;
  end if;

  v_trigger:=v_reaction->>'trigger_key';
  v_reservation:=public.srd_reservar_ataque_oportunidade_srd(
    p_campaign_id,btrim(p_reactor_token_id),v_trigger,v_flat_footed);
  v_updated:=v_reaction||jsonb_build_object(
    'status','reserved','reservation_id',v_reservation->>'reaction_id',
    'reservation_number',v_reservation->'used','reservation_limit',v_reservation->'limit',
    'flat_footed',v_flat_footed);
  update priv.srd_aoo_pending_movements
  set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],v_updated,false),
      updated_at=now()
  where pending_id=p_pending_id;
  return jsonb_build_object('reserved',true,
    'duplicate',coalesce((v_reservation->>'duplicate')::boolean,false),
    'reservation',v_reservation,'pending_id',p_pending_id,
    'reactor_token_id',p_reactor_token_id,'reaction',v_updated);
end;
$function$;

create or replace function priv.srd_guard_aoo_cannot_attack()
returns trigger
language plpgsql
security definer
set search_path=pg_catalog,public,priv,pg_temp
as $function$
begin
  if new.status in ('awaiting_attack_roll','awaiting_critical_confirmation','awaiting_damage') then
    if priv.srd_condition_has_flag(new.campaign_id,'token',new.actor_token_id,'cannot_attack')
      or (new.actor_character_id is not null and
        priv.srd_condition_has_flag(new.campaign_id,'character',new.actor_character_id::text,'cannot_attack')) then
      raise exception 'A condição atual impede realizar este ataque de oportunidade.';
    end if;
  end if;
  return new;
end;
$function$;
revoke all on function priv.srd_guard_aoo_cannot_attack() from public,anon,authenticated;
drop trigger if exists trg_srd_guard_aoo_cannot_attack on priv.srd_aoo_attacks;
create trigger trg_srd_guard_aoo_cannot_attack
before insert or update of status on priv.srd_aoo_attacks
for each row execute function priv.srd_guard_aoo_cannot_attack();

revoke all on function public.srd_reservar_reacao_movimento_aoo_srd(bigint,uuid,text) from public,anon;
grant execute on function public.srd_reservar_reacao_movimento_aoo_srd(bigint,uuid,text) to authenticated;
