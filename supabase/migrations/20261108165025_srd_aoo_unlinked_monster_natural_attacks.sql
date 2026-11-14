
alter table priv.srd_aoo_attacks
  alter column actor_character_id drop not null,
  alter column weapon_instance_id drop not null,
  alter column weapon_hand_slot drop not null;
alter table priv.srd_aoo_attacks drop constraint if exists srd_aoo_attacks_weapon_hand_slot_check;
alter table priv.srd_aoo_attacks add constraint srd_aoo_attacks_weapon_hand_slot_check
  check (weapon_hand_slot in ('main_hand','off_hand','natural') or weapon_hand_slot is null);

create or replace function public.srd_iniciar_ataque_oportunidade_monstro_srd(
  p_campaign_id bigint,p_pending_id uuid,p_reactor_token_id text,p_reaction_id uuid
)
returns jsonb language plpgsql security definer
set search_path=pg_catalog,public,priv,pg_temp
as $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_reaction jsonb;
  v_index bigint;
  v_ledger priv.srd_aoo_reaction_ledger%rowtype;
  v_profile jsonb;
  v_token jsonb;
  v_target jsonb;
  v_count integer;
  v_attack_text text;
  v_match text[];
  v_bonus integer;
  v_damage_expr text;
  v_damage_type text;
  v_reach integer;
  v_steps integer;
  v_step integer;
  v_tx integer;
  v_ty integer;
  v_dx integer;
  v_dy integer;
  v_distance integer;
  v_attack_id uuid;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode iniciar um ataque natural de oportunidade.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then raise exception 'Movimento não está aguardando reações.'; end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
    or coalesce(v_campaign.combat_data->>'active','false')<>'true'
    or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
    or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'O combate ou turno mudou desde a solicitação do movimento.';
  end if;
  select ordinality,value into v_index,v_reaction
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality
  where value->>'reactor_token_id'=btrim(p_reactor_token_id) limit 1;
  if v_reaction is null or v_reaction->>'status'<>'reserved'
    or v_reaction->>'reservation_id' is distinct from p_reaction_id::text then
    raise exception 'O combatente não possui reação reservada para este movimento.';
  end if;
  select * into v_ledger from priv.srd_aoo_reaction_ledger
  where reaction_id=p_reaction_id and campaign_id=p_campaign_id
    and actor_token_id=btrim(p_reactor_token_id) and combat_round=v_pending.combat_round for update;
  if not found then raise exception 'Reserva de reação não encontrada.'; end if;

  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_reactor_token_id));
  if nullif(v_profile->>'character_id','') is not null then
    raise exception 'Este combatente possui ficha vinculada; use o fluxo de arma equipada.';
  end if;
  select count(*)::integer,(array_agg(t))[1] into v_count,v_token
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id);
  if v_count<>1 or v_token->>'tipo' not in ('monstro','npc') then
    raise exception 'O fluxo natural é exclusivo de NPCs e monstros sem ficha SRD vinculada.';
  end if;
  if priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'no_actions')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'helpless')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stunned')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'unconscious')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dying')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stable')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dead') then
    raise exception 'A condição atual impede o ataque de oportunidade.';
  end if;
  v_attack_text:=coalesce(nullif(v_token->'monsterStats'->>'ataques',''),
    nullif(v_token->'monsterStats'->'dados_tecnicos'->'statblock'->>'attack',''),
    nullif(v_token->'monsterStats'->>'full_attack',''),
    nullif(v_token->'monsterStats'->'dados_tecnicos'->>'full_attack',''));
  v_match:=regexp_match(coalesce(v_attack_text,''),
    '([+-]?[0-9]+)[[:space:]]+melee[[:space:]]+\(([0-9]+d[0-9]+)([+-][0-9]+)?\)','i');
  if v_match is null then raise exception 'O bloco de estatísticas não contém ataque corpo a corpo legível.'; end if;
  v_bonus:=v_match[1]::integer;
  v_damage_expr:=v_match[2]||coalesce(v_match[3],'');
  v_damage_type:=lower(coalesce(v_token->'monsterStats'->>'tipo_dano','physical'));
  v_match:=regexp_match(coalesce(v_token->>'melee_reach_ft',v_token->'monsterStats'->>'espaco_alcance',
    v_token->'monsterStats'->'dados_tecnicos'->'statblock'->>'space_reach',''),'([0-9]+)[[:space:]]*ft\.?/[[:space:]]*([0-9]+)','i');
  v_reach:=coalesce(nullif(v_token->>'melee_reach_ft','')::integer,
    case when v_match is not null then v_match[2]::integer end,5);

  v_steps:=greatest(abs(v_pending.destination_x-v_pending.origin_x),abs(v_pending.destination_y-v_pending.origin_y));
  v_step:=greatest(0,coalesce(nullif(v_reaction->'threat'->>'last_threatened_step','')::integer,0));
  v_tx:=case when v_steps=0 then v_pending.origin_x else round(v_pending.origin_x+(v_pending.destination_x-v_pending.origin_x)::numeric*v_step/v_steps)::integer end;
  v_ty:=case when v_steps=0 then v_pending.origin_y else round(v_pending.origin_y+(v_pending.destination_y-v_pending.origin_y)::numeric*v_step/v_steps)::integer end;
  select count(*)::integer,(array_agg(t))[1] into v_count,v_target
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=v_pending.mover_token_id or t->>'key'=v_pending.mover_token_id;
  if v_count<>1 then raise exception 'Alvo do movimento não existe ou está duplicado.'; end if;
  if coalesce(v_token->>'gridX','') !~ '^[0-9]{1,3}$' or coalesce(v_token->>'gridY','') !~ '^[0-9]{1,3}$' then
    raise exception 'Posição do atacante inválida.';
  end if;
  v_dx:=abs(v_tx-(v_token->>'gridX')::integer);v_dy:=abs(v_ty-(v_token->>'gridY')::integer);
  v_distance:=greatest(v_dx,v_dy)+floor(least(v_dx,v_dy)::numeric/2)::integer;
  if v_distance*5>v_reach then raise exception 'O alvo está fora do alcance do ataque natural.'; end if;

  insert into priv.srd_aoo_attacks(campaign_id,pending_id,reaction_id,actor_token_id,target_token_id,
    actor_character_id,weapon_instance_id,weapon_hand_slot,created_by,resolution_data)
  values(p_campaign_id,p_pending_id,p_reaction_id,btrim(p_reactor_token_id),v_pending.mover_token_id,
    null,null,'natural',auth.uid(),jsonb_build_object(
      'weapon_name','Ataque natural','weapon_damage',v_damage_expr,'damage_expression',v_damage_expr,
      'monster_attack_bonus',v_bonus,'critical_threat_minimum',20,'critical_multiplier',2,
      'damage_type',v_damage_type,'source_attack_text',v_attack_text,'trigger_x',v_tx,'trigger_y',v_ty
    )) returning attack_id into v_attack_id;
  update priv.srd_aoo_pending_movements
  set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],
    v_reaction||jsonb_build_object('status','attack_started','attack_id',v_attack_id),false),updated_at=now()
  where pending_id=p_pending_id;
  return jsonb_build_object('started',true,'attack_id',v_attack_id,'weapon_name','Ataque natural',
    'damage_expression',v_damage_expr,'attack_bonus',v_bonus,'awaiting_manual_d20',true,'action_economy_cost',0);
