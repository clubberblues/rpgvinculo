
create or replace function public.srd_apply_campaign_condition(
  p_campaign_id bigint,
  p_target_kind text,
  p_target_id text,
  p_condition_id text,
  p_duration_rounds integer default null,
  p_notes jsonb default '{}'::jsonb
) returns bigint
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_round integer := 1;
  v_instance bigint;
begin
  if auth.uid() is null then raise exception 'É necessário estar autenticado.'; end if;
  if public.my_role(p_campaign_id) is distinct from 'GM' then raise exception 'Somente o Mestre pode administrar condições.'; end if;
  if p_target_kind not in ('character','token') then raise exception 'Tipo de alvo inválido.'; end if;
  if nullif(trim(p_target_id),'') is null then raise exception 'Alvo inválido.'; end if;
  if p_duration_rounds is not null and p_duration_rounds < 1 then raise exception 'A duração deve ser de pelo menos 1 rodada.'; end if;
  if not exists(select 1 from public.srd_conditions where condition_id=p_condition_id) then raise exception 'Condição D&D 3.5 inexistente.'; end if;

  if p_target_kind='character' then
    if not exists(select 1 from public.characters where id::text=p_target_id and campaign_id=p_campaign_id) then
      raise exception 'Personagem não pertence a esta campanha.';
    end if;
  else
    if not exists(
      select 1 from public.campaigns c,
      lateral jsonb_array_elements(coalesce(c.cba_data->'tokens','[]'::jsonb)) t
      where c.id=p_campaign_id and (t->>'id'=p_target_id or t->>'key'=p_target_id)
    ) then
      raise exception 'Token não pertence ao tabuleiro desta campanha.';
    end if;
  end if;

  select coalesce(nullif(c.combat_data->>'round','')::integer,1)
    into v_round from public.campaigns c where c.id=p_campaign_id;

  update public.srd_campaign_conditions
     set active=false
   where campaign_id=p_campaign_id
     and target_kind=p_target_kind
     and target_id=p_target_id
     and condition_id=p_condition_id
     and active=true;

  insert into public.srd_campaign_conditions(
    campaign_id,target_kind,target_id,condition_id,started_round,expires_round,active,notes
  ) values (
    p_campaign_id,p_target_kind,p_target_id,p_condition_id,v_round,
    case when p_duration_rounds is null then null else v_round+p_duration_rounds end,
    true,coalesce(p_notes,'{}'::jsonb)
  ) returning condition_instance_id into v_instance;

  return v_instance;
end;
$$;

create or replace function public.srd_remove_campaign_condition(
  p_campaign_id bigint,
  p_target_kind text,
  p_target_id text,
  p_condition_id text
) returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_count integer;
begin
  if auth.uid() is null then raise exception 'É necessário estar autenticado.'; end if;
  if public.my_role(p_campaign_id) is distinct from 'GM' then raise exception 'Somente o Mestre pode administrar condições.'; end if;
  update public.srd_campaign_conditions
     set active=false
   where campaign_id=p_campaign_id
     and target_kind=p_target_kind
     and target_id=p_target_id
     and condition_id=p_condition_id
     and active=true;
  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

revoke all on function public.srd_apply_campaign_condition(bigint,text,text,text,integer,jsonb) from public;
revoke all on function public.srd_remove_campaign_condition(bigint,text,text,text) from public;
grant execute on function public.srd_apply_campaign_condition(bigint,text,text,text,integer,jsonb) to authenticated;
grant execute on function public.srd_remove_campaign_condition(bigint,text,text,text) to authenticated;
