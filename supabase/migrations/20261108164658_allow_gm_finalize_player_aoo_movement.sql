
do $patch$
declare v_def text;
begin
  v_def:=pg_get_functiondef('public.srd_finalizar_movimento_aoo_pendente_srd(bigint,uuid)'::regprocedure);
  v_def:=replace(v_def,
    $old$  if v_pending.movement_controller='gm' then
    if public.my_role(p_campaign_id) is distinct from 'GM' then raise exception 'Somente o Mestre pode concluir este movimento.'; end if;
  else
    if v_user<>v_pending.created_by then raise exception 'Somente o jogador que solicitou o movimento pode concluí-lo.'; end if;
  end if;$old$,
    $new$  if public.my_role(p_campaign_id) is distinct from 'GM'
     and (v_pending.movement_controller='gm' or v_user<>v_pending.created_by) then
    raise exception 'Somente o Mestre ou o jogador que solicitou o movimento pode concluí-lo.';
  end if;$new$);
  v_def:=replace(v_def,
    $old$  if v_pending.movement_controller='player' then
    v_preview:=public.mover_token_player_cba(
      p_campaign_id,v_pending.mover_token_id,v_pending.destination_x,v_pending.destination_y);
  else
    v_preview:=public.mover_token_gm_cba_srd(
      p_campaign_id,v_pending.mover_token_id,v_pending.destination_x,v_pending.destination_y);
  end if;$old$,
    $new$  if v_pending.movement_controller='player' and v_user=v_pending.created_by
     and public.my_role(p_campaign_id) is distinct from 'GM' then
    v_preview:=public.mover_token_player_cba(
      p_campaign_id,v_pending.mover_token_id,v_pending.destination_x,v_pending.destination_y);
  else
    v_preview:=public.mover_token_gm_cba_srd(
      p_campaign_id,v_pending.mover_token_id,v_pending.destination_x,v_pending.destination_y);
  end if;$new$);
  if strpos(v_def,'Somente o Mestre ou o jogador que solicitou')=0
    or strpos(v_def,'v_user=v_pending.created_by')=0 then
    raise exception 'Não foi possível atualizar as permissões de finalização do movimento.';
  end if;
  execute v_def;
end;
$patch$;
