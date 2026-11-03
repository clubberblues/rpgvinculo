
create or replace function public.srd_expire_campaign_conditions(p_campaign_id bigint)
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_round integer;
  v_count integer;
begin
  if auth.uid() is null then raise exception 'É necessário estar autenticado.'; end if;
  if public.my_role(p_campaign_id) not in ('GM','PLAYER') then raise exception 'Sem acesso à campanha.'; end if;
  select coalesce(nullif(combat_data->>'round','')::integer,0)
    into v_round from public.campaigns where id=p_campaign_id;
  if not found or v_round < 1 then return 0; end if;
  update public.srd_campaign_conditions
     set active=false
   where campaign_id=p_campaign_id
     and active=true
     and expires_round is not null
     and expires_round <= v_round;
  get diagnostics v_count = row_count;
  return v_count;
end;
$$;
revoke all on function public.srd_expire_campaign_conditions(bigint) from public;
grant execute on function public.srd_expire_campaign_conditions(bigint) to authenticated;
