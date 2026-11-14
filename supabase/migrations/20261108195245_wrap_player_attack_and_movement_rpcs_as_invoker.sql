CREATE OR REPLACE FUNCTION priv.iniciar_sequencia_ataque_iterativo_srd_5_impl(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_user uuid := auth.uid();
  v_campaign public.campaigns%rowtype;
  v_combat jsonb;
  v_tokens jsonb;
  v_target_count integer;
  v_turn integer;
  v_round integer;
  v_bab integer;
  v_attacks integer;
  v_action jsonb;
  v_sequence public.srd_attack_sequences%rowtype;
begin
  if v_user is null then
    raise exception 'É necessário estar autenticado.';
  end if;
  if nullif(btrim(p_character_id), '') is null
     or nullif(btrim(p_target_token_id), '') is null
     or p_attack_type not in ('atk-corpo','atk-dist') then
    raise exception 'Dados da sequência de ataque inválidos.';
  end if;

  select c.* into v_campaign
  from public.campaigns c
  where c.id = p_campaign_id
  for update;
  if not found or upper(coalesce(v_campaign.state,'')) <> 'COMBATE' then
    raise exception 'A campanha não está em combate.';
  end if;

  if not exists (
    select 1
    from public.characters ch
    join public.members m on m.campaign_id = ch.campaign_id
      and m.user_id = ch.user_id and m.role = 'PLAYER'
    where ch.id::text = btrim(p_character_id)
      and ch.campaign_id = p_campaign_id
      and ch.user_id = v_user
  ) then
    raise exception 'A ficha atacante não pertence ao jogador nesta campanha.';
  end if;

  -- O alvo precisa ser um token real de NPC/monstro da própria campanha.
  v_tokens := case when jsonb_typeof(v_campaign.cba_data->'tokens') = 'array'
    then v_campaign.cba_data->'tokens' else '[]'::jsonb end;
  select count(*)::integer into v_target_count
  from jsonb_array_elements(v_tokens) t(token)
  where t.token->>'id' = btrim(p_target_token_id)
    and t.token->>'tipo' in ('npc','monstro');
  if v_target_count <> 1 then
    raise exception 'O alvo NPC/monstro não foi encontrado ou está duplicado nesta campanha.';
  end if;
  if not priv.srd_confusion_attack_target_allowed(p_campaign_id,'character',btrim(p_character_id),btrim(p_target_token_id)) then
    raise exception 'A condição Confuso impede este alvo. Siga o resultado D100 do turno e o alvo obrigatório registrado.';
  end if;

  -- Se a interface informar uma instância, ela deve pertencer à ficha e estar equipada.
  -- Não aceitamos UUID arbitrário nem item apenas presente no inventário.
  if p_weapon_instance_id is not null and not exists (
    select 1
    from public.srd_character_weapon_instances wi
    where wi.instance_id = p_weapon_instance_id
      and wi.character_id = btrim(p_character_id)
      and wi.equipado is true
      and wi.hand_slot is not null
  ) then
    raise exception 'A instância de arma não pertence à ficha ou não está equipada em uma mão válida.';
  end if;

  select coalesce(sum(
    case lower(coalesce(c.bab_progression,''))
      when 'good' then cl.class_level
      when 'bom' then cl.class_level
      when 'average' then floor(3 * cl.class_level / 4.0)::integer
      when 'medium' then floor(3 * cl.class_level / 4.0)::integer
      when 'medio' then floor(3 * cl.class_level / 4.0)::integer
      when 'poor' then floor(cl.class_level / 2.0)::integer
      when 'ruim' then floor(cl.class_level / 2.0)::integer
      else 0
    end
  ),0)::integer
  into v_bab
  from public.srd_character_class_levels cl
  join public.srd_classes c on c.id = cl.class_id
  where cl.character_id::text = btrim(p_character_id);

  if v_bab < 6 then
    raise exception 'Esta ficha ainda não possui BBA +6 para ataques iterativos.';
  end if;

  v_attacks := least(6, floor((v_bab - 1) / 5.0)::integer + 1);
  v_combat := coalesce(v_campaign.combat_data,'{}'::jsonb);
  if lower(coalesce(v_combat->>'active','false')) <> 'true'
     or coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$' then
    raise exception 'A iniciativa não está ativa ou o turno atual é inválido.';
  end if;
  v_turn := (v_combat->>'current_turn')::integer;
  v_round := case when coalesce(v_combat->>'round','') ~ '^[0-9]+$'
    then greatest(1,(v_combat->>'round')::integer) else 1 end;

  if exists (
    select 1 from public.srd_attack_sequences s
    where s.campaign_id = p_campaign_id
      and s.actor_character_id::text = btrim(p_character_id)
      and s.round_number = v_round and s.turn_index = v_turn
      and s.status = 'active'
  ) then
    raise exception 'Já existe uma sequência de ataques ativa para este turno.';
  end if;

  v_action := public.consumir_acao_rodada_completa_srd(
    p_campaign_id, btrim(p_character_id), 'character'
  );

  insert into public.srd_attack_sequences(
    campaign_id, actor_character_id, target_token_id, attack_type,
    weapon_instance_id, round_number, turn_index, base_attack_bonus,
    attacks_total, created_by
  ) values (
    p_campaign_id, btrim(p_character_id)::bigint, btrim(p_target_token_id), p_attack_type,
    p_weapon_instance_id, v_round, v_turn, v_bab, v_attacks, v_user
  )
  returning * into v_sequence;

  return jsonb_build_object(
    'sequence_id', v_sequence.id,
    'campaign_id', v_sequence.campaign_id,
    'actor_character_id', v_sequence.actor_character_id,
    'target_token_id', v_sequence.target_token_id,
    'attack_type', v_sequence.attack_type,
    'round', v_sequence.round_number,
    'turn_index', v_sequence.turn_index,
    'base_attack_bonus', v_sequence.base_attack_bonus,
    'attacks_total', v_sequence.attacks_total,
    'next_attack_index', v_sequence.next_attack_index,
    'action_economy', v_action->'action_economy'
  );
end;
$function$
;
CREATE OR REPLACE FUNCTION public.iniciar_sequencia_ataque_iterativo_srd(p_campaign_id bigint,p_character_id text,p_target_token_id text,p_attack_type text,p_weapon_instance_id uuid DEFAULT NULL)
RETURNS jsonb LANGUAGE sql SECURITY INVOKER
SET search_path=pg_catalog,public,priv,pg_temp
AS $wrapper$ SELECT priv.iniciar_sequencia_ataque_iterativo_srd_5_impl(p_campaign_id,p_character_id,p_target_token_id,p_attack_type,p_weapon_instance_id); $wrapper$;
REVOKE ALL ON FUNCTION priv.iniciar_sequencia_ataque_iterativo_srd_5_impl(bigint,text,text,text,uuid) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION priv.iniciar_sequencia_ataque_iterativo_srd_5_impl(bigint,text,text,text,uuid) TO authenticated;
REVOKE ALL ON FUNCTION public.iniciar_sequencia_ataque_iterativo_srd(bigint,text,text,text,uuid) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.iniciar_sequencia_ataque_iterativo_srd(bigint,text,text,text,uuid) TO authenticated;
CREATE OR REPLACE FUNCTION priv.iniciar_sequencia_ataque_iterativo_srd_7_impl(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_instance public.srd_character_weapon_instances%ROWTYPE;
  v_equipment public.srd_equipment%ROWTYPE;
  v_is_double boolean := false;
  v_result jsonb;
BEGIN
  IF p_weapon_instance_id IS NULL THEN
    RAISE EXCEPTION 'Selecione uma instância de arma equipada.';
  END IF;
  IF p_weapon_hand_slot IS NULL OR p_weapon_hand_slot NOT IN ('main_hand','off_hand') THEN
    RAISE EXCEPTION 'Mão da arma inválida.';
  END IF;

  SELECT * INTO v_instance
  FROM public.srd_character_weapon_instances
  WHERE instance_id = p_weapon_instance_id
    AND character_id = btrim(p_character_id)
    AND equipado IS TRUE
    AND hand_slot = p_weapon_hand_slot
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'A instância não está equipada na mão informada.';
  END IF;

  SELECT * INTO v_equipment
  FROM public.srd_equipment
  WHERE id = v_instance.equipment_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Equipamento da instância não encontrado no catálogo.';
  END IF;

  v_is_double := COALESCE((v_equipment.detalhes->>'weapon_double')::boolean, false);

  IF v_is_double AND (p_weapon_end IS NULL OR p_weapon_end NOT IN ('main','off')) THEN
    RAISE EXCEPTION 'Escolha a extremidade principal ou secundária da arma dupla.';
  ELSIF NOT v_is_double AND p_weapon_end IS NOT NULL THEN
    RAISE EXCEPTION 'Arma comum não possui seleção de extremidade.';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.srd_character_equipment ce
    WHERE ce.character_id = btrim(p_character_id)
      AND ce.equipment_id = v_instance.equipment_id
      AND ce.equipado IS TRUE
      AND ce.hand_slot = v_instance.hand_slot
  ) THEN
    RAISE EXCEPTION 'Inventário e instância de arma estão inconsistentes.';
  END IF;

  v_result := public.iniciar_sequencia_ataque_iterativo_srd(
    p_campaign_id, p_character_id, p_target_token_id,
    p_attack_type, p_weapon_instance_id
  );

  UPDATE public.srd_attack_sequences
  SET weapon_hand_slot = p_weapon_hand_slot,
      weapon_end = p_weapon_end
  WHERE id = (v_result->>'sequence_id')::uuid;

  RETURN v_result || jsonb_build_object(
    'weapon_instance_id', p_weapon_instance_id,
    'weapon_hand_slot', p_weapon_hand_slot,
    'weapon_end', p_weapon_end,
    'weapon_equipment_id', v_instance.equipment_id,
    'weapon_is_double', v_is_double
  );
END;
$function$
;
CREATE OR REPLACE FUNCTION public.iniciar_sequencia_ataque_iterativo_srd(p_campaign_id bigint,p_character_id text,p_target_token_id text,p_attack_type text,p_weapon_instance_id uuid,p_weapon_hand_slot text,p_weapon_end text)
RETURNS jsonb LANGUAGE sql SECURITY INVOKER
SET search_path=pg_catalog,public,priv,pg_temp
AS $wrapper$ SELECT priv.iniciar_sequencia_ataque_iterativo_srd_7_impl(p_campaign_id,p_character_id,p_target_token_id,p_attack_type,p_weapon_instance_id,p_weapon_hand_slot,p_weapon_end); $wrapper$;
REVOKE ALL ON FUNCTION priv.iniciar_sequencia_ataque_iterativo_srd_7_impl(bigint,text,text,text,uuid,text,text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION priv.iniciar_sequencia_ataque_iterativo_srd_7_impl(bigint,text,text,text,uuid,text,text) TO authenticated;
REVOKE ALL ON FUNCTION public.iniciar_sequencia_ataque_iterativo_srd(bigint,text,text,text,uuid,text,text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.iniciar_sequencia_ataque_iterativo_srd(bigint,text,text,text,uuid,text,text) TO authenticated;
CREATE OR REPLACE FUNCTION priv.iniciar_sequencia_ataque_iterativo_srd_8_impl(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text, p_power_attack_penalty integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_sheet public.srd_character_sheets%rowtype;
  v_weapon public.srd_equipment%rowtype;
  v_result jsonb;
  v_penalty integer:=coalesce(p_power_attack_penalty,0);
  v_bab integer;
  v_level integer;
begin
  if auth.uid() is null then raise exception 'É necessário estar autenticado.'; end if;
  if v_penalty<0 or v_penalty>30 then raise exception 'Penalidade de Ataque Poderoso inválida.'; end if;
  select sh.* into v_sheet from public.srd_character_sheets sh
  where sh.character_id::text=btrim(p_character_id);
  if not found then raise exception 'Ficha SRD não encontrada.'; end if;
  if v_penalty>0 then
    if p_attack_type<>'atk-corpo' then raise exception 'Ataque Poderoso só se aplica a ataques corpo a corpo.'; end if;
    if coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)<13 then
      raise exception 'Ataque Poderoso exige Força 13 ou superior.';
    end if;
    if not exists(select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f where f->>'id'='ataque_poderoso') then
      raise exception 'A ficha não possui o talento Ataque Poderoso.';
    end if;
    select eq.* into v_weapon from public.srd_character_weapon_instances wi
      join public.srd_equipment eq on eq.id=wi.equipment_id
      where wi.instance_id=p_weapon_instance_id and wi.character_id=btrim(p_character_id)
        and wi.equipado is true and wi.hand_slot=p_weapon_hand_slot;
    if not found then raise exception 'Arma não está equipada na mão selecionada.'; end if;
    if coalesce((v_weapon.detalhes->>'weapon_light')::boolean,false) then
      raise exception 'Ataque Poderoso não pode ser usado com arma leve.';
    end if;
    select coalesce(sum(case lower(coalesce(cl.bab_progression,''))
      when 'good' then lv.class_level when 'bom' then lv.class_level
      when 'average' then floor(3*lv.class_level/4.0)::integer
      when 'medium' then floor(3*lv.class_level/4.0)::integer
      when 'medio' then floor(3*lv.class_level/4.0)::integer
      when 'poor' then floor(lv.class_level/2.0)::integer
      when 'ruim' then floor(lv.class_level/2.0)::integer else 0 end),0)::integer
      into v_bab from public.srd_character_class_levels lv
      join public.srd_classes cl on cl.id=lv.class_id
      where lv.character_id=v_sheet.character_id;
    if not exists(select 1 from public.srd_character_class_levels lv where lv.character_id=v_sheet.character_id) then
      select greatest(1,coalesce(v_sheet.nivel,1)) into v_level;
      select case lower(coalesce(cl.bab_progression,''))
        when 'good' then v_level when 'bom' then v_level
        when 'average' then floor(3*v_level/4.0)::integer
        when 'medium' then floor(3*v_level/4.0)::integer
        when 'medio' then floor(3*v_level/4.0)::integer
        when 'poor' then floor(v_level/2.0)::integer
        when 'ruim' then floor(v_level/2.0)::integer else 0 end
      into v_bab from public.srd_classes cl where cl.id=v_sheet.classe_id;
    end if;
    if v_penalty>coalesce(v_bab,0) then raise exception 'Penalidade excede o BBA atual.'; end if;
  end if;
  v_result:=public.iniciar_sequencia_ataque_iterativo_srd(
    p_campaign_id,p_character_id,p_target_token_id,p_attack_type,
    p_weapon_instance_id,p_weapon_hand_slot,p_weapon_end
  );
  update public.srd_attack_sequences set power_attack_penalty=v_penalty
    where id=(v_result->>'sequence_id')::uuid;
  return v_result||jsonb_build_object('power_attack_penalty',v_penalty);
end;
$function$
;
CREATE OR REPLACE FUNCTION public.iniciar_sequencia_ataque_iterativo_srd(p_campaign_id bigint,p_character_id text,p_target_token_id text,p_attack_type text,p_weapon_instance_id uuid,p_weapon_hand_slot text,p_weapon_end text,p_power_attack_penalty integer)
RETURNS jsonb LANGUAGE sql SECURITY INVOKER
SET search_path=pg_catalog,public,priv,pg_temp
AS $wrapper$ SELECT priv.iniciar_sequencia_ataque_iterativo_srd_8_impl(p_campaign_id,p_character_id,p_target_token_id,p_attack_type,p_weapon_instance_id,p_weapon_hand_slot,p_weapon_end,p_power_attack_penalty); $wrapper$;
REVOKE ALL ON FUNCTION priv.iniciar_sequencia_ataque_iterativo_srd_8_impl(bigint,text,text,text,uuid,text,text,integer) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION priv.iniciar_sequencia_ataque_iterativo_srd_8_impl(bigint,text,text,text,uuid,text,text,integer) TO authenticated;
REVOKE ALL ON FUNCTION public.iniciar_sequencia_ataque_iterativo_srd(bigint,text,text,text,uuid,text,text,integer) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.iniciar_sequencia_ataque_iterativo_srd(bigint,text,text,text,uuid,text,text,integer) TO authenticated;
CREATE OR REPLACE FUNCTION priv.mover_token_player_cba_impl(p_campaign_id bigint, p_character_id text, p_grid_x integer, p_grid_y integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_combat JSONB;
  v_campaign_state TEXT;
  v_scene JSONB;
  v_tokens JSONB;
  v_order JSONB;
  v_usage JSONB;
  v_entry JSONB;
  v_current_id TEXT;
  v_round INTEGER;
  v_current_turn INTEGER;
  v_token_index BIGINT;
  v_token_count INTEGER;
  v_character_id TEXT;
  v_race_id TEXT;
  v_mover_size_text TEXT;
  v_token_size INTEGER := 1;
  v_raw_speed TEXT;
  v_speed_m NUMERIC;
  v_used_squares INTEGER := 0;
  v_move_squares INTEGER;
  v_total_squares INTEGER;
  v_used_diagonal_steps INTEGER := 0;
  v_segment_diagonal_steps INTEGER := 0;
  v_diagonal_steps INTEGER := 0;
  v_diagonal_extra INTEGER := 0;
  v_remaining_m NUMERIC;
  v_old_x INTEGER;
  v_old_y INTEGER;
  v_active BOOLEAN;
  v_action_state JSONB;
  v_by_character JSONB;
  v_character_actions JSONB;
  v_new_token JSONB;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF NULLIF(BTRIM(p_character_id), '') IS NULL THEN
    RAISE EXCEPTION 'O identificador do personagem é obrigatório.';
  END IF;
  IF p_grid_x IS NULL OR p_grid_y IS NULL OR p_grid_x < 0 OR p_grid_y < 0
     OR p_grid_x > 199 OR p_grid_y > 199 THEN
    RAISE EXCEPTION 'A posição deve estar na grade, com coordenadas inteiras entre 0 e 199.';
  END IF;

  SELECT c.cba_data, c.combat_data, c.state INTO v_scene, v_combat, v_campaign_state
  FROM public.campaigns AS c
  WHERE c.id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  v_combat := COALESCE(v_combat,'{}'::JSONB);
  v_active := lower(COALESCE(v_combat->>'active', 'false')) = 'true';
  IF v_active THEN
    v_order := CASE WHEN jsonb_typeof(v_combat->'turn_order') = 'array'
                    THEN v_combat->'turn_order' ELSE '[]'::JSONB END;
    IF jsonb_array_length(v_order) = 0 THEN RAISE EXCEPTION 'A ordem de iniciativa está vazia.'; END IF;
    v_current_turn := CASE WHEN COALESCE(v_combat->>'current_turn', '') ~ '^[0-9]+$'
                           THEN (v_combat->>'current_turn')::INTEGER ELSE 0 END;
    IF v_current_turn >= jsonb_array_length(v_order) THEN RAISE EXCEPTION 'O turno atual da iniciativa é inválido.'; END IF;
    v_entry := v_order->v_current_turn;
    PERFORM priv.srd_validate_surprise_action(p_campaign_id,BTRIM(p_character_id),'movimento');
    v_current_id := v_entry->>'id';
    IF COALESCE(lower(v_entry->>'is_monster'), 'false') = 'true' THEN RAISE EXCEPTION 'O turno atual pertence a uma criatura controlada pelo Mestre.'; END IF;
    IF v_current_id IS DISTINCT FROM BTRIM(p_character_id) THEN RAISE EXCEPTION 'Somente o personagem cujo turno está ativo pode mover seu token.'; END IF;
  ELSIF UPPER(COALESCE(v_campaign_state,''))='COMBATE' THEN
    RAISE EXCEPTION 'Aguarde a ativação da iniciativa para mover durante o combate.';
  END IF;

  SELECT c.id::TEXT, s.raca_id::TEXT INTO v_character_id, v_race_id
  FROM public.characters AS c
  JOIN public.srd_character_sheets AS s ON s.character_id::TEXT = c.id::TEXT
  WHERE c.id::TEXT = BTRIM(p_character_id)
    AND c.campaign_id = p_campaign_id
    AND c.user_id = auth.uid()
  FOR UPDATE OF c, s;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'O personagem não pertence à sua conta ou não tem ficha SRD nesta campanha.';
  END IF;

  SELECT to_jsonb(r)->>'deslocamento', r.tamanho::TEXT INTO v_raw_speed, v_mover_size_text
  FROM public.srd_races AS r
  WHERE r.id::TEXT = v_race_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'A raça da ficha não foi encontrada.';
  END IF;
  IF v_raw_speed IS NULL THEN
    v_speed_m := 9;
  ELSIF v_raw_speed ~ '^[0-9]+([.][0-9]+)?$' THEN
    v_speed_m := v_raw_speed::NUMERIC;
  ELSE
    RAISE EXCEPTION 'O deslocamento racial não possui um valor numérico válido em metros.';
  END IF;
  IF priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_move') OR (priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_actions') AND NOT priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'flee')) THEN RAISE EXCEPTION 'A condição atual impede movimentação.'; END IF;
  v_speed_m := public.srd35_deslocamento_personagem(v_character_id,v_speed_m);
  v_speed_m:=v_speed_m*priv.srd_condition_speed_multiplier(p_campaign_id,'character',v_character_id);
  v_speed_m:=LEAST(v_speed_m*2,v_speed_m+priv.srd_effective_modifier(p_campaign_id,'character',v_character_id,'speed_m'));
  IF v_speed_m < 0 THEN
    RAISE EXCEPTION 'O deslocamento racial não pode ser negativo.';
  END IF;

  v_tokens := CASE WHEN jsonb_typeof(v_scene->'tokens') = 'array'
                   THEN v_scene->'tokens' ELSE '[]'::JSONB END;
  SELECT count(*)::INTEGER, min(q.ordinality)
  INTO v_token_count, v_token_index
  FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS q(token, ordinality)
  WHERE q.token->>'id' = v_character_id AND q.token->>'tipo' = 'player';
  IF v_token_count = 0 THEN
    RAISE EXCEPTION 'Não existe token player publicado para este personagem.';
  ELSIF v_token_count > 1 THEN
    RAISE EXCEPTION 'Há mais de um token player para este personagem; peça ao Mestre para corrigir a cena.';
  END IF;
  v_entry := v_tokens->(v_token_index::INTEGER - 1);
  IF COALESCE(v_entry->>'gridX', '') !~ '^[0-9]+$'
     OR COALESCE(v_entry->>'gridY', '') !~ '^[0-9]+$' THEN
    RAISE EXCEPTION 'A posição atual do token é inválida.';
  END IF;
  v_old_x := (v_entry->>'gridX')::INTEGER;
  v_old_y := (v_entry->>'gridY')::INTEGER;
  IF NOT priv.srd_confusion_flee_destination_allowed(p_campaign_id,v_character_id,p_grid_x,p_grid_y) THEN
    RAISE EXCEPTION 'Confuso: a movimentação deve aumentar a distância em relação ao conjurador.';
  END IF;
  IF v_old_x < 0 OR v_old_y < 0 OR v_old_x > 199 OR v_old_y > 199 THEN
    RAISE EXCEPTION 'A posição atual do token está fora do domínio válido da grade.';
  END IF;
  v_token_size := CASE
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'colossal%' THEN 5
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'gargantuan%'
      OR public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'imenso%' THEN 4
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'huge%'
      OR public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'enorme%' THEN 3
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'large%'
      OR public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'grande%' THEN 2
    ELSE 1 END;

  IF EXISTS (
    SELECT 1
      FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS q(token, ordinality)
      LEFT JOIN public.characters other_character
        ON other_character.id::TEXT=q.token->>'id' AND other_character.campaign_id=p_campaign_id
      LEFT JOIN public.srd_character_sheets other_sheet
        ON other_sheet.character_id=other_character.id
      LEFT JOIN public.srd_races other_race
        ON other_race.id::TEXT=other_sheet.raca_id::TEXT
      CROSS JOIN LATERAL (
        SELECT
          CASE
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'colossal%' THEN 5
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'gargantuan%'
              OR public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'imenso%' THEN 4
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'huge%'
              OR public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'enorme%' THEN 3
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'large%'
              OR public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'grande%' THEN 2
            ELSE 1
          END AS footprint,
          CASE WHEN COALESCE(q.token->>'gridX','') ~ '^[0-9]{1,3}$' THEN (q.token->>'gridX')::INTEGER ELSE -1 END AS gx,
          CASE WHEN COALESCE(q.token->>'gridY','') ~ '^[0-9]{1,3}$' THEN (q.token->>'gridY')::INTEGER ELSE -1 END AS gy
      ) AS other_space
     WHERE q.ordinality<>v_token_index AND other_space.gx>=0 AND other_space.gy>=0
       AND p_grid_x < other_space.gx+other_space.footprint AND p_grid_x+v_token_size > other_space.gx
       AND p_grid_y < other_space.gy+other_space.footprint AND p_grid_y+v_token_size > other_space.gy
  ) THEN
    RAISE EXCEPTION 'O espaço de destino está ocupado pela área de outro token.';
  END IF;

-- O custo do deslocamento é calculado após recuperar a sequência diagonal da rodada.
  IF v_active THEN
    v_round := CASE WHEN COALESCE(v_combat->>'round', '') ~ '^[0-9]+$'
                    THEN GREATEST(1, (v_combat->>'round')::INTEGER) ELSE 1 END;
    v_usage := CASE WHEN jsonb_typeof(v_combat->'movement_usage') = 'object'
                    THEN v_combat->'movement_usage' ELSE '{}'::JSONB END;
    IF v_usage->>'character_id' = v_character_id
       AND v_usage->>'round' = v_round::TEXT
       AND v_usage->>'current_turn' = v_current_turn::TEXT
       AND COALESCE(v_usage->>'moved_squares', '') ~ '^[0-9]+$' THEN
      v_used_squares := (v_usage->>'moved_squares')::INTEGER;
      IF COALESCE(v_usage->>'diagonal_steps','') ~ '^[0-9]+$' THEN
        v_used_diagonal_steps := (v_usage->>'diagonal_steps')::INTEGER;
      END IF;
    END IF;
    -- D&D 3.5: diagonais alternam custo de 1 e 2 quadrados (5 ft / 10 ft).
    v_segment_diagonal_steps := LEAST(ABS(p_grid_x - v_old_x), ABS(p_grid_y - v_old_y));
    v_diagonal_extra := FLOOR((v_used_diagonal_steps + v_segment_diagonal_steps) / 2.0)::INTEGER
      - FLOOR(v_used_diagonal_steps / 2.0)::INTEGER;
    v_move_squares := GREATEST(ABS(p_grid_x - v_old_x), ABS(p_grid_y - v_old_y)) + v_diagonal_extra;
    v_diagonal_steps := v_used_diagonal_steps + v_segment_diagonal_steps;
    v_total_squares := v_used_squares + v_move_squares;
    v_remaining_m := GREATEST(0::NUMERIC, v_speed_m - (v_total_squares * 1.5));
    IF v_total_squares * 1.5 > v_speed_m THEN
      RAISE EXCEPTION 'Movimento excede o deslocamento restante deste turno (%.1f m restantes).',
        GREATEST(0::NUMERIC, v_speed_m - (v_used_squares * 1.5));
    END IF;
  ELSE
    v_remaining_m := NULL;
  END IF;

  IF v_active THEN
    v_action_state := v_combat->'action_economy';
    IF jsonb_typeof(v_action_state)='object'
       AND COALESCE(v_action_state->>'round','')=v_round::TEXT
       AND jsonb_typeof(v_action_state->'by_character')='object' THEN
      v_by_character := v_action_state->'by_character';
    ELSE v_by_character := '{}'::JSONB; END IF;
    v_character_actions := CASE WHEN jsonb_typeof(v_by_character->v_character_id)='object'
      THEN v_by_character->v_character_id ELSE '{}'::JSONB END;
    IF COALESCE(v_character_actions->>'movimento','false')='true' AND v_used_squares=0 THEN
      RAISE EXCEPTION 'A ação de movimento deste personagem já foi usada neste turno.';
    END IF;
    IF priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'one_move_or_standard')
       AND COALESCE(v_character_actions->>'padrao','false')='true' THEN
      RAISE EXCEPTION 'A condição permite apenas uma ação padrão ou de movimento por rodada.';
    END IF;
    v_character_actions := v_character_actions || jsonb_build_object('movimento',TRUE);
    v_by_character := jsonb_set(v_by_character,ARRAY[v_character_id],v_character_actions,TRUE);
    v_action_state := jsonb_build_object('round',v_round,'by_character',v_by_character);
    v_combat := v_combat || jsonb_build_object('action_economy',v_action_state);
  END IF;

  v_new_token := v_entry || jsonb_build_object('gridX', p_grid_x, 'gridY', p_grid_y);
  v_scene := COALESCE(v_scene, '{}'::JSONB) || jsonb_build_object(
    'tokens', jsonb_set(v_tokens, ARRAY[(v_token_index - 1)::TEXT], v_new_token, FALSE)
  );
  IF v_active THEN
    v_combat := v_combat || jsonb_build_object(
      'movement_usage', jsonb_build_object(
        'round', v_round,
        'current_turn', v_current_turn,
        'character_id', v_character_id,
        'moved_squares', v_total_squares,
        'diagonal_steps', v_diagonal_steps
      )
    );
  END IF;
  UPDATE public.campaigns
  SET cba_data = v_scene, combat_data = v_combat
  WHERE id = p_campaign_id;
  RETURN jsonb_build_object(
    'cba_data', v_scene,
    'movement_remaining_m', v_remaining_m
  );
END;
$function$
;
CREATE OR REPLACE FUNCTION public.mover_token_player_cba(p_campaign_id bigint,p_character_id text,p_grid_x integer,p_grid_y integer)
RETURNS jsonb LANGUAGE sql SECURITY INVOKER
SET search_path=pg_catalog,public,priv,pg_temp
AS $wrapper$ SELECT priv.mover_token_player_cba_impl(p_campaign_id,p_character_id,p_grid_x,p_grid_y); $wrapper$;
REVOKE ALL ON FUNCTION priv.mover_token_player_cba_impl(bigint,text,integer,integer) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION priv.mover_token_player_cba_impl(bigint,text,integer,integer) TO authenticated;
REVOKE ALL ON FUNCTION public.mover_token_player_cba(bigint,text,integer,integer) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.mover_token_player_cba(bigint,text,integer,integer) TO authenticated;
