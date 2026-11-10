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
  if v_sheet.raca_id='anao' and v_target_traits ~ '(^|[^a-z])orc|goblin|hobgoblin|bugbear|goblinoid([^a-z]|$)' then v_racial_bonus := 1; end if;

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
$function$;

CREATE OR REPLACE FUNCTION public.resolver_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_user uuid := auth.uid();
  v_campaign public.campaigns%rowtype;
  v_seq public.srd_attack_sequences%rowtype;
  v_attempt public.srd_attack_sequence_attempts%rowtype;
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
  v_expected integer;
  v_total integer;
  v_attack_key text;
  v_weapon_name text;
  v_weapon_prof text;
  v_class_profs jsonb;
  v_proficient boolean := false;
  v_has_finesse boolean := false;
  v_target_traits text;
  v_target_race text;
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

  select * into v_campaign from public.campaigns
  where id = p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,'')) <> 'COMBATE' then
    raise exception 'A campanha não está em combate.';
  end if;

  select * into v_seq from public.srd_attack_sequences
  where id = p_attempt_id and campaign_id = p_campaign_id;
  -- p_attempt_id is the attempt id; sequence is resolved below.
  select a.* into v_attempt from public.srd_attack_sequence_attempts a
  where a.id = p_attempt_id for update;
  if not found then raise exception 'Tentativa de ataque não encontrada.'; end if;

  select s.* into v_seq from public.srd_attack_sequences s
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

  if not exists (
    select 1 from public.characters ch
    join public.members m on m.campaign_id=ch.campaign_id and m.user_id=ch.user_id
    where ch.id=v_seq.actor_character_id and ch.campaign_id=p_campaign_id
      and ch.user_id=v_user and m.role='PLAYER'
  ) then raise exception 'A ficha atacante não pertence ao jogador autenticado nesta campanha.'; end if;

  v_scene := coalesce(v_campaign.cba_data,'{}'::jsonb);
  v_tokens := case when jsonb_typeof(v_scene->'tokens')='array' then v_scene->'tokens' else '[]'::jsonb end;
  v_target_count := 0; v_actor_count := 0;
  select count(*)::integer,min(t.ordinality) into v_target_count,v_target_ord
  from jsonb_array_elements(v_tokens) with ordinality t(token,ordinality)
  where t.token->>'id'=v_seq.target_token_id and t.token->>'tipo' in ('npc','monstro','player');
  if v_target_count <> 1 then raise exception 'Alvo ausente ou duplicado na cena.'; end if;
  select count(*)::integer,min(t.ordinality) into v_actor_count,v_actor_ord
  from jsonb_array_elements(v_tokens) with ordinality t(token,ordinality)
  where t.token->>'id'=v_seq.actor_character_id::text and t.token->>'tipo'='player';
  if v_actor_count <> 1 then raise exception 'Token do personagem ausente ou duplicado.'; end if;
  v_target := v_tokens->(v_target_ord::integer-1);
  v_actor := v_tokens->(v_actor_ord::integer-1);

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
    where e->>'id'=v_seq.actor_character_id::text and coalesce(e->>'is_monster','false')<>'true'
      and (select ordinality-1 from jsonb_array_elements(coalesce(v_campaign.combat_data->'turn_order','[]'::jsonb)) with ordinality x(e,ordinality) where x.e->>'id'=v_seq.actor_character_id::text limit 1)=v_turn
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
  if v_sheet.raca_id='anao' and v_target_traits ~ '(^|[^a-z])orc|goblin|hobgoblin|bugbear|goblinoid([^a-z]|$)' then v_racial_bonus := 1; end if;

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

  v_effect_attack := priv.srd_effective_modifier(p_campaign_id,'character',v_seq.actor_character_id::text,'attack')
    + case when v_seq.attack_type='atk-corpo'
      then priv.srd_effective_modifier(p_campaign_id,'character',v_seq.actor_character_id::text,'attack_melee')
        + floor((coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)
          + priv.srd_effective_modifier(p_campaign_id,'character',v_seq.actor_character_id::text,'strength')-10)::numeric/2)::integer
        - floor((coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)-10)::numeric/2)::integer
      else priv.srd_effective_modifier(p_campaign_id,'character',v_seq.actor_character_id::text,'attack_ranged')
        + floor((coalesce(nullif(v_sheet.atributos->>'DES','')::integer,10)
          + priv.srd_effective_modifier(p_campaign_id,'character',v_seq.actor_character_id::text,'dexterity')-10)::numeric/2)::integer
        - floor((coalesce(nullif(v_sheet.atributos->>'DES','')::integer,10)-10)::numeric/2)::integer end;
  v_effect_ac := priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac')
    + case when v_seq.attack_type='atk-corpo'
      then priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac_melee')
      else priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac_ranged') end;

  if v_target->>'tipo'='player' then
    v_player_ac:=priv.srd_calcular_ca_alvo_campanha_srd(
      p_campaign_id,v_seq.target_token_id,'normal'
    );
    v_ca:=nullif(v_player_ac->>'final_ac','')::integer;
    if v_ca is null then raise exception 'Não foi possível calcular a CA do personagem alvo.'; end if;
    v_ca:=v_ca+case when v_seq.attack_type='atk-corpo'
      then priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac_melee')
      else priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac_ranged') end;
  else
    v_ca_text := coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca');
    if coalesce(v_ca_text,'') !~ '^[0-9]{1,3}$' then raise exception 'O alvo não possui CA numérica válida.'; end if;
    v_ca := v_ca_text::integer + v_effect_ac;
  end if;
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

  update public.srd_attack_sequence_attempts
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
    update public.srd_attack_sequences set status='completed',completed_at=now() where id=v_seq.id;
  end if;

  return jsonb_build_object('attempt_id',v_attempt.id,'sequence_id',v_seq.id,
    'attempt_index',v_attempt.attempt_index,'status',v_status,'attack_total',v_total,
    'target_ac',v_ca,'critical_threat',v_is_threat,'resolution_data',v_attempt.resolution_data,
    'replayed',false);
end;
$function$;

