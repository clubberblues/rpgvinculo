
create or replace function priv.srd_validate_aoo_pending_movement_preview()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public, priv, pg_temp
as $function$
declare v_preview jsonb;
begin
  perform set_config('app.srd_aoo_pending_commit',new.pending_id::text,true);
  begin
    if new.movement_controller='player' then
      v_preview:=public.mover_token_player_cba(
        new.campaign_id,new.mover_token_id,new.destination_x,new.destination_y
      );
    else
      v_preview:=public.mover_token_gm_cba_srd(
        new.campaign_id,new.mover_token_id,new.destination_x,new.destination_y
      );
    end if;
    raise exception using errcode='P0001',message='__SRD_AOO_PREVIEW_ROLLBACK__';
  exception when others then
    if sqlerrm='__SRD_AOO_PREVIEW_ROLLBACK__' then
      null;
    else
      raise;
    end if;
  end;
  return new;
end;
$function$;
revoke all on function priv.srd_validate_aoo_pending_movement_preview() from public,anon,authenticated;
drop trigger if exists trg_srd_validate_aoo_pending_movement_preview on priv.srd_aoo_pending_movements;
create trigger trg_srd_validate_aoo_pending_movement_preview
after insert on priv.srd_aoo_pending_movements
for each row execute function priv.srd_validate_aoo_pending_movement_preview();

create or replace function public.srd_encerrar_reacao_aoo_pendente_srd(
  p_campaign_id bigint,
  p_pending_id uuid,
  p_reactor_token_id text,
  p_cancel_attack boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, priv, pg_temp
as $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_idx bigint;
  v_reaction jsonb;
  v_attack priv.srd_aoo_attacks%rowtype;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode encerrar uma reação pendente.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then
    raise exception 'Movimento não está aguardando reações.';
  end if;
  select ordinality,value into v_idx,v_reaction
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality
  where value->>'reactor_token_id'=btrim(p_reactor_token_id) limit 1;
  if v_reaction is null then raise exception 'Reação não encontrada neste movimento.'; end if;
  if v_reaction->>'status'='attack_started' then
    if not p_cancel_attack then
      raise exception 'O ataque já começou; resolva-o ou autorize explicitamente seu cancelamento.';
    end if;
    select * into v_attack from priv.srd_aoo_attacks
    where attack_id=(v_reaction->>'attack_id')::uuid and campaign_id=p_campaign_id for update;
    if not found or v_attack.status not in ('awaiting_attack_roll','awaiting_critical_confirmation','awaiting_damage') then
      raise exception 'Ataque não pode ser cancelado neste estado.';
    end if;
    update priv.srd_aoo_attacks set status='cancelled' where attack_id=v_attack.attack_id;
  elsif v_reaction->>'status' not in ('waiting','reserved') then
    raise exception 'Esta reação já foi encerrada.';
  end if;
  update priv.srd_aoo_pending_movements
  set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_idx-1)::text],
      v_reaction||jsonb_build_object('status','skipped','skip_reason',case
        when v_reaction->>'status'='reserved' or v_reaction->>'status'='attack_started'
          then 'gm_cancelled_after_reservation' else 'gm_declined_reaction' end),
      false),updated_at=now()
  where pending_id=p_pending_id;
  return jsonb_build_object('closed',true,'pending_id',p_pending_id,
    'reactor_token_id',p_reactor_token_id,'reaction_spent',
    (v_reaction->>'status') in ('reserved','attack_started'));
end;
$function$;

