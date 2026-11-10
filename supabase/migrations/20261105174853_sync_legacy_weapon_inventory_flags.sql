DO $migration$
DECLARE v_def text; v_old text; v_new text;
BEGIN
 v_def:=pg_get_functiondef('private.sync_character_weapon_instances_from_inventory()'::regprocedure);
 v_old:=' RETURN NEW;';
 v_new:=' UPDATE public.srd_character_equipment ce SET equipado=EXISTS (SELECT 1 FROM public.srd_character_weapon_instances wi WHERE wi.character_id=ce.character_id AND wi.equipment_id=ce.equipment_id AND wi.equipado), hand_slot=(SELECT wi.hand_slot FROM public.srd_character_weapon_instances wi WHERE wi.character_id=ce.character_id AND wi.equipment_id=ce.equipment_id AND wi.equipado ORDER BY CASE wi.hand_slot WHEN ''main_hand'' THEN 0 ELSE 1 END LIMIT 1) WHERE ce.character_id=NEW.character_id AND ce.equipment_id=NEW.equipment_id;'||chr(10)||v_old;
 IF position(v_old in v_def)=0 THEN RAISE EXCEPTION 'Ponto de sincronização do inventário da ficha não encontrado.'; END IF;
 EXECUTE replace(v_def,v_old,v_new);
 v_def:=pg_get_functiondef('private.sync_token_weapon_instances_from_inventory()'::regprocedure);
 v_new:=' UPDATE public.srd_cba_token_equipment ce SET equipado=EXISTS (SELECT 1 FROM public.srd_cba_token_weapon_instances wi WHERE wi.campaign_id=ce.campaign_id AND wi.token_id=ce.token_id AND wi.equipment_id=ce.equipment_id AND wi.equipado), hand_slot=(SELECT wi.hand_slot FROM public.srd_cba_token_weapon_instances wi WHERE wi.campaign_id=ce.campaign_id AND wi.token_id=ce.token_id AND wi.equipment_id=ce.equipment_id AND wi.equipado ORDER BY CASE wi.hand_slot WHEN ''main_hand'' THEN 0 ELSE 1 END LIMIT 1) WHERE ce.campaign_id=NEW.campaign_id AND ce.token_id=NEW.token_id AND ce.equipment_id=NEW.equipment_id;'||chr(10)||v_old;
 IF position(v_old in v_def)=0 THEN RAISE EXCEPTION 'Ponto de sincronização do inventário do token não encontrado.'; END IF;
 EXECUTE replace(v_def,v_old,v_new);
END;
$migration$;