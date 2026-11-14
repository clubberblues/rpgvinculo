
DO $patch$
DECLARE v_def text;
BEGIN
  v_def:=pg_get_functiondef('priv.srd_iniciar_derrubar_com_aoo_srd(bigint,text,text,boolean,boolean)'::regprocedure);
  v_def:=replace(v_def,
    '  v_reach integer;',
    '  v_reach integer; v_profile jsonb; v_character_id bigint; v_reach_match text[];'
  );
  v_def:=replace(v_def,
    '  v_reach:=coalesce(nullif(v_defender->>''melee_reach_ft'','''')::integer,5);' || E'\n' ||
    '  -- O alcance real é validado depois da escolha da arma no motor de AOO; não presumir alcance natural de 1,5 m.',
    '  v_reach:=coalesce(nullif(v_defender->>''melee_reach_ft'','''')::integer,5);' || E'\n' ||
    '  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,BTRIM(p_defender_token_id));' || E'\n' ||
    '  v_character_id:=NULLIF(v_profile->>''character_id'','''')::bigint;' || E'\n' ||
    '  IF v_character_id IS NOT NULL THEN' || E'\n' ||
    '    SELECT greatest(v_reach,coalesce(max(CASE WHEN eq.detalhes->>''reach_ft'' ~ ''^[0-9]{1,3}$'' THEN (eq.detalhes->>''reach_ft'')::integer END),v_reach))' || E'\n' ||
    '      INTO v_reach FROM public.srd_character_weapon_instances wi' || E'\n' ||
    '      JOIN public.srd_equipment eq ON eq.id=wi.equipment_id' || E'\n' ||
    '      JOIN public.srd_character_equipment ce ON ce.character_id=wi.character_id AND ce.equipment_id=wi.equipment_id AND ce.equipado IS TRUE AND ce.hand_slot=wi.hand_slot' || E'\n' ||
    '     WHERE wi.character_id=v_character_id::text AND wi.equipado IS TRUE AND wi.hand_slot IN (''main_hand'',''off_hand'') AND coalesce(eq.detalhes->>''weapon_melee'',''true'')<>''false'';' || E'\n' ||
    '  ELSE' || E'\n' ||
    '    v_reach_match:=regexp_match(coalesce(v_defender->''monsterStats''->>''espaco_alcance'',v_defender->''monsterStats''->>''space_reach'',''''),''([0-9]+)[[:space:]]*ft\\.?/[[:space:]]*([0-9]+)'',''i'');' || E'\n' ||
    '    IF v_reach_match IS NOT NULL THEN v_reach:=greatest(v_reach,v_reach_match[2]::integer); END IF;' || E'\n' ||
    '  END IF;' || E'\n' ||
    '  IF v_distance>v_reach THEN v_reaction_status:=''ineligible''; END IF;'
  );
  IF position('v_character_id:=NULLIF(v_profile' in v_def)=0 OR position('IF v_distance>v_reach THEN v_reaction_status' in v_def)=0 THEN
    RAISE EXCEPTION 'Falha ao aplicar validação de alcance de arma para AOO de Derrubar.';
  END IF;
  EXECUTE v_def;
END;
$patch$;