create or replace function public.srd_aplicar_dano_ataque_oportunidade_srd(
  p_campaign_id bigint,
  p_attack_id uuid,
  p_damage_rolls integer[],
  p_idempotency_key uuid
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, priv, pg_temp
as $function$
declare
  v_attack priv.srd_aoo_attacks%rowtype;
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_sheet public.srd_character_sheets%rowtype;
  v_race public.srd_races%rowtype;
  v_weapon public.srd_equipment%rowtype;
  v_target jsonb;
  v_tokens jsonb;
  v_scene jsonb;
  v_target_idx bigint;
  v_target_count integer;
  v_expr text;
  v_dice integer;
  v_faces integer;
  v_mult integer:=1;
  v_roll_sum integer:=0;
  v_str_bonus integer:=0;
  v_damage_bonus integer:=0;
  v_critical_static integer:=0;
  v_specialization integer:=0;
  v_raw integer:=0;
  v_final integer:=0;
  v_damage_type text;
  v_hp integer;
  v_max_hp integer;
  v_new_hp integer;
  v_idem uuid;
  i integer;
  v_end_meta jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode aplicar dano de ataque de oportunidade.';
  end if;
  if p_idempotency_key is null or p_damage_rolls is null
     or cardinality(p_damage_rolls)<1 or cardinality(p_damage_rolls)>30
     or array_position(p_damage_rolls,null) is not null
     or exists(select 1 from unnest(p_damage_rolls) x where x<1 or x>1000) then
    raise exception 'Resultados de dano inválidos.';
  end if;
  select * into v_attack from priv.srd_aoo_attacks
  where attack_id=p_attack_id and campaign_id=p_campaign_id for update;
  if not found or v_attack.created_by<>auth.uid() then raise exception 'Ataque não encontrado ou sem autorização.'; end if;
  if v_attack.damage_idempotency_key=p_idempotency_key and v_attack.status='damage_applied' then
    return jsonb_build_object('attack_id',p_attack_id,'status','damage_applied',
      'damage_applied',v_attack.damage_applied,'replayed',true);
  end if;
  if v_attack.status<>'awaiting_damage' then raise exception 'Ataque ainda não está pronto para receber dano.'; end if;

  select * into v_pending from priv.srd_aoo_pending_movements
  where pending_id=v_attack.pending_id and campaign_id=p_campaign_id for update;
  if not found or v_pending.status<>'waiting_reactions' then raise exception 'Movimento pendente não está ativo.'; end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
     or coalesce(v_campaign.combat_data->>'active','false')<>'true'
     or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
     or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'A iniciativa mudou antes da aplicação do dano.';
  end if;

  select * into v_sheet from public.srd_character_sheets where character_id=v_attack.actor_character_id;
  select * into v_race from public.srd_races where id=v_sheet.raca_id;
  select * into v_weapon from public.srd_equipment eq
  join public.srd_character_weapon_instances wi on wi.equipment_id=eq.id
  where wi.instance_id=v_attack.weapon_instance_id
    and wi.character_id=v_attack.actor_character_id::text
    and wi.equipado is true and wi.hand_slot=v_attack.weapon_hand_slot;
  if not found then raise exception 'Arma não está mais equipada.'; end if;

  v_end_meta:=case when v_attack.weapon_end='off' then coalesce(v_weapon.detalhes->'weapon_end_off','{}'::jsonb)
    when v_attack.weapon_end='main' then coalesce(v_weapon.detalhes->'weapon_end_main','{}'::jsonb)
    else '{}'::jsonb end;
  v_expr:=coalesce(
    case when lower(coalesce(v_race.tamanho,'')) in ('pequeno','small')
      then v_end_meta->>'damage_small' else v_end_meta->>'damage_medium' end,
    case when lower(coalesce(v_race.tamanho,'')) in ('pequeno','small')
      then v_weapon.detalhes->>'damage_small' else v_weapon.detalhes->>'damage_medium' end,
    v_weapon.dano
  );
  if v_expr !~ '^[0-9]+d[0-9]+$' then
    raise exception 'Expressão de dano não normalizada: %.',coalesce(v_expr,'vazia');
  end if;
  v_dice:=split_part(v_expr,'d',1)::integer;
  v_faces:=split_part(v_expr,'d',2)::integer;
  if v_dice<1 or v_dice>10 or v_faces<2 or v_faces>100 then
    raise exception 'Expressão de dano fora dos limites suportados.';
  end if;
  v_mult:=case when v_attack.is_critical
    then coalesce(nullif(v_attack.resolution_data->>'critical_multiplier','')::integer,2) else 1 end;
  if v_mult<1 or v_mult>5 then raise exception 'Multiplicador crítico inválido.'; end if;
  if cardinality(p_damage_rolls)<>v_dice*v_mult then
    raise exception 'A arma exige % resultados de dano (% dados x multiplicador %).',v_dice*v_mult,v_dice,v_mult;
  end if;
  for i in 1..cardinality(p_damage_rolls) loop
    if p_damage_rolls[i]>v_faces then raise exception 'Resultado excede o dado d%.',v_faces; end if;
    v_roll_sum:=v_roll_sum+p_damage_rolls[i];
  end loop;

  v_damage_bonus:=priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'damage');
  v_str_bonus:=floor((coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)
    +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'strength')-10)::numeric/2)::integer;
  if v_attack.weapon_hand_slot='off_hand' then
    v_str_bonus:=floor(v_str_bonus/2.0)::integer;
  elsif coalesce((v_weapon.detalhes->>'weapon_two_handed')::boolean,false)
    and not coalesce((v_weapon.detalhes->>'weapon_double')::boolean,false) then
    v_str_bonus:=floor(v_str_bonus*1.5)::integer;
  end if;
  v_damage_bonus:=v_damage_bonus+v_str_bonus;
  v_critical_static:=v_str_bonus;
  select coalesce(sum(case f->>'id'
    when 'srd35_feat_weapon_specialization' then 2
    when 'srd35_feat_greater_weapon_specialization' then 2 else 0 end),0)::integer
  into v_specialization
  from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
  where f->>'id' in ('srd35_feat_weapon_specialization','srd35_feat_greater_weapon_specialization')
    and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))
      =public.srd35_normalizar_parametro_talento(v_weapon.nome);
  v_damage_bonus:=v_damage_bonus+v_specialization;
  v_critical_static:=v_critical_static+v_specialization;

  v_raw:=greatest(0,v_roll_sum+v_damage_bonus+(v_critical_static*greatest(0,v_mult-1)));
  v_damage_type:=lower(coalesce(v_end_meta->>'damage_type',v_weapon.tipo_dano,'bludgeoning'));
  v_damage_type:=case v_damage_type when 'cortante' then 'slashing'
    when 'perfurante' then 'piercing' when 'impacto' then 'bludgeoning'
    when 'cortante/perfurante' then 'physical' when 'impacto/perfurante' then 'physical'
    else v_damage_type end;

  select count(*)::integer,min(t.ordinality) into v_target_count,v_target_idx
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) with ordinality t(token,ordinality)
  where t.token->>'id'=v_attack.target_token_id and t.token->>'tipo' in ('player','npc','monstro');
  if v_target_count<>1 then raise exception 'Alvo ausente ou duplicado na cena.'; end if;
  v_tokens:=case when jsonb_typeof(v_campaign.cba_data->'tokens')='array' then v_campaign.cba_data->'tokens' else '[]'::jsonb end;
  v_target:=v_tokens->(v_target_idx::integer-1);
  if v_target->>'tipo'='player' then
    select sh.pv_atual,sh.pv_max into v_hp,v_max_hp
    from public.srd_character_sheets sh where sh.character_id::text=v_attack.target_token_id for update;
    if not found or v_max_hp is null or v_max_hp<1 then raise exception 'Ficha alvo sem PV válidos.'; end if;
    v_final:=priv.srd_adjust_damage(p_campaign_id,'character',v_attack.target_token_id,v_damage_type,v_raw);
    v_new_hp:=greatest(-10,least(v_max_hp,coalesce(v_hp,v_max_hp)-v_final));
    update public.srd_character_sheets set pv_atual=v_new_hp where character_id::text=v_attack.target_token_id;
    perform priv.srd_sync_character_vital_condition(v_attack.target_token_id,v_new_hp,false);
  else
    if coalesce(v_target->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' then raise exception 'PV máximo do alvo inválido.'; end if;
    v_max_hp:=(v_target->>'maxHp')::integer;
    v_hp:=case when coalesce(v_target->>'hp','') ~ '^-?[0-9]{1,6}$' then (v_target->>'hp')::integer else v_max_hp end;
    v_final:=priv.srd_adjust_damage(p_campaign_id,'token',v_attack.target_token_id,v_damage_type,v_raw);
    v_new_hp:=greatest(-10,least(v_max_hp,v_hp-v_final));
  end if;
  v_target:=v_target||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp);
  v_scene:=coalesce(v_campaign.cba_data,'{}'::jsonb)||jsonb_build_object(
    'tokens',jsonb_set(v_tokens,ARRAY[(v_target_idx-1)::text],v_target,false));
  update public.campaigns set cba_data=v_scene where id=p_campaign_id;
  perform priv.srd_sync_linked_npc_token_vitals(p_campaign_id,v_attack.target_token_id,v_new_hp,v_max_hp);

  update priv.srd_aoo_attacks set status='damage_applied',damage_rolls=p_damage_rolls,
    damage_applied=v_final,damage_idempotency_key=p_idempotency_key,damage_applied_at=now(),
    resolution_data=resolution_data||jsonb_build_object('damage_expression',v_expr,
      'damage_roll_sum',v_roll_sum,'damage_bonus',v_damage_bonus,'damage_raw',v_raw,
      'damage_final',v_final,'critical_multiplier_applied',v_mult,'damage_type',v_damage_type)
  where attack_id=p_attack_id returning * into v_attack;

  update priv.srd_aoo_pending_movements p
  set pending_reactions=jsonb_set(p.pending_reactions,ARRAY[
    (select (e.ordinality-1)::text from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
     where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1)
  ],(
    select e.value||jsonb_build_object('status','damage_applied','damage_applied',v_final)
    from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
    where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1
  ),false),updated_at=now()
  where p.pending_id=v_attack.pending_id;

  return jsonb_build_object('attack_id',p_attack_id,'status','damage_applied',
    'damage_applied',v_final,'target_hp',v_new_hp,'target_max_hp',v_max_hp,
    'damage_expression',v_expr,'damage_rolls',p_damage_rolls,
    'critical',v_attack.is_critical,'critical_multiplier',v_mult,'replayed',false);
