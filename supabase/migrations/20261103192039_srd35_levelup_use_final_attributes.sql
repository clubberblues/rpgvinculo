CREATE OR REPLACE FUNCTION public.concluir_avanco_nivel_personagem_srd(p_campaign_id bigint, p_character_id text, p_hit_die_roll integer, p_skill_ranks jsonb DEFAULT '{}'::jsonb, p_feats jsonb DEFAULT '[]'::jsonb, p_attribute text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  v_owner UUID;
  v_campaign BIGINT;
  v_xp INTEGER;
  v_pending INTEGER;
  v_level INTEGER;
  v_next_level INTEGER;
  v_required_level INTEGER;
  v_class public.srd_classes%ROWTYPE;
  v_race public.srd_races%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_attrs JSONB;
  v_skill_state JSONB;
  v_feat_state JSONB;
  v_class_skills JSONB;
  v_skill RECORD;
  v_skill_id TEXT;
  v_skill_name TEXT;
  v_is_class_skill BOOLEAN;
  v_old_rank NUMERIC;
  v_added_rank NUMERIC;
  v_new_rank NUMERIC;
  v_max_rank NUMERIC;
  v_skill_points INTEGER;
  v_spent NUMERIC := 0;
  v_skill_cost NUMERIC;
  v_con_mod INTEGER;
  v_con_mod_old INTEGER;
  v_int_mod INTEGER;
  v_int_mod_old INTEGER;
  v_die INTEGER;
  v_hit_die_roll INTEGER;
  v_hp_gain INTEGER;
  v_hp_delta INTEGER;
  v_hp_max INTEGER;
  v_hp_current INTEGER;
  v_general_feats INTEGER := 0;
  v_bonus_kind TEXT := NULL;
  v_choice_count INTEGER := 0;
  v_choice RECORD;
  v_feat public.srd_feats%ROWTYPE;
  v_feat_id TEXT;
  v_req JSONB;
  v_req_item TEXT;
  v_owned_ids TEXT[] := ARRAY[]::TEXT[];
  v_selected_ids TEXT[] := ARRAY[]::TEXT[];
  v_feat_parameter TEXT;
  v_feat_type TEXT;
  v_parameter_type TEXT;
  v_owned_parameter TEXT;
  v_param_key TEXT;
  v_param_expected TEXT;
  v_weapon_name TEXT;
  v_weapon_details JSONB;
  v_weapon_prof TEXT;
  v_has_proficiency BOOLEAN;
  v_conditional RECORD;
  v_bab INTEGER;
  v_caster_level INTEGER;
  v_minimum INTEGER;
  v_json_value JSONB;
  v_feature_names JSONB := '[]'::jsonb;
  v_human BOOLEAN;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF p_campaign_id IS NULL OR NULLIF(BTRIM(p_character_id),'') IS NULL THEN
    RAISE EXCEPTION 'Campanha e personagem são obrigatórios.';
  END IF;
  IF p_skill_ranks IS NULL OR jsonb_typeof(p_skill_ranks) <> 'object' THEN
    RAISE EXCEPTION 'As graduações de perícia precisam ser um objeto JSON.';
  END IF;
  IF p_feats IS NULL OR jsonb_typeof(p_feats) <> 'array' THEN
    RAISE EXCEPTION 'As escolhas de talentos precisam ser uma lista.';
  END IF;

  SELECT c.user_id,c.campaign_id,c.xp
    INTO v_owner,v_campaign,v_xp
    FROM public.characters c
   WHERE c.id::text=BTRIM(p_character_id)
   FOR UPDATE;
  IF NOT FOUND OR v_campaign IS DISTINCT FROM p_campaign_id THEN
    RAISE EXCEPTION 'Personagem não encontrado nesta campanha.';
  END IF;
  IF v_owner IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'Somente o dono da ficha pode aplicar seu avanço de nível.';
  END IF;

  SELECT s.* INTO v_sheet
    FROM public.srd_character_sheets s
   WHERE s.character_id::text=BTRIM(p_character_id)
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha D&D 3.5 não encontrada.'; END IF;

  v_level:=GREATEST(1,COALESCE(v_sheet.nivel,1));
  v_pending:=GREATEST(0,COALESCE(v_sheet.niveis_pendentes,0));
  IF v_pending<1 THEN RAISE EXCEPTION 'Não há nível pendente para aplicar.'; END IF;
  IF v_level>=20 THEN RAISE EXCEPTION 'O personagem já atingiu o nível máximo 20.'; END IF;
  v_required_level:=LEAST(20,public.nivel_de_xp(GREATEST(0,COALESCE(v_xp,v_sheet.xp,0))));
  v_next_level:=v_level+1;
  IF v_required_level<v_next_level THEN
    RAISE EXCEPTION 'O XP atual ainda não libera o próximo nível.';
  END IF;

  SELECT c.* INTO v_class FROM public.srd_classes c WHERE c.id=v_sheet.classe_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Classe SRD da ficha não encontrada.'; END IF;
  SELECT r.* INTO v_race FROM public.srd_races r WHERE r.id=v_sheet.raca_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Raça SRD da ficha não encontrada.'; END IF;

  v_die:=GREATEST(1,COALESCE(v_class.dado_vida,0));
  IF p_hit_die_roll IS NULL OR p_hit_die_roll < 1 OR p_hit_die_roll > v_die THEN
    RAISE EXCEPTION 'O resultado manual do dado de vida deve estar entre 1 e %.',v_die;
  END IF;
  v_hit_die_roll:=p_hit_die_roll;

  v_attrs:=COALESCE(v_sheet.atributos,'{}'::jsonb);
  -- Sheet attributes already include racial adjustments; never apply them twice.
  v_con_mod_old:=FLOOR((COALESCE(NULLIF(v_attrs->>'CON','')::numeric,10)-10)/2)::integer;
  v_int_mod_old:=FLOOR((COALESCE(NULLIF(v_attrs->>'INT','')::numeric,10)-10)/2)::integer;
  v_human:=public.srd35_normalizar_parametro_talento(v_race.id||' '||v_race.nome) LIKE '%humano%';

  -- Apply the character-level ability increase before validating feats and calculating skill points.
  IF MOD(v_next_level,4)=0 THEN
    IF p_attribute NOT IN ('FOR','DES','CON','INT','SAB','CAR') THEN
      RAISE EXCEPTION 'Escolha um atributo para receber +1 neste nível.';
    END IF;
    v_attrs:=jsonb_set(v_attrs,ARRAY[p_attribute],to_jsonb(COALESCE(NULLIF(v_attrs->>p_attribute,'')::integer,10)+1),true);
  ELSIF NULLIF(BTRIM(COALESCE(p_attribute,'')),'') IS NOT NULL THEN
    RAISE EXCEPTION 'Este nível não concede aumento de atributo.';
  END IF;
  v_con_mod:=FLOOR((COALESCE(NULLIF(v_attrs->>'CON','')::numeric,10)-10)/2)::integer;
  v_int_mod:=FLOOR((COALESCE(NULLIF(v_attrs->>'INT','')::numeric,10)-10)/2)::integer;

  -- INT increases apply retroactively to all class-level skill point awards.
  v_skill_points:=GREATEST(1,COALESCE(v_class.pericias_por_nivel,0)+v_int_mod)
    +(CASE WHEN v_human THEN 1 ELSE 0 END)
    +GREATEST(0,v_int_mod-v_int_mod_old)*v_level;
  v_skill_state:=COALESCE(v_sheet.pericias,'{}'::jsonb);
  v_class_skills:=COALESCE(v_class.pericias_classe,'[]'::jsonb);

  FOR v_skill IN
    SELECT e.key AS id,e.value AS amount,s.id AS skill_id,s.nome,s.treinada_apenas
      FROM jsonb_each(p_skill_ranks) e
      LEFT JOIN public.srd_skills s ON s.id=e.key
  LOOP
    v_skill_id:=v_skill.id;
    IF v_skill.skill_id IS NULL THEN RAISE EXCEPTION 'Perícia não encontrada: %.',v_skill_id; END IF;
    IF jsonb_typeof((p_skill_ranks->v_skill_id))<>'number' THEN
      RAISE EXCEPTION 'Graduação inválida para a perícia %.',v_skill.nome;
    END IF;
    v_added_rank:=(p_skill_ranks->>v_skill_id)::numeric;
    IF v_added_rank<0 OR v_added_rank<>round(v_added_rank*2)/2 THEN
      RAISE EXCEPTION 'Graduações para % devem ser incrementos positivos de 0,5.',v_skill.nome;
    END IF;
    IF v_added_rank=0 THEN CONTINUE; END IF;

    v_skill_name:=public.srd35_normalizar_parametro_talento(v_skill.nome);
    v_is_class_skill:=EXISTS (
      SELECT 1
        FROM jsonb_array_elements_text(v_class_skills) AS class_skill(name)
       WHERE public.srd35_normalizar_parametro_talento(class_skill.name)=v_skill_name
    ) OR (
      EXISTS (
        SELECT 1 FROM jsonb_array_elements_text(v_class_skills) AS class_skill(name)
         WHERE public.srd35_normalizar_parametro_talento(class_skill.name)='conhecimentoqualquer'
      )
      AND v_skill.nome ILIKE 'Conhecimento%'
    );
    IF v_skill_id='srd35_skill_speak_language' AND v_added_rank<>trunc(v_added_rank) THEN
      RAISE EXCEPTION 'Falar Idioma é comprado em graduações inteiras.';
    END IF;
    IF v_is_class_skill AND v_added_rank<>trunc(v_added_rank) THEN
      RAISE EXCEPTION 'A perícia de classe % exige graduações inteiras.',v_skill.nome;
    END IF;

    v_old_rank:=COALESCE(NULLIF(v_skill_state->>v_skill_id,'')::numeric,0);
    v_new_rank:=v_old_rank+v_added_rank;
    IF v_skill_id<>'srd35_skill_speak_language' THEN
      v_max_rank:=CASE WHEN v_is_class_skill THEN v_next_level+3 ELSE (v_next_level+3)/2.0 END;
      IF v_new_rank>v_max_rank THEN
        RAISE EXCEPTION 'O máximo de graduações em % no nível % é %.',v_skill.nome,v_next_level,v_max_rank;
      END IF;
    END IF;
    v_skill_cost:=CASE WHEN v_is_class_skill OR v_skill_id='srd35_skill_speak_language' THEN 1 ELSE 2 END;
    v_spent:=v_spent+(v_added_rank*v_skill_cost);
    v_skill_state:=jsonb_set(v_skill_state,ARRAY[v_skill_id],to_jsonb(v_new_rank),true);
  END LOOP;
  IF v_spent>v_skill_points THEN
    RAISE EXCEPTION 'Pontos de perícia excedidos: % de %.',v_spent,v_skill_points;
  END IF;

  -- One general feat at each 3rd character level.
  IF MOD(v_next_level,3)=0 THEN v_general_feats:=1; END IF;
  IF (v_class.id IN ('guerreiro','fighter') OR v_class.class_key='fighter') AND MOD(v_next_level,2)=0 THEN
    v_bonus_kind:='fighter';
  ELSIF (v_class.id IN ('mago','wizard') OR v_class.class_key='wizard') AND v_next_level IN (5,10,15,20) THEN
    v_bonus_kind:='wizard';
  ELSIF (v_class.id IN ('monge','monk') OR v_class.class_key='monk') AND v_next_level IN (2,6) THEN
    v_bonus_kind:='monk';
  END IF;

  v_choice_count:=v_general_feats+CASE WHEN v_bonus_kind IS NULL THEN 0 ELSE 1 END;
  IF jsonb_array_length(p_feats)<>v_choice_count THEN
    RAISE EXCEPTION 'Este nível exige % escolha(s) de talento.',v_choice_count;
  END IF;
  v_feat_state:=CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::jsonb END;
  SELECT COALESCE(array_agg(value->>'id'),'{}'::text[]) INTO v_owned_ids
    FROM jsonb_array_elements(v_feat_state) AS existing(value)
   WHERE value->>'id' IS NOT NULL;

  FOR v_choice IN SELECT value,ord FROM jsonb_array_elements(p_feats) WITH ORDINALITY AS choices(value,ord) ORDER BY ord LOOP
    IF jsonb_typeof(v_choice.value)<>'object' THEN RAISE EXCEPTION 'Escolha de talento inválida.'; END IF;
    v_feat_id:=NULLIF(BTRIM(v_choice.value->>'id'),'');
    v_feat_parameter:=BTRIM(COALESCE(v_choice.value->>'parametro',''));
    v_feat_type:=CASE WHEN v_choice.ord<=v_general_feats THEN 'general' ELSE COALESCE(v_choice.value->>'choice_type','') END;
    IF v_feat_id IS NULL THEN RAISE EXCEPTION 'Selecione todos os talentos exigidos.'; END IF;
    IF v_feat_id=ANY(v_selected_ids) THEN RAISE EXCEPTION 'Não repita o mesmo talento neste avanço.'; END IF;
    SELECT f.* INTO v_feat FROM public.srd_feats f WHERE f.id=v_feat_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Talento não encontrado: %.',v_feat_id; END IF;
    v_req:=COALESCE(v_feat.requisitos,'{}'::jsonb);

    IF v_feat_type='general' THEN
      IF COALESCE(v_req->>'type','General')<>'General' THEN
        RAISE EXCEPTION 'Escolha um talento geral para esta seleção.';
      END IF;
    ELSIF v_feat_type='fighter' AND v_bonus_kind='fighter' THEN
      IF v_feat_id NOT IN (
        'srd35_feat_blind_fight','srd35_feat_cleave','srd35_feat_combat_expertise','srd35_feat_deflect_arrows',
        'esquiva','srd35_feat_far_shot','srd35_feat_great_cleave','srd35_feat_improved_bull_rush',
        'srd35_feat_improved_critical','srd35_feat_improved_disarm','srd35_feat_improved_feint',
        'srd35_feat_improved_grapple','iniciativa_aprimorada','srd35_feat_improved_overrun',
        'srd35_feat_improved_precise_shot','srd35_feat_improved_shield_bash','srd35_feat_improved_sunder',
        'srd35_feat_improved_trip','srd35_feat_improved_two_weapon_fighting','srd35_feat_manyshot',
        'srd35_feat_mobility','srd35_feat_mounted_archery','srd35_feat_mounted_combat',
        'srd35_feat_point_blank_shot','ataque_poderoso','srd35_feat_precise_shot','srd35_feat_quick_draw',
        'srd35_feat_rapid_reload','srd35_feat_rapid_shot','srd35_feat_ride_by_attack',
        'srd35_feat_shot_on_the_run','srd35_feat_spring_attack','srd35_feat_spirited_charge',
        'srd35_feat_trample','srd35_feat_two_weapon_fighting','srd35_feat_weapon_finesse',
        'foco_em_arma','srd35_feat_weapon_specialization','srd35_feat_greater_weapon_focus',
        'srd35_feat_greater_weapon_specialization','srd35_feat_whirlwind_attack',
        'srd35_feat_improved_unarmed_strike','reflexos_de_combate','srd35_feat_stunning_fist'
      ) THEN RAISE EXCEPTION 'Este talento não está na lista de talentos adicionais do Guerreiro.'; END IF;
    ELSIF v_feat_type='wizard' AND v_bonus_kind='wizard' THEN
      -- The SRD explicitly says the wizard is not limited to feat categories for these bonus feats.
      -- All ordinary prerequisites are still checked below.
    ELSIF v_feat_type='monk' AND v_bonus_kind='monk' THEN
      IF NOT (
        (v_next_level=2 AND v_feat_id IN ('reflexos_de_combate','srd35_feat_deflect_arrows'))
        OR (v_next_level=6 AND v_feat_id IN ('srd35_feat_improved_disarm','srd35_feat_improved_trip'))
      ) THEN RAISE EXCEPTION 'Este talento não é uma opção de talento adicional de Monge neste nível.'; END IF;
    ELSE
      RAISE EXCEPTION 'Tipo de escolha de talento incompatível com a progressão desta classe.';
    END IF;

    IF v_feat_id=ANY(v_owned_ids) THEN RAISE EXCEPTION 'Este personagem já possui o talento %.',v_feat.nome; END IF;
    -- Monk bonus-feat lists explicitly waive each feat's normal prerequisites.
    IF v_feat_type<>'monk' THEN
    FOR v_req_item IN SELECT value FROM jsonb_array_elements_text(COALESCE(v_req->'feat_ids','[]'::jsonb)) AS reqs(value) LOOP
      IF NOT (v_req_item=ANY(v_owned_ids)) THEN
        RAISE EXCEPTION 'O talento % exige o pré-requisito %.',v_feat.nome,v_req_item;
      END IF;
    END LOOP;

    IF COALESCE(NULLIF(v_req->>'for_min','')::integer,0)>COALESCE(NULLIF(v_attrs->>'FOR','')::integer,10)
      OR COALESCE(NULLIF(v_req->>'des_min','')::integer,0)>COALESCE(NULLIF(v_attrs->>'DES','')::integer,10)
      OR COALESCE(NULLIF(v_req->>'con_min','')::integer,0)>COALESCE(NULLIF(v_attrs->>'CON','')::integer,10)
      OR COALESCE(NULLIF(v_req->>'int_min','')::integer,0)>COALESCE(NULLIF(v_attrs->>'INT','')::integer,10)
      OR COALESCE(NULLIF(v_req->>'sab_min','')::integer,0)>COALESCE(NULLIF(v_attrs->>'SAB','')::integer,10)
      OR COALESCE(NULLIF(v_req->>'car_min','')::integer,0)>COALESCE(NULLIF(v_attrs->>'CAR','')::integer,10) THEN
      RAISE EXCEPTION 'Os atributos atuais não atendem aos pré-requisitos de %.',v_feat.nome;
    END IF;

    v_bab:=CASE
      WHEN COALESCE(v_class.bab_progression,'') IN ('good','bom') THEN v_next_level
      WHEN COALESCE(v_class.bab_progression,'') IN ('average','medium','medio') THEN FLOOR(v_next_level*0.75)::integer
      WHEN COALESCE(v_class.bab_progression,'') IN ('poor','bad','ruim') THEN FLOOR(v_next_level/2.0)::integer
      ELSE COALESCE(v_class.dados_tecnicos->>'bab_nivel_1','0')::integer
    END;
    IF COALESCE(NULLIF(v_req->>'bab_min','')::integer,0)>v_bab THEN
      RAISE EXCEPTION '% exige BBA +%.',v_feat.nome,(v_req->>'bab_min');
    END IF;
    IF COALESCE(NULLIF(v_req->>'character_level_min','')::integer,0)>v_next_level
      OR COALESCE(NULLIF(v_req->>'class_level_min','')::integer,0)>v_next_level
      OR (NULLIF(v_req->>'class_key_required','') IS NOT NULL AND v_req->>'class_key_required' IS DISTINCT FROM v_class.class_key) THEN
      RAISE EXCEPTION 'O nível ou a classe atual ainda não atende aos pré-requisitos de %.',v_feat.nome;
    END IF;

    v_caster_level:=CASE
      WHEN COALESCE(v_class.class_key,'') IN ('wizard','sorcerer','cleric','druid','bard') THEN v_next_level
      WHEN COALESCE(v_class.class_key,'') IN ('paladin','ranger') THEN GREATEST(0,v_next_level-3)
      ELSE 0
    END;
    IF COALESCE(NULLIF(v_req->>'caster_level_min','')::integer,0)>v_caster_level THEN
      RAISE EXCEPTION '% exige nível de conjurador %.',v_feat.nome,(v_req->>'caster_level_min');
    END IF;
    IF v_req ? 'skill_ranks' THEN
      FOR v_skill_id IN SELECT key FROM jsonb_each(v_req->'skill_ranks') LOOP
        IF COALESCE(NULLIF(v_skill_state->>v_skill_id,'')::numeric,0)<COALESCE(NULLIF(v_req->'skill_ranks'->>v_skill_id,'')::numeric,0) THEN
          RAISE EXCEPTION '% exige mais graduações na perícia %.',v_feat.nome,v_skill_id;
        END IF;
      END LOOP;
    END IF;

    v_parameter_type:=COALESCE(NULLIF(v_req->>'parameter_type',''),CASE WHEN v_feat_id='srd35_feat_spell_mastery' THEN 'spell_list' ELSE '' END);
    IF (v_feat.exige_parametro OR v_parameter_type<>'') AND v_feat_parameter='' THEN
      RAISE EXCEPTION 'Informe a escolha exigida pelo talento %.',v_feat.nome;
    END IF;

    -- Validate selected weapon parameters against the SRD weapon catalogue.
    IF v_parameter_type IN ('weapon','weapon_martial','weapon_exotic','crossbow') THEN
      SELECT e.nome,e.detalhes INTO v_weapon_name,v_weapon_details
        FROM public.srd_equipment e
       WHERE e.categoria='arma'
         AND public.srd35_normalizar_parametro_talento(e.nome)=public.srd35_normalizar_parametro_talento(v_feat_parameter)
       LIMIT 1;
      IF NOT FOUND THEN
        RAISE EXCEPTION 'A arma informada para % não existe no catálogo SRD.',v_feat.nome;
      END IF;
      v_weapon_prof:=COALESCE(v_weapon_details->>'weapon_proficiency','');
      IF v_parameter_type='weapon_martial' AND v_weapon_prof<>'martial' THEN
        RAISE EXCEPTION 'A arma escolhida precisa ser marcial.';
      ELSIF v_parameter_type='weapon_exotic' AND v_weapon_prof<>'exotic' THEN
        RAISE EXCEPTION 'A arma escolhida precisa ser exótica.';
      ELSIF v_parameter_type='crossbow' AND public.srd35_normalizar_parametro_talento(v_weapon_name) NOT IN ('besta de mao','besta leve','besta pesada') THEN
        RAISE EXCEPTION 'Escolha besta de mão, besta leve ou besta pesada.';
      END IF;

      IF COALESCE((v_req->>'weapon_proficiency_required')::boolean,false) THEN
        v_has_proficiency:=EXISTS (
          SELECT 1
            FROM jsonb_array_elements_text(COALESCE(v_class.dados_tecnicos->'proficiencias'->'armas','[]'::jsonb)) AS proficiency(value)
           WHERE public.srd35_normalizar_parametro_talento(proficiency.value)=public.srd35_normalizar_parametro_talento(v_weapon_name)
              OR (public.srd35_normalizar_parametro_talento(proficiency.value)='armas simples' AND v_weapon_prof='simple')
              OR (public.srd35_normalizar_parametro_talento(proficiency.value)='todasasarmassimplesemarciais' AND v_weapon_prof IN ('simple','martial'))
        );
        IF NOT v_has_proficiency THEN
          RAISE EXCEPTION 'A classe não é proficiente com %; não pode escolher % ainda.',v_weapon_name,v_feat.nome;
        END IF;
      END IF;
    END IF;

    -- Conditional ability prerequisites apply only to their listed parameter choices.
    FOR v_conditional IN
      SELECT key,value FROM jsonb_each(COALESCE(v_req->'conditional_ability_min','{}'::jsonb))
    LOOP
      IF EXISTS (
        SELECT 1 FROM jsonb_array_elements_text(COALESCE(v_conditional.value->'parameters','[]'::jsonb)) AS param(value)
         WHERE public.srd35_normalizar_parametro_talento(param.value)=public.srd35_normalizar_parametro_talento(v_feat_parameter)
      ) THEN
        v_minimum:=COALESCE(NULLIF(v_conditional.value->>'minimum','')::integer,0);
        IF COALESCE(NULLIF(v_attrs->>v_conditional.key,'')::integer,10)<v_minimum THEN
          RAISE EXCEPTION 'A escolha % exige % %.',v_feat.nome,v_conditional.key,v_minimum;
        END IF;
      END IF;
    END LOOP;

    -- The prerequisite feat must have the same selected parameter where the source requires it.
    FOR v_param_key,v_param_expected IN
      SELECT key,value FROM jsonb_each_text(COALESCE(v_req->'feat_parameters','{}'::jsonb))
    LOOP
      SELECT existing.value->>'parametro' INTO v_owned_parameter
        FROM jsonb_array_elements(v_feat_state) AS existing(value)
       WHERE existing.value->>'id'=v_param_key
       LIMIT 1;
      IF v_owned_parameter IS NULL OR
         public.srd35_normalizar_parametro_talento(v_owned_parameter)<>public.srd35_normalizar_parametro_talento(v_param_expected) THEN
        RAISE EXCEPTION '% exige que o pré-requisito % use o parâmetro %.',v_feat.nome,v_param_key,v_param_expected;
      END IF;
    END LOOP;
    FOR v_param_key IN
      SELECT jsonb_array_elements_text(COALESCE(v_req->'feat_parameter_matches','[]'::jsonb))
    LOOP
      SELECT existing.value->>'parametro' INTO v_owned_parameter
        FROM jsonb_array_elements(v_feat_state) AS existing(value)
       WHERE existing.value->>'id'=v_param_key
       LIMIT 1;
      IF v_owned_parameter IS NULL OR
         public.srd35_normalizar_parametro_talento(v_owned_parameter)<>public.srd35_normalizar_parametro_talento(v_feat_parameter) THEN
        RAISE EXCEPTION '% exige o mesmo parâmetro (arma/escola) do talento %.',v_feat.nome,v_param_key;
      END IF;
    END LOOP;

    IF v_parameter_type='spell_list' THEN
      IF v_class.class_key<>'wizard' OR v_int_mod<1 THEN
        RAISE EXCEPTION 'Maestria em Magia exige Mago com modificador positivo de Inteligência.';
      END IF;
      IF cardinality(regexp_split_to_array(v_feat_parameter,'[,;]'))<>v_int_mod THEN
        RAISE EXCEPTION 'Maestria em Magia exige % magia(s) escolhida(s).',v_int_mod;
      END IF;
      IF cardinality(ARRAY(SELECT DISTINCT public.srd35_normalizar_parametro_talento(value) FROM unnest(regexp_split_to_array(v_feat_parameter,'[,;]')) AS spell(value)))<>v_int_mod THEN
        RAISE EXCEPTION 'Não repita uma magia em Maestria em Magia.';
      END IF;
      FOR v_req_item IN SELECT BTRIM(value) FROM unnest(regexp_split_to_array(v_feat_parameter,'[,;]')) AS spell(value) LOOP
        IF NOT EXISTS (
          SELECT 1
            FROM public.srd_character_spellbook book
            JOIN public.srd_spells spell ON spell.id=book.spell_id
           WHERE book.character_id::text=BTRIM(p_character_id)
             AND (book.class_id=v_class.id OR book.class_id=v_class.class_key)
             AND (spell.id=v_req_item OR public.srd35_normalizar_parametro_talento(spell.nome)=public.srd35_normalizar_parametro_talento(v_req_item))
        ) THEN
          RAISE EXCEPTION 'A magia % não consta no grimório deste personagem.',v_req_item;
        END IF;
      END LOOP;
    END IF;

    END IF;

    v_feat_state:=v_feat_state||jsonb_build_array(jsonb_build_object('id',v_feat_id,'parametro',NULLIF(v_feat_parameter,'')));
    v_owned_ids:=array_append(v_owned_ids,v_feat_id);
    v_selected_ids:=array_append(v_selected_ids,v_feat_id);
  END LOOP;

  -- A Constitution modifier increase changes HP for every Hit Die already gained.
  v_hp_gain:=GREATEST(1,v_hit_die_roll+v_con_mod)
    +GREATEST(0,v_con_mod-v_con_mod_old)*v_level;
  v_hp_delta:=v_hp_gain;
  v_hp_max:=GREATEST(1,COALESCE(v_sheet.pv_max,0))+v_hp_delta;
  v_hp_current:=LEAST(v_hp_max,GREATEST(0,COALESCE(v_sheet.pv_atual,v_sheet.pv_max,0))+v_hp_delta);

  SELECT COALESCE(jsonb_agg(jsonb_build_object('name',f.name,'summary',f.summary,'mechanics',f.mechanics) ORDER BY f.feature_key),'[]'::jsonb)
    INTO v_feature_names
    FROM public.srd_class_level_features f
   WHERE f.class_id=v_class.id AND f.class_level=v_next_level;

  UPDATE public.srd_character_sheets
     SET nivel=v_next_level,
         niveis_pendentes=GREATEST(0,v_pending-1),
         pv_max=v_hp_max,
         pv_atual=v_hp_current,
         atributos=v_attrs,
         pericias=v_skill_state,
         talentos=v_feat_state,
         xp=GREATEST(0,COALESCE(v_xp,v_sheet.xp,0))
   WHERE character_id::text=BTRIM(p_character_id);

  RETURN jsonb_build_object(
    'character_id',BTRIM(p_character_id),
    'nivel_anterior',v_level,
    'nivel',v_next_level,
    'niveis_pendentes',GREATEST(0,v_pending-1),
    'dado_vida',v_die,
    'rolagem_dado_vida',v_hit_die_roll,
    'modificador_constituicao',v_con_mod,
    'ajuste_pv_constituicao',GREATEST(0,v_con_mod-v_con_mod_old)*v_level,
    'ganho_pv',v_hp_delta,
    'pv_atual',v_hp_current,
    'pv_max',v_hp_max,
    'pontos_pericia',v_skill_points,
    'pontos_pericia_gastos',v_spent,
    'atributos',v_attrs,
    'caracteristicas',v_feature_names
  );
END;
$function$
;
