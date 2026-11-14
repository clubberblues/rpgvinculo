CREATE OR REPLACE FUNCTION priv.srd_end_barbarian_rage_token(
 p_campaign_id bigint,p_token_id text,p_apply_fatigue boolean DEFAULT true
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $$
DECLARE
 v_effect public.srd_campaign_effects%ROWTYPE; v_campaign public.campaigns%ROWTYPE;
 v_tokens jsonb; v_token_count integer; v_token_index bigint; v_token jsonb;
 v_hp integer; v_max_hp integer; v_bonus integer:=0; v_new_hp integer; v_new_max integer;
 v_level integer:=0; v_condition text;
BEGIN
 SELECT * INTO v_effect FROM public.srd_campaign_effects
 WHERE campaign_id=p_campaign_id AND target_kind='token' AND target_id=BTRIM(p_token_id)
   AND active AND effect_data->>'source_feature'='barbarian_rage'
 ORDER BY effect_instance_id DESC LIMIT 1 FOR UPDATE;
 IF NOT FOUND THEN RETURN jsonb_build_object('ended',false,'reason','rage_not_active'); END IF;
 SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
 v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END;
 SELECT count(*)::integer,min(t.ordinality) INTO v_token_count,v_token_index
 FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality)
 WHERE t.token->>'id'=BTRIM(p_token_id) AND t.token->>'tipo'='npc';
 IF v_token_count>1 THEN RAISE EXCEPTION 'Token NPC duplicado ao encerrar Fúria.'; END IF;
 IF v_token_count=0 THEN
   UPDATE public.srd_campaign_effects SET active=false WHERE effect_instance_id=v_effect.effect_instance_id;
   RETURN jsonb_build_object('ended',true,'token_missing',true,'rage_hp_removed',0,'fatigue_applied',false);
 END IF;
 v_token:=v_tokens->(v_token_index::integer-1);
 IF COALESCE(v_effect.effect_data->>'rage_hp_bonus','') ~ '^[0-9]{1,6}$' THEN v_bonus:=(v_effect.effect_data->>'rage_hp_bonus')::integer; END IF;
 IF COALESCE(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' OR COALESCE(v_token->>'hp','') !~ '^[0-9]{1,6}$' THEN
   RAISE EXCEPTION 'PV do token NPC inválidos; Fúria não foi encerrada.';
 END IF;
 v_max_hp:=(v_token->>'maxHp')::integer; v_hp:=(v_token->>'hp')::integer;
 v_new_max:=GREATEST(1,v_max_hp-v_bonus); v_new_hp:=GREATEST(0,LEAST(v_new_max,v_hp-v_bonus));
 v_level:=COALESCE(NULLIF(v_effect.effect_data->>'rage_level','')::integer,0);
 UPDATE public.srd_campaign_effects SET active=false WHERE effect_instance_id=v_effect.effect_instance_id;
 SELECT COALESCE(jsonb_agg(CASE WHEN t.ordinality=v_token_index
   THEN t.token||jsonb_build_object('hp',v_new_hp,'maxHp',v_new_max) ELSE t.token END ORDER BY t.ordinality),'[]'::jsonb)
 INTO v_tokens FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality);
 UPDATE public.campaigns SET cba_data=COALESCE(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens) WHERE id=p_campaign_id;
 IF p_apply_fatigue AND v_level<17 THEN
   IF EXISTS(SELECT 1 FROM public.srd_campaign_conditions WHERE campaign_id=p_campaign_id AND target_kind='token'
     AND target_id=BTRIM(p_token_id) AND condition_id='exhausted' AND active) THEN v_condition:=NULL;
   ELSIF EXISTS(SELECT 1 FROM public.srd_campaign_conditions WHERE campaign_id=p_campaign_id AND target_kind='token'
     AND target_id=BTRIM(p_token_id) AND condition_id='fatigued' AND active) THEN v_condition:='exhausted';
   ELSE v_condition:='fatigued'; END IF;
   IF v_condition IS NOT NULL THEN
     IF v_condition='exhausted' THEN UPDATE public.srd_campaign_conditions SET active=false
       WHERE campaign_id=p_campaign_id AND target_kind='token' AND target_id=BTRIM(p_token_id)
         AND condition_id='fatigued' AND active; END IF;
     PERFORM priv.srd_apply_campaign_condition(p_campaign_id,'token',BTRIM(p_token_id),v_condition,NULL,
       jsonb_build_object('source_feature','barbarian_rage','reason','rage_ended'),NULL);
   END IF;
 END IF;
 SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id;
 RETURN jsonb_build_object('ended',true,'rage_hp_removed',v_bonus,'hp',v_new_hp,'max_hp',v_new_max,
   'fatigue_applied',p_apply_fatigue AND v_level<17,'cba_data',v_campaign.cba_data);
