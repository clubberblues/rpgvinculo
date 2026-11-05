DO $migration$
DECLARE v_def text; v_old text; v_new text;
BEGIN
 v_def:=pg_get_functiondef('private.equipar_arma_instancia_personagem_impl(text,uuid,text,boolean)'::regprocedure);
 v_old:=' RETURN jsonb_build_object(''character_id'',btrim(p_character_id),''instance_id'',p_instance_id';
 v_new:=' UPDATE public.srd_character_equipment ce SET equipado=EXISTS (SELECT 1 FROM public.srd_character_weapon_instances wi WHERE wi.character_id=ce.character_id AND wi.equipment_id=ce.equipment_id AND wi.equipado), hand_slot=(SELECT wi.hand_slot FROM public.srd_character_weapon_instances wi WHERE wi.character_id=ce.character_id AND wi.equipment_id=ce.equipment_id AND wi.equipado ORDER BY CASE wi.hand_slot WHEN ''main_hand'' THEN 0 ELSE 1 END LIMIT 1) WHERE ce.character_id=btrim(p_character_id) AND ce.equipment_id=v_instance.equipment_id;'||chr(10)||v_old;
 IF position(v_old in v_def)=0 THEN RAISE EXCEPTION 'Ponto de sincronização da ficha não encontrado.'; END IF;
 EXECUTE replace(v_def,v_old,v_new);
 v_def:=pg_get_functiondef('private.equipar_arma_instancia_token_impl(bigint,text,uuid,text,boolean)'::regprocedure);
 v_old:=' RETURN jsonb_build_object(''campaign_id'',p_campaign_id,''token_id'',btrim(p_token_id),''instance_id'',p_instance_id';
 v_new:=' UPDATE public.srd_cba_token_equipment ce SET equipado=EXISTS (SELECT 1 FROM public.srd_cba_token_weapon_instances wi WHERE wi.campaign_id=ce.campaign_id AND wi.token_id=ce.token_id AND wi.equipment_id=ce.equipment_id AND wi.equipado), hand_slot=(SELECT wi.hand_slot FROM public.srd_cba_token_weapon_instances wi WHERE wi.campaign_id=ce.campaign_id AND wi.token_id=ce.token_id AND wi.equipment_id=ce.equipment_id AND wi.equipado ORDER BY CASE wi.hand_slot WHEN ''main_hand'' THEN 0 ELSE 1 END LIMIT 1) WHERE ce.campaign_id=p_campaign_id AND ce.token_id=btrim(p_token_id) AND ce.equipment_id=v_instance.equipment_id;'||chr(10)||v_old;
 IF position(v_old in v_def)=0 THEN RAISE EXCEPTION 'Ponto de sincronização do token não encontrado.'; END IF;
 EXECUTE replace(v_def,v_old,v_new);
 v_def:=pg_get_functiondef('public.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer)'::regprocedure);
 v_old:='AND ce.equipado IS TRUE AND eq.categoria=''arma'';';
 v_new:='AND ce.equipado IS TRUE AND eq.categoria=''arma'' AND EXISTS (SELECT 1 FROM public.srd_character_weapon_instances wi WHERE wi.character_id=ce.character_id AND wi.equipment_id=ce.equipment_id AND wi.equipado IS TRUE AND wi.hand_slot=''main_hand'');';
 IF position(v_old in v_def)=0 THEN RAISE EXCEPTION 'Validação de arma equipada no ataque não encontrada.'; END IF;
 EXECUTE replace(v_def,v_old,v_new);
END;
$migration$;