
create or replace function priv.srd_token_grid_footprint(p_campaign_id bigint,p_token_id text)
returns integer language plpgsql stable security definer
set search_path=pg_catalog,public,priv,pg_temp
as $function$
declare v_token jsonb; v_count integer; v_type text; v_size text;
begin
  select count(*)::integer,(array_agg(t))[1] into v_count,v_token
  from jsonb_array_elements(coalesce((select cba_data->'tokens' from public.campaigns where id=p_campaign_id),'[]'::jsonb)) t
  where t->>'id'=btrim(p_token_id) or t->>'key'=btrim(p_token_id);
  if v_count<>1 then raise exception 'Token inexistente ou duplicado ao calcular ocupação na grade.'; end if;
  v_type:=v_token->>'tipo';
  select coalesce(nullif(v_token->'monsterStats'->>'tamanho',''),
                  nullif(v_token->'monsterStats'->>'size',''),
                  nullif(v_token->>'tamanho',''),
                  nullif(v_token->>'size',''),
                  r.tamanho,'Médio')
  into v_size
  from (select 1) seed
  left join lateral (
    select sr.tamanho
    from public.srd_character_sheets sh
    join public.srd_races sr on sr.id::text=sh.raca_id::text
    where sh.character_id::text=coalesce(nullif(v_token->>'sourceCharacterId',''),
      case when v_type='player' then v_token->>'id' end)
    limit 1
  ) r on true;
  v_size:=public.srd35_normalizar_parametro_talento(coalesce(v_size,'medio'));
  return case
    when v_size like 'colossal%' then 6
    when v_size like 'gargantuan%' or v_size like 'imenso%' then 4
    when v_size like 'huge%' or v_size like 'enorme%' then 3
    when v_size like 'large%' or v_size like 'grande%' then 2
    else 1 end;
end;
$function$;
revoke all on function priv.srd_token_grid_footprint(bigint,text) from public,anon,authenticated;

do $patch$
declare v_def text; v_old text; v_new text; v_sig text;
begin
  v_sig:='public.srd_detectar_saida_alcance_ameacado_srd(bigint,text,integer,integer)';
  v_def:=pg_get_functiondef(v_sig::regprocedure);
  v_def:=replace(v_def,'like ''colossal%'' then 5','like ''colossal%'' then 6');
  execute v_def;

  v_sig:='public.srd_iniciar_ataque_oportunidade_monstro_srd(bigint,uuid,text,uuid)';
  v_def:=pg_get_functiondef(v_sig::regprocedure);
  v_old:=$old$v_dx:=abs(v_tx-(v_token->>'gridX')::integer);v_dy:=abs(v_ty-(v_token->>'gridY')::integer);
  v_distance:=greatest(v_dx,v_dy)+floor(least(v_dx,v_dy)::numeric/2)::integer;
  if v_distance*5>v_reach then raise exception 'O alvo está fora do alcance do ataque natural.'; end if;$old$;
  v_new:=$new$v_distance:=priv.srd_grid_footprint_distance_ft(
    (v_token->>'gridX')::integer,(v_token->>'gridY')::integer,
    priv.srd_token_grid_footprint(p_campaign_id,p_reactor_token_id),
    v_tx,v_ty,priv.srd_token_grid_footprint(p_campaign_id,v_pending.mover_token_id));
  if v_distance>v_reach then raise exception 'O alvo está fora do alcance do ataque natural.'; end if;$new$;
  if strpos(v_def,v_old)=0 then raise exception 'Trecho de alcance do ataque natural não encontrado.'; end if;
  execute replace(v_def,v_old,v_new);

  v_sig:='public.srd_iniciar_ataque_oportunidade_desarmado_srd(bigint,uuid,text,uuid)';
  v_def:=pg_get_functiondef(v_sig::regprocedure);
  v_old:=$old$v_dx:=abs(v_tx-(v_token->>'gridX')::integer);v_dy:=abs(v_ty-(v_token->>'gridY')::integer);
  v_distance:=greatest(v_dx,v_dy)+floor(least(v_dx,v_dy)::numeric/2)::integer;
  v_reach:=coalesce(nullif(v_token->>'melee_reach_ft','')::integer,5);
  if v_distance*5>v_reach then raise exception 'O alvo está fora do alcance do ataque desarmado.'; end if;$old$;
  v_new:=$new$v_distance:=priv.srd_grid_footprint_distance_ft(
    (v_token->>'gridX')::integer,(v_token->>'gridY')::integer,
    priv.srd_token_grid_footprint(p_campaign_id,p_reactor_token_id),
    v_tx,v_ty,priv.srd_token_grid_footprint(p_campaign_id,v_pending.mover_token_id));
  v_reach:=coalesce(nullif(v_token->>'melee_reach_ft','')::integer,5);
  if v_distance>v_reach then raise exception 'O alvo está fora do alcance do ataque desarmado.'; end if;$new$;
  if strpos(v_def,v_old)=0 then raise exception 'Trecho de alcance do ataque desarmado não encontrado.'; end if;
  execute replace(v_def,v_old,v_new);

  v_sig:='public.srd_iniciar_ataque_oportunidade_srd(bigint,uuid,text,uuid,uuid,text,text)';
  v_def:=pg_get_functiondef(v_sig::regprocedure);
  v_old:=$old$v_dx:=abs(v_trigger_x-(v_token->>'gridX')::integer);
  v_dy:=abs(v_trigger_y-(v_token->>'gridY')::integer);
  v_distance:=greatest(v_dx,v_dy)+floor(least(v_dx,v_dy)::numeric/2)::integer;
  v_reach:=coalesce(nullif(v_weapon.detalhes->>'reach_ft','')::integer,nullif(v_token->>'melee_reach_ft','')::integer,5);
  if v_distance*5>v_reach then
    raise exception 'O alvo não está no alcance corpo a corpo do reator no momento da provocação.';
  end if;$old$;
  v_new:=$new$v_distance:=priv.srd_grid_footprint_distance_ft(
    (v_token->>'gridX')::integer,(v_token->>'gridY')::integer,
    priv.srd_token_grid_footprint(p_campaign_id,p_reactor_token_id),
    v_trigger_x,v_trigger_y,priv.srd_token_grid_footprint(p_campaign_id,v_pending.mover_token_id));
  v_reach:=coalesce(nullif(v_weapon.detalhes->>'reach_ft','')::integer,nullif(v_token->>'melee_reach_ft','')::integer,5);
  if v_distance>v_reach then
    raise exception 'O alvo não está no alcance corpo a corpo do reator no momento da provocação.';
  end if;$new$;
  if strpos(v_def,v_old)=0 then raise exception 'Trecho de alcance da arma equipada não encontrado.'; end if;
  execute replace(v_def,v_old,v_new);
end;
$patch$;
