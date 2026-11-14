UPDATE public.srd_equipment
SET detalhes = coalesce(detalhes,'{}'::jsonb) || jsonb_build_object(
  'weapon_melee',true,
  'trip',true,
  'trip_attack',true,
  'special_maneuvers',jsonb_build_array('trip'),
  'reach_ft',CASE id
    WHEN 'srd35_equipment_martial_weapons_two_handed_melee_weapons_guisarme' THEN 10
    WHEN 'srd35_equipment_exotic_weapons_two_handed_melee_weapons_chain_spiked' THEN 10
    WHEN 'srd35_equipment_exotic_weapons_one_handed_melee_weapons_whip' THEN 15
    ELSE 5
  END,
  'maneuver_rules_source','SRD 3.5 weapon special rules'
)
WHERE id IN (
  'srd35_equipment_martial_weapons_one_handed_melee_weapons_flail',
  'srd35_equipment_martial_weapons_two_handed_melee_weapons_flail_heavy',
  'srd35_equipment_martial_weapons_two_handed_melee_weapons_guisarme',
  'srd35_equipment_exotic_weapons_two_handed_melee_weapons_chain_spiked',
  'srd35_equipment_exotic_weapons_one_handed_melee_weapons_whip'
);

CREATE OR REPLACE FUNCTION public.srd_consultar_modificadores_manobra_srd(
  p_campaign_id bigint,
  p_attacker_token_id text,
  p_defender_token_id text,
  p_maneuver text,
  p_defender_firm_ground boolean,
  p_trip_using_weapon boolean
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $function$
DECLARE
  v_result jsonb;
  v_maneuver text := lower(btrim(coalesce(p_maneuver,'')));
  v_campaign public.campaigns%ROWTYPE;
  v_attacker jsonb;
  v_defender jsonb;
  v_profile jsonb;
  v_character_id text;
  v_distance integer;
  v_reach integer := 5;
  v_trip_weapon_count integer := 0;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode consultar os modificadores de manobra.';
  END IF;

  v_result := public.srd_consultar_modificadores_manobra_srd(
    p_campaign_id,p_attacker_token_id,p_defender_token_id,
    p_maneuver,p_defender_firm_ground
  );

  IF v_maneuver='trip' THEN
    SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;

    SELECT t INTO v_attacker
      FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
     WHERE t->>'id'=btrim(p_attacker_token_id) OR t->>'key'=btrim(p_attacker_token_id)
     LIMIT 1;
    SELECT t INTO v_defender
      FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
     WHERE t->>'id'=btrim(p_defender_token_id) OR t->>'key'=btrim(p_defender_token_id)
     LIMIT 1;

    IF v_attacker IS NULL OR v_defender IS NULL THEN
      RAISE EXCEPTION 'Atacante ou defensor não está na cena.';
    END IF;
    IF coalesce(v_attacker->>'gridX','') !~ '^[0-9]{1,3}$'
       OR coalesce(v_attacker->>'gridY','') !~ '^[0-9]{1,3}$'
       OR coalesce(v_defender->>'gridX','') !~ '^[0-9]{1,3}$'
       OR coalesce(v_defender->>'gridY','') !~ '^[0-9]{1,3}$' THEN
      RAISE EXCEPTION 'Posição inválida para validar o alcance de Derrubar.';
    END IF;

    v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_attacker_token_id));
    v_character_id:=v_profile->>'character_id';

    IF coalesce(p_trip_using_weapon,false) THEN
      IF v_character_id IS NULL THEN
        RAISE EXCEPTION 'Não foi possível confirmar uma arma apropriada equipada para Derrubar.';
      END IF;
      SELECT count(*),
             coalesce(max(CASE WHEN eq.detalhes->>'reach_ft' ~ '^[0-9]{1,3}$'
                               THEN (eq.detalhes->>'reach_ft')::integer END),5)
        INTO v_trip_weapon_count,v_reach
        FROM public.srd_character_weapon_instances wi
        JOIN public.srd_equipment eq ON eq.id=wi.equipment_id
        JOIN public.srd_character_equipment ce
          ON ce.character_id=wi.character_id
         AND ce.equipment_id=wi.equipment_id
         AND ce.equipado IS TRUE
         AND ce.hand_slot=wi.hand_slot
       WHERE wi.character_id=v_character_id
         AND wi.equipado IS TRUE
         AND wi.hand_slot IN ('main_hand','off_hand')
         AND coalesce(eq.detalhes->>'weapon_melee','true')='true'
         AND coalesce((eq.detalhes->>'trip')::boolean,false) IS TRUE;
      IF v_trip_weapon_count=0 THEN
        RAISE EXCEPTION 'A arma equipada não possui a propriedade de Derrubar. Use uma arma apropriada ou tente desarmado.';
      END IF;
    END IF;

    v_distance:=priv.srd_grid_footprint_distance_ft(
      (v_attacker->>'gridX')::integer,(v_attacker->>'gridY')::integer,
      priv.srd_token_grid_footprint(p_campaign_id,p_attacker_token_id),
      (v_defender->>'gridX')::integer,(v_defender->>'gridY')::integer,
      priv.srd_token_grid_footprint(p_campaign_id,p_defender_token_id)
    );

    IF v_distance>v_reach THEN
      RAISE EXCEPTION 'Derrubar fora do alcance: distância de % pés; alcance da arma equipada de % pés.',v_distance,v_reach;
    END IF;

    IF coalesce(p_trip_using_weapon,false) THEN
      v_result:=v_result||jsonb_build_object(
        'trip_using_weapon',true,'trip_reach_ft',v_reach,
        'aoo_status','not_provoked_by_armed_trip',
        'aoo_source','none',
        'note','Arma equipada com propriedade de Derrubar confirmada pelo catálogo; a tentativa não provoca ataque de oportunidade.'
      );
    ELSE
      v_result:=v_result||jsonb_build_object('trip_using_weapon',false,'trip_reach_ft',5);
      IF coalesce((v_result->>'improved_trip')::boolean,false) THEN
        v_result:=v_result||jsonb_build_object(
          'aoo_status','suppressed_by_feat','aoo_source','defender',
          'note','Tentativa desarmada: Derrubar Aprimorado concede +4 no teste e impede o ataque de oportunidade.'
        );
      ELSE
        v_result:=v_result||jsonb_build_object(
          'aoo_status','provokes','aoo_source','defender',
          'note','Tentativa desarmada: o defensor pode realizar ataque de oportunidade antes do teste resistido.'
        );
      END IF;
    END IF;
  END IF;
  RETURN v_result;
END;
$function$;

REVOKE ALL ON FUNCTION public.srd_consultar_modificadores_manobra_srd(bigint,text,text,text,boolean,boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_consultar_modificadores_manobra_srd(bigint,text,text,text,boolean,boolean) TO authenticated;