CREATE OR REPLACE FUNCTION public.aplicar_dano_token_ataque_srd_v2(p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer, p_bonus_ataque integer, p_dano integer, p_weapon_id text, p_attack_type text, p_power_penalty integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
 v_user UUID:=auth.uid(); v_campaign public.campaigns%ROWTYPE; v_combat JSONB; v_order JSONB; v_actor JSONB; v_scene JSONB; v_tokens JSONB; v_target JSONB;
 v_target_count INTEGER; v_target_index BIGINT; v_ca_text TEXT; v_ca INTEGER; v_max_hp INTEGER; v_hp INTEGER; v_new_hp INTEGER; v_attack_total INTEGER; v_round INTEGER;
 v_sheet public.srd_character_sheets%ROWTYPE; v_weapon public.srd_equipment%ROWTYPE; v_bab_progression TEXT; v_race_size TEXT;
 v_level INTEGER; v_bab INTEGER; v_str_score INTEGER; v_dex_score INTEGER; v_ability_mod INTEGER; v_ability_key TEXT;
 v_size_modifier INTEGER:=0; v_weapon_focus INTEGER:=0; v_power_penalty INTEGER:=0; v_range_penalty INTEGER:=0; v_expected_bonus INTEGER; v_racial_attack_bonus INTEGER:=0; v_target_traits TEXT;
 v_has_finesse BOOLEAN:=FALSE; v_has_power_attack BOOLEAN:=FALSE; v_weapon_name TEXT;
 v_effective_attack_modifier INTEGER:=0; v_effective_ac_modifier INTEGER:=0; v_damage_final INTEGER:=0; v_damage_type TEXT;
 v_attacker_count INTEGER; v_attacker_index BIGINT; v_attacker JSONB;
 v_attacker_size INTEGER:=1; v_target_size INTEGER:=1; v_reach_squares INTEGER:=1;
 v_ax INTEGER; v_ay INTEGER; v_bx INTEGER; v_by INTEGER; v_dx INTEGER; v_dy INTEGER; v_distance_squares INTEGER;
 v_range_increment_m NUMERIC; v_range_increments INTEGER; v_max_range_increments INTEGER:=10;
 v_class_weapon_proficiencies JSONB; v_weapon_proficiency_type TEXT; v_weapon_proficiency_penalty INTEGER:=0; v_weapon_focus_name TEXT;
 v_class_has_simple BOOLEAN:=FALSE; v_class_has_simple_martial BOOLEAN:=FALSE; v_class_has_exact_weapon BOOLEAN:=FALSE;
 v_has_simple_feat BOOLEAN:=FALSE; v_has_martial_feat BOOLEAN:=FALSE; v_has_exotic_feat BOOLEAN:=FALSE; v_is_dwarf_familiar_weapon BOOLEAN:=FALSE; v_is_proficient BOOLEAN:=FALSE;
BEGIN
 IF v_user IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
 IF p_d20 IS NULL OR p_d20<1 OR p_d20>20 THEN RAISE EXCEPTION 'Resultado de ataque inválido.'; END IF;
 IF p_bonus_ataque IS NULL OR p_bonus_ataque < -30 OR p_bonus_ataque > 60 THEN RAISE EXCEPTION 'Bônus de ataque inválido.'; END IF;
 IF p_dano IS NULL OR p_dano<1 OR p_dano>1000 THEN RAISE EXCEPTION 'Dano inválido.'; END IF;
 SELECT c.* INTO v_campaign FROM public.campaigns c WHERE c.id=p_campaign_id FOR UPDATE;
 IF NOT FOUND OR UPPER(COALESCE(v_campaign.state,''))<>'COMBATE' THEN RAISE EXCEPTION 'A campanha não está em combate.'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.characters ch JOIN public.members m ON m.campaign_id=ch.campaign_id AND m.user_id=ch.user_id AND m.role='PLAYER' WHERE ch.id::TEXT=BTRIM(p_character_id) AND ch.campaign_id=p_campaign_id AND ch.user_id=v_user) THEN RAISE EXCEPTION 'A ficha atacante não pertence ao jogador nesta campanha.'; END IF;
 v_combat:=COALESCE(v_campaign.combat_data,'{}'::JSONB);
 IF COALESCE(v_combat->>'active','false')<>'true' THEN RAISE EXCEPTION 'A iniciativa não está ativa.'; END IF;
 v_order:=CASE WHEN jsonb_typeof(v_combat->'turn_order')='array' THEN v_combat->'turn_order' ELSE '[]'::JSONB END;
 IF COALESCE(v_combat->>'current_turn','') !~ '^[0-9]+$' THEN RAISE EXCEPTION 'O turno atual é inválido.'; END IF;
 v_actor:=v_order->(v_combat->>'current_turn')::INTEGER;
 IF v_actor->>'id' IS DISTINCT FROM BTRIM(p_character_id) OR COALESCE(v_actor->>'is_monster','false')='true' THEN RAISE EXCEPTION 'Apenas o personagem ativo pode concluir este ataque.'; END IF;
 v_round:=CASE WHEN COALESCE(v_combat->>'round','') ~ '^[0-9]+$' THEN GREATEST(1,(v_combat->>'round')::INTEGER) ELSE 1 END;
 IF COALESCE(v_combat->'action_economy'->>'round','')<>v_round::TEXT OR COALESCE(v_combat->'action_economy'->'by_character'->BTRIM(p_character_id)->>'padrao','false')<>'true' THEN RAISE EXCEPTION 'A ação padrão do atacante ainda não foi consumida neste turno.'; END IF;
 v_scene:=COALESCE(v_campaign.cba_data,'{}'::JSONB); v_tokens:=CASE WHEN jsonb_typeof(v_scene->'tokens')='array' THEN v_scene->'tokens' ELSE '[]'::JSONB END;
 SELECT count(*)::INTEGER,min(t.ordinality),min(coalesce(t.token->>'ac',t.token->'monsterStats'->>'ca')) INTO v_target_count,v_target_index,v_ca_text FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(token,ordinality) WHERE t.token->>'id'=BTRIM(p_token_id) AND t.token->>'tipo' IN ('npc','monstro');
 IF v_target_count<>1 THEN RAISE EXCEPTION 'O alvo NPC/monstro não foi encontrado ou está duplicado.'; END IF;
 v_target:=v_tokens->(v_target_index::INTEGER-1);
 IF p_attack_type IS NULL OR p_attack_type NOT IN ('atk-corpo','atk-dist') THEN RAISE EXCEPTION 'Tipo de ataque inválido.'; END IF;
 v_power_penalty:=COALESCE(p_power_penalty,0);
 IF v_power_penalty<0 THEN RAISE EXCEPTION 'Penalidade de Ataque Poderoso inválida.'; END IF;
 SELECT sh.* INTO v_sheet
 FROM public.characters ch JOIN public.srd_character_sheets sh ON sh.character_id=ch.id
 WHERE ch.id::TEXT=BTRIM(p_character_id) AND ch.campaign_id=p_campaign_id AND ch.user_id=v_user;
 IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD 3.5 do atacante não encontrada.'; END IF;
 SELECT cl.bab_progression,r.tamanho,cl.dados_tecnicos->'proficiencias'->'armas' INTO v_bab_progression,v_race_size,v_class_weapon_proficiencies
 FROM public.srd_classes cl CROSS JOIN public.srd_races r
 WHERE cl.id=v_sheet.classe_id AND r.id=v_sheet.raca_id;
 IF NOT FOUND THEN RAISE EXCEPTION 'Classe ou raça da ficha não encontrada.'; END IF;
 v_level:=GREATEST(1,COALESCE(v_sheet.nivel,1));
 v_bab:=CASE lower(COALESCE(v_bab_progression,''))
   WHEN 'good' THEN v_level WHEN 'bom' THEN v_level
   WHEN 'average' THEN FLOOR(3*v_level/4)::INTEGER WHEN 'medium' THEN FLOOR(3*v_level/4)::INTEGER WHEN 'medio' THEN FLOOR(3*v_level/4)::INTEGER
   WHEN 'poor' THEN FLOOR(v_level/2)::INTEGER WHEN 'ruim' THEN FLOOR(v_level/2)::INTEGER ELSE 0 END;
 v_str_score:=CASE WHEN COALESCE(v_sheet.atributos->>'FOR','') ~ '^[0-9]+$' THEN (v_sheet.atributos->>'FOR')::INTEGER ELSE 10 END;
 v_dex_score:=CASE WHEN COALESCE(v_sheet.atributos->>'DES','') ~ '^[0-9]+$' THEN (v_sheet.atributos->>'DES')::INTEGER ELSE 10 END;
 v_has_finesse:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_weapon_finesse');
 v_has_power_attack:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='ataque_poderoso');
 IF NULLIF(BTRIM(p_weapon_id),'') IS NOT NULL THEN
   SELECT eq.* INTO v_weapon FROM public.srd_character_equipment ce JOIN public.srd_equipment eq ON eq.id=ce.equipment_id
   WHERE ce.character_id=v_sheet.character_id AND ce.equipment_id=BTRIM(p_weapon_id) AND ce.equipado IS TRUE AND public.srd35_equipment_slot(eq.categoria,eq.nome)='arma' AND EXISTS (SELECT 1 FROM public.srd_character_weapon_instances wi WHERE wi.character_id=ce.character_id AND wi.equipment_id=ce.equipment_id AND wi.equipado IS TRUE AND wi.hand_slot='main_hand');
   IF NOT FOUND THEN RAISE EXCEPTION 'A arma informada não está equipada nesta ficha.'; END IF;
 END IF;
 v_weapon_name:=COALESCE(v_weapon.detalhes->>'weapon_proficiency_name',v_weapon.nome,'Ataque desarmado'); v_weapon_focus_name:=COALESCE(v_weapon.detalhes->>'weapon_focus_name',v_weapon.nome,'Ataque desarmado');
 
