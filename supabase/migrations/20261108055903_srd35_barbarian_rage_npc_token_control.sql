
CREATE OR REPLACE FUNCTION priv.srd_end_barbarian_rage_token(
  p_campaign_id bigint, p_token_id text, p_apply_fatigue boolean DEFAULT true
) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $$
DECLARE
  v_effect public.srd_campaign_effects%ROWTYPE;
  v_campaign public.campaigns%ROWTYPE;
  v_tokens jsonb;
  v_token_count integer;
  v_token_index bigint;
  v_token jsonb;
  v_hp integer;
  v_max_hp integer;
  v_bonus integer := 0;
  v_new_hp integer;
  v_new_max integer;
  v_level integer := 0;
  v_condition text;
BEGIN
  SELECT * INTO v_effect
    FROM public.srd_campaign_effects
   WHERE campaign_id=p_campaign_id AND target_kind='token'
     AND target_id=BTRIM(p_token_id) AND active
     AND effect_data->>'source_feature'='barbarian_rage'
   ORDER BY effect_instance_id DESC LIMIT 1 FOR UPDATE;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ended',false,'reason','rage_not_active');
  END IF;

  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;

  v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array'
                 THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END;
  SELECT count(*)::integer,min(t.ordinality) INTO v_token_count,v_token_index
    FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality)
   WHERE t.token->>'id'=BTRIM(p_token_id) AND t.token->>'tipo'='npc';
  IF v_token_count<>1 THEN RAISE EXCEPTION 'Token NPC ausente ou duplicado ao encerrar Fúria.'; END IF;
  v_token:=v_tokens->(v_token_index::integer-1);

  IF COALESCE(v_effect.effect_data->>'rage_hp_bonus','') ~ '^[0-9]{1,6}$' THEN
    v_bonus:=(v_effect.effect_data->>'rage_hp_bonus')::integer;
  END IF;
  IF COALESCE(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$'
     OR COALESCE(v_token->>'hp','') !~ '^[0-9]{1,6}$' THEN
    RAISE EXCEPTION 'PV do token NPC inválidos; Fúria não foi encerrada.';
  END IF;
  v_max_hp:=(v_token->>'maxHp')::integer;
  v_hp:=(v_token->>'hp')::integer;
  v_new_max:=GREATEST(1,v_max_hp-v_bonus);
  v_new_hp:=GREATEST(0,LEAST(v_new_max,v_hp-v_bonus));

  SELECT COALESCE(NULLIF(v_effect.effect_data->>'rage_level','')::integer,0)
    INTO v_level;

  UPDATE public.srd_campaign_effects SET active=false
   WHERE effect_instance_id=v_effect.effect_instance_id;

  SELECT COALESCE(jsonb_agg(
    CASE WHEN t.ordinality=v_token_index
      THEN t.token || jsonb_build_object('hp',v_new_hp,'maxHp',v_new_max)
      ELSE t.token END ORDER BY t.ordinality
  ),'[]'::jsonb) INTO v_tokens
    FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality);
  UPDATE public.campaigns
     SET cba_data=COALESCE(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens)
   WHERE id=p_campaign_id;

  IF p_apply_fatigue AND v_level<17 THEN
    IF EXISTS (
      SELECT 1 FROM public.srd_campaign_conditions
       WHERE campaign_id=p_campaign_id AND target_kind='token'
         AND target_id=BTRIM(p_token_id) AND condition_id='exhausted' AND active
    ) THEN
      v_condition:=NULL;
    ELSIF EXISTS (
      SELECT 1 FROM public.srd_campaign_conditions
       WHERE campaign_id=p_campaign_id AND target_kind='token'
         AND target_id=BTRIM(p_token_id) AND condition_id='fatigued' AND active
    ) THEN
      v_condition:='exhausted';
    ELSE
      v_condition:='fatigued';
    END IF;
    IF v_condition IS NOT NULL THEN
      IF v_condition='exhausted' THEN
        UPDATE public.srd_campaign_conditions SET active=false
         WHERE campaign_id=p_campaign_id AND target_kind='token'
           AND target_id=BTRIM(p_token_id) AND condition_id='fatigued' AND active;
      END IF;
      PERFORM priv.srd_apply_campaign_condition(
        p_campaign_id,'token',BTRIM(p_token_id),v_condition,NULL,
        jsonb_build_object('source_feature','barbarian_rage','reason','rage_ended'),NULL
      );
    END IF;
  END IF;

  RETURN jsonb_build_object('ended',true,'rage_hp_removed',v_bonus,
    'hp',v_new_hp,'max_hp',v_new_max,'fatigue_applied',p_apply_fatigue AND v_level<17);
