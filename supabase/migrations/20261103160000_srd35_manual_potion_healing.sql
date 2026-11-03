CREATE OR REPLACE FUNCTION public.usar_pocao_cura_srd_manual(
  p_character_id text,p_equipment_id text,p_roll_results integer[]
)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'public','pg_temp'
AS $function$
DECLARE v_count integer;v_current_hp integer;v_max_hp integer;v_dice integer;v_flat integer;v_healing integer;v_campaign_id bigint;v_campaign_state text;
BEGIN
 IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.';END IF;
 IF NOT EXISTS(SELECT 1 FROM public.characters WHERE id::TEXT=BTRIM(p_character_id) AND user_id=auth.uid()) THEN RAISE EXCEPTION 'A ficha não pertence à sua conta.';END IF;
 CASE p_equipment_id
  WHEN 'pocao_cura_lig' THEN v_dice:=1;v_flat:=1;
  WHEN 'pocao_cura_mod' THEN v_dice:=2;v_flat:=3;
  WHEN 'pocao_cura_grav' THEN v_dice:=3;v_flat:=5;
  ELSE RAISE EXCEPTION 'Esta poção não tem efeito de cura automatizado.';
 END CASE;
 IF p_roll_results IS NULL OR cardinality(p_roll_results)<>v_dice OR EXISTS(SELECT 1 FROM unnest(p_roll_results) value WHERE value<1 OR value>8)
 THEN RAISE EXCEPTION 'A poção exige exatamente % resultado(s) manual(is) de d8.',v_dice;END IF;
 SELECT campaign_id INTO v_campaign_id FROM public.characters WHERE id::TEXT=BTRIM(p_character_id) AND user_id=auth.uid();
 IF v_campaign_id IS NOT NULL THEN
  SELECT state INTO v_campaign_state FROM public.campaigns WHERE id=v_campaign_id;
  IF upper(coalesce(v_campaign_state,''))='COMBATE' THEN PERFORM public.consumir_acao_turno_srd(v_campaign_id,p_character_id,'padrao');END IF;
 END IF;
 SELECT quantidade INTO v_count FROM public.srd_character_equipment WHERE character_id=BTRIM(p_character_id) AND equipment_id=p_equipment_id AND quantidade>0 FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Poção não encontrada na mochila.';END IF;
 SELECT pv_atual,pv_max INTO v_current_hp,v_max_hp FROM public.srd_character_sheets WHERE character_id::TEXT=BTRIM(p_character_id) FOR UPDATE;
 IF NOT FOUND OR v_max_hp IS NULL THEN RAISE EXCEPTION 'Ficha SRD sem PV máximo.';END IF;
 SELECT v_flat+sum(value) INTO v_healing FROM unnest(p_roll_results) value;
 UPDATE public.srd_character_sheets SET pv_atual=LEAST(v_max_hp,COALESCE(v_current_hp,0)+v_healing) WHERE character_id::TEXT=BTRIM(p_character_id) RETURNING pv_atual INTO v_current_hp;
 IF v_count=1 THEN DELETE FROM public.srd_character_equipment WHERE character_id=BTRIM(p_character_id) AND equipment_id=p_equipment_id;
 ELSE UPDATE public.srd_character_equipment SET quantidade=quantidade-1 WHERE character_id=BTRIM(p_character_id) AND equipment_id=p_equipment_id;END IF;
 RETURN jsonb_build_object('character_id',BTRIM(p_character_id),'healing_rolled',v_healing,'roll_results',to_jsonb(p_roll_results),'pv_atual',v_current_hp,'pv_max',v_max_hp,'quantidade_restante',GREATEST(v_count-1,0));
END;$function$;
REVOKE EXECUTE ON FUNCTION public.usar_pocao_cura_srd(text,text) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.usar_pocao_cura_srd_manual(text,text,integer[]) TO authenticated;