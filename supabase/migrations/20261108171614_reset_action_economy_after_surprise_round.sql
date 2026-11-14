
DO $patch$
DECLARE v_def text;v_old text;v_new text;
BEGIN
 SELECT pg_get_functiondef('public.avancar_turno(bigint)'::regprocedure) INTO v_def;
 v_old:='v_next_data:=v_data||jsonb_build_object(''surprise'',v_surprise,''current_turn'',0,''round'',1,''active'',true);';
 IF position(v_old in v_def)=0 THEN RAISE EXCEPTION 'Transição da rodada surpresa para rodada normal não encontrada.'; END IF;
 v_new:=replace(v_def,v_old,
  'v_next_data:=v_data||jsonb_build_object(''surprise'',v_surprise,''current_turn'',0,''round'',1,''active'',true,'||
  '''action_economy'',jsonb_build_object(''round'',1,''by_character'',''{}''::jsonb),'||
  '''movement_usage'',''{}''::jsonb);');
 EXECUTE v_new;
END;
$patch$;