END;
$$;

CREATE OR REPLACE FUNCTION public.consultar_furia_barbaro_npc_srd(
  p_campaign_id bigint, p_token_id text
) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $$
DECLARE
  v_campaign public.campaigns%ROWTYPE;
  v_token jsonb;
  v_token_count integer;
  v_character_id text;
  v_character public.characters%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_level integer:=0;
  v_uses_day integer:=0;
  v_uses_spent integer:=0;
  v_active boolean:=false;
  v_expiry integer;
  v_round integer:=1;
  v_order jsonb:='[]'::jsonb;
  v_turn integer:=-1;
  v_actor jsonb;
  v_can_start boolean:=false;
  v_can_end boolean:=false;
  v_fatigued boolean:=false;
  v_no_actions boolean:=false;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre autenticado pode controlar habilidades de NPC.';
  END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;

  SELECT count(*)::integer,min(t.token) INTO v_token_count,v_token
    FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array'
      THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END) t(token)
   WHERE t.token->>'id'=BTRIM(p_token_id) AND t.token->>'tipo'='npc';
  IF v_token_count<>1 THEN RAISE EXCEPTION 'Token NPC não encontrado ou duplicado.'; END IF;
  v_character_id:=NULLIF(v_token->>'sourceCharacterId','');
  IF v_character_id IS NULL THEN RAISE EXCEPTION 'Este NPC não está vinculado a uma ficha de origem.'; END IF;

  SELECT * INTO v_character FROM public.characters
   WHERE id::text=v_character_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha de origem não encontrada.'; END IF;
  SELECT * INTO v_sheet FROM public.srd_character_sheets WHERE character_id=v_character.id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD de origem não encontrada.'; END IF;

  SELECT COALESCE(
    MAX(cl.class_level) FILTER (WHERE cls.class_key='barbarian'),
    CASE WHEN NOT EXISTS(SELECT 1 FROM public.srd_character_class_levels lv WHERE lv.character_id=v_sheet.character_id)
      AND v_sheet.classe_id='barbaro' THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
  ) INTO v_level
  FROM public.srd_character_sheets sh
  LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
  LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
  WHERE sh.character_id=v_sheet.character_id
  GROUP BY sh.character_id,sh.classe_id,sh.nivel;
  v_level:=COALESCE(v_level,0);
  IF v_level<1 THEN RETURN jsonb_build_object('eligible',false,'barbarian_level',0,'active',false); END IF;

  v_uses_day:=1+FLOOR(v_level/4.0)::integer;
  SELECT COALESCE(uses_spent,0) INTO v_uses_spent
    FROM public.srd_character_feature_resources
   WHERE character_id=v_character.id AND feature_key='barbarian_rage';

  v_round:=CASE WHEN COALESCE(v_campaign.combat_data->>'round','') ~ '^[0-9]+$'
    THEN GREATEST(1,(v_campaign.combat_data->>'round')::integer) ELSE 1 END;
  v_order:=CASE WHEN jsonb_typeof(v_campaign.combat_data->'turn_order')='array'
    THEN v_campaign.combat_data->'turn_order' ELSE '[]'::jsonb END;
  IF COALESCE(v_campaign.combat_data->>'current_turn','') ~ '^[0-9]+$' THEN
    v_turn:=(v_campaign.combat_data->>'current_turn')::integer;
  END IF;
  IF v_turn>=0 AND v_turn<jsonb_array_length(v_order) THEN v_actor:=v_order->v_turn; END IF;

  SELECT EXISTS(SELECT 1 FROM public.srd_campaign_effects
    WHERE campaign_id=p_campaign_id AND target_kind='token' AND target_id=BTRIM(p_token_id)
      AND active AND effect_data->>'source_feature'='barbarian_rage'),
    (SELECT expires_round FROM public.srd_campaign_effects
      WHERE campaign_id=p_campaign_id AND target_kind='token' AND target_id=BTRIM(p_token_id)
        AND active AND effect_data->>'source_feature'='barbarian_rage'
      ORDER BY effect_instance_id DESC LIMIT 1)
    INTO v_active,v_expiry;

  v_fatigued:=EXISTS(SELECT 1 FROM public.srd_campaign_conditions
    WHERE campaign_id=p_campaign_id AND target_kind='token' AND target_id=BTRIM(p_token_id)
      AND active AND condition_id IN ('fatigued','exhausted'));
  v_no_actions:=priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'no_actions');

  v_can_start:=UPPER(COALESCE(v_campaign.state,''))='COMBATE'
    AND COALESCE(v_campaign.combat_data->>'active','false')='true'
    AND v_actor->>'id'=BTRIM(p_token_id)
    AND COALESCE(v_actor->>'is_monster','false')='true'
    AND NOT v_active AND NOT v_fatigued AND NOT v_no_actions
    AND COALESCE(v_uses_spent,0)<v_uses_day;
  v_can_end:=v_active AND (
    UPPER(COALESCE(v_campaign.state,''))<>'COMBATE'
    OR (COALESCE(v_campaign.combat_data->>'active','false')='true'
      AND v_actor->>'id'=BTRIM(p_token_id)
      AND COALESCE(v_actor->>'is_monster','false')='true')
  );

  RETURN jsonb_build_object('eligible',true,'barbarian_level',v_level,
    'uses_per_day',v_uses_day,'uses_spent',COALESCE(v_uses_spent,0),
    'uses_remaining',GREATEST(0,v_uses_day-COALESCE(v_uses_spent,0)),
    'active',v_active,'expires_round',v_expiry,
    'rounds_remaining',CASE WHEN v_active AND v_expiry IS NOT NULL THEN GREATEST(0,v_expiry-v_round) ELSE 0 END,
    'can_start',v_can_start,'can_end',v_can_end);
