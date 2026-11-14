
DO $patch$
DECLARE v_def text;v_start integer;v_end integer;v_branch text;v_marker text;v_new text;
BEGIN
 SELECT pg_get_functiondef('public.avancar_turno(bigint)'::regprocedure) INTO v_def;
 v_start:=position('  -- Rodada surpresa: somente participantes conscientes recebem turno nesta fase.' in v_def);
 IF v_start=0 THEN RAISE EXCEPTION 'Bloco da rodada surpresa não encontrado.'; END IF;
 v_end:=position('  IF v_role <> ''GM'' THEN' in v_def);
 IF v_end=0 OR v_end<v_start THEN RAISE EXCEPTION 'Bloco de autorização do turno não encontrado.'; END IF;
 v_branch:=substring(v_def from v_start for v_end-v_start);
 v_new:=replace(v_def,v_branch,'');
 v_marker:='  END IF;'||E'\n\n  v_next := v_current + 1;';
 IF position(v_marker in v_new)=0 THEN RAISE EXCEPTION 'Destino seguro do bloco surpresa não encontrado.'; END IF;
 v_new:=replace(v_new,v_marker,'  END IF;'||E'\n\n'||v_branch||'  v_next := v_current + 1;');
 EXECUTE v_new;
END;
$patch$;
