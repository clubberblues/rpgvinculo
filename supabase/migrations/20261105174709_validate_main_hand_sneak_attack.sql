DO $migration$
DECLARE v_def text; v_old text; v_new text; v_oid oid;
BEGIN
 SELECT p.oid INTO v_oid FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
 WHERE n.nspname='public' AND p.proname='aplicar_dano_token_ataque_srd_v2' AND p.pronargs=11;
 IF v_oid IS NULL THEN RAISE EXCEPTION 'Overload de ataque com Ataque Furtivo não encontrado.'; END IF;
 v_def:=pg_get_functiondef(v_oid);
 v_old:='AND ce.equipado IS TRUE AND eq.categoria=''arma'';';
 v_new:='AND ce.equipado IS TRUE AND eq.categoria=''arma'' AND EXISTS (SELECT 1 FROM public.srd_character_weapon_instances wi WHERE wi.character_id=ce.character_id AND wi.equipment_id=ce.equipment_id AND wi.equipado IS TRUE AND wi.hand_slot=''main_hand'');';
 IF position(v_old in v_def)=0 THEN
  IF position('wi.hand_slot=''main_hand''' in v_def)>0 THEN RETURN; END IF;
  RAISE EXCEPTION 'Validação de arma equipada no overload com Ataque Furtivo não encontrada.';
 END IF;
 EXECUTE replace(v_def,v_old,v_new);
END;
$migration$;