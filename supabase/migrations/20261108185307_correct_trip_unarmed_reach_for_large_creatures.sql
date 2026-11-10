DO $migration$
DECLARE v_definition text;
BEGIN
  SELECT pg_get_functiondef(
    'priv.srd_iniciar_derrubar_com_aoo_srd(bigint,text,text,boolean,boolean)'::regprocedure
  ) INTO v_definition;
  IF position('v_reach:=5;' in v_definition)=0 THEN
    RAISE EXCEPTION 'Atribuição de alcance desarmado não encontrada; migration cancelada.';
  END IF;
  v_definition:=replace(v_definition,'v_reach:=5;','v_reach:=v_base_reach;');
  EXECUTE v_definition;
END
$migration$;