v_weapon_proficiency_type:=COALESCE(
  NULLIF(v_weapon.detalhes->>'weapon_proficiency',''),
  CASE
    WHEN lower(concat_ws(' ',v_weapon.detalhes->>'weapon_group',v_weapon.categoria)) LIKE '%exotic%' THEN 'exotic'
    WHEN lower(concat_ws(' ',v_weapon.detalhes->>'weapon_group',v_weapon.categoria)) LIKE '%martial%' THEN 'martial'
    WHEN lower(concat_ws(' ',v_weapon.detalhes->>'weapon_group',v_weapon.categoria)) LIKE '%simple%' THEN 'simple'
    ELSE ''
  END
);
v_is_dwarf_familiar_weapon:=v_sheet.raca_id='anao'
  AND regexp_replace(lower(translate(v_weapon_name,'ã','a')),'[^a-z0-9]+','','g')
    IN ('waraxedwarven','dwarvenwaraxe','urgroshdwarven','dwarvenurgrosh','machadodeguerraanao','urgroshanao');

 IF v_weapon.id IS NOT NULL THEN
   v_class_has_simple:=EXISTS(
     SELECT 1 FROM jsonb_array_elements_text(CASE WHEN jsonb_typeof(v_class_weapon_proficiencies)='array' THEN v_class_weapon_proficiencies ELSE '[]'::JSONB END) p(value)
     WHERE lower(BTRIM(p.value))='armas simples'
   );
   v_class_has_simple_martial:=EXISTS(
     SELECT 1 FROM jsonb_array_elements_text(CASE WHEN jsonb_typeof(v_class_weapon_proficiencies)='array' THEN v_class_weapon_proficiencies ELSE '[]'::JSONB END) p(value)
     WHERE lower(BTRIM(p.value))='todas as armas simples e marciais'
   );
   v_class_has_exact_weapon:=EXISTS(
     SELECT 1 FROM jsonb_array_elements_text(CASE WHEN jsonb_typeof(v_class_weapon_proficiencies)='array' THEN v_class_weapon_proficiencies ELSE '[]'::JSONB END) p(value)
     WHERE public.srd35_normalizar_parametro_talento(p.value)=public.srd35_normalizar_parametro_talento(v_weapon_name)
   );
   v_has_simple_feat:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_simple_weapon_proficiency');
   v_has_martial_feat:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_martial_weapon_proficiency' AND public.srd35_normalizar_parametro_talento(COALESCE(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name));
   v_has_exotic_feat:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_exotic_weapon_proficiency' AND public.srd35_normalizar_parametro_talento(COALESCE(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name));
   v_is_proficient:=CASE
     WHEN v_weapon_proficiency_type='simple' THEN v_class_has_exact_weapon OR v_class_has_simple OR v_class_has_simple_martial OR v_has_simple_feat
     WHEN v_weapon_proficiency_type='martial' THEN v_class_has_exact_weapon OR v_class_has_simple_martial OR v_has_martial_feat
     WHEN v_weapon_proficiency_type='exotic' THEN
       v_class_has_exact_weapon OR v_has_exotic_feat
       OR (v_is_dwarf_familiar_weapon AND (v_class_has_simple_martial OR v_has_martial_feat))
     ELSE FALSE END;
   v_weapon_proficiency_penalty:=CASE WHEN v_is_proficient THEN 0 ELSE 4 END;
 END IF;
 IF p_attack_type='atk-dist' THEN
   IF v_weapon.id IS NULL OR COALESCE(v_weapon.detalhes->>'weapon_ranged','false')<>'true' THEN RAISE EXCEPTION 'A arma equipada não permite ataque à distância.'; END IF;
   v_ability_key:='DES';
 ELSE
   IF v_weapon.id IS NOT NULL AND COALESCE(v_weapon.detalhes->>'weapon_melee','true')='false' THEN RAISE EXCEPTION 'A arma equipada não permite ataque corpo a corpo.'; END IF;
   IF v_has_finesse AND v_bab<1 THEN RAISE EXCEPTION 'Acuidade com Arma exige bônus base de ataque +1.'; END IF;
 IF v_has_finesse AND (v_weapon.id IS NULL OR COALESCE(v_weapon.detalhes->>'weapon_finesse_eligible','false')='true') THEN v_ability_key:='DES'; ELSE v_ability_key:='FOR'; END IF;
 END IF;
 v_ability_mod:=FLOOR(((CASE WHEN v_ability_key='DES' THEN v_dex_score ELSE v_str_score END)-10)::NUMERIC/2)::INTEGER;
 v_size_modifier:=CASE WHEN lower(COALESCE(v_race_size,'')) IN ('pequeno','small') THEN 1 ELSE 0 END;
 SELECT (CASE WHEN EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='foco_em_arma' AND public.srd35_normalizar_parametro_talento(COALESCE(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_focus_name)) THEN 1 ELSE 0 END)+(CASE WHEN EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_greater_weapon_focus' AND public.srd35_normalizar_parametro_talento(COALESCE(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_focus_name)) THEN 1 ELSE 0 END) INTO v_weapon_focus;
 IF v_power_penalty>0 AND (p_attack_type<>'atk-corpo' OR (v_weapon.id IS NOT NULL AND COALESCE(v_weapon.detalhes->>'weapon_light','false')='true') OR NOT v_has_power_attack OR v_power_penalty>v_bab) THEN RAISE EXCEPTION 'Ataque Poderoso inválido para esta ficha ou ataque.'; END IF;
 SELECT count(*)::INTEGER,min(t.ordinality) INTO v_attacker_count,v_attacker_index
 FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(token,ordinality)
 WHERE t.token->>'id'=BTRIM(p_character_id) AND t.token->>'tipo'='player';
 IF v_attacker_count<>1 THEN RAISE EXCEPTION 'O token do personagem atacante não foi encontrado ou está duplicado.'; END IF;
 v_attacker:=v_tokens->(v_attacker_index::INTEGER-1);
 v_attacker_size:=CASE
   WHEN lower(COALESCE(v_race_size,'')) LIKE 'large%' OR lower(COALESCE(v_race_size,'')) LIKE 'grande%' THEN 2
   WHEN lower(COALESCE(v_race_size,'')) LIKE 'huge%' OR lower(COALESCE(v_race_size,'')) LIKE 'enorme%' THEN 3
   WHEN lower(COALESCE(v_race_size,'')) LIKE 'gargantuan%' OR lower(COALESCE(v_race_size,'')) LIKE 'imenso%' THEN 4
   WHEN lower(COALESCE(v_race_size,'')) LIKE 'colossal%' THEN 5 ELSE 1 END;
 v_target_size:=CASE
   WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'large%' OR lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'grande%' THEN 2
   WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'huge%' OR lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'enorme%' THEN 3
   WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'gargantuan%' OR lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'imenso%' THEN 4
   WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'colossal%' THEN 5 ELSE 1 END;
 IF COALESCE(v_attacker->>'gridX','') !~ '^-?[0-9]+$' OR COALESCE(v_attacker->>'gridY','') !~ '^-?[0-9]+$' OR COALESCE(v_target->>'gridX','') !~ '^-?[0-9]+$' OR COALESCE(v_target->>'gridY','') !~ '^-?[0-9]+$' THEN RAISE EXCEPTION 'Posição de token inválida para calcular alcance.'; END IF;
 v_ax:=(v_attacker->>'gridX')::INTEGER; v_ay:=(v_attacker->>'gridY')::INTEGER; v_bx:=(v_target->>'gridX')::INTEGER; v_by:=(v_target->>'gridY')::INTEGER;
 v_dx:=GREATEST(0,v_bx-(v_ax+v_attacker_size-1),v_ax-(v_bx+v_target_size-1));
 v_dy:=GREATEST(0,v_by-(v_ay+v_attacker_size-1),v_ay-(v_by+v_target_size-1));
 v_distance_squares:=GREATEST(v_dx,v_dy)+FLOOR(LEAST(v_dx,v_dy)::NUMERIC/2)::INTEGER;
 IF p_attack_type='atk-corpo' THEN
   v_reach_squares:=GREATEST(1,v_attacker_size);
   IF v_distance_squares>v_reach_squares THEN RAISE EXCEPTION 'Alvo fora do alcance corpo a corpo.'; END IF;
 ELSE
   v_range_increment_m:=NULLIF(v_weapon.detalhes->>'range_increment_m','')::NUMERIC;
   IF v_range_increment_m IS NULL OR v_range_increment_m<=0 THEN RAISE EXCEPTION 'Incremento de distância da arma não cadastrado.'; END IF;
   v_range_increments:=GREATEST(1,CEIL((v_distance_squares*1.5)/v_range_increment_m)::INTEGER);
   v_max_range_increments:=COALESCE(NULLIF(v_weapon.detalhes->>'max_range_increments','')::INTEGER,10); IF v_range_increments>v_max_range_increments THEN RAISE EXCEPTION 'Alvo fora do alcance máximo de % incrementos da arma.',v_max_range_increments; END IF;
   v_range_penalty:=(v_range_increments-1)*2;
 END IF;
 
v_target_traits:=lower(concat_ws(' ',
  v_target->>'nome',v_target->>'detalhe',
  v_target->'monsterStats'->>'tipo',v_target->'monsterStats'->>'subtipo',
  v_target->'monsterStats'->>'subtype',v_target->'monsterStats'->>'subtypes',
  v_target->'monsterStats'->>'type',v_target->'monsterStats'->>'creature_type',
  v_target->'monsterStats'->>'race_id',v_target->>'creature_type'
));
IF v_sheet.raca_id='anao'
   AND v_target_traits ~ '(^|[^a-z])orc|goblin|hobgoblin|bugbear|goblinoid([^a-z]|$)' THEN
  v_racial_attack_bonus:=1;
ELSIF v_sheet.raca_id='gnomo'
   AND v_target_traits ~ '(^|[^a-z])kobold|goblin|hobgoblin|bugbear|goblinoid([^a-z]|$)' THEN
  v_racial_attack_bonus:=1;
ELSIF v_sheet.raca_id='halfling'
   AND p_attack_type='atk-dist'
   AND (
     COALESCE(v_weapon.detalhes->>'weapon_ranged_type','')='thrown'
     OR lower(COALESCE(v_weapon.nome,''))='funda'
   ) THEN
  v_racial_attack_bonus:=1;
END IF;
v_expected_bonus:=v_bab+v_ability_mod+v_size_modifier+v_weapon_focus-v_power_penalty-v_range_penalty-v_weapon_proficiency_penalty+v_racial_attack_bonus;

 IF p_bonus_ataque<>v_expected_bonus THEN RAISE EXCEPTION 'Bônus de ataque não confere com a ficha. Esperado: %, recebido: %.',v_expected_bonus,p_bonus_ataque; END IF;
 IF priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_character_id),'no_actions') OR priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_character_id),'cannot_attack') THEN RAISE EXCEPTION 'A condição atual impede ataques.'; END IF;
 v_effective_attack_modifier:=priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'attack')+CASE WHEN p_attack_type='atk-corpo' THEN priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'attack_melee')+FLOOR((v_str_score+priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'strength')-10)::numeric/2)::integer-FLOOR((v_str_score-10)::numeric/2)::integer ELSE priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'attack_ranged')+FLOOR((v_dex_score+priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'dexterity')-10)::numeric/2)::integer-FLOOR((v_dex_score-10)::numeric/2)::integer END;
 IF COALESCE(v_ca_text,'') !~ '[0-9]{1,3}' THEN RAISE EXCEPTION 'O token alvo precisa ter uma CA numérica.'; END IF;
 v_effective_ac_modifier:=priv.srd_effective_modifier(p_campaign_id,'token',BTRIM(p_token_id),'ac')+CASE WHEN p_attack_type='atk-corpo' THEN priv.srd_effective_modifier(p_campaign_id,'token',BTRIM(p_token_id),'ac_melee') ELSE priv.srd_effective_modifier(p_campaign_id,'token',BTRIM(p_token_id),'ac_ranged') END;
 v_ca:=substring(v_ca_text from '[0-9]{1,3}')::INTEGER+v_effective_ac_modifier; v_attack_total:=p_d20+p_bonus_ataque+v_effective_attack_modifier;
 IF p_d20=1 OR (p_d20<>20 AND v_attack_total<v_ca) THEN RAISE EXCEPTION 'Ataque não atingiu a CA do alvo (%). Nenhum dano foi aplicado.',v_ca; END IF;
 v_target:=v_tokens->(v_target_index::INTEGER-1);
 IF COALESCE(v_target->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN RAISE EXCEPTION 'O alvo não possui PV máximo configurado.'; END IF;
 v_max_hp:=(v_target->>'maxHp')::INTEGER; v_hp:=CASE WHEN COALESCE(v_target->>'hp','') ~ '^-?[0-9]{1,6}$' THEN (v_target->>'hp')::INTEGER ELSE v_max_hp END;
 v_damage_type:=CASE lower(COALESCE(v_weapon.tipo_dano,'bludgeoning')) WHEN 'cortante' THEN 'slashing' WHEN 'perfurante' THEN 'piercing' WHEN 'impacto' THEN 'bludgeoning' WHEN 'cortante/perfurante' THEN 'physical' WHEN 'impacto/perfurante' THEN 'physical' ELSE lower(COALESCE(v_weapon.tipo_dano,'bludgeoning')) END;
 v_damage_final:=priv.srd_adjust_damage(p_campaign_id,'token',BTRIM(p_token_id),v_damage_type,GREATEST(0,p_dano+priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'damage')));
 v_new_hp:=GREATEST(-10,LEAST(v_max_hp,v_hp-v_damage_final)); v_target:=v_target||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp);
 v_scene:=v_scene||jsonb_build_object('tokens',jsonb_set(v_tokens,ARRAY[(v_target_index-1)::TEXT],v_target,FALSE)); UPDATE public.campaigns SET cba_data=v_scene WHERE id=p_campaign_id;
  PERFORM priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,v_new_hp,v_max_hp);
 RETURN jsonb_build_object('cba_data',v_scene,'hp',v_new_hp,'max_hp',v_max_hp,'ca',v_ca,'attack_total',v_attack_total,'damage',v_damage_final,'damage_roll',p_dano,'attack_effect_modifier',v_effective_attack_modifier,'target_ac_modifier',v_effective_ac_modifier);
