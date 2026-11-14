CREATE OR REPLACE FUNCTION priv.srd_confusion_attack_target_allowed(p_campaign_id bigint, p_actor_kind text, p_actor_id text, p_target_token_id text)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
 v_condition public.srd_campaign_conditions%rowtype;
 v_character_id text;
 v_round integer;
BEGIN
 IF p_actor_kind NOT IN ('character','token') OR NULLIF(BTRIM(p_actor_id),'') IS NULL
   OR NULLIF(BTRIM(p_target_token_id),'') IS NULL THEN RETURN false; END IF;
 SELECT greatest(0,coalesce(nullif(c.combat_data->>'round','')::integer,0))
 INTO v_round FROM public.campaigns c WHERE c.id=p_campaign_id;
 IF NOT FOUND THEN RETURN false; END IF;
 IF p_actor_kind='character' THEN
   SELECT * INTO v_condition FROM public.srd_campaign_conditions cc
   WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='character'
     AND cc.target_id=btrim(p_actor_id) AND cc.condition_id='confused' AND cc.active
   ORDER BY cc.condition_instance_id DESC LIMIT 1;
 ELSE
   SELECT nullif(t.token->>'sourceCharacterId','') INTO v_character_id
   FROM public.campaigns c,jsonb_array_elements(coalesce(c.cba_data->'tokens','[]'::jsonb)) t(token)
   WHERE c.id=p_campaign_id AND t.token->>'id'=btrim(p_actor_id) AND t.token->>'tipo'='npc'
   LIMIT 1;
   SELECT * INTO v_condition FROM public.srd_campaign_conditions cc
   WHERE cc.campaign_id=p_campaign_id AND cc.condition_id='confused' AND cc.active
     AND ((cc.target_kind='token' AND cc.target_id=btrim(p_actor_id))
       OR (v_character_id IS NOT NULL AND cc.target_kind='character' AND cc.target_id=v_character_id))
   ORDER BY CASE WHEN cc.target_kind='token' THEN 0 ELSE 1 END,cc.condition_instance_id DESC
   LIMIT 1;
 END IF;
 IF NOT FOUND THEN RETURN true; END IF;
 IF nullif(v_condition.notes->>'confusion_pending_request_id','') IS NOT NULL
   OR coalesce(nullif(v_condition.notes->>'confusion_last_round','')::integer,-1)<>v_round THEN
   RETURN false;
 END IF;
 CASE v_condition.notes->>'confusion_last_outcome'
   WHEN 'act_normally' THEN RETURN true;
   WHEN 'attack_caster' THEN
     RETURN v_condition.notes->>'confusion_last_selected_target_token_id'=btrim(p_target_token_id);
   WHEN 'attack_nearest' THEN
     RETURN v_condition.notes->>'confusion_last_selected_target_token_id'=btrim(p_target_token_id);
   ELSE RETURN false;
 END CASE;
END;
$function$
;
CREATE OR REPLACE FUNCTION priv.srd_confusion_flee_destination_allowed(p_campaign_id bigint, p_actor_token_id text, p_destination_x integer, p_destination_y integer)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
 v_token jsonb;
 v_caster_token jsonb;
 v_condition public.srd_campaign_conditions%rowtype;
 v_character_id text;
 v_round integer;
 v_old_distance integer;
 v_new_distance integer;
BEGIN
 SELECT greatest(0,coalesce(nullif(c.combat_data->>'round','')::integer,0)),
        (SELECT t.token FROM jsonb_array_elements(coalesce(c.cba_data->'tokens','[]'::jsonb)) t(token)
         WHERE t.token->>'id'=btrim(p_actor_token_id) LIMIT 1)
 INTO v_round,v_token
 FROM public.campaigns c WHERE c.id=p_campaign_id;
 IF v_token IS NULL THEN RETURN false; END IF;
 v_character_id:=nullif(v_token->>'sourceCharacterId','');
 SELECT * INTO v_condition FROM public.srd_campaign_conditions cc
 WHERE cc.campaign_id=p_campaign_id AND cc.condition_id='confused' AND cc.active
   AND ((cc.target_kind='token' AND cc.target_id=btrim(p_actor_token_id))
     OR (cc.target_kind='character' AND cc.target_id IN (btrim(p_actor_token_id),coalesce(v_character_id,''))))
 ORDER BY CASE WHEN cc.target_kind='token' THEN 0 ELSE 1 END,cc.condition_instance_id DESC
 LIMIT 1;
 IF NOT FOUND OR v_condition.notes->>'confusion_last_outcome'<>'flee'
   OR coalesce(nullif(v_condition.notes->>'confusion_last_round','')::integer,-1)<>v_round THEN
   RETURN true;
 END IF;
 IF coalesce(v_token->>'gridX','') !~ '^[0-9]{1,3}$'
   OR coalesce(v_token->>'gridY','') !~ '^[0-9]{1,3}$'
   OR p_destination_x NOT BETWEEN 0 AND 199 OR p_destination_y NOT BETWEEN 0 AND 199 THEN
   RETURN false;
 END IF;
 SELECT t.token INTO v_caster_token
 FROM jsonb_array_elements(coalesce((SELECT c.cba_data->'tokens' FROM public.campaigns c WHERE c.id=p_campaign_id),'[]'::jsonb)) t(token)
 WHERE t.token->>'id'=v_condition.notes->>'confusion_last_selected_target_token_id'
 LIMIT 1;
 IF v_caster_token IS NULL OR coalesce(v_caster_token->>'gridX','') !~ '^[0-9]{1,3}$'
   OR coalesce(v_caster_token->>'gridY','') !~ '^[0-9]{1,3}$' THEN RETURN false; END IF;
 v_old_distance:=priv.srd_grid_footprint_distance_ft(
   (v_token->>'gridX')::integer,(v_token->>'gridY')::integer,
   priv.srd_token_grid_footprint(p_campaign_id,p_actor_token_id),
   (v_caster_token->>'gridX')::integer,(v_caster_token->>'gridY')::integer,
   priv.srd_token_grid_footprint(p_campaign_id,v_caster_token->>'id'));
 v_new_distance:=priv.srd_grid_footprint_distance_ft(
   p_destination_x,p_destination_y,
   priv.srd_token_grid_footprint(p_campaign_id,p_actor_token_id),
   (v_caster_token->>'gridX')::integer,(v_caster_token->>'gridY')::integer,
   priv.srd_token_grid_footprint(p_campaign_id,v_caster_token->>'id'));
 RETURN v_new_distance>v_old_distance;
END;
$function$
;
