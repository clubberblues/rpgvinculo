CREATE OR REPLACE FUNCTION priv.npc_resolver_ataque_iterativo_impl(p_campaign_id bigint, p_attempt_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_user uuid := auth.uid();
  v_campaign public.campaigns%rowtype;
  v_seq public.srd_npc_attack_sequences%rowtype;
  v_attempt public.srd_npc_attack_attempts%rowtype;
  v_sheet public.srd_character_sheets%rowtype;
  v_class public.srd_classes%rowtype;
  v_race public.srd_races%rowtype;
  v_weapon public.srd_equipment%rowtype;
  v_instance public.srd_character_weapon_instances%rowtype;
  v_scene jsonb;
  v_tokens jsonb;
  v_actor jsonb;
  v_target jsonb;
  v_ca_text text;
  v_ca integer;
  v_turn integer;
  v_round integer;
  v_target_count integer;
  v_actor_count integer;
  v_target_ord bigint;
  v_actor_ord bigint;
  v_bab integer;
  v_level integer;
  v_score integer;
  v_ability_mod integer;
  v_size_mod integer := 0;
  v_focus integer := 0;
  v_proficiency_penalty integer := 0;
  v_racial_bonus integer := 0;
  v_range_penalty integer := 0;
  v_effect_attack integer := 0;
  v_effect_ac integer := 0;
  v_rogue_level integer := 0;
  v_sneak_dice integer := 0;
  v_target_denies_dex boolean := false;
  v_actor_is_giant boolean := false;
  v_target_race text;
  v_target_loses_dex boolean := false;
  v_expected integer;
  v_total integer;
  v_attack_key text;
  v_weapon_name text;
  v_weapon_prof text;
  v_class_profs jsonb;
  v_proficient boolean := false;
  v_has_finesse boolean := false;
  v_target_traits text;
  v_target_type text;
  v_critical_immune boolean := false;
  v_critical_immunity_text text;
  v_critical_special_text text;
  v_ax integer; v_ay integer; v_bx integer; v_by integer;
  v_dx integer; v_dy integer; v_dist integer;
  v_attacker_size integer := 1;
  v_target_size integer := 1;
  v_range_increment numeric;
  v_range_increments integer;
  v_max_range integer;
  v_crit_text text;
  v_crit_min integer := 20;
  v_crit_mult integer := 2;
  v_is_threat boolean := false;
  v_status text;
  v_end_meta jsonb;
  v_player_ac jsonb;
begin
  if v_user is null then raise exception 'É necessário estar autenticado.'; end if;
  if public.my_role(p_campaign_id) is distinct from 'GM' then raise exception 'Somente o Mestre pode resolver ataques de NPC.'; end if;

  select * into v_campaign from public.campaigns
  where id = p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,'')) <> 'COMBATE' then
    raise exception 'A campanha não está em combate.';
  end if;

  select * into v_seq from public.srd_npc_attack_sequences
  where id = p_attempt_id and campaign_id = p_campaign_id;
  -- p_attempt_id is the attempt id; sequence is resolved below.
  select a.* into v_attempt from public.srd_npc_attack_attempts a
  where a.id = p_attempt_id for update;
  if not found then raise exception 'Tentativa de ataque não encontrada.'; end if;

  select s.* into v_seq from public.srd_npc_attack_sequences s
  where s.id = v_attempt.sequence_id and s.campaign_id = p_campaign_id
  for update;
  if not found then raise exception 'Sequência de ataque não encontrada.'; end if;

  if v_seq.created_by <> v_user then
    raise exception 'Somente quem iniciou a sequência pode resolver o ataque.';
  end if;
  if v_attempt.status <> 'pending_resolution' then
    return jsonb_build_object('attempt_id',v_attempt.id,'sequence_id',v_seq.id,
      'status',v_attempt.status,'resolution_data',v_attempt.resolution_data,'replayed',true);
  end if;
  if v_seq.status <> 'active' then raise exception 'A sequência não está ativa.'; end if;

  if public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode resolver ataques de NPC.';
  end if;
  if v_seq.created_by<>v_user then raise exception 'Somente o Mestre que iniciou a sequência pode resolvê-la.'; end if;

  v_scene := coalesce(v_campaign.cba_data,'{}'::jsonb);
  v_tokens := case when jsonb_typeof(v_scene->'tokens')='array' then v_scene->'tokens' else '[]'::jsonb end;
  v_target_count := 0; v_actor_count := 0;
  select count(*)::integer,min(t.ordinality) into v_target_count,v_target_ord
  from jsonb_array_elements(v_tokens) with ordinality t(token,ordinality)
  where t.token->>'id'=v_seq.target_token_id and t.token->>'tipo' in ('player','npc','monstro');
  if v_target_count <> 1 then raise exception 'Alvo ausente ou duplicado na cena.'; end if;
  select count(*)::integer,min(t.ordinality) into v_actor_count,v_actor_ord
  from jsonb_array_elements(v_tokens) with ordinality t(token,ordinality)
  where t.token->>'id'=v_seq.actor_token_id and t.token->>'tipo'='npc';
  if v_actor_count <> 1 then raise exception 'Token do personagem ausente ou duplicado.'; end if;
  v_target := v_tokens->(v_target_ord::integer-1);
  v_actor := v_tokens->(v_actor_ord::integer-1);
  v_actor_is_giant:=lower(concat_ws(' ',v_actor->>'creature_type',v_actor->'monsterStats'->>'type',v_actor->'monsterStats'->>'tipo',v_actor->'monsterStats'->>'creature_type',v_actor->'monsterStats'->>'subtype',v_actor->'monsterStats'->>'subtypes')) ~ '(giant|gigante)';

  v_turn := case when coalesce(v_campaign.combat_data->>'current_turn','') ~ '^[0-9]+$'
    then (v_campaign.combat_data->>'current_turn')::integer else -1 end;
  v_round := case when coalesce(v_campaign.combat_data->>'round','') ~ '^[0-9]+$'
    then greatest(1,(v_campaign.combat_data->>'round')::integer) else -1 end;
  if lower(coalesce(v_campaign.combat_data->>'active','false')) <> 'true'
     or v_turn <> v_seq.turn_index or v_round <> v_seq.round_number then
    raise exception 'A iniciativa, turno ou rodada mudou; ataque invalidado.';
  end if;
  if not exists (
    select 1 from jsonb_array_elements(coalesce(v_campaign.combat_data->'turn_order','[]'::jsonb)) e
    where e->>'id'=v_seq.actor_token_id and coalesce(e->>'is_monster','false')='true'
      and (select ordinality-1 from jsonb_array_elements(coalesce(v_campaign.combat_data->'turn_order','[]'::jsonb)) with ordinality x(e,ordinality) where x.e->>'id'=v_seq.actor_token_id limit 1)=v_turn
  ) then raise exception 'O personagem não é o ator do turno atual.'; end if;

  select sh.* into v_sheet from public.srd_character_sheets sh
  where sh.character_id=v_seq.actor_character_id;
  if not found then raise exception 'Ficha SRD não encontrada.'; end if;
  select cl.* into v_class from public.srd_classes cl where cl.id=v_sheet.classe_id;
  select r.* into v_race from public.srd_races r where r.id=v_sheet.raca_id;
  if v_class.id is null or v_race.id is null then raise exception 'Classe ou raça não encontrada.'; end if;

  select wi.* into v_instance from public.srd_character_weapon_instances wi
  where wi.instance_id=v_seq.weapon_instance_id
    and wi.character_id=v_seq.actor_character_id::text
    and wi.equipado is true and wi.hand_slot=v_seq.weapon_hand_slot
  for share;
  if not found then raise exception 'A instância de arma não está mais equipada na mão vinculada.'; end if;
  if not exists (
    select 1 from public.srd_character_equipment ce
    where ce.character_id=v_seq.actor_character_id::text
      and ce.equipment_id=v_instance.equipment_id and ce.equipado is true
      and ce.hand_slot=v_seq.weapon_hand_slot
  ) then raise exception 'O equipamento não corresponde à instância equipada.'; end if;
  select eq.* into v_weapon from public.srd_equipment eq where eq.id=v_instance.equipment_id;
  if not found then raise exception 'Arma do ataque não encontrada no catálogo.'; end if;

  v_end_meta := case when v_seq.weapon_end='off' then coalesce(v_weapon.detalhes->'weapon_end_off','{}'::jsonb)
    when v_seq.weapon_end='main' then coalesce(v_weapon.detalhes->'weapon_end_main','{}'::jsonb)
    else '{}'::jsonb end;
  if coalesce((v_weapon.detalhes->>'weapon_double')::boolean,false) and v_seq.weapon_end is null then
    raise exception 'A extremidade da arma dupla não foi vinculada.';
  end if;

  v_level := greatest(1,coalesce(v_sheet.nivel,1));
  select coalesce(sum(case lower(coalesce(clas.bab_progression,''))
    when 'good' then lv.class_level when 'bom' then lv.class_level
    when 'average' then floor(3*lv.class_level/4.0)::integer
    when 'medium' then floor(3*lv.class_level/4.0)::integer
    when 'medio' then floor(3*lv.class_level/4.0)::integer
    when 'poor' then floor(lv.class_level/2.0)::integer
    when 'ruim' then floor(lv.class_level/2.0)::integer else 0 end),0)::integer
  into v_bab
  from public.srd_character_class_levels lv
  join public.srd_classes clas on clas.id=lv.class_id
  where lv.character_id=v_seq.actor_character_id;
  if not exists(select 1 from public.srd_character_class_levels lv
      where lv.character_id=v_seq.actor_character_id) then
    v_bab := case lower(coalesce(v_class.bab_progression,''))
      when 'good' then v_level when 'bom' then v_level
      when 'average' then floor(3*v_level/4.0)::integer
      when 'medium' then floor(3*v_level/4.0)::integer
      when 'medio' then floor(3*v_level/4.0)::integer
      when 'poor' then floor(v_level/2.0)::integer
      when 'ruim' then floor(v_level/2.0)::integer else 0 end;
  end if;
  if v_bab <> v_seq.base_attack_bonus then
    raise exception 'O BBA da ficha mudou desde o início da sequência.';
  end if;

  v_weapon_name := coalesce(v_weapon.detalhes->>'weapon_proficiency_name',v_weapon.nome,'Ataque desarmado');
  v_weapon_prof := coalesce(v_weapon.detalhes->>'weapon_proficiency','');
  v_class_profs := coalesce(v_class.dados_tecnicos->'proficiencias'->'armas','[]'::jsonb);
  v_proficient := exists (
    select 1 from jsonb_array_elements_text(case when jsonb_typeof(v_class_profs)='array' then v_class_profs else '[]'::jsonb end) p
    where lower(btrim(p.value))='todas as armas simples e marciais'
      or public.srd35_normalizar_parametro_talento(p.value)=public.srd35_normalizar_parametro_talento(v_weapon_name)
      or (lower(btrim(p.value))='armas simples' and v_weapon_prof='simple')
  );
  if not v_proficient and v_weapon_prof='exotic' and v_sheet.raca_id='anao'
     and coalesce(v_weapon.detalhes->'weapon_familiarity_race_ids','[]'::jsonb) ? 'anao' then
    v_proficient := exists (
      select 1 from jsonb_array_elements_text(case when jsonb_typeof(v_class_profs)='array' then v_class_profs else '[]'::jsonb end) p
      where lower(btrim(p.value))='todas as armas simples e marciais'
    ) or exists (
      select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
      where f->>'id'='srd35_feat_martial_weapon_proficiency'
        and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name)
    );
  end if;
  if not v_proficient then
    v_proficient := exists (
      select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
      where (f->>'id'='srd35_feat_simple_weapon_proficiency' and v_weapon_prof='simple')
        or (f->>'id' in ('srd35_feat_martial_weapon_proficiency','srd35_feat_exotic_weapon_proficiency')
          and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name))
    );
  end if;
  if not v_proficient then v_proficiency_penalty := 4; end if;

  v_has_finesse := exists (
    select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
    where f->>'id'='srd35_feat_weapon_finesse'
  );
  if v_seq.attack_type='atk-dist' then
    if coalesce(v_weapon.detalhes->>'weapon_ranged','false')<>'true' then
      raise exception 'A arma vinculada não permite ataque à distância.';
    end if;
    v_attack_key := 'DES';
    v_score := coalesce(nullif(v_sheet.atributos->>'DES','')::integer,10);
  else
    if coalesce(v_weapon.detalhes->>'weapon_melee','true')='false' then
      raise exception 'A arma vinculada não permite ataque corpo a corpo.';
    end if;
    if v_has_finesse and coalesce(v_weapon.detalhes->>'weapon_finesse_eligible','false')='true' then
      v_attack_key := 'DES'; v_score := coalesce(nullif(v_sheet.atributos->>'DES','')::integer,10);
    else
      v_attack_key := 'FOR'; v_score := coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10);
    end if;
  end if;
  v_ability_mod := floor((v_score-10)::numeric/2)::integer;
  if lower(coalesce(v_race.tamanho,'')) in ('pequeno','small') then v_size_mod := 1;
  elsif lower(coalesce(v_race.tamanho,'')) in ('grande','large') then v_size_mod := -1; end if;

  v_focus := (case when exists (
    select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
    where f->>'id'='foco_em_arma' and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name)
  ) then 1 else 0 end) + (case when exists (
    select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
    where f->>'id'='srd35_feat_greater_weapon_focus' and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name)
  ) then 1 else 0 end);

  v_target_race:=lower(coalesce(nullif(v_target->>'raca_id',''),nullif(v_target->>'race_id',''),nullif(v_target->'monsterStats'->>'race_id','')));
  IF v_target->>'tipo'='player' THEN
    SELECT lower(sh.raca_id::text) INTO v_target_race
      FROM public.srd_character_sheets sh
      WHERE sh.character_id::text=v_seq.target_token_id;
  ELSIF v_target->>'tipo'='npc' AND NULLIF(v_target->>'sourceCharacterId','') IS NOT NULL THEN
    SELECT lower(sh.raca_id::text) INTO v_target_race
      FROM public.srd_character_sheets sh
      WHERE sh.character_id::text=v_target->>'sourceCharacterId';
  END IF;
  v_target_traits := lower(concat_ws(' ',v_target->>'nome',v_target->>'detalhe',
    v_target->'monsterStats'->>'tipo',v_target->'monsterStats'->>'subtipo',
    v_target->'monsterStats'->>'type',v_target->'monsterStats'->>'creature_type',
    v_target_race));
  if v_sheet.raca_id='anao' and v_target_traits ~ '(orc|goblin|hobgoblin|bugbear|goblinoid)' then v_racial_bonus := 1; end if;

  if coalesce(v_actor->>'gridX','') !~ '^-?[0-9]+$' or coalesce(v_actor->>'gridY','') !~ '^-?[0-9]+$'
    or coalesce(v_target->>'gridX','') !~ '^-?[0-9]+$' or coalesce(v_target->>'gridY','') !~ '^-?[0-9]+$' then
    raise exception 'Posição de token inválida para validar alcance.';
  end if;
  v_ax := (v_actor->>'gridX')::integer; v_ay := (v_actor->>'gridY')::integer;
  v_bx := (v_target->>'gridX')::integer; v_by := (v_target->>'gridY')::integer;
  v_dx := abs(v_bx-v_ax); v_dy := abs(v_by-v_ay);
  v_dist := greatest(v_dx,v_dy)+floor(least(v_dx,v_dy)::numeric/2)::integer;
  if v_seq.attack_type='atk-corpo' then
    if v_dist > 1 then raise exception 'Alvo fora do alcance corpo a corpo.'; end if;
  else
    v_range_increment := nullif(v_weapon.detalhes->>'range_increment_m','')::numeric;
    if v_range_increment is null then
      v_range_increment := nullif(regexp_replace(coalesce(v_weapon.detalhes->>'range_increment',''),'[^0-9.]','','g'),'')::numeric;
    end if;
    if v_range_increment is null or v_range_increment<=0 then raise exception 'Incremento de distância não cadastrado para a arma.'; end if;
    v_range_increments := greatest(1,ceil((v_dist*1.5)/v_range_increment)::integer);
    v_max_range := coalesce(nullif(v_weapon.detalhes->>'max_range_increments','')::integer,10);
    if v_range_increments>v_max_range then raise exception 'Alvo fora do alcance máximo da arma.'; end if;
    v_range_penalty := (v_range_increments-1)*2;
  end if;
  v_target_type:=lower(coalesce(nullif(v_target->'monsterStats'->>'creature_type',''),nullif(v_target->'monsterStats'->>'type',''),nullif(v_target->'monsterStats'->>'tipo',''),nullif(v_target->>'creature_type',''),nullif(v_target->>'tipo_criatura',''),nullif(v_target->>'tipo',''),''));
  v_critical_immunity_text:=translate(lower(concat_ws(' ',v_target_type,v_target->'monsterStats'->>'subtipo',v_target->'monsterStats'->>'subtype',v_target->'monsterStats'->>'subtypes')),'áàâãäéèêëíìîïóòôõöúùûüç','aaaaaeeeeiiiiooooouuuuc');
  v_critical_special_text:=translate(lower(concat_ws(' ',v_target->'monsterStats'->>'qualidades_especiais',v_target->'monsterStats'->>'special_qualities',v_target->'monsterStats'->>'specialQualities',v_target->'monsterStats'->>'immunities',v_target->'monsterStats'->>'imunidades',v_target->>'qualidades_especiais',v_target->>'special_qualities',v_target->>'immunities',v_target->>'imunidades')),'áàâãäéèêëíìîïóòôõöúùûüç','aaaaaeeeeiiiiooooouuuuc');
  v_critical_immune:=v_target_type in ('undead','morto-vivo','construct','construto','ooze','gosma','plant','planta','elemental','incorporeal','incorporeo') or v_critical_immunity_text ~ '(^|[^a-z])(undead|morto.vivo|construct|construto|ooze|gosma|plant|planta|elemental|incorporeal|incorporeo)([^a-z]|$)' or v_target->>'imune_critico'='true' or v_target->>'critical_immune'='true' or v_target->'monsterStats'->>'imune_critico'='true' or v_target->'monsterStats'->>'critical_immune'='true' or v_target->>'incorporeal'='true' or v_target->'monsterStats'->>'incorporeal'='true' or v_critical_special_text ~ '(immune to critical hits|immunity to critical hits|critical hit immunity|imune a acertos criticos|imunidade a acertos criticos|imune a criticos|imunidade a criticos)';
  v_target_denies_dex:=exists(select 1 from public.srd_campaign_conditions cc
    where cc.campaign_id=p_campaign_id and cc.target_kind='token'
      and cc.target_id in (v_seq.target_token_id,coalesce(v_target->>'key',v_seq.target_token_id))
      and cc.active is true and cc.condition_id in
        ('blinded','cowering','flatfooted','helpless','paralyzed','pinned','stunned','unconscious','dying','stable','dead'));
  select coalesce(max(lv.class_level),0) into v_rogue_level
    from public.srd_character_class_levels lv join public.srd_classes cls on cls.id=lv.class_id
    where lv.character_id=v_seq.actor_character_id and cls.class_key='rogue';
  if v_rogue_level=0 and not exists(select 1 from public.srd_character_class_levels lv
      where lv.character_id=v_seq.actor_character_id) and v_sheet.classe_id='ladino' then
    v_rogue_level:=greatest(1,coalesce(v_sheet.nivel,1));
  end if;
  if v_target_denies_dex and not v_critical_immune then
    v_sneak_dice:=least(10,floor((v_rogue_level+1)/2.0)::integer);
    if v_seq.attack_type='atk-dist' and v_dist>6 then v_sneak_dice:=0; end if;
  end if;

  v_effect_attack := priv.srd_effective_modifier(p_campaign_id,'token',v_seq.actor_token_id,'attack')
    + case when v_seq.attack_type='atk-corpo'
      then priv.srd_effective_modifier(p_campaign_id,'token',v_seq.actor_token_id,'attack_melee')
        + floor((coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)
          + priv.srd_effective_modifier(p_campaign_id,'token',v_seq.actor_token_id,'strength')-10)::numeric/2)::integer
        - floor((coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)-10)::numeric/2)::integer
      else priv.srd_effective_modifier(p_campaign_id,'token',v_seq.actor_token_id,'attack_ranged')
        + floor((coalesce(nullif(v_sheet.atributos->>'DES','')::integer,10)
          + priv.srd_effective_modifier(p_campaign_id,'token',v_seq.actor_token_id,'dexterity')-10)::numeric/2)::integer
        - floor((coalesce(nullif(v_sheet.atributos->>'DES','')::integer,10)-10)::numeric/2)::integer end;
  v_effect_ac := priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac')
    + case when v_seq.attack_type='atk-corpo'
      then priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac_melee')
      else priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac_ranged') end;

  if v_target->>'tipo'='player' then
    v_player_ac:=public.srd_calcular_ca_personagem_srd(p_campaign_id,v_seq.target_token_id,'normal',v_actor_is_giant);
    v_ca:=nullif(v_player_ac->>'final_ac','')::integer;
    if v_ca is null then raise exception 'Não foi possível calcular a CA do personagem alvo.'; end if;
  else
    v_ca_text:=coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca');
    if coalesce(v_ca_text,'') !~ '^[0-9]{1,3}$' then raise exception 'O alvo não possui CA numérica válida.'; end if;
    v_ca:=v_ca_text::integer+v_effect_ac;
  end if;
  IF v_target->>'tipo'<>'player' AND v_actor_is_giant THEN
    SELECT sh.raca_id::text INTO v_target_race
    FROM public.srd_character_sheets sh
    WHERE sh.character_id::text=COALESCE(NULLIF(v_target->>'sourceCharacterId',''),v_seq.target_token_id)
    LIMIT 1;
    v_target_race:=COALESCE(v_target_race,NULLIF(v_target->>'raca_id',''),v_target->'monsterStats'->>'race_id');
    v_target_loses_dex:=priv.srd_condition_has_flag(p_campaign_id,'token',v_seq.target_token_id,'loses_dex_ac')
      OR COALESCE(v_target->>'flat_footed','false')='true'
      OR COALESCE(v_target->'monsterStats'->>'loses_dex_ac','false')='true';
    IF v_target_race IN ('anao','gnomo') AND NOT v_target_loses_dex THEN
      v_ca:=v_ca+4;
    END IF;
  END IF;
  v_expected := v_bab + v_ability_mod + v_size_mod + v_focus + v_racial_bonus
    - v_proficiency_penalty - v_range_penalty - v_attempt.iterative_penalty - v_seq.power_attack_penalty;
  v_total := v_attempt.manual_d20 + v_expected + v_effect_attack;

  v_crit_text := coalesce(v_end_meta->>'critical',v_weapon.detalhes->>'critical',v_weapon.critico,'x2');
  if v_crit_text ~ '^[0-9]{2}(-[0-9]{2})?/x[0-9]+$' then
    v_crit_min := split_part(v_crit_text,'-',1)::integer;
    if v_crit_min < 2 or v_crit_min > 20 then raise exception 'Faixa crítica cadastrada é inválida.'; end if;
  else
    v_crit_min := 20;
  end if;
  if v_attempt.manual_d20=20 or (v_attempt.manual_d20<>1 and v_total>=v_ca) then
    v_is_threat := v_attempt.manual_d20>=v_crit_min and not v_critical_immune;
    v_status := case when v_is_threat then 'critical_confirmation_pending' else 'hit_pending_damage' end;
  else
    v_status := 'miss';
  end if;

  update public.srd_npc_attack_attempts
  set status=v_status, attack_total=v_total, target_ac=v_ca, is_critical=false,
      resolved_at=now(),
      resolution_data=jsonb_build_object(
        'attack_bonus_base',v_bab,'ability',v_attack_key,'ability_modifier',v_ability_mod,
        'size_modifier',v_size_mod,'weapon_focus',v_focus,'racial_bonus',v_racial_bonus,
        'proficiency_penalty',v_proficiency_penalty,'range_penalty',v_range_penalty,
        'iterative_penalty',v_attempt.iterative_penalty,'power_attack_penalty',v_seq.power_attack_penalty,'effect_attack_modifier',v_effect_attack,
        'attack_total',v_total,'target_ac',v_ca,'manual_d20',v_attempt.manual_d20,
        'critical_threat_minimum',v_crit_min,'critical_multiplier',coalesce(nullif(regexp_replace(v_crit_text,'^.*x',''),'')::integer,2),
        'critical_threat',v_is_threat,'critical_immune',v_critical_immune,'weapon_instance_id',v_seq.weapon_instance_id,
        'weapon_hand_slot',v_seq.weapon_hand_slot,'weapon_end',v_seq.weapon_end,'sneak_attack_dice',v_sneak_dice,'sneak_attack_eligible',(v_sneak_dice>0)
      )
  where id=v_attempt.id returning * into v_attempt;

  if v_status='miss' and v_attempt.attempt_index=v_seq.attacks_total then
    update public.srd_npc_attack_sequences set status='completed',completed_at=now() where id=v_seq.id;
  end if;

  return jsonb_build_object('attempt_id',v_attempt.id,'sequence_id',v_seq.id,
    'attempt_index',v_attempt.attempt_index,'status',v_status,'attack_total',v_total,
    'target_ac',v_ca,'critical_threat',v_is_threat,'resolution_data',v_attempt.resolution_data,
    'replayed',false);
end;
$function$
;