end;
$function$;

create or replace function public.srd_finalizar_movimento_aoo_pendente_srd(
  p_campaign_id bigint,
  p_pending_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, priv, pg_temp
as $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_preview jsonb;
  v_remaining integer;
  v_user uuid:=auth.uid();
begin
  if v_user is null then raise exception 'É necessário estar autenticado.'; end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then raise exception 'Movimento pendente não está ativo.'; end if;

  if v_pending.movement_controller='gm' then
    if public.my_role(p_campaign_id) is distinct from 'GM' then raise exception 'Somente o Mestre pode concluir este movimento.'; end if;
  else
    if v_user<>v_pending.created_by then raise exception 'Somente o jogador que solicitou o movimento pode concluí-lo.'; end if;
  end if;

  if exists(select 1 from jsonb_array_elements(v_pending.pending_reactions) r
    where r->>'status' in ('waiting','reserved','attack_started','hit_pending_damage')) then
    raise exception 'Ainda existem ataques de oportunidade sem resolução.';
  end if;

  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
     or coalesce(v_campaign.combat_data->>'active','false')<>'true'
     or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
     or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'O combate avançou; solicite uma nova movimentação.';
  end if;
  if not exists(select 1 from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
    where (t->>'id'=v_pending.mover_token_id or t->>'key'=v_pending.mover_token_id)
      and coalesce(t->>'gridX','')=v_pending.origin_x::text
      and coalesce(t->>'gridY','')=v_pending.origin_y::text) then
    raise exception 'A posição original do token mudou; movimento não pode ser concluído.';
  end if;

  perform set_config('app.srd_aoo_pending_commit',p_pending_id::text,true);
  if v_pending.movement_controller='player' then
    v_preview:=public.mover_token_player_cba(
      p_campaign_id,v_pending.mover_token_id,v_pending.destination_x,v_pending.destination_y);
  else
    v_preview:=public.mover_token_gm_cba_srd(
      p_campaign_id,v_pending.mover_token_id,v_pending.destination_x,v_pending.destination_y);
  end if;

  update priv.srd_aoo_pending_movements set status='committed',
    committed_at=now(),updated_at=now() where pending_id=p_pending_id;
  perform set_config('app.srd_aoo_pending_commit','',true);
  return jsonb_build_object('committed',true,'pending_id',p_pending_id,
    'mover_token_id',v_pending.mover_token_id,
    'destination',jsonb_build_array(v_pending.destination_x,v_pending.destination_y),
    'movement_result',v_preview);
end;
$function$;

revoke all on function public.srd_encerrar_reacao_aoo_pendente_srd(bigint,uuid,text,boolean) from public,anon;
grant execute on function public.srd_encerrar_reacao_aoo_pendente_srd(bigint,uuid,text,boolean) to authenticated;
revoke all on function public.srd_aplicar_dano_ataque_oportunidade_srd(bigint,uuid,integer[],uuid) from public,anon;
grant execute on function public.srd_aplicar_dano_ataque_oportunidade_srd(bigint,uuid,integer[],uuid) to authenticated;
revoke all on function public.srd_finalizar_movimento_aoo_pendente_srd(bigint,uuid) from public,anon;
grant execute on function public.srd_finalizar_movimento_aoo_pendente_srd(bigint,uuid) to authenticated;
