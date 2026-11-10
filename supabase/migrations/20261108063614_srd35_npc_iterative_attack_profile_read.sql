
create or replace function public.consultar_ataque_iterativo_npc_srd(
  p_campaign_id bigint,
  p_token_id text,
  p_attack_type text
) returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, priv, pg_temp
as $function$
declare
  v_user uuid := auth.uid();
  v_campaign public.campaigns%rowtype;
  v_token jsonb;
  v_token_count integer;
  v_character_id text;
  v_character public.characters%rowtype;
  v_sheet public.srd_character_sheets%rowtype;
  v_class public.srd_classes%rowtype;
  v_race public.srd_races%rowtype;
  v_bab integer := 0;
  v_level integer := 1;
  v_barbarian_level integer := 0;
  v_strength integer := 10;
  v_dexterity integer := 10;
  v_weapons jsonb := '[]'::jsonb;
  v_order jsonb;
  v_actor jsonb;
  v_current integer;
  v_round integer;
  v_action_state jsonb;
  v_actor_actions jsonb;
  v_has_power_attack boolean := false;
begin
  if v_user is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre autenticado pode consultar ataques de NPC.';
  end if;
  if lower(btrim(coalesce(p_attack_type,''))) not in ('atk-corpo','atk-dist') then
    raise exception 'Tipo de ataque inválido.';
  end if;

  select c.* into v_campaign
  from public.campaigns c where c.id=p_campaign_id;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
     or lower(coalesce(v_campaign.combat_data->>'active','false'))<>'true' then
    raise exception 'A campanha não está em combate ativo.';
  end if;

  v_order:=case when jsonb_typeof(v_campaign.combat_data->'turn_order')='array'
    then v_campaign.combat_data->'turn_order' else '[]'::jsonb end;
  if coalesce(v_campaign.combat_data->>'current_turn','') !~ '^[0-9]+$' then
    raise exception 'O turno atual é inválido.';
  end if;
  v_current:=(v_campaign.combat_data->>'current_turn')::integer;
  if v_current<0 or v_current>=jsonb_array_length(v_order) then
    raise exception 'Índice do turno atual fora da iniciativa.';
  end if;
  v_actor:=v_order->v_current;
  if v_actor->>'id' is distinct from btrim(p_token_id)
     or coalesce(v_actor->>'is_monster','false')<>'true' then
    raise exception 'O NPC não está no turno ativo do Mestre.';
  end if;

  select count(*)::integer,(jsonb_agg(t.token)->0)
  into v_token_count,v_token
  from jsonb_array_elements(case when jsonb_typeof(v_campaign.cba_data->'tokens')='array'
    then v_campaign.cba_data->'tokens' else '[]'::jsonb end) t(token)
  where t.token->>'id'=btrim(p_token_id) and t.token->>'tipo'='npc';
  if v_token_count<>1 then
    raise exception 'O token NPC está ausente ou duplicado.';
  end if;

  v_character_id:=nullif(v_token->>'sourceCharacterId','');
  if v_character_id is null then
    return jsonb_build_object('eligible',false,'reason','unlinked_npc');
  end if;
  select ch.* into v_character from public.characters ch where ch.id::text=v_character_id;
  if not found then raise exception 'Ficha de origem do NPC não encontrada.'; end if;
  select sh.* into v_sheet from public.srd_character_sheets sh where sh.character_id=v_character.id;
  if not found then return jsonb_build_object('eligible',false,'reason','missing_srd_sheet'); end if;

  select cl.* into v_class from public.srd_classes cl where cl.id=v_sheet.classe_id;
  select r.* into v_race from public.srd_races r where r.id=v_sheet.raca_id;
  if v_class.id is null or v_race.id is null then
    raise exception 'Classe ou raça da ficha de origem não encontrada.';
  end if;
  v_level:=greatest(1,coalesce(v_sheet.nivel,1));
  v_strength:=coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10);
  v_dexterity:=coalesce(nullif(v_sheet.atributos->>'DES','')::integer,10);

  select coalesce(sum(case lower(coalesce(cl.bab_progression,''))
    when 'good' then lv.class_level when 'bom' then lv.class_level
    when 'average' then floor(3*lv.class_level/4.0)::integer
    when 'medium' then floor(3*lv.class_level/4.0)::integer
    when 'medio' then floor(3*lv.class_level/4.0)::integer
    when 'poor' then floor(lv.class_level/2.0)::integer
    when 'ruim' then floor(lv.class_level/2.0)::integer else 0 end),0)::integer
  into v_bab
  from public.srd_character_class_levels lv
  join public.srd_classes cl on cl.id=lv.class_id
  where lv.character_id=v_sheet.character_id;
  if not exists(select 1 from public.srd_character_class_levels lv where lv.character_id=v_sheet.character_id) then
    v_bab:=case lower(coalesce(v_class.bab_progression,''))
      when 'good' then v_level when 'bom' then v_level
      when 'average' then floor(3*v_level/4.0)::integer
      when 'medium' then floor(3*v_level/4.0)::integer
      when 'medio' then floor(3*v_level/4.0)::integer
      when 'poor' then floor(v_level/2.0)::integer
      when 'ruim' then floor(v_level/2.0)::integer else 0 end;
  end if;
  select coalesce(max(lv.class_level),0)::integer into v_barbarian_level
  from public.srd_character_class_levels lv
  join public.srd_classes cl on cl.id=lv.class_id
  where lv.character_id=v_sheet.character_id and cl.class_key='barbarian';
  if v_barbarian_level=0 and not exists(select 1 from public.srd_character_class_levels lv where lv.character_id=v_sheet.character_id)
     and v_sheet.classe_id='barbaro' then
    v_barbarian_level:=v_level;
  end if;

  v_has_power_attack:=exists(
    select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array'
      then v_sheet.talentos else '[]'::jsonb end) f
    where f->>'id'='ataque_poderoso'
  );

  select coalesce(jsonb_agg(jsonb_build_object(
    'instance_id',wi.instance_id,'equipment_id',wi.equipment_id,
    'hand_slot',wi.hand_slot,'name',eq.nome,'damage',eq.dano,
    'critical',eq.critico,'details',eq.detalhes
  ) order by case wi.hand_slot when 'main_hand' then 1 else 2 end,eq.nome),'[]'::jsonb)
  into v_weapons
  from public.srd_character_weapon_instances wi
  join public.srd_equipment eq on eq.id=wi.equipment_id
  join public.srd_character_equipment ce
    on ce.character_id=v_sheet.character_id::text
   and ce.equipment_id=wi.equipment_id
   and ce.equipado is true and ce.hand_slot=wi.hand_slot
  where wi.character_id=v_sheet.character_id::text
    and wi.equipado is true
    and wi.hand_slot in ('main_hand','off_hand')
    and case when p_attack_type='atk-dist'
      then coalesce(eq.detalhes->>'weapon_ranged','false')='true'
      else coalesce(eq.detalhes->>'weapon_melee','true')<>'false' end;

  v_round:=case when coalesce(v_campaign.combat_data->>'round','') ~ '^[0-9]+$'
    then greatest(1,(v_campaign.combat_data->>'round')::integer) else 1 end;
  v_action_state:=v_campaign.combat_data->'action_economy';
  if jsonb_typeof(v_action_state)='object'
     and coalesce(v_action_state->>'round','')=v_round::text
     and jsonb_typeof(v_action_state->'by_character')='object' then
    v_actor_actions:=v_action_state->'by_character'->btrim(p_token_id);
  end if;

  return jsonb_build_object(
    'eligible',v_bab>=6,
    'reason',case when v_bab<6 then 'bab_below_6' when jsonb_array_length(v_weapons)=0 then 'no_equipped_weapon' else null end,
    'token_id',btrim(p_token_id),'token_name',coalesce(v_token->>'nome','NPC'),
    'character_id',v_character_id,'character_name',v_character.nome,
    'class_id',v_sheet.classe_id,'class_name',v_class.nome,
    'barbarian_level',v_barbarian_level,'character_level',v_level,
    'race_id',v_sheet.raca_id,'size',v_race.tamanho,
    'strength',v_strength,'dexterity',v_dexterity,
    'strength_modifier',floor((v_strength-10)::numeric/2)::integer,
    'dexterity_modifier',floor((v_dexterity-10)::numeric/2)::integer,
    'base_attack_bonus',v_bab,
    'attacks_total',case when v_bab>=6 then least(6,1+floor((v_bab-1)/5.0)::integer) else 1 end,
    'power_attack_available',v_has_power_attack,
    'attack_type',p_attack_type,'weapons',v_weapons,
    'full_round_action_already_used',coalesce(v_actor_actions->>'ataque_total','false')='true'
      or coalesce(v_actor_actions->>'padrao','false')='true'
      or coalesce(v_actor_actions->>'movimento','false')='true'
  );
end;
$function$;

revoke all on function public.consultar_ataque_iterativo_npc_srd(bigint,text,text) from public, anon;
grant execute on function public.consultar_ataque_iterativo_npc_srd(bigint,text,text) to authenticated;