END; $function$;

CREATE OR REPLACE FUNCTION public.aplicar_dano_token_ataque_srd_v2(p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer, p_bonus_ataque integer, p_dano integer, p_weapon_id text, p_attack_type text, p_power_penalty integer, p_sneak_attack_dice integer, p_sneak_attack_damage integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
 v_user UUID:=auth.uid(); v_campaign public.campaigns%ROWTYPE; v_combat JSONB; v_order JSONB; v_actor JSONB; v_scene JSONB; v_tokens JSONB; v_target JSONB;
 v_target_count INTEGER; v_target_index BIGINT; v_ca_text TEXT; v_ca INTEGER; v_max_hp INTEGER; v_hp INTEGER; v_new_hp INTEGER; v_attack_total INTEGER; v_round INTEGER;
 v_sheet public.srd_character_sheets%ROWTYPE; v_weapon public.srd_equipment%ROWTYPE; v_bab_progression TEXT; v_race_size TEXT;
 v_level INTEGER; v_bab INTEGER; v_str_score INTEGER; v_dex_score INTEGER; v_ability_mod INTEGER; v_ability_key TEXT;
 v_size_modifier INTEGER:=0; v_weapon_focus INTEGER:=0; v_power_penalty INTEGER:=0; v_range_penalty INTEGER:=0; v_expected_bonus INTEGER; v_racial_attack_bonus INTEGER:=0; v_target_traits TEXT;
 v_has_finesse BOOLEAN:=FALSE; v_has_power_attack BOOLEAN:=FALSE; v_weapon_name TEXT;
 v_effective_attack_modifier INTEGER:=0; v_effective_ac_modifier INTEGER:=0; v_damage_final INTEGER:=0; v_damage_type TEXT;
 v_attacker_count INTEGER; v_attacker_index BIGINT; v_attacker JSONB;
 v_attacker_size INTEGER:=1; v_target_size INTEGER:=1; v_reach_squares INTEGER:=1;
 v_ax INTEGER; v_ay INTEGER; v_bx INTEGER; v_by INTEGER; v_dx INTEGER; v_dy INTEGER; v_distance_squares INTEGER;
 v_range_increment_m NUMERIC; v_range_increments INTEGER; v_max_range_increments INTEGER:=10;
 v_class_weapon_proficiencies JSONB; v_weapon_proficiency_type TEXT; v_weapon_proficiency_penalty INTEGER:=0; v_weapon_focus_name TEXT;
 v_class_has_simple BOOLEAN:=FALSE; v_class_has_simple_martial BOOLEAN:=FALSE; v_class_has_exact_weapon BOOLEAN:=FALSE;
 v_has_simple_feat BOOLEAN:=FALSE; v_has_martial_feat BOOLEAN:=FALSE; v_has_exotic_feat BOOLEAN:=FALSE; v_is_dwarf_familiar_weapon BOOLEAN:=FALSE; v_is_proficient BOOLEAN:=FALSE; v_rogue_level INTEGER:=0; v_expected_sneak_dice INTEGER:=0; v_target_type TEXT;
BEGIN
 IF v_user IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
 IF p_d20 IS NULL OR p_d20<1 OR p_d20>20 THEN RAISE EXCEPTION 'Resultado de ataque inválido.'; END IF;
 IF p_bonus_ataque IS NULL OR p_bonus_ataque < -30 OR p_bonus_ataque > 60 THEN RAISE EXCEPTION 'Bônus de ataque inválido.'; END IF;
 IF p_dano IS NULL OR p_dano<1 OR p_dano>1000 THEN RAISE EXCEPTION 'Dano inválido.'; END IF;
 SELECT c.* INTO v_campaign FROM public.campaigns c WHERE c.id=p_campaign_id FOR UPDATE;
 IF NOT FOUND OR UPPER(COALESCE(v_campaign.state,''))<>'COMBATE' THEN RAISE EXCEPTION 'A campanha não está em combate.'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.characters ch JOIN public.members m ON m.campaign_id=ch.campaign_id AND m.user_id=ch.user_id AND m.role='PLAYER' WHERE ch.id::TEXT=BTRIM(p_character_id) AND ch.campaign_id=p_campaign_id AND ch.user_id=v_user) THEN RAISE EXCEPTION 'A ficha atacante não pertence ao jogador nesta campanha.'; END IF;
 v_combat:=COALESCE(v_campaign.combat_data,'{}'::JSONB);
 IF COALESCE(v_combat->>'active','false')<>'true' THEN RAISE EXCEPTION 'A iniciativa não está ativa.'; END IF;
 v_order:=CASE WHEN jsonb_typeof(v_combat->'turn_order')='array' THEN v_combat->'turn_order' ELSE '[]'::JSONB END;
 IF COALESCE(v_combat->>'current_turn','') !~ '^[0-9]+$' THEN RAISE EXCEPTION 'O turno atual é inválido.'; END IF;
 v_actor:=v_order->(v_combat->>'current_turn')::INTEGER;
 IF v_actor->>'id' IS DISTINCT FROM BTRIM(p_character_id) OR COALESCE(v_actor->>'is_monster','false')='true' THEN RAISE EXCEPTION 'Apenas o personagem ativo pode concluir este ataque.'; END IF;
 v_round:=CASE WHEN COALESCE(v_combat->>'round','') ~ '^[0-9]+$' THEN GREATEST(1,(v_combat->>'round')::INTEGER) ELSE 1 END;
 IF COALESCE(v_combat->'action_economy'->>'round','')<>v_round::TEXT OR COALESCE(v_combat->'action_economy'->'by_character'->BTRIM(p_character_id)->>'padrao','false')<>'true' THEN RAISE EXCEPTION 'A ação padrão do atacante ainda não foi consumida neste turno.'; END IF;
 v_scene:=COALESCE(v_campaign.cba_data,'{}'::JSONB); v_tokens:=CASE WHEN jsonb_typeof(v_scene->'tokens')='array' THEN v_scene->'tokens' ELSE '[]'::JSONB END;
 SELECT count(*)::INTEGER,min(t.ordinality),min(coalesce(t.token->>'ac',t.token->'monsterStats'->>'ca')) INTO v_target_count,v_target_index,v_ca_text FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(token,ordinality) WHERE t.token->>'id'=BTRIM(p_token_id) AND t.token->>'tipo' IN ('npc','monstro');
 IF v_target_count<>1 THEN RAISE EXCEPTION 'O alvo NPC/monstro não foi encontrado ou está duplicado.'; END IF;
 v_target:=v_tokens->(v_target_index::INTEGER-1);
 IF p_attack_type IS NULL OR p_attack_type NOT IN ('atk-corpo','atk-dist') THEN RAISE EXCEPTION 'Tipo de ataque inválido.'; END IF;
 v_power_penalty:=COALESCE(p_power_penalty,0);
 IF v_power_penalty<0 THEN RAISE EXCEPTION 'Penalidade de Ataque Poderoso inválida.'; END IF;
 SELECT sh.* INTO v_sheet
 FROM public.characters ch JOIN public.srd_character_sheets sh ON sh.character_id=ch.id
 WHERE ch.id::TEXT=BTRIM(p_character_id) AND ch.campaign_id=p_campaign_id AND ch.user_id=v_user;
 IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD 3.5 do atacante não encontrada.'; END IF;
 SELECT COALESCE(
   MAX(cl.class_level) FILTER (WHERE cls.class_key='rogue'),
   CASE WHEN NOT EXISTS (SELECT 1 FROM public.srd_character_class_levels any_level WHERE any_level.character_id=v_sheet.character_id)
          AND v_sheet.classe_id='ladino' THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
 ) INTO v_rogue_level
 FROM public.srd_character_sheets sh
 LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
 LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
 WHERE sh.character_id=v_sheet.character_id
 GROUP BY sh.character_id,sh.classe_id,sh.nivel;
 v_expected_sneak_dice:=LEAST(10,FLOOR((COALESCE(v_rogue_level,0)+1)/2.0)::INTEGER);
 v_target_type:=lower(COALESCE(v_target->'monsterStats'->>'creature_type',v_target->'monsterStats'->>'type',v_target->>'creature_type',''));
 IF COALESCE(p_sneak_attack_dice,0)<0 OR COALESCE(p_sneak_attack_damage,0)<0 THEN RAISE EXCEPTION 'Dados de Ataque Furtivo inválidos.'; END IF;
 IF COALESCE(p_sneak_attack_dice,0)>0 THEN
   IF p_sneak_attack_dice<>v_expected_sneak_dice OR p_sneak_attack_damage<p_sneak_attack_dice OR p_sneak_attack_damage>p_sneak_attack_dice*6 THEN
     RAISE EXCEPTION 'Rolagem de Ataque Furtivo não corresponde ao nível do Ladino.';
   END IF;
   IF NOT (priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'loses_dex_ac')
        OR priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'loses_dex_ac_vs_non_grapplers')) THEN
     RAISE EXCEPTION 'Ataque Furtivo exige que o alvo perca seu bônus de Destreza na CA; flanqueamento ainda não foi validado pelo motor.';
   END IF;
   IF v_target_type IN ('undead','construct','ooze','plant','elemental','incorporeal') THEN
     RAISE EXCEPTION 'Este tipo de criatura é imune a Ataque Furtivo.';
   END IF;

 ELSE
   IF COALESCE(p_sneak_attack_damage,0)<>0 THEN RAISE EXCEPTION 'Dano de Ataque Furtivo sem dados declarados.';
   END IF;
 END IF;
 SELECT cl.bab_progression,r.tamanho,cl.dados_tecnicos->'proficiencias'->'armas' INTO v_bab_progression,v_race_size,v_class_weapon_proficiencies
 FROM public.srd_classes cl CROSS JOIN public.srd_races r
 WHERE cl.id=v_sheet.classe_id AND r.id=v_sheet.raca_id;
 IF NOT FOUND THEN RAISE EXCEPTION 'Classe ou raça da ficha não encontrada.'; END IF;
 v_level:=GREATEST(1,COALESCE(v_sheet.nivel,1));
 v_bab:=CASE lower(COALESCE(v_bab_progression,''))
   WHEN 'good' THEN v_level WHEN 'bom' THEN v_level
   WHEN 'average' THEN FLOOR(3*v_level/4)::INTEGER WHEN 'medium' THEN FLOOR(3*v_level/4)::INTEGER WHEN 'medio' THEN FLOOR(3*v_level/4)::INTEGER
   WHEN 'poor' THEN FLOOR(v_level/2)::INTEGER WHEN 'ruim' THEN FLOOR(v_level/2)::INTEGER ELSE 0 END;
 v_str_score:=CASE WHEN COALESCE(v_sheet.atributos->>'FOR','') ~ '^[0-9]+$' THEN (v_sheet.atributos->>'FOR')::INTEGER ELSE 10 END;
 v_dex_score:=CASE WHEN COALESCE(v_sheet.atributos->>'DES','') ~ '^[0-9]+$' THEN (v_sheet.atributos->>'DES')::INTEGER ELSE 10 END;
 v_has_finesse:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_weapon_finesse');
 v_has_power_attack:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='ataque_poderoso');
 IF NULLIF(BTRIM(p_weapon_id),'') IS NOT NULL THEN
   SELECT eq.* INTO v_weapon FROM public.srd_character_equipment ce JOIN public.srd_equipment eq ON eq.id=ce.equipment_id
   WHERE ce.character_id=v_sheet.character_id AND ce.equipment_id=BTRIM(p_weapon_id) AND ce.equipado IS TRUE AND public.srd35_equipment_slot(eq.categoria,eq.nome)='arma' AND EXISTS (SELECT 1 FROM public.srd_character_weapon_instances wi WHERE wi.character_id=ce.character_id AND wi.equipment_id=ce.equipment_id AND wi.equipado IS TRUE AND wi.hand_slot='main_hand');
   IF NOT FOUND THEN RAISE EXCEPTION 'A arma informada não está equipada nesta ficha.'; END IF;
 END IF;
 v_weapon_name:=COALESCE(v_weapon.detalhes->>'weapon_proficiency_name',v_weapon.nome,'Ataque desarmado'); v_weapon_focus_name:=COALESCE(v_weapon.detalhes->>'weapon_focus_name',v_weapon.nome,'Ataque desarmado');
 
