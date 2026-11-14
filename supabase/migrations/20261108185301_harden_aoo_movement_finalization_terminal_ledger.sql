CREATE OR REPLACE FUNCTION public.srd_finalizar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_preview jsonb;
  v_remaining integer;
  v_user uuid:=auth.uid();
begin
  if v_user is null then raise exception 'É necessário estar autenticado.'; end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then raise exception 'Movimento pendente não está ativo.'; end if;

  if public.my_role(p_campaign_id) is distinct from 'GM'
     and (v_pending.movement_controller='gm' or v_user<>v_pending.created_by) then
    raise exception 'Somente o Mestre ou o jogador que solicitou o movimento pode concluí-lo.';
  end if;

  if exists(
    select 1 from jsonb_array_elements(v_pending.pending_reactions) r
    where coalesce(r->>'status','') not in ('ineligible','skipped','miss','damage_applied')
  ) then
    raise exception 'Ainda existem reações de oportunidade sem estado terminal válido.';
  end if;

  if exists(
    select 1 from priv.srd_aoo_attacks a
    where a.pending_id=p_pending_id and a.campaign_id=p_campaign_id
      and a.status not in ('miss','damage_applied','cancelled')
  ) then
    raise exception 'Ainda existe um ataque de oportunidade sem resolução completa.';
  end if;

  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
     or coalesce(v_campaign.combat_data->>'active','false')<>'true'
     or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
     or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'O combate avançou; solicite uma nova movimentação.';
  end if;
  if not exists(select 1 from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
    where (t->>'id'=v_pending.mover_token_id or t->>'key'=v_pending.mover_token_id)
      and coalesce(t->>'gridX','')=v_pending.origin_x::text
      and coalesce(t->>'gridY','')=v_pending.origin_y::text) then
    raise exception 'A posição original do token mudou; movimento não pode ser concluído.';
  end if;

  perform set_config('app.srd_aoo_pending_commit',p_pending_id::text,true);
  if v_pending.movement_controller='player' and v_user=v_pending.created_by
     and public.my_role(p_campaign_id) is distinct from 'GM' then
    v_preview:=public.mover_token_player_cba(
      p_campaign_id,v_pending.mover_token_id,v_pending.destination_x,v_pending.destination_y);
  else
    v_preview:=public.mover_token_gm_cba_srd(
      p_campaign_id,v_pending.mover_token_id,v_pending.destination_x,v_pending.destination_y);
  end if;

  update priv.srd_aoo_pending_movements set status='committed',
    committed_at=now(),updated_at=now() where pending_id=p_pending_id;
  perform set_config('app.srd_aoo_pending_commit','',true);
  return jsonb_build_object('committed',true,'pending_id',p_pending_id,
    'mover_token_id',v_pending.mover_token_id,
    'destination',jsonb_build_array(v_pending.destination_x,v_pending.destination_y),
    'movement_result',v_preview);
end;
$function$
;
REVOKE ALL ON FUNCTION public.srd_finalizar_movimento_aoo_pendente_srd(bigint,uuid) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.srd_finalizar_movimento_aoo_pendente_srd(bigint,uuid) TO authenticated;