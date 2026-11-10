
create or replace function public.srd_listar_movimentos_aoo_pendentes_srd(
  p_campaign_id bigint
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, priv, pg_temp
as $function$
declare v_rows jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode listar movimentos aguardando ataques de oportunidade.';
  end if;
  select coalesce(jsonb_agg(jsonb_build_object(
    'pending_id',p.pending_id,'mover_token_id',p.mover_token_id,
    'movement_controller',p.movement_controller,
    'origin',jsonb_build_array(p.origin_x,p.origin_y),
    'destination',jsonb_build_array(p.destination_x,p.destination_y),
    'round',p.combat_round,'current_turn',p.current_turn,
    'status',p.status,'threats',p.threats,
    'pending_reactions',p.pending_reactions,
    'created_at',p.created_at
  ) order by p.created_at),'[]'::jsonb)
  into v_rows
  from priv.srd_aoo_pending_movements p
  where p.campaign_id=p_campaign_id
    and p.status in ('waiting_reactions','ready_to_commit');
  return jsonb_build_object('pending_movements',v_rows);
end;
$function$;

create or replace function public.srd_consultar_armas_aoo_srd(
  p_campaign_id bigint,
  p_pending_id uuid,
  p_reactor_token_id text
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, priv, pg_temp
as $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_reaction jsonb;
  v_profile jsonb;
  v_character_id bigint;
  v_weapons jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode consultar armas para a reação.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id;
  if not found or v_pending.status<>'waiting_reactions' then
    raise exception 'Movimento pendente não encontrado ou encerrado.';
  end if;
  select value into v_reaction
  from jsonb_array_elements(v_pending.pending_reactions)
  where value->>'reactor_token_id'=btrim(p_reactor_token_id)
    and value->>'status'='reserved'
  limit 1;
  if v_reaction is null then raise exception 'O combatente ainda não possui reação reservada.'; end if;
  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_reactor_token_id));
  v_character_id:=nullif(v_profile->>'character_id','')::bigint;
  if v_character_id is null then
    return jsonb_build_object('eligible_for_automated_attack',false,
      'reason','unlinked_creature_requires_gm_adjudication','weapons','[]'::jsonb);
  end if;
  select coalesce(jsonb_agg(jsonb_build_object(
    'instance_id',wi.instance_id,'equipment_id',eq.id,
    'name',eq.nome,'hand_slot',wi.hand_slot,'damage',eq.dano,
    'critical',coalesce(eq.detalhes->>'critical',eq.critico,'x2'),
    'weapon_end_main',eq.detalhes->'weapon_end_main',
    'weapon_end_off',eq.detalhes->'weapon_end_off',
    'weapon_double',coalesce((eq.detalhes->>'weapon_double')::boolean,false),
    'weapon_reach_ft',coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5),
    'damage_type',eq.tipo_dano
  ) order by case wi.hand_slot when 'main_hand' then 1 else 2 end,eq.nome),'[]'::jsonb)
  into v_weapons
  from public.srd_character_weapon_instances wi
  join public.srd_equipment eq on eq.id=wi.equipment_id
  join public.srd_character_equipment ce
    on ce.character_id=v_character_id::text and ce.equipment_id=wi.equipment_id
    and ce.equipado is true and ce.hand_slot=wi.hand_slot
  where wi.character_id=v_character_id::text and wi.equipado is true
    and wi.hand_slot in ('main_hand','off_hand')
    and coalesce(eq.detalhes->>'weapon_melee','true')<>'false';
  return jsonb_build_object('eligible_for_automated_attack',jsonb_array_length(v_weapons)>0,
    'character_id',v_character_id,'weapons',v_weapons,
    'note',case when jsonb_array_length(v_weapons)=0
      then 'Sem arma corpo a corpo equipada; a resolução manual pelo Mestre ainda é necessária.'
      else null end);
end;
$function$;

create or replace function public.srd_consultar_ataque_oportunidade_srd(
  p_campaign_id bigint,
  p_attack_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, priv, pg_temp
as $function$
declare v_attack priv.srd_aoo_attacks%rowtype;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode consultar ataques de oportunidade.';
  end if;
  select * into v_attack from priv.srd_aoo_attacks
  where campaign_id=p_campaign_id and attack_id=p_attack_id;
  if not found then raise exception 'Ataque de oportunidade não encontrado.'; end if;
  return jsonb_build_object(
    'attack_id',v_attack.attack_id,'pending_id',v_attack.pending_id,
    'reaction_id',v_attack.reaction_id,
    'actor_token_id',v_attack.actor_token_id,'target_token_id',v_attack.target_token_id,
    'weapon_instance_id',v_attack.weapon_instance_id,
    'weapon_hand_slot',v_attack.weapon_hand_slot,'weapon_end',v_attack.weapon_end,
    'status',v_attack.status,'manual_d20',v_attack.manual_d20,
    'attack_total',v_attack.attack_total,'target_ac',v_attack.target_ac,
    'critical_confirmation_d20',v_attack.critical_confirmation_d20,
    'is_critical',v_attack.is_critical,'damage_rolls',v_attack.damage_rolls,
    'damage_applied',v_attack.damage_applied,
    'resolution_data',v_attack.resolution_data,
    'created_at',v_attack.created_at,'resolved_at',v_attack.resolved_at,
    'damage_applied_at',v_attack.damage_applied_at
  );
end;
$function$;

revoke all on function public.srd_listar_movimentos_aoo_pendentes_srd(bigint) from public,anon;
grant execute on function public.srd_listar_movimentos_aoo_pendentes_srd(bigint) to authenticated;
revoke all on function public.srd_consultar_armas_aoo_srd(bigint,uuid,text) from public,anon;
grant execute on function public.srd_consultar_armas_aoo_srd(bigint,uuid,text) to authenticated;
revoke all on function public.srd_consultar_ataque_oportunidade_srd(bigint,uuid) from public,anon;
grant execute on function public.srd_consultar_ataque_oportunidade_srd(bigint,uuid) to authenticated;
