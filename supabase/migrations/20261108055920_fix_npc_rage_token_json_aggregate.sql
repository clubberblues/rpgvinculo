CREATE OR REPLACE FUNCTION public.consultar_furia_barbaro_npc_srd(p_campaign_id bigint,p_token_id text)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $$
DECLARE
 v_campaign public.campaigns%ROWTYPE; v_token jsonb; v_token_count integer;
 v_character_id text; v_character public.characters%ROWTYPE; v_sheet public.srd_character_sheets%ROWTYPE;
 v_level integer:=0; v_uses_day integer:=0; v_uses_spent integer:=0; v_active boolean:=false;
 v_expiry integer; v_round integer:=1; v_order jsonb:='[]'::jsonb; v_turn integer:=-1;
 v_actor jsonb; v_can_start boolean:=false; v_can_end boolean:=false;
 v_fatigued boolean:=false; v_no_actions boolean:=false;
BEGIN
 IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
   RAISE EXCEPTION 'Somente o Mestre autenticado pode controlar habilidades de NPC.';
 END IF;
 SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id;
 IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
 SELECT count(*)::integer,(jsonb_agg(t.token)->0) INTO v_token_count,v_token
 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array'
   THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END) t(token)
 WHERE t.token->>'id'=BTRIM(p_token_id) AND t.token->>'tipo'='npc';
 IF v_token_count<>1 THEN RAISE EXCEPTION 'Token NPC não encontrado ou duplicado.'; END IF;
 v_character_id:=NULLIF(v_token->>'sourceCharacterId','');
 IF v_character_id IS NULL THEN RAISE EXCEPTION 'Este NPC não está vinculado a uma ficha de origem.'; END IF;
 SELECT * INTO v_character FROM public.characters WHERE id::text=v_character_id;
 IF NOT FOUND THEN RAISE EXCEPTION 'Ficha de origem não encontrada.'; END IF;
 SELECT * INTO v_sheet FROM public.srd_character_sheets WHERE character_id=v_character.id;
 IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD de origem não encontrada.'; END IF;
 SELECT COALESCE(MAX(cl.class_level) FILTER (WHERE cls.class_key='barbarian'),
   CASE WHEN NOT EXISTS(SELECT 1 FROM public.srd_character_class_levels lv WHERE lv.character_id=v_sheet.character_id)
     AND v_sheet.classe_id='barbaro' THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END)
 INTO v_level FROM public.srd_character_sheets sh
 LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
 LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
 WHERE sh.character_id=v_sheet.character_id GROUP BY sh.character_id,sh.classe_id,sh.nivel;
 v_level:=COALESCE(v_level,0);
 IF v_level<1 THEN RETURN jsonb_build_object('eligible',false,'barbarian_level',0,'active',false); END IF;
 v_uses_day:=1+FLOOR(v_level/4.0)::integer;
 SELECT COALESCE(uses_spent,0) INTO v_uses_spent FROM public.srd_character_feature_resources
 WHERE character_id=v_character.id AND feature_key='barbarian_rage';
 v_round:=CASE WHEN COALESCE(v_campaign.combat_data->>'round','') ~ '^[0-9]+$'
   THEN GREATEST(1,(v_campaign.combat_data->>'round')::integer) ELSE 1 END;
 v_order:=CASE WHEN jsonb_typeof(v_campaign.combat_data->'turn_order')='array'
   THEN v_campaign.combat_data->'turn_order' ELSE '[]'::jsonb END;
 IF COALESCE(v_campaign.combat_data->>'current_turn','') ~ '^[0-9]+$' THEN
   v_turn:=(v_campaign.combat_data->>'current_turn')::integer;
 END IF;
 IF v_turn>=0 AND v_turn<jsonb_array_length(v_order) THEN v_actor:=v_order->v_turn; END IF;
 SELECT EXISTS(SELECT 1 FROM public.srd_campaign_effects WHERE campaign_id=p_campaign_id
   AND target_kind='token' AND target_id=BTRIM(p_token_id) AND active
   AND effect_data->>'source_feature'='barbarian_rage'),
   (SELECT expires_round FROM public.srd_campaign_effects WHERE campaign_id=p_campaign_id
     AND target_kind='token' AND target_id=BTRIM(p_token_id) AND active
     AND effect_data->>'source_feature'='barbarian_rage' ORDER BY effect_instance_id DESC LIMIT 1)
 INTO v_active,v_expiry;
 v_fatigued:=EXISTS(SELECT 1 FROM public.srd_campaign_conditions WHERE campaign_id=p_campaign_id
   AND target_kind='token' AND target_id=BTRIM(p_token_id) AND active
   AND condition_id IN ('fatigued','exhausted'));
 v_no_actions:=priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'no_actions');
 v_can_start:=UPPER(COALESCE(v_campaign.state,''))='COMBATE'
   AND COALESCE(v_campaign.combat_data->>'active','false')='true'
   AND v_actor->>'id'=BTRIM(p_token_id) AND COALESCE(v_actor->>'is_monster','false')='true'
   AND NOT v_active AND NOT v_fatigued AND NOT v_no_actions
   AND COALESCE(v_uses_spent,0)<v_uses_day;
 v_can_end:=v_active AND (UPPER(COALESCE(v_campaign.state,''))<>'COMBATE'
   OR (COALESCE(v_campaign.combat_data->>'active','false')='true'
     AND v_actor->>'id'=BTRIM(p_token_id) AND COALESCE(v_actor->>'is_monster','false')='true'));
 RETURN jsonb_build_object('eligible',true,'barbarian_level',v_level,'uses_per_day',v_uses_day,
   'uses_spent',COALESCE(v_uses_spent,0),'uses_remaining',GREATEST(0,v_uses_day-COALESCE(v_uses_spent,0)),
   'active',v_active,'expires_round',v_expiry,
   'rounds_remaining',CASE WHEN v_active AND v_expiry IS NOT NULL THEN GREATEST(0,v_expiry-v_round) ELSE 0 END,
   'can_start',v_can_start,'can_end',v_can_end);
END;
$$;