CREATE OR REPLACE FUNCTION private.sync_character_weapon_instances_from_inventory()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'pg_catalog','public'
AS $function$
DECLARE v_slot text; v_delta integer; v_removed integer;
BEGIN
 IF TG_OP='DELETE' THEN DELETE FROM public.srd_character_weapon_instances WHERE character_id=OLD.character_id AND equipment_id=OLD.equipment_id; RETURN OLD; END IF;
 SELECT public.srd35_equipment_slot(e.categoria,e.nome) INTO v_slot FROM public.srd_equipment e WHERE e.id=NEW.equipment_id;
 IF v_slot IS DISTINCT FROM 'arma' THEN RETURN NEW; END IF;
 IF TG_OP='INSERT' THEN v_delta:=NEW.quantidade; ELSE v_delta:=NEW.quantidade-OLD.quantidade; END IF;
 IF v_delta>0 THEN
  INSERT INTO public.srd_character_weapon_instances(character_id,equipment_id) SELECT NEW.character_id,NEW.equipment_id FROM generate_series(1,v_delta);
 ELSIF v_delta<0 THEN
  DELETE FROM public.srd_character_weapon_instances WHERE instance_id IN (SELECT instance_id FROM public.srd_character_weapon_instances WHERE character_id=NEW.character_id AND equipment_id=NEW.equipment_id AND NOT equipado ORDER BY created_at DESC LIMIT abs(v_delta));
  GET DIAGNOSTICS v_removed=ROW_COUNT;
  IF v_removed<abs(v_delta) THEN RAISE EXCEPTION 'Não é possível reduzir a quantidade: há armas equipadas ou instâncias em uso.'; END IF;
 END IF;
 RETURN NEW;
END;
$function$;
CREATE OR REPLACE FUNCTION private.sync_token_weapon_instances_from_inventory()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'pg_catalog','public'
AS $function$
DECLARE v_slot text; v_delta integer; v_removed integer;
BEGIN
 IF TG_OP='DELETE' THEN DELETE FROM public.srd_cba_token_weapon_instances WHERE campaign_id=OLD.campaign_id AND token_id=OLD.token_id AND equipment_id=OLD.equipment_id; RETURN OLD; END IF;
 SELECT public.srd35_equipment_slot(e.categoria,e.nome) INTO v_slot FROM public.srd_equipment e WHERE e.id=NEW.equipment_id;
 IF v_slot IS DISTINCT FROM 'arma' THEN RETURN NEW; END IF;
 IF TG_OP='INSERT' THEN v_delta:=NEW.quantidade; ELSE v_delta:=NEW.quantidade-OLD.quantidade; END IF;
 IF v_delta>0 THEN
  INSERT INTO public.srd_cba_token_weapon_instances(campaign_id,token_id,equipment_id) SELECT NEW.campaign_id,NEW.token_id,NEW.equipment_id FROM generate_series(1,v_delta);
 ELSIF v_delta<0 THEN
  DELETE FROM public.srd_cba_token_weapon_instances WHERE instance_id IN (SELECT instance_id FROM public.srd_cba_token_weapon_instances WHERE campaign_id=NEW.campaign_id AND token_id=NEW.token_id AND equipment_id=NEW.equipment_id AND NOT equipado ORDER BY created_at DESC LIMIT abs(v_delta));
  GET DIAGNOSTICS v_removed=ROW_COUNT;
  IF v_removed<abs(v_delta) THEN RAISE EXCEPTION 'Não é possível reduzir a quantidade: há armas equipadas ou instâncias em uso.'; END IF;
 END IF;
 RETURN NEW;
END;
$function$;
REVOKE ALL ON FUNCTION private.sync_character_weapon_instances_from_inventory() FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION private.sync_token_weapon_instances_from_inventory() FROM PUBLIC,anon,authenticated;
DROP TRIGGER IF EXISTS sync_character_weapon_instances_from_inventory ON public.srd_character_equipment;
CREATE TRIGGER sync_character_weapon_instances_from_inventory AFTER INSERT OR UPDATE OF quantidade OR DELETE ON public.srd_character_equipment FOR EACH ROW EXECUTE FUNCTION private.sync_character_weapon_instances_from_inventory();
DROP TRIGGER IF EXISTS sync_token_weapon_instances_from_inventory ON public.srd_cba_token_equipment;
CREATE TRIGGER sync_token_weapon_instances_from_inventory AFTER INSERT OR UPDATE OF quantidade OR DELETE ON public.srd_cba_token_equipment FOR EACH ROW EXECUTE FUNCTION private.sync_token_weapon_instances_from_inventory();