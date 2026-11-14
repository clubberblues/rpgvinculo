CREATE OR REPLACE FUNCTION priv.srd_cancelar_movimento_aoo_pendente_impl(p_campaign_id bigint, p_pending_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare v_pending priv.srd_aoo_pending_movements%rowtype; v_reactions jsonb;
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
  update priv.srd_aoo_attacks set status='cancelled'
  where pending_id=p_pending_id
    and status in ('awaiting_attack_roll','awaiting_critical_confirmation','awaiting_miss_chance','awaiting_damage');
  select coalesce(jsonb_agg(
    case when r.value->>'status' in ('waiting','reserved','attack_started','hit_pending_damage')
      then r.value||jsonb_build_object('status','skipped','skip_reason','movement_cancelled')
      else r.value end order by r.ordinality),'[]'::jsonb)
  into v_reactions
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality r(value,ordinality);
  update priv.srd_aoo_pending_movements
  set status='cancelled',pending_reactions=v_reactions,cancelled_at=now(),updated_at=now()
  where pending_id=p_pending_id;
  return jsonb_build_object('cancelled',true,'pending_id',p_pending_id,
    'mover_token_id',v_pending.mover_token_id,'reactions',v_reactions);
end;
$function$
;
CREATE OR REPLACE FUNCTION priv.srd_encerrar_reacao_aoo_pendente_impl(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_cancel_attack boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_idx bigint;
  v_reaction jsonb;
  v_attack priv.srd_aoo_attacks%rowtype;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode encerrar uma reação pendente.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then
    raise exception 'Movimento não está aguardando reações.';
  end if;
  select ordinality,value into v_idx,v_reaction
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality
  where value->>'reactor_token_id'=btrim(p_reactor_token_id) limit 1;
  if v_reaction is null then raise exception 'Reação não encontrada neste movimento.'; end if;
  if v_reaction->>'status' in ('attack_started','hit_pending_damage') then
    if not p_cancel_attack then
      raise exception 'O ataque já começou; resolva-o ou autorize explicitamente seu cancelamento.';
    end if;
    select * into v_attack from priv.srd_aoo_attacks
    where attack_id=(v_reaction->>'attack_id')::uuid and campaign_id=p_campaign_id for update;
    if not found or v_attack.status not in ('awaiting_attack_roll','awaiting_critical_confirmation','awaiting_miss_chance','awaiting_damage') then
      raise exception 'Ataque não pode ser cancelado neste estado.';
    end if;
    update priv.srd_aoo_attacks set status='cancelled' where attack_id=v_attack.attack_id;
  elsif v_reaction->>'status' not in ('waiting','reserved') then
    raise exception 'Esta reação já foi encerrada.';
  end if;
  update priv.srd_aoo_pending_movements
  set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_idx-1)::text],
      v_reaction||jsonb_build_object('status','skipped','skip_reason',case
        when v_reaction->>'status' in ('reserved','attack_started','hit_pending_damage')
          then 'gm_cancelled_after_reservation' else 'gm_declined_reaction' end),
      false),updated_at=now()
  where pending_id=p_pending_id;
  return jsonb_build_object('closed',true,'pending_id',p_pending_id,
    'reactor_token_id',p_reactor_token_id,'reaction_spent',
    (v_reaction->>'status') in ('reserved','attack_started','hit_pending_damage'));
end;
$function$
;

create or replace function public.srd_cancelar_movimento_aoo_pendente_srd(p_campaign_id bigint,p_pending_id uuid)
returns jsonb language sql security invoker
set search_path=pg_catalog,public,priv,pg_temp
as $function$ select priv.srd_cancelar_movimento_aoo_pendente_impl(p_campaign_id,p_pending_id); $function$;

create or replace function public.srd_encerrar_reacao_aoo_pendente_srd(
 p_campaign_id bigint,p_pending_id uuid,p_reactor_token_id text,p_cancel_attack boolean default false
) returns jsonb language sql security invoker
set search_path=pg_catalog,public,priv,pg_temp
as $function$ select priv.srd_encerrar_reacao_aoo_pendente_impl(p_campaign_id,p_pending_id,p_reactor_token_id,p_cancel_attack); $function$;

revoke all on function priv.srd_cancelar_movimento_aoo_pendente_impl(bigint,uuid) from public,anon;
grant execute on function priv.srd_cancelar_movimento_aoo_pendente_impl(bigint,uuid) to authenticated;
revoke all on function priv.srd_encerrar_reacao_aoo_pendente_impl(bigint,uuid,text,boolean) from public,anon;
grant execute on function priv.srd_encerrar_reacao_aoo_pendente_impl(bigint,uuid,text,boolean) to authenticated;
revoke all on function public.srd_cancelar_movimento_aoo_pendente_srd(bigint,uuid) from public,anon;
grant execute on function public.srd_cancelar_movimento_aoo_pendente_srd(bigint,uuid) to authenticated;
revoke all on function public.srd_encerrar_reacao_aoo_pendente_srd(bigint,uuid,text,boolean) from public,anon;
grant execute on function public.srd_encerrar_reacao_aoo_pendente_srd(bigint,uuid,text,boolean) to authenticated;
