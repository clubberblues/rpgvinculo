
DO $patch$
DECLARE v_def text;
BEGIN
  v_def:=pg_get_functiondef('public.srd_iniciar_derrubar_com_aoo_srd(bigint,text,text,boolean,boolean)'::regprocedure);
  v_def:=replace(v_def,
    '  IF v_distance>v_reach THEN v_reaction_status:=''ineligible''; END IF;',
    '  -- O alcance real é validado depois da escolha da arma no motor de AOO; não presumir alcance natural de 1,5 m.'
  );
  EXECUTE v_def;
END;
$patch$;
