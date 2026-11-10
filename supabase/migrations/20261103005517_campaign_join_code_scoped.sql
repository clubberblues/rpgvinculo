
create or replace function public.entrar_campanha_com_codigo(p_campaign_id bigint,p_code text)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  v_uid uuid := auth.uid();
  v_owner uuid;
begin
  if v_uid is null then raise exception 'Não autenticado.'; end if;
  if p_code is null or p_code !~ '^[0-9]{4}$' then
    return jsonb_build_object('ok',false,'erro','Informe um código válido de 4 números.');
  end if;
  select owner_id into v_owner
  from public.campaigns
  where id = p_campaign_id and active;
  if v_owner is null then
    return jsonb_build_object('ok',false,'erro','Mesa não encontrada ou indisponível.');
  end if;
  if not exists(select 1 from public.campaign_codes where campaign_id=p_campaign_id and code=p_code) then
    return jsonb_build_object('ok',false,'erro','Código incorreto para esta mesa.');
  end if;
  if v_owner <> v_uid then
    insert into public.members(campaign_id,user_id,role)
    values(p_campaign_id,v_uid,'PLAYER')
    on conflict(campaign_id,user_id) do nothing;
  end if;
  return jsonb_build_object('ok',true,'id',p_campaign_id,'papel',case when v_owner=v_uid then 'GM' else 'PLAYER' end);
end;
$function$;
revoke all on function public.entrar_campanha_com_codigo(bigint,text) from public,anon;
grant execute on function public.entrar_campanha_com_codigo(bigint,text) to authenticated;
