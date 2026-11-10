CREATE OR REPLACE FUNCTION public.srd_resolver_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
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
  v_target_race text;
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

  if v_attack.actor_character_id is null then
    v_actor_is_giant:=lower(concat_ws(' ',v_actor_token->>'creature_type',
      v_actor_token->'monsterStats'->>'type',v_actor_token->'monsterStats'->>'tipo',
      v_actor_token->'monsterStats'->>'creature_type',v_actor_token->'monsterStats'->>'subtype')) ~ '(giant|gigante)';
    if v_target->>'tipo'='player' then
      v_target_ac_data:=public.srd_calcular_ca_personagem_srd(p_campaign_id,v_attack.target_token_id,'normal',v_actor_is_giant);
      v_target_ac:=nullif(v_target_ac_data->>'final_ac','')::integer
        +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
    elsif v_target->>'tipo'='npc' AND NULLIF(v_target->>'sourceCharacterId','') IS NOT NULL then
      v_target_ac_data:=priv.srd_calcular_ca_alvo_campanha_srd(
        p_campaign_id,v_target->>'sourceCharacterId','normal'
      );
      v_target_ac:=nullif(v_target_ac_data->>'final_ac','')::integer
        +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
      if v_actor_is_giant then
        select lower(sh.raca_id::text) into v_target_race
          from public.srd_character_sheets sh
         where sh.character_id::text=v_target->>'sourceCharacterId';
        if v_target_race in ('anao','gnomo')
           and not coalesce((v_target_ac_data->>'dexterity_lost')::boolean,false) then
          v_target_ac:=v_target_ac+4;
        end if;
      end if;
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
  -- Para Anões, armas com familiaridade racial são tratadas como marciais.
  if not v_proficient and v_race.id='anao' and v_weapon_prof='exotic'
     and coalesce(v_weapon.detalhes->'weapon_familiarity_race_ids','[]'::jsonb) ? 'anao' then
    v_proficient:=exists(select 1 from jsonb_array_elements_text(case when jsonb_typeof(v_profs)='array' then v_profs else '[]'::jsonb end) p
      where lower(btrim(p.value))='todas as armas simples e marciais');
  end if;
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

  v_target_race:=lower(coalesce(nullif(v_target->>'raca_id',''),
    nullif(v_target->>'race_id',''),nullif(v_target->'monsterStats'->>'race_id','')));
  if v_target->>'tipo'='player' then
    select lower(sh.raca_id::text) into v_target_race
      from public.srd_character_sheets sh
     where sh.character_id::text=v_attack.target_token_id;
  elsif v_target->>'tipo'='npc' and nullif(v_target->>'sourceCharacterId','') is not null then
    select lower(sh.raca_id::text) into v_target_race
      from public.srd_character_sheets sh
     where sh.character_id::text=v_target->>'sourceCharacterId';
  end if;
  v_target_traits:=lower(concat_ws(' ',v_target->>'nome',v_target->>'detalhe',
    v_target->'monsterStats'->>'tipo',v_target->'monsterStats'->>'subtipo',
    v_target->'monsterStats'->>'type',v_target->'monsterStats'->>'creature_type',
    v_target_race));
  if v_race.id='anao' and v_target_traits ~ '(^|[^a-z])(orc|goblin|hobgoblin|bugbear|goblinoid(e)?)([^a-z]|$)' then v_racial_bonus:=1; end if;

  v_effect_attack:=priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'attack')
    +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'attack_melee')
    +floor((coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)
      +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.actor_token_id,'strength')-10)::numeric/2)::integer
    -floor((coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)-10)::numeric/2)::integer;

  v_actor_is_giant:=lower(concat_ws(' ',v_actor_token->>'creature_type',v_actor_token->'monsterStats'->>'type',v_actor_token->'monsterStats'->>'tipo',v_actor_token->'monsterStats'->>'creature_type',v_actor_token->'monsterStats'->>'subtype',v_actor_token->'monsterStats'->>'subtypes')) ~ '(giant|gigante)';
  if v_target->>'tipo'='player' then
    v_target_ac_data:=public.srd_calcular_ca_personagem_srd(p_campaign_id,v_attack.target_token_id,'normal',v_actor_is_giant);
    v_target_ac:=nullif(v_target_ac_data->>'final_ac','')::integer
      +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
  elsif v_target->>'tipo'='npc' AND NULLIF(v_target->>'sourceCharacterId','') IS NOT NULL then
    v_target_ac_data:=priv.srd_calcular_ca_alvo_campanha_srd(
      p_campaign_id,v_target->>'sourceCharacterId','normal'
    );
    v_target_ac:=nullif(v_target_ac_data->>'final_ac','')::integer
      +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
    if v_actor_is_giant then
      select lower(sh.raca_id::text) into v_target_race
        from public.srd_character_sheets sh
       where sh.character_id::text=v_target->>'sourceCharacterId';
      if v_target_race in ('anao','gnomo')
         and not coalesce((v_target_ac_data->>'dexterity_lost')::boolean,false) then
        v_target_ac:=v_target_ac+4;
      end if;
    end if;
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
$function$
