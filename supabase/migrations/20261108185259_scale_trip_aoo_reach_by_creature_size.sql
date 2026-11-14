DO $migration$
DECLARE
  v_definition text;
  v_old text;
BEGIN
  SELECT pg_get_functiondef(
    'priv.srd_iniciar_derrubar_com_aoo_srd(bigint,text,text,boolean,boolean)'::regprocedure
  ) INTO v_definition;

  v_old := '  v_has_unarmed_threat boolean:=false;';
  IF position(v_old in v_definition)=0 THEN
    RAISE EXCEPTION 'Ponto de inserção das variáveis não encontrado; migration cancelada.';
  END IF;
  v_definition := replace(v_definition, v_old,
    v_old || E'\n  v_size_rank integer:=4;\n  v_base_reach integer:=5;');

  v_old := '  v_character_id:=NULLIF(v_profile->>''character_id'','''')::bigint;';
  IF position(v_old in v_definition)=0 THEN
    RAISE EXCEPTION 'Ponto de cálculo do perfil não encontrado; migration cancelada.';
  END IF;
  v_definition := replace(v_definition, v_old, v_old || E'
  v_size_rank:=coalesce(nullif(v_profile->>''size_rank'','''')::integer,4);
  v_base_reach:=CASE
    WHEN v_size_rank>=8 THEN 30
    WHEN v_size_rank=7 THEN 20
    WHEN v_size_rank=6 THEN 15
    WHEN v_size_rank=5 THEN 10
    ELSE 5
  END;');

  v_old := $old$
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
$old$;
  IF position(v_old in v_definition)=0 THEN
    RAISE EXCEPTION 'Consulta de armas para AOO não encontrada; migration cancelada.';
  END IF;
  v_definition := replace(v_definition, v_old, $new$
    SELECT coalesce(bool_or(
      coalesce((eq.detalhes->>'threatens_squares')::boolean,true)
      AND v_distance BETWEEN
        CASE
          WHEN coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5)>5 AND v_size_rank>4
            THEN v_base_reach+5
          ELSE greatest(5,coalesce(nullif(eq.detalhes->>'threat_min_ft','')::integer,5))
        END
        AND CASE
          WHEN coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5)>5 AND v_size_rank>4
            THEN coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5)*greatest(1,v_base_reach/5)
          ELSE greatest(coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5),v_base_reach)
        END
    ),false),
    coalesce(max(
      CASE
        WHEN coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5)>5 AND v_size_rank>4
          THEN coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5)*greatest(1,v_base_reach/5)
        ELSE greatest(coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5),v_base_reach)
      END
    ),v_base_reach)
      INTO v_has_threatening_weapon,v_reach
      FROM public.srd_character_weapon_instances wi
      JOIN public.srd_equipment eq ON eq.id=wi.equipment_id
      JOIN public.srd_character_equipment ce
        ON ce.character_id=wi.character_id AND ce.equipment_id=wi.equipment_id
       AND ce.equipado IS TRUE AND ce.hand_slot=wi.hand_slot
     WHERE wi.character_id=v_character_id::text AND wi.equipado IS TRUE
       AND wi.hand_slot IN ('main_hand','off_hand')
       AND coalesce(eq.detalhes->>'weapon_melee','true')<>'false';
$new$);

  v_old := '      IF v_has_unarmed_threat AND v_distance<=5 THEN';
  IF position(v_old in v_definition)=0 THEN
    RAISE EXCEPTION 'Validação de alcance desarmado não encontrada; migration cancelada.';
  END IF;
  v_definition := replace(v_definition, v_old,
    '      IF v_has_unarmed_threat AND v_distance BETWEEN 5 AND v_base_reach THEN');

  v_old := '    v_reach:=coalesce(nullif(v_defender->>''melee_reach_ft'','''')::integer,5);';
  IF position(v_old in v_definition)=0 THEN
    RAISE EXCEPTION 'Validação de alcance natural não encontrada; migration cancelada.';
  END IF;
  v_definition := replace(v_definition, v_old,
    '    v_reach:=greatest(v_base_reach,coalesce(nullif(v_defender->>''melee_reach_ft'','''')::integer,5));');

  EXECUTE v_definition;
END
$migration$;