END;
$$;

CREATE OR REPLACE FUNCTION public.usar_furia_barbaro_npc_srd(
  p_campaign_id bigint, p_token_id text, p_action text DEFAULT 'start'
) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $$
DECLARE
  v_campaign public.campaigns%ROWTYPE;
  v_token jsonb;
  v_tokens jsonb;
  v_token_count integer;
  v_token_index bigint;
  v_character_id text;
  v_character public.characters%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_level integer:=0;
  v_uses_day integer:=0;
  v_uses_spent integer:=0;
  v_str_bonus integer:=4;
  v_con_bonus integer:=4;
  v_will_bonus integer:=2;
  v_con integer:=10;
  v_duration integer:=1;
  v_hp_bonus integer:=0;
  v_hp integer;
  v_max_hp integer;
  v_round integer:=1;
  v_order jsonb:='[]'::jsonb;
  v_turn integer:=-1;
  v_actor jsonb;
  v_effect_id bigint;
  v_result jsonb;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre autenticado pode controlar habilidades de NPC.';
  END IF;
  IF LOWER(BTRIM(COALESCE(p_action,'start'))) NOT IN ('start','end') THEN
    RAISE EXCEPTION 'Ação inválida. Use start ou end.';
  END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;

  v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array'
    THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END;
  SELECT count(*)::integer,min(t.ordinality) INTO v_token_count,v_token_index
    FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality)
   WHERE t.token->>'id'=BTRIM(p_token_id) AND t.token->>'tipo'='npc';
  IF v_token_count<>1 THEN RAISE EXCEPTION 'Token NPC não encontrado ou duplicado.'; END IF;
  v_token:=v_tokens->(v_token_index::integer-1);
  v_character_id:=NULLIF(v_token->>'sourceCharacterId','');
  IF v_character_id IS NULL THEN RAISE EXCEPTION 'Este NPC não está vinculado a uma ficha de origem.'; END IF;
  SELECT * INTO v_character FROM public.characters WHERE id::text=v_character_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha de origem não encontrada.'; END IF;
  SELECT * INTO v_sheet FROM public.srd_character_sheets WHERE character_id=v_character.id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD de origem não encontrada.'; END IF;

  SELECT COALESCE(
    MAX(cl.class_level) FILTER (WHERE cls.class_key='barbarian'),
    CASE WHEN NOT EXISTS(SELECT 1 FROM public.srd_character_class_levels lv WHERE lv.character_id=v_sheet.character_id)
      AND v_sheet.classe_id='barbaro' THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
  ) INTO v_level
  FROM public.srd_character_sheets sh
  LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
  LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
  WHERE sh.character_id=v_sheet.character_id
  GROUP BY sh.character_id,sh.classe_id,sh.nivel;
  v_level:=COALESCE(v_level,0);
  IF v_level<1 THEN RAISE EXCEPTION 'Fúria exige pelo menos 1 nível efetivo de Bárbaro.'; END IF;

  v_round:=CASE WHEN COALESCE(v_campaign.combat_data->>'round','') ~ '^[0-9]+$'
    THEN GREATEST(1,(v_campaign.combat_data->>'round')::integer) ELSE 1 END;
  v_order:=CASE WHEN jsonb_typeof(v_campaign.combat_data->'turn_order')='array'
    THEN v_campaign.combat_data->'turn_order' ELSE '[]'::jsonb END;
  IF COALESCE(v_campaign.combat_data->>'current_turn','') ~ '^[0-9]+$' THEN
    v_turn:=(v_campaign.combat_data->>'current_turn')::integer;
  END IF;
  IF v_turn>=0 AND v_turn<jsonb_array_length(v_order) THEN v_actor:=v_order->v_turn; END IF;

  IF LOWER(BTRIM(p_action))='end' THEN
    IF UPPER(COALESCE(v_campaign.state,''))='COMBATE'
       AND NOT (COALESCE(v_campaign.combat_data->>'active','false')='true'
         AND v_actor->>'id'=BTRIM(p_token_id)
         AND COALESCE(v_actor->>'is_monster','false')='true') THEN
      RAISE EXCEPTION 'A Fúria só pode ser encerrada no turno do NPC durante o combate.';
    END IF;
    v_result:=priv.srd_end_barbarian_rage_token(
      p_campaign_id,BTRIM(p_token_id),UPPER(COALESCE(v_campaign.state,''))='COMBATE'
    );
    IF COALESCE((v_result->>'ended')::boolean,false) IS NOT TRUE THEN
      RAISE EXCEPTION 'O NPC não está em Fúria.';
    END IF;
    PERFORM priv.log(p_campaign_id,'CLASS_FEATURE',jsonb_build_object(
      'feature_key','barbarian_rage','action','end','token_id',BTRIM(p_token_id),
      'character_id',v_character_id,'character_name',v_token->>'nome',
      'rage_hp_removed',v_result->'rage_hp_removed','fatigue_applied',v_result->'fatigue_applied'
    ));
    RETURN v_result||jsonb_build_object('feature_key','barbarian_rage','action','end','action_cost','free');
  END IF;

  IF UPPER(COALESCE(v_campaign.state,''))<>'COMBATE'
     OR COALESCE(v_campaign.combat_data->>'active','false')<>'true'
     OR v_actor->>'id' IS DISTINCT FROM BTRIM(p_token_id)
     OR COALESCE(v_actor->>'is_monster','false')<>'true' THEN
    RAISE EXCEPTION 'A Fúria só pode ser iniciada no turno do NPC em combate ativo.';
  END IF;
  IF priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'no_actions') THEN
    RAISE EXCEPTION 'A condição atual impede iniciar a Fúria.';
  END IF;
  IF EXISTS(SELECT 1 FROM public.srd_campaign_conditions
    WHERE campaign_id=p_campaign_id AND target_kind='token' AND target_id=BTRIM(p_token_id)
      AND active AND condition_id IN ('fatigued','exhausted')) THEN
    RAISE EXCEPTION 'Um NPC fatigado ou exausto não pode entrar em Fúria.';
  END IF;
  IF EXISTS(SELECT 1 FROM public.srd_campaign_effects
    WHERE campaign_id=p_campaign_id AND target_kind='token' AND target_id=BTRIM(p_token_id)
      AND active AND effect_data->>'source_feature'='barbarian_rage') THEN
    RAISE EXCEPTION 'O NPC já está em Fúria.';
  END IF;

  v_uses_day:=1+FLOOR(v_level/4.0)::integer;
  INSERT INTO public.srd_character_feature_resources(character_id,feature_key)
  VALUES(v_character.id,'barbarian_rage') ON CONFLICT(character_id,feature_key) DO NOTHING;
  SELECT uses_spent INTO v_uses_spent FROM public.srd_character_feature_resources
   WHERE character_id=v_character.id AND feature_key='barbarian_rage' FOR UPDATE;
  v_uses_spent:=COALESCE(v_uses_spent,0);
  IF v_uses_spent>=v_uses_day THEN RAISE EXCEPTION 'Fúria esgotada: % de % usos diários.',v_uses_spent,v_uses_day; END IF;

  IF COALESCE(v_sheet.atributos->>'CON','') ~ '^[0-9]{1,3}$' THEN
    v_con:=(v_sheet.atributos->>'CON')::integer;
  END IF;
  IF v_level>=20 THEN v_str_bonus:=8;v_con_bonus:=8;v_will_bonus:=4;
  ELSIF v_level>=11 THEN v_str_bonus:=6;v_con_bonus:=6;v_will_bonus:=3; END IF;
  v_duration:=GREATEST(1,3+FLOOR((v_con+v_con_bonus-10)::numeric/2)::integer);
  v_hp_bonus:=GREATEST(0,COALESCE(v_sheet.nivel,1)*(v_con_bonus/2));

  IF COALESCE(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$'
     OR COALESCE(v_token->>'hp','') !~ '^[0-9]{1,6}$' THEN
    RAISE EXCEPTION 'O token NPC precisa ter PV atuais e máximos válidos.';
  END IF;
  v_max_hp:=(v_token->>'maxHp')::integer;
  v_hp:=(v_token->>'hp')::integer;
  IF v_max_hp+v_hp_bonus>999999 THEN RAISE EXCEPTION 'PV temporários excedem o limite suportado.'; END IF;

  v_effect_id:=priv.srd_apply_campaign_effect(
    p_campaign_id,'token',BTRIM(p_token_id),'buff',
    jsonb_build_object(
      'source_feature','barbarian_rage','feature_key','barbarian_rage',
      'source_character_id',v_character_id,'rage_hp_bonus',v_hp_bonus,
      'rage_level',v_level,'duration_rounds',v_duration,
      'flags',jsonb_build_object('rage_active',true,'cannot_cast',true,
        'cannot_use_int_dex_cha_skills',true,'cannot_concentrate',true),
      'modifiers',jsonb_build_array(
        jsonb_build_object('stat','strength','value',v_str_bonus,'bonus_type','morale'),
        jsonb_build_object('stat','constitution','value',v_con_bonus,'bonus_type','morale'),
        jsonb_build_object('stat','will','value',v_will_bonus,'bonus_type','morale'),
        jsonb_build_object('stat','ac','value',-2,'bonus_type','untyped')
      )
    ),v_duration,NULL,NULL
  );

  v_token:=v_token||jsonb_build_object('hp',LEAST(v_max_hp+v_hp_bonus,v_hp+v_hp_bonus),
    'maxHp',v_max_hp+v_hp_bonus);
  v_tokens:=jsonb_set(v_tokens,ARRAY[(v_token_index-1)::text],v_token,false);
  UPDATE public.campaigns SET cba_data=COALESCE(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens)
   WHERE id=p_campaign_id;

  UPDATE public.srd_character_feature_resources
     SET uses_spent=v_uses_spent+1,last_reset_at=clock_timestamp(),
         payload=COALESCE(payload,'{}'::jsonb)||jsonb_build_object(
           'last_use_effect_id',v_effect_id,'last_use_round',v_round,
           'last_use_barbarian_level',v_level)
   WHERE character_id=v_character.id AND feature_key='barbarian_rage';

  PERFORM priv.log(p_campaign_id,'CLASS_FEATURE',jsonb_build_object(
    'feature_key','barbarian_rage','action','start','token_id',BTRIM(p_token_id),
    'character_id',v_character_id,'character_name',v_token->>'nome',
    'round',v_round,'duration_rounds',v_duration,'uses_remaining',v_uses_day-v_uses_spent-1,
    'strength_bonus',v_str_bonus,'constitution_bonus',v_con_bonus));
  RETURN jsonb_build_object('feature_key','barbarian_rage','action','start',
    'action_cost','free','effect_instance_id',v_effect_id,'barbarian_level',v_level,
    'uses_per_day',v_uses_day,'uses_spent',v_uses_spent+1,'uses_remaining',v_uses_day-v_uses_spent-1,
    'strength_bonus',v_str_bonus,'constitution_bonus',v_con_bonus,'will_bonus',v_will_bonus,
    'armor_class_penalty',-2,'rage_hp_bonus',v_hp_bonus,'duration_rounds',v_duration,
    'expires_round',v_round+v_duration,'cba_data',COALESCE((SELECT cba_data FROM public.campaigns WHERE id=p_campaign_id),'{}'::jsonb));
END;
$$;

CREATE OR REPLACE FUNCTION public.srd_expire_campaign_conditions(p_campaign_id bigint)
RETURNS integer
LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $$
DECLARE
  v_round integer;
  v_count integer:=0;
  v_effect_count integer:=0;
  v_rage_count integer:=0;
  v_rage record;
  v_result jsonb;
BEGIN
  IF auth.uid() IS NULL OR (
    public.my_role(p_campaign_id) IS NULL AND NOT EXISTS(
      SELECT 1 FROM public.campaigns c WHERE c.id=p_campaign_id AND c.owner_id=auth.uid()
    )
  ) THEN RAISE EXCEPTION 'Sem acesso à campanha.'; END IF;

  SELECT COALESCE(NULLIF(combat_data->>'round','')::integer,0)
    INTO v_round FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND OR v_round<1 THEN RETURN 0; END IF;

  FOR v_rage IN
    SELECT e.target_id FROM public.srd_campaign_effects e
     WHERE e.campaign_id=p_campaign_id AND e.target_kind='character'
       AND e.active=true AND e.expires_round IS NOT NULL
       AND e.expires_round<=v_round AND e.effect_data->>'source_feature'='barbarian_rage'
     FOR UPDATE
  LOOP
    PERFORM priv.srd_end_barbarian_rage(p_campaign_id,v_rage.target_id,true);
    v_rage_count:=v_rage_count+1;
  END LOOP;

  FOR v_rage IN
    SELECT e.target_id FROM public.srd_campaign_effects e
     WHERE e.campaign_id=p_campaign_id AND e.target_kind='token'
       AND e.active=true AND e.expires_round IS NOT NULL
       AND e.expires_round<=v_round AND e.effect_data->>'source_feature'='barbarian_rage'
     FOR UPDATE
  LOOP
    v_result:=priv.srd_end_barbarian_rage_token(p_campaign_id,v_rage.target_id,true);
    IF COALESCE((v_result->>'ended')::boolean,false) THEN v_rage_count:=v_rage_count+1; END IF;
  END LOOP;

  UPDATE public.srd_campaign_conditions SET active=false
   WHERE campaign_id=p_campaign_id AND active=true
     AND expires_round IS NOT NULL AND expires_round<=v_round;
  GET DIAGNOSTICS v_count=ROW_COUNT;

  UPDATE public.srd_campaign_effects SET active=false
   WHERE campaign_id=p_campaign_id AND active=true
     AND expires_round IS NOT NULL AND expires_round<=v_round;
  GET DIAGNOSTICS v_effect_count=ROW_COUNT;

  RETURN v_count+v_effect_count+v_rage_count;
END;
$$;

REVOKE ALL ON FUNCTION public.consultar_furia_barbaro_npc_srd(bigint,text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.consultar_furia_barbaro_npc_srd(bigint,text) TO authenticated;
REVOKE ALL ON FUNCTION public.usar_furia_barbaro_npc_srd(bigint,text,text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.usar_furia_barbaro_npc_srd(bigint,text,text) TO authenticated;
REVOKE ALL ON FUNCTION priv.srd_end_barbarian_rage_token(bigint,text,boolean) FROM PUBLIC,anon,authenticated;
