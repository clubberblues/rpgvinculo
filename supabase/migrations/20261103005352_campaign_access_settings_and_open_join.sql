
create or replace function public.atualizar_configuracoes_campanha(
  p_campaign_id bigint,
  p_name text,
  p_require_code boolean,
  p_code text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  v_uid uuid := auth.uid();
  v_name text := btrim(coalesce(p_name, ''));
begin
  if v_uid is null then raise exception 'Não autenticado.'; end if;
  if not exists (
    select 1 from public.campaigns
    where id = p_campaign_id and owner_id = v_uid and active
    for update
  ) then raise exception 'Somente o criador da mesa pode alterar suas configurações.'; end if;
  if char_length(v_name) < 2 or char_length(v_name) > 60 then
    raise exception 'O nome da mesa deve ter entre 2 e 60 caracteres.';
  end if;
  if p_require_code then
    if p_code is null or p_code !~ '^[0-9]{4}$' then
      raise exception 'O código deve conter exatamente 4 números.';
    end if;
    if exists(select 1 from public.campaign_codes where code = p_code and campaign_id <> p_campaign_id) then
      raise exception 'Esse código já está sendo usado por outra mesa.';
    end if;
    insert into public.campaign_codes(campaign_id, code)
    values(p_campaign_id, p_code)
    on conflict(campaign_id) do update set code = excluded.code;
  else
    delete from public.campaign_codes where campaign_id = p_campaign_id;
  end if;
  update public.campaigns set name = v_name where id = p_campaign_id and owner_id = v_uid;
  return jsonb_build_object('ok', true, 'id', p_campaign_id, 'name', v_name, 'requires_code', p_require_code);
end;
$function$;

create or replace function public.entrar_campanha_aberta(p_campaign_id bigint)
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
  select owner_id into v_owner
  from public.campaigns
  where id = p_campaign_id and active
  for share;
  if v_owner is null then
    return jsonb_build_object('ok', false, 'erro', 'Mesa não encontrada ou indisponível.');
  end if;
  if exists(select 1 from public.campaign_codes where campaign_id = p_campaign_id) then
    return jsonb_build_object('ok', false, 'erro', 'code_required');
  end if;
  if v_owner <> v_uid then
    insert into public.members(campaign_id, user_id, role)
    values(p_campaign_id, v_uid, 'PLAYER')
    on conflict(campaign_id, user_id) do nothing;
  end if;
  return jsonb_build_object('ok', true, 'id', p_campaign_id, 'papel', case when v_owner = v_uid then 'GM' else 'PLAYER' end);
end;
$function$;

revoke all on function public.atualizar_configuracoes_campanha(bigint,text,boolean,text) from public, anon;
revoke all on function public.entrar_campanha_aberta(bigint) from public, anon;
grant execute on function public.atualizar_configuracoes_campanha(bigint,text,boolean,text) to authenticated;
grant execute on function public.entrar_campanha_aberta(bigint) to authenticated;
