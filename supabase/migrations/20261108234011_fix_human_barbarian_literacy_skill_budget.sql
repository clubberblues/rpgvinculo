DO $$
DECLARE
  v_definition text;
  v_old text := 'v_skill_budget := GREATEST(1,v_class.pericias_por_nivel+FLOOR((((v_attrs->>''INT'')::numeric-10)/2))::integer)*4;';
  v_new text := 'v_skill_budget := GREATEST(1,v_class.pericias_por_nivel+FLOOR((((v_attrs->>''INT'')::numeric-10)/2))::integer)*4 + CASE WHEN v_race.id=''humano'' THEN 4 ELSE 0 END;';
BEGIN
  SELECT pg_get_functiondef('public.criar_personagem_srd_completo(text,text,text,jsonb,jsonb,jsonb,jsonb)'::regprocedure)
    INTO v_definition;
  IF position(v_old IN v_definition)=0 THEN
    RAISE EXCEPTION 'Trecho esperado da validação de alfabetização não encontrado.';
  END IF;
  v_definition:=replace(v_definition,v_old,v_new);
  EXECUTE v_definition;
END $$;