
DO $patch$
DECLARE v_def text; v_pos integer; v_len integer;
BEGIN
  v_def:=pg_get_functiondef('priv.srd_iniciar_derrubar_com_aoo_srd(bigint,text,text,boolean,boolean)'::regprocedure);
  v_pos:=position('v_reach_match:=regexp_match' in v_def);
  IF v_pos=0 THEN RAISE EXCEPTION 'Trecho do parser de alcance não encontrado.'; END IF;
  v_len:=position(';' in substring(v_def from v_pos));
  IF v_len=0 THEN RAISE EXCEPTION 'Fim do parser de alcance não encontrado.'; END IF;
  v_def:=overlay(v_def placing $line$v_reach_match:=regexp_match(coalesce(v_defender->'monsterStats'->>'espaco_alcance',v_defender->'monsterStats'->>'space_reach',''),'([0-9]+)[[:space:]]*ft[^0-9]*([0-9]+)','i');$line$ from v_pos for v_len);
  EXECUTE v_def;
END;
$patch$;
