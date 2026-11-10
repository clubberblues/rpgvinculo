
DO $migration$
DECLARE
  v_definition text;
  v_old text := 'IF v_total>=v_pending.save_dc THEN';
  v_new text := 'IF (p_d20=20 OR (p_d20<>1 AND v_total>=v_pending.save_dc)) THEN';
BEGIN
  SELECT pg_get_functiondef(
    'public.srd_resolve_pending_spell_save(uuid,integer)'::regprocedure
  ) INTO v_definition;

  IF position(v_new in v_definition)>0 AND position(v_old in v_definition)=0 THEN
    RETURN;
  END IF;
  IF position(v_old in v_definition)=0 THEN
    RAISE EXCEPTION 'Trecho esperado não encontrado; migração interrompida sem alterar a função.';
  END IF;

  v_definition:=replace(v_definition,v_old,v_new);
  EXECUTE v_definition;
END
$migration$;
