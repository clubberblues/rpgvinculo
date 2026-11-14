CREATE OR REPLACE FUNCTION public.consultar_furia_barbaro_srd(p_character_id text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $function$
DECLARE
  v_character public.characters%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_campaign public.campaigns%ROWTYPE;
  v_barbarian_level integer:=0;
  v_uses_per_day integer:=0;
  v_uses_spent integer:=0;
  v_active boolean:=false;
  v_expires_round integer;
  v_round integer:=0;
  v_current integer:=-1;
  v_order jsonb:='[]'::jsonb;
  v_actor jsonb;
  v_can_start boolean:=false;
  v_can_end boolean:=false;
  v_fatigued boolean:=false;
  v_no_actions boolean:=false;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  SELECT * INTO v_character FROM public.characters
   WHERE id::text=BTRIM(p_character_id) AND user_id=auth.uid();
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou não pertence ao usuário.'; END IF;
  SELECT * INTO v_sheet FROM public.srd_character_sheets
   WHERE character_id=v_character.id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD do personagem não encontrada.'; END IF;

  SELECT COALESCE(
    MAX(cl.class_level) FILTER (WHERE cls.class_key='barbarian'),
    CASE WHEN NOT EXISTS (
      SELECT 1 FROM public.srd_character_class_levels any_level
       WHERE any_level.character_id=v_sheet.character_id
    ) AND v_sheet.classe_id='barbaro'
    THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
  )
    INTO v_barbarian_level
    FROM public.srd_character_sheets sh
    LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
    LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
   WHERE sh.character_id=v_sheet.character_id
   GROUP BY sh.character_id,sh.classe_id,sh.nivel;

  v_barbarian_level:=COALESCE(v_barbarian_level,0);
  IF v_barbarian_level<1 THEN
    RETURN jsonb_build_object('eligible',false,'barbarian_level',0,'active',false);
  END IF;

  v_uses_per_day:=1+FLOOR(v_barbarian_level/4.0)::integer;
  SELECT COALESCE(uses_spent,0) INTO v_uses_spent
    FROM public.srd_character_feature_resources
   WHERE character_id=v_character.id AND feature_key='barbarian_rage';

  IF v_character.campaign_id IS NOT NULL THEN
    SELECT * INTO v_campaign FROM public.campaigns WHERE id=v_character.campaign_id;
    IF FOUND THEN
      v_round:=CASE WHEN COALESCE(v_campaign.combat_data->>'round','') ~ '^[0-9]+$'
                    THEN GREATEST(1,(v_campaign.combat_data->>'round')::integer) ELSE 1 END;
      v_order:=CASE WHEN jsonb_typeof(v_campaign.combat_data->'turn_order')='array'
                    THEN v_campaign.combat_data->'turn_order' ELSE '[]'::jsonb END;
      IF COALESCE(v_campaign.combat_data->>'current_turn','') ~ '^[0-9]+$' THEN
        v_current:=(v_campaign.combat_data->>'current_turn')::integer;
      END IF;
      IF v_current>=0 AND v_current<jsonb_array_length(v_order) THEN
        v_actor:=v_order->v_current;
      END IF;
      v_can_start:=UPPER(COALESCE(v_campaign.state,''))='COMBATE'
        AND COALESCE(v_campaign.combat_data->>'active','false')='true'
        AND v_actor->>'id'=v_character.id::text
        AND COALESCE(v_actor->>'is_monster','false')<>'true';
      v_can_end:=v_can_start OR UPPER(COALESCE(v_campaign.state,''))<>'COMBATE';
    END IF;
    SELECT EXISTS (
      SELECT 1 FROM public.srd_campaign_effects
       WHERE campaign_id=v_character.campaign_id AND target_kind='character'
         AND target_id=v_character.id::text AND active=true
         AND effect_data->>'source_feature'='barbarian_rage'
    ), (
      SELECT NULLIF(expires_round,0) FROM public.srd_campaign_effects
       WHERE campaign_id=v_character.campaign_id AND target_kind='character'
         AND target_id=v_character.id::text AND active=true
         AND effect_data->>'source_feature'='barbarian_rage'
       ORDER BY effect_instance_id DESC LIMIT 1
    ) INTO v_active,v_expires_round;
    v_fatigued:=EXISTS (
      SELECT 1 FROM public.srd_campaign_conditions
       WHERE campaign_id=v_character.campaign_id AND target_kind='character'
         AND target_id=v_character.id::text AND active=true
         AND condition_id IN ('fatigued','exhausted')
    );
    v_no_actions:=priv.srd_condition_has_flag(v_character.campaign_id,'character',v_character.id::text,'no_actions');
  END IF;

  v_can_start:=v_can_start AND NOT v_active AND NOT v_fatigued AND NOT v_no_actions
    AND COALESCE(v_uses_spent,0)<v_uses_per_day;
  v_can_end:=v_can_end AND v_active;

  RETURN jsonb_build_object(
    'eligible',true,
    'barbarian_level',v_barbarian_level,
    'uses_per_day',v_uses_per_day,
    'uses_spent',COALESCE(v_uses_spent,0),
    'uses_remaining',GREATEST(0,v_uses_per_day-COALESCE(v_uses_spent,0)),
    'active',v_active,
    'expires_round',v_expires_round,
    'rounds_remaining',CASE WHEN v_active AND v_expires_round IS NOT NULL THEN GREATEST(0,v_expires_round-v_round) ELSE 0 END,
    'can_start',v_can_start,
    'can_end',v_can_end,
    'tier',CASE WHEN v_barbarian_level>=20 THEN 'mighty' WHEN v_barbarian_level>=11 THEN 'greater' ELSE 'normal' END
  );
END;
$function$;

REVOKE ALL ON FUNCTION public.consultar_furia_barbaro_srd(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.consultar_furia_barbaro_srd(text) TO authenticated;
