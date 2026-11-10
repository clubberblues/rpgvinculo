
create or replace function public.srd_detectar_saida_alcance_ameacado_srd(
  p_campaign_id bigint,
  p_mover_token_id text,
  p_destination_x integer,
  p_destination_y integer
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, priv, pg_temp
as $function$
declare
  v_campaign public.campaigns%rowtype;
  v_tokens jsonb;
  v_mover jsonb;
  v_mover_index bigint;
  v_count integer;
  v_mover_type text;
  v_faction text;
  v_reach integer;
  v_size integer := 1;
  v_old_x integer;
  v_old_y integer;
  v_is_gm boolean;
  v_threats jsonb := '[]'::jsonb;
  v_result jsonb;
begin
  if auth.uid() is null then
    raise exception 'É necessário estar autenticado.';
  end if;
  if p_destination_x is null or p_destination_y is null
     or p_destination_x < 0 or p_destination_y < 0
     or p_destination_x > 199 or p_destination_y > 199 then
    raise exception 'Destino inválido na grade.';
  end if;

  v_is_gm := public.my_role(p_campaign_id) = 'GM';
  select * into v_campaign
  from public.campaigns where id=p_campaign_id;
  if not found then raise exception 'Campanha não encontrada.'; end if;

  v_tokens := case when jsonb_typeof(v_campaign.cba_data->'tokens')='array'
    then v_campaign.cba_data->'tokens' else '[]'::jsonb end;

  select count(*)::integer, min(x.ordinality), (array_agg(x.token))[1]
    into v_count, v_mover_index, v_mover
  from jsonb_array_elements(v_tokens) with ordinality x(token,ordinality)
  where x.token->>'id'=btrim(p_mover_token_id) or x.token->>'key'=btrim(p_mover_token_id);
  if v_count <> 1 then raise exception 'Token de movimento inexistente ou duplicado.'; end if;

  v_mover_type := v_mover->>'tipo';
  if not v_is_gm then
    if v_mover_type <> 'player' or not exists(
      select 1 from public.characters c
      where c.id::text=btrim(p_mover_token_id)
        and c.campaign_id=p_campaign_id and c.user_id=auth.uid()
    ) then
      raise exception 'Você só pode consultar ameaças para seu próprio personagem.';
    end if;
  end if;

  if coalesce(v_mover->>'gridX','') !~ '^[0-9]{1,3}$'
     or coalesce(v_mover->>'gridY','') !~ '^[0-9]{1,3}$' then
    raise exception 'A posição atual do token é inválida.';
  end if;
  v_old_x := (v_mover->>'gridX')::integer;
  v_old_y := (v_mover->>'gridY')::integer;

  v_faction := lower(coalesce(v_mover->>'combat_faction',''));
  if v_faction not in ('ally','hostile') then
    return jsonb_build_object(
      'detected',false,'reason','mover_faction_not_configured',
      'mover_token_id',p_mover_token_id,'from',jsonb_build_array(v_old_x,v_old_y),
      'to',jsonb_build_array(p_destination_x,p_destination_y),'threats',v_threats
    );
  end if;

  v_size := case
    when public.srd35_normalizar_parametro_talento(coalesce(v_mover->'monsterStats'->>'tamanho',v_mover->'monsterStats'->>'size',v_mover->>'tamanho','')) like 'colossal%' then 5
    when public.srd35_normalizar_parametro_talento(coalesce(v_mover->'monsterStats'->>'tamanho',v_mover->'monsterStats'->>'size',v_mover->>'tamanho','')) like 'gargantuan%'
      or public.srd35_normalizar_parametro_talento(coalesce(v_mover->'monsterStats'->>'tamanho',v_mover->'monsterStats'->>'size',v_mover->>'tamanho','')) like 'imenso%' then 4
    when public.srd35_normalizar_parametro_talento(coalesce(v_mover->'monsterStats'->>'tamanho',v_mover->'monsterStats'->>'size',v_mover->>'tamanho','')) like 'huge%'
      or public.srd35_normalizar_parametro_talento(coalesce(v_mover->'monsterStats'->>'tamanho',v_mover->'monsterStats'->>'size',v_mover->>'tamanho','')) like 'enorme%' then 3
    when public.srd35_normalizar_parametro_talento(coalesce(v_mover->'monsterStats'->>'tamanho',v_mover->'monsterStats'->>'size',v_mover->>'tamanho','')) like 'large%'
      or public.srd35_normalizar_parametro_talento(coalesce(v_mover->'monsterStats'->>'tamanho',v_mover->'monsterStats'->>'size',v_mover->>'tamanho','')) like 'grande%' then 2
    else 1 end;

  with enemies as (
    select t,
      case
        when public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho','')) like 'colossal%' then 5
        when public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho','')) like 'gargantuan%'
          or public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho','')) like 'imenso%' then 4
        when public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho','')) like 'huge%'
          or public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho','')) like 'enorme%' then 3
        when public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho','')) like 'large%'
          or public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho','')) like 'grande%' then 2
        else 1 end as footprint,
      case when coalesce(t->>'gridX','') ~ '^[0-9]{1,3}$' then (t->>'gridX')::integer else -1 end as gx,
      case when coalesce(t->>'gridY','') ~ '^[0-9]{1,3}$' then (t->>'gridY')::integer else -1 end as gy,
      case when coalesce(t->>'melee_reach_ft','') ~ '^[0-9]{1,3}$' then (t->>'melee_reach_ft')::integer else 0 end as reach_ft,
      lower(coalesce(t->>'combat_faction','')) as faction
    from jsonb_array_elements(v_tokens) t
    where t->>'id' is distinct from p_mover_token_id
      and t->>'key' is distinct from p_mover_token_id
  ), valid as (
    select *,
      greatest(0, greatest(gx-(v_old_x+v_size-1),v_old_x-(gx+footprint-1))) as dx_start,
      greatest(0, greatest(gy-(v_old_y+v_size-1),v_old_y-(gy+footprint-1))) as dy_start,
      greatest(0, greatest(gx-(p_destination_x+v_size-1),p_destination_x-(gx+footprint-1))) as dx_end,
      greatest(0, greatest(gy-(p_destination_y+v_size-1),p_destination_y-(gy+footprint-1))) as dy_end
    from enemies
    where gx>=0 and gy>=0 and reach_ft>0
      and faction = case when v_faction='ally' then 'hostile' else 'ally' end
  )
  select coalesce(jsonb_agg(jsonb_build_object(
    'token_id',t->>'id','token_key',t->>'key',
    'name',coalesce(t->>'nome',t->>'name','Criatura'),
    'reach_ft',reach_ft,'reach_squares',ceil(reach_ft/5.0)::integer,
    'distance_start_squares',greatest(dx_start,dy_start),
    'distance_end_squares',greatest(dx_end,dy_end),
    'leaving_threatened_area',true,
    'combat_faction',faction
  ) order by greatest(dx_start,dy_start)), '[]'::jsonb)
  into v_threats
  from valid
  where greatest(dx_start,dy_start) <= ceil(reach_ft/5.0)::integer
    and greatest(dx_end,dy_end) > ceil(reach_ft/5.0)::integer;

  return jsonb_build_object(
    'detected',jsonb_array_length(v_threats)>0,
    'reason',case when jsonb_array_length(v_threats)>0 then 'leaving_threatened_area' else 'no_threatened_area_exit' end,
    'mover_token_id',p_mover_token_id,
    'mover_faction',v_faction,
    'from',jsonb_build_array(v_old_x,v_old_y),
    'to',jsonb_build_array(p_destination_x,p_destination_y),
    'threats',v_threats,
    'movement_committed',false,
    'reaction_reserved',false
  );
end;
$function$;

revoke all on function public.srd_detectar_saida_alcance_ameacado_srd(bigint,text,integer,integer) from public, anon;
grant execute on function public.srd_detectar_saida_alcance_ameacado_srd(bigint,text,integer,integer) to authenticated;
