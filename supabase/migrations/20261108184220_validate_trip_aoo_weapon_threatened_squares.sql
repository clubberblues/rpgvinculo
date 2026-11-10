UPDATE public.srd_equipment
SET detalhes=coalesce(detalhes,'{}'::jsonb)||jsonb_build_object(
  'threat_min_ft',CASE
    WHEN id IN ('srd35_equipment_martial_weapons_two_handed_melee_weapons_guisarme','srd35_equipment_exotic_weapons_two_handed_melee_weapons_chain_spiked') THEN 10
    ELSE 5 END,
  'threatens_squares',CASE
    WHEN id='srd35_equipment_exotic_weapons_one_handed_melee_weapons_whip' THEN false
    ELSE true END
)
WHERE id IN (
  'srd35_equipment_martial_weapons_one_handed_melee_weapons_flail',
  'srd35_equipment_martial_weapons_two_handed_melee_weapons_flail_heavy',
  'srd35_equipment_martial_weapons_two_handed_melee_weapons_guisarme',
  'srd35_equipment_exotic_weapons_two_handed_melee_weapons_chain_spiked',
  'srd35_equipment_exotic_weapons_one_handed_melee_weapons_whip'
);

CREATE OR REPLACE FUNCTION priv.srd_iniciar_derrubar_com_aoo_srd(
  p_campaign_id bigint,
  p_attacker_token_id text,
  p_defender_token_id text,
  p_defender_firm_ground boolean DEFAULT false,
  p_trip_using_weapon boolean DEFAULT false
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
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
      v_reaction_status:='ineligible';
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
$function$;

REVOKE ALL ON FUNCTION priv.srd_iniciar_derrubar_com_aoo_srd(bigint,text,text,boolean,boolean) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION priv.srd_iniciar_derrubar_com_aoo_srd(bigint,text,text,boolean,boolean) TO authenticated;