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
  v_weapon_prof := priv.srd_weapon_proficiency(v_weapon.detalhes,v_weapon_name);
  v_class_profs := coalesce(v_class.dados_tecnicos->'proficiencias'->'armas','[]'::jsonb);
  v_proficient := exists (
    select 1 from jsonb_array_elements_text(case when jsonb_typeof(v_class_profs)='array' then v_class_profs else '[]'::jsonb end) p
    where lower(btrim(p.value))='todas as armas simples e marciais' AND v_weapon_prof IN ('simple','martial')
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
  if v_sheet.raca_id='anao' and v_target_traits ~ '(^|[^a-z])(orc|goblin|hobgoblin|bugbear|goblinoid(e)?)([^a-z]|$)' then v_racial_bonus := 1; end if;

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
  elsif v_target->>'tipo'='npc' AND NULLIF(v_target->>'sourceCharacterId','') IS NOT NULL then
    v_player_ac:=priv.srd_calcular_ca_alvo_campanha_srd(
      p_campaign_id,v_target->>'sourceCharacterId','normal'
    );
    v_ca:=nullif(v_player_ac->>'final_ac','')::integer;
    if v_ca is null then raise exception 'Não foi possível calcular a CA atual da ficha SRD vinculada ao NPC alvo.'; end if;
    v_ca:=v_ca+case when v_seq.attack_type='atk-corpo'
      then priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac_melee')
      else priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac_ranged') end;
    if v_actor_is_giant then
      SELECT sh.raca_id::text INTO v_target_race
      FROM public.srd_character_sheets sh
      WHERE sh.character_id::text=v_target->>'sourceCharacterId';
      IF v_target_race IN ('anao','gnomo')
         AND NOT COALESCE((v_player_ac->>'dexterity_lost')::boolean,false) THEN
        v_ca:=v_ca+4;
      END IF;
    end if;
  else
    v_ca_text:=coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca');
    if coalesce(v_ca_text,'') !~ '^[0-9]{1,3}$' then raise exception 'O alvo não possui CA numérica válida.'; end if;
    v_ca:=v_ca_text::integer+v_effect_ac;
  end if;
  IF v_target->>'tipo'<>'player'
     AND NOT (v_target->>'tipo'='npc' AND NULLIF(v_target->>'sourceCharacterId','') IS NOT NULL)
     AND v_actor_is_giant THEN
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
  v_weapon_prof := priv.srd_weapon_proficiency(v_weapon.detalhes,v_weapon_name);
  v_class_profs := coalesce(v_class.dados_tecnicos->'proficiencias'->'armas','[]'::jsonb);
  v_proficient := exists (
    select 1 from jsonb_array_elements_text(case when jsonb_typeof(v_class_profs)='array' then v_class_profs else '[]'::jsonb end) p
    where lower(btrim(p.value))='todas as armas simples e marciais' AND v_weapon_prof IN ('simple','martial')
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
  if v_sheet.raca_id='anao' and v_target_traits ~ '(^|[^a-z])(orc|goblin|hobgoblin|bugbear|goblinoid(e)?)([^a-z]|$)' then v_racial_bonus := 1; end if;

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

  if v_target->>'tipo'='player' OR (
       v_target->>'tipo'='npc' AND NULLIF(v_target->>'sourceCharacterId','') IS NOT NULL
     ) then
    v_player_ac:=priv.srd_calcular_ca_alvo_campanha_srd(
      p_campaign_id,
      CASE WHEN v_target->>'tipo'='player' THEN v_seq.target_token_id
           ELSE v_target->>'sourceCharacterId' END,
      'normal'
    );
    v_ca:=nullif(v_player_ac->>'final_ac','')::integer;
    if v_ca is null then raise exception 'Não foi possível calcular a CA atual da ficha SRD vinculada ao alvo.'; end if;
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
  v_weapon_prof:=priv.srd_weapon_proficiency(v_weapon.detalhes,v_weapon_name);
  v_profs:=coalesce(v_class.dados_tecnicos->'proficiencias'->'armas','[]'::jsonb);
  v_proficient:=exists(select 1 from jsonb_array_elements_text(case when jsonb_typeof(v_profs)='array' then v_profs else '[]'::jsonb end) p
    where lower(btrim(p.value))='todas as armas simples e marciais' AND v_weapon_prof IN ('simple','martial')
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
$function$;

CREATE OR REPLACE FUNCTION priv.concluir_avanco_nivel_personagem_srd(p_campaign_id bigint, p_character_id text, p_hit_die_roll integer, p_skill_ranks jsonb DEFAULT '{}'::jsonb, p_feats jsonb DEFAULT '[]'::jsonb, p_attribute text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv'
AS $function$
DECLARE
  v_owner UUID;
  v_campaign BIGINT;
  v_xp INTEGER;
  v_pending INTEGER;
  v_level INTEGER;
  v_next_level INTEGER;
  v_required_level INTEGER;
  v_class public.srd_classes%ROWTYPE;
  v_race public.srd_races%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_attrs JSONB;
  v_skill_state JSONB;
  v_feat_state JSONB;
  v_class_skills JSONB;
  v_skill RECORD;
  v_skill_id TEXT;
  v_skill_name TEXT;
  v_is_class_skill BOOLEAN;
  v_old_rank NUMERIC;
  v_added_rank NUMERIC;
  v_new_rank NUMERIC;
  v_max_rank NUMERIC;
  v_skill_points INTEGER;
  v_spent NUMERIC := 0;
  v_skill_cost NUMERIC;
  v_con_mod INTEGER;
  v_con_mod_old INTEGER;
  v_int_mod INTEGER;
  v_int_mod_old INTEGER;
  v_die INTEGER;
  v_hit_die_roll INTEGER;
  v_hp_gain INTEGER;
  v_hp_delta INTEGER;
  v_hp_max INTEGER;
  v_hp_current INTEGER;
  v_general_feats INTEGER := 0;
  v_bonus_kind TEXT := NULL;
  v_choice_count INTEGER := 0;
  v_choice RECORD;
  v_feat public.srd_feats%ROWTYPE;
  v_feat_id TEXT;
  v_req JSONB;
  v_req_item TEXT;
  v_owned_ids TEXT[] := ARRAY[]::TEXT[];
  v_selected_ids TEXT[] := ARRAY[]::TEXT[];
  v_feat_parameter TEXT;
  v_feat_type TEXT;
  v_parameter_type TEXT;
  v_owned_parameter TEXT;
  v_param_key TEXT;
  v_param_expected TEXT;
  v_weapon_name TEXT;
  v_weapon_details JSONB;
  v_weapon_prof TEXT;
  v_has_proficiency BOOLEAN;
  v_conditional RECORD;
  v_bab INTEGER;
  v_caster_level INTEGER;
  v_minimum INTEGER;
  v_json_value JSONB;
  v_feature_names JSONB := '[]'::jsonb;
  v_human BOOLEAN;
  v_class_skill_spend_delta JSONB := '{}'::jsonb;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF p_campaign_id IS NULL OR NULLIF(BTRIM(p_character_id),'') IS NULL THEN
    RAISE EXCEPTION 'Campanha e personagem são obrigatórios.';
  END IF;
  IF p_skill_ranks IS NULL OR jsonb_typeof(p_skill_ranks) <> 'object' THEN
    RAISE EXCEPTION 'As graduações de perícia precisam ser um objeto JSON.';
  END IF;
  IF p_feats IS NULL OR jsonb_typeof(p_feats) <> 'array' THEN
    RAISE EXCEPTION 'As escolhas de talentos precisam ser uma lista.';
  END IF;

  SELECT c.user_id,c.campaign_id,c.xp
    INTO v_owner,v_campaign,v_xp
    FROM public.characters c
   WHERE c.id::text=BTRIM(p_character_id)
   FOR UPDATE;
  IF NOT FOUND OR v_campaign IS DISTINCT FROM p_campaign_id THEN
    RAISE EXCEPTION 'Personagem não encontrado nesta campanha.';
  END IF;
  IF v_owner IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'Somente o dono da ficha pode aplicar seu avanço de nível.';
  END IF;

  SELECT s.* INTO v_sheet
    FROM public.srd_character_sheets s
   WHERE s.character_id::text=BTRIM(p_character_id)
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha D&D 3.5 não encontrada.'; END IF;

  v_level:=GREATEST(1,COALESCE(v_sheet.nivel,1));
  v_pending:=GREATEST(0,COALESCE(v_sheet.niveis_pendentes,0));
  IF v_pending<1 THEN RAISE EXCEPTION 'Não há nível pendente para aplicar.'; END IF;
  IF v_level>=20 THEN RAISE EXCEPTION 'O personagem já atingiu o nível máximo 20.'; END IF;
  v_required_level:=LEAST(20,public.nivel_de_xp(GREATEST(0,COALESCE(v_xp,v_sheet.xp,0))));
  v_next_level:=v_level+1;
  IF v_required_level<v_next_level THEN
    RAISE EXCEPTION 'O XP atual ainda não libera o próximo nível.';
  END IF;

  SELECT c.* INTO v_class FROM public.srd_classes c WHERE c.id=v_sheet.classe_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Classe SRD da ficha não encontrada.'; END IF;
  SELECT r.* INTO v_race FROM public.srd_races r WHERE r.id=v_sheet.raca_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Raça SRD da ficha não encontrada.'; END IF;

  v_die:=GREATEST(1,COALESCE(v_class.dado_vida,0));
  IF p_hit_die_roll IS NULL OR p_hit_die_roll < 1 OR p_hit_die_roll > v_die THEN
    RAISE EXCEPTION 'O resultado manual do dado de vida deve estar entre 1 e %.',v_die;
  END IF;
  v_hit_die_roll:=p_hit_die_roll;

  v_attrs:=COALESCE(v_sheet.atributos,'{}'::jsonb);
  -- Sheet attributes already include racial adjustments; never apply them twice.
  v_con_mod_old:=FLOOR((COALESCE(NULLIF(v_attrs->>'CON','')::numeric,10)-10)/2)::integer;
  v_int_mod_old:=FLOOR((COALESCE(NULLIF(v_attrs->>'INT','')::numeric,10)-10)/2)::integer;
  v_human:=public.srd35_normalizar_parametro_talento(v_race.id||' '||v_race.nome) LIKE '%humano%';

  -- Apply the character-level ability increase before validating feats and calculating skill points.
  IF MOD(v_next_level,4)=0 THEN
    IF p_attribute NOT IN ('FOR','DES','CON','INT','SAB','CAR') THEN
      RAISE EXCEPTION 'Escolha um atributo para receber +1 neste nível.';
    END IF;
    v_attrs:=jsonb_set(v_attrs,ARRAY[p_attribute],to_jsonb(COALESCE(NULLIF(v_attrs->>p_attribute,'')::integer,10)+1),true);
  ELSIF NULLIF(BTRIM(COALESCE(p_attribute,'')),'') IS NOT NULL THEN
    RAISE EXCEPTION 'Este nível não concede aumento de atributo.';
  END IF;
  v_con_mod:=FLOOR((COALESCE(NULLIF(v_attrs->>'CON','')::numeric,10)-10)/2)::integer;
  v_int_mod:=FLOOR((COALESCE(NULLIF(v_attrs->>'INT','')::numeric,10)-10)/2)::integer;

  -- INT increases apply retroactively to all class-level skill point awards.
  v_skill_points:=GREATEST(1,COALESCE(v_class.pericias_por_nivel,0)+v_int_mod)
    +(CASE WHEN v_human THEN 1 ELSE 0 END)
    +GREATEST(0,v_int_mod-v_int_mod_old)*v_level;
  v_skill_state:=COALESCE(v_sheet.pericias,'{}'::jsonb);
  v_class_skills:=COALESCE(v_class.pericias_classe,'[]'::jsonb);

  FOR v_skill IN
    SELECT e.key AS id,e.value AS amount,s.id AS skill_id,s.nome,s.treinada_apenas
      FROM jsonb_each(p_skill_ranks) e
      LEFT JOIN public.srd_skills s ON s.id=e.key
  LOOP
    v_skill_id:=v_skill.id;
    IF v_skill.skill_id IS NULL THEN RAISE EXCEPTION 'Perícia não encontrada: %.',v_skill_id; END IF;
    IF jsonb_typeof((p_skill_ranks->v_skill_id))<>'number' THEN
      RAISE EXCEPTION 'Graduação inválida para a perícia %.',v_skill.nome;
    END IF;
    v_added_rank:=(p_skill_ranks->>v_skill_id)::numeric;
    IF v_added_rank<0 OR v_added_rank<>round(v_added_rank*2)/2 THEN
      RAISE EXCEPTION 'Graduações para % devem ser incrementos positivos de 0,5.',v_skill.nome;
    END IF;
    IF v_added_rank=0 THEN CONTINUE; END IF;

    v_skill_name:=public.srd35_normalizar_parametro_talento(v_skill.nome);
    v_is_class_skill:=EXISTS (
      SELECT 1
        FROM jsonb_array_elements_text(v_class_skills) AS class_skill(name)
       WHERE public.srd35_normalizar_parametro_talento(class_skill.name)=v_skill_name
    ) OR (
      EXISTS (
        SELECT 1 FROM jsonb_array_elements_text(v_class_skills) AS class_skill(name)
         WHERE public.srd35_normalizar_parametro_talento(class_skill.name)='conhecimentoqualquer'
      )
      AND v_skill.nome ILIKE 'Conhecimento%'
    );
    IF v_skill_id='srd35_skill_speak_language' AND v_added_rank<>trunc(v_added_rank) THEN
      RAISE EXCEPTION 'Falar Idioma é comprado em graduações inteiras.';
    END IF;
    IF v_is_class_skill AND v_added_rank<>trunc(v_added_rank) THEN
      RAISE EXCEPTION 'A perícia de classe % exige graduações inteiras.',v_skill.nome;
    END IF;

    v_old_rank:=COALESCE(NULLIF(v_skill_state->>v_skill_id,'')::numeric,0);
    v_new_rank:=v_old_rank+v_added_rank;
    IF v_skill_id<>'srd35_skill_speak_language' THEN
      v_max_rank:=CASE WHEN v_is_class_skill THEN v_next_level+3 ELSE (v_next_level+3)/2.0 END;
      IF v_new_rank>v_max_rank THEN
        RAISE EXCEPTION 'O máximo de graduações em % no nível % é %.',v_skill.nome,v_next_level,v_max_rank;
      END IF;
    END IF;
    v_skill_cost:=CASE WHEN v_is_class_skill OR v_skill_id='srd35_skill_speak_language' THEN 1 ELSE 2 END;
    v_spent:=v_spent+(v_added_rank*v_skill_cost);
    v_class_skill_spend_delta:=jsonb_set(v_class_skill_spend_delta,ARRAY[v_skill_id],to_jsonb(COALESCE(NULLIF(v_class_skill_spend_delta->>v_skill_id,'')::numeric,0)+(v_added_rank*v_skill_cost)),true);
    v_skill_state:=jsonb_set(v_skill_state,ARRAY[v_skill_id],to_jsonb(v_new_rank),true);
  END LOOP;
  IF v_spent>v_skill_points THEN
    RAISE EXCEPTION 'Pontos de perícia excedidos: % de %.',v_spent,v_skill_points;
  END IF;

  -- One general feat at each 3rd character level.
  IF MOD(v_next_level,3)=0 THEN v_general_feats:=1; END IF;
  IF (v_class.id IN ('guerreiro','fighter') OR v_class.class_key='fighter') AND MOD(v_next_level,2)=0 THEN
    v_bonus_kind:='fighter';
  ELSIF (v_class.id IN ('mago','wizard') OR v_class.class_key='wizard') AND v_next_level IN (5,10,15,20) THEN
    v_bonus_kind:='wizard';
  ELSIF (v_class.id IN ('monge','monk') OR v_class.class_key='monk') AND v_next_level IN (2,6) THEN
    v_bonus_kind:='monk';
  END IF;

  v_choice_count:=v_general_feats+CASE WHEN v_bonus_kind IS NULL THEN 0 ELSE 1 END;
  IF jsonb_array_length(p_feats)<>v_choice_count THEN
    RAISE EXCEPTION 'Este nível exige % escolha(s) de talento.',v_choice_count;
  END IF;
  v_feat_state:=CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::jsonb END;
  SELECT COALESCE(array_agg(value->>'id'),'{}'::text[]) INTO v_owned_ids
    FROM jsonb_array_elements(v_feat_state) AS existing(value)
   WHERE value->>'id' IS NOT NULL;

  FOR v_choice IN SELECT value,ord FROM jsonb_array_elements(p_feats) WITH ORDINALITY AS choices(value,ord) ORDER BY ord LOOP
    IF jsonb_typeof(v_choice.value)<>'object' THEN RAISE EXCEPTION 'Escolha de talento inválida.'; END IF;
    v_feat_id:=NULLIF(BTRIM(v_choice.value->>'id'),'');
    v_feat_parameter:=BTRIM(COALESCE(v_choice.value->>'parametro',''));
    v_feat_type:=CASE WHEN v_choice.ord<=v_general_feats THEN 'general' ELSE COALESCE(v_choice.value->>'choice_type','') END;
    IF v_feat_id IS NULL THEN RAISE EXCEPTION 'Selecione todos os talentos exigidos.'; END IF;
    SELECT f.* INTO v_feat FROM public.srd_feats f WHERE f.id=v_feat_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Talento não encontrado: %.',v_feat_id; END IF;
    v_req:=COALESCE(v_feat.requisitos,'{}'::jsonb);
    IF EXISTS (
      SELECT 1 FROM jsonb_array_elements(v_feat_state) AS existing(value)
       WHERE existing.value->>'id'=v_feat_id
         AND (
           NOT COALESCE((v_req->>'repeatable')::boolean,false)
           OR (
             v_req->>'repeatable_mode'='different_parameter'
             AND public.srd35_normalizar_parametro_talento(COALESCE(existing.value->>'parametro',''))
                 = public.srd35_normalizar_parametro_talento(COALESCE(v_feat_parameter,''))
           )
         )
    ) THEN
      RAISE EXCEPTION 'Este talento já foi escolhido com a mesma opção ou não permite repetição: %.',v_feat.nome;
    END IF;

    IF v_feat_type='general' THEN
      IF COALESCE(v_req->>'type','General')<>'General' THEN
        RAISE EXCEPTION 'Escolha um talento geral para esta seleção.';
      END IF;
    ELSIF v_feat_type='fighter' AND v_bonus_kind='fighter' THEN
      IF v_feat_id NOT IN (
        'srd35_feat_blind_fight','srd35_feat_cleave','srd35_feat_combat_expertise','srd35_feat_deflect_arrows',
        'esquiva','srd35_feat_far_shot','srd35_feat_great_cleave','srd35_feat_improved_bull_rush',
        'srd35_feat_improved_critical','srd35_feat_improved_disarm','srd35_feat_improved_feint',
        'srd35_feat_improved_grapple','iniciativa_aprimorada','srd35_feat_improved_overrun',
        'srd35_feat_improved_precise_shot','srd35_feat_improved_shield_bash','srd35_feat_improved_sunder',
        'srd35_feat_improved_trip','srd35_feat_improved_two_weapon_fighting','srd35_feat_manyshot',
        'srd35_feat_mobility','srd35_feat_mounted_archery','srd35_feat_mounted_combat',
        'srd35_feat_point_blank_shot','ataque_poderoso','srd35_feat_precise_shot','srd35_feat_quick_draw',
        'srd35_feat_rapid_reload','srd35_feat_rapid_shot','srd35_feat_ride_by_attack',
        'srd35_feat_shot_on_the_run','srd35_feat_spring_attack','srd35_feat_spirited_charge',
        'srd35_feat_trample','srd35_feat_two_weapon_fighting','srd35_feat_weapon_finesse',
        'foco_em_arma','srd35_feat_weapon_specialization','srd35_feat_greater_weapon_focus',
        'srd35_feat_greater_weapon_specialization','srd35_feat_whirlwind_attack',
        'srd35_feat_improved_unarmed_strike','reflexos_de_combate','srd35_feat_stunning_fist'
      ) THEN RAISE EXCEPTION 'Este talento não está na lista de talentos adicionais do Guerreiro.'; END IF;
    ELSIF v_feat_type='wizard' AND v_bonus_kind='wizard' THEN
      -- The SRD explicitly says the wizard is not limited to feat categories for these bonus feats.
      -- All ordinary prerequisites are still checked below.
    ELSIF v_feat_type='monk' AND v_bonus_kind='monk' THEN
      IF NOT (
        (v_next_level=2 AND v_feat_id IN ('reflexos_de_combate','srd35_feat_deflect_arrows'))
        OR (v_next_level=6 AND v_feat_id IN ('srd35_feat_improved_disarm','srd35_feat_improved_trip'))
      ) THEN RAISE EXCEPTION 'Este talento não é uma opção de talento adicional de Monge neste nível.'; END IF;
    ELSE
      RAISE EXCEPTION 'Tipo de escolha de talento incompatível com a progressão desta classe.';
    END IF;

    -- Repetições válidas já foram verificadas contra v_feat_state e repeatable_mode.
    -- Monk bonus-feat lists explicitly waive each feat's normal prerequisites.
    IF v_feat_type<>'monk' THEN
    FOR v_req_item IN SELECT value FROM jsonb_array_elements_text(COALESCE(v_req->'feat_ids','[]'::jsonb)) AS reqs(value) LOOP
      IF NOT (v_req_item=ANY(v_owned_ids)) THEN
        RAISE EXCEPTION 'O talento % exige o pré-requisito %.',v_feat.nome,v_req_item;
      END IF;
    END LOOP;

    IF COALESCE(NULLIF(v_req->>'for_min','')::integer,0)>COALESCE(NULLIF(v_attrs->>'FOR','')::integer,10)
      OR COALESCE(NULLIF(v_req->>'des_min','')::integer,0)>COALESCE(NULLIF(v_attrs->>'DES','')::integer,10)
      OR COALESCE(NULLIF(v_req->>'con_min','')::integer,0)>COALESCE(NULLIF(v_attrs->>'CON','')::integer,10)
      OR COALESCE(NULLIF(v_req->>'int_min','')::integer,0)>COALESCE(NULLIF(v_attrs->>'INT','')::integer,10)
      OR COALESCE(NULLIF(v_req->>'sab_min','')::integer,0)>COALESCE(NULLIF(v_attrs->>'SAB','')::integer,10)
      OR COALESCE(NULLIF(v_req->>'car_min','')::integer,0)>COALESCE(NULLIF(v_attrs->>'CAR','')::integer,10) THEN
      RAISE EXCEPTION 'Os atributos atuais não atendem aos pré-requisitos de %.',v_feat.nome;
    END IF;

    v_bab:=CASE
      WHEN COALESCE(v_class.bab_progression,'') IN ('good','bom') THEN v_next_level
      WHEN COALESCE(v_class.bab_progression,'') IN ('average','medium','medio') THEN FLOOR(v_next_level*0.75)::integer
      WHEN COALESCE(v_class.bab_progression,'') IN ('poor','bad','ruim') THEN FLOOR(v_next_level/2.0)::integer
      ELSE COALESCE(v_class.dados_tecnicos->>'bab_nivel_1','0')::integer
    END;
    IF COALESCE(NULLIF(v_req->>'bab_min','')::integer,0)>v_bab THEN
      RAISE EXCEPTION '% exige BBA +%.',v_feat.nome,(v_req->>'bab_min');
    END IF;
    IF COALESCE(NULLIF(v_req->>'character_level_min','')::integer,0)>v_next_level
      OR COALESCE(NULLIF(v_req->>'class_level_min','')::integer,0)>v_next_level
      OR (NULLIF(v_req->>'class_key_required','') IS NOT NULL AND v_req->>'class_key_required' IS DISTINCT FROM v_class.class_key) THEN
      RAISE EXCEPTION 'O nível ou a classe atual ainda não atende aos pré-requisitos de %.',v_feat.nome;
    END IF;

    v_caster_level:=CASE
      WHEN COALESCE(v_class.class_key,'') IN ('wizard','sorcerer','cleric','druid','bard') THEN v_next_level
      WHEN COALESCE(v_class.class_key,'') IN ('paladin','ranger') THEN GREATEST(0,v_next_level-3)
      ELSE 0
    END;
    IF COALESCE(NULLIF(v_req->>'caster_level_min','')::integer,0)>v_caster_level THEN
      RAISE EXCEPTION '% exige nível de conjurador %.',v_feat.nome,(v_req->>'caster_level_min');
    END IF;
    IF v_req ? 'skill_ranks' THEN
      FOR v_skill_id IN SELECT key FROM jsonb_each(v_req->'skill_ranks') LOOP
        IF COALESCE(NULLIF(v_skill_state->>v_skill_id,'')::numeric,0)<COALESCE(NULLIF(v_req->'skill_ranks'->>v_skill_id,'')::numeric,0) THEN
          RAISE EXCEPTION '% exige mais graduações na perícia %.',v_feat.nome,v_skill_id;
        END IF;
      END LOOP;
    END IF;

    v_parameter_type:=COALESCE(NULLIF(v_req->>'parameter_type',''),CASE WHEN v_feat_id='srd35_feat_spell_mastery' THEN 'spell_list' ELSE '' END);
    IF (v_feat.exige_parametro OR v_parameter_type<>'') AND v_feat_parameter='' THEN
      RAISE EXCEPTION 'Informe a escolha exigida pelo talento %.',v_feat.nome;
    END IF;

    -- Validate selected weapon parameters against the SRD weapon catalogue.
    IF v_parameter_type IN ('weapon','weapon_martial','weapon_exotic','crossbow') THEN
      SELECT e.nome,e.detalhes INTO v_weapon_name,v_weapon_details
        FROM public.srd_equipment e
       WHERE public.srd35_equipment_slot(e.categoria,e.nome)='arma'
         AND public.srd35_normalizar_parametro_talento(e.nome)=public.srd35_normalizar_parametro_talento(v_feat_parameter)
       LIMIT 1;
      IF NOT FOUND THEN
        RAISE EXCEPTION 'A arma informada para % não existe no catálogo SRD.',v_feat.nome;
      END IF;
      v_weapon_prof:=priv.srd_weapon_proficiency(v_weapon_details,v_weapon_name);
      IF v_race.id='anao' AND regexp_replace(lower(translate(v_weapon_name,'ã','a')),'[^a-z0-9]+','','g') IN ('waraxedwarven','dwarvenwaraxe','urgroshdwarven','dwarvenurgrosh','machadodeguerraanao','urgroshanao') THEN v_weapon_prof:='martial'; END IF;
      IF v_parameter_type='weapon_martial' AND v_weapon_prof<>'martial' THEN
        RAISE EXCEPTION 'A arma escolhida precisa ser marcial.';
      ELSIF v_parameter_type='weapon_exotic' AND v_weapon_prof<>'exotic' THEN
        RAISE EXCEPTION 'A arma escolhida precisa ser exótica.';
      ELSIF v_parameter_type='crossbow' AND public.srd35_normalizar_parametro_talento(v_weapon_name) NOT IN ('besta de mao','besta leve','besta pesada') THEN
        RAISE EXCEPTION 'Escolha besta de mão, besta leve ou besta pesada.';
      END IF;

      IF COALESCE((v_req->>'weapon_proficiency_required')::boolean,false) THEN
        v_has_proficiency:=EXISTS (
          SELECT 1
            FROM jsonb_array_elements_text(COALESCE(v_class.dados_tecnicos->'proficiencias'->'armas','[]'::jsonb)) AS proficiency(value)
           WHERE public.srd35_normalizar_parametro_talento(proficiency.value)=public.srd35_normalizar_parametro_talento(v_weapon_name)
              OR (public.srd35_normalizar_parametro_talento(proficiency.value)='armas simples' AND v_weapon_prof='simple')
              OR (public.srd35_normalizar_parametro_talento(proficiency.value)='todasasarmassimplesemarciais' AND v_weapon_prof IN ('simple','martial'))
        );
        IF NOT v_has_proficiency THEN
          RAISE EXCEPTION 'A classe não é proficiente com %; não pode escolher % ainda.',v_weapon_name,v_feat.nome;
        END IF;
      END IF;
    END IF;

    -- Conditional ability prerequisites apply only to their listed parameter choices.
    FOR v_conditional IN
      SELECT key,value FROM jsonb_each(COALESCE(v_req->'conditional_ability_min','{}'::jsonb))
    LOOP
      IF EXISTS (
        SELECT 1 FROM jsonb_array_elements_text(COALESCE(v_conditional.value->'parameters','[]'::jsonb)) AS param(value)
         WHERE public.srd35_normalizar_parametro_talento(param.value)=public.srd35_normalizar_parametro_talento(v_feat_parameter)
      ) THEN
        v_minimum:=COALESCE(NULLIF(v_conditional.value->>'minimum','')::integer,0);
        IF COALESCE(NULLIF(v_attrs->>v_conditional.key,'')::integer,10)<v_minimum THEN
          RAISE EXCEPTION 'A escolha % exige % %.',v_feat.nome,v_conditional.key,v_minimum;
        END IF;
      END IF;
    END LOOP;

    -- Com talentos repetíveis, qualquer instância do pré-requisito com a opção
    -- correspondente satisfaz a cadeia; não assumir que a primeira instância é a correta.
    FOR v_param_key,v_param_expected IN
      SELECT key,value FROM jsonb_each_text(COALESCE(v_req->'feat_parameters','{}'::jsonb))
    LOOP
      IF NOT EXISTS (
        SELECT 1 FROM jsonb_array_elements(v_feat_state) AS existing(value)
         WHERE existing.value->>'id'=v_param_key
           AND public.srd35_normalizar_parametro_talento(COALESCE(existing.value->>'parametro',''))
               = public.srd35_normalizar_parametro_talento(v_param_expected)
      ) THEN
        RAISE EXCEPTION '% exige que o pré-requisito % use o parâmetro %.',v_feat.nome,v_param_key,v_param_expected;
      END IF;
    END LOOP;
    FOR v_param_key IN
      SELECT jsonb_array_elements_text(COALESCE(v_req->'feat_parameter_matches','[]'::jsonb))
    LOOP
      IF NOT EXISTS (
        SELECT 1 FROM jsonb_array_elements(v_feat_state) AS existing(value)
         WHERE existing.value->>'id'=v_param_key
           AND public.srd35_normalizar_parametro_talento(COALESCE(existing.value->>'parametro',''))
               = public.srd35_normalizar_parametro_talento(v_feat_parameter)
           AND public.srd35_normalizar_parametro_talento(v_feat_parameter)<>''
      ) THEN
        RAISE EXCEPTION '% exige o mesmo parâmetro (arma/escola) do talento %.',v_feat.nome,v_param_key;
      END IF;
    END LOOP;

    IF v_parameter_type='spell_list' THEN
      IF v_class.class_key<>'wizard' OR v_int_mod<1 THEN
        RAISE EXCEPTION 'Maestria em Magia exige Mago com modificador positivo de Inteligência.';
      END IF;
      IF cardinality(regexp_split_to_array(v_feat_parameter,'[,;]'))<>v_int_mod THEN
        RAISE EXCEPTION 'Maestria em Magia exige % magia(s) escolhida(s).',v_int_mod;
      END IF;
      IF cardinality(ARRAY(SELECT DISTINCT public.srd35_normalizar_parametro_talento(value) FROM unnest(regexp_split_to_array(v_feat_parameter,'[,;]')) AS spell(value)))<>v_int_mod THEN
        RAISE EXCEPTION 'Não repita uma magia em Maestria em Magia.';
      END IF;
      FOR v_req_item IN SELECT BTRIM(value) FROM unnest(regexp_split_to_array(v_feat_parameter,'[,;]')) AS spell(value) LOOP
        IF NOT EXISTS (
          SELECT 1
            FROM public.srd_character_spellbook book
            JOIN public.srd_spells spell ON spell.id=book.spell_id
           WHERE book.character_id::text=BTRIM(p_character_id)
             AND (book.class_id=v_class.id OR book.class_id=v_class.class_key)
             AND (spell.id=v_req_item OR public.srd35_normalizar_parametro_talento(spell.nome)=public.srd35_normalizar_parametro_talento(v_req_item))
        ) THEN
          RAISE EXCEPTION 'A magia % não consta no grimório deste personagem.',v_req_item;
        END IF;
      END LOOP;
    END IF;

    END IF;

    v_feat_state:=v_feat_state||jsonb_build_array(jsonb_build_object('id',v_feat_id,'parametro',NULLIF(v_feat_parameter,'')));
    v_owned_ids:=array_append(v_owned_ids,v_feat_id);
    v_selected_ids:=array_append(v_selected_ids,v_feat_id);
  END LOOP;

  -- A Constitution modifier increase changes HP for every Hit Die already gained.
  v_hp_gain:=GREATEST(1,v_hit_die_roll+v_con_mod)
    +GREATEST(0,v_con_mod-v_con_mod_old)*v_level;
  v_hp_delta:=v_hp_gain;
  v_hp_max:=GREATEST(1,COALESCE(v_sheet.pv_max,0))+v_hp_delta;
  v_hp_current:=LEAST(v_hp_max,GREATEST(0,COALESCE(v_sheet.pv_atual,v_sheet.pv_max,0))+v_hp_delta);

  SELECT COALESCE(jsonb_agg(jsonb_build_object('name',f.name,'summary',f.summary,'mechanics',f.mechanics) ORDER BY f.feature_key),'[]'::jsonb)
    INTO v_feature_names
    FROM public.srd_class_level_features f
   WHERE f.class_id=v_class.id AND f.class_level=v_next_level;

  UPDATE public.srd_character_sheets
     SET nivel=v_next_level,
         niveis_pendentes=GREATEST(0,v_pending-1),
         pv_max=v_hp_max,
         pv_atual=v_hp_current,
         atributos=v_attrs,
         pericias=v_skill_state,
         talentos=v_feat_state,
         xp=GREATEST(0,COALESCE(v_xp,v_sheet.xp,0))
   WHERE character_id::text=BTRIM(p_character_id);

  INSERT INTO public.srd_character_class_levels
    (character_id,class_id,class_level,taken_at_character_level,hit_points_gained,skill_points_spent)
  VALUES
    (v_sheet.character_id,v_class.id,v_next_level,1,v_hp_gain,v_class_skill_spend_delta)
  ON CONFLICT (character_id,class_id) DO UPDATE
    SET class_level=EXCLUDED.class_level,
        taken_at_character_level=COALESCE(public.srd_character_class_levels.taken_at_character_level,1),
        hit_points_gained=COALESCE(public.srd_character_class_levels.hit_points_gained,0)+v_hp_gain,
        skill_points_spent=(
          SELECT COALESCE(jsonb_object_agg(keys.skill_id,to_jsonb(
            COALESCE(NULLIF(public.srd_character_class_levels.skill_points_spent->>keys.skill_id,'')::numeric,0)
            +COALESCE(NULLIF(v_class_skill_spend_delta->>keys.skill_id,'')::numeric,0)
          )),'{}'::jsonb)
          FROM (
            SELECT key AS skill_id FROM jsonb_each(COALESCE(public.srd_character_class_levels.skill_points_spent,'{}'::jsonb))
            UNION
            SELECT key AS skill_id FROM jsonb_each(v_class_skill_spend_delta)
          ) keys
        );

  RETURN jsonb_build_object(
    'character_id',BTRIM(p_character_id),
    'nivel_anterior',v_level,
    'nivel',v_next_level,
    'niveis_pendentes',GREATEST(0,v_pending-1),
    'dado_vida',v_die,
    'rolagem_dado_vida',v_hit_die_roll,
    'modificador_constituicao',v_con_mod,
    'ajuste_pv_constituicao',GREATEST(0,v_con_mod-v_con_mod_old)*v_level,
    'ganho_pv',v_hp_delta,
    'pv_atual',v_hp_current,
    'pv_max',v_hp_max,
    'pontos_pericia',v_skill_points,
    'pontos_pericia_gastos',v_spent,
    'atributos',v_attrs,
    'caracteristicas',v_feature_names
  );
END;
$function$;

CREATE OR REPLACE FUNCTION public.salvar_talentos_bonus_classe_inicial_srd(p_character_id text, p_talentos jsonb DEFAULT '[]'::jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_character public.characters%ROWTYPE;
  v_class public.srd_classes%ROWTYPE;
  v_feat public.srd_feats%ROWTYPE;
  v_req JSONB;
  v_existing JSONB;
  v_updated JSONB;
  v_entry JSONB;
  v_feat_id TEXT;
  v_param TEXT;
  v_class_key TEXT;
  v_expected INTEGER := 0;
  v_bab INTEGER := 0;
  v_required INTEGER;
  v_stat_key TEXT;
  v_weapon_name TEXT;
  v_weapon_details JSONB;
  v_weapon_prof TEXT;
  v_has_prof BOOLEAN;
  v_owned TEXT[] := ARRAY[]::TEXT[];
  v_added TEXT[] := ARRAY[]::TEXT[];
  v_feature TEXT;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  IF NULLIF(BTRIM(p_character_id),'') IS NULL THEN RAISE EXCEPTION 'Personagem obrigatório.'; END IF;
  IF p_talentos IS NULL OR jsonb_typeof(p_talentos)<>'array' THEN
    RAISE EXCEPTION 'Talentos bônus precisam ser enviados como uma lista JSON.';
  END IF;

  SELECT ch.* INTO v_character
    FROM public.characters ch
   WHERE ch.id::text=BTRIM(p_character_id) AND ch.user_id=auth.uid()
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou sem autorização.'; END IF;

  SELECT sh.* INTO v_sheet
    FROM public.srd_character_sheets sh
   WHERE sh.character_id=v_character.id
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha D&D 3.5 não encontrada.'; END IF;
  IF COALESCE(v_sheet.nivel,1)<>1 THEN
    RAISE EXCEPTION 'Esta operação só concede características da criação de nível 1.';
  END IF;

  SELECT cl.* INTO v_class FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Classe SRD não encontrada.'; END IF;
  v_class_key:=COALESCE(v_class.class_key,'');
  v_expected:=CASE WHEN v_class_key IN ('fighter','monk') THEN 1 ELSE 0 END;
  IF jsonb_array_length(p_talentos)<>v_expected THEN
    RAISE EXCEPTION 'A classe exige % escolha(s) de talento bônus no nível 1.',v_expected;
  END IF;

  v_existing:=CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::jsonb END;
  SELECT COALESCE(array_agg(value->>'id'),'{}'::text[]) INTO v_owned
    FROM jsonb_array_elements(v_existing) AS current(value)
   WHERE value->>'id' IS NOT NULL;

  IF v_class_key IN ('fighter','monk') AND EXISTS (
    SELECT 1 FROM jsonb_array_elements(v_existing) AS saved(value)
     WHERE saved.value->>'origem'='class_bonus'
  ) THEN
    SELECT saved.value INTO v_entry
      FROM jsonb_array_elements(v_existing) AS saved(value)
     WHERE saved.value->>'origem'='class_bonus'
     LIMIT 1;
    IF jsonb_array_length(p_talentos)=1
       AND v_entry->>'id'=p_talentos->0->>'id'
       AND COALESCE(v_entry->>'parametro','')=COALESCE(p_talentos->0->>'parametro','') THEN
      RETURN jsonb_build_object('character_id',v_character.id::text,'class_key',v_class_key,'added','[]'::jsonb,'talentos',v_existing,'already_applied',true);
    END IF;
    RAISE EXCEPTION 'Já existe um talento bônus de classe gravado para este personagem.';
  END IF;

  IF v_class_key='fighter' THEN
    v_bab:=CASE
      WHEN v_class.bab_progression IN ('good','bom') THEN 1
      WHEN v_class.bab_progression IN ('average','medium','medio') THEN 0
      WHEN v_class.bab_progression IN ('poor','bad','ruim') THEN 0
      ELSE 0 END;

    v_entry:=p_talentos->0;
    IF jsonb_typeof(v_entry)<>'object' THEN RAISE EXCEPTION 'Escolha um talento bônus válido para Guerreiro.'; END IF;
    v_feat_id:=NULLIF(BTRIM(v_entry->>'id'),'');
    v_param:=BTRIM(COALESCE(v_entry->>'parametro',''));
    IF v_feat_id IS NULL THEN RAISE EXCEPTION 'Selecione o talento bônus do Guerreiro.'; END IF;
    IF v_feat_id NOT IN (
      'srd35_feat_blind_fight','srd35_feat_cleave','srd35_feat_combat_expertise',
      'srd35_feat_deflect_arrows','esquiva','srd35_feat_far_shot','srd35_feat_great_cleave',
      'srd35_feat_improved_bull_rush','srd35_feat_improved_critical','srd35_feat_improved_disarm',
      'srd35_feat_improved_feint','srd35_feat_improved_grapple','iniciativa_aprimorada',
      'srd35_feat_improved_overrun','srd35_feat_improved_precise_shot','srd35_feat_improved_shield_bash',
      'srd35_feat_improved_sunder','srd35_feat_improved_trip','srd35_feat_improved_two_weapon_fighting',
      'srd35_feat_manyshot','srd35_feat_mobility','srd35_feat_mounted_archery','srd35_feat_mounted_combat',
      'srd35_feat_point_blank_shot','ataque_poderoso','srd35_feat_precise_shot','srd35_feat_quick_draw',
      'srd35_feat_rapid_reload','srd35_feat_rapid_shot','srd35_feat_ride_by_attack',
      'srd35_feat_shot_on_the_run','srd35_feat_spring_attack','srd35_feat_spirited_charge',
      'srd35_feat_trample','srd35_feat_two_weapon_fighting','srd35_feat_weapon_finesse',
      'foco_em_arma','srd35_feat_weapon_specialization','srd35_feat_greater_weapon_focus',
      'srd35_feat_greater_weapon_specialization','srd35_feat_whirlwind_attack',
      'srd35_feat_improved_unarmed_strike','reflexos_de_combate','srd35_feat_stunning_fist'
    ) THEN RAISE EXCEPTION 'Este talento não faz parte da lista de bônus do Guerreiro.'; END IF;

    SELECT f.* INTO v_feat FROM public.srd_feats f WHERE f.id=v_feat_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Talento do catálogo não encontrado.'; END IF;
    v_req:=COALESCE(v_feat.requisitos,'{}'::jsonb);
    IF COALESCE(v_req->>'type','General')<>'General' THEN
      RAISE EXCEPTION 'O talento bônus do Guerreiro precisa ser geral.';
    END IF;
    IF v_feat.exige_parametro AND v_param='' THEN
      RAISE EXCEPTION 'Informe o parâmetro exigido por %.',v_feat.nome;
    ELSIF NOT COALESCE(v_feat.exige_parametro,false) AND v_param<>'' THEN
      RAISE EXCEPTION '% não aceita parâmetro.',v_feat.nome;
    END IF;
    IF v_feat_id=ANY(v_owned) THEN
      IF EXISTS (
        SELECT 1 FROM jsonb_array_elements(v_existing) AS saved(value)
         WHERE saved.value->>'id'=v_feat_id
           AND saved.value->>'origem'='class_bonus'
           AND COALESCE(saved.value->>'parametro','')=v_param
      ) THEN
        RETURN jsonb_build_object('character_id',v_character.id::text,'class_key',v_class_key,'added','[]'::jsonb,'talentos',v_existing,'already_applied',true);
      END IF;
      RAISE EXCEPTION 'O personagem já possui %.',v_feat.nome;
    END IF;

    FOR v_stat_key IN SELECT unnest(ARRAY['FOR','DES','CON','INT','SAB','CAR']) LOOP
      v_required:=COALESCE(NULLIF(v_req->>(lower(v_stat_key)||'_min'),'')::integer,0);
      IF COALESCE(NULLIF(v_sheet.atributos->>v_stat_key,'')::integer,10)<v_required THEN
        RAISE EXCEPTION '% exige % %.',v_feat.nome,v_stat_key,v_required;
      END IF;
    END LOOP;
    v_required:=COALESCE(NULLIF(v_req->>'bab_min','')::integer,0);
    IF v_bab<v_required THEN RAISE EXCEPTION '% exige BBA +%.',v_feat.nome,v_required; END IF;
    IF COALESCE(NULLIF(v_req->>'class_level_min','')::integer,0)>1
       OR (NULLIF(v_req->>'class_key_required','') IS NOT NULL AND v_req->>'class_key_required'<>'fighter') THEN
      RAISE EXCEPTION 'O nível de Guerreiro ainda não atende aos pré-requisitos de %.',v_feat.nome;
    END IF;
    FOR v_feature IN SELECT value FROM jsonb_array_elements_text(COALESCE(v_req->'feat_ids','[]'::jsonb)) AS prereq(value) LOOP
      IF NOT (v_feature=ANY(v_owned)) THEN
        RAISE EXCEPTION '% exige o talento prévio %.',v_feat.nome,v_feature;
      END IF;
    END LOOP;
    IF v_req ? 'skill_ranks' THEN
      FOR v_stat_key IN SELECT key FROM jsonb_each(v_req->'skill_ranks') LOOP
        IF COALESCE(NULLIF(v_sheet.pericias->>v_stat_key,'')::numeric,0)<COALESCE(NULLIF(v_req->'skill_ranks'->>v_stat_key,'')::numeric,0) THEN
          RAISE EXCEPTION '% exige mais graduações em %.',v_feat.nome,v_stat_key;
        END IF;
      END LOOP;
    END IF;
    IF v_param<>'' AND COALESCE(v_req->>'parameter_type','') IN ('weapon','weapon_martial','weapon_exotic','crossbow') THEN
      SELECT e.nome,e.detalhes INTO v_weapon_name,v_weapon_details
        FROM public.srd_equipment e
       WHERE public.srd35_equipment_slot(e.categoria,e.nome)='arma'
         AND public.srd35_normalizar_parametro_talento(e.nome)=public.srd35_normalizar_parametro_talento(v_param)
       LIMIT 1;
      IF NOT FOUND THEN RAISE EXCEPTION 'Arma escolhida não existe no catálogo SRD.'; END IF;
      v_weapon_prof:=priv.srd_weapon_proficiency(v_weapon_details,v_weapon_name);
      IF v_sheet.raca_id='anao' AND regexp_replace(lower(translate(v_weapon_name,'ã','a')),'[^a-z0-9]+','','g') IN ('waraxedwarven','dwarvenwaraxe','urgroshdwarven','dwarvenurgrosh','machadodeguerraanao','urgroshanao') THEN v_weapon_prof:='martial'; END IF;
      IF COALESCE(v_req->>'parameter_type','')='weapon_martial' AND v_weapon_prof<>'martial' THEN
        RAISE EXCEPTION 'Escolha uma arma marcial.';
      ELSIF COALESCE(v_req->>'parameter_type','')='weapon_exotic' AND v_weapon_prof<>'exotic' THEN
        RAISE EXCEPTION 'Escolha uma arma exótica.';
      END IF;
      IF COALESCE((v_req->>'weapon_proficiency_required')::boolean,false) THEN
        v_has_prof:=EXISTS(
          SELECT 1 FROM jsonb_array_elements_text(COALESCE(v_class.dados_tecnicos->'proficiencias'->'armas','[]'::jsonb)) AS prof(value)
           WHERE public.srd35_normalizar_parametro_talento(prof.value)=public.srd35_normalizar_parametro_talento(v_weapon_name)
              OR (public.srd35_normalizar_parametro_talento(prof.value)='armassimples' AND v_weapon_prof='simple')
              OR (public.srd35_normalizar_parametro_talento(prof.value)='todasasarmassimplesemarciais' AND v_weapon_prof IN ('simple','martial'))
        );
        IF NOT v_has_prof THEN RAISE EXCEPTION 'Guerreiro não é proficiente com %.',v_weapon_name; END IF;
      END IF;
    END IF;
    v_updated:=v_existing||jsonb_build_array(jsonb_build_object('id',v_feat_id,'parametro',NULLIF(v_param,''),'origem','class_bonus'));
    v_added:=array_append(v_added,v_feat_id);

  ELSIF v_class_key='monk' THEN
    v_entry:=p_talentos->0;
    IF jsonb_typeof(v_entry)<>'object' THEN RAISE EXCEPTION 'Escolha um talento bônus válido para Monge.'; END IF;
    v_feat_id:=NULLIF(BTRIM(v_entry->>'id'),'');
    IF v_feat_id NOT IN ('srd35_feat_improved_grapple','srd35_feat_stunning_fist') THEN
      RAISE EXCEPTION 'No nível 1, Monge escolhe Agarrar Aprimorado ou Ataque Atordoante.';
    END IF;
    IF v_feat_id=ANY(v_owned) THEN
      IF EXISTS (
        SELECT 1 FROM jsonb_array_elements(v_existing) AS saved(value)
         WHERE saved.value->>'id'=v_feat_id AND saved.value->>'origem'='class_bonus'
      ) THEN
        RETURN jsonb_build_object('character_id',v_character.id::text,'class_key',v_class_key,'added','[]'::jsonb,'talentos',v_existing,'already_applied',true);
      END IF;
      RAISE EXCEPTION 'O personagem já possui esse talento.';
    END IF;
    IF NOT ('srd35_feat_improved_unarmed_strike'=ANY(v_owned)) THEN
      v_updated:=v_existing||jsonb_build_array(jsonb_build_object('id','srd35_feat_improved_unarmed_strike','parametro',null,'origem','class_feature'));
      v_added:=array_append(v_added,'srd35_feat_improved_unarmed_strike');
    ELSE
      v_updated:=v_existing;
    END IF;
    v_updated:=v_updated||jsonb_build_array(jsonb_build_object('id',v_feat_id,'parametro',null,'origem','class_bonus'));
    v_added:=array_append(v_added,v_feat_id);

  ELSIF v_class_key='wizard' THEN
    IF jsonb_array_length(p_talentos)<>0 THEN RAISE EXCEPTION 'Mago recebe Escrever Pergaminho automaticamente; não escolha talento de classe aqui.'; END IF;
    IF NOT ('srd35_feat_scribe_scroll'=ANY(v_owned)) THEN
      v_updated:=v_existing||jsonb_build_array(jsonb_build_object('id','srd35_feat_scribe_scroll','parametro',null,'origem','class_feature'));
      v_added:=array_append(v_added,'srd35_feat_scribe_scroll');
    ELSE
      v_updated:=v_existing;
    END IF;
  ELSE
    IF jsonb_array_length(p_talentos)<>0 THEN RAISE EXCEPTION 'Esta classe não recebe uma escolha de talento bônus no nível 1.'; END IF;
    v_updated:=v_existing;
  END IF;

  UPDATE public.srd_character_sheets
     SET talentos=v_updated
   WHERE character_id=v_character.id;

  RETURN jsonb_build_object('character_id',v_character.id::text,'class_key',v_class_key,'added',to_jsonb(v_added),'talentos',v_updated);
END;
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
 
v_weapon_proficiency_type:=priv.srd_weapon_proficiency(v_weapon.detalhes,v_weapon_name);
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
  v_target->'monsterStats'->>'race_id',v_target->>'creature_type',
  (SELECT lower(sh.raca_id::text) FROM public.srd_character_sheets sh
    WHERE sh.character_id::text=CASE
      WHEN v_target->>'tipo'='player' THEN v_target->>'id'
      WHEN v_target->>'tipo'='npc' THEN v_target->>'sourceCharacterId'
      ELSE NULL END LIMIT 1)
));
IF v_sheet.raca_id='anao'
   AND v_target_traits ~ '(^|[^a-z])(orc|goblin|hobgoblin|bugbear|goblinoid(e)?)([^a-z]|$)' THEN
  v_racial_attack_bonus:=1;
ELSIF v_sheet.raca_id='gnomo'
   AND v_target_traits ~ '(^|[^a-z])(kobold|goblin|hobgoblin|bugbear|goblinoid(e)?)([^a-z]|$)' THEN
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
 
v_weapon_proficiency_type:=priv.srd_weapon_proficiency(v_weapon.detalhes,v_weapon_name);
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
  v_target->'monsterStats'->>'race_id',v_target->>'creature_type',
  (SELECT lower(sh.raca_id::text) FROM public.srd_character_sheets sh
    WHERE sh.character_id::text=CASE
      WHEN v_target->>'tipo'='player' THEN v_target->>'id'
      WHEN v_target->>'tipo'='npc' THEN v_target->>'sourceCharacterId'
      ELSE NULL END LIMIT 1)
));
IF v_sheet.raca_id='anao'
   AND v_target_traits ~ '(^|[^a-z])(orc|goblin|hobgoblin|bugbear|goblinoid(e)?)([^a-z]|$)' THEN
  v_racial_attack_bonus:=1;
ELSIF v_sheet.raca_id='gnomo'
   AND v_target_traits ~ '(^|[^a-z])(kobold|goblin|hobgoblin|bugbear|goblinoid(e)?)([^a-z]|$)' THEN
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