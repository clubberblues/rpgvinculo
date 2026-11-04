
DO $fix_potion_dead_target$
DECLARE
  v_definition text;
  v_update text:=' UPDATE public.srd_character_sheets SET pv_atual=LEAST(v_max_hp,COALESCE(v_current_hp,0)+v_healing) WHERE character_id::TEXT=BTRIM(p_character_id) RETURNING pv_atual INTO v_current_hp;';
  v_bad text:=' IF COALESCE(v_current_hp,0)<=-10 THEN RAISE EXCEPTION ''Personagens mortos não podem receber cura comum.''; END IF;';
BEGIN
  SELECT pg_get_functiondef('public.usar_pocao_cura_srd_manual(text,text,integer[])'::regprocedure)
    INTO v_definition;
  IF position(v_bad IN v_definition)>0 THEN
    v_definition:=replace(v_definition,v_bad,'');
  END IF;
  IF position(v_update IN v_definition)=0 THEN RAISE EXCEPTION 'Atualização da poção não localizada para correção.'; END IF;
  IF position('IF COALESCE(v_current_hp,0)<=-10' IN v_definition)=0 THEN
    v_definition:=replace(v_definition,v_update,
      ' IF COALESCE(v_current_hp,0)<=-10 THEN RAISE EXCEPTION ''Personagens mortos não podem receber cura comum.''; END IF;' || E'\n' || v_update);
  END IF;
  EXECUTE v_definition;
END;
$fix_potion_dead_target$;

DO $fix_spell_dead_target$
DECLARE
  v_definition text;
  v_marker text:='v_target_hp:=CASE WHEN COALESCE(v_target_hp,0)<=-10 THEN COALESCE(v_target_hp,0) ELSE LEAST(v_target_max_hp,COALESCE(v_target_hp,0)+v_healing) END;';
BEGIN
  SELECT pg_get_functiondef('public.conjurar_magia_srd_manual(text,text,smallint,text,integer[])'::regprocedure)
    INTO v_definition;
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Atualização de PV da cura mágica não localizada.'; END IF;
  v_definition:=replace(v_definition,v_marker,
    'IF COALESCE(v_target_hp,0)<=-10 THEN v_healing:=0; END IF;' || E'\n' || v_marker);
  EXECUTE v_definition;
END;
$fix_spell_dead_target$;
