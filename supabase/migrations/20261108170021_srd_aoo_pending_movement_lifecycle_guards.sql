
create or replace function public.srd_cancelar_movimento_aoo_pendente_srd(p_campaign_id bigint,p_pending_id uuid)
returns jsonb language plpgsql security definer
set search_path=pg_catalog,public,priv,pg_temp
as $function$
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
    and status in ('awaiting_attack_roll','awaiting_critical_confirmation','awaiting_damage');
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
$function$;
revoke all on function public.srd_cancelar_movimento_aoo_pendente_srd(bigint,uuid) from public,anon;
grant execute on function public.srd_cancelar_movimento_aoo_pendente_srd(bigint,uuid) to authenticated;

do $patch$
declare v_def text; v_old text; v_new text;
begin
  v_def:=replace(pg_get_functiondef('public.avancar_turno(bigint)'::regprocedure),E'\r\n',E'\n');
  v_old:=$old$IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  IF v_data IS NULL OR COALESCE((v_data->>'active')::BOOLEAN, FALSE) IS NOT TRUE THEN$old$;
  v_new:=$new$IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  IF EXISTS(select 1 from priv.srd_aoo_pending_movements
    where campaign_id=p_campaign_id and status in ('waiting_reactions','ready_to_commit')) THEN
    RAISE EXCEPTION 'Há um movimento interrompido por Ataques de Oportunidade. O Mestre deve concluir ou cancelar esse movimento antes de avançar o turno.';
  END IF;
  IF v_data IS NULL OR COALESCE((v_data->>'active')::BOOLEAN, FALSE) IS NOT TRUE THEN$new$;
  if strpos(v_def,v_old)=0 then raise exception 'Âncora de avancar_turno não encontrada.'; end if;
  execute replace(v_def,v_old,v_new);

  v_def:=replace(pg_get_functiondef('public.alternar_estado_campanha(bigint,text)'::regprocedure),E'\r\n',E'\n');
  v_old:=$old$  UPDATE public.campaigns SET state=v_novo_estado,combat_data=v_combat WHERE id=p_campaign_id;$old$;
  v_new:=$new$  IF v_estado_atual='COMBATE' AND v_novo_estado='EXPLORACAO' THEN
    UPDATE priv.srd_aoo_attacks a SET status='cancelled'
    WHERE a.pending_id IN (SELECT p.pending_id FROM priv.srd_aoo_pending_movements p
      WHERE p.campaign_id=p_campaign_id AND p.status IN ('waiting_reactions','ready_to_commit'))
      AND a.status IN ('awaiting_attack_roll','awaiting_critical_confirmation','awaiting_damage');
    UPDATE priv.srd_aoo_pending_movements p
    SET status='expired',cancelled_at=now(),updated_at=now(),
      pending_reactions=coalesce((SELECT jsonb_agg(
        CASE WHEN r.value->>'status' IN ('waiting','reserved','attack_started','hit_pending_damage')
          THEN r.value||jsonb_build_object('status','skipped','skip_reason','combat_ended')
          ELSE r.value END ORDER BY r.ordinality)
        FROM jsonb_array_elements(p.pending_reactions) WITH ORDINALITY r(value,ordinality)),'[]'::jsonb)
    WHERE p.campaign_id=p_campaign_id AND p.status IN ('waiting_reactions','ready_to_commit');
  END IF;
  UPDATE public.campaigns SET state=v_novo_estado,combat_data=v_combat WHERE id=p_campaign_id;$new$;
  if strpos(v_def,v_old)=0 then raise exception 'Âncora de alternar_estado_campanha não encontrada.'; end if;
  execute replace(v_def,v_old,v_new);

  v_def:=replace(pg_get_functiondef('public.end_combat(bigint)'::regprocedure),E'\r\n',E'\n');
  v_old:=$old$  UPDATE public.combat_state SET ativo=false,ordem='[]'::jsonb,iniciado_em=NULL WHERE campaign_id=cid;$old$;
  v_new:=$new$  UPDATE priv.srd_aoo_attacks a SET status='cancelled'
  WHERE a.pending_id IN (SELECT p.pending_id FROM priv.srd_aoo_pending_movements p
    WHERE p.campaign_id=cid AND p.status IN ('waiting_reactions','ready_to_commit'))
    AND a.status IN ('awaiting_attack_roll','awaiting_critical_confirmation','awaiting_damage');
  UPDATE priv.srd_aoo_pending_movements p
  SET status='expired',cancelled_at=now(),updated_at=now(),
    pending_reactions=coalesce((SELECT jsonb_agg(
      CASE WHEN r.value->>'status' IN ('waiting','reserved','attack_started','hit_pending_damage')
        THEN r.value||jsonb_build_object('status','skipped','skip_reason','combat_ended')
        ELSE r.value END ORDER BY r.ordinality)
      FROM jsonb_array_elements(p.pending_reactions) WITH ORDINALITY r(value,ordinality)),'[]'::jsonb)
  WHERE p.campaign_id=cid AND p.status IN ('waiting_reactions','ready_to_commit');
  UPDATE public.combat_state SET ativo=false,ordem='[]'::jsonb,iniciado_em=NULL WHERE campaign_id=cid;$new$;
  if strpos(v_def,v_old)=0 then raise exception 'Âncora de end_combat não encontrada.'; end if;
  execute replace(v_def,v_old,v_new);
end;
$patch$;
