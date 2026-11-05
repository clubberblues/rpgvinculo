DO $migration$
DECLARE v_def text; v_bad text; v_good text;
BEGIN
 v_bad:='IF v_slot IS DISTINCT FROM ''arma'' THEN UPDATE public.srd_character_equipment ce SET equipado=EXISTS (SELECT 1 FROM public.srd_character_weapon_instances wi WHERE wi.character_id=ce.character_id AND wi.equipment_id=ce.equipment_id AND wi.equipado), hand_slot=(SELECT wi.hand_slot FROM public.srd_character_weapon_instances wi WHERE wi.character_id=ce.character_id AND wi.equipment_id=ce.equipment_id AND wi.equipado ORDER BY CASE wi.hand_slot WHEN ''main_hand'' THEN 0 ELSE 1 END LIMIT 1) WHERE ce.character_id=NEW.character_id AND ce.equipment_id=NEW.equipment_id;'||chr(10)||' RETURN NEW; END IF;';
 v_good:='IF v_slot IS DISTINCT FROM ''arma'' THEN RETURN NEW; END IF;';
 v_def:=pg_get_functiondef('private.sync_character_weapon_instances_from_inventory()'::regprocedure);
 IF position(v_bad in v_def)=0 THEN RAISE EXCEPTION 'Ramo de itens não-arma da ficha não corresponde ao esperado.'; END IF;
 EXECUTE replace(v_def,v_bad,v_good);
 v_bad:='IF v_slot IS DISTINCT FROM ''arma'' THEN UPDATE public.srd_cba_token_equipment ce SET equipado=EXISTS (SELECT 1 FROM public.srd_cba_token_weapon_instances wi WHERE wi.campaign_id=ce.campaign_id AND wi.token_id=ce.token_id AND wi.equipment_id=ce.equipment_id AND wi.equipado), hand_slot=(SELECT wi.hand_slot FROM public.srd_cba_token_weapon_instances wi WHERE wi.campaign_id=ce.campaign_id AND wi.token_id=ce.token_id AND wi.equipment_id=ce.equipment_id AND wi.equipado ORDER BY CASE wi.hand_slot WHEN ''main_hand'' THEN 0 ELSE 1 END LIMIT 1) WHERE ce.campaign_id=NEW.campaign_id AND ce.token_id=NEW.token_id AND ce.equipment_id=NEW.equipment_id;'||chr(10)||' RETURN NEW; END IF;';
 v_good:='IF v_slot IS DISTINCT FROM ''arma'' THEN RETURN NEW; END IF;';
 v_def:=pg_get_functiondef('private.sync_token_weapon_instances_from_inventory()'::regprocedure);
 IF position(v_bad in v_def)=0 THEN RAISE EXCEPTION 'Ramo de itens não-arma do token não corresponde ao esperado.'; END IF;
 EXECUTE replace(v_def,v_bad,v_good);
END;
$migration$;