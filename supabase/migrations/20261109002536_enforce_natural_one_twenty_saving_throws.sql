
DO $migration$
DECLARE
  v_definition text;
  v_old text := '''success'',CASE WHEN v_dc IS NULL THEN NULL ELSE v_total>=v_dc END';
  v_new text := '''success'',CASE WHEN v_dc IS NULL THEN NULL WHEN p_d20=1 THEN false WHEN p_d20=20 THEN true ELSE v_total>=v_dc END,
    ''natural_1'',p_d20=1,
    ''natural_20'',p_d20=20';
BEGIN
  SELECT pg_get_functiondef(
    'public.srd_resolve_requested_saving_throw_srd(bigint,text,text,integer)'::regprocedure
  ) INTO v_definition;

  IF position(v_new in v_definition)>0 THEN
    RETURN;
  END IF;
  IF position(v_old in v_definition)=0 THEN
    RAISE EXCEPTION 'Trecho esperado não encontrado; migração interrompida sem alterar a função.';
  END IF;

  v_definition:=replace(v_definition,v_old,v_new);
  EXECUTE v_definition;
END
$migration$;