v_weapon_proficiency_type:=COALESCE(
  NULLIF(v_weapon.detalhes->>'weapon_proficiency',''),
  CASE
    WHEN lower(concat_ws(' ',v_weapon.detalhes->>'weapon_group',v_weapon.categoria)) LIKE '%exotic%' THEN 'exotic'
    WHEN lower(concat_ws(' ',v_weapon.detalhes->>'weapon_group',v_weapon.categoria)) LIKE '%martial%' THEN 'martial'
    WHEN lower(concat_ws(' ',v_weapon.detalhes->>'weapon_group',v_weapon.categoria)) LIKE '%simple%' THEN 'simple'
    ELSE ''
  END
);
v_is_dwarf_familiar_weapon:=v_sheet.raca_id='anao'
  AND regexp_replace(lower(translate(v_weapon_name,'ã','a')),'[^a-z0-9]+','','g')
    IN ('waraxedwarven','dwarvenwaraxe','urgroshdwarven','dwarvenurgrosh','machadodeguerraanao','urgroshanao');

 IF v_weapon.id IS NOT NULL THEN
   v_class_has_simple:=EXISTS(
     SELECT 1 FROM jsonb_array_elements_text(CASE WHEN jsonb_typeof(v_class_weapon_proficiencies)='array' THEN v_class_weapon_proficiencies ELSE '[]'::JSONB END) p(value)
     WHERE lower(BTRIM(p.value))='armas simples'
   );
   v_class_has_simple_martial:=EXISTS(
     SELECT 1 FROM jsonb_array_elements_text(CASE WHEN jsonb_typeof(v_class_weapon_proficiencies)='array' THEN v_class_weapon_proficiencies ELSE '[]'::JSONB END) p(value)
     WHERE lower(BTRIM(p.value))='todas as armas simples e marciais'
   );
   v_class_has_exact_weapon:=EXISTS(
     SELECT 1 FROM jsonb_array_elements_text(CASE WHEN jsonb_typeof(v_class_weapon_proficiencies)='array' THEN v_class_weapon_proficiencies ELSE '[]'::JSONB END) p(value)
     WHERE public.srd35_normalizar_parametro_talento(p.value)=public.srd35_normalizar_parametro_talento(v_weapon_name)
   );
   v_has_simple_feat:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_simple_weapon_proficiency');
   v_has_martial_feat:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_martial_weapon_proficiency' AND public.srd35_normalizar_parametro_talento(COALESCE(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name));
   v_has_exotic_feat:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_exotic_weapon_proficiency' AND public.srd35_normalizar_parametro_talento(COALESCE(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name));
   v_is_proficient:=CASE
     WHEN v_weapon_proficiency_type='simple' THEN v_class_has_exact_weapon OR v_class_has_simple OR v_class_has_simple_martial OR v_has_simple_feat
     WHEN v_weapon_proficiency_type='martial' THEN v_class_has_exact_weapon OR v_class_has_simple_martial OR v_has_martial_feat
     WHEN v_weapon_proficiency_type='exotic' THEN
       v_class_has_exact_weapon OR v_has_exotic_feat
       OR (v_is_dwarf_familiar_weapon AND (v_class_has_simple_martial OR v_has_martial_feat))
     ELSE FALSE END;
   v_weapon_proficiency_penalty:=CASE WHEN v_is_proficient THEN 0 ELSE 4 END;
 END IF;
 IF p_attack_type='atk-dist' THEN
   IF v_weapon.id IS NULL OR COALESCE(v_weapon.detalhes->>'weapon_ranged','false')<>'true' THEN RAISE EXCEPTION 'A arma equipada não permite ataque à distância.'; END IF;
   v_ability_key:='DES';
 ELSE
   IF v_weapon.id IS NOT NULL AND COALESCE(v_weapon.detalhes->>'weapon_melee','true')='false' THEN RAISE EXCEPTION 'A arma equipada não permite ataque corpo a corpo.'; END IF;
   IF v_has_finesse AND v_bab<1 THEN RAISE EXCEPTION 'Acuidade com Arma exige bônus base de ataque +1.'; END IF;
 IF v_has_finesse AND (v_weapon.id IS NULL OR COALESCE(v_weapon.detalhes->>'weapon_finesse_eligible','false')='true') THEN v_ability_key:='DES'; ELSE v_ability_key:='FOR'; END IF;
 END IF;
 v_ability_mod:=FLOOR(((CASE WHEN v_ability_key='DES' THEN v_dex_score ELSE v_str_score END)-10)::NUMERIC/2)::INTEGER;
 v_size_modifier:=CASE WHEN lower(COALESCE(v_race_size,'')) IN ('pequeno','small') THEN 1 ELSE 0 END;
 SELECT (CASE WHEN EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='foco_em_arma' AND public.srd35_normalizar_parametro_talento(COALESCE(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_focus_name)) THEN 1 ELSE 0 END)+(CASE WHEN EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_greater_weapon_focus' AND public.srd35_normalizar_parametro_talento(COALESCE(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_focus_name)) THEN 1 ELSE 0 END) INTO v_weapon_focus;
 IF v_power_penalty>0 AND (p_attack_type<>'atk-corpo' OR (v_weapon.id IS NOT NULL AND COALESCE(v_weapon.detalhes->>'weapon_light','false')='true') OR NOT v_has_power_attack OR v_power_penalty>v_bab) THEN RAISE EXCEPTION 'Ataque Poderoso inválido para esta ficha ou ataque.'; END IF;
 SELECT count(*)::INTEGER,min(t.ordinality) INTO v_attacker_count,v_attacker_index
 FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(token,ordinality)
 WHERE t.token->>'id'=BTRIM(p_character_id) AND t.token->>'tipo'='player';
 IF v_attacker_count<>1 THEN RAISE EXCEPTION 'O token do personagem atacante não foi encontrado ou está duplicado.'; END IF;
 v_attacker:=v_tokens->(v_attacker_index::INTEGER-1);
 v_attacker_size:=CASE
   WHEN lower(COALESCE(v_race_size,'')) LIKE 'large%' OR lower(COALESCE(v_race_size,'')) LIKE 'grande%' THEN 2
   WHEN lower(COALESCE(v_race_size,'')) LIKE 'huge%' OR lower(COALESCE(v_race_size,'')) LIKE 'enorme%' THEN 3
   WHEN lower(COALESCE(v_race_size,'')) LIKE 'gargantuan%' OR lower(COALESCE(v_race_size,'')) LIKE 'imenso%' THEN 4
   WHEN lower(COALESCE(v_race_size,'')) LIKE 'colossal%' THEN 5 ELSE 1 END;
 v_target_size:=CASE
   WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'large%' OR lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'grande%' THEN 2
   WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'huge%' OR lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'enorme%' THEN 3
   WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'gargantuan%' OR lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'imenso%' THEN 4
   WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'colossal%' THEN 5 ELSE 1 END;
 IF COALESCE(v_attacker->>'gridX','') !~ '^-?[0-9]+$' OR COALESCE(v_attacker->>'gridY','') !~ '^-?[0-9]+$' OR COALESCE(v_target->>'gridX','') !~ '^-?[0-9]+$' OR COALESCE(v_target->>'gridY','') !~ '^-?[0-9]+$' THEN RAISE EXCEPTION 'Posição de token inválida para calcular alcance.'; END IF;
 v_ax:=(v_attacker->>'gridX')::INTEGER; v_ay:=(v_attacker->>'gridY')::INTEGER; v_bx:=(v_target->>'gridX')::INTEGER; v_by:=(v_target->>'gridY')::INTEGER;
 v_dx:=GREATEST(0,v_bx-(v_ax+v_attacker_size-1),v_ax-(v_bx+v_target_size-1));
 v_dy:=GREATEST(0,v_by-(v_ay+v_attacker_size-1),v_ay-(v_by+v_target_size-1));
 v_distance_squares:=GREATEST(v_dx,v_dy)+FLOOR(LEAST(v_dx,v_dy)::NUMERIC/2)::INTEGER;
 IF p_attack_type='atk-dist' AND COALESCE(p_sneak_attack_dice,0)>0 AND v_distance_squares>6 THEN RAISE EXCEPTION 'Ataque Furtivo à distância exige até 9 metros.'; END IF;
 IF p_attack_type='atk-corpo' THEN
   v_reach_squares:=GREATEST(1,v_attacker_size);
   IF v_distance_squares>v_reach_squares THEN RAISE EXCEPTION 'Alvo fora do alcance corpo a corpo.'; END IF;
 ELSE
   v_range_increment_m:=NULLIF(v_weapon.detalhes->>'range_increment_m','')::NUMERIC;
   IF v_range_increment_m IS NULL OR v_range_increment_m<=0 THEN RAISE EXCEPTION 'Incremento de distância da arma não cadastrado.'; END IF;
   v_range_increments:=GREATEST(1,CEIL((v_distance_squares*1.5)/v_range_increment_m)::INTEGER);
   v_max_range_increments:=COALESCE(NULLIF(v_weapon.detalhes->>'max_range_increments','')::INTEGER,10); IF v_range_increments>v_max_range_increments THEN RAISE EXCEPTION 'Alvo fora do alcance máximo de % incrementos da arma.',v_max_range_increments; END IF;
   v_range_penalty:=(v_range_increments-1)*2;
 END IF;
 
v_target_traits:=lower(concat_ws(' ',
  v_target->>'nome',v_target->>'detalhe',
  v_target->'monsterStats'->>'tipo',v_target->'monsterStats'->>'subtipo',
  v_target->'monsterStats'->>'subtype',v_target->'monsterStats'->>'subtypes',
  v_target->'monsterStats'->>'type',v_target->'monsterStats'->>'creature_type',
  v_target->'monsterStats'->>'race_id',v_target->>'creature_type'
));
IF v_sheet.raca_id='anao'
   AND v_target_traits ~ '(^|[^a-z])orc|goblin|hobgoblin|bugbear|goblinoid([^a-z]|$)' THEN
  v_racial_attack_bonus:=1;
ELSIF v_sheet.raca_id='gnomo'
   AND v_target_traits ~ '(^|[^a-z])kobold|goblin|hobgoblin|bugbear|goblinoid([^a-z]|$)' THEN
  v_racial_attack_bonus:=1;
ELSIF v_sheet.raca_id='halfling'
   AND p_attack_type='atk-dist'
   AND (
     COALESCE(v_weapon.detalhes->>'weapon_ranged_type','')='thrown'
     OR lower(COALESCE(v_weapon.nome,''))='funda'
   ) THEN
  v_racial_attack_bonus:=1;
END IF;
v_expected_bonus:=v_bab+v_ability_mod+v_size_modifier+v_weapon_focus-v_power_penalty-v_range_penalty-v_weapon_proficiency_penalty+v_racial_attack_bonus;

 IF p_bonus_ataque>v_expected_bonus OR p_bonus_ataque<v_expected_bonus-30 THEN RAISE EXCEPTION 'Bônus de ataque excede o bônus calculado da ficha ou aplica penalidade inválida. Máximo: %, recebido: %.',v_expected_bonus,p_bonus_ataque; END IF;
 IF priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_character_id),'no_actions') OR priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_character_id),'cannot_attack') THEN RAISE EXCEPTION 'A condição atual impede ataques.'; END IF;
 v_effective_attack_modifier:=priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'attack')+CASE WHEN p_attack_type='atk-corpo' THEN priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'attack_melee')+FLOOR((v_str_score+priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'strength')-10)::numeric/2)::integer-FLOOR((v_str_score-10)::numeric/2)::integer ELSE priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'attack_ranged')+FLOOR((v_dex_score+priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'dexterity')-10)::numeric/2)::integer-FLOOR((v_dex_score-10)::numeric/2)::integer END;
 IF COALESCE(v_ca_text,'') !~ '[0-9]{1,3}' THEN RAISE EXCEPTION 'O token alvo precisa ter uma CA numérica.'; END IF;
 v_effective_ac_modifier:=priv.srd_effective_modifier(p_campaign_id,'token',BTRIM(p_token_id),'ac')+CASE WHEN p_attack_type='atk-corpo' THEN priv.srd_effective_modifier(p_campaign_id,'token',BTRIM(p_token_id),'ac_melee') ELSE priv.srd_effective_modifier(p_campaign_id,'token',BTRIM(p_token_id),'ac_ranged') END;
 v_ca:=substring(v_ca_text from '[0-9]{1,3}')::INTEGER+v_effective_ac_modifier; v_attack_total:=p_d20+p_bonus_ataque+v_effective_attack_modifier;
 IF p_d20=1 OR (p_d20<>20 AND v_attack_total<v_ca) THEN RAISE EXCEPTION 'Ataque não atingiu a CA do alvo (%). Nenhum dano foi aplicado.',v_ca; END IF;
 v_target:=v_tokens->(v_target_index::INTEGER-1);
 IF COALESCE(v_target->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN RAISE EXCEPTION 'O alvo não possui PV máximo configurado.'; END IF;
 v_max_hp:=(v_target->>'maxHp')::INTEGER; v_hp:=CASE WHEN COALESCE(v_target->>'hp','') ~ '^-?[0-9]{1,6}$' THEN (v_target->>'hp')::INTEGER ELSE v_max_hp END;
 v_damage_type:=CASE lower(COALESCE(v_weapon.tipo_dano,'bludgeoning')) WHEN 'cortante' THEN 'slashing' WHEN 'perfurante' THEN 'piercing' WHEN 'impacto' THEN 'bludgeoning' WHEN 'cortante/perfurante' THEN 'physical' WHEN 'impacto/perfurante' THEN 'physical' ELSE lower(COALESCE(v_weapon.tipo_dano,'bludgeoning')) END;
 v_damage_final:=priv.srd_adjust_damage(p_campaign_id,'token',BTRIM(p_token_id),v_damage_type,GREATEST(0,p_dano+COALESCE(p_sneak_attack_damage,0)+priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'damage')));
 v_new_hp:=GREATEST(-10,LEAST(v_max_hp,v_hp-v_damage_final)); v_target:=v_target||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp);
 v_scene:=v_scene||jsonb_build_object('tokens',jsonb_set(v_tokens,ARRAY[(v_target_index-1)::TEXT],v_target,FALSE)); UPDATE public.campaigns SET cba_data=v_scene WHERE id=p_campaign_id;
  PERFORM priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,v_new_hp,v_max_hp);
 RETURN jsonb_build_object('cba_data',v_scene,'hp',v_new_hp,'max_hp',v_max_hp,'ca',v_ca,'attack_total',v_attack_total,'damage',v_damage_final,'damage_roll',p_dano,'attack_effect_modifier',v_effective_attack_modifier,'target_ac_modifier',v_effective_ac_modifier);
