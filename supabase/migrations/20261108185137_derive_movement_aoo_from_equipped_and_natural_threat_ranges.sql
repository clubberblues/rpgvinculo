CREATE OR REPLACE FUNCTION public.srd_detectar_saida_alcance_ameacado_srd(p_campaign_id bigint, p_mover_token_id text, p_destination_x integer, p_destination_y integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_campaign public.campaigns%rowtype;
  v_tokens jsonb;
  v_mover jsonb;
  v_count integer;
  v_mover_type text;
  v_faction text;
  v_size_text text;
  v_size integer := 1;
  v_old_x integer;
  v_old_y integer;
  v_is_gm boolean;
  v_threats jsonb := '[]'::jsonb;
begin
  if auth.uid() is null then raise exception 'É necessário estar autenticado.'; end if;
  if p_destination_x is null or p_destination_y is null
     or p_destination_x < 0 or p_destination_y < 0
     or p_destination_x > 199 or p_destination_y > 199 then
    raise exception 'Destino inválido na grade.';
  end if;
  v_is_gm := public.my_role(p_campaign_id) = 'GM';
  select * into v_campaign from public.campaigns where id=p_campaign_id;
  if not found then raise exception 'Campanha não encontrada.'; end if;
  v_tokens := case when jsonb_typeof(v_campaign.cba_data->'tokens')='array'
    then v_campaign.cba_data->'tokens' else '[]'::jsonb end;

  select count(*)::integer, (array_agg(x.token))[1]
    into v_count, v_mover
  from jsonb_array_elements(v_tokens) x(token)
  where x.token->>'id'=btrim(p_mover_token_id) or x.token->>'key'=btrim(p_mover_token_id);
  if v_count<>1 then raise exception 'Token de movimento inexistente ou duplicado.'; end if;

  v_mover_type:=v_mover->>'tipo';
  if not v_is_gm and (v_mover_type<>'player' or not exists(
    select 1 from public.characters c where c.id::text=btrim(p_mover_token_id)
      and c.campaign_id=p_campaign_id and c.user_id=auth.uid()
  )) then raise exception 'Você só pode consultar ameaças para seu próprio personagem.'; end if;
  if coalesce(v_mover->>'gridX','') !~ '^[0-9]{1,3}$'
     or coalesce(v_mover->>'gridY','') !~ '^[0-9]{1,3}$' then
    raise exception 'A posição atual do token é inválida.';
  end if;
  v_old_x:=(v_mover->>'gridX')::integer;
  v_old_y:=(v_mover->>'gridY')::integer;
  v_faction:=lower(coalesce(v_mover->>'combat_faction',''));
  if v_faction not in ('ally','hostile') then
    return jsonb_build_object('detected',false,'reason','mover_faction_not_configured',
      'mover_token_id',p_mover_token_id,'from',jsonb_build_array(v_old_x,v_old_y),
      'to',jsonb_build_array(p_destination_x,p_destination_y),'threats','[]'::jsonb,
      'movement_committed',false,'reaction_reserved',false);
  end if;

  select coalesce(
    nullif(v_mover->'monsterStats'->>'tamanho',''),
    nullif(v_mover->'monsterStats'->>'size',''),
    nullif(v_mover->>'tamanho',''),
    race.tamanho,
    'Médio'
  ) into v_size_text
  from (select 1) seed
  left join lateral (
    select r.tamanho
    from public.srd_character_sheets sh
    join public.srd_races r on r.id::text=sh.raca_id::text
    where sh.character_id::text=coalesce(
      nullif(v_mover->>'sourceCharacterId',''),
      case when v_mover_type='player' then v_mover->>'id' end
    )
    limit 1
  ) race on true;

  v_size:=case
    when public.srd35_normalizar_parametro_talento(coalesce(v_size_text,'')) like 'colossal%' then 6
    when public.srd35_normalizar_parametro_talento(coalesce(v_size_text,'')) like 'gargantuan%'
      or public.srd35_normalizar_parametro_talento(coalesce(v_size_text,'')) like 'imenso%' then 4
    when public.srd35_normalizar_parametro_talento(coalesce(v_size_text,'')) like 'huge%'
      or public.srd35_normalizar_parametro_talento(coalesce(v_size_text,'')) like 'enorme%' then 3
    when public.srd35_normalizar_parametro_talento(coalesce(v_size_text,'')) like 'large%'
      or public.srd35_normalizar_parametro_talento(coalesce(v_size_text,'')) like 'grande%' then 2
    else 1 end;

  with enemies as (
    select t,
      case
        when public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho',race.tamanho,'Médio')) like 'colossal%' then 6
        when public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho',race.tamanho,'Médio')) like 'gargantuan%'
          or public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho',race.tamanho,'Médio')) like 'imenso%' then 4
        when public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho',race.tamanho,'Médio')) like 'huge%'
          or public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho',race.tamanho,'Médio')) like 'enorme%' then 3
        when public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho',race.tamanho,'Médio')) like 'large%'
          or public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho',race.tamanho,'Médio')) like 'grande%' then 2
        else 1 end as footprint,
      case when coalesce(t->>'gridX','') ~ '^[0-9]{1,3}$' then (t->>'gridX')::integer else -1 end as gx,
      case when coalesce(t->>'gridY','') ~ '^[0-9]{1,3}$' then (t->>'gridY')::integer else -1 end as gy,
      lower(coalesce(t->>'combat_faction','')) as faction,
      coalesce(profile.threat_ranges,'[]'::jsonb) as threat_ranges
    from jsonb_array_elements(v_tokens) t
    left join lateral (
      select r.tamanho from public.srd_character_sheets sh
      join public.srd_races r on r.id::text=sh.raca_id::text
      where sh.character_id::text=coalesce(nullif(t->>'sourceCharacterId',''),case when t->>'tipo'='player' then t->>'id' end)
      limit 1
    ) race on true
    left join lateral (
      select jsonb_agg(jsonb_build_object('min_ft',r.min_ft,'max_ft',r.max_ft,'source',r.source)) as threat_ranges
      from (
        select 5::integer min_ft,greatest(5,(t->>'melee_reach_ft')::integer) max_ft,'token_melee_reach'::text source
        where coalesce(t->>'melee_reach_ft','') ~ '^[0-9]{1,3}$' and (t->>'melee_reach_ft')::integer>0
        union all
        select
          case when coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5)>5 and sz.footprint>1
            then sz.base_reach+5 else greatest(5,coalesce(nullif(eq.detalhes->>'threat_min_ft','')::integer,5)) end,
          case when coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5)>5 and sz.footprint>1
            then coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5)*greatest(1,sz.base_reach/5)
            else greatest(coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5),sz.base_reach) end,
          'equipped_weapon'
        from public.srd_character_weapon_instances wi
        join public.srd_equipment eq on eq.id=wi.equipment_id
        join public.srd_character_equipment ce on ce.character_id=wi.character_id and ce.equipment_id=wi.equipment_id
          and ce.equipado is true and ce.hand_slot=wi.hand_slot
        cross join lateral (
          select
            case
              when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'colossal%' then 6
              when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'gargantuan%'
                or public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'imenso%' then 4
              when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'huge%'
                or public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'enorme%' then 3
              when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'large%'
                or public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'grande%' then 2 else 1 end footprint,
            case
              when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'colossal%' then 30
              when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'gargantuan%'
                or public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'imenso%' then 20
              when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'huge%'
                or public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'enorme%' then 15
              when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'large%'
                or public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'grande%' then 10 else 5 end base_reach
        ) sz
        where wi.character_id::text=coalesce(nullif(t->>'sourceCharacterId',''),case when t->>'tipo'='player' then t->>'id' end)
          and wi.equipado is true and wi.hand_slot in ('main_hand','off_hand')
          and coalesce(eq.detalhes->>'weapon_melee','true')<>'false'
          and coalesce((eq.detalhes->>'threatens_squares')::boolean,true) is true
        union all
        select 5,
          coalesce(
            (regexp_match(coalesce(t->'monsterStats'->>'espaco_alcance',t->'monsterStats'->'dados_tecnicos'->'statblock'->>'space_reach',''),
              '/[[:space:]]*([0-9]+)[[:space:]]*ft'))[1]::integer,
            case
              when public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho','')) like 'colossal%' then 30
              when public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho','')) like 'gargantuan%'
                or public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho','')) like 'imenso%' then 20
              when public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho','')) like 'huge%'
                or public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho','')) like 'enorme%' then 15
              when public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho','')) like 'large%'
                or public.srd35_normalizar_parametro_talento(coalesce(t->'monsterStats'->>'tamanho',t->'monsterStats'->>'size',t->>'tamanho','')) like 'grande%' then 10 else 5 end),
          'natural_attack'
        where nullif(t->>'sourceCharacterId','') is null
          and coalesce(t->>'tipo','') in ('monstro','monster','npc')
          and coalesce(t->'monsterStats'->>'ataques',t->'monsterStats'->>'full_attack','') ~* '(melee|corpo a corpo|claw|bite|slam|tentacle|gore|tail|sting|hoof)'
        union all
        select 5,
          case
            when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'colossal%' then 30
            when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'gargantuan%'
              or public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'imenso%' then 20
            when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'huge%'
              or public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'enorme%' then 15
            when public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'large%'
              or public.srd35_normalizar_parametro_talento(coalesce(race.tamanho,'')) like 'grande%' then 10 else 5 end,
          'unarmed_strike'
        where exists (
          select 1 from public.srd_character_sheets sh join public.srd_classes cl on cl.id=sh.classe_id
          where sh.character_id::text=coalesce(nullif(t->>'sourceCharacterId',''),case when t->>'tipo'='player' then t->>'id' end)
            and (cl.class_key='monk' or exists (
              select 1 from jsonb_array_elements(case when jsonb_typeof(sh.talentos)='array' then sh.talentos else '[]'::jsonb end) feat
              where lower(concat_ws(' ',feat->>'id',feat->>'nome',feat->>'name')) ~
                '(ataque_desarmado_aprimorado|srd35_feat_improved_unarmed_strike|improved_unarmed_strike|ataque desarmado aprimorado|improved unarmed strike)'
            ))
        )
      ) r where r.max_ft>=r.min_ft
    ) profile on true
    where t->>'id' is distinct from p_mover_token_id
      and t->>'key' is distinct from p_mover_token_id
  ), path as (
    select i,
      case when greatest(abs(p_destination_x-v_old_x),abs(p_destination_y-v_old_y))=0 then v_old_x
        else round(v_old_x+(p_destination_x-v_old_x)::numeric*i/greatest(abs(p_destination_x-v_old_x),abs(p_destination_y-v_old_y)))::integer end as px,
      case when greatest(abs(p_destination_x-v_old_x),abs(p_destination_y-v_old_y))=0 then v_old_y
        else round(v_old_y+(p_destination_y-v_old_y)::numeric*i/greatest(abs(p_destination_x-v_old_x),abs(p_destination_y-v_old_y)))::integer end as py
    from generate_series(0,greatest(abs(p_destination_x-v_old_x),abs(p_destination_y-v_old_y))) i
  ), evaluated as (
    select e.t,
      coalesce((select max((r->>'max_ft')::integer) from jsonb_array_elements(e.threat_ranges) r),0) reach_ft,
      e.threat_ranges,e.faction,e.gx,e.gy,e.footprint,
      min(path.i) filter (where exists (
        select 1 from jsonb_array_elements(e.threat_ranges) r
        where priv.srd_grid_footprint_distance_ft(path.px,path.py,v_size,e.gx,e.gy,e.footprint)
          between (r->>'min_ft')::integer and (r->>'max_ft')::integer
      )) first_threatened_step,
      max(path.i) filter (where exists (
        select 1 from jsonb_array_elements(e.threat_ranges) r
        where priv.srd_grid_footprint_distance_ft(path.px,path.py,v_size,e.gx,e.gy,e.footprint)
          between (r->>'min_ft')::integer and (r->>'max_ft')::integer
      )) last_threatened_step,
      max(path.i) final_step
    from enemies e cross join path
    where e.gx>=0 and e.gy>=0 and jsonb_array_length(e.threat_ranges)>0
      and e.faction=case when v_faction='ally' then 'hostile' else 'ally' end
    group by e.t,e.threat_ranges,e.faction,e.gx,e.gy,e.footprint
  )
  select coalesce(jsonb_agg(jsonb_build_object(
    'token_id',t->>'id','token_key',t->>'key',
    'name',coalesce(t->>'nome',t->>'name','Criatura'),
    'reach_ft',reach_ft,'reach_squares',ceil(reach_ft/5.0)::integer,
    'threat_ranges',threat_ranges,
    'reach_distance_rule','D&D 3.5 diagonal 5-10-5',
    'first_threatened_step',first_threatened_step,
    'last_threatened_step',last_threatened_step,
    'leaving_threatened_area',true,'combat_faction',faction
  ) order by first_threatened_step),'[]'::jsonb)
  into v_threats
  from evaluated
  where first_threatened_step is not null
    and last_threatened_step < final_step;

  return jsonb_build_object(
    'detected',jsonb_array_length(v_threats)>0,
    'reason',case when jsonb_array_length(v_threats)>0 then 'leaving_threatened_area' else 'no_threatened_area_exit' end,
    'mover_token_id',p_mover_token_id,'mover_faction',v_faction,
    'from',jsonb_build_array(v_old_x,v_old_y),
    'to',jsonb_build_array(p_destination_x,p_destination_y),
    'mover_footprint',v_size,
    'threats',v_threats,'movement_committed',false,'reaction_reserved',false
  );
end;
$function$
;
REVOKE ALL ON FUNCTION public.srd_detectar_saida_alcance_ameacado_srd(bigint,text,integer,integer) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.srd_detectar_saida_alcance_ameacado_srd(bigint,text,integer,integer) TO authenticated;