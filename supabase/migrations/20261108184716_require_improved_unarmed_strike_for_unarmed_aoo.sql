CREATE OR REPLACE FUNCTION priv.srd_iniciar_derrubar_com_aoo_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_defender_firm_ground boolean DEFAULT false, p_trip_using_weapon boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_campaign public.campaigns%ROWTYPE;
  v_combat jsonb;
  v_order jsonb;
  v_actor jsonb;
  v_calc jsonb;
  v_attacker jsonb;
  v_defender jsonb;
  v_round integer;
  v_turn integer;
  v_pending_id uuid:=gen_random_uuid();
  v_distance integer;
  v_reach integer:=5;
  v_profile jsonb;
  v_character_id bigint;
  v_reach_match text[];
  v_reaction_status text:='waiting';
  v_trigger text;
  v_has_threatening_weapon boolean:=false;
  v_has_unarmed_threat boolean:=false;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode preparar a reação de Derrubar.';
  END IF;
  IF NULLIF(BTRIM(p_attacker_token_id),'') IS NULL OR NULLIF(BTRIM(p_defender_token_id),'') IS NULL
     OR BTRIM(p_attacker_token_id)=BTRIM(p_defender_token_id) THEN
    RAISE EXCEPTION 'Atacante e defensor precisam ser tokens diferentes.';
  END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND OR upper(coalesce(v_campaign.state,''))<>'COMBATE'
     OR coalesce(v_campaign.combat_data->>'active','false')<>'true' THEN
    RAISE EXCEPTION 'A iniciativa precisa estar ativa.';
  END IF;
  v_combat:=v_campaign.combat_data;
  IF coalesce(v_combat->'surprise'->>'phase','normal')='surprise_round' THEN
    RAISE EXCEPTION 'Derrubar não pode ser iniciado durante a rodada surpresa.';
  END IF;
  IF coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$' THEN
    RAISE EXCEPTION 'Turno atual inválido.';
  END IF;
  v_turn:=(v_combat->>'current_turn')::integer;
  v_order:=CASE WHEN jsonb_typeof(v_combat->'turn_order')='array' THEN v_combat->'turn_order' ELSE '[]'::jsonb END;
  v_actor:=v_order->v_turn;
  IF v_actor->>'id' IS DISTINCT FROM BTRIM(p_attacker_token_id) THEN
    RAISE EXCEPTION 'O atacante precisa estar no turno ativo.';
  END IF;
  IF EXISTS (SELECT 1 FROM priv.srd_aoo_pending_movements
    WHERE campaign_id=p_campaign_id AND status IN ('waiting_reactions','ready_to_commit')) THEN
    RAISE EXCEPTION 'Já existe outra reação de oportunidade pendente nesta campanha.';
  END IF;
  v_calc:=public.srd_consultar_modificadores_manobra_srd(
    p_campaign_id,p_attacker_token_id,p_defender_token_id,'trip',
    coalesce(p_defender_firm_ground,false),coalesce(p_trip_using_weapon,false)
  );
  IF v_calc->>'aoo_status'<>'provokes' THEN
    RAISE EXCEPTION 'Esta tentativa não exige a fila de reação de Derrubar; consulte os modificadores e resolva pelo fluxo normal.';
  END IF;

  SELECT t INTO v_attacker FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
   WHERE t->>'id'=BTRIM(p_attacker_token_id) OR t->>'key'=BTRIM(p_attacker_token_id) LIMIT 1;
  SELECT t INTO v_defender FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
   WHERE t->>'id'=BTRIM(p_defender_token_id) OR t->>'key'=BTRIM(p_defender_token_id) LIMIT 1;
  IF v_attacker IS NULL OR v_defender IS NULL THEN
    RAISE EXCEPTION 'Atacante ou defensor não está na cena.';
  END IF;
  IF coalesce(v_attacker->>'gridX','') !~ '^[0-9]{1,3}$' OR coalesce(v_attacker->>'gridY','') !~ '^[0-9]{1,3}$'
     OR coalesce(v_defender->>'gridX','') !~ '^[0-9]{1,3}$' OR coalesce(v_defender->>'gridY','') !~ '^[0-9]{1,3}$' THEN
    RAISE EXCEPTION 'A posição de um dos tokens não é válida para medir alcance.';
  END IF;

  v_distance:=priv.srd_grid_footprint_distance_ft(
    (v_defender->>'gridX')::integer,(v_defender->>'gridY')::integer,
    priv.srd_token_grid_footprint(p_campaign_id,p_defender_token_id),
    (v_attacker->>'gridX')::integer,(v_attacker->>'gridY')::integer,
    priv.srd_token_grid_footprint(p_campaign_id,p_attacker_token_id)
  );
  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,BTRIM(p_defender_token_id));
  v_character_id:=NULLIF(v_profile->>'character_id','')::bigint;

  IF v_character_id IS NOT NULL THEN
    SELECT coalesce(bool_or(
      coalesce((eq.detalhes->>'threatens_squares')::boolean,true)
      AND v_distance BETWEEN
        coalesce(nullif(eq.detalhes->>'threat_min_ft','')::integer,5)
        AND coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5)
    ),false),
    coalesce(max(nullif(eq.detalhes->>'reach_ft','')::integer),5)
      INTO v_has_threatening_weapon,v_reach
      FROM public.srd_character_weapon_instances wi
      JOIN public.srd_equipment eq ON eq.id=wi.equipment_id
      JOIN public.srd_character_equipment ce
        ON ce.character_id=wi.character_id AND ce.equipment_id=wi.equipment_id
       AND ce.equipado IS TRUE AND ce.hand_slot=wi.hand_slot
     WHERE wi.character_id=v_character_id::text AND wi.equipado IS TRUE
       AND wi.hand_slot IN ('main_hand','off_hand')
       AND coalesce(eq.detalhes->>'weapon_melee','true')<>'false';
    IF NOT v_has_threatening_weapon THEN
      SELECT coalesce(cl.class_key='monk',false) OR EXISTS (
        SELECT 1
        FROM jsonb_array_elements(
          CASE WHEN jsonb_typeof(sh.talentos)='array' THEN sh.talentos ELSE '[]'::jsonb END
        ) feat
        WHERE lower(concat_ws(' ',feat->>'id',feat->>'nome',feat->>'name')) ~
          '(ataque_desarmado_aprimorado|srd35_feat_improved_unarmed_strike|improved_unarmed_strike|ataque desarmado aprimorado|improved unarmed strike)'
      )
      INTO v_has_unarmed_threat
      FROM public.srd_character_sheets sh
      JOIN public.srd_classes cl ON cl.id=sh.classe_id
      WHERE sh.character_id=v_character_id;

      IF v_has_unarmed_threat AND v_distance<=5 THEN
        v_has_threatening_weapon:=true;
        v_reach:=5;
      ELSE
        v_reaction_status:='ineligible';
      END IF;
    END IF;
  ELSE
    v_reach:=coalesce(nullif(v_defender->>'melee_reach_ft','')::integer,5);
    v_reach_match:=regexp_match(
      coalesce(v_defender->'monsterStats'->>'espaco_alcance',v_defender->'monsterStats'->>'space_reach',''),
      '([0-9]+)[[:space:]]*ft[^0-9]*([0-9]+)','i'
    );
    IF v_reach_match IS NOT NULL THEN v_reach:=greatest(v_reach,v_reach_match[2]::integer); END IF;
    IF v_distance>v_reach THEN v_reaction_status:='ineligible'; END IF;
  END IF;

  v_round:=greatest(1,coalesce(nullif(v_combat->>'round','')::integer,1));
  v_trigger:='trip:'||v_pending_id::text;
  INSERT INTO priv.srd_aoo_pending_movements(
    pending_id,campaign_id,mover_token_id,movement_controller,destination_x,destination_y,
    origin_x,origin_y,combat_round,current_turn,turn_actor_id,threats,pending_reactions,
    status,created_by
  ) VALUES (
    v_pending_id,p_campaign_id,BTRIM(p_attacker_token_id),'gm',
    (v_attacker->>'gridX')::integer,(v_attacker->>'gridY')::integer,
    (v_attacker->>'gridX')::integer,(v_attacker->>'gridY')::integer,
    v_round,v_turn,BTRIM(p_attacker_token_id),
    jsonb_build_array(jsonb_build_object('maneuver_event','trip','defender_token_id',BTRIM(p_defender_token_id),
      'defender_firm_ground',coalesce(p_defender_firm_ground,false),'distance_ft',v_distance,'reach_ft',v_reach)),
    jsonb_build_array(jsonb_build_object('reactor_token_id',BTRIM(p_defender_token_id),'trigger_key',v_trigger,
      'status',v_reaction_status,'reason',CASE WHEN v_reaction_status='ineligible' THEN 'no_equipped_weapon_threatens_trigger_square' END,
      'threat',jsonb_build_object('last_threatened_step',0,'maneuver_event','trip'))),
    'waiting_reactions',auth.uid()
  );
  RETURN jsonb_build_object('pending',true,'pending_id',v_pending_id,'maneuver','trip',
    'attacker_token_id',BTRIM(p_attacker_token_id),'defender_token_id',BTRIM(p_defender_token_id),
    'reaction_status',v_reaction_status,'distance_ft',v_distance,'reach_ft',v_reach);
END;
$function$
;
REVOKE ALL ON FUNCTION priv.srd_iniciar_derrubar_com_aoo_srd(bigint,text,text,boolean,boolean) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION priv.srd_iniciar_derrubar_com_aoo_srd(bigint,text,text,boolean,boolean) TO authenticated;
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
  if v_race.id='anao' and v_target_traits ~ '(orc|goblin|hobgoblin|bugbear|goblinoid)' then v_racial_bonus:=1; end if;
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
$function$
;
REVOKE ALL ON FUNCTION public.srd_iniciar_ataque_oportunidade_desarmado_srd(bigint,uuid,text,uuid) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.srd_iniciar_ataque_oportunidade_desarmado_srd(bigint,uuid,text,uuid) TO authenticated;