end;
$function$;

do $patch$
declare v_def text;
begin
  v_def:=pg_get_functiondef('public.srd_resolver_ataque_oportunidade_srd(bigint,uuid)'::regprocedure);
  v_def:=replace(v_def,
    $marker$  select * into v_sheet from public.srd_character_sheets where character_id=v_attack.actor_character_id;$marker$,
    $insert$  if v_attack.actor_character_id is null then
    v_actor_is_giant:=lower(concat_ws(' ',v_actor_token->>'creature_type',
      v_actor_token->'monsterStats'->>'type',v_actor_token->'monsterStats'->>'tipo',
      v_actor_token->'monsterStats'->>'creature_type',v_actor_token->'monsterStats'->>'subtype')) ~ '(giant|gigante)';
    if v_target->>'tipo'='player' then
      v_target_ac_data:=public.srd_calcular_ca_personagem_srd(p_campaign_id,v_attack.target_token_id,'normal',v_actor_is_giant);
      v_target_ac:=nullif(v_target_ac_data->>'final_ac','')::integer
        +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
    else
      if coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca','') !~ '^[0-9]{1,3}$' then
        raise exception 'O alvo não possui CA numérica válida.';
      end if;
      v_target_ac:=(coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca'))::integer
        +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac')
        +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
    end if;
    v_expected:=coalesce(nullif(v_attack.resolution_data->>'monster_attack_bonus','')::integer,0)
      +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'attack')
      +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'attack_melee');
    v_total:=v_attack.manual_d20+v_expected;
    v_crit_min:=coalesce(nullif(v_attack.resolution_data->>'critical_threat_minimum','')::integer,20);
    v_crit_mult:=coalesce(nullif(v_attack.resolution_data->>'critical_multiplier','')::integer,2);
    v_is_threat:=v_attack.manual_d20>=v_crit_min
      and (v_attack.manual_d20=20 or (v_attack.manual_d20<>1 and v_total>=v_target_ac));
    v_status:=case when v_attack.manual_d20=20 or (v_attack.manual_d20<>1 and v_total>=v_target_ac)
      then case when v_is_threat then 'awaiting_critical_confirmation' else 'awaiting_damage' end
      else 'miss' end;
    update priv.srd_aoo_attacks set status=v_status,attack_total=v_total,target_ac=v_target_ac,
      resolution_data=resolution_data||jsonb_build_object('attack_total',v_total,'target_ac',v_target_ac,
        'monster_attack_bonus',v_expected,'critical_threat',v_is_threat,'critical_threat_minimum',v_crit_min,
        'critical_multiplier',v_crit_mult,'manual_d20',v_attack.manual_d20),resolved_at=now()
    where attack_id=p_attack_id returning * into v_attack;
    update priv.srd_aoo_pending_movements p
    set pending_reactions=jsonb_set(p.pending_reactions,ARRAY[
      (select (e.ordinality-1)::text from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
       where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1)
    ],(
      select e.value||jsonb_build_object('status',case when v_status='miss' then 'miss' else 'hit_pending_damage' end)
      from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
      where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1
    ),false),updated_at=now()
    where p.pending_id=v_attack.pending_id;
    return jsonb_build_object('attack_id',p_attack_id,'status',v_status,
      'manual_d20',v_attack.manual_d20,'attack_total',v_total,'target_ac',v_target_ac,
      'critical_threat',v_is_threat,'critical_multiplier',v_crit_mult,
      'damage_expression',v_attack.resolution_data->>'damage_expression',
      'resolution_data',v_attack.resolution_data,'action_economy_cost',0);
  end if;

  select * into v_sheet from public.srd_character_sheets where character_id=v_attack.actor_character_id;$insert$);
  if strpos(v_def,'if v_attack.actor_character_id is null then')=0 then
    raise exception 'Não foi possível adicionar a resolução de ataques naturais.';
  end if;
  execute v_def;
