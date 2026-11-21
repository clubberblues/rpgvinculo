DO $migration$
DECLARE
  v_definition text;
  v_old text;
BEGIN
  SELECT pg_get_functiondef('public.salvar_grimorio_srd(text,jsonb)'::regprocedure)
    INTO v_definition;
  v_old := $old$    IF false THEN
      SELECT count(*) INTO v_specialized_count
        FROM jsonb_array_elements(v_prepared_out) prep(value)
        JOIN public.srd_spells sp ON sp.id=prep.value->>'spell_id'
       WHERE (prep.value->>'slot_level')::integer=v_circle
         AND public._srd35_school_key(sp.escola)=v_specialization;
      IF v_specialized_count<1 THEN
        RAISE EXCEPTION 'O espaço adicional do círculo % exige uma magia da escola especializada (%).',v_circle,v_specialization;
      END IF;
    END IF;
$old$;
  IF position(v_old IN v_definition)=0 THEN
    RAISE EXCEPTION 'Bloco obsoleto de espaço de especialização não encontrado.';
  END IF;
  v_definition:=replace(v_definition,v_old,'');
  EXECUTE v_definition;
END
$migration$;
