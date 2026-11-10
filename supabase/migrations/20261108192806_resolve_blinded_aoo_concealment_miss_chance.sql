
create or replace function priv.srd_aoo_require_blind_concealment_roll()
returns trigger
language plpgsql
security definer
set search_path=pg_catalog,public,priv,pg_temp
as $function$
begin
  if new.status='awaiting_damage'
     and old.status is distinct from 'awaiting_miss_chance'
     and not (coalesce(new.resolution_data,'{}'::jsonb) ? 'concealment_d100') then
    if priv.srd_condition_has_flag(new.campaign_id,'token',new.actor_token_id,'opponents_total_concealment')
       or (new.actor_character_id is not null and
         priv.srd_condition_has_flag(new.campaign_id,'character',new.actor_character_id::text,'opponents_total_concealment')) then
      new.resolution_data:=coalesce(new.resolution_data,'{}'::jsonb)||jsonb_build_object(
        'concealment_required',true,
        'concealment_miss_chance',50,
        'concealment_source','opponents_total_concealment',
        'concealment_pending_status','awaiting_damage'
      );
      new.status:='awaiting_miss_chance';
    end if;
  end if;
  return new;
end;
$function$;
revoke all on function priv.srd_aoo_require_blind_concealment_roll() from public,anon,authenticated;
drop trigger if exists trg_srd_aoo_require_blind_concealment_roll on priv.srd_aoo_attacks;
create trigger trg_srd_aoo_require_blind_concealment_roll
before update of status on priv.srd_aoo_attacks
for each row execute function priv.srd_aoo_require_blind_concealment_roll();

create or replace function public.srd_registrar_ocultacao_ataque_oportunidade_srd(
  p_campaign_id bigint,p_attack_id uuid,p_manual_d100 integer
) returns jsonb
language plpgsql
security definer
set search_path=pg_catalog,public,priv,pg_temp
as $function$
declare
  v_attack priv.srd_aoo_attacks%rowtype;
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_next_status text;
  v_reaction_index integer;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode registrar a chance de falha por ocultação.';
  end if;
  if p_manual_d100 not between 1 and 100 then
    raise exception 'A chance de falha exige um resultado D100 físico entre 1 e 100.';
  end if;
  select * into v_attack from priv.srd_aoo_attacks
  where campaign_id=p_campaign_id and attack_id=p_attack_id for update;
  if not found or v_attack.created_by<>auth.uid() then
    raise exception 'Ataque não encontrado ou sem autorização.';
  end if;
  if v_attack.status<>'awaiting_miss_chance' then
    if v_attack.resolution_data ? 'concealment_d100'
       and (v_attack.resolution_data->>'concealment_d100')::integer=p_manual_d100 then
      return jsonb_build_object('attack_id',p_attack_id,'status',v_attack.status,
        'miss_chance',50,'d100',p_manual_d100,
        'missed',coalesce((v_attack.resolution_data->>'concealment_missed')::boolean,false),
        'replayed',true);
    end if;
    raise exception 'Este ataque não aguarda a rolagem de ocultação.';
  end if;
  if coalesce(v_attack.resolution_data->>'concealment_miss_chance','')<>'50'
     or coalesce(v_attack.resolution_data->>'concealment_pending_status','')<>'awaiting_damage' then
    raise exception 'Os dados de ocultação do ataque são inválidos.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=v_attack.pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then
    raise exception 'O movimento que originou o ataque não está mais pendente.';
  end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
    or coalesce(v_campaign.combat_data->>'active','false')<>'true'
    or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
    or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'O combate avançou antes da rolagem de ocultação.';
  end if;
  v_next_status:=case when p_manual_d100<=50 then 'miss' else 'awaiting_damage' end;
  update priv.srd_aoo_attacks
  set status=v_next_status,
      resolution_data=resolution_data||jsonb_build_object(
        'concealment_d100',p_manual_d100,
        'concealment_missed',(p_manual_d100<=50),
        'concealment_resolved_at',now()
      ),
      resolved_at=case when p_manual_d100<=50 then now() else resolved_at end
  where attack_id=p_attack_id returning * into v_attack;

  select (e.ordinality-1)::integer into v_reaction_index
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality e(value,ordinality)
  where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1;
  if v_reaction_index is null then
    raise exception 'A reação vinculada ao ataque não foi encontrada.';
  end if;
  update priv.srd_aoo_pending_movements p
  set pending_reactions=jsonb_set(p.pending_reactions,ARRAY[v_reaction_index::text],
    (p.pending_reactions->v_reaction_index)||jsonb_build_object(
      'status',case when p_manual_d100<=50 then 'miss' else 'hit_pending_damage' end,
      'concealment_d100',p_manual_d100,
      'concealment_missed',(p_manual_d100<=50)
    ),false),updated_at=now()
  where p.pending_id=v_attack.pending_id;
  return jsonb_build_object('attack_id',p_attack_id,'status',v_next_status,
    'd100',p_manual_d100,'miss_chance',50,'missed',(p_manual_d100<=50),
    'replayed',false);
end;
$function$;
revoke all on function public.srd_registrar_ocultacao_ataque_oportunidade_srd(bigint,uuid,integer) from public,anon;
grant execute on function public.srd_registrar_ocultacao_ataque_oportunidade_srd(bigint,uuid,integer) to authenticated;
