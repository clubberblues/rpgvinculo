
create table if not exists priv.srd_aoo_attacks (
  attack_id uuid primary key default gen_random_uuid(),
  campaign_id bigint not null references public.campaigns(id) on delete cascade,
  pending_id uuid not null references priv.srd_aoo_pending_movements(pending_id) on delete cascade,
  reaction_id uuid not null references priv.srd_aoo_reaction_ledger(reaction_id),
  actor_token_id text not null,
  target_token_id text not null,
  actor_character_id bigint not null,
  weapon_instance_id uuid not null,
  weapon_hand_slot text not null check (weapon_hand_slot in ('main_hand','off_hand')),
  weapon_end text check (weapon_end in ('main','off')),
  status text not null default 'awaiting_attack_roll'
    check (status in ('awaiting_attack_roll','awaiting_critical_confirmation','awaiting_damage','miss','damage_applied','cancelled')),
  manual_d20 integer check (manual_d20 between 1 and 20),
  critical_confirmation_d20 integer check (critical_confirmation_d20 between 1 and 20),
  attack_total integer,
  target_ac integer,
  is_critical boolean not null default false,
  damage_rolls integer[],
  damage_applied integer,
  damage_idempotency_key uuid,
  resolution_data jsonb not null default '{}'::jsonb,
  created_by uuid not null,
  created_at timestamptz not null default now(),
  resolved_at timestamptz,
  damage_applied_at timestamptz,
  unique(reaction_id),
  unique(damage_idempotency_key)
);
alter table priv.srd_aoo_attacks enable row level security;
revoke all on priv.srd_aoo_attacks from public,anon,authenticated;
create index if not exists srd_aoo_attacks_pending_status
  on priv.srd_aoo_attacks(pending_id,status);

