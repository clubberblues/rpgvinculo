
DO $migration$
DECLARE
  v_definition text;
  v_updated text;
  v_old text := $old$'will',1,jsonb_build_object('damage',p_damage,'damage_type','force'),true,v_sheet.nivel,$old$;
  v_new text := $new$NULL,NULL,jsonb_build_object('damage',p_damage,'damage_type','force'),true,v_sheet.nivel,$new$;
  v_old_return text := $oldreturn$'pv_max',v_max_hp,'missiles',v_missiles,'spell_resistance_pending',true$oldreturn$;
  v_new_return text := $newreturn$'pv_max',v_max_hp,'missiles',v_missiles,'spell_resistance_pending',false$newreturn$;
BEGIN
  SELECT pg_get_functiondef('public.conjurar_missil_magico_srd(text,text,smallint,text,integer)'::regprocedure)
    INTO v_definition;
  IF position(v_old IN v_definition)=0 THEN
    RAISE EXCEPTION 'Trecho de resistência pendente de Míssil Mágico não encontrado; migração cancelada.';
  END IF;
  IF position(v_old IN substring(v_definition FROM position(v_old IN v_definition)+length(v_old)))>0 THEN
    RAISE EXCEPTION 'Trecho de resistência aparece mais de uma vez; migração cancelada.';
  END IF;
  v_updated:=replace(v_definition,v_old,v_new);
  IF position(v_old_return IN v_updated)=0 THEN
    RAISE EXCEPTION 'Retorno final de Míssil Mágico não encontrado; migração cancelada.';
  END IF;
  IF position(v_old_return IN substring(v_updated FROM position(v_old_return IN v_updated)+length(v_old_return)))>0 THEN
    RAISE EXCEPTION 'Retorno final aparece mais de uma vez; migração cancelada.';
  END IF;
  v_updated:=replace(v_updated,v_old_return,v_new_return);
  EXECUTE v_updated;
END
$migration$;
