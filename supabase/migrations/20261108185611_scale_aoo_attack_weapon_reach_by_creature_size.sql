DO $migration$
DECLARE
  v_definition text;
  v_old text;
BEGIN
  SELECT pg_get_functiondef(
    'public.srd_iniciar_ataque_oportunidade_srd(bigint,uuid,text,uuid,uuid,text,text)'::regprocedure
  ) INTO v_definition;

  v_old := '  v_distance integer;';
  IF position(v_old in v_definition)=0 THEN
    RAISE EXCEPTION 'Declaração de distância não encontrada; migration cancelada.';
  END IF;
  v_definition := replace(v_definition,v_old,
    v_old || E'\n  v_size_rank integer:=4;\n  v_base_reach integer:=5;\n  v_min_reach integer:=5;');

  v_old := '  v_character_id:=nullif(v_profile->>''character_id'','''')::bigint;';
  IF position(v_old in v_definition)=0 THEN
    RAISE EXCEPTION 'Perfil do reator não encontrado; migration cancelada.';
  END IF;
  v_definition := replace(v_definition,v_old,v_old || E'
  v_size_rank:=coalesce(nullif(v_profile->>''size_rank'','''')::integer,4);
  v_base_reach:=CASE
    WHEN v_size_rank>=8 THEN 30
    WHEN v_size_rank=7 THEN 20
    WHEN v_size_rank=6 THEN 15
    WHEN v_size_rank=5 THEN 10
    ELSE 5
  END;');

  v_old := '  v_reach:=coalesce(nullif(v_weapon.detalhes->>''reach_ft'','''')::integer,nullif(v_token->>''melee_reach_ft'','''')::integer,5);';
  IF position(v_old in v_definition)=0 THEN
    RAISE EXCEPTION 'Cálculo de alcance da arma não encontrado; migration cancelada.';
  END IF;
  v_definition := replace(v_definition,v_old,E'
  IF coalesce(nullif(v_weapon.detalhes->>''reach_ft'','''')::integer,5)>5 AND v_size_rank>4 THEN
    v_min_reach:=v_base_reach+5;
    v_reach:=coalesce(nullif(v_weapon.detalhes->>''reach_ft'','''')::integer,5)*greatest(1,v_base_reach/5);
  ELSE
    v_min_reach:=greatest(5,coalesce(nullif(v_weapon.detalhes->>''threat_min_ft'','''')::integer,5));
    v_reach:=greatest(v_base_reach,coalesce(nullif(v_weapon.detalhes->>''reach_ft'','''')::integer,
      nullif(v_token->>''melee_reach_ft'','''')::integer,5));
  END IF;');

  v_old := '  if v_distance < coalesce(nullif(v_weapon.detalhes->>''threat_min_ft'','''')::integer,5)'
    || E'\n     OR v_distance>v_reach then';
  IF position(v_old in v_definition)=0 THEN
    RAISE EXCEPTION 'Validação de distância ameaçada não encontrada; migration cancelada.';
  END IF;
  v_definition := replace(v_definition,v_old,
    '  if v_distance < v_min_reach' || E'\n     OR v_distance>v_reach then');

  EXECUTE v_definition;
END
$migration$;