END; $function$;

CREATE OR REPLACE FUNCTION public.srd_iniciar_ataque_oportunidade_desarmado_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
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
  v_character_id bigint;
  v_sheet public.srd_character_sheets%rowtype;
  v_class public.srd_classes%rowtype;
  v_race public.srd_races%rowtype;
  v_level integer;
  v_bab integer:=0;
  v_str integer;
  v_str_mod integer;
  v_size text;
  v_size_mod integer:=0;
  v_damage_dice text:='1d3';
  v_damage_expr text;
  v_attack_bonus integer;
  v_racial_bonus integer:=0;
  v_target_traits text;
  v_reach integer;
  v_steps integer;
  v_step integer;
  v_tx integer;
  v_ty integer;
  v_dx integer;
  v_dy integer;
  v_distance integer;
  v_attack_id uuid;
  v_has_improved_unarmed boolean:=false;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode iniciar um ataque desarmado de oportunidade.';
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
  v_character_id:=nullif(v_profile->>'character_id','')::bigint;
  if v_character_id is null then raise exception 'Ataque desarmado automatizado exige ficha SRD vinculada.'; end if;
  select * into v_sheet from public.srd_character_sheets where character_id=v_character_id;
  if not found then raise exception 'Ficha SRD do combatente não encontrada.'; end if;
  select * into v_class from public.srd_classes where id=v_sheet.classe_id;
  select * into v_race from public.srd_races where id=v_sheet.raca_id;
  if not found then raise exception 'Raça do combatente não encontrada.'; end if;

  SELECT coalesce(v_class.class_key='monk',false) OR EXISTS (
    SELECT 1
    FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::jsonb END
    ) feat
    WHERE lower(concat_ws(' ',feat->>'id',feat->>'nome',feat->>'name')) ~
      '(ataque_desarmado_aprimorado|srd35_feat_improved_unarmed_strike|improved_unarmed_strike|ataque desarmado aprimorado|improved unarmed strike)'
  ) INTO v_has_improved_unarmed;

  IF NOT v_has_improved_unarmed THEN
    RAISE EXCEPTION 'Ataque de Oportunidade desarmado exige Ataque Desarmado Aprimorado ou níveis de Monge.';
  END IF;
  if priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'no_actions')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'helpless')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stunned')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'unconscious')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dying')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stable')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dead')
    or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id::text,'no_actions')
    or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id::text,'helpless')
    or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id::text,'stunned')
    or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id::text,'unconscious')
    or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id::text,'dying')
    or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id::text,'stable')
    or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id::text,'dead') then
    raise exception 'A condição atual impede o ataque desarmado.';
  end if;

  v_level:=greatest(1,coalesce(v_sheet.nivel,1));
  select coalesce(sum(case lower(coalesce(cl.bab_progression,''))
    when 'good' then lv.class_level when 'bom' then lv.class_level
    when 'average' then floor(3*lv.class_level/4.0)::integer
    when 'medium' then floor(3*lv.class_level/4.0)::integer
    when 'medio' then floor(3*lv.class_level/4.0)::integer
    when 'poor' then floor(lv.class_level/2.0)::integer
    when 'ruim' then floor(lv.class_level/2.0)::integer else 0 end),0)::integer
  into v_bab from public.srd_character_class_levels lv
  join public.srd_classes cl on cl.id=lv.class_id where lv.character_id=v_character_id;
  if not exists(select 1 from public.srd_character_class_levels lv where lv.character_id=v_character_id) then
    v_bab:=case lower(coalesce(v_class.bab_progression,''))
      when 'good' then v_level when 'bom' then v_level
      when 'average' then floor(3*v_level/4.0)::integer
      when 'medium' then floor(3*v_level/4.0)::integer
      when 'medio' then floor(3*v_level/4.0)::integer
      when 'poor' then floor(v_level/2.0)::integer
      when 'ruim' then floor(v_level/2.0)::integer else 0 end;
  end if;

  v_str:=coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)
    +priv.srd_effective_modifier(p_campaign_id,'token',btrim(p_reactor_token_id),'strength');
  v_str_mod:=floor((v_str-10)::numeric/2)::integer;
  v_size:=lower(public.srd35_normalizar_parametro_talento(coalesce(v_race.tamanho,'medio')));
  v_size_mod:=case when v_size like 'fine%' or v_size like 'minusculo%' then 8
    when v_size like 'diminutive%' or v_size like 'diminuto%' then 4
    when v_size like 'tiny%' or v_size like 'miudo%' then 2
    when v_size like 'small%' or v_size like 'pequeno%' then 1
    when v_size like 'large%' or v_size like 'grande%' then -1
    when v_size like 'huge%' or v_size like 'enorme%' then -2
    when v_size like 'gargantuan%' or v_size like 'imenso%' then -4
    when v_size like 'colossal%' then -8 else 0 end;
  v_damage_dice:=case when v_size like 'fine%' or v_size like 'diminutive%' or v_size like 'tiny%'
      or v_size like 'minusculo%' or v_size like 'diminuto%' or v_size like 'miudo%' then '1d2'
    when v_size like 'small%' or v_size like 'pequeno%' then '1d2'
    when v_size like 'large%' or v_size like 'grande%' then '1d4'
    when v_size like 'huge%' or v_size like 'enorme%' then '1d6'
    when v_size like 'gargantuan%' or v_size like 'imenso%' then '1d8'
    when v_size like 'colossal%' then '2d6' else '1d3' end;
  v_damage_expr:=v_damage_dice||case when v_str_mod>0 then '+'||v_str_mod::text when v_str_mod<0 then v_str_mod::text else '' end;
  select count(*)::integer,(array_agg(t))[1] into v_count,v_token
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id);
  if v_count<>1 then raise exception 'Token atacante ausente ou duplicado.'; end if;
  select count(*)::integer,(array_agg(t))[1] into v_count,v_target
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=v_pending.mover_token_id or t->>'key'=v_pending.mover_token_id;
  if v_count<>1 then raise exception 'Alvo do movimento ausente ou duplicado.'; end if;
  v_target_traits:=lower(concat_ws(' ',v_target->>'nome',v_target->>'detalhe',
    v_target->'monsterStats'->>'tipo',v_target->'monsterStats'->>'subtipo',
    v_target->'monsterStats'->>'type',v_target->'monsterStats'->>'creature_type'));
  if v_race.id='anao' and v_target_traits ~ '(^|[^a-z])orc|goblin|hobgoblin|bugbear|goblinoid([^a-z]|$)' then v_racial_bonus:=1; end if;
  v_attack_bonus:=v_bab+v_str_mod+v_size_mod+v_racial_bonus;

  v_steps:=greatest(abs(v_pending.destination_x-v_pending.origin_x),abs(v_pending.destination_y-v_pending.origin_y));
  v_step:=greatest(0,coalesce(nullif(v_reaction->'threat'->>'last_threatened_step','')::integer,0));
  v_tx:=case when v_steps=0 then v_pending.origin_x else round(v_pending.origin_x+(v_pending.destination_x-v_pending.origin_x)::numeric*v_step/v_steps)::integer end;
  v_ty:=case when v_steps=0 then v_pending.origin_y else round(v_pending.origin_y+(v_pending.destination_y-v_pending.origin_y)::numeric*v_step/v_steps)::integer end;
  if coalesce(v_token->>'gridX','') !~ '^[0-9]{1,3}$' or coalesce(v_token->>'gridY','') !~ '^[0-9]{1,3}$' then
    raise exception 'Posição do atacante inválida.';
  end if;
  v_distance:=priv.srd_grid_footprint_distance_ft(
    (v_token->>'gridX')::integer,(v_token->>'gridY')::integer,
    priv.srd_token_grid_footprint(p_campaign_id,p_reactor_token_id),
    v_tx,v_ty,priv.srd_token_grid_footprint(p_campaign_id,v_pending.mover_token_id));
  v_reach:=coalesce(nullif(v_token->>'melee_reach_ft','')::integer,5);
  if v_distance>v_reach then raise exception 'O alvo está fora do alcance do ataque desarmado.'; end if;

  insert into priv.srd_aoo_attacks(campaign_id,pending_id,reaction_id,actor_token_id,target_token_id,
    actor_character_id,weapon_instance_id,weapon_hand_slot,created_by,resolution_data)
  values(p_campaign_id,p_pending_id,p_reaction_id,btrim(p_reactor_token_id),v_pending.mover_token_id,
    null,null,'natural',auth.uid(),jsonb_build_object(
      'weapon_name','Ataque desarmado','weapon_damage',v_damage_expr,'damage_expression',v_damage_expr,
      'monster_attack_bonus',v_attack_bonus,'critical_threat_minimum',20,'critical_multiplier',2,
      'damage_type','bludgeoning','source_character_id',v_character_id,
      'base_attack_bonus',v_bab,'strength_modifier',v_str_mod,'size_modifier',v_size_mod,
      'racial_bonus',v_racial_bonus,'trigger_x',v_tx,'trigger_y',v_ty
    )) returning attack_id into v_attack_id;
  update priv.srd_aoo_pending_movements
  set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],
    v_reaction||jsonb_build_object('status','attack_started','attack_id',v_attack_id),false),updated_at=now()
  where pending_id=p_pending_id;
  return jsonb_build_object('started',true,'attack_id',v_attack_id,'weapon_name','Ataque desarmado',
    'damage_expression',v_damage_expr,'attack_bonus',v_attack_bonus,'awaiting_manual_d20',true,'action_economy_cost',0);
end;
$function$;

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
  if v_race.id='anao' and v_target_traits ~ '(^|[^a-z])orc|goblin|hobgoblin|bugbear|goblinoid([^a-z]|$)' then v_racial_bonus:=1; end if;

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