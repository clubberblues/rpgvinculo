
DO $migration$
DECLARE v_def text;v_old text;v_new text;v_count integer;
BEGIN
 v_def:=pg_get_functiondef('public.descanso_longo_personagem_srd(bigint,text)'::regprocedure);
 v_old:=$old$ IF v_max IS NULL OR v_max<1 THEN RAISE EXCEPTION 'PV máximo inválido.'; END IF;
 v_new_hp:=LEAST(v_max,COALESCE(v_hp,v_max)+v_level);$old$;
 v_new:=$new$ IF v_max IS NULL OR v_max<1 THEN RAISE EXCEPTION 'PV máximo inválido.'; END IF;
 IF COALESCE(v_hp,0)<=-10 OR priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_character_id),'no_healing') THEN
   RAISE EXCEPTION 'Personagens mortos não podem se beneficiar de descanso longo.';
 END IF;
 v_new_hp:=LEAST(v_max,COALESCE(v_hp,v_max)+v_level);
 PERFORM priv.srd_sync_character_vital_condition(BTRIM(p_character_id),v_new_hp,
   v_new_hp<0 AND EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc
     WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='character'
       AND cc.target_id=BTRIM(p_character_id) AND cc.condition_id='stable' AND cc.active=true));$new$;
 v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
 IF v_count<>1 THEN RAISE EXCEPTION 'Ponto de validação de descanso longo não é único: %.',v_count; END IF;
 EXECUTE replace(v_def,v_old,v_new);
END;
$migration$;