end;
$patch$;

create or replace function public.srd_aplicar_dano_ataque_oportunidade_monstro_srd(
  p_campaign_id bigint,p_attack_id uuid,p_damage_rolls integer[],p_idempotency_key uuid
)
returns jsonb language plpgsql security definer
set search_path=pg_catalog,public,priv,pg_temp
as $function$
declare
  v_attack priv.srd_aoo_attacks%rowtype;
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_target jsonb;
  v_tokens jsonb;
  v_scene jsonb;
  v_idx bigint;
  v_count integer;
  v_expr text;
  v_dice integer;
  v_faces integer;
  v_flat integer:=0;
  v_mult integer:=1;
  v_roll integer:=0;
  v_raw integer;
  v_final integer;
  v_hp integer;
  v_max integer;
  v_new_hp integer;
  v_type text;
  i integer;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then raise exception 'Somente o Mestre pode aplicar dano.'; end if;
  if p_idempotency_key is null or p_damage_rolls is null or cardinality(p_damage_rolls)<1
    or cardinality(p_damage_rolls)>30 or array_position(p_damage_rolls,null) is not null
    or exists(select 1 from unnest(p_damage_rolls) x where x<1 or x>1000) then
    raise exception 'Resultados de dano inválidos.';
  end if;
  select * into v_attack from priv.srd_aoo_attacks
  where campaign_id=p_campaign_id and attack_id=p_attack_id for update;
  if not found or v_attack.created_by<>auth.uid() or v_attack.actor_character_id is not null then
    raise exception 'Ataque natural não encontrado ou sem autorização.';
  end if;
  if v_attack.status='damage_applied' and v_attack.damage_idempotency_key=p_idempotency_key then
    return jsonb_build_object('attack_id',p_attack_id,'status','damage_applied','damage_applied',v_attack.damage_applied,'replayed',true);
  end if;
  if v_attack.status<>'awaiting_damage' then raise exception 'Ataque natural não está pronto para receber dano.'; end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where pending_id=v_attack.pending_id and campaign_id=p_campaign_id for update;
  if not found or v_pending.status<>'waiting_reactions' then raise exception 'Movimento pendente não está ativo.'; end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
    or coalesce(v_campaign.combat_data->>'active','false')<>'true'
    or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
    or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'A iniciativa mudou antes do dano.';
  end if;
  v_expr:=coalesce(v_attack.resolution_data->>'damage_expression',v_attack.resolution_data->>'weapon_damage');
  if v_expr !~ '^[0-9]+d[0-9]+([+-][0-9]+)?$' then raise exception 'Expressão de dano natural inválida: %.',v_expr; end if;
  v_dice:=substring(v_expr from '^([0-9]+)d')::integer;
  v_faces:=substring(v_expr from 'd([0-9]+)')::integer;
  v_flat:=coalesce(nullif(substring(v_expr from 'd[0-9]+([+-][0-9]+)$'),'')::integer,0);
  v_mult:=case when v_attack.is_critical then coalesce(nullif(v_attack.resolution_data->>'critical_multiplier','')::integer,2) else 1 end;
  if v_dice<1 or v_dice>10 or v_faces<2 or v_faces>100 or v_mult<1 or v_mult>5
    or cardinality(p_damage_rolls)<>v_dice*v_mult then raise exception 'Quantidade de dados não corresponde ao dano natural.'; end if;
  for i in 1..cardinality(p_damage_rolls) loop
    if p_damage_rolls[i]>v_faces then raise exception 'Resultado excede d%.',v_faces; end if;
    v_roll:=v_roll+p_damage_rolls[i];
  end loop;
  v_raw:=greatest(0,v_roll+v_flat+priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'damage')
    +v_flat*greatest(0,v_mult-1));
  v_type:=lower(coalesce(v_attack.resolution_data->>'damage_type','physical'));
  v_type:=case v_type when 'cortante' then 'slashing' when 'perfurante' then 'piercing'
    when 'impacto' then 'bludgeoning' else v_type end;

  select count(*)::integer,min(t.ordinality) into v_count,v_idx
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) with ordinality t(token,ordinality)
  where t.token->>'id'=v_attack.target_token_id and t.token->>'tipo' in ('player','npc','monstro');
  if v_count<>1 then raise exception 'Alvo ausente ou duplicado.'; end if;
  v_tokens:=case when jsonb_typeof(v_campaign.cba_data->'tokens')='array' then v_campaign.cba_data->'tokens' else '[]'::jsonb end;
  v_target:=v_tokens->(v_idx::integer-1);
  if v_target->>'tipo'='player' then
    select pv_atual,pv_max into v_hp,v_max from public.srd_character_sheets
    where character_id::text=v_attack.target_token_id for update;
    if not found or v_max is null or v_max<1 then raise exception 'PV do alvo inválidos.'; end if;
    v_final:=priv.srd_adjust_damage(p_campaign_id,'character',v_attack.target_token_id,v_type,v_raw);
    v_new_hp:=greatest(-10,least(v_max,coalesce(v_hp,v_max)-v_final));
    update public.srd_character_sheets set pv_atual=v_new_hp where character_id::text=v_attack.target_token_id;
    perform priv.srd_sync_character_vital_condition(v_attack.target_token_id,v_new_hp,false);
  else
    if coalesce(v_target->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' then raise exception 'PV máximo do alvo inválido.'; end if;
    v_max:=(v_target->>'maxHp')::integer;
    v_hp:=case when coalesce(v_target->>'hp','') ~ '^-?[0-9]{1,6}$' then (v_target->>'hp')::integer else v_max end;
    v_final:=priv.srd_adjust_damage(p_campaign_id,'token',v_attack.target_token_id,v_type,v_raw);
    v_new_hp:=greatest(-10,least(v_max,v_hp-v_final));
  end if;
  v_target:=v_target||jsonb_build_object('hp',v_new_hp,'maxHp',v_max);
  v_scene:=coalesce(v_campaign.cba_data,'{}'::jsonb)||jsonb_build_object('tokens',jsonb_set(v_tokens,ARRAY[(v_idx-1)::text],v_target,false));
  update public.campaigns set cba_data=v_scene where id=p_campaign_id;
  perform priv.srd_sync_linked_npc_token_vitals(p_campaign_id,v_attack.target_token_id,v_new_hp,v_max);
  update priv.srd_aoo_attacks set status='damage_applied',damage_rolls=p_damage_rolls,
    damage_applied=v_final,damage_idempotency_key=p_idempotency_key,damage_applied_at=now(),
    resolution_data=resolution_data||jsonb_build_object('damage_roll_sum',v_roll,'damage_raw',v_raw,
      'damage_final',v_final,'critical_multiplier_applied',v_mult)
  where attack_id=p_attack_id returning * into v_attack;
  update priv.srd_aoo_pending_movements p
  set pending_reactions=jsonb_set(p.pending_reactions,ARRAY[
    (select (e.ordinality-1)::text from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
     where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1)
  ],(
    select e.value||jsonb_build_object('status','damage_applied','damage_applied',v_final)
    from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
    where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1
  ),false),updated_at=now() where p.pending_id=v_attack.pending_id;
  return jsonb_build_object('attack_id',p_attack_id,'status','damage_applied','damage_applied',v_final,
    'target_hp',v_new_hp,'target_max_hp',v_max,'damage_expression',v_expr,'damage_rolls',p_damage_rolls,
    'critical',v_attack.is_critical,'critical_multiplier',v_mult,'replayed',false);
end;
$function$;

revoke all on function public.srd_iniciar_ataque_oportunidade_monstro_srd(bigint,uuid,text,uuid) from public,anon;
grant execute on function public.srd_iniciar_ataque_oportunidade_monstro_srd(bigint,uuid,text,uuid) to authenticated;
revoke all on function public.srd_aplicar_dano_ataque_oportunidade_monstro_srd(bigint,uuid,integer[],uuid) from public,anon;
grant execute on function public.srd_aplicar_dano_ataque_oportunidade_monstro_srd(bigint,uuid,integer[],uuid) to authenticated;
