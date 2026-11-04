CREATE OR REPLACE FUNCTION public.usar_furia_barbaro_srd(p_character_id text, p_action text DEFAULT 'start'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_character public.characters%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_campaign public.campaigns%ROWTYPE;
  v_barbarian_level integer := 0;
  v_uses_per_day integer := 0;
  v_uses_spent integer := 0;
  v_strength_bonus integer := 4;
  v_constitution_bonus integer := 4;
  v_will_bonus integer := 2;
  v_con_score integer := 10;
  v_con_mod integer := 0;
  v_duration integer := 1;
  v_hp_bonus integer := 0;
  v_round integer := 1;
  v_current integer := 0;
  v_order jsonb := '[]'::jsonb;
  v_actor jsonb;
  v_effect_id bigint;
  v_result jsonb;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF NULLIF(BTRIM(p_character_id),'') IS NULL THEN RAISE EXCEPTION 'Personagem inválido.'; END IF;
  IF LOWER(BTRIM(COALESCE(p_action,'start'))) NOT IN ('start','end') THEN
    RAISE EXCEPTION 'Ação inválida. Use start ou end.';
  END IF;

  SELECT * INTO v_character
    FROM public.characters
   WHERE id::text=BTRIM(p_character_id)
     AND user_id=auth.uid()
   FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Personagem não encontrado ou não pertence ao usuário.';
  END IF;
  IF v_character.campaign_id IS NULL THEN
    RAISE EXCEPTION 'O personagem precisa estar em uma campanha para usar Fúria.';
  END IF;

  SELECT * INTO v_sheet
    FROM public.srd_character_sheets
   WHERE character_id=v_character.id
   FOR UPDATE;
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

  IF COALESCE(v_barbarian_level,0)<1 THEN
    RAISE EXCEPTION 'Fúria exige pelo menos 1 nível efetivo de Bárbaro.';
  END IF;

  SELECT * INTO v_campaign
    FROM public.campaigns
   WHERE id=v_character.campaign_id
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha do personagem não encontrada.'; END IF;

  IF LOWER(BTRIM(p_action))='end' THEN
    IF UPPER(COALESCE(v_campaign.state,''))='COMBATE' THEN
      IF COALESCE(v_campaign.combat_data->>'active','false')<>'true'
         OR COALESCE(v_campaign.combat_data->>'current_turn','') !~ '^[0-9]+$' THEN
        RAISE EXCEPTION 'A iniciativa não está ativa.';
      END IF;
      v_order:=CASE WHEN jsonb_typeof(v_campaign.combat_data->'turn_order')='array'
                    THEN v_campaign.combat_data->'turn_order' ELSE '[]'::jsonb END;
      v_current:=(v_campaign.combat_data->>'current_turn')::integer;
      IF v_current<0 OR v_current>=jsonb_array_length(v_order) THEN
        RAISE EXCEPTION 'Índice de turno inválido.';
      END IF;
      v_actor:=v_order->v_current;
      IF v_actor->>'id' IS DISTINCT FROM BTRIM(p_character_id)
         OR COALESCE(v_actor->>'is_monster','false')='true' THEN
        RAISE EXCEPTION 'Apenas no próprio turno é possível encerrar a Fúria.';
      END IF;
    END IF;
    v_result:=priv.srd_end_barbarian_rage(
      v_character.campaign_id,v_character.id::text,
      UPPER(COALESCE(v_campaign.state,''))='COMBATE'
    );
    IF COALESCE((v_result->>'ended')::boolean,false) IS NOT TRUE THEN
      RAISE EXCEPTION 'O personagem não está em Fúria.';
    END IF;
    PERFORM priv.log(v_character.campaign_id,'CLASS_FEATURE',jsonb_build_object(
      'feature_key','barbarian_rage','action','end','character_id',v_character.id::text,
      'character_name',v_character.nome,'rage_hp_removed',v_result->'rage_hp_removed',
      'fatigue_applied',v_result->'fatigue_applied'
    ));
    RETURN v_result || jsonb_build_object('feature_key','barbarian_rage','action','end','action_cost','free');
  END IF;

  IF UPPER(COALESCE(v_campaign.state,''))<>'COMBATE'
     OR COALESCE(v_campaign.combat_data->>'active','false')<>'true'
     OR COALESCE(v_campaign.combat_data->>'current_turn','') !~ '^[0-9]+$' THEN
    RAISE EXCEPTION 'A Fúria só pode ser iniciada durante um combate com iniciativa ativa.';
  END IF;

  v_order:=CASE WHEN jsonb_typeof(v_campaign.combat_data->'turn_order')='array'
                THEN v_campaign.combat_data->'turn_order' ELSE '[]'::jsonb END;
  v_current:=(v_campaign.combat_data->>'current_turn')::integer;
  IF v_current<0 OR v_current>=jsonb_array_length(v_order) THEN
    RAISE EXCEPTION 'Índice de turno inválido.';
  END IF;
  v_actor:=v_order->v_current;
  IF v_actor->>'id' IS DISTINCT FROM BTRIM(p_character_id)
     OR COALESCE(v_actor->>'is_monster','false')='true' THEN
    RAISE EXCEPTION 'A Fúria só pode ser iniciada no turno do próprio personagem.';
  END IF;

  IF priv.srd_condition_has_flag(v_character.campaign_id,'character',v_character.id::text,'no_actions') THEN
    RAISE EXCEPTION 'A condição atual impede iniciar a Fúria.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM public.srd_campaign_conditions
     WHERE campaign_id=v_character.campaign_id AND target_kind='character'
       AND target_id=v_character.id::text AND active=true
       AND condition_id IN ('fatigued','exhausted')
  ) THEN
    RAISE EXCEPTION 'Um personagem fatigado ou exausto não pode entrar em Fúria.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM public.srd_campaign_effects
     WHERE campaign_id=v_character.campaign_id AND target_kind='character'
       AND target_id=v_character.id::text AND active=true
       AND effect_data->>'source_feature'='barbarian_rage'
  ) THEN
    RAISE EXCEPTION 'O personagem já está em Fúria.';
  END IF;

  v_uses_per_day:=1+FLOOR(v_barbarian_level/4.0)::integer;
  INSERT INTO public.srd_character_feature_resources(character_id,feature_key)
  VALUES(v_character.id,'barbarian_rage')
  ON CONFLICT(character_id,feature_key) DO NOTHING;

  SELECT uses_spent INTO v_uses_spent
    FROM public.srd_character_feature_resources
   WHERE character_id=v_character.id AND feature_key='barbarian_rage'
   FOR UPDATE;
  v_uses_spent:=COALESCE(v_uses_spent,0);
  IF v_uses_spent>=v_uses_per_day THEN
    RAISE EXCEPTION 'Fúria esgotada: % de % usos diários já foram consumidos.',v_uses_spent,v_uses_per_day;
  END IF;

  IF COALESCE(v_sheet.atributos->>'CON','') ~ '^[0-9]{1,3}$' THEN
    v_con_score:=(v_sheet.atributos->>'CON')::integer;
  END IF;
  v_con_mod:=FLOOR((v_con_score-10)::numeric/2)::integer;

  IF v_barbarian_level>=20 THEN
    v_strength_bonus:=8; v_constitution_bonus:=8; v_will_bonus:=4;
  ELSIF v_barbarian_level>=11 THEN
    v_strength_bonus:=6; v_constitution_bonus:=6; v_will_bonus:=3;
  END IF;

  -- Rage duration uses the Constitution modifier after the rage increase.
  v_duration:=GREATEST(1,3+FLOOR((v_con_score+v_constitution_bonus-10)::numeric/2)::integer);

  IF v_sheet.pv_max IS NULL OR v_sheet.pv_max<1 THEN
    RAISE EXCEPTION 'A ficha precisa ter PV máximo válido para iniciar a Fúria.';
  END IF;
  v_hp_bonus:=GREATEST(0,COALESCE(v_sheet.nivel,1)*(v_constitution_bonus/2));

  v_round:=CASE WHEN COALESCE(v_campaign.combat_data->>'round','') ~ '^[0-9]+$'
                THEN GREATEST(1,(v_campaign.combat_data->>'round')::integer) ELSE 1 END;

  v_effect_id:=priv.srd_apply_campaign_effect(
    v_character.campaign_id,'character',v_character.id::text,'buff',
    jsonb_build_object(
      'source_feature','barbarian_rage',
      'feature_key','barbarian_rage',
      'rage_hp_bonus',v_hp_bonus,
      'rage_level',v_barbarian_level,
      'duration_rounds',v_duration,
      'flags',jsonb_build_object('rage_active',true,'cannot_cast',true,'cannot_use_int_dex_cha_skills',true,'cannot_concentrate',true),
      'modifiers',jsonb_build_array(
        jsonb_build_object('stat','strength','value',v_strength_bonus,'bonus_type','morale'),
        jsonb_build_object('stat','constitution','value',v_constitution_bonus,'bonus_type','morale'),
        jsonb_build_object('stat','will','value',v_will_bonus,'bonus_type','morale'),
        jsonb_build_object('stat','ac','value',-2,'bonus_type','untyped')
      )
    ),
    v_duration,NULL,NULL
  );

  UPDATE public.srd_character_sheets
     SET pv_max=pv_max+v_hp_bonus,
         pv_atual=LEAST(pv_max+v_hp_bonus,COALESCE(pv_atual,pv_max)+v_hp_bonus)
   WHERE character_id=v_character.id;

  UPDATE public.srd_character_feature_resources
     SET uses_spent=v_uses_spent+1,last_reset_at=clock_timestamp(),
         payload=COALESCE(payload,'{}'::jsonb)||jsonb_build_object(
           'last_use_effect_id',v_effect_id,
           'last_use_round',v_round,
           'last_use_barbarian_level',v_barbarian_level
         )
   WHERE character_id=v_character.id AND feature_key='barbarian_rage';

  PERFORM priv.log(v_character.campaign_id,'CLASS_FEATURE',jsonb_build_object(
    'feature_key','barbarian_rage','action','start','character_id',v_character.id::text,
    'character_name',v_character.nome,'round',v_round,'duration_rounds',v_duration,
    'uses_remaining',v_uses_per_day-v_uses_spent-1,
    'strength_bonus',v_strength_bonus,'constitution_bonus',v_constitution_bonus
  ));
  RETURN jsonb_build_object(
    'feature_key','barbarian_rage',
    'action','start',
    'action_cost','free',
    'effect_instance_id',v_effect_id,
    'barbarian_level',v_barbarian_level,
    'uses_per_day',v_uses_per_day,
    'uses_spent',v_uses_spent+1,
    'uses_remaining',v_uses_per_day-v_uses_spent-1,
    'strength_bonus',v_strength_bonus,
    'constitution_bonus',v_constitution_bonus,
    'will_bonus',v_will_bonus,
    'armor_class_penalty',-2,
    'rage_hp_bonus',v_hp_bonus,
    'duration_rounds',v_duration,
    'expires_round',v_round+v_duration
  );
END;
$function$
;