create or replace function public.srd_iniciar_ataque_oportunidade_srd(
  p_campaign_id bigint,
  p_pending_id uuid,
  p_reactor_token_id text,
  p_reaction_id uuid,
  p_weapon_instance_id uuid,
  p_weapon_hand_slot text,
  p_weapon_end text default null
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, priv, pg_temp
as $function$
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
  v_dx:=abs(v_trigger_x-(v_token->>'gridX')::integer);
  v_dy:=abs(v_trigger_y-(v_token->>'gridY')::integer);
  v_distance:=greatest(v_dx,v_dy)+floor(least(v_dx,v_dy)::numeric/2)::integer;
  v_reach:=coalesce(nullif(v_token->>'melee_reach_ft','')::integer,5);
  if v_distance*5>v_reach then
    raise exception 'O alvo não está no alcance corpo a corpo do reator no momento da provocação.';
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
$function$;

create or replace function public.srd_registrar_rolagem_ataque_oportunidade_srd(
  p_campaign_id bigint,
  p_attack_id uuid,
  p_manual_d20 integer,
  p_idempotency_key uuid
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, priv, pg_temp
as $function$
declare
  v_attack priv.srd_aoo_attacks%rowtype;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode registrar a rolagem do ataque de oportunidade.';
  end if;
  if p_manual_d20 not between 1 and 20 or p_idempotency_key is null then
    raise exception 'A rolagem exige d20 físico válido e chave de idempotência.';
  end if;
  select * into v_attack from priv.srd_aoo_attacks
  where attack_id=p_attack_id and campaign_id=p_campaign_id for update;
  if not found then raise exception 'Ataque de oportunidade não encontrado.'; end if;
  if v_attack.created_by<>auth.uid() then raise exception 'Somente o Mestre que iniciou o ataque pode registrar a rolagem.'; end if;
  if v_attack.status<>'awaiting_attack_roll' then
    if v_attack.manual_d20=p_manual_d20 then
      return jsonb_build_object('attack_id',p_attack_id,'manual_d20',v_attack.manual_d20,'replayed',true);
    end if;
    raise exception 'Este ataque já recebeu uma rolagem diferente.';
  end if;
  update priv.srd_aoo_attacks
  set manual_d20=p_manual_d20,
      resolution_data=resolution_data||jsonb_build_object('attack_roll_idempotency_key',p_idempotency_key),
      updated_at=now()
  where attack_id=p_attack_id;
  return jsonb_build_object('attack_id',p_attack_id,'manual_d20',p_manual_d20,
    'ready_to_resolve',true,'replayed',false);
end;
$function$;

create or replace function public.srd_resolver_ataque_oportunidade_srd(
  p_campaign_id bigint,
  p_attack_id uuid
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
  v_actor_token jsonb;
  v_target jsonb;
  v_sheet public.srd_character_sheets%rowtype;
  v_class public.srd_classes%rowtype;
  v_race public.srd_races%rowtype;
  v_weapon public.srd_equipment%rowtype;
  v_instance public.srd_character_weapon_instances%rowtype;
  v_target_ac integer;
  v_target_ac_data jsonb;
  v_bab integer:=0;
  v_level integer:=1;
  v_score integer:=10;
  v_ability_mod integer:=0;
  v_size_mod integer:=0;
  v_focus integer:=0;
  v_prof_penalty integer:=0;
  v_racial_bonus integer:=0;
  v_effect_attack integer:=0;
  v_expected integer;
  v_total integer;
  v_attack_key text;
  v_weapon_name text;
  v_weapon_prof text;
  v_profs jsonb;
  v_proficient boolean:=false;
  v_finesse boolean:=false;
  v_target_traits text;
  v_crit_text text;
  v_crit_min integer:=20;
  v_crit_mult integer:=2;
  v_is_threat boolean:=false;
  v_status text;
  v_target_type text;
  v_actor_is_giant boolean:=false;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode resolver ataques de oportunidade.';
  end if;
  select * into v_attack from priv.srd_aoo_attacks
  where attack_id=p_attack_id and campaign_id=p_campaign_id for update;
  if not found then raise exception 'Ataque de oportunidade não encontrado.'; end if;
  if v_attack.created_by<>auth.uid() then raise exception 'Somente o Mestre que iniciou o ataque pode resolvê-lo.'; end if;
  if v_attack.status<>'awaiting_attack_roll' or v_attack.manual_d20 is null then
    if v_attack.status in ('awaiting_critical_confirmation','awaiting_damage','miss','damage_applied') then
      return jsonb_build_object('attack_id',p_attack_id,'status',v_attack.status,
        'attack_total',v_attack.attack_total,'target_ac',v_attack.target_ac,
        'is_critical',v_attack.is_critical,'resolution_data',v_attack.resolution_data,'replayed',true);
    end if;
    raise exception 'Registre primeiro a rolagem manual do d20.';
  end if;

  select * into v_pending from priv.srd_aoo_pending_movements
  where pending_id=v_attack.pending_id and campaign_id=p_campaign_id for update;
  if not found or v_pending.status<>'waiting_reactions' then raise exception 'Movimento pendente não está mais ativo.'; end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
    or coalesce(v_campaign.combat_data->>'active','false')<>'true'
    or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
    or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'O combate mudou antes da resolução do ataque.';
  end if;

  select t into v_actor_token from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=v_attack.actor_token_id or t->>'key'=v_attack.actor_token_id limit 1;
  select t into v_target from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=v_attack.target_token_id or t->>'key'=v_attack.target_token_id limit 1;
  if v_actor_token is null or v_target is null then raise exception 'Atacante ou alvo saiu da cena.'; end if;

  select * into v_sheet from public.srd_character_sheets where character_id=v_attack.actor_character_id;
  select * into v_class from public.srd_classes where id=v_sheet.classe_id;
  select * into v_race from public.srd_races where id=v_sheet.raca_id;
  select * into v_instance from public.srd_character_weapon_instances
  where instance_id=v_attack.weapon_instance_id and character_id=v_attack.actor_character_id::text
    and equipado is true and hand_slot=v_attack.weapon_hand_slot;
  if not found or not exists(select 1 from public.srd_character_equipment ce
    where ce.character_id=v_attack.actor_character_id::text and ce.equipment_id=v_instance.equipment_id
      and ce.equipado is true and ce.hand_slot=v_attack.weapon_hand_slot) then
    raise exception 'A arma deixou de estar equipada corretamente.';
  end if;
  select * into v_weapon from public.srd_equipment where id=v_instance.equipment_id;

  v_level:=greatest(1,coalesce(v_sheet.nivel,1));
  select coalesce(sum(case lower(coalesce(cl.bab_progression,''))
    when 'good' then lv.class_level when 'bom' then lv.class_level
    when 'average' then floor(3*lv.class_level/4.0)::integer
    when 'medium' then floor(3*lv.class_level/4.0)::integer
    when 'medio' then floor(3*lv.class_level/4.0)::integer
    when 'poor' then floor(lv.class_level/2.0)::integer
    when 'ruim' then floor(lv.class_level/2.0)::integer else 0 end),0)::integer
  into v_bab from public.srd_character_class_levels lv
  join public.srd_classes cl on cl.id=lv.class_id where lv.character_id=v_attack.actor_character_id;
  if not exists(select 1 from public.srd_character_class_levels lv where lv.character_id=v_attack.actor_character_id) then
    v_bab:=case lower(coalesce(v_class.bab_progression,''))
      when 'good' then v_level when 'bom' then v_level
      when 'average' then floor(3*v_level/4.0)::integer
      when 'medium' then floor(3*v_level/4.0)::integer
      when 'medio' then floor(3*v_level/4.0)::integer
      when 'poor' then floor(v_level/2.0)::integer
      when 'ruim' then floor(v_level/2.0)::integer else 0 end;
  end if;

  v_weapon_name:=coalesce(v_weapon.detalhes->>'weapon_proficiency_name',v_weapon.nome);
  v_weapon_prof:=coalesce(v_weapon.detalhes->>'weapon_proficiency','');
  v_profs:=coalesce(v_class.dados_tecnicos->'proficiencias'->'armas','[]'::jsonb);
  v_proficient:=exists(select 1 from jsonb_array_elements_text(case when jsonb_typeof(v_profs)='array' then v_profs else '[]'::jsonb end) p
    where lower(btrim(p.value))='todas as armas simples e marciais'
      or public.srd35_normalizar_parametro_talento(p.value)=public.srd35_normalizar_parametro_talento(v_weapon_name)
      or (lower(btrim(p.value))='armas simples' and v_weapon_prof='simple'));
  if not v_proficient then
    v_proficient:=exists(select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
      where (f->>'id'='srd35_feat_simple_weapon_proficiency' and v_weapon_prof='simple')
        or (f->>'id' in ('srd35_feat_martial_weapon_proficiency','srd35_feat_exotic_weapon_proficiency')
          and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name)));
  end if;
  if not v_proficient then v_prof_penalty:=4; end if;

  v_finesse:=exists(select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
    where f->>'id'='srd35_feat_weapon_finesse');
  if v_finesse and coalesce(v_weapon.detalhes->>'weapon_finesse_eligible','false')='true' then
    v_attack_key:='DES'; v_score:=coalesce(nullif(v_sheet.atributos->>'DES','')::integer,10);
  else
    v_attack_key:='FOR'; v_score:=coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10);
  end if;
  v_ability_mod:=floor((v_score-10)::numeric/2)::integer;
  if lower(coalesce(v_race.tamanho,'')) in ('pequeno','small') then v_size_mod:=1;
  elsif lower(coalesce(v_race.tamanho,'')) in ('grande','large') then v_size_mod:=-1; end if;

  v_focus:=(case when exists(select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
      where f->>'id'='foco_em_arma' and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name)) then 1 else 0 end)
    +(case when exists(select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
      where f->>'id'='srd35_feat_greater_weapon_focus' and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name)) then 1 else 0 end);

  v_target_traits:=lower(concat_ws(' ',v_target->>'nome',v_target->>'detalhe',
    v_target->'monsterStats'->>'tipo',v_target->'monsterStats'->>'subtipo',
    v_target->'monsterStats'->>'type',v_target->'monsterStats'->>'creature_type'));
  if v_race.id='anao' and v_target_traits ~ '(orc|goblin|hobgoblin|bugbear|goblinoid)' then v_racial_bonus:=1; end if;

  v_effect_attack:=priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'attack')
    +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'attack_melee')
    +floor((coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)
      +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'strength')-10)::numeric/2)::integer
    -floor((coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)-10)::numeric/2)::integer;

  if v_target->>'tipo'='player' then
    v_target_ac_data:=public.srd_calcular_ca_personagem_srd(p_campaign_id,v_attack.target_token_id,'normal',false);
    v_target_ac:=nullif(v_target_ac_data->>'final_ac','')::integer;
  else
    if coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca','') !~ '^[0-9]{1,3}$' then
      raise exception 'O alvo não possui CA numérica válida.';
    end if;
    v_target_ac:=(coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca'))::integer
      +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac')
      +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
  end if;
  if v_target_ac is null then raise exception 'Não foi possível calcular a CA do alvo.'; end if;

  v_expected:=v_bab+v_ability_mod+v_size_mod+v_focus+v_racial_bonus-v_prof_penalty;
  v_total:=v_attack.manual_d20+v_expected+v_effect_attack;
  v_crit_text:=coalesce(v_attack.resolution_data->>'weapon_critical',v_weapon.critico,'x2');
  if v_crit_text ~ '^[0-9]{2}(-[0-9]{2})?/x[0-9]+$' then
    v_crit_min:=split_part(v_crit_text,'-',1)::integer;
  else
    v_crit_min:=20;
  end if;
  if v_crit_min<2 or v_crit_min>20 then v_crit_min:=20; end if;
  v_crit_mult:=coalesce(nullif(regexp_replace(v_crit_text,'^.*x',''),'')::integer,2);
  if v_crit_mult<2 or v_crit_mult>5 then v_crit_mult:=2; end if;

  if v_attack.manual_d20=20 or (v_attack.manual_d20<>1 and v_total>=v_target_ac) then
    v_is_threat:=v_attack.manual_d20>=v_crit_min;
    v_status:=case when v_is_threat then 'awaiting_critical_confirmation' else 'awaiting_damage' end;
  else
    v_status:='miss';
  end if;

  update priv.srd_aoo_attacks set
    status=v_status,attack_total=v_total,target_ac=v_target_ac,
    resolution_data=resolution_data||jsonb_build_object(
      'base_attack_bonus',v_bab,'ability',v_attack_key,'ability_modifier',v_ability_mod,
      'size_modifier',v_size_mod,'weapon_focus',v_focus,'racial_bonus',v_racial_bonus,
      'proficiency_penalty',v_prof_penalty,'effect_attack_modifier',v_effect_attack,
      'attack_total',v_total,'target_ac',v_target_ac,'manual_d20',v_attack.manual_d20,
      'critical_threat_minimum',v_crit_min,'critical_multiplier',v_crit_mult,
      'critical_threat',v_is_threat
    ),resolved_at=now()
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
    'damage_expression',v_weapon.dano,'resolution_data',v_attack.resolution_data,
    'action_economy_cost',0);
