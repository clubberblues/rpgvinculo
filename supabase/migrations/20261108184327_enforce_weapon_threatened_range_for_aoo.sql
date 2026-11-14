CREATE OR REPLACE FUNCTION public.srd_iniciar_ataque_oportunidade_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_reaction jsonb;
  v_reaction_index bigint;
  v_ledger priv.srd_aoo_reaction_ledger%rowtype;
  v_token jsonb;
  v_token_count integer;
  v_profile jsonb;
  v_character_id bigint;
  v_sheet public.srd_character_sheets%rowtype;
  v_instance public.srd_character_weapon_instances%rowtype;
  v_weapon public.srd_equipment%rowtype;
  v_attack_id uuid;
  v_reach integer;
  v_steps integer;
  v_step integer;
  v_trigger_x integer;
  v_trigger_y integer;
  v_dx integer;
  v_dy integer;
  v_distance integer;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode iniciar um ataque de oportunidade.';
  end if;
  if p_weapon_hand_slot not in ('main_hand','off_hand') then
    raise exception 'Mão da arma inválida.';
  end if;
  if p_weapon_end is not null and p_weapon_end not in ('main','off') then
    raise exception 'Extremidade da arma inválida.';
  end if;

  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then
    raise exception 'Movimento não está aguardando reação.';
  end if;

  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
    or coalesce(v_campaign.combat_data->>'active','false')<>'true'
    or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
    or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'O combate ou turno mudou desde a solicitação do movimento.';
  end if;

  select ordinality,value into v_reaction_index,v_reaction
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality
  where coalesce(value->>'reactor_token_id','')=btrim(p_reactor_token_id)
  limit 1;
  if v_reaction is null or v_reaction->>'status'<>'reserved'
     or v_reaction->>'reservation_id' is distinct from p_reaction_id::text then
    raise exception 'O combatente não possui reação reservada para este movimento.';
  end if;

  select * into v_ledger from priv.srd_aoo_reaction_ledger
  where reaction_id=p_reaction_id and campaign_id=p_campaign_id
    and actor_token_id=btrim(p_reactor_token_id)
    and combat_round=v_pending.combat_round for update;
  if not found then raise exception 'Reserva de reação não encontrada no ledger.'; end if;

  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_reactor_token_id));
  v_character_id:=nullif(v_profile->>'character_id','')::bigint;
  if v_character_id is null then
    raise exception 'Ataque de oportunidade automatizado requer ficha SRD vinculada. Criaturas sem ficha vinculada ainda precisam de resolução manual do Mestre.';
  end if;
  select * into v_sheet from public.srd_character_sheets
  where character_id=v_character_id;
  if not found then raise exception 'Ficha SRD do combatente não encontrada.'; end if;

  if priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'no_actions')
     or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'helpless')
     or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stunned')
     or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'unconscious')
     or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dying')
     or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stable')
     or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dead') then
    raise exception 'O combatente não pode realizar ataques de oportunidade devido à sua condição.';
  end if;

  select count(*)::integer,(array_agg(t))[1] into v_token_count,v_token
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id);
  if v_token_count<>1 then raise exception 'Token reator ausente ou duplicado.'; end if;

  select * into v_instance from public.srd_character_weapon_instances
  where instance_id=p_weapon_instance_id and character_id=v_character_id::text
    and equipado is true and hand_slot=p_weapon_hand_slot for share;
  if not found then raise exception 'A arma não está equipada na mão informada.'; end if;
  if not exists(select 1 from public.srd_character_equipment ce
    where ce.character_id=v_character_id::text and ce.equipment_id=v_instance.equipment_id
      and ce.equipado is true and ce.hand_slot=p_weapon_hand_slot) then
    raise exception 'A instância e o inventário da arma estão inconsistentes.';
  end if;
  select * into v_weapon from public.srd_equipment where id=v_instance.equipment_id;
  if not found or coalesce(v_weapon.detalhes->>'weapon_melee','true')='false' then
    raise exception 'A arma selecionada não é uma arma corpo a corpo válida.';
  end if;
  if coalesce((v_weapon.detalhes->>'weapon_double')::boolean,false) and p_weapon_end is null then
    raise exception 'Selecione a extremidade da arma dupla.';
  end if;

  v_steps:=greatest(abs(v_pending.destination_x-v_pending.origin_x),
                    abs(v_pending.destination_y-v_pending.origin_y));
  v_step:=greatest(0,coalesce(nullif(v_reaction->'threat'->>'last_threatened_step','')::integer,0));
  v_trigger_x:=case when v_steps=0 then v_pending.origin_x
    else round(v_pending.origin_x+(v_pending.destination_x-v_pending.origin_x)::numeric*v_step/v_steps)::integer end;
  v_trigger_y:=case when v_steps=0 then v_pending.origin_y
    else round(v_pending.origin_y+(v_pending.destination_y-v_pending.origin_y)::numeric*v_step/v_steps)::integer end;
  v_distance:=priv.srd_grid_footprint_distance_ft(
    (v_token->>'gridX')::integer,(v_token->>'gridY')::integer,
    priv.srd_token_grid_footprint(p_campaign_id,p_reactor_token_id),
    v_trigger_x,v_trigger_y,priv.srd_token_grid_footprint(p_campaign_id,v_pending.mover_token_id));
  v_reach:=coalesce(nullif(v_weapon.detalhes->>'reach_ft','')::integer,nullif(v_token->>'melee_reach_ft','')::integer,5);
  if coalesce((v_weapon.detalhes->>'threatens_squares')::boolean,true) IS NOT TRUE THEN
    raise exception 'A arma selecionada não ameaça quadrados e não pode realizar ataques de oportunidade.';
  end if;
  if v_distance < coalesce(nullif(v_weapon.detalhes->>'threat_min_ft','')::integer,5)
     OR v_distance>v_reach then
    raise exception 'O alvo não está em um quadrado ameaçado pela arma selecionada.';
  end if;

  insert into priv.srd_aoo_attacks(
    campaign_id,pending_id,reaction_id,actor_token_id,target_token_id,
    actor_character_id,weapon_instance_id,weapon_hand_slot,weapon_end,created_by,
    resolution_data
  ) values (
    p_campaign_id,p_pending_id,p_reaction_id,btrim(p_reactor_token_id),
    v_pending.mover_token_id,v_character_id,p_weapon_instance_id,
    p_weapon_hand_slot,p_weapon_end,auth.uid(),
    jsonb_build_object('trigger_x',v_trigger_x,'trigger_y',v_trigger_y,
      'weapon_name',v_weapon.nome,'weapon_damage',v_weapon.dano,
      'weapon_critical',coalesce(v_weapon.detalhes->>'critical',v_weapon.critico,'x2'),
      'weapon_details',v_weapon.detalhes)
  ) returning attack_id into v_attack_id;

  update priv.srd_aoo_pending_movements
  set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_reaction_index-1)::text],
    v_reaction||jsonb_build_object('status','attack_started','attack_id',v_attack_id),
    false),updated_at=now()
  where pending_id=p_pending_id;

  return jsonb_build_object('started',true,'attack_id',v_attack_id,
    'pending_id',p_pending_id,'reactor_token_id',p_reactor_token_id,
    'target_token_id',v_pending.mover_token_id,'weapon_name',v_weapon.nome,
    'weapon_damage',v_weapon.dano,'trigger_position',jsonb_build_array(v_trigger_x,v_trigger_y),
    'awaiting_manual_d20',true,'action_economy_cost',0);
end;
$function$
;
REVOKE ALL ON FUNCTION public.srd_iniciar_ataque_oportunidade_srd(bigint,uuid,text,uuid,uuid,text,text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.srd_iniciar_ataque_oportunidade_srd(bigint,uuid,text,uuid,uuid,text,text) TO authenticated;