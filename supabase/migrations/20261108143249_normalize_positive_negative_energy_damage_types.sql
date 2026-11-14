
DO $migration$
DECLARE
  v_sig text:='priv.srd_adjust_damage(bigint,text,text,text,integer)';
  v_def text:=pg_get_functiondef(v_sig::regprocedure);
  v_old text:='    ELSE v_type END;';
  v_new text:='    WHEN ''positive'' THEN ''positive_energy'''||
    E'\n    WHEN ''negative'' THEN ''negative_energy'''||
    E'\n    ELSE v_type END;';
  v_count integer;
BEGIN
  v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
  IF v_count<>1 THEN RAISE EXCEPTION 'Normalização de energia positiva/negativa não única: %.',v_count; END IF;
  EXECUTE replace(v_def,v_old,v_new);
END;
$migration$;