end;
$function$;

create or replace function public.srd_confirmar_critico_ataque_oportunidade_srd(
  p_campaign_id bigint,
  p_attack_id uuid,
  p_confirmation_d20 integer
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, priv, pg_temp
as $function$
declare
  v_attack priv.srd_aoo_attacks%rowtype;
  v_bonus integer;
  v_total integer;
  v_confirmed boolean;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode confirmar o crítico.';
  end if;
  if p_confirmation_d20 not between 1 and 20 then raise exception 'Confirmação crítica exige d20 físico válido.'; end if;
  select * into v_attack from priv.srd_aoo_attacks
  where attack_id=p_attack_id and campaign_id=p_campaign_id for update;
  if not found or v_attack.created_by<>auth.uid() then raise exception 'Ataque não encontrado ou sem autorização.'; end if;
  if v_attack.status<>'awaiting_critical_confirmation' then
    return jsonb_build_object('attack_id',p_attack_id,'status',v_attack.status,
      'is_critical',v_attack.is_critical,'replayed',true);
  end if;
  v_bonus:=v_attack.attack_total-v_attack.manual_d20;
  v_total:=p_confirmation_d20+v_bonus;
  v_confirmed:=p_confirmation_d20=20 or (p_confirmation_d20<>1 and v_total>=v_attack.target_ac);
  update priv.srd_aoo_attacks set
    critical_confirmation_d20=p_confirmation_d20,is_critical=v_confirmed,
    status='awaiting_damage',
    resolution_data=resolution_data||jsonb_build_object(
      'critical_confirmation_d20',p_confirmation_d20,
      'critical_confirmation_total',v_total,'critical_confirmed',v_confirmed
    )
  where attack_id=p_attack_id returning * into v_attack;
  update priv.srd_aoo_pending_movements p
  set pending_reactions=jsonb_set(p.pending_reactions,ARRAY[
    (select (e.ordinality-1)::text from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
     where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1)
  ],(
    select e.value||jsonb_build_object('status','hit_pending_damage','critical',v_confirmed)
    from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
    where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1
  ),false),updated_at=now()
  where p.pending_id=v_attack.pending_id;
  return jsonb_build_object('attack_id',p_attack_id,'status','awaiting_damage',
    'critical_confirmed',v_confirmed,'confirmation_total',v_total,
    'damage_expression',v_attack.resolution_data->>'weapon_damage');
end;
$function$;

revoke all on function public.srd_iniciar_ataque_oportunidade_srd(bigint,uuid,text,uuid,uuid,text,text) from public,anon;
grant execute on function public.srd_iniciar_ataque_oportunidade_srd(bigint,uuid,text,uuid,uuid,text,text) to authenticated;
revoke all on function public.srd_registrar_rolagem_ataque_oportunidade_srd(bigint,uuid,integer,uuid) from public,anon;
grant execute on function public.srd_registrar_rolagem_ataque_oportunidade_srd(bigint,uuid,integer,uuid) to authenticated;
revoke all on function public.srd_resolver_ataque_oportunidade_srd(bigint,uuid) from public,anon;
grant execute on function public.srd_resolver_ataque_oportunidade_srd(bigint,uuid) to authenticated;
revoke all on function public.srd_confirmar_critico_ataque_oportunidade_srd(bigint,uuid,integer) from public,anon;
grant execute on function public.srd_confirmar_critico_ataque_oportunidade_srd(bigint,uuid,integer) to authenticated;