END;
$$;
CREATE OR REPLACE FUNCTION public.srd_expire_campaign_conditions(p_campaign_id bigint)
RETURNS integer LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $$
DECLARE
 v_round integer; v_count integer:=0; v_effect_count integer:=0; v_rage_count integer:=0;
 v_rage record; v_result jsonb;
BEGIN
 IF auth.uid() IS NULL OR (public.my_role(p_campaign_id) IS NULL AND NOT EXISTS(
   SELECT 1 FROM public.campaigns c WHERE c.id=p_campaign_id AND c.owner_id=auth.uid()
 )) THEN RAISE EXCEPTION 'Sem acesso à campanha.'; END IF;
 SELECT COALESCE(NULLIF(combat_data->>'round','')::integer,0) INTO v_round
 FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
 IF NOT FOUND OR v_round<1 THEN RETURN 0; END IF;
 FOR v_rage IN SELECT e.target_id FROM public.srd_campaign_effects e
   WHERE e.campaign_id=p_campaign_id AND e.target_kind='character' AND e.active
     AND e.expires_round IS NOT NULL AND e.expires_round<=v_round
     AND e.effect_data->>'source_feature'='barbarian_rage' FOR UPDATE
 LOOP
   PERFORM priv.srd_end_barbarian_rage(p_campaign_id,v_rage.target_id,true);
   v_rage_count:=v_rage_count+1;
 END LOOP;
 FOR v_rage IN SELECT e.target_id,e.effect_instance_id FROM public.srd_campaign_effects e
   WHERE e.campaign_id=p_campaign_id AND e.target_kind='token' AND e.active
     AND e.expires_round IS NOT NULL AND e.expires_round<=v_round
     AND e.effect_data->>'source_feature'='barbarian_rage' FOR UPDATE
 LOOP
   v_result:=priv.srd_end_barbarian_rage_token(p_campaign_id,v_rage.target_id,true);
   IF COALESCE((v_result->>'ended')::boolean,false) THEN
     v_rage_count:=v_rage_count+1;
     PERFORM priv.log(p_campaign_id,'CLASS_FEATURE',jsonb_build_object(
       'feature_key','barbarian_rage','action','expire','token_id',v_rage.target_id,
       'effect_instance_id',v_rage.effect_instance_id,'round',v_round,
       'rage_hp_removed',v_result->'rage_hp_removed','fatigue_applied',v_result->'fatigue_applied'));
   END IF;
 END LOOP;
 UPDATE public.srd_campaign_conditions SET active=false
 WHERE campaign_id=p_campaign_id AND active AND expires_round IS NOT NULL AND expires_round<=v_round;
 GET DIAGNOSTICS v_count=ROW_COUNT;
 UPDATE public.srd_campaign_effects SET active=false
 WHERE campaign_id=p_campaign_id AND active AND expires_round IS NOT NULL AND expires_round<=v_round;
 GET DIAGNOSTICS v_effect_count=ROW_COUNT;
 RETURN v_count+v_effect_count+v_rage_count;
END;
$$;