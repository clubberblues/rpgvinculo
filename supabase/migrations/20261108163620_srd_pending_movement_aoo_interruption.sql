
create table if not exists priv.srd_aoo_pending_movements (
  pending_id uuid primary key default gen_random_uuid(),
  campaign_id bigint not null references public.campaigns(id) on delete cascade,
  mover_token_id text not null,
  movement_controller text not null check (movement_controller in ('player','gm')),
  destination_x integer not null check (destination_x between 0 and 199),
  destination_y integer not null check (destination_y between 0 and 199),
  origin_x integer not null check (origin_x between 0 and 199),
  origin_y integer not null check (origin_y between 0 and 199),
  combat_round integer not null check (combat_round >= 1),
  current_turn integer not null check (current_turn >= 0),
  turn_actor_id text not null,
  threats jsonb not null default '[]'::jsonb check (jsonb_typeof(threats)='array'),
  pending_reactions jsonb not null default '[]'::jsonb check (jsonb_typeof(pending_reactions)='array'),
  status text not null default 'waiting_reactions'
    check (status in ('waiting_reactions','ready_to_commit','committed','cancelled','expired')),
  created_by uuid not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  committed_at timestamptz,
  cancelled_at timestamptz
);
create unique index if not exists srd_aoo_one_pending_movement_per_campaign
  on priv.srd_aoo_pending_movements(campaign_id)
  where status in ('waiting_reactions','ready_to_commit');
create index if not exists srd_aoo_pending_movements_campaign_status
  on priv.srd_aoo_pending_movements(campaign_id,status,created_at desc);
alter table priv.srd_aoo_pending_movements enable row level security;
revoke all on priv.srd_aoo_pending_movements from public,anon,authenticated;

create or replace function priv.srd_guard_pending_aoo_movement()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public, priv, pg_temp
as $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_old_token jsonb;
  v_new_token jsonb;
  v_commit_id text;
begin
  if new.cba_data is not distinct from old.cba_data then return new; end if;
  select * into v_pending
  from priv.srd_aoo_pending_movements p
  where p.campaign_id=new.id
    and p.status in ('waiting_reactions','ready_to_commit')
  order by p.created_at desc limit 1;
  if not found then return new; end if;

  select t into v_old_token
  from jsonb_array_elements(case when jsonb_typeof(old.cba_data->'tokens')='array'
    then old.cba_data->'tokens' else '[]'::jsonb end) t
  where t->>'id'=v_pending.mover_token_id or t->>'key'=v_pending.mover_token_id
  limit 1;
  select t into v_new_token
  from jsonb_array_elements(case when jsonb_typeof(new.cba_data->'tokens')='array'
    then new.cba_data->'tokens' else '[]'::jsonb end) t
  where t->>'id'=v_pending.mover_token_id or t->>'key'=v_pending.mover_token_id
  limit 1;

  if v_old_token is not null and v_new_token is not null
     and ((v_old_token->>'gridX') is distinct from (v_new_token->>'gridX')
       or (v_old_token->>'gridY') is distinct from (v_new_token->>'gridY')) then
    v_commit_id:=current_setting('app.srd_aoo_pending_commit',true);
    if v_commit_id is distinct from v_pending.pending_id::text then
      raise exception 'Movimento bloqueado: há um ataque de oportunidade pendente de resolução.';
    end if;
  end if;
  return new;
end;
$function$;
revoke all on function priv.srd_guard_pending_aoo_movement() from public,anon,authenticated;
drop trigger if exists trg_srd_guard_pending_aoo_movement on public.campaigns;
create trigger trg_srd_guard_pending_aoo_movement
before update of cba_data on public.campaigns
for each row execute function priv.srd_guard_pending_aoo_movement();

