DO $migration$
DECLARE
  v_definition text;
  v_old text;
  v_new text;
BEGIN
  SELECT pg_get_functiondef('public.salvar_grimorio_srd(text,jsonb)'::regprocedure)
    INTO v_definition;
  v_old := $old$IF v_score < 10+v_spell_level THEN RAISE EXCEPTION 'Atributo insuficiente para preparar a magia: %',v_spell_id; END IF;$old$;
  v_new := $new$IF v_score < 10+v_spell_level THEN RAISE EXCEPTION 'Atributo insuficiente para preparar a magia: %',v_spell_id; END IF;
    IF v_class='wizard' AND (
      coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_slot)::integer
                  FROM public.srd_spell_progressions WHERE class_key=v_class),0)=0
      OR v_score < 10+v_slot
    ) THEN
      RAISE EXCEPTION 'O círculo escolhido para preparar a magia não está acessível neste nível/atributo: %',v_spell_id;
    END IF;$new$;
  IF position(v_old IN v_definition)=0 THEN
    RAISE EXCEPTION 'Validação de atributo da preparação não encontrada; migration abortada.';
  END IF;
  v_definition:=replace(v_definition,v_old,v_new);
  EXECUTE v_definition;
END
$migration$;
