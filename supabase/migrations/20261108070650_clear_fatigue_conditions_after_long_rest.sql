CREATE OR REPLACE FUNCTION public.descanso_longo_personagem_srd(p_campaign_id bigint, p_character_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
 v_owner UUID;
 v_campaign BIGINT;
 v_state TEXT;
 v_level INTEGER;
 v_hp INTEGER;
 v_max INTEGER;
 v_new_hp INTEGER;
 v_last_rest TIMESTAMPTZ;
 v_spell_state JSONB;
 v_conditions_removed INTEGER:=0;
BEGIN
 IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
 SELECT c.user_id,c.campaign_id INTO v_owner,v_campaign
   FROM public.characters c
  WHERE c.id::TEXT=BTRIM(p_character_id) FOR UPDATE;
 IF NOT FOUND OR v_campaign IS DISTINCT FROM p_campaign_id THEN
   RAISE EXCEPTION 'Personagem não encontrado nesta campanha.';
 END IF;
 IF v_owner IS DISTINCT FROM auth.uid() THEN
   RAISE EXCEPTION 'Somente o dono da ficha pode realizar descanso.';
 END IF;
 SELECT state INTO v_state FROM public.campaigns WHERE id=p_campaign_id;
 IF UPPER(COALESCE(v_state,''))='COMBATE' THEN
   RAISE EXCEPTION 'Não é possível descansar durante um combate.';
 END IF;
 SELECT s.nivel,s.pv_atual,s.pv_max,s.magias_descanso_em
   INTO v_level,v_hp,v_max,v_last_rest
   FROM public.srd_character_sheets s
  WHERE s.character_id::TEXT=BTRIM(p_character_id) FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada.'; END IF;
 IF v_last_rest IS NOT NULL AND v_last_rest>clock_timestamp()-INTERVAL '8 hours' THEN
   RAISE EXCEPTION 'O descanso longo exige 8 horas entre descansos.';
 END IF;
 v_level:=GREATEST(1,COALESCE(v_level,1));
 IF v_max IS NULL OR v_max<1 THEN RAISE EXCEPTION 'PV máximo inválido.'; END IF;
 v_new_hp:=LEAST(v_max,COALESCE(v_hp,v_max)+v_level);
 PERFORM public.repor_magias_srd(BTRIM(p_character_id));
 UPDATE public.srd_character_feature_resources
    SET uses_spent=0,resource_spent=0,last_reset_at=clock_timestamp()
  WHERE character_id=(SELECT id FROM public.characters WHERE id::text=BTRIM(p_character_id));
 UPDATE public.srd_character_sheets
    SET pv_atual=v_new_hp
  WHERE character_id::TEXT=BTRIM(p_character_id)
  RETURNING magias_preparadas INTO v_spell_state;

 -- Eight hours of complete rest removes fatigue and exhaustion (SRD 3.5).
 UPDATE public.srd_campaign_conditions
    SET active=false
  WHERE campaign_id=p_campaign_id AND target_kind='character'
    AND target_id=BTRIM(p_character_id) AND active
    AND condition_id IN ('fatigued','exhausted');
 GET DIAGNOSTICS v_conditions_removed=ROW_COUNT;

 RETURN jsonb_build_object(
   'character_id',BTRIM(p_character_id),
   'pv_atual',v_new_hp,'pv_max',v_max,
   'cura',v_new_hp-COALESCE(v_hp,v_max),
   'magias_repostas',TRUE,
   'recursos_classe_repostos',TRUE,
   'condicoes_removidas',v_conditions_removed,
   'descanso_em',clock_timestamp()
 );
END;
$function$;