create or replace function public.srd_solicitar_movimento_com_aoo_srd(
  p_campaign_id bigint,
  p_mover_token_id text,
  p_destination_x integer,
  p_destination_y integer,
  p_controller text default 'player'
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, priv, pg_temp
as $function$
declare
  v_campaign public.campaigns%rowtype;
  v_combat jsonb;
  v_order jsonb;
  v_round integer;
  v_turn integer;
  v_actor_id text;
  v_token jsonb;
  v_token_type text;
  v_pos_x integer;
  v_pos_y integer;
  v_detection jsonb;
  v_pending_id uuid;
  v_reactions jsonb;
begin
  if auth.uid() is null then raise exception 'É necessário estar autenticado.'; end if;
  if p_controller not in ('player','gm') then raise exception 'Controlador de movimento inválido.'; end if;
  if p_controller='gm' and public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode solicitar movimento de token sob seu controle.';
  end if;

  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found then raise exception 'Campanha não encontrada.'; end if;
  v_combat:=coalesce(v_campaign.combat_data,'{}'::jsonb);
  if upper(coalesce(v_campaign.state,''))<>'COMBATE'
     or coalesce(v_combat->>'active','false')<>'true' then
    return jsonb_build_object('pending',false,'requires_aoo',false,
      'reason','combat_not_active','continue_with_existing_movement_rpc',true);
  end if;
  if coalesce(v_combat->>'round','') !~ '^[0-9]+$'
     or coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$' then
    raise exception 'Rodada ou turno de combate inválido.';
  end if;
  v_round:=greatest(1,(v_combat->>'round')::integer);
  v_turn:=(v_combat->>'current_turn')::integer;
  v_order:=case when jsonb_typeof(v_combat->'turn_order')='array'
    then v_combat->'turn_order' else '[]'::jsonb end;
  if v_turn<0 or v_turn>=jsonb_array_length(v_order) then
    raise exception 'Índice do turno atual inválido.';
  end if;
  v_actor_id:=v_order->v_turn->>'id';

  select t into v_token
  from jsonb_array_elements(case when jsonb_typeof(v_campaign.cba_data->'tokens')='array'
    then v_campaign.cba_data->'tokens' else '[]'::jsonb end) t
  where t->>'id'=btrim(p_mover_token_id) or t->>'key'=btrim(p_mover_token_id)
  limit 1;
  if v_token is null then raise exception 'Token não encontrado na cena.'; end if;
  v_token_type:=v_token->>'tipo';
  if coalesce(v_token->>'gridX','') !~ '^[0-9]{1,3}$'
     or coalesce(v_token->>'gridY','') !~ '^[0-9]{1,3}$' then
    raise exception 'Posição atual do token inválida.';
  end if;
  v_pos_x:=(v_token->>'gridX')::integer;
  v_pos_y:=(v_token->>'gridY')::integer;

  if p_controller='player' then
    if v_token_type<>'player'
       or v_actor_id is distinct from btrim(p_mover_token_id)
       or not exists(select 1 from public.characters c
         where c.id::text=btrim(p_mover_token_id)
           and c.campaign_id=p_campaign_id and c.user_id=auth.uid()) then
      raise exception 'O personagem não é seu ou não está no turno ativo.';
    end if;
  else
    if v_actor_id is distinct from btrim(p_mover_token_id)
       or v_token_type not in ('npc','monstro','player') then
      raise exception 'O token não está no turno ativo ou não pode ser controlado pelo Mestre.';
    end if;
  end if;

  v_detection:=public.srd_detectar_saida_alcance_ameacado_srd(
    p_campaign_id,btrim(p_mover_token_id),p_destination_x,p_destination_y);
  if coalesce((v_detection->>'detected')::boolean,false) is not true then
    return jsonb_build_object('pending',false,'requires_aoo',false,
      'reason',coalesce(v_detection->>'reason','no_threat_detected'),
      'detection',v_detection,'continue_with_existing_movement_rpc',true);
  end if;

  if exists(select 1 from priv.srd_aoo_pending_movements
    where campaign_id=p_campaign_id and status in ('waiting_reactions','ready_to_commit')) then
    raise exception 'Já existe um movimento aguardando resolução de ataques de oportunidade nesta campanha.';
  end if;

  v_reactions:=(
    select coalesce(jsonb_agg(jsonb_build_object(
      'reactor_token_id',coalesce(x->>'token_id',x->>'token_key'),
      'trigger_key',concat('move:',p_mover_token_id,':',v_round,':',p_destination_x,':',p_destination_y,':',coalesce(x->>'token_id',x->>'token_key')),
      'status','waiting',
      'threat',x
    )),'[]'::jsonb)
    from jsonb_array_elements(coalesce(v_detection->'threats','[]'::jsonb)) x
  );
  insert into priv.srd_aoo_pending_movements(
    campaign_id,mover_token_id,movement_controller,destination_x,destination_y,
    origin_x,origin_y,combat_round,current_turn,turn_actor_id,threats,
    pending_reactions,created_by
  ) values (
    p_campaign_id,btrim(p_mover_token_id),p_controller,p_destination_x,p_destination_y,
    v_pos_x,v_pos_y,v_round,v_turn,v_actor_id,
    coalesce(v_detection->'threats','[]'::jsonb),v_reactions,auth.uid()
  ) returning pending_id into v_pending_id;

  return jsonb_build_object('pending',true,'requires_aoo',true,
    'pending_id',v_pending_id,'status','waiting_reactions',
    'round',v_round,'current_turn',v_turn,'mover_token_id',p_mover_token_id,
    'from',jsonb_build_array(v_pos_x,v_pos_y),
    'to',jsonb_build_array(p_destination_x,p_destination_y),
    'pending_reactions',v_reactions,
    'movement_committed',false);
end;
$function$;

create or replace function public.srd_cancelar_movimento_aoo_pendente_srd(
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
    raise exception 'Somente o Mestre pode cancelar o movimento pendente.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where pending_id=p_pending_id and campaign_id=p_campaign_id for update;
  if not found then raise exception 'Movimento pendente não encontrado.'; end if;
  if v_pending.status not in ('waiting_reactions','ready_to_commit') then
    raise exception 'Este movimento não está mais pendente.';
  end if;
  update priv.srd_aoo_pending_movements
  set status='cancelled',cancelled_at=now(),updated_at=now()
  where pending_id=p_pending_id;
  return jsonb_build_object('cancelled',true,'pending_id',p_pending_id,
    'mover_token_id',v_pending.mover_token_id);
end;
$function$;

revoke all on function public.srd_solicitar_movimento_com_aoo_srd(bigint,text,integer,integer,text) from public,anon;
grant execute on function public.srd_solicitar_movimento_com_aoo_srd(bigint,text,integer,integer,text) to authenticated;
revoke all on function public.srd_cancelar_movimento_aoo_pendente_srd(bigint,uuid) from public,anon;
grant execute on function public.srd_cancelar_movimento_aoo_pendente_srd(bigint,uuid) to authenticated;
