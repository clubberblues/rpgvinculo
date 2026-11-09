-- REMOTE FUNCTION EXPORT
-- Project: grrgwxcagvvafdmzsmro
-- Captured: 2026-11-09
-- Schema: priv
-- Count: 94
-- Source: pg_get_functiondef; definitions only, not a restore script.
-- Owners, grants, types, tables, triggers, policies and dependency order are separate.

-- can_delete_midia(p_name text)
CREATE OR REPLACE FUNCTION priv.can_delete_midia(p_name text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_uid uuid := auth.uid();
  v_match text[];
BEGIN
  IF v_uid IS NULL OR p_name IS NULL THEN RETURN false; END IF;
  IF priv.can_write_midia(p_name) THEN RETURN true; END IF;

  v_match := regexp_match(p_name, '^campaigns/([0-9]+)/');
  IF v_match IS NULL THEN
    v_match := regexp_match(p_name, '^capas_mesas/mesa-([0-9]+)-');
  END IF;
  IF v_match IS NOT NULL THEN
    RETURN EXISTS (SELECT 1 FROM priv.campaign_deletion_cleanup d
      WHERE d.campaign_id::text = v_match[1] AND d.owner_id = v_uid);
  END IF;

  RETURN false;
END;
$function$
;

-- can_write_midia(p_name text)
CREATE OR REPLACE FUNCTION priv.can_write_midia(p_name text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_uid uuid := auth.uid();
  v_match text[];
BEGIN
  IF v_uid IS NULL OR p_name IS NULL THEN RETURN false; END IF;

  IF split_part(p_name, '/', 1) = 'avatars' THEN
    RETURN split_part(p_name, '/', 2) = v_uid::text
       AND split_part(p_name, '/', 3) <> '';
  END IF;

  IF left(p_name, length('retratos/temp-' || v_uid::text || '-')) =
       'retratos/temp-' || v_uid::text || '-'
     OR left(p_name, length('headers/temp-bg-' || v_uid::text || '-')) =
       'headers/temp-bg-' || v_uid::text || '-' THEN
    RETURN true;
  END IF;

  v_match := regexp_match(p_name, '^retratos/([0-9]+)-foto-');
  IF v_match IS NOT NULL THEN
    RETURN EXISTS (SELECT 1 FROM public.characters c
      WHERE c.id::text = v_match[1] AND c.user_id = v_uid);
  END IF;

  v_match := regexp_match(p_name, '^headers/([0-9]+)-bg-');
  IF v_match IS NOT NULL THEN
    RETURN EXISTS (SELECT 1 FROM public.characters c
      WHERE c.id::text = v_match[1] AND c.user_id = v_uid);
  END IF;

  v_match := regexp_match(p_name, '^capas_mesas/mesa-([0-9]+)-');
  IF v_match IS NOT NULL THEN
    RETURN EXISTS (SELECT 1 FROM public.campaigns c
      WHERE c.id::text = v_match[1] AND c.owner_id = v_uid
        AND NOT EXISTS (SELECT 1 FROM priv.campaign_deletion_cleanup d WHERE d.campaign_id = c.id));
  END IF;

  v_match := regexp_match(p_name, '^campaigns/([0-9]+)/');
  IF v_match IS NOT NULL THEN
    RETURN EXISTS (SELECT 1 FROM public.campaigns c
      WHERE c.id::text = v_match[1]
        AND NOT EXISTS (SELECT 1 FROM priv.campaign_deletion_cleanup d WHERE d.campaign_id = c.id)
        AND (c.owner_id = v_uid OR EXISTS (
          SELECT 1 FROM public.members m
          WHERE m.campaign_id = c.id AND m.user_id = v_uid AND m.role = 'GM'
        )));
  END IF;

  RETURN false;
END;
$function$
;

-- clear(k text)
CREATE OR REPLACE FUNCTION priv.clear(k text)
 RETURNS void
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$ delete from priv.throttle where key = k $function$
;

-- concluir_avanco_nivel_personagem_srd(p_campaign_id bigint, p_character_id text, p_hit_die_roll integer, p_skill_ranks jsonb, p_feats jsonb, p_attribute text)
CREATE OR REPLACE FUNCTION priv.concluir_avanco_nivel_personagem_srd(p_campaign_id bigint, p_character_id text, p_hit_die_roll integer, p_skill_ranks jsonb DEFAULT '{}'::jsonb, p_feats jsonb DEFAULT '[]'::jsonb, p_attribute text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
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
  v_class_skill_spend_delta JSONB := '{}'::jsonb;
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
    v_class_skill_spend_delta:=jsonb_set(v_class_skill_spend_delta,ARRAY[v_skill_id],to_jsonb(COALESCE(NULLIF(v_class_skill_spend_delta->>v_skill_id,'')::numeric,0)+(v_added_rank*v_skill_cost)),true);
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
    SELECT f.* INTO v_feat FROM public.srd_feats f WHERE f.id=v_feat_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Talento não encontrado: %.',v_feat_id; END IF;
    v_req:=COALESCE(v_feat.requisitos,'{}'::jsonb);
    IF EXISTS (
      SELECT 1 FROM jsonb_array_elements(v_feat_state) AS existing(value)
       WHERE existing.value->>'id'=v_feat_id
         AND (
           NOT COALESCE((v_req->>'repeatable')::boolean,false)
           OR (
             v_req->>'repeatable_mode'='different_parameter'
             AND public.srd35_normalizar_parametro_talento(COALESCE(existing.value->>'parametro',''))
                 = public.srd35_normalizar_parametro_talento(COALESCE(v_feat_parameter,''))
           )
         )
    ) THEN
      RAISE EXCEPTION 'Este talento já foi escolhido com a mesma opção ou não permite repetição: %.',v_feat.nome;
    END IF;

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

    -- Repetições válidas já foram verificadas contra v_feat_state e repeatable_mode.
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
       WHERE public.srd35_equipment_slot(e.categoria,e.nome)='arma'
         AND public.srd35_normalizar_parametro_talento(e.nome)=public.srd35_normalizar_parametro_talento(v_feat_parameter)
       LIMIT 1;
      IF NOT FOUND THEN
        RAISE EXCEPTION 'A arma informada para % não existe no catálogo SRD.',v_feat.nome;
      END IF;
      v_weapon_prof:=priv.srd_weapon_proficiency(v_weapon_details,v_weapon_name);
      IF v_race.id='anao' AND regexp_replace(lower(translate(v_weapon_name,'ã','a')),'[^a-z0-9]+','','g') IN ('waraxedwarven','dwarvenwaraxe','urgroshdwarven','dwarvenurgrosh','machadodeguerraanao','urgroshanao') THEN v_weapon_prof:='martial'; END IF;
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

    -- Com talentos repetíveis, qualquer instância do pré-requisito com a opção
    -- correspondente satisfaz a cadeia; não assumir que a primeira instância é a correta.
    FOR v_param_key,v_param_expected IN
      SELECT key,value FROM jsonb_each_text(COALESCE(v_req->'feat_parameters','{}'::jsonb))
    LOOP
      IF NOT EXISTS (
        SELECT 1 FROM jsonb_array_elements(v_feat_state) AS existing(value)
         WHERE existing.value->>'id'=v_param_key
           AND public.srd35_normalizar_parametro_talento(COALESCE(existing.value->>'parametro',''))
               = public.srd35_normalizar_parametro_talento(v_param_expected)
      ) THEN
        RAISE EXCEPTION '% exige que o pré-requisito % use o parâmetro %.',v_feat.nome,v_param_key,v_param_expected;
      END IF;
    END LOOP;
    FOR v_param_key IN
      SELECT jsonb_array_elements_text(COALESCE(v_req->'feat_parameter_matches','[]'::jsonb))
    LOOP
      IF NOT EXISTS (
        SELECT 1 FROM jsonb_array_elements(v_feat_state) AS existing(value)
         WHERE existing.value->>'id'=v_param_key
           AND public.srd35_normalizar_parametro_talento(COALESCE(existing.value->>'parametro',''))
               = public.srd35_normalizar_parametro_talento(v_feat_parameter)
           AND public.srd35_normalizar_parametro_talento(v_feat_parameter)<>''
      ) THEN
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

  INSERT INTO public.srd_character_class_levels
    (character_id,class_id,class_level,taken_at_character_level,hit_points_gained,skill_points_spent)
  VALUES
    (v_sheet.character_id,v_class.id,v_next_level,1,v_hp_gain,v_class_skill_spend_delta)
  ON CONFLICT (character_id,class_id) DO UPDATE
    SET class_level=EXCLUDED.class_level,
        taken_at_character_level=COALESCE(public.srd_character_class_levels.taken_at_character_level,1),
        hit_points_gained=COALESCE(public.srd_character_class_levels.hit_points_gained,0)+v_hp_gain,
        skill_points_spent=(
          SELECT COALESCE(jsonb_object_agg(keys.skill_id,to_jsonb(
            COALESCE(NULLIF(public.srd_character_class_levels.skill_points_spent->>keys.skill_id,'')::numeric,0)
            +COALESCE(NULLIF(v_class_skill_spend_delta->>keys.skill_id,'')::numeric,0)
          )),'{}'::jsonb)
          FROM (
            SELECT key AS skill_id FROM jsonb_each(COALESCE(public.srd_character_class_levels.skill_points_spent,'{}'::jsonb))
            UNION
            SELECT key AS skill_id FROM jsonb_each(v_class_skill_spend_delta)
          ) keys
        );

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

-- consumir_acao_rodada_completa_srd_impl(p_campaign_id bigint, p_actor_id text, p_actor_kind text)
CREATE OR REPLACE FUNCTION priv.consumir_acao_rodada_completa_srd_impl(p_campaign_id bigint, p_actor_id text, p_actor_kind text DEFAULT 'character'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_user uuid := auth.uid();
  v_campaign public.campaigns%rowtype;
  v_combat jsonb;
  v_order jsonb;
  v_actor jsonb;
  v_current_turn integer;
  v_round integer;
  v_kind text := lower(btrim(coalesce(p_actor_kind, 'character')));
  v_target_kind text;
  v_linked_character_id text;
  v_action_state jsonb;
  v_by_actor jsonb;
  v_actor_actions jsonb;
  v_movement jsonb;
begin
  if v_user is null then
    raise exception 'É necessário estar autenticado.';
  end if;
  if nullif(btrim(p_actor_id), '') is null then
    raise exception 'O identificador do ator é obrigatório.';
  end if;
  if v_kind not in ('character', 'token') then
    raise exception 'Tipo de ator inválido.';
  end if;

  select c.* into v_campaign
  from public.campaigns c
  where c.id = p_campaign_id
  for update;
  if not found or upper(coalesce(v_campaign.state, '')) <> 'COMBATE' then
    raise exception 'A campanha não está em combate.';
  end if;

  v_combat := coalesce(v_campaign.combat_data, '{}'::jsonb);
  if lower(coalesce(v_combat->>'active', 'false')) <> 'true' then
    raise exception 'A iniciativa não está ativa.';
  end if;
  v_order := case when jsonb_typeof(v_combat->'turn_order') = 'array'
    then v_combat->'turn_order' else '[]'::jsonb end;
  if jsonb_array_length(v_order) = 0
     or coalesce(v_combat->>'current_turn', '') !~ '^[0-9]+$' then
    raise exception 'A ordem de iniciativa ou o turno atual é inválido.';
  end if;
  v_current_turn := (v_combat->>'current_turn')::integer;
  if v_current_turn < 0 or v_current_turn >= jsonb_array_length(v_order) then
    raise exception 'O índice do turno atual está fora da ordem de iniciativa.';
  end if;
  v_actor := v_order->v_current_turn;
  PERFORM priv.srd_validate_surprise_action(p_campaign_id,BTRIM(p_actor_id),'rodada_completa');
  if v_actor->>'id' is distinct from btrim(p_actor_id) then
    raise exception 'Somente o ator cujo turno está ativo pode executar uma ação de rodada completa.';
  end if;

  if v_kind = 'character' then
    v_target_kind := 'character';
    if coalesce(lower(v_actor->>'is_monster'), 'false') = 'true'
       or not exists (
         select 1 from public.characters ch
         join public.members m on m.campaign_id = ch.campaign_id
           and m.user_id = ch.user_id and m.role = 'PLAYER'
         where ch.id::text = btrim(p_actor_id)
           and ch.campaign_id = p_campaign_id
           and ch.user_id = v_user
       ) then
      raise exception 'A ficha não pertence a este jogador ou não está no turno dele.';
    end if;
  else
    v_target_kind := 'token';
    if not exists (
      select 1 from public.members m
      where m.campaign_id = p_campaign_id and m.user_id = v_user and m.role = 'GM'
    ) then
      raise exception 'Somente o Mestre pode coordenar tokens controlados por ele.';
    end if;
    if coalesce(lower(v_actor->>'is_monster'), 'false') <> 'true' then
      raise exception 'O token não está registrado como ator do Mestre na iniciativa.';
    end if;
    if not exists (
      select 1
      from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens', '[]'::jsonb)) t(token)
      where t.token->>'id' = btrim(p_actor_id)
        and (
          t.token->>'tipo' in ('npc', 'monstro')
          or (
            t.token->>'tipo' = 'player'
            and exists (
              select 1 from public.characters ch
              where ch.id::text = btrim(p_actor_id)
                and ch.user_id = v_user and ch.campaign_id = p_campaign_id
            )
          )
        )
    ) then
      raise exception 'Este token não é controlado pelo Mestre.';
    end if;
    select nullif(t.token->>'sourceCharacterId','') into v_linked_character_id
    from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t(token)
    where t.token->>'id'=btrim(p_actor_id) and t.token->>'tipo'='npc'
    limit 1;
  end if;

  if priv.srd_condition_has_flag(p_campaign_id, v_target_kind, btrim(p_actor_id), 'no_actions')
     or (v_linked_character_id is not null and priv.srd_condition_has_flag(p_campaign_id,'character',v_linked_character_id,'no_actions')) then
    raise exception 'A condição atual impede qualquer ação.';
  end if;
  if priv.srd_condition_has_flag(p_campaign_id, v_target_kind, btrim(p_actor_id), 'no_full_round')
     or (v_linked_character_id is not null and priv.srd_condition_has_flag(p_campaign_id,'character',v_linked_character_id,'no_full_round')) then
    raise exception 'A condição atual impede ações de rodada completa.';
  end if;
  if priv.srd_condition_has_flag(p_campaign_id, v_target_kind, btrim(p_actor_id), 'only_move_action')
     or priv.srd_condition_has_flag(p_campaign_id, v_target_kind, btrim(p_actor_id), 'one_move_or_standard')
     or (v_linked_character_id is not null and (
       priv.srd_condition_has_flag(p_campaign_id,'character',v_linked_character_id,'only_move_action')
       or priv.srd_condition_has_flag(p_campaign_id,'character',v_linked_character_id,'one_move_or_standard')
     )) then
    raise exception 'A condição atual não permite uma ação de rodada completa.';
  end if;

  v_round := case when coalesce(v_combat->>'round', '') ~ '^[0-9]+$'
    then greatest(1, (v_combat->>'round')::integer) else 1 end;
  v_action_state := v_combat->'action_economy';
  if jsonb_typeof(v_action_state) = 'object'
     and coalesce(v_action_state->>'round', '') = v_round::text
     and jsonb_typeof(v_action_state->'by_character') = 'object' then
    v_by_actor := v_action_state->'by_character';
  else
    v_by_actor := '{}'::jsonb;
  end if;
  v_actor_actions := case when jsonb_typeof(v_by_actor->btrim(p_actor_id)) = 'object'
    then v_by_actor->btrim(p_actor_id) else '{}'::jsonb end;

  if coalesce(v_actor_actions->>'padrao', 'false') = 'true'
     or coalesce(v_actor_actions->>'movimento', 'false') = 'true'
     or coalesce(v_actor_actions->>'ataque_total', 'false') = 'true' then
    raise exception 'A ação padrão ou de movimento já foi usada; a ação de rodada completa não está disponível.';
  end if;

  v_movement := v_combat->'movement_usage';
  if jsonb_typeof(v_movement) = 'object'
     and v_movement->>'character_id' = btrim(p_actor_id)
     and v_movement->>'round' = v_round::text
     and v_movement->>'current_turn' = v_current_turn::text
     and coalesce(v_movement->>'moved_squares', '0') ~ '^[0-9]+$'
     and (v_movement->>'moved_squares')::integer > 0 then
    raise exception 'O ator já se movimentou nesta rodada; não pode iniciar uma ação de rodada completa.';
  end if;

  v_actor_actions := v_actor_actions || jsonb_build_object(
    'padrao', true,
    'movimento', true,
    'ataque_total', true
  );
  v_by_actor := jsonb_set(v_by_actor, array[btrim(p_actor_id)], v_actor_actions, true);
  v_action_state := jsonb_build_object('round', v_round, 'by_character', v_by_actor);
  v_combat := v_combat || jsonb_build_object('action_economy', v_action_state);

  if v_kind = 'character'
     and priv.srd_condition_has_flag(p_campaign_id, 'character', btrim(p_actor_id), 'strenuous_action_cost_1hp') then
    update public.srd_character_sheets
       set pv_atual = -1
     where character_id::text = btrim(p_actor_id)
       and coalesce(pv_atual, 0) = 0;
    if found then
      perform priv.srd_sync_character_vital_condition(btrim(p_actor_id), -1, false);
    end if;
  end if;

  update public.campaigns set combat_data = v_combat where id = p_campaign_id;
  return jsonb_build_object(
    'combat_data', v_combat,
    'action_economy', v_action_state,
    'round', v_round,
    'actor_id', btrim(p_actor_id),
    'actor_kind', v_kind,
    'action', 'ataque_total'
  );
end;
$function$
;

-- consumir_acao_token_gm_srd_impl(p_campaign_id bigint, p_token_id text, p_acao text)
CREATE OR REPLACE FUNCTION priv.consumir_acao_token_gm_srd_impl(p_campaign_id bigint, p_token_id text, p_acao text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
 v_user uuid:=auth.uid();
 v_campaign public.campaigns%ROWTYPE;
 v_combat jsonb;
 v_order jsonb;
 v_actor jsonb;
 v_action_state jsonb;
 v_by_token jsonb;
 v_token_actions jsonb;
 v_action text:=lower(btrim(coalesce(p_acao,'')));
 v_round integer; v_tokens jsonb; v_token jsonb; v_token_index bigint; v_linked_character_id text; v_token_count integer; v_hp integer; v_max_hp integer;
BEGIN
 IF v_user IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.members WHERE campaign_id=p_campaign_id AND user_id=v_user AND role='GM') THEN
  RAISE EXCEPTION 'Somente o Mestre pode coordenar os tokens controlados por ele.';
 END IF;
 IF v_action NOT IN ('padrao','movimento','rapida') THEN RAISE EXCEPTION 'Ação inválida.'; END IF;
 SELECT c.* INTO v_campaign FROM public.campaigns c WHERE c.id=p_campaign_id FOR UPDATE;
 IF NOT FOUND OR upper(coalesce(v_campaign.state,''))<>'COMBATE' THEN RAISE EXCEPTION 'A campanha não está em combate.'; END IF;
 v_combat:=coalesce(v_campaign.combat_data,'{}'::jsonb);
 IF coalesce(v_combat->>'active','false')<>'true' THEN RAISE EXCEPTION 'A iniciativa não está ativa.'; END IF;
 v_order:=CASE WHEN jsonb_typeof(v_combat->'turn_order')='array' THEN v_combat->'turn_order' ELSE '[]'::jsonb END;
 IF coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$' THEN RAISE EXCEPTION 'O turno atual é inválido.'; END IF;
 v_actor:=v_order->(v_combat->>'current_turn')::integer;
 PERFORM priv.srd_validate_surprise_action(p_campaign_id,btrim(p_token_id),v_action);
 IF v_actor->>'id' IS DISTINCT FROM btrim(p_token_id) OR coalesce(v_actor->>'is_monster','false')<>'true' THEN RAISE EXCEPTION 'O token não está no turno ativo do Mestre.'; END IF;
 IF NOT EXISTS(
  SELECT 1 FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t(token)
  WHERE t.token->>'id'=btrim(p_token_id)
   AND (t.token->>'tipo' IN ('npc','monstro') OR
    (t.token->>'tipo'='player' AND EXISTS(
      SELECT 1 FROM public.characters ch WHERE ch.id::text=btrim(p_token_id)
       AND ch.user_id=v_user AND ch.campaign_id=p_campaign_id
    )))
 ) THEN RAISE EXCEPTION 'Este token não é controlado pelo Mestre.'; END IF;
 v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END;
 SELECT t.token INTO v_token FROM jsonb_array_elements(v_tokens) t(token)
 WHERE t.token->>'id'=btrim(p_token_id) LIMIT 1;
 v_linked_character_id:=nullif(v_token->>'sourceCharacterId','');
 IF priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'no_actions')
    OR (v_linked_character_id IS NOT NULL AND priv.srd_condition_has_flag(p_campaign_id,'character',v_linked_character_id,'no_actions')) THEN
  RAISE EXCEPTION 'A condição atual impede qualquer ação.';
 END IF;
 IF v_action<>'movimento' AND (
    priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'only_move_action')
    OR (v_linked_character_id IS NOT NULL AND priv.srd_condition_has_flag(p_campaign_id,'character',v_linked_character_id,'only_move_action'))
 ) THEN
  RAISE EXCEPTION 'A condição atual permite somente uma ação de movimento.';
 END IF;
 v_round:=CASE WHEN coalesce(v_combat->>'round','') ~ '^[0-9]+$' THEN greatest(1,(v_combat->>'round')::integer) ELSE 1 END;
 v_action_state:=v_combat->'action_economy';
 IF jsonb_typeof(v_action_state)='object' AND coalesce(v_action_state->>'round','')=v_round::text AND jsonb_typeof(v_action_state->'by_character')='object' THEN
  v_by_token:=v_action_state->'by_character';
 ELSE v_by_token:='{}'::jsonb; END IF;
 v_token_actions:=CASE WHEN jsonb_typeof(v_by_token->btrim(p_token_id))='object' THEN v_by_token->btrim(p_token_id) ELSE '{}'::jsonb END;
 IF (priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'one_move_or_standard')
     OR (v_linked_character_id IS NOT NULL AND priv.srd_condition_has_flag(p_campaign_id,'character',v_linked_character_id,'one_move_or_standard')))
    AND v_action IN ('padrao','movimento')
    AND (coalesce(v_token_actions->>'padrao','false')='true' OR coalesce(v_token_actions->>'movimento','false')='true') THEN
  RAISE EXCEPTION 'A condição permite apenas uma ação padrão ou de movimento por rodada.';
 END IF;
 IF coalesce(v_token_actions->>v_action,'false')='true' THEN RAISE EXCEPTION 'Esta ação do token já foi usada nesta rodada.'; END IF;
 v_token_actions:=v_token_actions||jsonb_build_object(v_action,true);
 v_by_token:=jsonb_set(v_by_token,ARRAY[btrim(p_token_id)],v_token_actions,true);
 v_action_state:=jsonb_build_object('round',v_round,'by_character',v_by_token);
 v_combat:=v_combat||jsonb_build_object('action_economy',v_action_state);
 IF v_action='padrao' AND priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'strenuous_action_cost_1hp') THEN
  v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END;
  SELECT count(*)::integer,min(t.ordinality),(array_agg(t.token ORDER BY t.ordinality))[1]
    INTO v_token_count,v_token_index,v_token FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality)
   WHERE t.token->>'id'=btrim(p_token_id) AND t.token->>'tipo'='npc';
  IF v_token_count=1 AND COALESCE(v_token->>'hp','') ~ '^[0-9]{1,6}$' AND (v_token->>'hp')::integer=0 THEN
   v_hp:=-1; v_max_hp:=NULLIF(v_token->>'maxHp','')::integer;
   v_token:=v_token||jsonb_build_object('hp',v_hp);
   SELECT COALESCE(jsonb_agg(CASE WHEN t.ordinality=v_token_index THEN v_token ELSE t.token END ORDER BY t.ordinality),'[]'::jsonb) INTO v_tokens
     FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality);
   UPDATE public.campaigns SET cba_data=COALESCE(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens) WHERE id=p_campaign_id;
   IF v_max_hp IS NOT NULL AND v_max_hp>0 AND NULLIF(BTRIM(v_token->>'sourceCharacterId'),'') IS NOT NULL THEN
    PERFORM priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,v_hp,v_max_hp,false);
   END IF;
  END IF;
 END IF;
 UPDATE public.campaigns SET combat_data=v_combat WHERE id=p_campaign_id;
 RETURN jsonb_build_object('combat_data',v_combat,'token_id',btrim(p_token_id),'action',v_action,'round',v_round);
END;
$function$
;

-- d20()
CREATE OR REPLACE FUNCTION priv.d20()
 RETURNS integer
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  select 1 + floor(random() * 20)::int
$function$
;

-- descanso_longo_npc_vinculado_srd_impl(p_campaign_id bigint, p_token_id text)
CREATE OR REPLACE FUNCTION priv.descanso_longo_npc_vinculado_srd_impl(p_campaign_id bigint, p_token_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
 v_campaign public.campaigns%ROWTYPE; v_token jsonb; v_tokens jsonb;
 v_token_count integer; v_token_index bigint;
 v_character public.characters%ROWTYPE; v_sheet public.srd_character_sheets%ROWTYPE;
 v_level integer; v_hp integer; v_max integer; v_new_hp integer; v_last_rest timestamptz;
 v_spell_state jsonb; v_class_key text; v_conditions_removed integer:=0; v_changed integer:=0;
 v_rage_end jsonb;
BEGIN
 IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
   RAISE EXCEPTION 'Somente o Mestre autenticado pode realizar o descanso de NPCs.';
 END IF;
 SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
 IF UPPER(COALESCE(v_campaign.state,''))='COMBATE' THEN RAISE EXCEPTION 'Não é possível realizar descanso longo durante combate.'; END IF;
 v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END;
 SELECT count(*)::integer,min(t.ordinality) INTO v_token_count,v_token_index
 FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality)
 WHERE t.token->>'id'=BTRIM(p_token_id) AND t.token->>'tipo'='npc';
 IF v_token_count<>1 THEN RAISE EXCEPTION 'Token NPC não encontrado ou duplicado.'; END IF;
 v_token:=v_tokens->(v_token_index::integer-1);
 IF NULLIF(v_token->>'sourceCharacterId','') IS NULL THEN RAISE EXCEPTION 'Este NPC não possui ficha SRD de origem vinculada.'; END IF;
 SELECT * INTO v_character FROM public.characters WHERE id::text=v_token->>'sourceCharacterId' FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Ficha de origem do NPC não encontrada.'; END IF;
 IF v_character.user_id IS DISTINCT FROM auth.uid() THEN
   RAISE EXCEPTION 'O Mestre só pode controlar recursos da ficha NPC que pertence à sua própria conta.';
 END IF;
 SELECT * INTO v_sheet FROM public.srd_character_sheets WHERE character_id=v_character.id FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD de origem não encontrada.'; END IF;
 v_last_rest:=v_sheet.magias_descanso_em;
 IF v_last_rest IS NOT NULL AND v_last_rest>clock_timestamp()-INTERVAL '8 hours' THEN
   RAISE EXCEPTION 'O descanso longo exige 8 horas entre descansos.';
 END IF;
 v_level:=GREATEST(1,COALESCE(v_sheet.nivel,1));
 v_rage_end:=priv.srd_end_barbarian_rage_token(p_campaign_id,BTRIM(p_token_id),true);
 SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
 v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END;
 SELECT count(*)::integer,min(t.ordinality) INTO v_token_count,v_token_index
 FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality)
 WHERE t.token->>'id'=BTRIM(p_token_id) AND t.token->>'tipo'='npc';
 IF v_token_count<>1 THEN RAISE EXCEPTION 'Token NPC deixou de ser único durante o descanso.'; END IF;
 v_token:=v_tokens->(v_token_index::integer-1);
 IF COALESCE(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' OR COALESCE(v_token->>'hp','') !~ '^[0-9]{1,6}$' THEN
   RAISE EXCEPTION 'PV atuais ou máximos do token são inválidos.';
 END IF;
 v_max:=(v_token->>'maxHp')::integer; v_hp:=(v_token->>'hp')::integer;
 v_new_hp:=LEAST(v_max,v_hp+v_level);
 v_spell_state:=COALESCE(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
 IF jsonb_typeof(v_spell_state->'preparadas')<>'array' THEN RAISE EXCEPTION 'Estado de magias da ficha de NPC inválido.'; END IF;
 SELECT COALESCE(NULLIF(cls.class_key,''),public._srd35_class_key(cls.nome)) INTO v_class_key
 FROM public.srd_classes cls WHERE cls.id=v_sheet.classe_id;
 IF v_class_key IS NULL THEN RAISE EXCEPTION 'Classe da ficha de NPC não foi resolvida.'; END IF;
 SELECT jsonb_build_object(
   'version',1,'conhecidas',COALESCE(v_spell_state->'conhecidas','[]'::jsonb),
   'preparadas',COALESCE(jsonb_agg(jsonb_set(e.value,'{expended}','false'::jsonb,true) ORDER BY e.ord),'[]'::jsonb),
   'dominio_preparadas',COALESCE((SELECT jsonb_agg(jsonb_set(d.value,'{expended}','false'::jsonb,true) ORDER BY d.ord)
     FROM jsonb_array_elements(COALESCE(v_spell_state->'dominio_preparadas','[]'::jsonb)) WITH ORDINALITY d(value,ord)),'[]'::jsonb),
   'usos',CASE WHEN v_class_key IN ('sorcerer','bard') THEN '{}'::jsonb ELSE COALESCE(v_spell_state->'usos','{}'::jsonb) END
 ) INTO v_spell_state FROM jsonb_array_elements(v_spell_state->'preparadas') WITH ORDINALITY e(value,ord);
 UPDATE public.srd_character_feature_resources SET uses_spent=0,resource_spent=0,last_reset_at=clock_timestamp()
 WHERE character_id=v_character.id;
 UPDATE public.srd_character_sheets SET pv_atual=v_new_hp,pv_max=v_max,magias_preparadas=v_spell_state,magias_descanso_em=clock_timestamp()
 WHERE character_id=v_character.id;
 UPDATE public.srd_campaign_conditions SET active=false
 WHERE campaign_id=p_campaign_id AND target_kind='token' AND target_id=BTRIM(p_token_id)
   AND active AND condition_id IN ('fatigued','exhausted');
 GET DIAGNOSTICS v_conditions_removed=ROW_COUNT;
 UPDATE public.srd_campaign_conditions SET active=false
 WHERE campaign_id=p_campaign_id AND target_kind='character' AND target_id=v_character.id::text
   AND active AND condition_id IN ('fatigued','exhausted');
 GET DIAGNOSTICS v_changed=ROW_COUNT;
 v_conditions_removed:=v_conditions_removed+v_changed;
 v_token:=v_token||jsonb_build_object('hp',v_new_hp,'maxHp',v_max);
 SELECT COALESCE(jsonb_agg(CASE WHEN t.ordinality=v_token_index THEN v_token ELSE t.token END ORDER BY t.ordinality),'[]'::jsonb)
 INTO v_tokens FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality);
 UPDATE public.campaigns SET cba_data=COALESCE(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens) WHERE id=p_campaign_id;
 PERFORM priv.log(p_campaign_id,'NPC_LONG_REST',jsonb_build_object(
   'token_id',BTRIM(p_token_id),'character_id',v_character.id,'character_name',v_token->>'nome',
   'healing',v_new_hp-v_hp,'hp',v_new_hp,'max_hp',v_max,'class_resources_reset',true));
 RETURN jsonb_build_object('ok',true,'token_id',BTRIM(p_token_id),'character_id',v_character.id::text,
   'character_name',COALESCE(v_character.nome,v_token->>'nome'),'pv_atual',v_new_hp,'pv_max',v_max,
   'cura',v_new_hp-v_hp,'magias_repostas',true,'recursos_classe_repostos',true,
   'condicoes_removidas',v_conditions_removed,'furia_encerrada',COALESCE((v_rage_end->>'ended')::boolean,false),
   'descanso_em',clock_timestamp(),'cba_data',(SELECT cba_data FROM public.campaigns WHERE id=p_campaign_id));
END;
$function$
;

-- fail(k text, mx integer)
CREATE OR REPLACE FUNCTION priv.fail(k text, mx integer DEFAULT 5)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare f int;
begin
  insert into priv.throttle(key, fails) values (k, 1)
  on conflict (key) do update set
    fails = case when priv.throttle.until_ts is not null and priv.throttle.until_ts <= now() then 1 else priv.throttle.fails + 1 end,
    until_ts = case when priv.throttle.until_ts is not null and priv.throttle.until_ts <= now() then null else priv.throttle.until_ts end
  returning fails into f;
  if f >= mx then update priv.throttle set until_ts = now() + interval '15 minutes' where key = k; end if;
end $function$
;

-- finalizar_exclusao_campanha_propria(p_campaign_id bigint)
CREATE OR REPLACE FUNCTION priv.finalizar_exclusao_campanha_propria(p_campaign_id bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_owner uuid;
  v_pending_owner uuid;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT d.owner_id INTO v_pending_owner
  FROM priv.campaign_deletion_cleanup d
  WHERE d.campaign_id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND OR v_pending_owner IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'Não existe uma exclusão autorizada para esta campanha.';
  END IF;
  SELECT c.owner_id INTO v_owner
  FROM public.campaigns c
  WHERE c.id = p_campaign_id
  FOR UPDATE;
  IF FOUND THEN
    IF v_owner IS DISTINCT FROM auth.uid() THEN
      RAISE EXCEPTION 'Somente o proprietário pode excluir esta campanha.';
    END IF;
    DELETE FROM public.campaigns WHERE id = p_campaign_id;
  END IF;
  DELETE FROM priv.campaign_deletion_cleanup
  WHERE campaign_id = p_campaign_id AND owner_id = auth.uid();
  RETURN jsonb_build_object('ok', true, 'campaign_id', p_campaign_id, 'deleted', true);
END;
$function$
;

-- gm_npc_apply_typed_damage_impl(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_raw_damage integer, p_damage_type text)
CREATE OR REPLACE FUNCTION priv.gm_npc_apply_typed_damage_impl(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_raw_damage integer, p_damage_type text DEFAULT 'untyped'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
 v_campaign public.campaigns%rowtype; v_order jsonb; v_actor jsonb; v_tokens jsonb;
 v_target jsonb; v_count integer; v_index bigint; v_kind text;
 v_damage_type text; v_damage integer; v_hp integer; v_max_hp integer; v_new_hp integer; v_round integer; v_action_state jsonb; v_by_actor jsonb; v_actor_actions jsonb; v_combat jsonb;
begin
 if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
  raise exception 'Somente o Mestre autenticado pode aplicar dano de NPC.';
 end if;
 if p_raw_damage is null or p_raw_damage<1 or p_raw_damage>1000 then raise exception 'Dano bruto inválido.'; end if;
 v_damage_type:=lower(btrim(coalesce(p_damage_type,'untyped')));
 if v_damage_type not in ('slashing','piercing','bludgeoning','physical','untyped','fire','cold','electricity','acid','sonic','force','positive','negative') then raise exception 'Tipo de dano inválido.'; end if;
 select * into v_campaign from public.campaigns where id=p_campaign_id for update;
 if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE' or coalesce(v_campaign.combat_data->>'active','false')<>'true' then raise exception 'A campanha não está em combate ativo.'; end if;
 v_order:=case when jsonb_typeof(v_campaign.combat_data->'turn_order')='array' then v_campaign.combat_data->'turn_order' else '[]'::jsonb end;
 if coalesce(v_campaign.combat_data->>'current_turn','') !~ '^[0-9]+$' then raise exception 'Turno atual inválido.'; end if;
 v_actor:=v_order->(v_campaign.combat_data->>'current_turn')::integer;
 if v_actor->>'id' is distinct from btrim(p_actor_token_id) or coalesce(v_actor->>'is_monster','false')<>'true' then raise exception 'O token atacante não pertence ao turno atual do Mestre.'; end if;
 v_round:=case when coalesce(v_campaign.combat_data->>'round','') ~ '^[0-9]+$' then greatest(1,(v_campaign.combat_data->>'round')::integer) else 1 end;
 v_action_state:=coalesce(v_campaign.combat_data->'action_economy','{}'::jsonb);
 if coalesce(v_action_state->>'round','')<>v_round::text or coalesce(v_action_state->'by_character'->btrim(p_actor_token_id)->>'padrao','false')<>'true' then raise exception 'A ação padrão do NPC ainda não foi consumida neste turno.'; end if;
 v_actor_actions:=coalesce(v_action_state->'by_character'->btrim(p_actor_token_id),'{}'::jsonb);
 if coalesce(v_actor_actions->>'gm_npc_attack_damage_applied','false')='true' then raise exception 'Este NPC já aplicou dano de ataque normal nesta rodada.'; end if;
 v_tokens:=case when jsonb_typeof(v_campaign.cba_data->'tokens')='array' then v_campaign.cba_data->'tokens' else '[]'::jsonb end;
 select count(*)::integer,min(t.ordinality) into v_count,v_index
 from jsonb_array_elements(v_tokens) with ordinality t(token,ordinality)
 where t.token->>'id'=btrim(p_target_token_id) and coalesce(t.token->>'tipo','') in ('player','npc','monstro');
 if v_count<>1 then raise exception 'O alvo não foi encontrado ou está duplicado na cena.'; end if;
 v_target:=v_tokens->(v_index::integer-1); v_kind:=v_target->>'tipo';
 if v_kind='player' then
  select sh.pv_atual,sh.pv_max into v_hp,v_max_hp
  from public.characters ch join public.members m on m.campaign_id=ch.campaign_id and m.user_id=ch.user_id and m.role='PLAYER'
  join public.srd_character_sheets sh on sh.character_id=ch.id
  where ch.id::text=btrim(p_target_token_id) and ch.campaign_id=p_campaign_id for update of sh;
  if not found or v_max_hp is null or v_max_hp<1 then raise exception 'Ficha do personagem alvo não encontrada ou sem PV máximos válidos.'; end if;
  v_damage:=priv.srd_adjust_damage(p_campaign_id,'character',btrim(p_target_token_id),v_damage_type,p_raw_damage);
  v_new_hp:=greatest(-10,least(v_max_hp,coalesce(v_hp,v_max_hp)-v_damage));
  perform priv.srd_sync_character_vital_condition(btrim(p_target_token_id),v_new_hp,false);
  update public.srd_character_sheets set pv_atual=v_new_hp where character_id::text=btrim(p_target_token_id);
  v_target:=v_target||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp);
  v_tokens:=jsonb_set(v_tokens,array[(v_index-1)::text],v_target,false);
  v_combat:=coalesce(v_campaign.combat_data,'{}'::jsonb); v_by_actor:=coalesce(v_action_state->'by_character','{}'::jsonb);
  v_actor_actions:=v_actor_actions||jsonb_build_object('gm_npc_attack_damage_applied',true); v_by_actor:=jsonb_set(v_by_actor,array[btrim(p_actor_token_id)],v_actor_actions,true);
  v_action_state:=v_action_state||jsonb_build_object('by_character',v_by_actor); v_combat:=v_combat||jsonb_build_object('action_economy',v_action_state);
  update public.campaigns
     set cba_data=coalesce(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens),
         combat_data=v_combat
   where id=p_campaign_id;
  return jsonb_build_object('target_kind','character','target_id',p_target_token_id,
    'damage_raw',p_raw_damage,'damage_applied',v_damage,'damage_type',v_damage_type,
    'pv_atual',v_new_hp,'pv_max',v_max_hp,
    'cba_data',(select cba_data from public.campaigns where id=p_campaign_id));
 end if;
 if coalesce(v_target->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' then raise exception 'O alvo NPC/monstro não possui PV máximos válidos.'; end if;
 v_max_hp:=(v_target->>'maxHp')::integer;
 if coalesce(v_target->>'hp','') !~ '^-?[0-9]{1,6}$' then raise exception 'O alvo NPC/monstro não possui PV atuais válidos.'; end if;
 v_hp:=(v_target->>'hp')::integer;
 v_damage:=priv.srd_adjust_damage(p_campaign_id,'token',btrim(p_target_token_id),v_damage_type,p_raw_damage);
 v_new_hp:=greatest(-10,least(v_max_hp,v_hp-v_damage));
 v_target:=v_target||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp);
 v_tokens:=jsonb_set(v_tokens,array[(v_index-1)::text],v_target,false);
 update public.campaigns set cba_data=coalesce(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens) where id=p_campaign_id;
  perform priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_target_token_id,v_new_hp,v_max_hp);
 v_combat:=coalesce(v_campaign.combat_data,'{}'::jsonb); v_by_actor:=coalesce(v_action_state->'by_character','{}'::jsonb);
 v_actor_actions:=v_actor_actions||jsonb_build_object('gm_npc_attack_damage_applied',true); v_by_actor:=jsonb_set(v_by_actor,array[btrim(p_actor_token_id)],v_actor_actions,true);
 v_action_state:=v_action_state||jsonb_build_object('by_character',v_by_actor); v_combat:=v_combat||jsonb_build_object('action_economy',v_action_state);
 update public.campaigns set combat_data=v_combat where id=p_campaign_id;
 return jsonb_build_object('target_kind','token','target_id',p_target_token_id,'damage_raw',p_raw_damage,'damage_applied',v_damage,'damage_type',v_damage_type,'hp',v_new_hp,'max_hp',v_max_hp,'cba_data',(select cba_data from public.campaigns where id=p_campaign_id));
end;
$function$
;

-- grow_scene()
CREATE OR REPLACE FUNCTION priv.grow_scene()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare mc int;
begin
  select greatest(40, least(300, ceil(4 * coalesce(max(desl), 0))::int)) into mc from tokens where campaign_id = new.campaign_id;
  update scenes set cols = mc, rows = least(300, ceil(0.75 * mc / 0.8660254037844386)::int) where campaign_id = new.campaign_id and not manual and cols < mc;
  return new;
end $function$
;

-- iniciar_sequencia_ataque_iterativo_srd_5_impl(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid)
CREATE OR REPLACE FUNCTION priv.iniciar_sequencia_ataque_iterativo_srd_5_impl(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_user uuid := auth.uid();
  v_campaign public.campaigns%rowtype;
  v_combat jsonb;
  v_tokens jsonb;
  v_target_count integer;
  v_turn integer;
  v_round integer;
  v_bab integer;
  v_attacks integer;
  v_action jsonb;
  v_sequence public.srd_attack_sequences%rowtype;
begin
  if v_user is null then
    raise exception 'É necessário estar autenticado.';
  end if;
  if nullif(btrim(p_character_id), '') is null
     or nullif(btrim(p_target_token_id), '') is null
     or p_attack_type not in ('atk-corpo','atk-dist') then
    raise exception 'Dados da sequência de ataque inválidos.';
  end if;

  select c.* into v_campaign
  from public.campaigns c
  where c.id = p_campaign_id
  for update;
  if not found or upper(coalesce(v_campaign.state,'')) <> 'COMBATE' then
    raise exception 'A campanha não está em combate.';
  end if;

  if not exists (
    select 1
    from public.characters ch
    join public.members m on m.campaign_id = ch.campaign_id
      and m.user_id = ch.user_id and m.role = 'PLAYER'
    where ch.id::text = btrim(p_character_id)
      and ch.campaign_id = p_campaign_id
      and ch.user_id = v_user
  ) then
    raise exception 'A ficha atacante não pertence ao jogador nesta campanha.';
  end if;

  -- O alvo precisa ser um token único e real da própria campanha.
  v_tokens := case when jsonb_typeof(v_campaign.cba_data->'tokens') = 'array'
    then v_campaign.cba_data->'tokens' else '[]'::jsonb end;
  select count(*)::integer into v_target_count
  from jsonb_array_elements(v_tokens) t(token)
  where t.token->>'id' = btrim(p_target_token_id)
    and t.token->>'tipo' in ('npc','monstro','player');
  if v_target_count <> 1 then
    raise exception 'O alvo não foi encontrado ou está duplicado nesta campanha.';
  end if;
  if exists (
    select 1 from jsonb_array_elements(v_tokens) t(token)
    where t.token->>'id'=btrim(p_target_token_id)
      and t.token->>'tipo'='player'
  ) then
    if btrim(p_target_token_id)=btrim(p_character_id)
       or not exists (
         select 1 from public.characters ch
         join public.members m on m.campaign_id=ch.campaign_id
           and m.user_id=ch.user_id and m.role='PLAYER'
         join public.srd_character_sheets sh on sh.character_id=ch.id
         where ch.id::text=btrim(p_target_token_id)
           and ch.campaign_id=p_campaign_id
       ) then
      raise exception 'O alvo jogador não possui ficha ativa nesta campanha ou é o próprio atacante.';
    end if;
  end if;
  if not priv.srd_confusion_attack_target_allowed(p_campaign_id,'character',btrim(p_character_id),btrim(p_target_token_id)) then
    raise exception 'A condição Confuso impede este alvo. Siga o resultado D100 do turno e o alvo obrigatório registrado.';
  end if;

  -- Se a interface informar uma instância, ela deve pertencer à ficha e estar equipada.
  -- Não aceitamos UUID arbitrário nem item apenas presente no inventário.
  if p_weapon_instance_id is not null and not exists (
    select 1
    from public.srd_character_weapon_instances wi
    where wi.instance_id = p_weapon_instance_id
      and wi.character_id = btrim(p_character_id)
      and wi.equipado is true
      and wi.hand_slot is not null
  ) then
    raise exception 'A instância de arma não pertence à ficha ou não está equipada em uma mão válida.';
  end if;

  select coalesce(sum(
    case lower(coalesce(c.bab_progression,''))
      when 'good' then cl.class_level
      when 'bom' then cl.class_level
      when 'average' then floor(3 * cl.class_level / 4.0)::integer
      when 'medium' then floor(3 * cl.class_level / 4.0)::integer
      when 'medio' then floor(3 * cl.class_level / 4.0)::integer
      when 'poor' then floor(cl.class_level / 2.0)::integer
      when 'ruim' then floor(cl.class_level / 2.0)::integer
      else 0
    end
  ),0)::integer
  into v_bab
  from public.srd_character_class_levels cl
  join public.srd_classes c on c.id = cl.class_id
  where cl.character_id::text = btrim(p_character_id);

  if v_bab < 6 then
    raise exception 'Esta ficha ainda não possui BBA +6 para ataques iterativos.';
  end if;

  v_attacks := least(6, floor((v_bab - 1) / 5.0)::integer + 1);
  v_combat := coalesce(v_campaign.combat_data,'{}'::jsonb);
  if lower(coalesce(v_combat->>'active','false')) <> 'true'
     or coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$' then
    raise exception 'A iniciativa não está ativa ou o turno atual é inválido.';
  end if;
  v_turn := (v_combat->>'current_turn')::integer;
  v_round := case when coalesce(v_combat->>'round','') ~ '^[0-9]+$'
    then greatest(1,(v_combat->>'round')::integer) else 1 end;

  if exists (
    select 1 from public.srd_attack_sequences s
    where s.campaign_id = p_campaign_id
      and s.actor_character_id::text = btrim(p_character_id)
      and s.round_number = v_round and s.turn_index = v_turn
      and s.status = 'active'
  ) then
    raise exception 'Já existe uma sequência de ataques ativa para este turno.';
  end if;

  v_action := public.consumir_acao_rodada_completa_srd(
    p_campaign_id, btrim(p_character_id), 'character'
  );

  insert into public.srd_attack_sequences(
    campaign_id, actor_character_id, target_token_id, attack_type,
    weapon_instance_id, round_number, turn_index, base_attack_bonus,
    attacks_total, created_by
  ) values (
    p_campaign_id, btrim(p_character_id)::bigint, btrim(p_target_token_id), p_attack_type,
    p_weapon_instance_id, v_round, v_turn, v_bab, v_attacks, v_user
  )
  returning * into v_sequence;

  return jsonb_build_object(
    'sequence_id', v_sequence.id,
    'campaign_id', v_sequence.campaign_id,
    'actor_character_id', v_sequence.actor_character_id,
    'target_token_id', v_sequence.target_token_id,
    'attack_type', v_sequence.attack_type,
    'round', v_sequence.round_number,
    'turn_index', v_sequence.turn_index,
    'base_attack_bonus', v_sequence.base_attack_bonus,
    'attacks_total', v_sequence.attacks_total,
    'next_attack_index', v_sequence.next_attack_index,
    'action_economy', v_action->'action_economy'
  );
end;
$function$
;

-- iniciar_sequencia_ataque_iterativo_srd_7_impl(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text)
CREATE OR REPLACE FUNCTION priv.iniciar_sequencia_ataque_iterativo_srd_7_impl(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_instance public.srd_character_weapon_instances%ROWTYPE;
  v_equipment public.srd_equipment%ROWTYPE;
  v_is_double boolean := false;
  v_result jsonb;
BEGIN
  IF p_weapon_instance_id IS NULL THEN
    RAISE EXCEPTION 'Selecione uma instância de arma equipada.';
  END IF;
  IF p_weapon_hand_slot IS NULL OR p_weapon_hand_slot NOT IN ('main_hand','off_hand') THEN
    RAISE EXCEPTION 'Mão da arma inválida.';
  END IF;

  SELECT * INTO v_instance
  FROM public.srd_character_weapon_instances
  WHERE instance_id = p_weapon_instance_id
    AND character_id = btrim(p_character_id)
    AND equipado IS TRUE
    AND hand_slot = p_weapon_hand_slot
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'A instância não está equipada na mão informada.';
  END IF;

  SELECT * INTO v_equipment
  FROM public.srd_equipment
  WHERE id = v_instance.equipment_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Equipamento da instância não encontrado no catálogo.';
  END IF;

  v_is_double := COALESCE((v_equipment.detalhes->>'weapon_double')::boolean, false);

  IF v_is_double AND (p_weapon_end IS NULL OR p_weapon_end NOT IN ('main','off')) THEN
    RAISE EXCEPTION 'Escolha a extremidade principal ou secundária da arma dupla.';
  ELSIF NOT v_is_double AND p_weapon_end IS NOT NULL THEN
    RAISE EXCEPTION 'Arma comum não possui seleção de extremidade.';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.srd_character_equipment ce
    WHERE ce.character_id = btrim(p_character_id)
      AND ce.equipment_id = v_instance.equipment_id
      AND ce.equipado IS TRUE
      AND ce.hand_slot = v_instance.hand_slot
  ) THEN
    RAISE EXCEPTION 'Inventário e instância de arma estão inconsistentes.';
  END IF;

  v_result := public.iniciar_sequencia_ataque_iterativo_srd(
    p_campaign_id, p_character_id, p_target_token_id,
    p_attack_type, p_weapon_instance_id
  );

  UPDATE public.srd_attack_sequences
  SET weapon_hand_slot = p_weapon_hand_slot,
      weapon_end = p_weapon_end
  WHERE id = (v_result->>'sequence_id')::uuid;

  RETURN v_result || jsonb_build_object(
    'weapon_instance_id', p_weapon_instance_id,
    'weapon_hand_slot', p_weapon_hand_slot,
    'weapon_end', p_weapon_end,
    'weapon_equipment_id', v_instance.equipment_id,
    'weapon_is_double', v_is_double
  );
END;
$function$
;

-- iniciar_sequencia_ataque_iterativo_srd_8_impl(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text, p_power_attack_penalty integer)
CREATE OR REPLACE FUNCTION priv.iniciar_sequencia_ataque_iterativo_srd_8_impl(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text, p_power_attack_penalty integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_sheet public.srd_character_sheets%rowtype;
  v_weapon public.srd_equipment%rowtype;
  v_result jsonb;
  v_penalty integer:=coalesce(p_power_attack_penalty,0);
  v_bab integer;
  v_level integer;
begin
  if auth.uid() is null then raise exception 'É necessário estar autenticado.'; end if;
  if v_penalty<0 or v_penalty>30 then raise exception 'Penalidade de Ataque Poderoso inválida.'; end if;
  select sh.* into v_sheet from public.srd_character_sheets sh
  where sh.character_id::text=btrim(p_character_id);
  if not found then raise exception 'Ficha SRD não encontrada.'; end if;
  if v_penalty>0 then
    if p_attack_type<>'atk-corpo' then raise exception 'Ataque Poderoso só se aplica a ataques corpo a corpo.'; end if;
    if coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)<13 then
      raise exception 'Ataque Poderoso exige Força 13 ou superior.';
    end if;
    if not exists(select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f where f->>'id'='ataque_poderoso') then
      raise exception 'A ficha não possui o talento Ataque Poderoso.';
    end if;
    select eq.* into v_weapon from public.srd_character_weapon_instances wi
      join public.srd_equipment eq on eq.id=wi.equipment_id
      where wi.instance_id=p_weapon_instance_id and wi.character_id=btrim(p_character_id)
        and wi.equipado is true and wi.hand_slot=p_weapon_hand_slot;
    if not found then raise exception 'Arma não está equipada na mão selecionada.'; end if;
    if coalesce((v_weapon.detalhes->>'weapon_light')::boolean,false) then
      raise exception 'Ataque Poderoso não pode ser usado com arma leve.';
    end if;
    select coalesce(sum(case lower(coalesce(cl.bab_progression,''))
      when 'good' then lv.class_level when 'bom' then lv.class_level
      when 'average' then floor(3*lv.class_level/4.0)::integer
      when 'medium' then floor(3*lv.class_level/4.0)::integer
      when 'medio' then floor(3*lv.class_level/4.0)::integer
      when 'poor' then floor(lv.class_level/2.0)::integer
      when 'ruim' then floor(lv.class_level/2.0)::integer else 0 end),0)::integer
      into v_bab from public.srd_character_class_levels lv
      join public.srd_classes cl on cl.id=lv.class_id
      where lv.character_id=v_sheet.character_id;
    if not exists(select 1 from public.srd_character_class_levels lv where lv.character_id=v_sheet.character_id) then
      select greatest(1,coalesce(v_sheet.nivel,1)) into v_level;
      select case lower(coalesce(cl.bab_progression,''))
        when 'good' then v_level when 'bom' then v_level
        when 'average' then floor(3*v_level/4.0)::integer
        when 'medium' then floor(3*v_level/4.0)::integer
        when 'medio' then floor(3*v_level/4.0)::integer
        when 'poor' then floor(v_level/2.0)::integer
        when 'ruim' then floor(v_level/2.0)::integer else 0 end
      into v_bab from public.srd_classes cl where cl.id=v_sheet.classe_id;
    end if;
    if v_penalty>coalesce(v_bab,0) then raise exception 'Penalidade excede o BBA atual.'; end if;
  end if;
  v_result:=public.iniciar_sequencia_ataque_iterativo_srd(
    p_campaign_id,p_character_id,p_target_token_id,p_attack_type,
    p_weapon_instance_id,p_weapon_hand_slot,p_weapon_end
  );
  update public.srd_attack_sequences set power_attack_penalty=v_penalty
    where id=(v_result->>'sequence_id')::uuid;
  return v_result||jsonb_build_object('power_attack_penalty',v_penalty);
end;
$function$
;

-- is_my_turn(p_campaign bigint, p_token bigint)
CREATE OR REPLACE FUNCTION priv.is_my_turn(p_campaign bigint, p_token bigint)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
  select coalesce((select (ordem->>turno_index)::bigint = p_token
                   from public.combat_state where campaign_id = p_campaign and ativo), false)
$function$
;

-- locked(k text)
CREATE OR REPLACE FUNCTION priv.locked(k text)
 RETURNS boolean
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$ select coalesce((select until_ts > now() from priv.throttle where key = k), false) $function$
;

-- log(cid bigint, t text, d jsonb)
CREATE OR REPLACE FUNCTION priv.log(cid bigint, t text, d jsonb)
 RETURNS void
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$ insert into public.campaign_log(campaign_id, type, data) values (cid, t, d) $function$
;

-- monster_atk(p_nivel integer)
CREATE OR REPLACE FUNCTION priv.monster_atk(p_nivel integer)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  select greatest(-1, case p_nivel
    when 1 then 3 when 2 then 4 when 3 then 6 when 4 then 8 when 5 then 10
    when 6 then 12 when 7 then 14 when 8 then 16 when 9 then 18 when 10 then 20
    when 11 then 22 when 12 then 24 when 13 then 26 when 14 then 28 when 15 then 30
    when 16 then 32 when 17 then 34 when 18 then 36 when 19 then 38 when 20 then 40
    else 0 end - 7)
$function$
;

-- mover_token_gm_cba_srd_impl(p_campaign_id bigint, p_token_id text, p_grid_x integer, p_grid_y integer)
CREATE OR REPLACE FUNCTION priv.mover_token_gm_cba_srd_impl(p_campaign_id bigint, p_token_id text, p_grid_x integer, p_grid_y integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_user UUID := auth.uid();
  v_campaign public.campaigns%ROWTYPE;
  v_combat JSONB;
  v_scene JSONB;
  v_tokens JSONB;
  v_order JSONB;
  v_actor JSONB;
  v_token JSONB;
  v_token_count INTEGER;
  v_token_index BIGINT;
  v_token_type TEXT;
  v_token_size_text TEXT;
  v_token_size INTEGER := 1;
  v_speed_text TEXT;
  v_speed_number TEXT;
  v_speed_m NUMERIC;
  v_old_x INTEGER;
  v_old_y INTEGER;
  v_move_squares INTEGER;
  v_diagonal_steps INTEGER := 0;
  v_diagonal_extra INTEGER := 0;
  v_movement_used NUMERIC;
  v_remaining_m NUMERIC;
  v_round INTEGER;
  v_current_turn INTEGER;
  v_economy JSONB;
  v_by_token JSONB;
  v_token_actions JSONB;
  v_movement_usage JSONB;
  v_usage JSONB;
  v_used_squares INTEGER:=0;
  v_total_squares INTEGER;
  v_used_diagonal_steps INTEGER:=0;
  v_segment_diagonal_steps INTEGER:=0;
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  IF p_grid_x IS NULL OR p_grid_y IS NULL OR p_grid_x < 0 OR p_grid_y < 0
     OR p_grid_x > 199 OR p_grid_y > 199 THEN
    RAISE EXCEPTION 'A posição deve estar na grade, com coordenadas inteiras entre 0 e 199.';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.members
    WHERE campaign_id = p_campaign_id AND user_id = v_user AND role = 'GM'
  ) THEN RAISE EXCEPTION 'Somente o Mestre pode mover tokens sob seu controle.'; END IF;

  SELECT campaign.* INTO v_campaign
  FROM public.campaigns AS campaign
  WHERE campaign.id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND OR UPPER(COALESCE(v_campaign.state, '')) <> 'COMBATE' THEN
    RAISE EXCEPTION 'A campanha não está em combate.';
  END IF;
  v_combat := COALESCE(v_campaign.combat_data, '{}'::JSONB);
  IF COALESCE(v_combat->>'active', 'false') <> 'true' THEN
    RAISE EXCEPTION 'Não há turno de combate ativo.';
  END IF;
  v_order := CASE WHEN jsonb_typeof(v_combat->'turn_order') = 'array'
                  THEN v_combat->'turn_order' ELSE '[]'::JSONB END;
  IF COALESCE(v_combat->>'current_turn', '') !~ '^[0-9]+$' THEN
    RAISE EXCEPTION 'O turno atual da iniciativa é inválido.';
  END IF;
  v_current_turn := (v_combat->>'current_turn')::INTEGER;
  v_actor := v_order->v_current_turn;
  PERFORM priv.srd_validate_surprise_action(p_campaign_id,BTRIM(p_token_id),'movimento');
  IF v_actor->>'id' IS DISTINCT FROM BTRIM(p_token_id) THEN
    RAISE EXCEPTION 'O token não está no turno ativo.';
  END IF;

  v_scene := COALESCE(v_campaign.cba_data, '{}'::JSONB);
  v_tokens := CASE WHEN jsonb_typeof(v_scene->'tokens') = 'array'
                   THEN v_scene->'tokens' ELSE '[]'::JSONB END;
  SELECT COUNT(*)::INTEGER, MIN(token.ordinality)
  INTO v_token_count, v_token_index
  FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS token(value, ordinality)
  WHERE token.value->>'id' = BTRIM(p_token_id);
  IF v_token_count <> 1 THEN RAISE EXCEPTION 'O token não existe na cena ou está duplicado.'; END IF;
  v_token := v_tokens->(v_token_index::INTEGER - 1);
  v_token_type := v_token->>'tipo';
  IF v_token_type NOT IN ('npc', 'monstro', 'player') THEN
    RAISE EXCEPTION 'Este tipo de token não pode ser movido pelo Mestre nesta ação.';
  END IF;
  IF v_token_type = 'player' AND NOT EXISTS (
    SELECT 1 FROM public.characters AS character
    WHERE character.id::TEXT = BTRIM(p_token_id)
      AND character.campaign_id = p_campaign_id
  ) THEN RAISE EXCEPTION 'O token de personagem não pertence ao Mestre.'; END IF;
  IF COALESCE(v_token->>'gridX', '') !~ '^[0-9]{1,3}$'
     OR COALESCE(v_token->>'gridY', '') !~ '^[0-9]{1,3}$' THEN
    RAISE EXCEPTION 'A posição atual do token é inválida.';
  END IF;
  v_old_x := (v_token->>'gridX')::INTEGER;
  v_old_y := (v_token->>'gridY')::INTEGER;
  IF NOT priv.srd_confusion_flee_destination_allowed(p_campaign_id,BTRIM(p_token_id),p_grid_x,p_grid_y) THEN
    RAISE EXCEPTION 'Confuso: a movimentação deve aumentar a distância em relação ao conjurador.';
  END IF;
  v_token_size_text := COALESCE(v_token->'monsterStats'->>'tamanho',v_token->'monsterStats'->>'size',v_token->>'tamanho');
  IF v_token_type='player' THEN
    SELECT race.tamanho::TEXT INTO v_token_size_text
      FROM public.characters character
      JOIN public.srd_character_sheets sheet ON sheet.character_id=character.id
      JOIN public.srd_races race ON race.id::TEXT=sheet.raca_id::TEXT
     WHERE character.id::TEXT=BTRIM(p_token_id) AND character.campaign_id=p_campaign_id;
  END IF;
  v_token_size := CASE
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_token_size_text,'')) LIKE 'colossal%' THEN 5
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_token_size_text,'')) LIKE 'gargantuan%'
      OR public.srd35_normalizar_parametro_talento(COALESCE(v_token_size_text,'')) LIKE 'imenso%' THEN 4
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_token_size_text,'')) LIKE 'huge%'
      OR public.srd35_normalizar_parametro_talento(COALESCE(v_token_size_text,'')) LIKE 'enorme%' THEN 3
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_token_size_text,'')) LIKE 'large%'
      OR public.srd35_normalizar_parametro_talento(COALESCE(v_token_size_text,'')) LIKE 'grande%' THEN 2
    ELSE 1 END;

  IF EXISTS (
    SELECT 1
      FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS other_token(value, ordinality)
      LEFT JOIN public.characters other_character
        ON other_character.id::TEXT=other_token.value->>'id' AND other_character.campaign_id=p_campaign_id
      LEFT JOIN public.srd_character_sheets other_sheet
        ON other_sheet.character_id=other_character.id
      LEFT JOIN public.srd_races other_race
        ON other_race.id::TEXT=other_sheet.raca_id::TEXT
      CROSS JOIN LATERAL (
        SELECT
          CASE
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(other_token.value->'monsterStats'->>'tamanho',other_token.value->'monsterStats'->>'size',other_token.value->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'colossal%' THEN 5
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(other_token.value->'monsterStats'->>'tamanho',other_token.value->'monsterStats'->>'size',other_token.value->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'gargantuan%'
              OR public.srd35_normalizar_parametro_talento(COALESCE(other_token.value->'monsterStats'->>'tamanho',other_token.value->'monsterStats'->>'size',other_token.value->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'imenso%' THEN 4
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(other_token.value->'monsterStats'->>'tamanho',other_token.value->'monsterStats'->>'size',other_token.value->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'huge%'
              OR public.srd35_normalizar_parametro_talento(COALESCE(other_token.value->'monsterStats'->>'tamanho',other_token.value->'monsterStats'->>'size',other_token.value->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'enorme%' THEN 3
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(other_token.value->'monsterStats'->>'tamanho',other_token.value->'monsterStats'->>'size',other_token.value->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'large%'
              OR public.srd35_normalizar_parametro_talento(COALESCE(other_token.value->'monsterStats'->>'tamanho',other_token.value->'monsterStats'->>'size',other_token.value->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'grande%' THEN 2
            ELSE 1
          END AS footprint,
          CASE WHEN COALESCE(other_token.value->>'gridX','') ~ '^[0-9]{1,3}$' THEN (other_token.value->>'gridX')::INTEGER ELSE -1 END AS gx,
          CASE WHEN COALESCE(other_token.value->>'gridY','') ~ '^[0-9]{1,3}$' THEN (other_token.value->>'gridY')::INTEGER ELSE -1 END AS gy
      ) AS other_space
     WHERE other_token.ordinality<>v_token_index AND other_space.gx>=0 AND other_space.gy>=0
       AND p_grid_x < other_space.gx+other_space.footprint AND p_grid_x+v_token_size > other_space.gx
       AND p_grid_y < other_space.gy+other_space.footprint AND p_grid_y+v_token_size > other_space.gy
  ) THEN RAISE EXCEPTION 'O espaço de destino está ocupado pela área de outro token.'; END IF;

  
IF v_token_type='npc' AND NULLIF(BTRIM(v_token->>'sourceCharacterId'),'') IS NOT NULL THEN
    SELECT race.deslocamento INTO v_speed_m
      FROM public.srd_character_sheets AS sheet
      JOIN public.srd_races AS race ON race.id::TEXT=sheet.raca_id::TEXT
     WHERE sheet.character_id::TEXT=BTRIM(v_token->>'sourceCharacterId');
    IF NOT FOUND OR v_speed_m IS NULL THEN
      RAISE EXCEPTION 'Não foi possível obter o deslocamento racial da ficha vinculada a %.',v_token->>'nome';
    END IF;
    v_speed_m:=public.srd35_deslocamento_personagem(BTRIM(v_token->>'sourceCharacterId'),v_speed_m);
    IF priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'no_move')
       OR priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(v_token->>'sourceCharacterId'),'no_move')
       OR ((priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'no_actions')
         OR priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(v_token->>'sourceCharacterId'),'no_actions'))
         AND NOT (priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'flee')
           OR priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(v_token->>'sourceCharacterId'),'flee'))) THEN
      RAISE EXCEPTION 'A condição atual impede movimentação.';
    END IF;
    v_speed_m:=v_speed_m*priv.srd_condition_speed_multiplier(p_campaign_id,'token',BTRIM(p_token_id));
  ELSE
    v_speed_text := COALESCE(
      NULLIF(v_token->>'deslocamento_m', ''),
      NULLIF(v_token->'monsterStats'->>'deslocamento', ''),
      NULLIF(v_token->'monsterStats'->>'speed', ''),
      NULLIF(v_token->>'speed_m', '')
    );
    IF v_token_type = 'player' THEN
      SELECT race.deslocamento::TEXT INTO v_speed_text
      FROM public.characters AS character
      JOIN public.srd_character_sheets AS sheet ON sheet.character_id::TEXT = character.id::TEXT
      JOIN public.srd_races AS race ON race.id::TEXT = sheet.raca_id::TEXT
      WHERE character.id::TEXT = BTRIM(p_token_id)
        AND character.campaign_id = p_campaign_id;
    END IF;
    IF v_speed_text IS NULL OR BTRIM(v_speed_text) = '' THEN
      v_speed_m := 9;
    ELSE
      v_speed_number := substring(v_speed_text FROM '([0-9]+([.][0-9]+)?)');
      IF v_speed_number IS NULL THEN RAISE EXCEPTION 'Não foi possível ler o deslocamento de %.', v_token->>'nome'; END IF;
      v_speed_m := v_speed_number::NUMERIC;
      IF LOWER(v_speed_text) ~ '(ft|feet|foot|p[eé]s|pé)' THEN v_speed_m := v_speed_m * 0.3048; END IF;
    END IF;
    IF v_token_type<>'player' THEN
      IF priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'no_move') OR (priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'no_actions') AND NOT priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'flee')) THEN
        RAISE EXCEPTION 'A condição atual impede movimentação.';
      END IF;
      v_speed_m:=v_speed_m*priv.srd_condition_speed_multiplier(p_campaign_id,'token',BTRIM(p_token_id));
    END IF;
    IF v_token_type='player' THEN
      IF priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_token_id),'no_move') OR (priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_token_id),'no_actions') AND NOT priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_token_id),'flee')) THEN
        RAISE EXCEPTION 'A condição atual impede movimentação.';
      END IF;
      v_speed_m:=public.srd35_deslocamento_personagem(BTRIM(p_token_id),v_speed_m);
      v_speed_m:=v_speed_m*priv.srd_condition_speed_multiplier(p_campaign_id,'character',BTRIM(p_token_id));
    END IF;
  END IF;

  -- D&D 3.5: permite dividir a ação de movimento antes/depois da ação padrão,
  -- acumulando distância e alternância diagonal durante o mesmo turno.
  v_round := CASE WHEN COALESCE(v_combat->>'round', '') ~ '^[0-9]+$'
                  THEN GREATEST(1, (v_combat->>'round')::INTEGER) ELSE 1 END;
  v_usage := CASE WHEN jsonb_typeof(v_combat->'movement_usage')='object'
                  THEN v_combat->'movement_usage' ELSE '{}'::JSONB END;
  IF v_usage->>'character_id'=BTRIM(p_token_id)
     AND v_usage->>'round'=v_round::TEXT
     AND v_usage->>'current_turn'=v_current_turn::TEXT
     AND COALESCE(v_usage->>'moved_squares','') ~ '^[0-9]+$' THEN
    v_used_squares:=(v_usage->>'moved_squares')::INTEGER;
    IF COALESCE(v_usage->>'diagonal_steps','') ~ '^[0-9]+$' THEN
      v_used_diagonal_steps:=(v_usage->>'diagonal_steps')::INTEGER;
    END IF;
  END IF;
  v_segment_diagonal_steps:=LEAST(ABS(p_grid_x-v_old_x),ABS(p_grid_y-v_old_y));
  v_diagonal_extra:=FLOOR((v_used_diagonal_steps+v_segment_diagonal_steps)/2.0)::INTEGER
    - FLOOR(v_used_diagonal_steps/2.0)::INTEGER;
  v_move_squares:=GREATEST(ABS(p_grid_x-v_old_x),ABS(p_grid_y-v_old_y))+v_diagonal_extra;
  v_diagonal_steps:=v_used_diagonal_steps+v_segment_diagonal_steps;
  v_total_squares:=v_used_squares+v_move_squares;
  v_movement_used:=v_total_squares*1.5;
  v_remaining_m:=GREATEST(0::NUMERIC,v_speed_m-v_movement_used);
  IF v_movement_used>v_speed_m THEN
    RAISE EXCEPTION 'Movimento excede o deslocamento restante deste turno (%.1f m restantes).',
      GREATEST(0::NUMERIC,v_speed_m-(v_used_squares*1.5));
  END IF;
  v_economy := v_combat->'action_economy';
  IF jsonb_typeof(v_economy) = 'object'
     AND COALESCE(v_economy->>'round', '') = v_round::TEXT
     AND jsonb_typeof(v_economy->'by_character') = 'object' THEN
    v_by_token := v_economy->'by_character';
  ELSE v_by_token := '{}'::JSONB; END IF;
  v_token_actions := CASE WHEN jsonb_typeof(v_by_token->BTRIM(p_token_id)) = 'object'
                          THEN v_by_token->BTRIM(p_token_id) ELSE '{}'::JSONB END;
  IF priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'one_move_or_standard') AND COALESCE(v_token_actions->>'padrao','false')='true' THEN RAISE EXCEPTION 'A condição permite apenas uma ação padrão ou de movimento por rodada.'; END IF;
  IF COALESCE(v_token_actions->>'movimento', 'false') = 'true' AND v_used_squares=0 THEN
    RAISE EXCEPTION 'A ação de movimento deste token já foi usada no turno.';
  END IF;
  v_token_actions := v_token_actions || jsonb_build_object('movimento', TRUE);
  v_by_token := jsonb_set(v_by_token, ARRAY[BTRIM(p_token_id)], v_token_actions, TRUE);
  v_combat := v_combat || jsonb_build_object(
    'action_economy', jsonb_build_object('round', v_round, 'by_character', v_by_token),
    'movement_usage', jsonb_build_object('round',v_round,'current_turn',v_current_turn,
      'character_id',BTRIM(p_token_id),'moved_squares',v_total_squares,'diagonal_steps',v_diagonal_steps)
  );
  v_token := v_token || jsonb_build_object('gridX', p_grid_x, 'gridY', p_grid_y);
  v_scene := v_scene || jsonb_build_object('tokens', jsonb_set(v_tokens, ARRAY[(v_token_index - 1)::TEXT], v_token, FALSE));
  UPDATE public.campaigns SET cba_data = v_scene, combat_data = v_combat WHERE id = p_campaign_id;
  RETURN jsonb_build_object('cba_data',v_scene,'combat_data',v_combat,
    'movement_remaining_m',GREATEST(0::NUMERIC,v_speed_m-v_movement_used));
END
$function$
;

-- mover_token_player_cba_impl(p_campaign_id bigint, p_character_id text, p_grid_x integer, p_grid_y integer)
CREATE OR REPLACE FUNCTION priv.mover_token_player_cba_impl(p_campaign_id bigint, p_character_id text, p_grid_x integer, p_grid_y integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_combat JSONB;
  v_campaign_state TEXT;
  v_scene JSONB;
  v_tokens JSONB;
  v_order JSONB;
  v_usage JSONB;
  v_entry JSONB;
  v_current_id TEXT;
  v_round INTEGER;
  v_current_turn INTEGER;
  v_token_index BIGINT;
  v_token_count INTEGER;
  v_character_id TEXT;
  v_race_id TEXT;
  v_mover_size_text TEXT;
  v_token_size INTEGER := 1;
  v_raw_speed TEXT;
  v_speed_m NUMERIC;
  v_used_squares INTEGER := 0;
  v_move_squares INTEGER;
  v_total_squares INTEGER;
  v_used_diagonal_steps INTEGER := 0;
  v_segment_diagonal_steps INTEGER := 0;
  v_diagonal_steps INTEGER := 0;
  v_diagonal_extra INTEGER := 0;
  v_remaining_m NUMERIC;
  v_old_x INTEGER;
  v_old_y INTEGER;
  v_active BOOLEAN;
  v_action_state JSONB;
  v_by_character JSONB;
  v_character_actions JSONB;
  v_new_token JSONB;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF NULLIF(BTRIM(p_character_id), '') IS NULL THEN
    RAISE EXCEPTION 'O identificador do personagem é obrigatório.';
  END IF;
  IF p_grid_x IS NULL OR p_grid_y IS NULL OR p_grid_x < 0 OR p_grid_y < 0
     OR p_grid_x > 199 OR p_grid_y > 199 THEN
    RAISE EXCEPTION 'A posição deve estar na grade, com coordenadas inteiras entre 0 e 199.';
  END IF;

  SELECT c.cba_data, c.combat_data, c.state INTO v_scene, v_combat, v_campaign_state
  FROM public.campaigns AS c
  WHERE c.id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  v_combat := COALESCE(v_combat,'{}'::JSONB);
  v_active := lower(COALESCE(v_combat->>'active', 'false')) = 'true';
  IF v_active THEN
    v_order := CASE WHEN jsonb_typeof(v_combat->'turn_order') = 'array'
                    THEN v_combat->'turn_order' ELSE '[]'::JSONB END;
    IF jsonb_array_length(v_order) = 0 THEN RAISE EXCEPTION 'A ordem de iniciativa está vazia.'; END IF;
    v_current_turn := CASE WHEN COALESCE(v_combat->>'current_turn', '') ~ '^[0-9]+$'
                           THEN (v_combat->>'current_turn')::INTEGER ELSE 0 END;
    IF v_current_turn >= jsonb_array_length(v_order) THEN RAISE EXCEPTION 'O turno atual da iniciativa é inválido.'; END IF;
    v_entry := v_order->v_current_turn;
    PERFORM priv.srd_validate_surprise_action(p_campaign_id,BTRIM(p_character_id),'movimento');
    v_current_id := v_entry->>'id';
    IF COALESCE(lower(v_entry->>'is_monster'), 'false') = 'true' THEN RAISE EXCEPTION 'O turno atual pertence a uma criatura controlada pelo Mestre.'; END IF;
    IF v_current_id IS DISTINCT FROM BTRIM(p_character_id) THEN RAISE EXCEPTION 'Somente o personagem cujo turno está ativo pode mover seu token.'; END IF;
  ELSIF UPPER(COALESCE(v_campaign_state,''))='COMBATE' THEN
    RAISE EXCEPTION 'Aguarde a ativação da iniciativa para mover durante o combate.';
  END IF;

  SELECT c.id::TEXT, s.raca_id::TEXT INTO v_character_id, v_race_id
  FROM public.characters AS c
  JOIN public.srd_character_sheets AS s ON s.character_id::TEXT = c.id::TEXT
  WHERE c.id::TEXT = BTRIM(p_character_id)
    AND c.campaign_id = p_campaign_id
    AND c.user_id = auth.uid()
  FOR UPDATE OF c, s;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'O personagem não pertence à sua conta ou não tem ficha SRD nesta campanha.';
  END IF;

  SELECT to_jsonb(r)->>'deslocamento', r.tamanho::TEXT INTO v_raw_speed, v_mover_size_text
  FROM public.srd_races AS r
  WHERE r.id::TEXT = v_race_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'A raça da ficha não foi encontrada.';
  END IF;
  IF v_raw_speed IS NULL THEN
    v_speed_m := 9;
  ELSIF v_raw_speed ~ '^[0-9]+([.][0-9]+)?$' THEN
    v_speed_m := v_raw_speed::NUMERIC;
  ELSE
    RAISE EXCEPTION 'O deslocamento racial não possui um valor numérico válido em metros.';
  END IF;
  IF priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_move') OR (priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_actions') AND NOT priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'flee')) THEN RAISE EXCEPTION 'A condição atual impede movimentação.'; END IF;
  v_speed_m := public.srd35_deslocamento_personagem(v_character_id,v_speed_m);
  v_speed_m:=v_speed_m*priv.srd_condition_speed_multiplier(p_campaign_id,'character',v_character_id);
  v_speed_m:=LEAST(v_speed_m*2,v_speed_m+priv.srd_effective_modifier(p_campaign_id,'character',v_character_id,'speed_m'));
  IF v_speed_m < 0 THEN
    RAISE EXCEPTION 'O deslocamento racial não pode ser negativo.';
  END IF;

  v_tokens := CASE WHEN jsonb_typeof(v_scene->'tokens') = 'array'
                   THEN v_scene->'tokens' ELSE '[]'::JSONB END;
  SELECT count(*)::INTEGER, min(q.ordinality)
  INTO v_token_count, v_token_index
  FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS q(token, ordinality)
  WHERE q.token->>'id' = v_character_id AND q.token->>'tipo' = 'player';
  IF v_token_count = 0 THEN
    RAISE EXCEPTION 'Não existe token player publicado para este personagem.';
  ELSIF v_token_count > 1 THEN
    RAISE EXCEPTION 'Há mais de um token player para este personagem; peça ao Mestre para corrigir a cena.';
  END IF;
  v_entry := v_tokens->(v_token_index::INTEGER - 1);
  IF COALESCE(v_entry->>'gridX', '') !~ '^[0-9]+$'
     OR COALESCE(v_entry->>'gridY', '') !~ '^[0-9]+$' THEN
    RAISE EXCEPTION 'A posição atual do token é inválida.';
  END IF;
  v_old_x := (v_entry->>'gridX')::INTEGER;
  v_old_y := (v_entry->>'gridY')::INTEGER;
  IF NOT priv.srd_confusion_flee_destination_allowed(p_campaign_id,v_character_id,p_grid_x,p_grid_y) THEN
    RAISE EXCEPTION 'Confuso: a movimentação deve aumentar a distância em relação ao conjurador.';
  END IF;
  IF v_old_x < 0 OR v_old_y < 0 OR v_old_x > 199 OR v_old_y > 199 THEN
    RAISE EXCEPTION 'A posição atual do token está fora do domínio válido da grade.';
  END IF;
  v_token_size := CASE
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'colossal%' THEN 5
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'gargantuan%'
      OR public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'imenso%' THEN 4
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'huge%'
      OR public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'enorme%' THEN 3
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'large%'
      OR public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'grande%' THEN 2
    ELSE 1 END;

  IF EXISTS (
    SELECT 1
      FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS q(token, ordinality)
      LEFT JOIN public.characters other_character
        ON other_character.id::TEXT=q.token->>'id' AND other_character.campaign_id=p_campaign_id
      LEFT JOIN public.srd_character_sheets other_sheet
        ON other_sheet.character_id=other_character.id
      LEFT JOIN public.srd_races other_race
        ON other_race.id::TEXT=other_sheet.raca_id::TEXT
      CROSS JOIN LATERAL (
        SELECT
          CASE
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'colossal%' THEN 5
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'gargantuan%'
              OR public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'imenso%' THEN 4
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'huge%'
              OR public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'enorme%' THEN 3
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'large%'
              OR public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'grande%' THEN 2
            ELSE 1
          END AS footprint,
          CASE WHEN COALESCE(q.token->>'gridX','') ~ '^[0-9]{1,3}$' THEN (q.token->>'gridX')::INTEGER ELSE -1 END AS gx,
          CASE WHEN COALESCE(q.token->>'gridY','') ~ '^[0-9]{1,3}$' THEN (q.token->>'gridY')::INTEGER ELSE -1 END AS gy
      ) AS other_space
     WHERE q.ordinality<>v_token_index AND other_space.gx>=0 AND other_space.gy>=0
       AND p_grid_x < other_space.gx+other_space.footprint AND p_grid_x+v_token_size > other_space.gx
       AND p_grid_y < other_space.gy+other_space.footprint AND p_grid_y+v_token_size > other_space.gy
  ) THEN
    RAISE EXCEPTION 'O espaço de destino está ocupado pela área de outro token.';
  END IF;

-- O custo do deslocamento é calculado após recuperar a sequência diagonal da rodada.
  IF v_active THEN
    v_round := CASE WHEN COALESCE(v_combat->>'round', '') ~ '^[0-9]+$'
                    THEN GREATEST(1, (v_combat->>'round')::INTEGER) ELSE 1 END;
    v_usage := CASE WHEN jsonb_typeof(v_combat->'movement_usage') = 'object'
                    THEN v_combat->'movement_usage' ELSE '{}'::JSONB END;
    IF v_usage->>'character_id' = v_character_id
       AND v_usage->>'round' = v_round::TEXT
       AND v_usage->>'current_turn' = v_current_turn::TEXT
       AND COALESCE(v_usage->>'moved_squares', '') ~ '^[0-9]+$' THEN
      v_used_squares := (v_usage->>'moved_squares')::INTEGER;
      IF COALESCE(v_usage->>'diagonal_steps','') ~ '^[0-9]+$' THEN
        v_used_diagonal_steps := (v_usage->>'diagonal_steps')::INTEGER;
      END IF;
    END IF;
    -- D&D 3.5: diagonais alternam custo de 1 e 2 quadrados (5 ft / 10 ft).
    v_segment_diagonal_steps := LEAST(ABS(p_grid_x - v_old_x), ABS(p_grid_y - v_old_y));
    v_diagonal_extra := FLOOR((v_used_diagonal_steps + v_segment_diagonal_steps) / 2.0)::INTEGER
      - FLOOR(v_used_diagonal_steps / 2.0)::INTEGER;
    v_move_squares := GREATEST(ABS(p_grid_x - v_old_x), ABS(p_grid_y - v_old_y)) + v_diagonal_extra;
    v_diagonal_steps := v_used_diagonal_steps + v_segment_diagonal_steps;
    v_total_squares := v_used_squares + v_move_squares;
    v_remaining_m := GREATEST(0::NUMERIC, v_speed_m - (v_total_squares * 1.5));
    IF v_total_squares * 1.5 > v_speed_m THEN
      RAISE EXCEPTION 'Movimento excede o deslocamento restante deste turno (%.1f m restantes).',
        GREATEST(0::NUMERIC, v_speed_m - (v_used_squares * 1.5));
    END IF;
  ELSE
    v_remaining_m := NULL;
  END IF;

  IF v_active THEN
    v_action_state := v_combat->'action_economy';
    IF jsonb_typeof(v_action_state)='object'
       AND COALESCE(v_action_state->>'round','')=v_round::TEXT
       AND jsonb_typeof(v_action_state->'by_character')='object' THEN
      v_by_character := v_action_state->'by_character';
    ELSE v_by_character := '{}'::JSONB; END IF;
    v_character_actions := CASE WHEN jsonb_typeof(v_by_character->v_character_id)='object'
      THEN v_by_character->v_character_id ELSE '{}'::JSONB END;
    IF COALESCE(v_character_actions->>'movimento','false')='true' AND v_used_squares=0 THEN
      RAISE EXCEPTION 'A ação de movimento deste personagem já foi usada neste turno.';
    END IF;
    IF priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'one_move_or_standard')
       AND COALESCE(v_character_actions->>'padrao','false')='true' THEN
      RAISE EXCEPTION 'A condição permite apenas uma ação padrão ou de movimento por rodada.';
    END IF;
    v_character_actions := v_character_actions || jsonb_build_object('movimento',TRUE);
    v_by_character := jsonb_set(v_by_character,ARRAY[v_character_id],v_character_actions,TRUE);
    v_action_state := jsonb_build_object('round',v_round,'by_character',v_by_character);
    v_combat := v_combat || jsonb_build_object('action_economy',v_action_state);
  END IF;

  v_new_token := v_entry || jsonb_build_object('gridX', p_grid_x, 'gridY', p_grid_y);
  v_scene := COALESCE(v_scene, '{}'::JSONB) || jsonb_build_object(
    'tokens', jsonb_set(v_tokens, ARRAY[(v_token_index - 1)::TEXT], v_new_token, FALSE)
  );
  IF v_active THEN
    v_combat := v_combat || jsonb_build_object(
      'movement_usage', jsonb_build_object(
        'round', v_round,
        'current_turn', v_current_turn,
        'character_id', v_character_id,
        'moved_squares', v_total_squares,
        'diagonal_steps', v_diagonal_steps
      )
    );
  END IF;
  UPDATE public.campaigns
  SET cba_data = v_scene, combat_data = v_combat
  WHERE id = p_campaign_id;
  RETURN jsonb_build_object(
    'cba_data', v_scene,
    'movement_remaining_m', v_remaining_m
  );
END;
$function$
;

-- need_gm(cid bigint)
CREATE OR REPLACE FUNCTION priv.need_gm(cid bigint)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
begin if public.my_role(cid) is distinct from 'GM' then raise exception 'Apenas o Mestre da mesa pode fazer isso.'; end if; end $function$
;

-- need_owner(cid bigint)
CREATE OR REPLACE FUNCTION priv.need_owner(cid bigint)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
begin if not exists (select 1 from public.campaigns where id = cid and owner_id = auth.uid() and active) then raise exception 'Apenas o Mestre da mesa pode fazer isso.'; end if; end $function$
;

-- new_sheet()
CREATE OR REPLACE FUNCTION priv.new_sheet()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
begin
  insert into public.character_sheets(character_id) values (new.id) on conflict do nothing;
  return new;
end $function$
;

-- new_user()
CREATE OR REPLACE FUNCTION priv.new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare u text;
begin
  u := coalesce(
    nullif(trim(new.raw_user_meta_data->>'username'), ''),
    'user_' || substr(new.id::text, 1, 8)
  );
  if exists (select 1 from public.profiles where lower(username) = lower(u)) then
    u := u || '_' || substr(new.id::text, 1, 4);
  end if;
  insert into public.profiles(id, username) values (new.id, u)
    on conflict (id) do nothing;
  return new;
end $function$
;

-- npc_aplicar_dano_ataque_iterativo_impl(p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid, p_sneak_damage_rolls integer[])
CREATE OR REPLACE FUNCTION priv.npc_aplicar_dano_ataque_iterativo_impl(p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid, p_sneak_damage_rolls integer[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_user uuid := auth.uid();
  v_campaign public.campaigns%rowtype;
  v_attempt public.srd_npc_attack_attempts%rowtype;
  v_seq public.srd_npc_attack_sequences%rowtype;
  v_sheet public.srd_character_sheets%rowtype;
  v_race public.srd_races%rowtype;
  v_weapon public.srd_equipment%rowtype;
  v_scene jsonb;
  v_tokens jsonb;
  v_target jsonb;
  v_target_ord bigint;
  v_target_count integer;
  v_expr text;
  v_dice integer;
  v_faces integer;
  v_mult integer := 1;
  v_roll_sum integer := 0;
  v_sneak_roll_sum integer := 0;
  v_sneak_dice_expected integer := 0;
  v_str integer := 0;
  v_str_bonus integer := 0;
  v_damage_bonus integer := 0;
  v_weapon_specialization_bonus integer := 0;
  v_critical_static_bonus integer := 0;
  v_raw_damage integer := 0;
  v_final_damage integer := 0;
  v_damage_type text;
  v_max_hp integer;
  v_hp integer;
  v_new_hp integer;
  v_end_meta jsonb;
  v_existing public.srd_npc_attack_attempts%rowtype;
  v_round integer;
  v_turn integer;
  i integer;
begin
  if v_user is null then raise exception 'É necessário estar autenticado.'; end if;
  if public.my_role(p_campaign_id) is distinct from 'GM' then raise exception 'Somente o Mestre pode aplicar dano de NPC.'; end if;
  if p_idempotency_key is null or p_damage_rolls is null
     or cardinality(p_damage_rolls)<1 or cardinality(p_damage_rolls)>30
     or array_position(p_damage_rolls,null) is not null
     or exists(select 1 from unnest(p_damage_rolls) x where x<1 or x>1000) then
    raise exception 'Rolagens de dano inválidas.';
  end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE' then
    raise exception 'A campanha não está em combate.';
  end if;

  select * into v_existing from public.srd_npc_attack_attempts
    where damage_idempotency_key=p_idempotency_key;
  if found then
    if v_existing.id<>p_attempt_id then raise exception 'Chave de dano já utilizada em outra tentativa.'; end if;
    return jsonb_build_object('attempt_id',v_existing.id,'status',v_existing.status,
      'damage_applied',v_existing.damage_applied,'damage_rolls',v_existing.damage_rolls,
      'replayed',true);
  end if;

  select * into v_attempt from public.srd_npc_attack_attempts where id=p_attempt_id for update;
  if not found then raise exception 'Tentativa de ataque não encontrada.'; end if;
  select * into v_seq from public.srd_npc_attack_sequences
    where id=v_attempt.sequence_id and campaign_id=p_campaign_id for update;
  if not found then raise exception 'Sequência não encontrada.'; end if;
  if v_seq.status<>'active' then raise exception 'A sequência de ataques não está mais ativa.'; end if;
  if v_seq.created_by<>v_user then raise exception 'Somente quem iniciou a sequência pode registrar o dano.'; end if;
  if v_attempt.status<>'hit_pending_damage' then raise exception 'A tentativa ainda não está pronta para receber dano.'; end if;
  if public.my_role(p_campaign_id) is distinct from 'GM' or v_seq.created_by<>v_user then
    raise exception 'Somente o Mestre que iniciou a sequência pode aplicar dano de NPC.';
  end if;

  v_turn:=case when coalesce(v_campaign.combat_data->>'current_turn','') ~ '^[0-9]+$'
    then (v_campaign.combat_data->>'current_turn')::integer else -1 end;
  v_round:=case when coalesce(v_campaign.combat_data->>'round','') ~ '^[0-9]+$'
    then greatest(1,(v_campaign.combat_data->>'round')::integer) else -1 end;
  if lower(coalesce(v_campaign.combat_data->>'active','false'))<>'true'
    or v_turn<>v_seq.turn_index or v_round<>v_seq.round_number then
    raise exception 'Turno ou rodada mudou antes da aplicação do dano.';
  end if;

  select sh.* into v_sheet from public.srd_character_sheets sh where sh.character_id=v_seq.actor_character_id;
  select r.* into v_race from public.srd_races r where r.id=v_sheet.raca_id;
  if not exists (
    select 1 from public.srd_character_weapon_instances wi
    where wi.instance_id=v_seq.weapon_instance_id and wi.character_id=v_seq.actor_character_id::text
      and wi.equipado is true and wi.hand_slot=v_seq.weapon_hand_slot
  ) then raise exception 'A arma não está mais equipada na mão vinculada.'; end if;
  if not exists (
    select 1 from public.srd_character_equipment ce
    join public.srd_character_weapon_instances wi on wi.instance_id=v_seq.weapon_instance_id
    where ce.character_id=v_seq.actor_character_id::text and ce.equipment_id=wi.equipment_id
      and ce.equipado is true and ce.hand_slot=v_seq.weapon_hand_slot
  ) then raise exception 'Inventário e instância da arma ficaram inconsistentes antes do dano.'; end if;
  select eq.* into v_weapon from public.srd_character_weapon_instances wi
    join public.srd_equipment eq on eq.id=wi.equipment_id
    where wi.instance_id=v_seq.weapon_instance_id;
  if not found then raise exception 'Arma não encontrada.'; end if;
  select coalesce(sum(case f->>'id'
    when 'srd35_feat_weapon_specialization' then 2
    when 'srd35_feat_greater_weapon_specialization' then 2
    else 0 end),0)::integer into v_weapon_specialization_bonus
  from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
  where f->>'id' in ('srd35_feat_weapon_specialization','srd35_feat_greater_weapon_specialization')
    and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))
      = public.srd35_normalizar_parametro_talento(v_weapon.nome);

  v_end_meta:=case when v_seq.weapon_end='off' then coalesce(v_weapon.detalhes->'weapon_end_off','{}'::jsonb)
    when v_seq.weapon_end='main' then coalesce(v_weapon.detalhes->'weapon_end_main','{}'::jsonb)
    else '{}'::jsonb end;
  v_expr:=coalesce(
    case when lower(coalesce(v_race.tamanho,'')) in ('pequeno','small')
      then v_end_meta->>'damage_small' else v_end_meta->>'damage_medium' end,
    case when lower(coalesce(v_race.tamanho,'')) in ('pequeno','small')
      then v_weapon.detalhes->>'damage_small' else v_weapon.detalhes->>'damage_medium' end,
    v_weapon.dano
  );
  if v_expr !~ '^[0-9]+d[0-9]+$' then
    raise exception 'Expressão de dano da arma não está normalizada: %.',coalesce(v_expr,'(vazia)');
  end if;
  v_dice:=split_part(v_expr,'d',1)::integer;
  v_faces:=split_part(v_expr,'d',2)::integer;
  if v_dice<1 or v_dice>10 or v_faces<2 or v_faces>100 then
    raise exception 'Expressão de dano da arma fora dos limites suportados.';
  end if;
  v_mult:=case when v_attempt.is_critical then
    coalesce(nullif(v_attempt.resolution_data->>'critical_multiplier','')::integer,2)
    else 1 end;
  if v_mult<2 or v_mult>5 then
    if v_attempt.is_critical then raise exception 'Multiplicador crítico inválido.'; else v_mult:=1; end if;
  end if;
  if cardinality(p_damage_rolls)<>v_dice*v_mult then
    raise exception 'A arma exige % resultados de dado de dano (% dados x multiplicador %).',
      v_dice*v_mult,v_dice,v_mult;
  end if;
  v_sneak_dice_expected:=greatest(0,coalesce(nullif(v_attempt.resolution_data->>'sneak_attack_dice','')::integer,0));
  if v_sneak_dice_expected=0 then
    if coalesce(cardinality(p_sneak_damage_rolls),0)<>0 then raise exception 'Esta tentativa não possui Ataque Furtivo elegível.'; end if;
  else
    if p_sneak_damage_rolls is null or cardinality(p_sneak_damage_rolls)<>v_sneak_dice_expected
       or array_position(p_sneak_damage_rolls,null) is not null
       or exists(select 1 from unnest(p_sneak_damage_rolls) x where x<1 or x>6) then
      raise exception 'Ataque Furtivo exige exatamente % resultados de d6 manuais.',v_sneak_dice_expected;
    end if;
    select coalesce(sum(x),0)::integer into v_sneak_roll_sum from unnest(p_sneak_damage_rolls) x;
  end if;
  for i in 1..cardinality(p_damage_rolls) loop
    if p_damage_rolls[i]>v_faces then
      raise exception 'Resultado % excede o dado d%.',p_damage_rolls[i],v_faces;
    end if;
    v_roll_sum:=v_roll_sum+p_damage_rolls[i];
  end loop;

   v_damage_bonus:=priv.srd_effective_modifier(p_campaign_id,'token',v_seq.actor_token_id,'damage');
  if v_seq.attack_type='atk-corpo' then
    v_str:=coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10);
    v_str_bonus:=floor((v_str+priv.srd_effective_modifier(p_campaign_id,'token',v_seq.actor_token_id,'strength')-10)::numeric/2)::integer;
    if v_seq.weapon_hand_slot='off_hand' then
      v_str_bonus:=floor(v_str_bonus/2.0)::integer;
    elsif coalesce((v_weapon.detalhes->>'weapon_two_handed')::boolean,false)
      and not coalesce((v_weapon.detalhes->>'weapon_double')::boolean,false) then
      v_str_bonus:=floor(v_str_bonus*1.5)::integer;
    end if;
    v_damage_bonus:=v_damage_bonus+v_str_bonus;
    v_critical_static_bonus:=v_critical_static_bonus+v_str_bonus;
  end if;
  v_damage_bonus:=v_damage_bonus+v_weapon_specialization_bonus;
  v_critical_static_bonus:=v_critical_static_bonus+v_weapon_specialization_bonus;
  if v_seq.attack_type='atk-corpo' and v_seq.power_attack_penalty>0 then
    v_damage_bonus:=v_damage_bonus+v_seq.power_attack_penalty * case when coalesce((v_weapon.detalhes->>'weapon_two_handed')::boolean,false) then 2 else 1 end;
    v_critical_static_bonus:=v_critical_static_bonus+v_seq.power_attack_penalty * case when coalesce((v_weapon.detalhes->>'weapon_two_handed')::boolean,false) then 2 else 1 end;
  end if;
  v_raw_damage:=v_roll_sum+v_damage_bonus+(v_critical_static_bonus*greatest(0,v_mult-1))+v_sneak_roll_sum;
  v_damage_type:=lower(coalesce(v_end_meta->>'damage_type',v_weapon.tipo_dano,'bludgeoning'));
  v_damage_type:=case v_damage_type
    when 'cortante' then 'slashing' when 'perfurante' then 'piercing'
    when 'impacto' then 'bludgeoning' when 'cortante/perfurante' then 'physical'
    when 'impacto/perfurante' then 'physical' else v_damage_type end;
  select t.token into v_target from jsonb_array_elements(case when jsonb_typeof(v_campaign.cba_data->'tokens')='array' then v_campaign.cba_data->'tokens' else '[]'::jsonb end) t(token) where t.token->>'id'=v_seq.target_token_id;
  if v_target is null then raise exception 'Alvo não encontrado na cena.'; end if;
  v_final_damage:=case when v_target->>'tipo'='player'
    then priv.srd_adjust_damage(p_campaign_id,'character',v_seq.target_token_id,v_damage_type,greatest(0,v_raw_damage))
    else priv.srd_adjust_damage(p_campaign_id,'token',v_seq.target_token_id,v_damage_type,greatest(0,v_raw_damage)) end;

  v_scene:=coalesce(v_campaign.cba_data,'{}'::jsonb);
  v_tokens:=case when jsonb_typeof(v_scene->'tokens')='array' then v_scene->'tokens' else '[]'::jsonb end;
  select count(*)::integer,min(t.ordinality) into v_target_count,v_target_ord
    from jsonb_array_elements(v_tokens) with ordinality t(token,ordinality)
    where t.token->>'id'=v_seq.target_token_id and t.token->>'tipo' in ('player','npc','monstro');
  if v_target_count<>1 then raise exception 'Alvo ausente ou duplicado na cena.'; end if;
  v_target:=v_tokens->(v_target_ord::integer-1);
  if v_target->>'tipo'='player' then
    select sh.pv_atual,sh.pv_max into v_hp,v_max_hp from public.srd_character_sheets sh
      where sh.character_id::text=v_seq.target_token_id for update;
    if not found or v_max_hp is null or v_max_hp<1 then raise exception 'Ficha do personagem alvo sem PV válidos.'; end if;
    v_new_hp:=greatest(-10,least(v_max_hp,coalesce(v_hp,v_max_hp)-v_final_damage));
    perform priv.srd_sync_character_vital_condition(v_seq.target_token_id,v_new_hp,false);
    update public.srd_character_sheets set pv_atual=v_new_hp where character_id::text=v_seq.target_token_id;
  else
    if coalesce(v_target->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' then raise exception 'PV máximo do alvo inválido.'; end if;
    v_max_hp:=(v_target->>'maxHp')::integer;
    v_hp:=case when coalesce(v_target->>'hp','') ~ '^-?[0-9]{1,6}$' then (v_target->>'hp')::integer else v_max_hp end;
    v_new_hp:=greatest(-10,least(v_max_hp,v_hp-v_final_damage));
  end if;
  v_target:=v_target||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp);
  v_scene:=v_scene||jsonb_build_object('tokens',jsonb_set(v_tokens,array[(v_target_ord-1)::text],v_target,false));
  update public.campaigns set cba_data=v_scene where id=p_campaign_id;
  perform priv.srd_sync_linked_npc_token_vitals(p_campaign_id,v_seq.target_token_id,v_new_hp,v_max_hp);

  update public.srd_npc_attack_attempts
    set status='damage_applied',damage_rolls=p_damage_rolls,damage_applied=v_final_damage,
      damage_type=v_damage_type,damage_applied_at=now(),damage_idempotency_key=p_idempotency_key,
      resolution_data=resolution_data||jsonb_build_object('damage_expression',v_expr,
        'damage_roll_sum',v_roll_sum,'sneak_attack_roll_sum',v_sneak_roll_sum,'sneak_attack_dice',v_sneak_dice_expected,'sneak_damage_rolls',to_jsonb(coalesce(p_sneak_damage_rolls,'{}'::integer[])),'damage_bonus',v_damage_bonus,'damage_raw',v_raw_damage,
        'damage_final',v_final_damage,'critical_multiplier_applied',v_mult)
    where id=p_attempt_id returning * into v_attempt;

  if v_attempt.attempt_index=v_seq.attacks_total then
    update public.srd_npc_attack_sequences set status='completed',completed_at=now() where id=v_seq.id;
  end if;
  return jsonb_build_object('attempt_id',v_attempt.id,'status',v_attempt.status,
    'damage_applied',v_final_damage,'damage_rolls',p_damage_rolls,'sneak_damage_rolls',coalesce(p_sneak_damage_rolls,'{}'::integer[]),'damage_type',v_damage_type,
    'target_hp',v_new_hp,'target_max_hp',v_max_hp,'critical',v_attempt.is_critical,
    'critical_multiplier',v_mult,'replayed',false);
end;
$function$
;

-- npc_confirmar_critico_ataque_iterativo_impl(p_campaign_id bigint, p_attempt_id uuid, p_confirmation_d20 integer)
CREATE OR REPLACE FUNCTION priv.npc_confirmar_critico_ataque_iterativo_impl(p_campaign_id bigint, p_attempt_id uuid, p_confirmation_d20 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_user uuid := auth.uid();
  v_campaign public.campaigns%rowtype;
  v_attempt public.srd_npc_attack_attempts%rowtype;
  v_seq public.srd_npc_attack_sequences%rowtype;
  v_bonus integer;
  v_total integer;
  v_confirmed boolean;
  v_scene jsonb;
  v_tokens jsonb;
begin
  if v_user is null then raise exception 'É necessário estar autenticado.'; end if;
  if public.my_role(p_campaign_id) is distinct from 'GM' then raise exception 'Somente o Mestre pode confirmar críticos de NPC.'; end if;
  if p_confirmation_d20 is null or p_confirmation_d20<1 or p_confirmation_d20>20 then
    raise exception 'Confirmação crítica exige um d20 válido.';
  end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE' then
    raise exception 'A campanha não está em combate.';
  end if;
  select * into v_attempt from public.srd_npc_attack_attempts where id=p_attempt_id for update;
  if not found then raise exception 'Tentativa de ataque não encontrada.'; end if;
  select * into v_seq from public.srd_npc_attack_sequences
    where id=v_attempt.sequence_id and campaign_id=p_campaign_id for update;
  if not found then raise exception 'Sequência não encontrada.'; end if;
  if v_seq.created_by<>v_user then raise exception 'Somente quem iniciou a sequência pode confirmar o crítico.'; end if;
  if v_attempt.status<>'critical_confirmation_pending' then
    return jsonb_build_object('attempt_id',v_attempt.id,'status',v_attempt.status,
      'is_critical',v_attempt.is_critical,'resolution_data',v_attempt.resolution_data,'replayed',true);
  end if;
  if public.my_role(p_campaign_id) is distinct from 'GM' or v_seq.created_by<>v_user then
    raise exception 'Somente o Mestre que iniciou a sequência pode confirmar o crítico.';
  end if;
  if lower(coalesce(v_campaign.combat_data->>'active','false'))<>'true'
    or coalesce(v_campaign.combat_data->>'current_turn','') !~ '^[0-9]+$'
    or (v_campaign.combat_data->>'current_turn')::integer<>v_seq.turn_index
    or coalesce(v_campaign.combat_data->>'round','') !~ '^[0-9]+$'
    or greatest(1,(v_campaign.combat_data->>'round')::integer)<>v_seq.round_number then
    raise exception 'Turno ou rodada mudou antes da confirmação crítica.';
  end if;
  select * into strict v_campaign from public.campaigns where id=p_campaign_id;
  v_scene:=coalesce(v_campaign.cba_data,'{}'::jsonb);
  v_tokens:=case when jsonb_typeof(v_scene->'tokens')='array' then v_scene->'tokens' else '[]'::jsonb end;
  if (select count(*) from jsonb_array_elements(v_tokens) t
      where t->>'id'=v_seq.target_token_id and t->>'tipo' in ('player','npc','monstro'))<>1 then
    raise exception 'Alvo não está mais presente na cena.';
  end if;
  if not exists (
    select 1 from public.srd_character_weapon_instances wi
    where wi.instance_id=v_seq.weapon_instance_id
      and wi.character_id=v_seq.actor_character_id::text
      and wi.equipado is true and wi.hand_slot=v_seq.weapon_hand_slot
  ) then raise exception 'A arma não está mais equipada na mão original.'; end if;
  if jsonb_typeof(v_attempt.resolution_data)<>'object'
     or coalesce(v_attempt.resolution_data->>'attack_total','') !~ '^-?[0-9]+$'
     or coalesce(v_attempt.resolution_data->>'target_ac','') !~ '^-?[0-9]+$' then
    raise exception 'Dados originais do ataque não permitem confirmar o crítico.';
  end if;
  v_bonus:=(v_attempt.resolution_data->>'attack_total')::integer-v_attempt.manual_d20;
  v_total:=p_confirmation_d20+v_bonus;
  v_confirmed:=p_confirmation_d20=20 or (p_confirmation_d20<>1 and v_total>=v_attempt.target_ac);
  update public.srd_npc_attack_attempts
  set critical_confirmation_d20=p_confirmation_d20,
      is_critical=v_confirmed,
      status='hit_pending_damage',
      resolution_data=resolution_data||jsonb_build_object(
        'critical_confirmation_d20',p_confirmation_d20,
        'critical_confirmation_total',v_total,
        'critical_confirmed',v_confirmed
      )
  where id=p_attempt_id returning * into v_attempt;
  return jsonb_build_object('attempt_id',v_attempt.id,'status',v_attempt.status,
    'is_critical',v_attempt.is_critical,'confirmation_total',v_total,
    'target_ac',v_attempt.target_ac,'replayed',false);
end;
$function$
;

-- npc_consultar_ataque_iterativo_impl(p_campaign_id bigint, p_token_id text, p_attack_type text)
CREATE OR REPLACE FUNCTION priv.npc_consultar_ataque_iterativo_impl(p_campaign_id bigint, p_token_id text, p_attack_type text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_user uuid := auth.uid();
  v_campaign public.campaigns%rowtype;
  v_token jsonb;
  v_token_count integer;
  v_character_id text;
  v_character public.characters%rowtype;
  v_sheet public.srd_character_sheets%rowtype;
  v_class public.srd_classes%rowtype;
  v_race public.srd_races%rowtype;
  v_bab integer := 0;
  v_level integer := 1;
  v_barbarian_level integer := 0;
  v_strength integer := 10;
  v_dexterity integer := 10;
  v_weapons jsonb := '[]'::jsonb;
  v_order jsonb;
  v_actor jsonb;
  v_current integer;
  v_round integer;
  v_action_state jsonb;
  v_actor_actions jsonb;
  v_has_power_attack boolean := false;
begin
  if v_user is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre autenticado pode consultar ataques de NPC.';
  end if;
  if lower(btrim(coalesce(p_attack_type,''))) not in ('atk-corpo','atk-dist') then
    raise exception 'Tipo de ataque inválido.';
  end if;

  select c.* into v_campaign
  from public.campaigns c where c.id=p_campaign_id;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
     or lower(coalesce(v_campaign.combat_data->>'active','false'))<>'true' then
    raise exception 'A campanha não está em combate ativo.';
  end if;

  v_order:=case when jsonb_typeof(v_campaign.combat_data->'turn_order')='array'
    then v_campaign.combat_data->'turn_order' else '[]'::jsonb end;
  if coalesce(v_campaign.combat_data->>'current_turn','') !~ '^[0-9]+$' then
    raise exception 'O turno atual é inválido.';
  end if;
  v_current:=(v_campaign.combat_data->>'current_turn')::integer;
  if v_current<0 or v_current>=jsonb_array_length(v_order) then
    raise exception 'Índice do turno atual fora da iniciativa.';
  end if;
  v_actor:=v_order->v_current;
  if v_actor->>'id' is distinct from btrim(p_token_id)
     or coalesce(v_actor->>'is_monster','false')<>'true' then
    raise exception 'O NPC não está no turno ativo do Mestre.';
  end if;

  select count(*)::integer,(jsonb_agg(t.token)->0)
  into v_token_count,v_token
  from jsonb_array_elements(case when jsonb_typeof(v_campaign.cba_data->'tokens')='array'
    then v_campaign.cba_data->'tokens' else '[]'::jsonb end) t(token)
  where t.token->>'id'=btrim(p_token_id) and t.token->>'tipo'='npc';
  if v_token_count<>1 then
    raise exception 'O token NPC está ausente ou duplicado.';
  end if;

  v_character_id:=nullif(v_token->>'sourceCharacterId','');
  if v_character_id is null then
    return jsonb_build_object('eligible',false,'reason','unlinked_npc');
  end if;
  select ch.* into v_character from public.characters ch where ch.id::text=v_character_id;
  if not found then raise exception 'Ficha de origem do NPC não encontrada.'; end if;
  select sh.* into v_sheet from public.srd_character_sheets sh where sh.character_id=v_character.id;
  if not found then return jsonb_build_object('eligible',false,'reason','missing_srd_sheet'); end if;

  select cl.* into v_class from public.srd_classes cl where cl.id=v_sheet.classe_id;
  select r.* into v_race from public.srd_races r where r.id=v_sheet.raca_id;
  if v_class.id is null or v_race.id is null then
    raise exception 'Classe ou raça da ficha de origem não encontrada.';
  end if;
  v_level:=greatest(1,coalesce(v_sheet.nivel,1));
  v_strength:=coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10);
  v_dexterity:=coalesce(nullif(v_sheet.atributos->>'DES','')::integer,10);

  select coalesce(sum(case lower(coalesce(cl.bab_progression,''))
    when 'good' then lv.class_level when 'bom' then lv.class_level
    when 'average' then floor(3*lv.class_level/4.0)::integer
    when 'medium' then floor(3*lv.class_level/4.0)::integer
    when 'medio' then floor(3*lv.class_level/4.0)::integer
    when 'poor' then floor(lv.class_level/2.0)::integer
    when 'ruim' then floor(lv.class_level/2.0)::integer else 0 end),0)::integer
  into v_bab
  from public.srd_character_class_levels lv
  join public.srd_classes cl on cl.id=lv.class_id
  where lv.character_id=v_sheet.character_id;
  if not exists(select 1 from public.srd_character_class_levels lv where lv.character_id=v_sheet.character_id) then
    v_bab:=case lower(coalesce(v_class.bab_progression,''))
      when 'good' then v_level when 'bom' then v_level
      when 'average' then floor(3*v_level/4.0)::integer
      when 'medium' then floor(3*v_level/4.0)::integer
      when 'medio' then floor(3*v_level/4.0)::integer
      when 'poor' then floor(v_level/2.0)::integer
      when 'ruim' then floor(v_level/2.0)::integer else 0 end;
  end if;
  select coalesce(max(lv.class_level),0)::integer into v_barbarian_level
  from public.srd_character_class_levels lv
  join public.srd_classes cl on cl.id=lv.class_id
  where lv.character_id=v_sheet.character_id and cl.class_key='barbarian';
  if v_barbarian_level=0 and not exists(select 1 from public.srd_character_class_levels lv where lv.character_id=v_sheet.character_id)
     and v_sheet.classe_id='barbaro' then
    v_barbarian_level:=v_level;
  end if;

  v_has_power_attack:=exists(
    select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array'
      then v_sheet.talentos else '[]'::jsonb end) f
    where f->>'id'='ataque_poderoso'
  );

  select coalesce(jsonb_agg(jsonb_build_object(
    'instance_id',wi.instance_id,'equipment_id',wi.equipment_id,
    'hand_slot',wi.hand_slot,'name',eq.nome,'damage',eq.dano,
    'critical',eq.critico,'details',eq.detalhes
  ) order by case wi.hand_slot when 'main_hand' then 1 else 2 end,eq.nome),'[]'::jsonb)
  into v_weapons
  from public.srd_character_weapon_instances wi
  join public.srd_equipment eq on eq.id=wi.equipment_id
  join public.srd_character_equipment ce
    on ce.character_id=v_sheet.character_id::text
   and ce.equipment_id=wi.equipment_id
   and ce.equipado is true and ce.hand_slot=wi.hand_slot
  where wi.character_id=v_sheet.character_id::text
    and wi.equipado is true
    and wi.hand_slot in ('main_hand','off_hand')
    and case when p_attack_type='atk-dist'
      then coalesce(eq.detalhes->>'weapon_ranged','false')='true'
      else coalesce(eq.detalhes->>'weapon_melee','true')<>'false' end;

  v_round:=case when coalesce(v_campaign.combat_data->>'round','') ~ '^[0-9]+$'
    then greatest(1,(v_campaign.combat_data->>'round')::integer) else 1 end;
  v_action_state:=v_campaign.combat_data->'action_economy';
  if jsonb_typeof(v_action_state)='object'
     and coalesce(v_action_state->>'round','')=v_round::text
     and jsonb_typeof(v_action_state->'by_character')='object' then
    v_actor_actions:=v_action_state->'by_character'->btrim(p_token_id);
  end if;

  return jsonb_build_object(
    'eligible',v_bab>=1,
    'reason',case when v_bab<1 then 'bab_below_1' when jsonb_array_length(v_weapons)=0 then 'no_equipped_weapon' else null end,
    'token_id',btrim(p_token_id),'token_name',coalesce(v_token->>'nome','NPC'),
    'character_id',v_character_id,'character_name',v_character.nome,
    'class_id',v_sheet.classe_id,'class_name',v_class.nome,
    'barbarian_level',v_barbarian_level,'character_level',v_level,
    'race_id',v_sheet.raca_id,'size',v_race.tamanho,
    'strength',v_strength,'dexterity',v_dexterity,
    'strength_modifier',floor((v_strength-10)::numeric/2)::integer,
    'dexterity_modifier',floor((v_dexterity-10)::numeric/2)::integer,
    'base_attack_bonus',v_bab,
    'attacks_total',case when v_bab>=6 then least(6,1+floor((v_bab-1)/5.0)::integer) else 1 end,
    'power_attack_available',v_has_power_attack,
    'attack_type',p_attack_type,'weapons',v_weapons,
    'full_round_action_already_used',coalesce(v_actor_actions->>'ataque_total','false')='true'
      or coalesce(v_actor_actions->>'padrao','false')='true'
      or coalesce(v_actor_actions->>'movimento','false')='true'
  );
end;
$function$
;

-- npc_consultar_ataque_iterativo_pendente_impl(p_campaign_id bigint, p_actor_token_id text)
CREATE OR REPLACE FUNCTION priv.npc_consultar_ataque_iterativo_pendente_impl(p_campaign_id bigint, p_actor_token_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
declare
 v_user uuid:=auth.uid();
 v_seq public.srd_npc_attack_sequences%rowtype;
 v_attempts jsonb;
begin
 if v_user is null or public.my_role(p_campaign_id) is distinct from 'GM' then
  raise exception 'Somente o Mestre autenticado pode consultar sequências de NPC.';
 end if;
 select * into v_seq from public.srd_npc_attack_sequences
 where campaign_id=p_campaign_id and actor_token_id=btrim(p_actor_token_id)
  and created_by=v_user and status='active'
 order by created_at desc limit 1;
 if not found then return jsonb_build_object('active',false); end if;
 select coalesce(jsonb_agg(jsonb_build_object(
  'id',a.id,'attempt_index',a.attempt_index,'manual_d20',a.manual_d20,
  'iterative_penalty',a.iterative_penalty,'status',a.status,
  'attack_total',a.attack_total,'target_ac',a.target_ac,
  'resolution_data',a.resolution_data,
  'critical_confirmation_d20',a.critical_confirmation_d20,
  'is_critical',a.is_critical,'damage_rolls',a.damage_rolls,
  'damage_applied',a.damage_applied
 ) order by a.attempt_index),'[]'::jsonb)
 into v_attempts from public.srd_npc_attack_attempts a where a.sequence_id=v_seq.id;
 return jsonb_build_object(
  'active',true,'sequence_id',v_seq.id,'campaign_id',v_seq.campaign_id,
  'actor_token_id',v_seq.actor_token_id,'actor_character_id',v_seq.actor_character_id,
  'target_token_id',v_seq.target_token_id,'attack_type',v_seq.attack_type,
  'weapon_instance_id',v_seq.weapon_instance_id,'weapon_hand_slot',v_seq.weapon_hand_slot,
  'weapon_end',v_seq.weapon_end,'base_attack_bonus',v_seq.base_attack_bonus,
  'attacks_total',v_seq.attacks_total,'next_attack_index',v_seq.next_attack_index,
  'round_number',v_seq.round_number,'turn_index',v_seq.turn_index,
  'power_attack_penalty',v_seq.power_attack_penalty,'attempts',v_attempts
 );
end;
$function$
;

-- npc_iniciar_ataque_iterativo_impl(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text)
CREATE OR REPLACE FUNCTION priv.npc_iniciar_ataque_iterativo_impl(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
 v_user uuid:=auth.uid();
 v_profile jsonb;
 v_weapon jsonb;
 v_campaign public.campaigns%rowtype;
 v_actor jsonb;
 v_target jsonb;
 v_target_count integer;
 v_actor_character_id bigint;
 v_sequence public.srd_npc_attack_sequences%rowtype;
 v_action jsonb;
begin
 if v_user is null or public.my_role(p_campaign_id) is distinct from 'GM' then
  raise exception 'Somente o Mestre autenticado pode iniciar Ataque Total de NPC.';
 end if;
 v_profile:=public.consultar_ataque_iterativo_npc_srd(p_campaign_id,p_actor_token_id,p_attack_type);
 if coalesce((v_profile->>'eligible')::boolean,false) is not true then
  raise exception 'NPC sem requisitos para Ataque Total: %.',coalesce(v_profile->>'reason','não elegível');
 end if;
 if coalesce((v_profile->>'full_round_action_already_used')::boolean,false) then
  raise exception 'A ação de rodada completa deste NPC já foi consumida.';
 end if;
 select e.value into v_weapon
 from jsonb_array_elements(coalesce(v_profile->'weapons','[]'::jsonb)) as e(value)
 where e.value->>'instance_id'=p_weapon_instance_id::text
 and e.value->>'hand_slot'=p_weapon_hand_slot
 limit 1;
 if v_weapon is null then raise exception 'A instância selecionada não está equipada nesta mão.'; end if;
 if p_attack_type='atk-corpo' and coalesce(v_weapon->'details'->>'weapon_melee','true')='false' then
  raise exception 'A arma selecionada não permite ataque corpo a corpo.';
 end if;
 if p_attack_type='atk-dist' and coalesce(v_weapon->'details'->>'weapon_ranged','false')<>'true' then
  raise exception 'A arma selecionada não permite ataque à distância.';
 end if;
 select c.* into v_campaign from public.campaigns c where c.id=p_campaign_id for update;
 if not found then raise exception 'Campanha não encontrada.'; end if;
 select count(*)::integer into v_target_count
 from jsonb_array_elements(case when jsonb_typeof(v_campaign.cba_data->'tokens')='array'
  then v_campaign.cba_data->'tokens' else '[]'::jsonb end) t(token)
 where t.token->>'id'=btrim(p_target_token_id);
 if v_target_count<>1 or p_target_token_id=p_actor_token_id then
  raise exception 'Alvo ausente, duplicado ou igual ao atacante.';
 end if;
 if not priv.srd_confusion_attack_target_allowed(p_campaign_id,'token',btrim(p_actor_token_id),btrim(p_target_token_id)) then
  raise exception 'A condição Confuso impede este alvo. Siga o resultado D100 do turno e o alvo obrigatório registrado.';
 end if;
 select (t.token) into v_actor
 from jsonb_array_elements(case when jsonb_typeof(v_campaign.cba_data->'tokens')='array' then v_campaign.cba_data->'tokens' else '[]'::jsonb end) t(token)
 where t.token->>'id'=btrim(p_actor_token_id) and t.token->>'tipo'='npc';
 if v_actor is null then raise exception 'Token atacante NPC inválido.'; end if;
 select (t.token) into v_target
 from jsonb_array_elements(case when jsonb_typeof(v_campaign.cba_data->'tokens')='array' then v_campaign.cba_data->'tokens' else '[]'::jsonb end) t(token)
 where t.token->>'id'=btrim(p_target_token_id);
 if coalesce(v_actor->>'gridX','') !~ '^-?[0-9]+$' or coalesce(v_actor->>'gridY','') !~ '^-?[0-9]+$'
  or coalesce(v_target->>'gridX','') !~ '^-?[0-9]+$' or coalesce(v_target->>'gridY','') !~ '^-?[0-9]+$' then
  raise exception 'Posição de token inválida para iniciar Ataque Total.';
 end if;
 v_actor_character_id:=(v_profile->>'character_id')::bigint;
 v_action:=public.consumir_acao_rodada_completa_srd(p_campaign_id,p_actor_token_id,'token');
 insert into public.srd_npc_attack_sequences(
  campaign_id,actor_token_id,actor_character_id,target_token_id,attack_type,
  weapon_instance_id,weapon_hand_slot,weapon_end,base_attack_bonus,attacks_total,
  round_number,turn_index,created_by
 ) values (
  p_campaign_id,p_actor_token_id,v_actor_character_id,p_target_token_id,p_attack_type,
  p_weapon_instance_id,p_weapon_hand_slot,p_weapon_end,
  (v_profile->>'base_attack_bonus')::integer,(v_profile->>'attacks_total')::smallint,
  greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,1)),
  (v_campaign.combat_data->>'current_turn')::integer,v_user
 ) returning * into v_sequence;
 return jsonb_build_object('sequence_id',v_sequence.id,'status',v_sequence.status,
  'actor_token_id',v_sequence.actor_token_id,'target_token_id',v_sequence.target_token_id,
  'attacks_total',v_sequence.attacks_total,'next_attack_index',v_sequence.next_attack_index,
  'weapon',v_weapon,'action_economy',v_action->'action_economy');
end;
$function$
;

-- npc_iniciar_ataque_iterativo_impl(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text, p_power_attack_penalty integer)
CREATE OR REPLACE FUNCTION priv.npc_iniciar_ataque_iterativo_impl(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text, p_power_attack_penalty integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
 v_user uuid:=auth.uid();
 v_profile jsonb;
 v_weapon jsonb;
 v_campaign public.campaigns%rowtype;
 v_actor jsonb;
 v_target jsonb;
 v_target_count integer;
 v_actor_character_id bigint;
 v_sequence public.srd_npc_attack_sequences%rowtype;
 v_action jsonb;
 v_power_attack_penalty integer:=coalesce(p_power_attack_penalty,0);
begin
 if v_user is null or public.my_role(p_campaign_id) is distinct from 'GM' then
  raise exception 'Somente o Mestre autenticado pode iniciar Ataque Total de NPC.';
 end if;
 v_profile:=public.consultar_ataque_iterativo_npc_srd(p_campaign_id,p_actor_token_id,p_attack_type);
 if coalesce((v_profile->>'eligible')::boolean,false) is not true then
  raise exception 'NPC sem requisitos para Ataque Total: %.',coalesce(v_profile->>'reason','não elegível');
 end if;
 if coalesce((v_profile->>'full_round_action_already_used')::boolean,false) then
  raise exception 'A ação de rodada completa deste NPC já foi consumida.';
 end if;
 select e.value into v_weapon
 from jsonb_array_elements(coalesce(v_profile->'weapons','[]'::jsonb)) as e(value)
 where e.value->>'instance_id'=p_weapon_instance_id::text
 and e.value->>'hand_slot'=p_weapon_hand_slot
 limit 1;
 if v_weapon is null then raise exception 'A instância selecionada não está equipada nesta mão.'; end if;
 if v_power_attack_penalty<0 OR v_power_attack_penalty>coalesce((v_profile->>'base_attack_bonus')::integer,0) then
  raise exception 'Penalidade de Ataque Poderoso deve ficar entre 0 e o BBA atual.';
 end if;
 if v_power_attack_penalty>0 then
  if p_attack_type<>'atk-corpo' then raise exception 'Ataque Poderoso só pode ser usado em ataques corpo a corpo.'; end if;
  if coalesce((v_profile->>'power_attack_available')::boolean,false) is not true
     or coalesce((v_profile->>'strength')::integer,0)<13 then
   raise exception 'Ataque Poderoso exige o talento e Força 13.';
  end if;
  if coalesce((v_weapon->'details'->>'weapon_light')::boolean,false) then
   raise exception 'Ataque Poderoso não pode ser usado com arma leve.';
  end if;
 end if;
 if p_attack_type='atk-corpo' and coalesce(v_weapon->'details'->>'weapon_melee','true')='false' then
  raise exception 'A arma selecionada não permite ataque corpo a corpo.';
 end if;
 if p_attack_type='atk-dist' and coalesce(v_weapon->'details'->>'weapon_ranged','false')<>'true' then
  raise exception 'A arma selecionada não permite ataque à distância.';
 end if;
 select c.* into v_campaign from public.campaigns c where c.id=p_campaign_id for update;
 if not found then raise exception 'Campanha não encontrada.'; end if;
 select count(*)::integer into v_target_count
 from jsonb_array_elements(case when jsonb_typeof(v_campaign.cba_data->'tokens')='array'
  then v_campaign.cba_data->'tokens' else '[]'::jsonb end) t(token)
 where t.token->>'id'=btrim(p_target_token_id);
 if v_target_count<>1 or p_target_token_id=p_actor_token_id then
  raise exception 'Alvo ausente, duplicado ou igual ao atacante.';
 end if;
 if not priv.srd_confusion_attack_target_allowed(p_campaign_id,'token',btrim(p_actor_token_id),btrim(p_target_token_id)) then
  raise exception 'A condição Confuso impede este alvo. Siga o resultado D100 do turno e o alvo obrigatório registrado.';
 end if;
 select (t.token) into v_actor
 from jsonb_array_elements(case when jsonb_typeof(v_campaign.cba_data->'tokens')='array' then v_campaign.cba_data->'tokens' else '[]'::jsonb end) t(token)
 where t.token->>'id'=btrim(p_actor_token_id) and t.token->>'tipo'='npc';
 if v_actor is null then raise exception 'Token atacante NPC inválido.'; end if;
 select (t.token) into v_target
 from jsonb_array_elements(case when jsonb_typeof(v_campaign.cba_data->'tokens')='array' then v_campaign.cba_data->'tokens' else '[]'::jsonb end) t(token)
 where t.token->>'id'=btrim(p_target_token_id);
 if coalesce(v_actor->>'gridX','') !~ '^-?[0-9]+$' or coalesce(v_actor->>'gridY','') !~ '^-?[0-9]+$'
  or coalesce(v_target->>'gridX','') !~ '^-?[0-9]+$' or coalesce(v_target->>'gridY','') !~ '^-?[0-9]+$' then
  raise exception 'Posição de token inválida para iniciar Ataque Total.';
 end if;
 v_actor_character_id:=(v_profile->>'character_id')::bigint;
 v_action:=public.consumir_acao_rodada_completa_srd(p_campaign_id,p_actor_token_id,'token');
 insert into public.srd_npc_attack_sequences(
  campaign_id,actor_token_id,actor_character_id,target_token_id,attack_type,
  weapon_instance_id,weapon_hand_slot,weapon_end,power_attack_penalty,base_attack_bonus,attacks_total,
  round_number,turn_index,created_by
 ) values (
  p_campaign_id,p_actor_token_id,v_actor_character_id,p_target_token_id,p_attack_type,
  p_weapon_instance_id,p_weapon_hand_slot,p_weapon_end,v_power_attack_penalty,
  (v_profile->>'base_attack_bonus')::integer,(v_profile->>'attacks_total')::smallint,
  greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,1)),
  (v_campaign.combat_data->>'current_turn')::integer,v_user
 ) returning * into v_sequence;
 return jsonb_build_object('sequence_id',v_sequence.id,'status',v_sequence.status,
  'actor_token_id',v_sequence.actor_token_id,'target_token_id',v_sequence.target_token_id,
  'attacks_total',v_sequence.attacks_total,'next_attack_index',v_sequence.next_attack_index,
  'weapon',v_weapon,'action_economy',v_action->'action_economy');
end;
$function$
;

-- npc_registrar_rolagem_ataque_iterativo_impl(p_campaign_id bigint, p_sequence_id uuid, p_manual_d20 integer, p_idempotency_key uuid)
CREATE OR REPLACE FUNCTION priv.npc_registrar_rolagem_ataque_iterativo_impl(p_campaign_id bigint, p_sequence_id uuid, p_manual_d20 integer, p_idempotency_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
declare
 v_user uuid:=auth.uid();
 v_seq public.srd_npc_attack_sequences%rowtype;
 v_attempt public.srd_npc_attack_attempts%rowtype;
 v_campaign public.campaigns%rowtype;
 v_index smallint;
begin
 if v_user is null or public.my_role(p_campaign_id) is distinct from 'GM' then
  raise exception 'Somente o Mestre autenticado pode registrar rolagens de NPC.';
 end if;
 if p_manual_d20 is null or p_manual_d20<1 or p_manual_d20>20 or p_idempotency_key is null then
  raise exception 'D20 manual ou chave idempotente inválida.';
 end if;
 select * into v_seq from public.srd_npc_attack_sequences
 where id=p_sequence_id and campaign_id=p_campaign_id and created_by=v_user
 for update;
 if not found or v_seq.status<>'active' then raise exception 'Sequência NPC não encontrada ou encerrada.'; end if;
 select * into v_campaign from public.campaigns where id=p_campaign_id for update;
 if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
  or lower(coalesce(v_campaign.combat_data->>'active','false'))<>'true'
  or (v_campaign.combat_data->>'current_turn')::integer<>v_seq.turn_index
  or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,1))<>v_seq.round_number then
  raise exception 'A rodada ou o turno mudou; sequência NPC invalidada.';
 end if;
 if exists(select 1 from public.srd_npc_attack_attempts a where a.sequence_id=v_seq.id
  and a.status in ('pending_resolution','critical_confirmation_pending','hit_pending_damage')) then
  raise exception 'Resolva a tentativa anterior antes de registrar outro d20.';
 end if;
 select * into v_attempt from public.srd_npc_attack_attempts
 where sequence_id=v_seq.id and idempotency_key=p_idempotency_key;
 if found then
  return jsonb_build_object('attempt_id',v_attempt.id,'status',v_attempt.status,'replayed',true);
 end if;
 v_index:=v_seq.next_attack_index;
 if v_index>v_seq.attacks_total then raise exception 'Todos os ataques da sequência já foram registrados.'; end if;
 insert into public.srd_npc_attack_attempts(sequence_id,attempt_index,manual_d20,iterative_penalty,idempotency_key)
 values(v_seq.id,v_index,p_manual_d20,((v_index-1)*5)::smallint,p_idempotency_key)
 returning * into v_attempt;
 update public.srd_npc_attack_sequences set next_attack_index=v_index+1 where id=v_seq.id;
 return jsonb_build_object('attempt_id',v_attempt.id,'sequence_id',v_seq.id,
  'attempt_index',v_index,'manual_d20',p_manual_d20,'iterative_penalty',v_attempt.iterative_penalty,'status',v_attempt.status);
end;
$function$
;

-- npc_resolver_ataque_iterativo_impl(p_campaign_id bigint, p_attempt_id uuid)
CREATE OR REPLACE FUNCTION priv.npc_resolver_ataque_iterativo_impl(p_campaign_id bigint, p_attempt_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_user uuid := auth.uid();
  v_campaign public.campaigns%rowtype;
  v_seq public.srd_npc_attack_sequences%rowtype;
  v_attempt public.srd_npc_attack_attempts%rowtype;
  v_sheet public.srd_character_sheets%rowtype;
  v_class public.srd_classes%rowtype;
  v_race public.srd_races%rowtype;
  v_weapon public.srd_equipment%rowtype;
  v_instance public.srd_character_weapon_instances%rowtype;
  v_scene jsonb;
  v_tokens jsonb;
  v_actor jsonb;
  v_target jsonb;
  v_ca_text text;
  v_ca integer;
  v_turn integer;
  v_round integer;
  v_target_count integer;
  v_actor_count integer;
  v_target_ord bigint;
  v_actor_ord bigint;
  v_bab integer;
  v_level integer;
  v_score integer;
  v_ability_mod integer;
  v_size_mod integer := 0;
  v_focus integer := 0;
  v_proficiency_penalty integer := 0;
  v_racial_bonus integer := 0;
  v_range_penalty integer := 0;
  v_effect_attack integer := 0;
  v_effect_ac integer := 0;
  v_rogue_level integer := 0;
  v_sneak_dice integer := 0;
  v_target_denies_dex boolean := false;
  v_actor_is_giant boolean := false;
  v_target_race text;
  v_target_loses_dex boolean := false;
  v_expected integer;
  v_total integer;
  v_attack_key text;
  v_weapon_name text;
  v_weapon_prof text;
  v_class_profs jsonb;
  v_proficient boolean := false;
  v_has_finesse boolean := false;
  v_target_traits text;
  v_target_type text;
  v_critical_immune boolean := false;
  v_critical_immunity_text text;
  v_critical_special_text text;
  v_ax integer; v_ay integer; v_bx integer; v_by integer;
  v_dx integer; v_dy integer; v_dist integer;
  v_attacker_size integer := 1;
  v_target_size integer := 1;
  v_range_increment numeric;
  v_range_increments integer;
  v_max_range integer;
  v_crit_text text;
  v_crit_min integer := 20;
  v_crit_mult integer := 2;
  v_is_threat boolean := false;
  v_status text;
  v_end_meta jsonb;
  v_player_ac jsonb;
begin
  if v_user is null then raise exception 'É necessário estar autenticado.'; end if;
  if public.my_role(p_campaign_id) is distinct from 'GM' then raise exception 'Somente o Mestre pode resolver ataques de NPC.'; end if;

  select * into v_campaign from public.campaigns
  where id = p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,'')) <> 'COMBATE' then
    raise exception 'A campanha não está em combate.';
  end if;

  select * into v_seq from public.srd_npc_attack_sequences
  where id = p_attempt_id and campaign_id = p_campaign_id;
  -- p_attempt_id is the attempt id; sequence is resolved below.
  select a.* into v_attempt from public.srd_npc_attack_attempts a
  where a.id = p_attempt_id for update;
  if not found then raise exception 'Tentativa de ataque não encontrada.'; end if;

  select s.* into v_seq from public.srd_npc_attack_sequences s
  where s.id = v_attempt.sequence_id and s.campaign_id = p_campaign_id
  for update;
  if not found then raise exception 'Sequência de ataque não encontrada.'; end if;

  if v_seq.created_by <> v_user then
    raise exception 'Somente quem iniciou a sequência pode resolver o ataque.';
  end if;
  if v_attempt.status <> 'pending_resolution' then
    return jsonb_build_object('attempt_id',v_attempt.id,'sequence_id',v_seq.id,
      'status',v_attempt.status,'resolution_data',v_attempt.resolution_data,'replayed',true);
  end if;
  if v_seq.status <> 'active' then raise exception 'A sequência não está ativa.'; end if;

  if public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode resolver ataques de NPC.';
  end if;
  if v_seq.created_by<>v_user then raise exception 'Somente o Mestre que iniciou a sequência pode resolvê-la.'; end if;

  v_scene := coalesce(v_campaign.cba_data,'{}'::jsonb);
  v_tokens := case when jsonb_typeof(v_scene->'tokens')='array' then v_scene->'tokens' else '[]'::jsonb end;
  v_target_count := 0; v_actor_count := 0;
  select count(*)::integer,min(t.ordinality) into v_target_count,v_target_ord
  from jsonb_array_elements(v_tokens) with ordinality t(token,ordinality)
  where t.token->>'id'=v_seq.target_token_id and t.token->>'tipo' in ('player','npc','monstro');
  if v_target_count <> 1 then raise exception 'Alvo ausente ou duplicado na cena.'; end if;
  select count(*)::integer,min(t.ordinality) into v_actor_count,v_actor_ord
  from jsonb_array_elements(v_tokens) with ordinality t(token,ordinality)
  where t.token->>'id'=v_seq.actor_token_id and t.token->>'tipo'='npc';
  if v_actor_count <> 1 then raise exception 'Token do personagem ausente ou duplicado.'; end if;
  v_target := v_tokens->(v_target_ord::integer-1);
  v_actor := v_tokens->(v_actor_ord::integer-1);
  v_actor_is_giant:=lower(concat_ws(' ',v_actor->>'creature_type',v_actor->'monsterStats'->>'type',v_actor->'monsterStats'->>'tipo',v_actor->'monsterStats'->>'creature_type',v_actor->'monsterStats'->>'subtype',v_actor->'monsterStats'->>'subtypes')) ~ '(giant|gigante)';

  v_turn := case when coalesce(v_campaign.combat_data->>'current_turn','') ~ '^[0-9]+$'
    then (v_campaign.combat_data->>'current_turn')::integer else -1 end;
  v_round := case when coalesce(v_campaign.combat_data->>'round','') ~ '^[0-9]+$'
    then greatest(1,(v_campaign.combat_data->>'round')::integer) else -1 end;
  if lower(coalesce(v_campaign.combat_data->>'active','false')) <> 'true'
     or v_turn <> v_seq.turn_index or v_round <> v_seq.round_number then
    raise exception 'A iniciativa, turno ou rodada mudou; ataque invalidado.';
  end if;
  if not exists (
    select 1 from jsonb_array_elements(coalesce(v_campaign.combat_data->'turn_order','[]'::jsonb)) e
    where e->>'id'=v_seq.actor_token_id and coalesce(e->>'is_monster','false')='true'
      and (select ordinality-1 from jsonb_array_elements(coalesce(v_campaign.combat_data->'turn_order','[]'::jsonb)) with ordinality x(e,ordinality) where x.e->>'id'=v_seq.actor_token_id limit 1)=v_turn
  ) then raise exception 'O personagem não é o ator do turno atual.'; end if;

  select sh.* into v_sheet from public.srd_character_sheets sh
  where sh.character_id=v_seq.actor_character_id;
  if not found then raise exception 'Ficha SRD não encontrada.'; end if;
  select cl.* into v_class from public.srd_classes cl where cl.id=v_sheet.classe_id;
  select r.* into v_race from public.srd_races r where r.id=v_sheet.raca_id;
  if v_class.id is null or v_race.id is null then raise exception 'Classe ou raça não encontrada.'; end if;

  select wi.* into v_instance from public.srd_character_weapon_instances wi
  where wi.instance_id=v_seq.weapon_instance_id
    and wi.character_id=v_seq.actor_character_id::text
    and wi.equipado is true and wi.hand_slot=v_seq.weapon_hand_slot
  for share;
  if not found then raise exception 'A instância de arma não está mais equipada na mão vinculada.'; end if;
  if not exists (
    select 1 from public.srd_character_equipment ce
    where ce.character_id=v_seq.actor_character_id::text
      and ce.equipment_id=v_instance.equipment_id and ce.equipado is true
      and ce.hand_slot=v_seq.weapon_hand_slot
  ) then raise exception 'O equipamento não corresponde à instância equipada.'; end if;
  select eq.* into v_weapon from public.srd_equipment eq where eq.id=v_instance.equipment_id;
  if not found then raise exception 'Arma do ataque não encontrada no catálogo.'; end if;

  v_end_meta := case when v_seq.weapon_end='off' then coalesce(v_weapon.detalhes->'weapon_end_off','{}'::jsonb)
    when v_seq.weapon_end='main' then coalesce(v_weapon.detalhes->'weapon_end_main','{}'::jsonb)
    else '{}'::jsonb end;
  if coalesce((v_weapon.detalhes->>'weapon_double')::boolean,false) and v_seq.weapon_end is null then
    raise exception 'A extremidade da arma dupla não foi vinculada.';
  end if;

  v_level := greatest(1,coalesce(v_sheet.nivel,1));
  select coalesce(sum(case lower(coalesce(clas.bab_progression,''))
    when 'good' then lv.class_level when 'bom' then lv.class_level
    when 'average' then floor(3*lv.class_level/4.0)::integer
    when 'medium' then floor(3*lv.class_level/4.0)::integer
    when 'medio' then floor(3*lv.class_level/4.0)::integer
    when 'poor' then floor(lv.class_level/2.0)::integer
    when 'ruim' then floor(lv.class_level/2.0)::integer else 0 end),0)::integer
  into v_bab
  from public.srd_character_class_levels lv
  join public.srd_classes clas on clas.id=lv.class_id
  where lv.character_id=v_seq.actor_character_id;
  if not exists(select 1 from public.srd_character_class_levels lv
      where lv.character_id=v_seq.actor_character_id) then
    v_bab := case lower(coalesce(v_class.bab_progression,''))
      when 'good' then v_level when 'bom' then v_level
      when 'average' then floor(3*v_level/4.0)::integer
      when 'medium' then floor(3*v_level/4.0)::integer
      when 'medio' then floor(3*v_level/4.0)::integer
      when 'poor' then floor(v_level/2.0)::integer
      when 'ruim' then floor(v_level/2.0)::integer else 0 end;
  end if;
  if v_bab <> v_seq.base_attack_bonus then
    raise exception 'O BBA da ficha mudou desde o início da sequência.';
  end if;

  v_weapon_name := coalesce(v_weapon.detalhes->>'weapon_proficiency_name',v_weapon.nome,'Ataque desarmado');
  v_weapon_prof := priv.srd_weapon_proficiency(v_weapon.detalhes,v_weapon_name);
  v_class_profs := coalesce(v_class.dados_tecnicos->'proficiencias'->'armas','[]'::jsonb);
  v_proficient := exists (
    select 1 from jsonb_array_elements_text(case when jsonb_typeof(v_class_profs)='array' then v_class_profs else '[]'::jsonb end) p
    where lower(btrim(p.value))='todas as armas simples e marciais' AND v_weapon_prof IN ('simple','martial')
      or public.srd35_normalizar_parametro_talento(p.value)=public.srd35_normalizar_parametro_talento(v_weapon_name)
      or (lower(btrim(p.value))='armas simples' and v_weapon_prof='simple')
  );
  if not v_proficient and v_weapon_prof='exotic' and v_sheet.raca_id='anao'
     and coalesce(v_weapon.detalhes->'weapon_familiarity_race_ids','[]'::jsonb) ? 'anao' then
    v_proficient := exists (
      select 1 from jsonb_array_elements_text(case when jsonb_typeof(v_class_profs)='array' then v_class_profs else '[]'::jsonb end) p
      where lower(btrim(p.value))='todas as armas simples e marciais'
    ) or exists (
      select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
      where f->>'id'='srd35_feat_martial_weapon_proficiency'
        and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name)
    );
  end if;
  if not v_proficient then
    v_proficient := exists (
      select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
      where (f->>'id'='srd35_feat_simple_weapon_proficiency' and v_weapon_prof='simple')
        or (f->>'id' in ('srd35_feat_martial_weapon_proficiency','srd35_feat_exotic_weapon_proficiency')
          and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name))
    );
  end if;
  if not v_proficient then v_proficiency_penalty := 4; end if;

  v_has_finesse := exists (
    select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
    where f->>'id'='srd35_feat_weapon_finesse'
  );
  if v_seq.attack_type='atk-dist' then
    if coalesce(v_weapon.detalhes->>'weapon_ranged','false')<>'true' then
      raise exception 'A arma vinculada não permite ataque à distância.';
    end if;
    v_attack_key := 'DES';
    v_score := coalesce(nullif(v_sheet.atributos->>'DES','')::integer,10);
  else
    if coalesce(v_weapon.detalhes->>'weapon_melee','true')='false' then
      raise exception 'A arma vinculada não permite ataque corpo a corpo.';
    end if;
    if v_has_finesse and coalesce(v_weapon.detalhes->>'weapon_finesse_eligible','false')='true' then
      v_attack_key := 'DES'; v_score := coalesce(nullif(v_sheet.atributos->>'DES','')::integer,10);
    else
      v_attack_key := 'FOR'; v_score := coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10);
    end if;
  end if;
  v_ability_mod := floor((v_score-10)::numeric/2)::integer;
  if lower(coalesce(v_race.tamanho,'')) in ('pequeno','small') then v_size_mod := 1;
  elsif lower(coalesce(v_race.tamanho,'')) in ('grande','large') then v_size_mod := -1; end if;

  v_focus := (case when exists (
    select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
    where f->>'id'='foco_em_arma' and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name)
  ) then 1 else 0 end) + (case when exists (
    select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
    where f->>'id'='srd35_feat_greater_weapon_focus' and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name)
  ) then 1 else 0 end);

  v_target_race:=lower(coalesce(nullif(v_target->>'raca_id',''),nullif(v_target->>'race_id',''),nullif(v_target->'monsterStats'->>'race_id','')));
  IF v_target->>'tipo'='player' THEN
    SELECT lower(sh.raca_id::text) INTO v_target_race
      FROM public.srd_character_sheets sh
      WHERE sh.character_id::text=v_seq.target_token_id;
  ELSIF v_target->>'tipo'='npc' AND NULLIF(v_target->>'sourceCharacterId','') IS NOT NULL THEN
    SELECT lower(sh.raca_id::text) INTO v_target_race
      FROM public.srd_character_sheets sh
      WHERE sh.character_id::text=v_target->>'sourceCharacterId';
  END IF;
  v_target_traits := lower(concat_ws(' ',v_target->>'nome',v_target->>'detalhe',
    v_target->'monsterStats'->>'tipo',v_target->'monsterStats'->>'subtipo',
    v_target->'monsterStats'->>'type',v_target->'monsterStats'->>'creature_type',
    v_target_race));
  if v_sheet.raca_id='anao' and v_target_traits ~ '(^|[^a-z])(orc|goblin|hobgoblin|bugbear|goblinoid(e)?)([^a-z]|$)' then v_racial_bonus := 1; end if;

  if coalesce(v_actor->>'gridX','') !~ '^-?[0-9]+$' or coalesce(v_actor->>'gridY','') !~ '^-?[0-9]+$'
    or coalesce(v_target->>'gridX','') !~ '^-?[0-9]+$' or coalesce(v_target->>'gridY','') !~ '^-?[0-9]+$' then
    raise exception 'Posição de token inválida para validar alcance.';
  end if;
  v_ax := (v_actor->>'gridX')::integer; v_ay := (v_actor->>'gridY')::integer;
  v_bx := (v_target->>'gridX')::integer; v_by := (v_target->>'gridY')::integer;
  v_dx := abs(v_bx-v_ax); v_dy := abs(v_by-v_ay);
  v_dist := greatest(v_dx,v_dy)+floor(least(v_dx,v_dy)::numeric/2)::integer;
  if v_seq.attack_type='atk-corpo' then
    if v_dist > 1 then raise exception 'Alvo fora do alcance corpo a corpo.'; end if;
  else
    v_range_increment := nullif(v_weapon.detalhes->>'range_increment_m','')::numeric;
    if v_range_increment is null then
      v_range_increment := nullif(regexp_replace(coalesce(v_weapon.detalhes->>'range_increment',''),'[^0-9.]','','g'),'')::numeric;
    end if;
    if v_range_increment is null or v_range_increment<=0 then raise exception 'Incremento de distância não cadastrado para a arma.'; end if;
    v_range_increments := greatest(1,ceil((v_dist*1.5)/v_range_increment)::integer);
    v_max_range := coalesce(nullif(v_weapon.detalhes->>'max_range_increments','')::integer,10);
    if v_range_increments>v_max_range then raise exception 'Alvo fora do alcance máximo da arma.'; end if;
    v_range_penalty := (v_range_increments-1)*2;
  end if;
  v_target_type:=lower(coalesce(nullif(v_target->'monsterStats'->>'creature_type',''),nullif(v_target->'monsterStats'->>'type',''),nullif(v_target->'monsterStats'->>'tipo',''),nullif(v_target->>'creature_type',''),nullif(v_target->>'tipo_criatura',''),nullif(v_target->>'tipo',''),''));
  v_critical_immunity_text:=translate(lower(concat_ws(' ',v_target_type,v_target->'monsterStats'->>'subtipo',v_target->'monsterStats'->>'subtype',v_target->'monsterStats'->>'subtypes')),'áàâãäéèêëíìîïóòôõöúùûüç','aaaaaeeeeiiiiooooouuuuc');
  v_critical_special_text:=translate(lower(concat_ws(' ',v_target->'monsterStats'->>'qualidades_especiais',v_target->'monsterStats'->>'special_qualities',v_target->'monsterStats'->>'specialQualities',v_target->'monsterStats'->>'immunities',v_target->'monsterStats'->>'imunidades',v_target->>'qualidades_especiais',v_target->>'special_qualities',v_target->>'immunities',v_target->>'imunidades')),'áàâãäéèêëíìîïóòôõöúùûüç','aaaaaeeeeiiiiooooouuuuc');
  v_critical_immune:=v_target_type in ('undead','morto-vivo','construct','construto','ooze','gosma','plant','planta','elemental','incorporeal','incorporeo') or v_critical_immunity_text ~ '(^|[^a-z])(undead|morto.vivo|construct|construto|ooze|gosma|plant|planta|elemental|incorporeal|incorporeo)([^a-z]|$)' or v_target->>'imune_critico'='true' or v_target->>'critical_immune'='true' or v_target->'monsterStats'->>'imune_critico'='true' or v_target->'monsterStats'->>'critical_immune'='true' or v_target->>'incorporeal'='true' or v_target->'monsterStats'->>'incorporeal'='true' or v_critical_special_text ~ '(immune to critical hits|immunity to critical hits|critical hit immunity|imune a acertos criticos|imunidade a acertos criticos|imune a criticos|imunidade a criticos)';
  v_target_denies_dex:=exists(select 1 from public.srd_campaign_conditions cc
    where cc.campaign_id=p_campaign_id and cc.target_kind='token'
      and cc.target_id in (v_seq.target_token_id,coalesce(v_target->>'key',v_seq.target_token_id))
      and cc.active is true and cc.condition_id in
        ('blinded','cowering','flatfooted','helpless','paralyzed','pinned','stunned','unconscious','dying','stable','dead'));
  select coalesce(max(lv.class_level),0) into v_rogue_level
    from public.srd_character_class_levels lv join public.srd_classes cls on cls.id=lv.class_id
    where lv.character_id=v_seq.actor_character_id and cls.class_key='rogue';
  if v_rogue_level=0 and not exists(select 1 from public.srd_character_class_levels lv
      where lv.character_id=v_seq.actor_character_id) and v_sheet.classe_id='ladino' then
    v_rogue_level:=greatest(1,coalesce(v_sheet.nivel,1));
  end if;
  if v_target_denies_dex and not v_critical_immune then
    v_sneak_dice:=least(10,floor((v_rogue_level+1)/2.0)::integer);
    if v_seq.attack_type='atk-dist' and v_dist>6 then v_sneak_dice:=0; end if;
  end if;

  v_effect_attack := priv.srd_effective_modifier(p_campaign_id,'token',v_seq.actor_token_id,'attack')
    + case when v_seq.attack_type='atk-corpo'
      then priv.srd_effective_modifier(p_campaign_id,'token',v_seq.actor_token_id,'attack_melee')
        + floor((coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)
          + priv.srd_effective_modifier(p_campaign_id,'token',v_seq.actor_token_id,'strength')-10)::numeric/2)::integer
        - floor((coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10)-10)::numeric/2)::integer
      else priv.srd_effective_modifier(p_campaign_id,'token',v_seq.actor_token_id,'attack_ranged')
        + floor((coalesce(nullif(v_sheet.atributos->>'DES','')::integer,10)
          + priv.srd_effective_modifier(p_campaign_id,'token',v_seq.actor_token_id,'dexterity')-10)::numeric/2)::integer
        - floor((coalesce(nullif(v_sheet.atributos->>'DES','')::integer,10)-10)::numeric/2)::integer end;
  v_effect_ac := priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac')
    + case when v_seq.attack_type='atk-corpo'
      then priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac_melee')
      else priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac_ranged') end;

  if v_target->>'tipo'='player' then
    v_player_ac:=public.srd_calcular_ca_personagem_srd(p_campaign_id,v_seq.target_token_id,'normal',v_actor_is_giant);
    v_ca:=nullif(v_player_ac->>'final_ac','')::integer;
    if v_ca is null then raise exception 'Não foi possível calcular a CA do personagem alvo.'; end if;
  elsif v_target->>'tipo'='npc' AND NULLIF(v_target->>'sourceCharacterId','') IS NOT NULL then
    v_player_ac:=priv.srd_calcular_ca_alvo_campanha_srd(
      p_campaign_id,v_target->>'sourceCharacterId','normal'
    );
    v_ca:=nullif(v_player_ac->>'final_ac','')::integer;
    if v_ca is null then raise exception 'Não foi possível calcular a CA atual da ficha SRD vinculada ao NPC alvo.'; end if;
    v_ca:=v_ca+case when v_seq.attack_type='atk-corpo'
      then priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac_melee')
      else priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac_ranged') end;
    if v_actor_is_giant then
      SELECT sh.raca_id::text INTO v_target_race
      FROM public.srd_character_sheets sh
      WHERE sh.character_id::text=v_target->>'sourceCharacterId';
      IF v_target_race IN ('anao','gnomo')
         AND NOT COALESCE((v_player_ac->>'dexterity_lost')::boolean,false) THEN
        v_ca:=v_ca+4;
      END IF;
    end if;
  else
    v_ca_text:=coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca');
    if coalesce(v_ca_text,'') !~ '^[0-9]{1,3}$' then raise exception 'O alvo não possui CA numérica válida.'; end if;
    v_ca:=v_ca_text::integer+v_effect_ac;
  end if;
  IF v_target->>'tipo'<>'player'
     AND NOT (v_target->>'tipo'='npc' AND NULLIF(v_target->>'sourceCharacterId','') IS NOT NULL)
     AND v_actor_is_giant THEN
    SELECT sh.raca_id::text INTO v_target_race
    FROM public.srd_character_sheets sh
    WHERE sh.character_id::text=COALESCE(NULLIF(v_target->>'sourceCharacterId',''),v_seq.target_token_id)
    LIMIT 1;
    v_target_race:=COALESCE(v_target_race,NULLIF(v_target->>'raca_id',''),v_target->'monsterStats'->>'race_id');
    v_target_loses_dex:=priv.srd_condition_has_flag(p_campaign_id,'token',v_seq.target_token_id,'loses_dex_ac')
      OR COALESCE(v_target->>'flat_footed','false')='true'
      OR COALESCE(v_target->'monsterStats'->>'loses_dex_ac','false')='true';
    IF v_target_race IN ('anao','gnomo') AND NOT v_target_loses_dex THEN
      v_ca:=v_ca+4;
    END IF;
  END IF;
  v_expected := v_bab + v_ability_mod + v_size_mod + v_focus + v_racial_bonus
    - v_proficiency_penalty - v_range_penalty - v_attempt.iterative_penalty - v_seq.power_attack_penalty;
  v_total := v_attempt.manual_d20 + v_expected + v_effect_attack;

  v_crit_text := coalesce(v_end_meta->>'critical',v_weapon.detalhes->>'critical',v_weapon.critico,'x2');
  if v_crit_text ~ '^[0-9]{2}(-[0-9]{2})?/x[0-9]+$' then
    v_crit_min := split_part(v_crit_text,'-',1)::integer;
    if v_crit_min < 2 or v_crit_min > 20 then raise exception 'Faixa crítica cadastrada é inválida.'; end if;
  else
    v_crit_min := 20;
  end if;
  if v_attempt.manual_d20=20 or (v_attempt.manual_d20<>1 and v_total>=v_ca) then
    v_is_threat := v_attempt.manual_d20>=v_crit_min and not v_critical_immune;
    v_status := case when v_is_threat then 'critical_confirmation_pending' else 'hit_pending_damage' end;
  else
    v_status := 'miss';
  end if;

  update public.srd_npc_attack_attempts
  set status=v_status, attack_total=v_total, target_ac=v_ca, is_critical=false,
      resolved_at=now(),
      resolution_data=jsonb_build_object(
        'attack_bonus_base',v_bab,'ability',v_attack_key,'ability_modifier',v_ability_mod,
        'size_modifier',v_size_mod,'weapon_focus',v_focus,'racial_bonus',v_racial_bonus,
        'proficiency_penalty',v_proficiency_penalty,'range_penalty',v_range_penalty,
        'iterative_penalty',v_attempt.iterative_penalty,'power_attack_penalty',v_seq.power_attack_penalty,'effect_attack_modifier',v_effect_attack,
        'attack_total',v_total,'target_ac',v_ca,'manual_d20',v_attempt.manual_d20,
        'critical_threat_minimum',v_crit_min,'critical_multiplier',coalesce(nullif(regexp_replace(v_crit_text,'^.*x',''),'')::integer,2),
        'critical_threat',v_is_threat,'critical_immune',v_critical_immune,'weapon_instance_id',v_seq.weapon_instance_id,
        'weapon_hand_slot',v_seq.weapon_hand_slot,'weapon_end',v_seq.weapon_end,'sneak_attack_dice',v_sneak_dice,'sneak_attack_eligible',(v_sneak_dice>0)
      )
  where id=v_attempt.id returning * into v_attempt;

  if v_status='miss' and v_attempt.attempt_index=v_seq.attacks_total then
    update public.srd_npc_attack_sequences set status='completed',completed_at=now() where id=v_seq.id;
  end if;

  return jsonb_build_object('attempt_id',v_attempt.id,'sequence_id',v_seq.id,
    'attempt_index',v_attempt.attempt_index,'status',v_status,'attack_total',v_total,
    'target_ac',v_ca,'critical_threat',v_is_threat,'resolution_data',v_attempt.resolution_data,
    'replayed',false);
end;
$function$
;

-- pasta_gm(p_name text)
CREATE OR REPLACE FUNCTION priv.pasta_gm(p_name text)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
  select case when (storage.foldername(p_name))[1] ~ '^[0-9]+$' then public.my_role(((storage.foldername(p_name))[1])::bigint) = 'GM' else false end $function$
;

-- pericias_completas(p jsonb)
CREATE OR REPLACE FUNCTION priv.pericias_completas(p jsonb)
 RETURNS jsonb
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
  select coalesce(jsonb_object_agg(s.nome, coalesce((p->>s.nome)::int, 0)), '{}'::jsonb)
  from public.skills s
$function$
;

-- preparar_exclusao_campanha_propria(p_campaign_id bigint)
CREATE OR REPLACE FUNCTION priv.preparar_exclusao_campanha_propria(p_campaign_id bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_owner uuid;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT c.owner_id INTO v_owner
  FROM public.campaigns c
  WHERE c.id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  IF v_owner IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'Somente o proprietário pode excluir esta campanha.';
  END IF;
  INSERT INTO priv.campaign_deletion_cleanup(campaign_id, owner_id, requested_at)
  VALUES (p_campaign_id, auth.uid(), now())
  ON CONFLICT (campaign_id) DO UPDATE
    SET owner_id = EXCLUDED.owner_id, requested_at = EXCLUDED.requested_at;
  RETURN jsonb_build_object('ok', true, 'campaign_id', p_campaign_id, 'deletion_pending', true);
END;
$function$
;

-- roll_dice_expr(p_expr text)
CREATE OR REPLACE FUNCTION priv.roll_dice_expr(p_expr text)
 RETURNS jsonb
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare m text[]; n int; sides int; mod int := 0; rolls int[] := '{}'; i int; total int := 0;
begin
  m := regexp_match(p_expr, '^(\d+)d(\d+)([+-]\d+)?$');
  if m is null then return jsonb_build_object('erro', 'expressao invalida', 'expr', p_expr); end if;
  n := m[1]::int; sides := m[2]::int;
  if m[3] is not null then mod := m[3]::int; end if;
  if n < 1 or n > 100 or sides < 2 or sides > 100 then raise exception 'Dados fora do limite.'; end if;
  for i in 1..n loop
    rolls := rolls || (1 + floor(random() * sides)::int);
    total := total + rolls[i];
  end loop;
  total := total + mod;
  return jsonb_build_object('rolls', rolls, 'soma', total - mod, 'mod', mod, 'total', total, 'sides', sides);
end $function$
;

-- sheet_fix()
CREATE OR REPLACE FUNCTION priv.sheet_fix()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare pvm int; pmm int; reset boolean := false;
begin
  if new.classe is null then new.pv_atual := 0; new.pm_atual := 0; return new; end if;
  pvm := public.calc_pv(new.classe, (new.atributos->>'CON')::int);
  pmm := public.calc_pm(new.classe, (new.atributos->>'INT')::int);
  if tg_op = 'INSERT' then
    reset := true;
  elsif not old.preserve_pv then
    if old.classe is null then
      reset := true;
    elsif not new.ready and (old.classe is distinct from new.classe
                          or old.atributos is distinct from new.atributos) then
      reset := true;
    end if;
  end if;
  if reset then new.pv_atual := pvm; new.pm_atual := pmm;
  else new.pv_atual := least(new.pv_atual, pvm); new.pm_atual := least(new.pm_atual, pmm);
  end if;
  return new;
end $function$
;

-- srd35_maneuver_profile(p_campaign_id bigint, p_token_id text)
CREATE OR REPLACE FUNCTION priv.srd35_maneuver_profile(p_campaign_id bigint, p_token_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_campaign public.campaigns%ROWTYPE;
  v_token jsonb;
  v_count integer;
  v_type text;
  v_source_id text;
  v_character_id bigint;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_stats jsonb;
  v_race_id text;
  v_size text;
  v_size_rank integer;
  v_str integer;
  v_dex integer;
  v_base_str integer;
  v_base_dex integer;
  v_strength_effect integer:=0;
  v_dexterity_effect integer:=0;
  v_target_kind text;
  v_target_id text;
  v_grapple_text text;
  v_grapple_bonus integer;
BEGIN
  IF p_campaign_id IS NULL OR p_campaign_id<1 OR NULLIF(BTRIM(p_token_id),'') IS NULL THEN
    RAISE EXCEPTION 'Campanha e token são obrigatórios.';
  END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;

  SELECT count(*)::integer,(array_agg(t.token))[1]
    INTO v_count,v_token
  FROM jsonb_array_elements(
    CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array'
      THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END
  ) t(token)
  WHERE t.token->>'id'=BTRIM(p_token_id) OR t.token->>'key'=BTRIM(p_token_id);
  IF v_count<>1 THEN RAISE EXCEPTION 'Token inexistente ou duplicado na cena.'; END IF;

  v_type:=lower(coalesce(v_token->>'tipo',''));
  v_source_id:=NULLIF(BTRIM(v_token->>'sourceCharacterId'),'');
  IF v_type='player' THEN
    IF coalesce(v_token->>'id','') !~ '^[0-9]+$' THEN
      RAISE EXCEPTION 'Token de jogador sem ficha numérica válida.';
    END IF;
    v_character_id:=(v_token->>'id')::bigint;
    IF NOT EXISTS (
      SELECT 1 FROM public.characters ch
      JOIN public.members m ON m.campaign_id=ch.campaign_id AND m.user_id=ch.user_id AND m.role='PLAYER'
      WHERE ch.id=v_character_id AND ch.campaign_id=p_campaign_id
    ) THEN
      RAISE EXCEPTION 'A ficha do token de jogador não pertence a um jogador desta campanha.';
    END IF;
  ELSIF v_type='npc' AND v_source_id ~ '^[0-9]+$' THEN
    v_character_id:=v_source_id::bigint;
    IF NOT EXISTS (
      SELECT 1 FROM public.characters ch
      WHERE ch.id=v_character_id AND (
        ch.user_id=v_campaign.owner_id OR EXISTS (
          SELECT 1 FROM public.members m
          WHERE m.campaign_id=p_campaign_id AND m.user_id=ch.user_id AND m.role='GM'
        )
      )
    ) THEN
      RAISE EXCEPTION 'A ficha vinculada ao NPC não pertence ao Mestre desta campanha.';
    END IF;
  END IF;

  IF v_character_id IS NOT NULL THEN
    SELECT * INTO v_sheet FROM public.srd_character_sheets
      WHERE character_id=v_character_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD vinculada ao token não encontrada.'; END IF;
    v_stats:=coalesce(v_sheet.atributos,'{}'::jsonb);
    v_race_id:=v_sheet.raca_id;
    SELECT tamanho INTO v_size FROM public.srd_races WHERE id::text=v_race_id;
    v_str:=NULLIF(v_stats->>'FOR','')::integer;
    v_dex:=NULLIF(v_stats->>'DES','')::integer;
  ELSIF v_type IN ('monstro','npc') THEN
    v_stats:=coalesce(v_token->'monsterStats','{}'::jsonb);
    v_str:=coalesce(
      NULLIF(v_stats->>'forca','')::integer,
      NULLIF(v_stats->'dados_tecnicos'->'statblock'->'abilities'->>'str','')::integer
    );
    v_dex:=coalesce(
      NULLIF(v_stats->>'destreza','')::integer,
      NULLIF(v_stats->'dados_tecnicos'->'statblock'->'abilities'->>'dex','')::integer
    );
    v_race_id:=NULLIF(v_stats->>'race_id','');
    v_size:=coalesce(v_token->>'size',v_stats->>'tamanho',v_stats->>'size','Medium');
    v_grapple_text:=coalesce(v_stats->>'base_attack_grapple',
      v_stats->'dados_tecnicos'->'statblock'->>'base_attack_grapple');
    IF v_grapple_text ~ '/[+-]?[0-9]+' THEN
      v_grapple_bonus:=substring(v_grapple_text from '/([+-]?[0-9]+)')::integer;
    END IF;
  ELSE
    RAISE EXCEPTION 'Tipo de token não suportado para manobras.';
  END IF;

  IF v_str IS NULL OR v_dex IS NULL THEN
    RAISE EXCEPTION 'A ficha ou bloco de estatísticas não contém FOR e DES válidas.';
  END IF;

  -- Manobras usam os valores efetivos: Fúria, magias e condições alteram FOR/DES.
  v_base_str:=v_str;
  v_base_dex:=v_dex;
  v_target_kind:=CASE WHEN v_type='player' THEN 'character' ELSE 'token' END;
  v_target_id:=CASE WHEN v_type='player' THEN v_character_id::text ELSE v_token->>'id' END;
  v_strength_effect:=priv.srd_effective_modifier(p_campaign_id,v_target_kind,v_target_id,'strength');
  v_dexterity_effect:=priv.srd_effective_modifier(p_campaign_id,v_target_kind,v_target_id,'dexterity');
  v_str:=GREATEST(0,v_str+v_strength_effect);
  v_dex:=GREATEST(0,v_dex+v_dexterity_effect);

  v_size:=coalesce(v_size,'Medium');
  v_size_rank:=CASE
    WHEN lower(translate(v_size,'áéíóúãõâêôç','aeiouaoaeoc')) IN ('fine','minusculo','minúsculo') THEN 0
    WHEN lower(translate(v_size,'áéíóúãõâêôç','aeiouaoaeoc')) IN ('diminutive','diminuto') THEN 1
    WHEN lower(translate(v_size,'áéíóúãõâêôç','aeiouaoaeoc')) IN ('tiny','miudo','miúdo') THEN 2
    WHEN lower(translate(v_size,'áéíóúãõâêôç','aeiouaoaeoc')) IN ('small','pequeno') THEN 3
    WHEN lower(translate(v_size,'áéíóúãõâêôç','aeiouaoaeoc')) IN ('large','grande') THEN 5
    WHEN lower(translate(v_size,'áéíóúãõâêôç','aeiouaoaeoc')) IN ('huge','enorme') THEN 6
    WHEN lower(translate(v_size,'áéíóúãõâêôç','aeiouaoaeoc')) IN ('gargantuan','imenso') THEN 7
    WHEN lower(translate(v_size,'áéíóúãõâêôç','aeiouaoaeoc'))='colossal' THEN 8
    ELSE 4
  END;

  RETURN jsonb_build_object(
    'token_id',v_token->>'id',
    'token_key',v_token->>'key',
    'token_type',v_type,
    'character_id',v_character_id,
    'source_character_id',v_source_id,
    'race_id',v_race_id,
    'strength_score',v_str,
    'base_strength_score',v_base_str,
    'strength_effect_modifier',v_strength_effect,
    'strength_modifier',floor((v_str-10)::numeric/2)::integer,
    'dexterity_score',v_dex,
    'base_dexterity_score',v_base_dex,
    'dexterity_effect_modifier',v_dexterity_effect,
    'dexterity_modifier',floor((v_dex-10)::numeric/2)::integer,
    'size',v_size,
    'size_rank',v_size_rank,
    'size_modifier',4*(v_size_rank-4),
    'monster_grapple_bonus',v_grapple_bonus
  );
END;
$function$
;

-- srd_adjust_damage(p_campaign_id bigint, p_target_kind text, p_target_id text, p_damage_type text, p_base_damage integer)
CREATE OR REPLACE FUNCTION priv.srd_adjust_damage(p_campaign_id bigint, p_target_kind text, p_target_id text, p_damage_type text, p_base_damage integer)
 RETURNS integer
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_type text:=lower(COALESCE(NULLIF(BTRIM(p_damage_type),''),'untyped'));
  v_immune boolean:=false;
  v_vulnerable boolean:=false;
  v_resistance integer:=0;
  v_damage integer;
  v_class_level integer:=0;
  v_class_dr integer:=0;
  v_token jsonb; v_special_qualities text:=''; v_match text[]; v_base_resistance integer:=0;
BEGIN
  IF p_base_damage IS NULL OR p_base_damage<0 OR p_base_damage>100000 THEN
    RAISE EXCEPTION 'Quantidade de dano inválida.';
  END IF;
  IF p_campaign_id IS NULL OR NULLIF(BTRIM(p_target_id),'') IS NULL THEN
    RETURN p_base_damage;
  END IF;
  v_type:=CASE v_type
    WHEN 'cortante' THEN 'slashing'
    WHEN 'perfurante' THEN 'piercing'
    WHEN 'impacto' THEN 'bludgeoning'
    WHEN 'cortante/perfurante' THEN 'physical'
    WHEN 'impacto/perfurante' THEN 'physical'
    WHEN 'positive' THEN 'positive_energy'
    WHEN 'negative' THEN 'negative_energy'
    ELSE v_type END;

  SELECT
    COALESCE(bool_or(a.value->>'mode'='immunity'),false),
    COALESCE(bool_or(a.value->>'mode'='vulnerability'),false),
    COALESCE(max(CASE WHEN a.value->>'mode'='resistance'
                      AND COALESCE(a.value->>'value','') ~ '^[0-9]{1,4}$'
                      THEN (a.value->>'value')::integer ELSE 0 END),0)
  INTO v_immune,v_vulnerable,v_resistance
  FROM public.srd_campaign_effects e
  CROSS JOIN LATERAL jsonb_array_elements(
    CASE WHEN jsonb_typeof(e.effect_data->'damage_adjustments')='array'
         THEN e.effect_data->'damage_adjustments' ELSE '[]'::jsonb END
  ) a(value)
  WHERE e.campaign_id=p_campaign_id
    AND e.target_kind=p_target_kind
    AND e.target_id=p_target_id
    AND e.active=true
    AND (
      a.value->>'damage_type'='all'
      OR a.value->>'damage_type'=v_type
      OR (a.value->>'damage_type'='physical' AND v_type IN ('slashing','piercing','bludgeoning'))
    );

  IF p_target_kind='token' THEN
    SELECT t.value INTO v_token
    FROM public.campaigns c
    CROSS JOIN LATERAL jsonb_array_elements(CASE WHEN jsonb_typeof(c.cba_data->'tokens')='array' THEN c.cba_data->'tokens' ELSE '[]'::jsonb END) t(value)
    WHERE c.id=p_campaign_id AND (t.value->>'id'=p_target_id OR t.value->>'key'=p_target_id) LIMIT 1;
    v_special_qualities:=lower(COALESCE(
      v_token->'monsterStats'->'qualidades_especiais'->>'special_qualities',
      v_token->'monsterStats'->'dados_tecnicos'->'statblock'->>'special_qualities',
      v_token->'monsterStats'->>'special_qualities',
      ''
    ));
    IF v_type IN ('acid','cold','electricity','fire','sonic','force','positive_energy','negative_energy') THEN
      IF position('immunity to '||v_type in v_special_qualities)>0
         OR position('immune to '||v_type in v_special_qualities)>0 THEN
        v_immune:=true;
      END IF;
      IF NOT v_immune THEN
        v_match:=regexp_match(v_special_qualities,'resistance to [^.;]*'||v_type||'[[:space:]]+([0-9]+)');
        IF v_match IS NULL THEN v_match:=regexp_match(v_special_qualities,v_type||'[[:space:]]+resistance[[:space:]]+([0-9]+)'); END IF;
        IF v_match IS NULL THEN v_match:=regexp_match(v_special_qualities,'resistance[[:space:]]+([0-9]+)[[:space:]]+to[[:space:]]+'||v_type); END IF;
        IF v_match IS NOT NULL THEN v_base_resistance:=v_match[1]::integer; END IF;
      END IF;
    END IF;
  END IF;
  IF v_immune THEN RETURN 0; END IF;
  v_resistance:=GREATEST(v_resistance,v_base_resistance);

  -- D&D 3.5: redução de dano do Bárbaro (1/— no nível 7,
  -- aumentando +1 a cada três níveis; máximo 5/— no nível 19).
  -- Só reduz dano físico; não reduz energia, ácido, fogo, frio etc.
  IF p_target_kind='character' AND v_type IN ('physical','slashing','piercing','bludgeoning') THEN
    SELECT COALESCE(
      MAX(cl.class_level) FILTER (WHERE cl.class_id='barbaro'),
      CASE WHEN sh.classe_id='barbaro' THEN sh.nivel ELSE 0 END
    )
      INTO v_class_level
      FROM public.srd_character_sheets sh
      LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
     WHERE sh.character_id::text=BTRIM(p_target_id)
     GROUP BY sh.character_id,sh.classe_id,sh.nivel;
    IF v_class_level>=7 THEN
      v_class_dr:=LEAST(5,GREATEST(0,FLOOR((v_class_level-4)::numeric/3)::integer));
    END IF;
  END IF;

  v_damage:=GREATEST(0,p_base_damage-v_resistance-v_class_dr);
  IF p_target_kind='token' AND v_type IN ('physical','slashing','piercing','bludgeoning')
     AND NULLIF(v_token->>'sourceCharacterId','') IS NOT NULL THEN
    SELECT COALESCE(
      MAX(cl.class_level) FILTER (WHERE cl.class_id='barbaro'),
      CASE WHEN sh.classe_id='barbaro' THEN sh.nivel ELSE 0 END
    ) INTO v_class_level
    FROM public.srd_character_sheets sh
    LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
    WHERE sh.character_id::text=NULLIF(v_token->>'sourceCharacterId','')
    GROUP BY sh.character_id,sh.classe_id,sh.nivel;
    IF v_class_level>=7 THEN
      v_class_dr:=LEAST(5,GREATEST(0,FLOOR((v_class_level-4)::numeric/3)::integer));
    END IF;
  END IF;

  v_damage:=GREATEST(0,p_base_damage-v_resistance-v_class_dr);
  IF v_vulnerable THEN v_damage:=FLOOR(v_damage*1.5)::integer; END IF;
  RETURN v_damage;
END;
$function$
;

-- srd_adjust_damage_components(p_campaign_id bigint, p_target_kind text, p_target_id text, p_effect_data jsonb)
CREATE OR REPLACE FUNCTION priv.srd_adjust_damage_components(p_campaign_id bigint, p_target_kind text, p_target_id text, p_effect_data jsonb)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_base integer:=GREATEST(0,COALESCE(NULLIF(p_effect_data->>'damage','')::integer,0));
  v_components jsonb:=p_effect_data->'damage_components';
  v_component jsonb;
  v_component_type text;
  v_component_ratio numeric;
  v_component_amount integer;
  v_component_count integer;
  v_allocated integer:=0;
  v_total integer:=0;
  v_ratio_sum numeric:=0;
  v_ord integer; v_explicit_amount integer; v_component_has_amount boolean:=false;
BEGIN
  IF COALESCE(jsonb_typeof(v_components),'null')<>'array' THEN
    RETURN priv.srd_adjust_damage(p_campaign_id,p_target_kind,p_target_id,
      COALESCE(NULLIF(p_effect_data->>'damage_type',''),'untyped'),v_base);
  END IF;
  v_component_count:=jsonb_array_length(v_components);
  IF v_component_count<1 OR v_component_count>8 THEN RAISE EXCEPTION 'Componentes de dano inválidos.'; END IF;
  v_component_has_amount:=COALESCE((v_components->0) ? 'amount',false);
  IF NOT v_component_has_amount THEN
    SELECT COALESCE(SUM((value->>'ratio')::numeric),0)
      INTO v_ratio_sum FROM jsonb_array_elements(v_components);
    IF ABS(v_ratio_sum-1.0)>0.001 THEN RAISE EXCEPTION 'As proporções dos componentes de dano devem somar 1.'; END IF;
  END IF;
  FOR v_component,v_ord IN
    SELECT value,ordinality::integer
    FROM jsonb_array_elements(v_components) WITH ORDINALITY
  LOOP
    v_component_type:=COALESCE(NULLIF(v_component->>'damage_type',''),'untyped');
    IF v_component_type='mixed' THEN RAISE EXCEPTION 'Tipo de componente de dano inválido.'; END IF;
    IF v_component_type='' THEN RAISE EXCEPTION 'Tipo de componente de dano inválido.'; END IF;
    IF v_component_has_amount THEN
      v_explicit_amount:=COALESCE(NULLIF(v_component->>'amount','')::integer,0);
      IF v_explicit_amount<0 THEN RAISE EXCEPTION 'Quantidade de dano por componente inválida.'; END IF;
      v_component_amount:=v_explicit_amount;
    ELSE
      v_component_ratio:=COALESCE((v_component->>'ratio')::numeric,0);
      IF v_component_ratio<0 OR v_component_ratio>1 THEN RAISE EXCEPTION 'Proporção de dano inválida.'; END IF;
      IF v_ord=v_component_count THEN
        v_component_amount:=v_base-v_allocated;
      ELSE
        v_component_amount:=FLOOR(v_base*v_component_ratio)::integer;
      END IF;
    END IF;
    v_allocated:=v_allocated+v_component_amount;
    v_total:=v_total+priv.srd_adjust_damage(p_campaign_id,p_target_kind,p_target_id,v_component_type,v_component_amount);
  END LOOP;
  IF v_component_has_amount AND v_allocated<>v_base THEN
    RAISE EXCEPTION 'A soma dos componentes (%) não corresponde ao dano total (%).',v_allocated,v_base;
  END IF;
  RETURN GREATEST(0,v_total);
END;
$function$
;

-- srd_aoo_require_blind_concealment_roll()
CREATE OR REPLACE FUNCTION priv.srd_aoo_require_blind_concealment_roll()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
begin
  if new.status='awaiting_damage'
     and old.status is distinct from 'awaiting_miss_chance'
     and not (coalesce(new.resolution_data,'{}'::jsonb) ? 'concealment_d100') then
    if priv.srd_condition_has_flag(new.campaign_id,'token',new.actor_token_id,'opponents_total_concealment')
       or (new.actor_character_id is not null and
         priv.srd_condition_has_flag(new.campaign_id,'character',new.actor_character_id::text,'opponents_total_concealment')) then
      new.resolution_data:=coalesce(new.resolution_data,'{}'::jsonb)||jsonb_build_object(
        'concealment_required',true,
        'concealment_miss_chance',50,
        'concealment_source','opponents_total_concealment',
        'concealment_pending_status','awaiting_damage'
      );
      new.status:='awaiting_miss_chance';
    end if;
  end if;
  return new;
end;
$function$
;

-- srd_apply_campaign_condition(p_campaign_id bigint, p_target_kind text, p_target_id text, p_condition_id text, p_duration_rounds integer, p_notes jsonb, p_source_spell_id text)
CREATE OR REPLACE FUNCTION priv.srd_apply_campaign_condition(p_campaign_id bigint, p_target_kind text, p_target_id text, p_condition_id text, p_duration_rounds integer DEFAULT NULL::integer, p_notes jsonb DEFAULT '{}'::jsonb, p_source_spell_id text DEFAULT NULL::text)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_round integer;
  v_cba jsonb;
  v_instance bigint;
BEGIN
  IF p_campaign_id IS NULL OR p_campaign_id<1 THEN RAISE EXCEPTION 'Campanha inválida.'; END IF;
  IF p_target_kind NOT IN ('character','token') THEN RAISE EXCEPTION 'Tipo de alvo inválido.'; END IF;
  IF NULLIF(BTRIM(p_target_id),'') IS NULL OR length(p_target_id)>160 THEN RAISE EXCEPTION 'Alvo inválido.'; END IF;
  IF p_duration_rounds IS NOT NULL AND p_duration_rounds NOT BETWEEN 1 AND 10000 THEN
    RAISE EXCEPTION 'A duração deve estar entre 1 e 10000 rodadas.';
  END IF;
  IF p_notes IS NULL OR jsonb_typeof(p_notes)<>'object' OR octet_length(p_notes::text)>12000 THEN
    RAISE EXCEPTION 'Metadados da condição inválidos.';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.srd_conditions WHERE condition_id=p_condition_id
  ) THEN RAISE EXCEPTION 'Condição D&D 3.5 inexistente.'; END IF;

  SELECT COALESCE(NULLIF(c.combat_data->>'round','')::integer,1),
         COALESCE(c.cba_data,'{}'::jsonb)
    INTO v_round,v_cba
    FROM public.campaigns c
   WHERE c.id=p_campaign_id
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;

  IF p_target_kind='character' AND NOT EXISTS (
    SELECT 1 FROM public.characters ch
    WHERE ch.id::text=p_target_id AND ch.campaign_id=p_campaign_id
  ) THEN
    RAISE EXCEPTION 'Personagem não pertence a esta campanha.';
  ELSIF p_target_kind='token' AND NOT (
    EXISTS (
      SELECT 1
      FROM jsonb_array_elements(
        CASE WHEN jsonb_typeof(v_cba->'tokens')='array' THEN v_cba->'tokens' ELSE '[]'::jsonb END
      ) t
      WHERE t->>'id'=p_target_id OR t->>'key'=p_target_id
    )
    OR EXISTS (
      SELECT 1 FROM public.tokens t
      WHERE t.campaign_id=p_campaign_id AND t.id::text=p_target_id
    )
  ) THEN
    RAISE EXCEPTION 'Token não pertence ao tabuleiro desta campanha.';
  END IF;

  IF p_condition_id='slowed' THEN
    UPDATE public.srd_campaign_effects SET active=false
     WHERE campaign_id=p_campaign_id AND target_kind=p_target_kind AND target_id=p_target_id
       AND source_spell_id='srd35_spell_haste' AND active=true;
  END IF;
  UPDATE public.srd_campaign_conditions
     SET active=false
   WHERE campaign_id=p_campaign_id AND target_kind=p_target_kind
     AND target_id=p_target_id AND condition_id=p_condition_id AND active=true;

  INSERT INTO public.srd_campaign_conditions(
    campaign_id,target_kind,target_id,condition_id,source_actor_id,source_spell_id,
    started_round,expires_round,active,notes
  ) VALUES (
    p_campaign_id,p_target_kind,p_target_id,p_condition_id,
    NULLIF(BTRIM(p_notes->>'caster_character_id'),''),p_source_spell_id,
    v_round,
    CASE WHEN p_duration_rounds IS NULL THEN NULL ELSE v_round+p_duration_rounds END,
    true,p_notes
  )
  RETURNING condition_instance_id INTO v_instance;

  RETURN v_instance;
END;
$function$
;

-- srd_apply_campaign_effect(p_campaign_id bigint, p_target_kind text, p_target_id text, p_effect_kind text, p_effect_data jsonb, p_duration_rounds integer, p_source_spell_id text, p_concentration_actor_id text)
CREATE OR REPLACE FUNCTION priv.srd_apply_campaign_effect(p_campaign_id bigint, p_target_kind text, p_target_id text, p_effect_kind text, p_effect_data jsonb, p_duration_rounds integer DEFAULT NULL::integer, p_source_spell_id text DEFAULT NULL::text, p_concentration_actor_id text DEFAULT NULL::text)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_round integer;
  v_cba jsonb;
  v_modifier jsonb;
  v_stat text;
  v_value integer;
  v_bonus_type text;
  v_stack_key text;
  v_instance bigint;
BEGIN
  IF p_campaign_id IS NULL OR p_campaign_id < 1 THEN
    RAISE EXCEPTION 'Campanha inválida.';
  END IF;
  IF p_target_kind NOT IN ('character','token','area') THEN
    RAISE EXCEPTION 'Tipo de alvo inválido.';
  END IF;
  IF NULLIF(BTRIM(p_target_id),'') IS NULL OR length(p_target_id)>160 THEN
    RAISE EXCEPTION 'Identificador do alvo inválido.';
  END IF;
  IF p_effect_kind NOT IN ('attack','buff','condition','damage','debuff','drain','healing','movement','saving_throw','special','summon','utility') THEN
    RAISE EXCEPTION 'Tipo de efeito não suportado.';
  END IF;
  IF p_effect_data IS NULL OR jsonb_typeof(p_effect_data)<>'object'
     OR octet_length(p_effect_data::text)>12000 THEN
    RAISE EXCEPTION 'Dados do efeito inválidos ou acima do limite.';
  END IF;
  IF p_duration_rounds IS NOT NULL AND p_duration_rounds NOT BETWEEN 1 AND 20000 THEN
    RAISE EXCEPTION 'Duração em rodadas inválida.';
  END IF;

  SELECT COALESCE(NULLIF(c.combat_data->>'round','')::integer,1),
         COALESCE(c.cba_data,'{}'::jsonb)
    INTO v_round,v_cba
    FROM public.campaigns c
   WHERE c.id=p_campaign_id
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  IF v_round<1 THEN RAISE EXCEPTION 'Rodada atual inválida.'; END IF;

  IF p_target_kind='character' AND NOT EXISTS (
    SELECT 1 FROM public.characters ch
    WHERE ch.id::text=p_target_id AND ch.campaign_id=p_campaign_id
  ) THEN
    RAISE EXCEPTION 'Personagem-alvo não pertence à campanha.';
  ELSIF p_target_kind='token' AND NOT (
    EXISTS (
      SELECT 1
      FROM jsonb_array_elements(
        CASE WHEN jsonb_typeof(v_cba->'tokens')='array' THEN v_cba->'tokens' ELSE '[]'::jsonb END
      ) t
      WHERE t->>'key'=p_target_id OR t->>'id'=p_target_id
    )
    OR EXISTS (
      SELECT 1 FROM public.tokens t
      WHERE t.campaign_id=p_campaign_id AND t.id::text=p_target_id
    )
  ) THEN
    RAISE EXCEPTION 'Token-alvo não pertence à campanha.';
  END IF;


  IF p_source_spell_id='srd35_spell_haste' THEN
    UPDATE public.srd_campaign_conditions SET active=false
     WHERE campaign_id=p_campaign_id AND target_kind=p_target_kind AND target_id=p_target_id
       AND condition_id='slowed' AND active=true;
  ELSIF p_source_spell_id='srd35_bless' THEN
    UPDATE public.srd_campaign_effects SET active=false
     WHERE campaign_id=p_campaign_id AND target_kind=p_target_kind AND target_id=p_target_id
       AND source_spell_id='srd35_spell_bane' AND active=true;
  ELSIF p_source_spell_id='srd35_spell_bane' THEN
    UPDATE public.srd_campaign_effects SET active=false
     WHERE campaign_id=p_campaign_id AND target_kind=p_target_kind AND target_id=p_target_id
       AND source_spell_id='srd35_bless' AND active=true;
  END IF;

  IF p_effect_data ? 'modifiers' THEN
    IF jsonb_typeof(p_effect_data->'modifiers')<>'array' THEN
      RAISE EXCEPTION 'modifiers deve ser uma lista.';
    END IF;
    FOR v_modifier IN SELECT value FROM jsonb_array_elements(p_effect_data->'modifiers')
    LOOP
      IF jsonb_typeof(v_modifier)<>'object' THEN
        RAISE EXCEPTION 'Cada modificador deve ser um objeto.';
      END IF;
      v_stat:=v_modifier->>'stat';
      IF v_stat IS NULL OR v_stat !~ '^[a-z][a-z0-9_:.]{0,47}$' THEN
        RAISE EXCEPTION 'Atributo de modificador inválido.';
      END IF;
      IF COALESCE(v_modifier->>'value','') !~ '^-?[0-9]{1,3}$' THEN
        RAISE EXCEPTION 'Valor de modificador inválido.';
      END IF;
      v_value:=(v_modifier->>'value')::integer;
      IF v_value NOT BETWEEN -100 AND 100 OR v_value=0 THEN
        RAISE EXCEPTION 'Modificador deve estar entre -100 e 100 e não pode ser zero.';
      END IF;
      v_bonus_type:=COALESCE(NULLIF(v_modifier->>'bonus_type',''),'untyped');
      IF v_bonus_type NOT IN (
        'alchemical','armor','circumstance','competence','deflection','dodge',
        'enhancement','inherent','insight','luck','morale','natural_armor',
        'profane','racial','resistance','sacred','shield','size','untyped'
      ) THEN
        RAISE EXCEPTION 'Tipo de bônus D&D 3.5 inválido.';
      END IF;
    END LOOP;
  END IF;


  IF p_effect_data ? 'damage_adjustments' THEN
    IF jsonb_typeof(p_effect_data->'damage_adjustments')<>'array' THEN
      RAISE EXCEPTION 'damage_adjustments deve ser uma lista.';
    END IF;
    FOR v_modifier IN SELECT value FROM jsonb_array_elements(p_effect_data->'damage_adjustments')
    LOOP
      IF jsonb_typeof(v_modifier)<>'object'
         OR COALESCE(v_modifier->>'damage_type','') !~ '^(all|physical|slashing|piercing|bludgeoning|acid|cold|electricity|fire|sonic|force|positive|negative|untyped)$'
         OR COALESCE(v_modifier->>'mode','') NOT IN ('immunity','resistance','vulnerability') THEN
        RAISE EXCEPTION 'Regra de resistência ou imunidade inválida.';
      END IF;
      IF v_modifier->>'mode'='resistance'
         AND (COALESCE(v_modifier->>'value','') !~ '^[0-9]{1,4}$'
              OR (v_modifier->>'value')::integer NOT BETWEEN 1 AND 20000) THEN
        RAISE EXCEPTION 'Valor de resistência inválido.';
      END IF;
    END LOOP;
  END IF;

  v_stack_key:=NULLIF(BTRIM(p_effect_data->>'stacking_key'),'');
  IF v_stack_key IS NOT NULL AND p_effect_data->>'stacking_policy'='replace' THEN
    UPDATE public.srd_campaign_effects
       SET active=false
     WHERE campaign_id=p_campaign_id
       AND target_kind=p_target_kind
       AND target_id=p_target_id
       AND active=true
       AND effect_data->>'stacking_key'=v_stack_key;
  END IF;

  INSERT INTO public.srd_campaign_effects(
    campaign_id,target_kind,target_id,source_spell_id,effect_kind,
    started_round,expires_round,concentration_actor_id,active,effect_data
  ) VALUES (
    p_campaign_id,p_target_kind,p_target_id,p_source_spell_id,p_effect_kind,
    v_round,
    CASE WHEN p_duration_rounds IS NULL THEN NULL ELSE v_round+p_duration_rounds END,
    p_concentration_actor_id,true,p_effect_data
  )
  RETURNING effect_instance_id INTO v_instance;

  RETURN v_instance;
END;
$function$
;

-- srd_apply_pending_spell_resolution(p_pending_id uuid)
CREATE OR REPLACE FUNCTION priv.srd_apply_pending_spell_resolution(p_pending_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE v_pending priv.srd_pending_spell_resolutions%ROWTYPE; v_instance bigint; v_campaign public.campaigns%ROWTYPE; v_hp integer; v_max_hp integer; v_new_hp integer; v_damage integer; v_tokens jsonb; v_token jsonb; v_index bigint; v_count integer; v_name text; v_condition_id text;
BEGIN
  SELECT * INTO v_pending FROM priv.srd_pending_spell_resolutions WHERE pending_id=p_pending_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Resolução de magia pendente não encontrada.'; END IF;
  IF v_pending.status NOT IN ('pending_save','awaiting_spell_resistance') THEN RAISE EXCEPTION 'Esta resolução de magia já foi concluída.'; END IF;

  IF v_pending.effect_kind='damage' THEN
    IF COALESCE(v_pending.effect_data->>'damage','') !~ '^-?[0-9]{1,6}$'
       OR (v_pending.effect_data->>'damage')::integer NOT BETWEEN 0 AND 100000
       OR COALESCE(v_pending.effect_data->>'damage_type','') !~ '^[a-z_]{1,24}$' THEN
      RAISE EXCEPTION 'Dados de dano pendente inválidos.';
    END IF;
    v_damage:=(v_pending.effect_data->>'damage')::integer;
    IF priv.srd_effect_has_flag(v_pending.campaign_id,v_pending.target_kind,v_pending.target_id,'negates_magic_missile') THEN
      UPDATE priv.srd_pending_spell_resolutions SET status='resolved',resolved_at=now() WHERE pending_id=p_pending_id;
      RETURN jsonb_build_object('pending_id',p_pending_id,'status','negated_by_shield','damage',0,'spell_negated_by_shield',true);
    END IF;
    SELECT * INTO v_campaign FROM public.campaigns WHERE id=v_pending.campaign_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Campanha do efeito de dano não encontrada.'; END IF;

    IF v_pending.target_kind='character' THEN
      SELECT sh.pv_atual,sh.pv_max INTO v_hp,v_max_hp
      FROM public.characters ch
      JOIN public.srd_character_sheets sh ON sh.character_id=ch.id
      WHERE ch.id::text=v_pending.target_id AND ch.campaign_id=v_pending.campaign_id
      FOR UPDATE OF sh;
      IF NOT FOUND OR v_max_hp IS NULL OR v_max_hp<1 THEN RAISE EXCEPTION 'Ficha do alvo de dano inválida.'; END IF;
      v_damage:=priv.srd_adjust_damage_components(v_pending.campaign_id,'character',v_pending.target_id,v_pending.effect_data);
      v_new_hp:=GREATEST(-10,COALESCE(v_hp,v_max_hp)-v_damage);
      PERFORM priv.srd_sync_character_vital_condition(v_pending.target_id,v_new_hp,false);
      UPDATE public.srd_character_sheets SET pv_atual=v_new_hp WHERE character_id::text=v_pending.target_id;
      v_name:=(SELECT nome FROM public.characters WHERE id::text=v_pending.target_id);
    ELSIF v_pending.target_kind='token' THEN
      v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END;
      SELECT count(*)::integer,min(e.ordinality),min(e.token->>'nome')
        INTO v_count,v_index,v_name
      FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
      WHERE e.token->>'key'=v_pending.target_id OR e.token->>'id'=v_pending.target_id;
      IF v_count<>1 THEN RAISE EXCEPTION 'Token-alvo de dano ausente ou duplicado.'; END IF;
      v_token:=v_tokens->(v_index::integer-1);
      IF COALESCE(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN RAISE EXCEPTION 'Token-alvo sem PV máximo válido.'; END IF;
      v_max_hp:=(v_token->>'maxHp')::integer;
      IF v_max_hp>100000 THEN RAISE EXCEPTION 'PV máximo do token excede o limite.'; END IF;
      v_hp:=CASE WHEN COALESCE(v_token->>'hp','') ~ '^-?[0-9]{1,6}$' THEN (v_token->>'hp')::integer ELSE v_max_hp END;
      v_damage:=priv.srd_adjust_damage_components(v_pending.campaign_id,'token',v_pending.target_id,v_pending.effect_data);
      v_new_hp:=GREATEST(-10,v_hp-v_damage);
      v_tokens:=jsonb_set(v_tokens,ARRAY[(v_index-1)::text],v_token||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp),false);
      UPDATE public.campaigns SET cba_data=COALESCE(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens)
      WHERE id=v_pending.campaign_id;
      PERFORM priv.srd_sync_linked_npc_token_vitals(v_pending.campaign_id,v_pending.target_id,v_new_hp,v_max_hp);
    ELSE
      RAISE EXCEPTION 'Tipo de alvo incompatível com dano pendente.';
    END IF;
    v_condition_id:=NULLIF(v_pending.effect_data->>'secondary_condition_id','');
    IF v_condition_id IS NOT NULL AND COALESCE((v_pending.effect_data->>'apply_secondary_condition')::boolean,true) THEN
      v_instance:=priv.srd_apply_campaign_condition(
        v_pending.campaign_id,v_pending.target_kind,v_pending.target_id,v_condition_id,
        v_pending.duration_rounds,
        jsonb_build_object('source_spell_id',v_pending.spell_id,'caster_character_id',v_pending.caster_character_id,
          'save_dc',v_pending.save_dc,'save_type',v_pending.save_type,'caster_level',v_pending.caster_level),
        v_pending.spell_id
      );
    END IF;
    UPDATE priv.srd_pending_spell_resolutions SET status='resolved',resolved_at=now() WHERE pending_id=p_pending_id;
    RETURN jsonb_build_object('pending_id',p_pending_id,'status','resolved','damage',v_damage,
      'pv_atual',v_new_hp,'pv_max',v_max_hp,'target_name',COALESCE(v_name,'Alvo'),
      'damage_type',v_pending.effect_data->>'damage_type','condition_id',v_condition_id,'condition_instance_id',v_instance);
  ELSIF v_pending.condition_id IS NOT NULL THEN

    v_instance:=priv.srd_apply_campaign_condition(
      v_pending.campaign_id,v_pending.target_kind,v_pending.target_id,v_pending.condition_id,
      v_pending.duration_rounds,
      jsonb_build_object('source_spell_id',v_pending.spell_id,'caster_character_id',v_pending.caster_character_id,'save_dc',v_pending.save_dc,'save_type',v_pending.save_type,
        'save_each_turn',v_pending.spell_id='srd35_spell_hold_person','caster_level',v_pending.caster_level),
      v_pending.spell_id
    );
  ELSIF v_pending.effect_data<>'{}'::jsonb THEN
    v_instance:=priv.srd_apply_campaign_effect(v_pending.campaign_id,v_pending.target_kind,v_pending.target_id,
      v_pending.effect_kind,v_pending.effect_data,v_pending.duration_rounds,v_pending.spell_id,NULL);
  ELSE
    RAISE EXCEPTION 'A magia não possui uma regra de efeito implementada.';
  END IF;
  UPDATE priv.srd_pending_spell_resolutions SET status='resolved',resolved_at=now() WHERE pending_id=p_pending_id;
  RETURN jsonb_build_object('pending_id',p_pending_id,'status','resolved','instance_id',v_instance,'condition_id',v_pending.condition_id);
END;
$function$
;

-- srd_calcular_ca_alvo_campanha_srd(p_campaign_id bigint, p_character_id text, p_attack_context text)
CREATE OR REPLACE FUNCTION priv.srd_calcular_ca_alvo_campanha_srd(p_campaign_id bigint, p_character_id text, p_attack_context text DEFAULT 'normal'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_character public.characters%ROWTYPE;
  v_context text:=lower(COALESCE(NULLIF(BTRIM(p_attack_context),''),'normal'));
  v_barbarian_level integer:=0;
  v_rogue_level integer:=0;
  v_armor_bonus integer:=0;
  v_shield_bonus integer:=0;
  v_max_dex integer:=99;
  v_dex_score integer:=10;
  v_dex_modifier integer:=0;
  v_dex_applied integer:=0;
  v_size_modifier integer:=0;
  v_effect_modifier integer:=0;
  v_linked_token_id text;
  v_linked_token_count integer:=0;
  v_trap_sense_bonus integer:=0;
  v_flatfooted boolean:=false;
  v_other_dex_loss boolean:=false;
  v_uncanny_dodge boolean:=false;
  v_improved_uncanny_dodge boolean:=false;
  v_lose_dex boolean:=false;
  v_final_ac integer:=10;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF v_context NOT IN ('normal','flatfooted','invisible','trap') THEN
    RAISE EXCEPTION 'Contexto de ataque inválido.';
  END IF;

  SELECT * INTO v_character
    FROM public.characters ch
   WHERE ch.id::text=BTRIM(p_character_id)
     AND (
       (ch.campaign_id=p_campaign_id AND EXISTS (
         SELECT 1 FROM public.members m
         WHERE m.campaign_id=p_campaign_id
           AND m.user_id=ch.user_id
           AND m.role='PLAYER'
       ))
       OR (
         public.my_role(p_campaign_id) IN ('GM','PLAYER')
         AND EXISTS (
           SELECT 1
           FROM public.members gm
           JOIN public.campaigns camp ON camp.id=gm.campaign_id
           CROSS JOIN LATERAL jsonb_array_elements(
             CASE WHEN jsonb_typeof(camp.cba_data->'tokens')='array'
                  THEN camp.cba_data->'tokens' ELSE '[]'::jsonb END
           ) tok
           WHERE gm.campaign_id=p_campaign_id
             AND gm.user_id=ch.user_id
             AND gm.role='GM'
             AND tok->>'tipo'='npc'
             AND tok->>'sourceCharacterId'=ch.id::text
         )
       )
     );
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou sem acesso à campanha.'; END IF;

  SELECT * INTO v_sheet
    FROM public.srd_character_sheets
   WHERE character_id=v_character.id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD do personagem não encontrada.'; END IF;

  SELECT COALESCE(
    MAX(cl.class_level) FILTER (WHERE cls.class_key='barbarian'),
    CASE WHEN NOT EXISTS (
      SELECT 1 FROM public.srd_character_class_levels any_level
       WHERE any_level.character_id=v_sheet.character_id
    ) AND v_sheet.classe_id='barbaro'
    THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
  ), COALESCE(
    MAX(cl.class_level) FILTER (WHERE cls.class_key='rogue'),
    CASE WHEN NOT EXISTS (
      SELECT 1 FROM public.srd_character_class_levels any_level
       WHERE any_level.character_id=v_sheet.character_id
    ) AND v_sheet.classe_id='ladino'
    THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
  )
    INTO v_barbarian_level,v_rogue_level
    FROM public.srd_character_sheets sh
    LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
    LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
   WHERE sh.character_id=v_sheet.character_id
   GROUP BY sh.character_id,sh.classe_id,sh.nivel;

  v_uncanny_dodge:=COALESCE(v_barbarian_level,0)>=2 OR COALESCE(v_rogue_level,0)>=4;
  v_improved_uncanny_dodge:=COALESCE(v_barbarian_level,0)>=5 OR COALESCE(v_rogue_level,0)>=8;

  WITH equipped AS (
    SELECT eq.id,
           lower(COALESCE(eq.detalhes->>'category',eq.categoria,'')) AS category,
           lower(COALESCE(eq.tipo,'')) AS item_type,
           lower(COALESCE(eq.nome,'')) AS item_name,
           COALESCE(eq.bonus_max_des,eq.max_des) AS max_dex,
           public.srd35_equipment_ca_bonus(eq.id) AS ca_bonus
      FROM public.srd_character_equipment ce
      JOIN public.srd_equipment eq ON eq.id=ce.equipment_id
     WHERE ce.character_id=v_character.id::text AND ce.equipado=true
  ), classified AS (
    SELECT *,
      CASE
        WHEN category='armor_and_shields' THEN
          CASE WHEN item_name LIKE '%shield%' THEN 'shield' ELSE 'armor' END
        WHEN category LIKE '%shield%' OR category LIKE '%escudo%'
          OR item_type LIKE '%shield%' OR item_type LIKE '%escudo%' THEN 'shield'
        WHEN category LIKE '%armor%' OR category LIKE '%armadura%'
          OR item_type LIKE '%armor%' OR item_type LIKE '%armadura%' THEN 'armor'
        ELSE 'other'
      END AS equipment_kind
    FROM equipped
  )
  SELECT
    COALESCE(SUM(ca_bonus) FILTER (WHERE equipment_kind='armor'),0)::integer,
    COALESCE(SUM(ca_bonus) FILTER (WHERE equipment_kind='shield'),0)::integer,
    COALESCE(MIN(max_dex) FILTER (WHERE equipment_kind='armor' AND max_dex IS NOT NULL),99)::integer
    INTO v_armor_bonus,v_shield_bonus,v_max_dex
    FROM classified;

  SELECT COUNT(*)::integer,MAX(COALESCE(tok->>'id',tok->>'key'))
    INTO v_linked_token_count,v_linked_token_id
    FROM public.campaigns camp
    CROSS JOIN LATERAL jsonb_array_elements(
      CASE WHEN jsonb_typeof(camp.cba_data->'tokens')='array'
           THEN camp.cba_data->'tokens' ELSE '[]'::jsonb END
    ) tok
    WHERE camp.id=p_campaign_id AND tok->>'tipo'='npc'
      AND tok->>'sourceCharacterId'=v_character.id::text;
  IF v_linked_token_count>1 THEN
    RAISE EXCEPTION 'Mais de um token NPC está vinculado à mesma ficha; cálculo de CA ambíguo.';
  END IF;
  v_dex_score:=GREATEST(0,COALESCE(NULLIF(v_sheet.atributos->>'DES','')::integer,10)
    +CASE WHEN v_linked_token_id IS NOT NULL
      THEN priv.srd_effective_modifier(p_campaign_id,'token',v_linked_token_id,'dexterity')
      ELSE priv.srd_effective_modifier(p_campaign_id,'character',v_character.id::text,'dexterity')
    END);
  v_dex_modifier:=FLOOR((v_dex_score-10)::numeric/2)::integer;

  SELECT EXISTS (
    SELECT 1 FROM public.srd_campaign_conditions
     WHERE campaign_id=p_campaign_id AND active=true AND condition_id='flatfooted'
       AND (
         (target_kind='character' AND target_id=v_character.id::text)
         OR (target_kind='token' AND target_id IN (
           SELECT tok->>'id' FROM public.campaigns camp
           CROSS JOIN LATERAL jsonb_array_elements(
             CASE WHEN jsonb_typeof(camp.cba_data->'tokens')='array'
                  THEN camp.cba_data->'tokens' ELSE '[]'::jsonb END
           ) tok
           WHERE camp.id=p_campaign_id AND tok->>'tipo'='npc'
             AND tok->>'sourceCharacterId'=v_character.id::text
           UNION
           SELECT tok->>'key' FROM public.campaigns camp
           CROSS JOIN LATERAL jsonb_array_elements(
             CASE WHEN jsonb_typeof(camp.cba_data->'tokens')='array'
                  THEN camp.cba_data->'tokens' ELSE '[]'::jsonb END
           ) tok
           WHERE camp.id=p_campaign_id AND tok->>'tipo'='npc'
             AND tok->>'sourceCharacterId'=v_character.id::text
         ))
       )
  ) INTO v_flatfooted;

  SELECT EXISTS (
    SELECT 1
      FROM public.srd_campaign_conditions cc
      JOIN priv.srd_condition_engine_rules r ON r.condition_id=cc.condition_id AND r.enabled
     WHERE cc.campaign_id=p_campaign_id AND cc.active=true
       AND COALESCE(r.flags->>'loses_dex_ac','false')='true'
       AND cc.condition_id<>'flatfooted'
       AND (
         (cc.target_kind='character' AND cc.target_id=v_character.id::text)
         OR (cc.target_kind='token' AND cc.target_id IN (
           SELECT tok->>'id' FROM public.campaigns camp
           CROSS JOIN LATERAL jsonb_array_elements(
             CASE WHEN jsonb_typeof(camp.cba_data->'tokens')='array'
                  THEN camp.cba_data->'tokens' ELSE '[]'::jsonb END
           ) tok
           WHERE camp.id=p_campaign_id AND tok->>'tipo'='npc'
             AND tok->>'sourceCharacterId'=v_character.id::text
           UNION
           SELECT tok->>'key' FROM public.campaigns camp
           CROSS JOIN LATERAL jsonb_array_elements(
             CASE WHEN jsonb_typeof(camp.cba_data->'tokens')='array'
                  THEN camp.cba_data->'tokens' ELSE '[]'::jsonb END
           ) tok
           WHERE camp.id=p_campaign_id AND tok->>'tipo'='npc'
             AND tok->>'sourceCharacterId'=v_character.id::text
         ))
       )
  ) INTO v_other_dex_loss;

  v_lose_dex:=v_other_dex_loss
    OR ((v_flatfooted OR v_context IN ('flatfooted','invisible')) AND NOT v_uncanny_dodge);
  IF NOT v_lose_dex THEN
    v_dex_applied:=LEAST(v_dex_modifier,v_max_dex);
  END IF;

  SELECT CASE translate(lower(COALESCE(race.tamanho,'medio')),
      'áéíóúãõâêôç','aeiouaoaeoc')
    WHEN 'minusculo' THEN 8 WHEN 'fine' THEN 8
    WHEN 'diminuto' THEN 4 WHEN 'diminutive' THEN 4
    WHEN 'miudo' THEN 2 WHEN 'tiny' THEN 2
    WHEN 'pequeno' THEN 1 WHEN 'small' THEN 1
    WHEN 'grande' THEN -1 WHEN 'large' THEN -1
    WHEN 'enorme' THEN -2 WHEN 'huge' THEN -2
    WHEN 'imenso' THEN -4 WHEN 'gargantuan' THEN -4
    WHEN 'colossal' THEN -8
    ELSE 0 END
    INTO v_size_modifier
    FROM public.srd_races race
   WHERE race.id::text=v_sheet.raca_id::text;
  v_size_modifier:=COALESCE(v_size_modifier,0);

  IF EXISTS (
    SELECT 1 FROM public.campaigns camp
    CROSS JOIN LATERAL jsonb_array_elements(
      CASE WHEN jsonb_typeof(camp.cba_data->'tokens')='array'
           THEN camp.cba_data->'tokens' ELSE '[]'::jsonb END
    ) tok
    WHERE camp.id=p_campaign_id
      AND tok->>'tipo'='npc'
      AND tok->>'sourceCharacterId'=v_character.id::text
  ) THEN
    SELECT COALESCE(priv.srd_effective_modifier(
      p_campaign_id,'token',tok->>'id','ac'
    ),0)
    INTO v_effect_modifier
    FROM public.campaigns camp
    CROSS JOIN LATERAL jsonb_array_elements(
      CASE WHEN jsonb_typeof(camp.cba_data->'tokens')='array'
           THEN camp.cba_data->'tokens' ELSE '[]'::jsonb END
    ) tok
    WHERE camp.id=p_campaign_id
      AND tok->>'tipo'='npc'
      AND tok->>'sourceCharacterId'=v_character.id::text
    LIMIT 1;
  ELSE
    v_effect_modifier:=priv.srd_effective_modifier(
      p_campaign_id,'character',v_character.id::text,'ac'
    );
  END IF;
  -- Trap Sense é bônus de esquiva: não se aplica quando o personagem está
  -- desprevenido ou perde Destreza na CA por uma condição incapacitante.
  IF v_context='trap' AND NOT v_flatfooted AND NOT v_other_dex_loss THEN
    -- Sentido para Armadilhas de Bárbaro e Ladino não acumula entre si.
    v_trap_sense_bonus:=GREATEST(
      FLOOR(COALESCE(v_barbarian_level,0)/3.0)::integer,
      FLOOR(COALESCE(v_rogue_level,0)/3.0)::integer
    );
  END IF;

  v_final_ac:=GREATEST(1,10+v_armor_bonus+v_shield_bonus+v_dex_applied
    +v_size_modifier+v_effect_modifier+v_trap_sense_bonus);

  RETURN jsonb_build_object(
    'character_id',v_character.id::text,
    'base_ac',10,
    'armor_bonus',v_armor_bonus,
    'shield_bonus',v_shield_bonus,
    'dexterity_modifier',v_dex_modifier,
    'dexterity_applied',v_dex_applied,
    'dexterity_lost',v_lose_dex,
    'max_dexterity_bonus',v_max_dex,
    'size_modifier',v_size_modifier,
    'effect_modifier',v_effect_modifier,
    'trap_sense_bonus',v_trap_sense_bonus,
    'barbarian_level',COALESCE(v_barbarian_level,0),
    'rogue_level',COALESCE(v_rogue_level,0),
    'uncanny_dodge',v_uncanny_dodge,
    'improved_uncanny_dodge',v_improved_uncanny_dodge,
    'flatfooted',v_flatfooted,
    'final_ac',v_final_ac,
    'attack_context',v_context
  );
END;
$function$
;

-- srd_cancelar_movimento_aoo_pendente_impl(p_campaign_id bigint, p_pending_id uuid)
CREATE OR REPLACE FUNCTION priv.srd_cancelar_movimento_aoo_pendente_impl(p_campaign_id bigint, p_pending_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare v_pending priv.srd_aoo_pending_movements%rowtype; v_reactions jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode cancelar o movimento pendente.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where pending_id=p_pending_id and campaign_id=p_campaign_id for update;
  if not found then raise exception 'Movimento pendente não encontrado.'; end if;
  if v_pending.status not in ('waiting_reactions','ready_to_commit') then
    raise exception 'Este movimento não está mais pendente.';
  end if;
  update priv.srd_aoo_attacks set status='cancelled'
  where pending_id=p_pending_id
    and status in ('awaiting_attack_roll','awaiting_critical_confirmation','awaiting_miss_chance','awaiting_damage');
  select coalesce(jsonb_agg(
    case when r.value->>'status' in ('waiting','reserved','attack_started','hit_pending_damage')
      then r.value||jsonb_build_object('status','skipped','skip_reason','movement_cancelled')
      else r.value end order by r.ordinality),'[]'::jsonb)
  into v_reactions
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality r(value,ordinality);
  update priv.srd_aoo_pending_movements
  set status='cancelled',pending_reactions=v_reactions,cancelled_at=now(),updated_at=now()
  where pending_id=p_pending_id;
  return jsonb_build_object('cancelled',true,'pending_id',p_pending_id,
    'mover_token_id',v_pending.mover_token_id,'reactions',v_reactions);
end;
$function$
;

-- srd_clear_combat_flatfooted_actor(p_campaign_id bigint, p_actor jsonb)
CREATE OR REPLACE FUNCTION priv.srd_clear_combat_flatfooted_actor(p_campaign_id bigint, p_actor jsonb)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare v_kind text; v_id text; v_count integer;
begin
 if p_actor is null or jsonb_typeof(p_actor) is distinct from 'object' then return 0; end if;
 v_id:=nullif(btrim(p_actor->>'id'),'');
 if v_id is null then return 0; end if;
 v_kind:=case when coalesce((p_actor->>'is_monster')::boolean,false) then 'token' else 'character' end;
 update public.srd_campaign_conditions set active=false,
 notes=notes||jsonb_build_object('ended_reason','first_turn_started','ended_at',now())
 where campaign_id=p_campaign_id and target_kind=v_kind and target_id=v_id
 and condition_id='flatfooted' and active=true and notes->>'source_feature'='combat_flatfooted';
 get diagnostics v_count=row_count;
 return v_count;
end;
$function$
;

-- srd_clear_combat_flatfooted_all(p_campaign_id bigint)
CREATE OR REPLACE FUNCTION priv.srd_clear_combat_flatfooted_all(p_campaign_id bigint)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare v_count integer;
begin
 update public.srd_campaign_conditions set active=false,
 notes=notes||jsonb_build_object('ended_reason','combat_ended','ended_at',now())
 where campaign_id=p_campaign_id and active=true and condition_id='flatfooted'
 and notes->>'source_feature'='combat_flatfooted';
 get diagnostics v_count=row_count;
 return v_count;
end;
$function$
;

-- srd_condition_has_flag(p_campaign_id bigint, p_target_kind text, p_target_id text, p_flag text)
CREATE OR REPLACE FUNCTION priv.srd_condition_has_flag(p_campaign_id bigint, p_target_kind text, p_target_id text, p_flag text)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
 select exists (
   select 1
   from public.srd_campaign_conditions cc
   join priv.srd_condition_engine_rules r
     on r.condition_id=cc.condition_id and r.enabled
   where cc.campaign_id=p_campaign_id
     and cc.target_kind=p_target_kind
     and cc.target_id=p_target_id
     and cc.active
     and coalesce(r.flags->>p_flag,'false')='true'
 ) or exists (
   select 1
   from public.srd_campaign_effects e
   where e.campaign_id=p_campaign_id
     and e.target_kind=p_target_kind
     and e.target_id=p_target_id
     and e.active
     and coalesce(e.effect_data->'flags'->>p_flag,'false')='true'
 ) or exists (
   select 1
   from public.srd_campaign_conditions cc
   where cc.campaign_id=p_campaign_id
     and cc.target_kind=p_target_kind
     and cc.target_id=p_target_id
     and cc.condition_id='confused'
     and cc.active
     and (
       (p_flag='no_actions' and (
         nullif(cc.notes->>'confusion_pending_request_id','') is not null
         or cc.notes->>'confusion_last_outcome'='babble'
       ))
       or
       (p_flag='only_move_action' and cc.notes->>'confusion_last_outcome'='flee')
       or
       (p_flag='flee' and cc.notes->>'confusion_last_outcome'='flee')
     )
 );
$function$
;

-- srd_condition_modifier(p_campaign_id bigint, p_target_kind text, p_target_id text, p_stat text)
CREATE OR REPLACE FUNCTION priv.srd_condition_modifier(p_campaign_id bigint, p_target_kind text, p_target_id text, p_stat text)
 RETURNS integer
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  WITH active AS (
    SELECT cc.condition_id,r.stack_group,r.stack_rank,r.modifiers,
      row_number() OVER (PARTITION BY r.stack_group ORDER BY r.stack_rank DESC,cc.condition_instance_id DESC) stack_order
    FROM public.srd_campaign_conditions cc
    JOIN priv.srd_condition_engine_rules r ON r.condition_id=cc.condition_id AND r.enabled
    WHERE cc.campaign_id=p_campaign_id AND cc.target_kind=p_target_kind AND cc.target_id=p_target_id AND cc.active
  ), selected AS (
    SELECT * FROM active WHERE stack_group IS NULL OR stack_order=1
  )
  SELECT COALESCE(sum((m.value->>'value')::integer),0)::integer
  FROM selected a CROSS JOIN LATERAL jsonb_array_elements(a.modifiers) m(value)
  WHERE m.value->>'stat'=p_stat AND COALESCE(m.value->>'value','') ~ '^-?[0-9]{1,3}$';
$function$
;

-- srd_condition_speed_multiplier(p_campaign_id bigint, p_target_kind text, p_target_id text)
CREATE OR REPLACE FUNCTION priv.srd_condition_speed_multiplier(p_campaign_id bigint, p_target_kind text, p_target_id text)
 RETURNS numeric
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  SELECT COALESCE(min(r.speed_multiplier),1)::numeric
  FROM public.srd_campaign_conditions cc
  JOIN priv.srd_condition_engine_rules r ON r.condition_id=cc.condition_id AND r.enabled
  WHERE cc.campaign_id=p_campaign_id AND cc.target_kind=p_target_kind AND cc.target_id=p_target_id
    AND cc.active AND r.speed_multiplier IS NOT NULL;
$function$
;

-- srd_confusion_aoo_engaged(p_campaign_id bigint, p_actor_token_id text, p_actor_character_id text, p_mover_token_id text)
CREATE OR REPLACE FUNCTION priv.srd_confusion_aoo_engaged(p_campaign_id bigint, p_actor_token_id text, p_actor_character_id text, p_mover_token_id text)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
 with current_round as (
   select greatest(0,coalesce(nullif(combat_data->>'round','')::integer,0)) round_no
   from public.campaigns where id=p_campaign_id
 )
 select exists(
   select 1 from public.srd_attack_sequences s,current_round r
   where s.campaign_id=p_campaign_id
     and s.round_number between greatest(0,r.round_no-1) and r.round_no
     and (
       (p_actor_character_id is not null and s.actor_character_id::text=p_actor_character_id
          and s.target_token_id=p_mover_token_id)
       or
       (p_mover_token_id ~ '^[0-9]+$' and s.actor_character_id::text=p_mover_token_id
          and s.target_token_id=p_actor_token_id)
     )
 ) or exists(
   select 1 from public.srd_npc_attack_sequences s,current_round r
   where s.campaign_id=p_campaign_id
     and s.round_number between greatest(0,r.round_no-1) and r.round_no
     and (
       (s.actor_token_id=p_actor_token_id and s.target_token_id=p_mover_token_id)
       or (s.actor_token_id=p_mover_token_id and s.target_token_id=p_actor_token_id)
     )
 );
$function$
;

-- srd_confusion_attack_target_allowed(p_campaign_id bigint, p_actor_kind text, p_actor_id text, p_target_token_id text)
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

-- srd_confusion_flee_destination_allowed(p_campaign_id bigint, p_actor_token_id text, p_destination_x integer, p_destination_y integer)
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

-- srd_confusion_nearest_target_id(p_campaign_id bigint, p_actor_token_id text)
CREATE OR REPLACE FUNCTION priv.srd_confusion_nearest_target_id(p_campaign_id bigint, p_actor_token_id text)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
 v_actor jsonb;
 v_candidate jsonb;
 v_min_distance integer;
 v_distance integer;
 v_tied text[]:=ARRAY[]::text[];
 v_token_id text;
BEGIN
 SELECT t.token INTO v_actor
 FROM jsonb_array_elements(coalesce((SELECT c.cba_data->'tokens' FROM public.campaigns c WHERE c.id=p_campaign_id),'[]'::jsonb)) t(token)
 WHERE t.token->>'id'=btrim(p_actor_token_id)
   AND coalesce(t.token->>'gridX','') ~ '^-?[0-9]+$'
   AND coalesce(t.token->>'gridY','') ~ '^-?[0-9]+$'
 LIMIT 1;
 IF v_actor IS NULL THEN RETURN NULL; END IF;
 FOR v_candidate IN
   SELECT t.token
   FROM jsonb_array_elements(coalesce((SELECT c.cba_data->'tokens' FROM public.campaigns c WHERE c.id=p_campaign_id),'[]'::jsonb)) t(token)
   WHERE t.token->>'id' IS NOT NULL
     AND t.token->>'tipo' IN ('player','npc','monstro')
     AND t.token->>'id'<>btrim(p_actor_token_id)
     AND coalesce(t.token->>'gridX','') ~ '^-?[0-9]+$'
     AND coalesce(t.token->>'gridY','') ~ '^-?[0-9]+$'
 LOOP
   v_distance:=priv.srd_grid_footprint_distance_ft(
     (v_actor->>'gridX')::integer,(v_actor->>'gridY')::integer,
     priv.srd_token_grid_footprint(p_campaign_id,p_actor_token_id),
     (v_candidate->>'gridX')::integer,(v_candidate->>'gridY')::integer,
     priv.srd_token_grid_footprint(p_campaign_id,v_candidate->>'id')
   );
   IF v_min_distance IS NULL OR v_distance<v_min_distance THEN
     v_min_distance:=v_distance;
     v_tied:=ARRAY[v_candidate->>'id'];
   ELSIF v_distance=v_min_distance THEN
     v_tied:=array_append(v_tied,v_candidate->>'id');
   END IF;
 END LOOP;
 IF cardinality(v_tied)=0 THEN RETURN NULL; END IF;
 RETURN v_tied[1+floor(random()*cardinality(v_tied))::integer];
END;
$function$
;

-- srd_effect_has_flag(p_campaign_id bigint, p_target_kind text, p_target_id text, p_flag text)
CREATE OR REPLACE FUNCTION priv.srd_effect_has_flag(p_campaign_id bigint, p_target_kind text, p_target_id text, p_flag text)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  SELECT EXISTS(
    SELECT 1 FROM public.srd_campaign_effects e
    WHERE e.campaign_id=p_campaign_id AND e.target_kind=p_target_kind AND e.target_id=p_target_id
      AND e.active=true AND COALESCE(e.effect_data->'flags'->>p_flag,'false')='true'
  );
$function$
;

-- srd_effective_modifier(p_campaign_id bigint, p_target_kind text, p_target_id text, p_stat text)
CREATE OR REPLACE FUNCTION priv.srd_effective_modifier(p_campaign_id bigint, p_target_kind text, p_target_id text, p_stat text)
 RETURNS integer
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  WITH modifiers AS (
    SELECT COALESCE(NULLIF(m.value->>'bonus_type',''),'untyped') bonus_type,
           (m.value->>'value')::integer value
    FROM public.srd_campaign_effects e
    CROSS JOIN LATERAL jsonb_array_elements(
      CASE WHEN jsonb_typeof(e.effect_data->'modifiers')='array' THEN e.effect_data->'modifiers' ELSE '[]'::jsonb END
    ) m(value)
    WHERE e.campaign_id=p_campaign_id AND e.target_kind=p_target_kind AND e.target_id=p_target_id AND e.active
      AND m.value->>'stat'=p_stat AND COALESCE(m.value->>'value','') ~ '^-?[0-9]{1,3}$'
  ), positive_typed AS (
    SELECT bonus_type,max(value) value FROM modifiers
    WHERE value>0 AND bonus_type NOT IN ('untyped','dodge','circumstance') GROUP BY bonus_type
  )
  SELECT COALESCE((SELECT sum(value) FROM positive_typed),0)
       + COALESCE((SELECT sum(value) FROM modifiers WHERE value>0 AND bonus_type IN ('untyped','dodge','circumstance')),0)
       + COALESCE((SELECT sum(value) FROM modifiers WHERE value<0),0)
       + COALESCE(priv.srd_condition_modifier(p_campaign_id,p_target_kind,p_target_id,p_stat),0);
$function$
;

-- srd_effective_token_speed_m(p_campaign_id bigint, p_token_id text)
CREATE OR REPLACE FUNCTION priv.srd_effective_token_speed_m(p_campaign_id bigint, p_token_id text)
 RETURNS numeric
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_token jsonb;
  v_count integer;
  v_type text;
  v_character_id text;
  v_base_speed numeric;
  v_speed_text text;
  v_speed_number text;
  v_speed numeric;
  v_target_kind text;
BEGIN
  SELECT count(*)::integer,(array_agg(t))[1]
    INTO v_count,v_token
    FROM jsonb_array_elements(COALESCE((SELECT cba_data->'tokens' FROM public.campaigns WHERE id=p_campaign_id),'[]'::jsonb)) t
   WHERE t->>'id'=btrim(p_token_id) OR t->>'key'=btrim(p_token_id);
  IF v_count<>1 THEN RAISE EXCEPTION 'Token inexistente ou duplicado ao calcular deslocamento.'; END IF;

  v_type:=v_token->>'tipo';
  v_character_id:=COALESCE(NULLIF(btrim(v_token->>'sourceCharacterId'),''),CASE WHEN v_type='player' THEN btrim(p_token_id) END);
  v_target_kind:=CASE WHEN v_type='player' THEN 'character' ELSE 'token' END;

  IF v_character_id IS NOT NULL THEN
    SELECT race.deslocamento::numeric
      INTO v_base_speed
      FROM public.srd_character_sheets sheet
      JOIN public.srd_races race ON race.id::text=sheet.raca_id::text
     WHERE sheet.character_id::text=v_character_id;
    IF v_base_speed IS NOT NULL THEN
      v_speed:=public.srd35_deslocamento_personagem(v_character_id,v_base_speed);
      IF v_type<>'player' THEN
        v_speed:=v_speed*priv.srd_condition_speed_multiplier(p_campaign_id,'token',btrim(p_token_id));
      ELSE
        v_speed:=v_speed*priv.srd_condition_speed_multiplier(p_campaign_id,'character',v_character_id);
      END IF;
      RETURN GREATEST(0,COALESCE(v_speed,0));
    END IF;
  END IF;

  v_speed_text:=COALESCE(
    NULLIF(v_token->>'deslocamento_m',''),
    NULLIF(v_token->'monsterStats'->>'deslocamento',''),
    NULLIF(v_token->'monsterStats'->>'speed',''),
    NULLIF(v_token->>'speed_m','')
  );
  IF v_speed_text IS NULL THEN
    v_speed:=9;
  ELSE
    v_speed_number:=substring(v_speed_text FROM '([0-9]+([.][0-9]+)?)');
    IF v_speed_number IS NULL THEN RAISE EXCEPTION 'Não foi possível interpretar o deslocamento do token %.',p_token_id; END IF;
    v_speed:=v_speed_number::numeric;
    IF lower(v_speed_text) ~ '(ft|feet|foot|p[eé]s|pé)' THEN v_speed:=v_speed*0.3048; END IF;
  END IF;
  v_speed:=v_speed*priv.srd_condition_speed_multiplier(p_campaign_id,'token',btrim(p_token_id));
  RETURN GREATEST(0,COALESCE(v_speed,0));
END;
$function$
;

-- srd_encerrar_reacao_aoo_pendente_impl(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_cancel_attack boolean)
CREATE OR REPLACE FUNCTION priv.srd_encerrar_reacao_aoo_pendente_impl(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_cancel_attack boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_idx bigint;
  v_reaction jsonb;
  v_attack priv.srd_aoo_attacks%rowtype;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode encerrar uma reação pendente.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then
    raise exception 'Movimento não está aguardando reações.';
  end if;
  select ordinality,value into v_idx,v_reaction
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality
  where value->>'reactor_token_id'=btrim(p_reactor_token_id) limit 1;
  if v_reaction is null then raise exception 'Reação não encontrada neste movimento.'; end if;
  if v_reaction->>'status' in ('attack_started','hit_pending_damage') then
    if not p_cancel_attack then
      raise exception 'O ataque já começou; resolva-o ou autorize explicitamente seu cancelamento.';
    end if;
    select * into v_attack from priv.srd_aoo_attacks
    where attack_id=(v_reaction->>'attack_id')::uuid and campaign_id=p_campaign_id for update;
    if not found or v_attack.status not in ('awaiting_attack_roll','awaiting_critical_confirmation','awaiting_miss_chance','awaiting_damage') then
      raise exception 'Ataque não pode ser cancelado neste estado.';
    end if;
    update priv.srd_aoo_attacks set status='cancelled' where attack_id=v_attack.attack_id;
  elsif v_reaction->>'status' not in ('waiting','reserved') then
    raise exception 'Esta reação já foi encerrada.';
  end if;
  update priv.srd_aoo_pending_movements
  set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_idx-1)::text],
      v_reaction||jsonb_build_object('status','skipped','skip_reason',case
        when v_reaction->>'status' in ('reserved','attack_started','hit_pending_damage')
          then 'gm_cancelled_after_reservation' else 'gm_declined_reaction' end),
      false),updated_at=now()
  where pending_id=p_pending_id;
  return jsonb_build_object('closed',true,'pending_id',p_pending_id,
    'reactor_token_id',p_reactor_token_id,'reaction_spent',
    (v_reaction->>'status') in ('reserved','attack_started','hit_pending_damage'));
end;
$function$
;

-- srd_end_barbarian_rage(p_campaign_id bigint, p_character_id text, p_apply_fatigue boolean)
CREATE OR REPLACE FUNCTION priv.srd_end_barbarian_rage(p_campaign_id bigint, p_character_id text, p_apply_fatigue boolean DEFAULT true)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_effect public.srd_campaign_effects%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_barbarian_level integer := 0;
  v_hp_bonus integer := 0;
  v_new_hp integer;
  v_new_max integer;
  v_condition_id text;
BEGIN
  SELECT * INTO v_effect
    FROM public.srd_campaign_effects
   WHERE campaign_id=p_campaign_id
     AND target_kind='character'
     AND target_id=BTRIM(p_character_id)
     AND active=true
     AND effect_data->>'source_feature'='barbarian_rage'
   ORDER BY effect_instance_id DESC
   LIMIT 1
   FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('ended',false,'reason','rage_not_active');
  END IF;

  IF COALESCE(v_effect.effect_data->>'rage_hp_bonus','') ~ '^[0-9]{1,6}$' THEN
    v_hp_bonus := (v_effect.effect_data->>'rage_hp_bonus')::integer;
  END IF;

  UPDATE public.srd_campaign_effects
     SET active=false
   WHERE effect_instance_id=v_effect.effect_instance_id;

  SELECT * INTO v_sheet
    FROM public.srd_character_sheets
   WHERE character_id::text=BTRIM(p_character_id)
   FOR UPDATE;

  IF FOUND THEN
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

    UPDATE public.srd_character_sheets
       SET pv_max=GREATEST(1,COALESCE(pv_max,1)-v_hp_bonus),
           pv_atual=GREATEST(-10,COALESCE(pv_atual,pv_max)-v_hp_bonus)
     WHERE character_id=v_sheet.character_id
     RETURNING pv_atual,pv_max INTO v_new_hp,v_new_max;

    PERFORM priv.srd_sync_character_vital_condition(BTRIM(p_character_id),v_new_hp,false);
  END IF;

  IF p_apply_fatigue AND COALESCE(v_barbarian_level,0)<17 THEN
    IF EXISTS (
      SELECT 1 FROM public.srd_campaign_conditions
       WHERE campaign_id=p_campaign_id AND target_kind='character'
         AND target_id=BTRIM(p_character_id) AND condition_id='exhausted' AND active=true
    ) THEN
      v_condition_id := NULL;
    ELSIF EXISTS (
      SELECT 1 FROM public.srd_campaign_conditions
       WHERE campaign_id=p_campaign_id AND target_kind='character'
         AND target_id=BTRIM(p_character_id) AND condition_id='fatigued' AND active=true
    ) THEN
      v_condition_id := 'exhausted';
    ELSE
      v_condition_id := 'fatigued';
    END IF;

    IF v_condition_id IS NOT NULL THEN
      IF v_condition_id='exhausted' THEN
        UPDATE public.srd_campaign_conditions SET active=false
         WHERE campaign_id=p_campaign_id AND target_kind='character'
           AND target_id=BTRIM(p_character_id) AND condition_id='fatigued' AND active=true;
      END IF;
      PERFORM priv.srd_apply_campaign_condition(
        p_campaign_id,'character',BTRIM(p_character_id),v_condition_id,NULL,
        jsonb_build_object('source_feature','barbarian_rage','reason','rage_ended'),NULL
      );
    END IF;
  END IF;

  RETURN jsonb_build_object(
    'ended',true,
    'effect_instance_id',v_effect.effect_instance_id,
    'barbarian_level',COALESCE(v_barbarian_level,0),
    'rage_hp_removed',v_hp_bonus,
    'pv_atual',v_new_hp,
    'pv_max',v_new_max,
    'fatigue_applied',p_apply_fatigue AND COALESCE(v_barbarian_level,0)<17
  );
END;
$function$
;

-- srd_end_barbarian_rage_token(p_campaign_id bigint, p_token_id text, p_apply_fatigue boolean)
CREATE OR REPLACE FUNCTION priv.srd_end_barbarian_rage_token(p_campaign_id bigint, p_token_id text, p_apply_fatigue boolean DEFAULT true)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
 v_effect public.srd_campaign_effects%ROWTYPE;
 v_campaign public.campaigns%ROWTYPE;
 v_tokens jsonb;
 v_token_count integer;
 v_token_index bigint;
 v_token jsonb;
 v_hp integer;
 v_max_hp integer;
 v_bonus integer:=0;
 v_new_hp integer;
 v_new_max integer;
 v_level integer:=0;
 v_condition text;
 v_source_id text;
 v_sheet public.srd_character_sheets%ROWTYPE;
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
 IF COALESCE(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' OR COALESCE(v_token->>'hp','') !~ '^-?[0-9]{1,6}$' THEN
   RAISE EXCEPTION 'PV do token NPC inválidos; Fúria não foi encerrada.';
 END IF;
 v_max_hp:=(v_token->>'maxHp')::integer; v_hp:=(v_token->>'hp')::integer;
 v_new_max:=GREATEST(1,v_max_hp-v_bonus);
 v_new_hp:=GREATEST(-10,LEAST(v_new_max,v_hp));
 v_level:=COALESCE(NULLIF(v_effect.effect_data->>'rage_level','')::integer,0);
 v_source_id:=NULLIF(BTRIM(v_token->>'sourceCharacterId'),'');
 UPDATE public.srd_campaign_effects SET active=false WHERE effect_instance_id=v_effect.effect_instance_id;
 SELECT COALESCE(jsonb_agg(CASE WHEN t.ordinality=v_token_index
   THEN t.token||jsonb_build_object('hp',v_new_hp,'maxHp',v_new_max) ELSE t.token END ORDER BY t.ordinality),'[]'::jsonb)
 INTO v_tokens FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality);
 UPDATE public.campaigns SET cba_data=COALESCE(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens) WHERE id=p_campaign_id;
 PERFORM priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,v_new_hp,v_new_max,EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='token' AND cc.target_id=p_token_id AND cc.condition_id='stable' AND cc.active=true));
 IF v_source_id IS NOT NULL AND v_source_id ~ '^[0-9]+$' THEN
   SELECT * INTO v_sheet FROM public.srd_character_sheets WHERE character_id::text=v_source_id FOR UPDATE;
   IF FOUND THEN
     UPDATE public.srd_character_sheets SET pv_max=v_new_max,pv_atual=LEAST(v_new_max,v_new_hp)
      WHERE character_id=v_sheet.character_id;
   END IF;
 END IF;
 IF p_apply_fatigue AND v_level<17 THEN
   IF EXISTS(SELECT 1 FROM public.srd_campaign_conditions WHERE campaign_id=p_campaign_id AND target_kind='token'
     AND target_id=BTRIM(p_token_id) AND condition_id='exhausted' AND active) THEN v_condition:=NULL;
   ELSIF EXISTS(SELECT 1 FROM public.srd_campaign_conditions WHERE campaign_id=p_campaign_id AND target_kind='token'
     AND target_id=BTRIM(p_token_id) AND condition_id='fatigued' AND active) THEN v_condition:='exhausted';
   ELSE v_condition:='fatigued'; END IF;
   IF v_condition IS NOT NULL THEN
     IF v_condition='exhausted' THEN UPDATE public.srd_campaign_conditions SET active=false
      WHERE campaign_id=p_campaign_id AND target_kind='token' AND target_id=BTRIM(p_token_id) AND condition_id='fatigued' AND active; END IF;
     PERFORM priv.srd_apply_campaign_condition(p_campaign_id,'token',BTRIM(p_token_id),v_condition,NULL,
      jsonb_build_object('source_feature','barbarian_rage','reason','rage_ended'),NULL);
   END IF;
 END IF;
 SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id;
 RETURN jsonb_build_object('ended',true,'rage_hp_removed',v_bonus,'hp',v_new_hp,'max_hp',v_new_max,
  'source_character_id',v_source_id,'fatigue_applied',p_apply_fatigue AND v_level<17,'cba_data',v_campaign.cba_data);
END;
$function$
;

-- srd_expire_barbarian_rage_on_round_change()
CREATE OR REPLACE FUNCTION priv.srd_expire_barbarian_rage_on_round_change()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_old_round integer;
  v_new_round integer;
  v_rage record;
  v_result jsonb;
BEGIN
  IF TG_OP <> 'UPDATE'
     OR UPPER(COALESCE(OLD.state,'')) <> 'COMBATE'
     OR UPPER(COALESCE(NEW.state,'')) <> 'COMBATE'
     OR COALESCE(NEW.combat_data->>'active','false') <> 'true'
     OR COALESCE(OLD.combat_data->>'round','') !~ '^[0-9]+$'
     OR COALESCE(NEW.combat_data->>'round','') !~ '^[0-9]+$' THEN
    RETURN NEW;
  END IF;

  v_old_round := (OLD.combat_data->>'round')::integer;
  v_new_round := (NEW.combat_data->>'round')::integer;
  IF v_new_round <= v_old_round THEN
    RETURN NEW;
  END IF;

  FOR v_rage IN
    SELECT effect_instance_id, target_id
      FROM public.srd_campaign_effects
     WHERE campaign_id=NEW.id
       AND target_kind='character'
       AND active=true
       AND effect_data->>'source_feature'='barbarian_rage'
       AND expires_round IS NOT NULL
       AND expires_round <= v_new_round
     ORDER BY effect_instance_id
     FOR UPDATE
  LOOP
    v_result := priv.srd_end_barbarian_rage(NEW.id,v_rage.target_id,true);
    IF COALESCE((v_result->>'ended')::boolean,false) THEN
      PERFORM priv.log(NEW.id,'CLASS_FEATURE',jsonb_build_object(
        'feature_key','barbarian_rage',
        'action','expire',
        'character_id',v_rage.target_id,
        'effect_instance_id',v_rage.effect_instance_id,
        'round',v_new_round,
        'rage_hp_removed',v_result->'rage_hp_removed',
        'fatigue_applied',v_result->'fatigue_applied'
      ));
    END IF;
  END LOOP;

  FOR v_rage IN
    SELECT effect_instance_id, target_id
      FROM public.srd_campaign_effects
     WHERE campaign_id=NEW.id
       AND target_kind='token'
       AND active=true
       AND effect_data->>'source_feature'='barbarian_rage'
       AND expires_round IS NOT NULL
       AND expires_round <= v_new_round
     ORDER BY effect_instance_id
     FOR UPDATE
  LOOP
    v_result := priv.srd_end_barbarian_rage_token(NEW.id,v_rage.target_id,true);
    IF COALESCE((v_result->>'ended')::boolean,false) THEN
      PERFORM priv.log(NEW.id,'CLASS_FEATURE',jsonb_build_object(
        'feature_key','barbarian_rage',
        'action','expire',
        'token_id',v_rage.target_id,
        'effect_instance_id',v_rage.effect_instance_id,
        'round',v_new_round,
        'rage_hp_removed',v_result->'rage_hp_removed',
        'fatigue_applied',v_result->'fatigue_applied'
      ));
    END IF;
  END LOOP;

  RETURN NEW;
END;
$function$
;

-- srd_feat_saving_throw_modifier(p_feats jsonb, p_save text)
CREATE OR REPLACE FUNCTION priv.srd_feat_saving_throw_modifier(p_feats jsonb, p_save text)
 RETURNS integer
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  WITH selected_feats AS (
    SELECT DISTINCT feat.id, feat.mechanics
    FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(p_feats)='array' THEN p_feats ELSE '[]'::jsonb END
    ) AS selected(value)
    JOIN public.srd_feats feat
      ON feat.id=COALESCE(selected.value->>'id',selected.value #>> '{}')
    WHERE feat.mechanics->>'engine_status' IN ('ready','implemented')
      AND feat.mechanics #>> '{activation,mode}'='passive'
  ),
  feat_modifiers AS (
    SELECT selected_feats.id AS feat_id,
           COALESCE(NULLIF(eff.elem->>'bonus_type',''),'untyped') AS bonus_type,
           MAX((eff.elem->>'value')::numeric) AS feat_value
    FROM selected_feats
    CROSS JOIN LATERAL jsonb_array_elements(
      CASE WHEN jsonb_typeof(selected_feats.mechanics #> '{resolution,effects}')='array'
           THEN selected_feats.mechanics #> '{resolution,effects}' ELSE '[]'::jsonb END
    ) AS eff(elem)
    WHERE eff.elem->>'kind'='modifier'
      AND eff.elem->>'stat'=lower(COALESCE(p_save,''))
      AND COALESCE(eff.elem->>'value','') ~ '^-?[0-9]{1,3}$'
    GROUP BY selected_feats.id,COALESCE(NULLIF(eff.elem->>'bonus_type',''),'untyped')
  ),
  grouped AS (
    SELECT bonus_type,
           CASE WHEN bonus_type IN ('untyped','dodge','circumstance')
                THEN SUM(feat_value) ELSE MAX(feat_value) END AS total_value
    FROM feat_modifiers
    GROUP BY bonus_type
  )
  SELECT COALESCE(SUM(total_value),0)::integer
  FROM grouped;
$function$
;

-- srd_grid_footprint_distance_ft(p_ax integer, p_ay integer, p_asize integer, p_bx integer, p_by integer, p_bsize integer)
CREATE OR REPLACE FUNCTION priv.srd_grid_footprint_distance_ft(p_ax integer, p_ay integer, p_asize integer, p_bx integer, p_by integer, p_bsize integer)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
 SET search_path TO 'pg_catalog', 'pg_temp'
AS $function$
  with gaps as (
    select greatest(0,p_bx-(p_ax+p_asize-1),p_ax-(p_bx+p_bsize-1)) dx,
           greatest(0,p_by-(p_ay+p_asize-1),p_ay-(p_by+p_bsize-1)) dy
  )
  select (greatest(dx,dy)*5 + floor(least(dx,dy)::numeric/2)*5)::integer
  from gaps;
$function$
;

-- srd_guard_aoo_cannot_attack()
CREATE OR REPLACE FUNCTION priv.srd_guard_aoo_cannot_attack()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
begin
  if new.status in ('awaiting_attack_roll','awaiting_critical_confirmation','awaiting_miss_chance','awaiting_damage') then
    if priv.srd_condition_has_flag(new.campaign_id,'token',new.actor_token_id,'cannot_attack')
      or (new.actor_character_id is not null and
        priv.srd_condition_has_flag(new.campaign_id,'character',new.actor_character_id::text,'cannot_attack')) then
      raise exception 'A condição atual impede realizar este ataque de oportunidade.';
    end if;
  end if;
  return new;
end;
$function$
;

-- srd_guard_pending_aoo_movement()
CREATE OR REPLACE FUNCTION priv.srd_guard_pending_aoo_movement()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_old_token jsonb;
  v_new_token jsonb;
  v_commit_id text;
begin
  if new.cba_data is not distinct from old.cba_data then return new; end if;
  select * into v_pending
  from priv.srd_aoo_pending_movements p
  where p.campaign_id=new.id
    and p.status in ('waiting_reactions','ready_to_commit')
  order by p.created_at desc limit 1;
  if not found then return new; end if;

  select t into v_old_token
  from jsonb_array_elements(case when jsonb_typeof(old.cba_data->'tokens')='array'
    then old.cba_data->'tokens' else '[]'::jsonb end) t
  where t->>'id'=v_pending.mover_token_id or t->>'key'=v_pending.mover_token_id
  limit 1;
  select t into v_new_token
  from jsonb_array_elements(case when jsonb_typeof(new.cba_data->'tokens')='array'
    then new.cba_data->'tokens' else '[]'::jsonb end) t
  where t->>'id'=v_pending.mover_token_id or t->>'key'=v_pending.mover_token_id
  limit 1;

  v_commit_id:=current_setting('app.srd_aoo_pending_commit',true);

  if v_old_token is not null and v_new_token is null
     and v_commit_id is distinct from v_pending.pending_id::text then
    raise exception 'Remoção do token bloqueada: há um movimento aguardando resolução de ataques de oportunidade.';
  end if;

  if v_old_token is not null and v_new_token is not null
     and ((v_old_token->>'gridX') is distinct from (v_new_token->>'gridX')
       or (v_old_token->>'gridY') is distinct from (v_new_token->>'gridY')) then
    if v_commit_id is distinct from v_pending.pending_id::text then
      raise exception 'Movimento bloqueado: há um ataque de oportunidade pendente de resolução.';
    end if;
  end if;
  return new;
end;
$function$
;

-- srd_iniciar_derrubar_com_aoo_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_defender_firm_ground boolean, p_trip_using_weapon boolean)
CREATE OR REPLACE FUNCTION priv.srd_iniciar_derrubar_com_aoo_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_defender_firm_ground boolean DEFAULT false, p_trip_using_weapon boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_campaign public.campaigns%ROWTYPE;
  v_combat jsonb;
  v_order jsonb;
  v_actor jsonb;
  v_calc jsonb;
  v_attacker jsonb;
  v_defender jsonb;
  v_round integer;
  v_turn integer;
  v_pending_id uuid:=gen_random_uuid();
  v_distance integer;
  v_reach integer:=5;
  v_profile jsonb;
  v_character_id bigint;
  v_reach_match text[];
  v_reaction_status text:='waiting';
  v_trigger text;
  v_has_threatening_weapon boolean:=false;
  v_has_unarmed_threat boolean:=false;
  v_size_rank integer:=4;
  v_base_reach integer:=5;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode preparar a reação de Derrubar.';
  END IF;
  IF NULLIF(BTRIM(p_attacker_token_id),'') IS NULL OR NULLIF(BTRIM(p_defender_token_id),'') IS NULL
     OR BTRIM(p_attacker_token_id)=BTRIM(p_defender_token_id) THEN
    RAISE EXCEPTION 'Atacante e defensor precisam ser tokens diferentes.';
  END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND OR upper(coalesce(v_campaign.state,''))<>'COMBATE'
     OR coalesce(v_campaign.combat_data->>'active','false')<>'true' THEN
    RAISE EXCEPTION 'A iniciativa precisa estar ativa.';
  END IF;
  v_combat:=v_campaign.combat_data;
  IF coalesce(v_combat->'surprise'->>'phase','normal')='surprise_round' THEN
    RAISE EXCEPTION 'Derrubar não pode ser iniciado durante a rodada surpresa.';
  END IF;
  IF coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$' THEN
    RAISE EXCEPTION 'Turno atual inválido.';
  END IF;
  v_turn:=(v_combat->>'current_turn')::integer;
  v_order:=CASE WHEN jsonb_typeof(v_combat->'turn_order')='array' THEN v_combat->'turn_order' ELSE '[]'::jsonb END;
  v_actor:=v_order->v_turn;
  IF v_actor->>'id' IS DISTINCT FROM BTRIM(p_attacker_token_id) THEN
    RAISE EXCEPTION 'O atacante precisa estar no turno ativo.';
  END IF;
  IF EXISTS (SELECT 1 FROM priv.srd_aoo_pending_movements
    WHERE campaign_id=p_campaign_id AND status IN ('waiting_reactions','ready_to_commit')) THEN
    RAISE EXCEPTION 'Já existe outra reação de oportunidade pendente nesta campanha.';
  END IF;
  v_calc:=public.srd_consultar_modificadores_manobra_srd(
    p_campaign_id,p_attacker_token_id,p_defender_token_id,'trip',
    coalesce(p_defender_firm_ground,false),coalesce(p_trip_using_weapon,false)
  );
  IF v_calc->>'aoo_status'<>'provokes' THEN
    RAISE EXCEPTION 'Esta tentativa não exige a fila de reação de Derrubar; consulte os modificadores e resolva pelo fluxo normal.';
  END IF;

  SELECT t INTO v_attacker FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
   WHERE t->>'id'=BTRIM(p_attacker_token_id) OR t->>'key'=BTRIM(p_attacker_token_id) LIMIT 1;
  SELECT t INTO v_defender FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
   WHERE t->>'id'=BTRIM(p_defender_token_id) OR t->>'key'=BTRIM(p_defender_token_id) LIMIT 1;
  IF v_attacker IS NULL OR v_defender IS NULL THEN
    RAISE EXCEPTION 'Atacante ou defensor não está na cena.';
  END IF;
  IF coalesce(v_attacker->>'gridX','') !~ '^[0-9]{1,3}$' OR coalesce(v_attacker->>'gridY','') !~ '^[0-9]{1,3}$'
     OR coalesce(v_defender->>'gridX','') !~ '^[0-9]{1,3}$' OR coalesce(v_defender->>'gridY','') !~ '^[0-9]{1,3}$' THEN
    RAISE EXCEPTION 'A posição de um dos tokens não é válida para medir alcance.';
  END IF;

  v_distance:=priv.srd_grid_footprint_distance_ft(
    (v_defender->>'gridX')::integer,(v_defender->>'gridY')::integer,
    priv.srd_token_grid_footprint(p_campaign_id,p_defender_token_id),
    (v_attacker->>'gridX')::integer,(v_attacker->>'gridY')::integer,
    priv.srd_token_grid_footprint(p_campaign_id,p_attacker_token_id)
  );
  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,BTRIM(p_defender_token_id));
  v_character_id:=NULLIF(v_profile->>'character_id','')::bigint;
  v_size_rank:=coalesce(nullif(v_profile->>'size_rank','')::integer,4);
  v_base_reach:=CASE
    WHEN v_size_rank>=8 THEN 30
    WHEN v_size_rank=7 THEN 20
    WHEN v_size_rank=6 THEN 15
    WHEN v_size_rank=5 THEN 10
    ELSE 5
  END;

  IF v_character_id IS NOT NULL THEN
    SELECT coalesce(bool_or(
      coalesce((eq.detalhes->>'threatens_squares')::boolean,true)
      AND v_distance BETWEEN
        CASE
          WHEN coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5)>5 AND v_size_rank>4
            THEN v_base_reach+5
          ELSE greatest(5,coalesce(nullif(eq.detalhes->>'threat_min_ft','')::integer,5))
        END
        AND CASE
          WHEN coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5)>5 AND v_size_rank>4
            THEN coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5)*greatest(1,v_base_reach/5)
          ELSE greatest(coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5),v_base_reach)
        END
    ),false),
    coalesce(max(
      CASE
        WHEN coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5)>5 AND v_size_rank>4
          THEN coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5)*greatest(1,v_base_reach/5)
        ELSE greatest(coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5),v_base_reach)
      END
    ),v_base_reach)
      INTO v_has_threatening_weapon,v_reach
      FROM public.srd_character_weapon_instances wi
      JOIN public.srd_equipment eq ON eq.id=wi.equipment_id
      JOIN public.srd_character_equipment ce
        ON ce.character_id=wi.character_id AND ce.equipment_id=wi.equipment_id
       AND ce.equipado IS TRUE AND ce.hand_slot=wi.hand_slot
     WHERE wi.character_id=v_character_id::text AND wi.equipado IS TRUE
       AND wi.hand_slot IN ('main_hand','off_hand')
       AND coalesce(eq.detalhes->>'weapon_melee','true')<>'false';
    IF NOT v_has_threatening_weapon THEN
      SELECT coalesce(cl.class_key='monk',false) OR EXISTS (
        SELECT 1
        FROM jsonb_array_elements(
          CASE WHEN jsonb_typeof(sh.talentos)='array' THEN sh.talentos ELSE '[]'::jsonb END
        ) feat
        WHERE lower(concat_ws(' ',feat->>'id',feat->>'nome',feat->>'name')) ~
          '(ataque_desarmado_aprimorado|srd35_feat_improved_unarmed_strike|improved_unarmed_strike|ataque desarmado aprimorado|improved unarmed strike)'
      )
      INTO v_has_unarmed_threat
      FROM public.srd_character_sheets sh
      JOIN public.srd_classes cl ON cl.id=sh.classe_id
      WHERE sh.character_id=v_character_id;

      IF v_has_unarmed_threat AND v_distance BETWEEN 5 AND v_base_reach THEN
        v_has_threatening_weapon:=true;
        v_reach:=v_base_reach;
      ELSE
        v_reaction_status:='ineligible';
      END IF;
    END IF;
  ELSE
    v_reach:=greatest(v_base_reach,coalesce(nullif(v_defender->>'melee_reach_ft','')::integer,5));
    v_reach_match:=regexp_match(
      coalesce(v_defender->'monsterStats'->>'espaco_alcance',v_defender->'monsterStats'->>'space_reach',''),
      '([0-9]+)[[:space:]]*ft[^0-9]*([0-9]+)','i'
    );
    IF v_reach_match IS NOT NULL THEN v_reach:=greatest(v_reach,v_reach_match[2]::integer); END IF;
    IF v_distance>v_reach THEN v_reaction_status:='ineligible'; END IF;
  END IF;

  v_round:=greatest(1,coalesce(nullif(v_combat->>'round','')::integer,1));
  v_trigger:='trip:'||v_pending_id::text;
  INSERT INTO priv.srd_aoo_pending_movements(
    pending_id,campaign_id,mover_token_id,movement_controller,destination_x,destination_y,
    origin_x,origin_y,combat_round,current_turn,turn_actor_id,threats,pending_reactions,
    status,created_by
  ) VALUES (
    v_pending_id,p_campaign_id,BTRIM(p_attacker_token_id),'gm',
    (v_attacker->>'gridX')::integer,(v_attacker->>'gridY')::integer,
    (v_attacker->>'gridX')::integer,(v_attacker->>'gridY')::integer,
    v_round,v_turn,BTRIM(p_attacker_token_id),
    jsonb_build_array(jsonb_build_object('maneuver_event','trip','defender_token_id',BTRIM(p_defender_token_id),
      'defender_firm_ground',coalesce(p_defender_firm_ground,false),'distance_ft',v_distance,'reach_ft',v_reach)),
    jsonb_build_array(jsonb_build_object('reactor_token_id',BTRIM(p_defender_token_id),'trigger_key',v_trigger,
      'status',v_reaction_status,'reason',CASE WHEN v_reaction_status='ineligible' THEN 'no_equipped_weapon_threatens_trigger_square' END,
      'threat',jsonb_build_object('last_threatened_step',0,'maneuver_event','trip'))),
    'waiting_reactions',auth.uid()
  );
  RETURN jsonb_build_object('pending',true,'pending_id',v_pending_id,'maneuver','trip',
    'attacker_token_id',BTRIM(p_attacker_token_id),'defender_token_id',BTRIM(p_defender_token_id),
    'reaction_status',v_reaction_status,'distance_ft',v_distance,'reach_ft',v_reach);
END;
$function$
;

-- srd_iniciar_encontrao_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text)
CREATE OR REPLACE FUNCTION priv.srd_iniciar_encontrao_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare c public.campaigns%rowtype; calc jsonb; a jsonb; d jsonb;
 rid uuid:=gen_random_uuid(); rnd int; turnidx int; reach int:=5; dist int; prof jsonb; charid bigint;
 status text:='waiting'; triggerid text;
begin
 if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then raise exception 'Somente o Mestre pode iniciar Encontrão.'; end if;
 if coalesce(trim(p_attacker_token_id),'')='' or coalesce(trim(p_defender_token_id),'')='' or trim(p_attacker_token_id)=trim(p_defender_token_id) then raise exception 'Selecione atacante e defensor diferentes.'; end if;
 select * into c from public.campaigns where id=p_campaign_id for update;
 if not found or upper(coalesce(c.state,''))<>'COMBATE' or coalesce(c.combat_data->>'active','false')<>'true' then raise exception 'A iniciativa precisa estar ativa.'; end if;
 if coalesce(c.combat_data->'surprise'->>'phase','')='surprise_round' then raise exception 'Encontrão não pode ser iniciado durante a rodada surpresa.'; end if;
 if coalesce(c.combat_data->>'current_turn','') !~ '^[0-9]+$' then raise exception 'Turno inválido.'; end if;
 turnidx:=(c.combat_data->>'current_turn')::int;
 if c.combat_data->'turn_order'->turnidx->>'id' is distinct from trim(p_attacker_token_id) then raise exception 'O atacante precisa estar no turno ativo.'; end if;
 if exists(select 1 from priv.srd_aoo_pending_movements where campaign_id=p_campaign_id and status in ('waiting_reactions','ready_to_commit')) then raise exception 'Já existe reação de oportunidade pendente.'; end if;
 calc:=public.srd_consultar_modificadores_manobra_srd(p_campaign_id,p_attacker_token_id,p_defender_token_id,'bull_rush',false);
 select t into a from jsonb_array_elements(coalesce(c.cba_data->'tokens','[]'::jsonb)) t where t->>'id'=trim(p_attacker_token_id) or t->>'key'=trim(p_attacker_token_id) limit 1;
 select t into d from jsonb_array_elements(coalesce(c.cba_data->'tokens','[]'::jsonb)) t where t->>'id'=trim(p_defender_token_id) or t->>'key'=trim(p_defender_token_id) limit 1;
 if a is null or d is null then raise exception 'Atacante ou defensor ausente da cena.'; end if;
 if coalesce(a->>'gridX','') !~ '^[0-9]{1,3}$' or coalesce(a->>'gridY','') !~ '^[0-9]{1,3}$' or coalesce(d->>'gridX','') !~ '^[0-9]{1,3}$' or coalesce(d->>'gridY','') !~ '^[0-9]{1,3}$' then raise exception 'Posição inválida.'; end if;
 dist:=priv.srd_grid_footprint_distance_ft((a->>'gridX')::int,(a->>'gridY')::int,priv.srd_token_grid_footprint(p_campaign_id,p_attacker_token_id),(d->>'gridX')::int,(d->>'gridY')::int,priv.srd_token_grid_footprint(p_campaign_id,p_defender_token_id));
 prof:=priv.srd35_maneuver_profile(p_campaign_id,p_defender_token_id); charid:=nullif(prof->>'character_id','')::bigint;
 if charid is not null then
   select greatest(5,coalesce(max(nullif(eq.detalhes->>'reach_ft','')::int),5)) into reach
   from public.srd_character_weapon_instances wi join public.srd_equipment eq on eq.id=wi.equipment_id
   join public.srd_character_equipment ce on ce.character_id=wi.character_id and ce.equipment_id=wi.equipment_id and ce.equipado is true and ce.hand_slot=wi.hand_slot
   where wi.character_id=charid::text and wi.equipado is true and wi.hand_slot in ('main_hand','off_hand') and coalesce(eq.detalhes->>'weapon_melee','true')<>'false'
   and coalesce(eq.detalhes->>'reach_ft','') ~ '^[0-9]{1,3}$';
 else
   if coalesce(d->>'melee_reach_ft','') ~ '^[0-9]{1,3}$' then reach:=greatest(5,(d->>'melee_reach_ft')::int); end if;
 end if;
 if dist>5 then raise exception 'Encontrão exige alcance corpo a corpo adjacente (distância atual: % pés).',dist; end if;
 rnd:=greatest(1,coalesce(nullif(c.combat_data->>'round','')::int,1));
 triggerid:='bull_rush:'||rid::text;
 if calc->>'aoo_status'='suppressed_by_feat' then status:='ineligible'; end if;
 insert into priv.srd_aoo_pending_movements(pending_id,campaign_id,mover_token_id,movement_controller,destination_x,destination_y,origin_x,origin_y,combat_round,current_turn,turn_actor_id,threats,pending_reactions,status,created_by)
 values(rid,p_campaign_id,trim(p_attacker_token_id),'gm',(a->>'gridX')::int,(a->>'gridY')::int,(a->>'gridX')::int,(a->>'gridY')::int,rnd,turnidx,trim(p_attacker_token_id),
 jsonb_build_array(jsonb_build_object('maneuver_event','bull_rush','defender_token_id',trim(p_defender_token_id))),
 jsonb_build_array(jsonb_build_object('reactor_token_id',trim(p_defender_token_id),'trigger_key',triggerid,'status',status,'threat',jsonb_build_object('maneuver_event','bull_rush'))),'waiting_reactions',auth.uid());
 return jsonb_build_object('pending',true,'pending_id',rid,'maneuver','bull_rush','attacker_token_id',trim(p_attacker_token_id),'defender_token_id',trim(p_defender_token_id),'aoo_status',calc->>'aoo_status','modifiers',calc);
end $function$
;

-- srd_iniciar_levantar_caido_srd(p_campaign_id bigint, p_token_id text)
CREATE OR REPLACE FUNCTION priv.srd_iniciar_levantar_caido_srd(p_campaign_id bigint, p_token_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_campaign public.campaigns%ROWTYPE;
  v_token jsonb;
  v_tokens jsonb;
  v_count integer;
  v_x integer; v_y integer; v_round integer; v_turn integer;
  v_order jsonb; v_actor jsonb;
  v_faction text;
  v_reach integer;
  v_reactions jsonb;
  v_threats jsonb;
  v_pending uuid:=gen_random_uuid();
  v_token_id text; v_profile jsonb; v_character_id text; v_action_state jsonb; v_by jsonb; v_actions jsonb;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND OR upper(coalesce(v_campaign.state,''))<>'COMBATE'
     OR coalesce(v_campaign.combat_data->>'active','false')<>'true' THEN
    RAISE EXCEPTION 'Levantar-se durante o combate exige iniciativa ativa.';
  END IF;
  IF coalesce(v_campaign.combat_data->'surprise'->>'phase','normal')='surprise_round' THEN
    RAISE EXCEPTION 'Levantar-se não pode ser executado durante a rodada surpresa.';
  END IF;
  IF coalesce(v_campaign.combat_data->>'current_turn','') !~ '^[0-9]+$'
     OR coalesce(v_campaign.combat_data->>'round','') !~ '^[0-9]+$' THEN
    RAISE EXCEPTION 'Turno ou rodada inválidos.';
  END IF;
  v_turn:=(v_campaign.combat_data->>'current_turn')::integer;
  v_round:=greatest(1,(v_campaign.combat_data->>'round')::integer);
  v_order:=CASE WHEN jsonb_typeof(v_campaign.combat_data->'turn_order')='array'
    THEN v_campaign.combat_data->'turn_order' ELSE '[]'::jsonb END;
  v_actor:=v_order->v_turn;
  IF v_actor IS NULL OR v_actor->>'id' IS DISTINCT FROM btrim(p_token_id) THEN
    RAISE EXCEPTION 'O personagem precisa estar no turno ativo.';
  END IF;
  SELECT count(*)::integer,(array_agg(t))[1] INTO v_count,v_token
  FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  WHERE t->>'id'=btrim(p_token_id) OR t->>'key'=btrim(p_token_id);
  IF v_count<>1 THEN RAISE EXCEPTION 'Token ausente ou duplicado.'; END IF;
  IF public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' AND NOT (
    v_token->>'tipo'='player' AND EXISTS(
      SELECT 1 FROM public.characters ch WHERE ch.id::text=v_token->>'id'
        AND ch.campaign_id=p_campaign_id AND ch.user_id=auth.uid()
    )
  ) THEN RAISE EXCEPTION 'Somente o Mestre ou o jogador dono do personagem pode iniciar o levantamento.'; END IF;
  v_token_id:=coalesce(v_token->>'key',v_token->>'id');
  IF coalesce(v_token->>'gridX','') !~ '^[0-9]{1,3}$'
     OR coalesce(v_token->>'gridY','') !~ '^[0-9]{1,3}$' THEN
    RAISE EXCEPTION 'Posição do token inválida.';
  END IF;
  v_x:=(v_token->>'gridX')::integer; v_y:=(v_token->>'gridY')::integer;
  IF NOT EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc
    WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='token'
      AND cc.target_id IN (btrim(p_token_id),v_token_id)
      AND cc.condition_id='prone' AND cc.active=true) THEN
    RAISE EXCEPTION 'Este combatente não está Caído.';
  END IF;
  IF priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'no_actions')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'no_move')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'helpless')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'unconscious')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'dying')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'stable')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'dead') THEN
    RAISE EXCEPTION 'A condição atual impede levantar-se.';
  END IF;
  IF EXISTS(SELECT 1 FROM priv.srd_aoo_pending_movements
    WHERE campaign_id=p_campaign_id AND status IN ('waiting_reactions','ready_to_commit')) THEN
    RAISE EXCEPTION 'Outra reação de oportunidade já está pendente nesta campanha.';
  END IF;
  v_faction:=lower(coalesce(v_token->>'combat_faction',''));
  IF v_faction NOT IN ('ally','hostile') THEN
    RAISE EXCEPTION 'Configure primeiro a facção do token para identificar inimigos que ameacem seu espaço.';
  END IF;
  IF EXISTS(
    SELECT 1 FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
    WHERE t->>'id' IS DISTINCT FROM btrim(p_token_id)
      AND t->>'key' IS DISTINCT FROM btrim(p_token_id)
      AND coalesce(t->>'tipo','') IN ('player','npc','monstro')
      AND lower(coalesce(t->>'combat_faction','')) NOT IN ('ally','hostile','neutral')
  ) THEN
    RAISE EXCEPTION 'Há combatentes sem facção configurada. Defina ally, hostile ou neutral para que nenhum inimigo ameaçador seja ignorado.';
  END IF;
  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_token_id));
  v_character_id:=v_profile->>'character_id';
  IF v_character_id IS NOT NULL AND (
    priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_actions')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_move')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'helpless')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'unconscious')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'dying')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'stable')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'dead')
  ) THEN
    RAISE EXCEPTION 'A condição da ficha impede levantar-se.';
  END IF;
  IF EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc
    WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='token'
      AND cc.target_id IN (btrim(p_token_id),v_token_id)
      AND cc.condition_id='prone' AND cc.active=true
      AND cc.notes->>'source'='standing_pending') THEN
    RAISE EXCEPTION 'Este levantamento já está pendente.';
  END IF;

  WITH enemies AS (
    SELECT t,
      CASE WHEN coalesce(t->>'melee_reach_ft','') ~ '^[0-9]{1,3}$'
        THEN (t->>'melee_reach_ft')::integer ELSE 5 END reach_ft
    FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
    WHERE (t->>'combat_faction')=CASE WHEN v_faction='ally' THEN 'hostile' ELSE 'ally' END
      AND (t->>'id' IS DISTINCT FROM btrim(p_token_id))
      AND (t->>'key' IS DISTINCT FROM btrim(p_token_id))
      AND coalesce(t->>'gridX','') ~ '^[0-9]{1,3}$'
      AND coalesce(t->>'gridY','') ~ '^[0-9]{1,3}$'
      AND coalesce(t->>'tipo','') IN ('player','npc','monstro')
  ), threatening AS (
    SELECT t,reach_ft,
      priv.srd_grid_footprint_distance_ft(
        (t->>'gridX')::integer,(t->>'gridY')::integer,
        priv.srd_token_grid_footprint(p_campaign_id,coalesce(t->>'key',t->>'id')),
        v_x,v_y,priv.srd_token_grid_footprint(p_campaign_id,p_token_id)
      ) distance_ft
    FROM enemies
  )
  SELECT coalesce(jsonb_agg(jsonb_build_object(
    'token_id',t->>'id','token_key',t->>'key',
    'name',coalesce(t->>'nome',t->>'name','Inimigo'),
    'reach_ft',reach_ft,'distance_ft',distance_ft,
    'last_threatened_step',0,'standing_event',true
  ) ORDER BY distance_ft),'[]'::jsonb)
  INTO v_threats FROM threatening WHERE distance_ft<=reach_ft;

  v_action_state:=v_campaign.combat_data->'action_economy';
  IF jsonb_typeof(v_action_state)='object'
     AND coalesce(v_action_state->>'round','')=v_round::text
     AND jsonb_typeof(v_action_state->'by_character')='object' THEN
    v_by:=v_action_state->'by_character';
  ELSE v_by:='{}'::jsonb; END IF;
  v_actions:=CASE WHEN jsonb_typeof(v_by->btrim(p_token_id))='object'
    THEN v_by->btrim(p_token_id) ELSE '{}'::jsonb END;
  IF coalesce((v_actions->>'movimento')::boolean,false) THEN
    RAISE EXCEPTION 'A ação de movimento já foi usada nesta rodada.';
  END IF;
  IF priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'one_move_or_standard')
     AND coalesce((v_actions->>'padrao')::boolean,false) THEN
    RAISE EXCEPTION 'As condições não permitem levantar-se depois de uma ação padrão nesta rodada.';
  END IF;

  SELECT coalesce(jsonb_agg(jsonb_build_object(
    'reactor_token_id',coalesce(x->>'token_id',x->>'token_key'),
    'trigger_key','stand:'||v_pending::text||':'||coalesce(x->>'token_id',x->>'token_key'),
    'status','waiting',
    'threat',x
  ) ORDER BY x->>'token_id'),'[]'::jsonb)
  INTO v_reactions FROM jsonb_array_elements(v_threats) x;

  INSERT INTO priv.srd_aoo_pending_movements(
    pending_id,campaign_id,mover_token_id,movement_controller,destination_x,destination_y,
    origin_x,origin_y,combat_round,current_turn,turn_actor_id,threats,pending_reactions,status,created_by
  ) VALUES (
    v_pending,p_campaign_id,btrim(p_token_id),'gm',v_x,v_y,v_x,v_y,
    v_round,v_turn,btrim(p_token_id),
    jsonb_build_array(jsonb_build_object('standing_event','stand_up','token_id',btrim(p_token_id))),
    coalesce(v_reactions,'[]'::jsonb),'waiting_reactions',auth.uid()
  );
  RETURN jsonb_build_object('pending',true,'pending_id',v_pending,'event','stand_up',
    'token_id',btrim(p_token_id),'threats',v_threats,'pending_reactions',v_reactions,
    'requires_reactions',jsonb_array_length(coalesce(v_reactions,'[]'::jsonb))>0);
END;
$function$
;

-- srd_parse_natural_attack_list(p_attack_text text)
CREATE OR REPLACE FUNCTION priv.srd_parse_natural_attack_list(p_attack_text text)
 RETURNS jsonb
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'public', 'priv'
AS $function$
declare
  v_part text; v_match text[]; v_result jsonb := '[]'::jsonb;
  v_index integer := 0; v_name text; v_count integer; v_bonus integer;
  v_damage text; v_flat integer; v_extra text; v_natural boolean;
  v_crit_match text[]; v_crit_min integer; v_crit_mult integer;
begin
  if nullif(btrim(p_attack_text),'') is null then return v_result; end if;
  foreach v_part in array regexp_split_to_array(btrim(p_attack_text),
    ',[[:space:]]+and[[:space:]]+|[[:space:]]+and[[:space:]]+|;[[:space:]]+or[[:space:]]+|[[:space:]]+or[[:space:]]+')
  loop
    v_part:=btrim(v_part, E' \t\n\r,;');
    if v_part='' then continue; end if;
    v_index:=v_index+1;
    v_match:=regexp_match(v_part,
      '^([0-9]+[[:space:]]+)?([[:alpha:]][[:alpha:]'' -]*?)[[:space:]]+([+-][0-9]+(/[+-]?[0-9]+)*)[[:space:]]+melee[[:space:]]+\(([0-9]+d[0-9]+)([+-][0-9]+)?([^)]*)\)$','i');
    if v_match is null then
      v_result:=v_result||jsonb_build_array(jsonb_build_object(
        'index',v_index,'is_natural',false,'parse_supported',false,
        'attack_group_text',v_part,'warning','unsupported_statblock_attack_syntax'));
      continue;
    end if;
    v_count:=coalesce(nullif(btrim(v_match[1]),'')::integer,1);
    v_name:=btrim(v_match[2]); v_bonus:=split_part(v_match[3],'/',1)::integer;
    v_damage:=v_match[5]||coalesce(v_match[6],'');
    v_flat:=coalesce(nullif(v_match[6],'')::integer,0);
    v_extra:=nullif(btrim(v_match[7]),'');
    v_natural:=lower(v_name) ~
      '^(bite|claw|claws|tentacle|tentacles|slam|slams|gore|sting|tail|tail slap|wing|wings|hoof|hooves|talon|talons|rake|rakes|pseudopod|pseudopods|slam attack|constrict|incorporeal touch|touch|spike|spikes|stomp|stinger|beak|fist|fists|horn|horns|trample|rend|swallow whole)$';
    v_crit_min:=20; v_crit_mult:=2;
    v_crit_match:=regexp_match(coalesce(v_extra,''),'([0-9]{2})(?:-([0-9]{2}))?/x([2-5])','i');
    if v_crit_match is not null then
      v_crit_min:=v_crit_match[1]::integer; v_crit_mult:=v_crit_match[3]::integer;
      v_extra:=regexp_replace(v_extra,'[0-9]{2}(?:-[0-9]{2})?/x[2-5]','', 'i');
    else
      v_crit_match:=regexp_match(coalesce(v_extra,''),'/x([2-5])','i');
      if v_crit_match is not null then
        v_crit_mult:=v_crit_match[1]::integer;
        v_extra:=regexp_replace(v_extra,'/x[2-5]','', 'i');
      end if;
    end if;
    v_extra:=nullif(regexp_replace(btrim(coalesce(v_extra,'')),'^[[:space:]/,;]+|[[:space:]/,;]+$','','g'),'');
    if v_count<1 or v_count>20 or v_damage !~ '^[0-9]+d[0-9]+([+-][0-9]+)?$'
      or v_crit_min<2 or v_crit_min>20 then
      v_result:=v_result||jsonb_build_array(jsonb_build_object(
        'index',v_index,'is_natural',false,'parse_supported',false,
        'attack_group_text',v_part,'warning','invalid_attack_metadata'));
      continue;
    end if;
    v_result:=v_result||jsonb_build_array(jsonb_build_object(
      'index',v_index,'name',v_name,'count',v_count,'attack_bonus',v_bonus,
      'attack_bonus_progression',v_match[3],'damage_expression',v_damage,
      'damage_flat',v_flat,'additional_effect',v_extra,'is_natural',v_natural,
      'critical_threat_minimum',v_crit_min,'critical_multiplier',v_crit_mult,
      'parse_supported',true,'attack_group_text',v_part));
  end loop;
  return v_result;
end;
$function$
;

-- srd_passive_feat_modifier(p_character_id bigint, p_stat text)
CREATE OR REPLACE FUNCTION priv.srd_passive_feat_modifier(p_character_id bigint, p_stat text)
 RETURNS integer
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_bonus integer := 0;
BEGIN
  IF p_character_id IS NULL OR NULLIF(BTRIM(p_stat), '') IS NULL THEN
    RETURN 0;
  END IF;

  SELECT COALESCE(SUM(
    CASE
      WHEN grouped.bonus_type IN ('untyped', 'dodge', 'circumstance')
        THEN grouped.sum_value
      ELSE grouped.max_value
    END
  ), 0)::integer
    INTO v_bonus
    FROM (
      SELECT
        COALESCE(NULLIF(effect.value->>'bonus_type', ''), 'untyped') AS bonus_type,
        SUM((effect.value->>'value')::numeric) AS sum_value,
        MAX((effect.value->>'value')::numeric) AS max_value
      FROM public.srd_character_sheets AS sheet
      CROSS JOIN LATERAL jsonb_array_elements(
        CASE WHEN jsonb_typeof(sheet.talentos)='array'
          THEN sheet.talentos ELSE '[]'::jsonb END
      ) AS chosen(value)
      JOIN public.srd_feats AS feat
        ON feat.id=COALESCE(chosen.value->>'id',chosen.value #>> '{}')
      CROSS JOIN LATERAL jsonb_array_elements(
        CASE WHEN jsonb_typeof(feat.mechanics->'resolution'->'effects')='array'
          THEN feat.mechanics->'resolution'->'effects' ELSE '[]'::jsonb END
      ) AS effect(value)
      WHERE sheet.character_id=p_character_id
        AND feat.mechanics->>'engine_status'='implemented'
        AND feat.mechanics->'activation'->>'mode'='passive'
        AND effect.value->>'kind'='modifier'
        AND lower(effect.value->>'stat')=lower(BTRIM(p_stat))
        AND COALESCE(effect.value->>'value','') ~ '^-?[0-9]+$'
      GROUP BY COALESCE(NULLIF(effect.value->>'bonus_type', ''), 'untyped')
    ) AS grouped;

  RETURN COALESCE(v_bonus,0);
END;
$function$
;

-- srd_registrar_ocultacao_ataque_oportunidade_impl(p_campaign_id bigint, p_attack_id uuid, p_manual_d100 integer)
CREATE OR REPLACE FUNCTION priv.srd_registrar_ocultacao_ataque_oportunidade_impl(p_campaign_id bigint, p_attack_id uuid, p_manual_d100 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_attack priv.srd_aoo_attacks%rowtype;
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_next_status text;
  v_reaction_index integer;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode registrar a chance de falha por ocultação.';
  end if;
  if p_manual_d100 is null or p_manual_d100 not between 1 and 100 then
    raise exception 'A chance de falha exige um resultado D100 físico entre 1 e 100.';
  end if;
  select * into v_attack from priv.srd_aoo_attacks
  where campaign_id=p_campaign_id and attack_id=p_attack_id for update;
  if not found or v_attack.created_by<>auth.uid() then
    raise exception 'Ataque não encontrado ou sem autorização.';
  end if;
  if v_attack.status<>'awaiting_miss_chance' then
    if v_attack.resolution_data ? 'concealment_d100'
       and (v_attack.resolution_data->>'concealment_d100')::integer=p_manual_d100 then
      return jsonb_build_object('attack_id',p_attack_id,'status',v_attack.status,
        'miss_chance',50,'d100',p_manual_d100,
        'missed',coalesce((v_attack.resolution_data->>'concealment_missed')::boolean,false),
        'replayed',true);
    end if;
    raise exception 'Este ataque não aguarda a rolagem de ocultação.';
  end if;
  if coalesce(v_attack.resolution_data->>'concealment_miss_chance','')<>'50'
     or coalesce(v_attack.resolution_data->>'concealment_pending_status','')<>'awaiting_damage' then
    raise exception 'Os dados de ocultação do ataque são inválidos.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=v_attack.pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then
    raise exception 'O movimento que originou o ataque não está mais pendente.';
  end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
    or coalesce(v_campaign.combat_data->>'active','false')<>'true'
    or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
    or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'O combate avançou antes da rolagem de ocultação.';
  end if;
  v_next_status:=case when p_manual_d100<=50 then 'miss' else 'awaiting_damage' end;
  update priv.srd_aoo_attacks
  set status=v_next_status,
      resolution_data=resolution_data||jsonb_build_object(
        'concealment_d100',p_manual_d100,
        'concealment_missed',(p_manual_d100<=50),
        'concealment_resolved_at',now()
      ),
      resolved_at=case when p_manual_d100<=50 then now() else resolved_at end
  where attack_id=p_attack_id returning * into v_attack;
  select (e.ordinality-1)::integer into v_reaction_index
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality e(value,ordinality)
  where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1;
  if v_reaction_index is null then raise exception 'A reação vinculada ao ataque não foi encontrada.'; end if;
  update priv.srd_aoo_pending_movements p
  set pending_reactions=jsonb_set(p.pending_reactions,ARRAY[v_reaction_index::text],
    (p.pending_reactions->v_reaction_index)||jsonb_build_object(
      'status',case when p_manual_d100<=50 then 'miss' else 'hit_pending_damage' end,
      'concealment_d100',p_manual_d100,'concealment_missed',(p_manual_d100<=50)
    ),false),updated_at=now()
  where p.pending_id=v_attack.pending_id;
  return jsonb_build_object('attack_id',p_attack_id,'status',v_next_status,
    'd100',p_manual_d100,'miss_chance',50,'missed',(p_manual_d100<=50),'replayed',false);
end;
$function$
;

-- srd_request_confusion_turn_roll()
CREATE OR REPLACE FUNCTION priv.srd_request_confusion_turn_roll()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_order jsonb;
  v_index integer;
  v_actor jsonb;
  v_target_kind text;
  v_target_id text;
  v_round integer;
  v_condition public.srd_campaign_conditions%rowtype;
  v_request uuid;
  v_name text;
begin
  if new.combat_data is null
     or coalesce(new.combat_data->>'active','false')<>'true'
     or upper(coalesce(new.state,''))<>'COMBATE' then
    return new;
  end if;
  if tg_op='UPDATE'
     and new.combat_data->>'current_turn' is not distinct from old.combat_data->>'current_turn'
     and new.combat_data->>'round' is not distinct from old.combat_data->>'round'
     and new.combat_data->'surprise'->>'phase' is not distinct from old.combat_data->'surprise'->>'phase' then
    return new;
  end if;
  v_order:=case when jsonb_typeof(new.combat_data->'turn_order')='array'
    then new.combat_data->'turn_order' else '[]'::jsonb end;
  if jsonb_array_length(v_order)=0
     or coalesce(new.combat_data->>'current_turn','') !~ '^[0-9]+$' then
    return new;
  end if;
  v_index:=(new.combat_data->>'current_turn')::integer;
  if v_index<0 or v_index>=jsonb_array_length(v_order) then return new; end if;
  v_actor:=v_order->v_index;
  v_target_id:=nullif(btrim(v_actor->>'id'),'');
  if v_target_id is null then return new; end if;
  v_target_kind:=case when coalesce((v_actor->>'is_monster')::boolean,false) then 'token' else 'character' end;
  v_round:=greatest(0,coalesce(nullif(new.combat_data->>'round','')::integer,0));

  select * into v_condition
  from public.srd_campaign_conditions
  where campaign_id=new.id and target_kind=v_target_kind
    and target_id=v_target_id and condition_id='confused' and active=true
  order by condition_instance_id desc limit 1
  for update;
  if not found then return new; end if;

  if coalesce(v_condition.notes->>'confusion_pending_round','')=v_round::text
     and coalesce(v_condition.notes->>'confusion_pending_turn','')=v_index::text
     and nullif(v_condition.notes->>'confusion_pending_request_id','') is not null then
    return new;
  end if;
  v_request:=gen_random_uuid();
  v_name:=coalesce(v_actor->>'name',v_actor->>'nome','Combatente confuso');

  update public.srd_campaign_conditions
  set notes=coalesce(notes,'{}'::jsonb)||jsonb_build_object(
    'confusion_pending_request_id',v_request::text,
    'confusion_pending_round',v_round,
    'confusion_pending_turn',v_index,
    'confusion_pending_at',now()
  )
  where condition_instance_id=v_condition.condition_instance_id;

  insert into public.campaign_log(campaign_id,type,visibilidade,data)
  values(new.id,'test_request','PUBLIC',jsonb_build_object(
    'tipo','Confusão — comportamento aleatório (D100)',
    'resolution_type','confusion_d100',
    'request_id',v_request::text,
    'alvos',case when v_target_kind='character' then jsonb_build_array(v_target_id) else '[]'::jsonb end,
    'npc_alvos',case when v_target_kind='token' then jsonb_build_array(v_target_id) else '[]'::jsonb end,
    'target_kind',v_target_kind,
    'target_id',v_target_id,
    'combat_round',v_round,
    'current_turn',v_index,
    'mestre','Sistema',
    'mestre_id',new.owner_id,
    'detalhes',jsonb_build_array(jsonb_build_object('id',v_target_id,'name',v_name))
  ));
  return new;
end;
$function$
;

-- srd_reservar_ataque_oportunidade_impl(p_campaign_id bigint, p_actor_token_id text, p_trigger_key text, p_actor_flat_footed boolean)
CREATE OR REPLACE FUNCTION priv.srd_reservar_ataque_oportunidade_impl(p_campaign_id bigint, p_actor_token_id text, p_trigger_key text, p_actor_flat_footed boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_combat jsonb;
  v_round integer;
  v_phase text;
  v_profile jsonb;
  v_character_id bigint;
  v_feats jsonb := '[]'::jsonb;
  v_has_combat_reflexes boolean := false;
  v_dex_mod integer := 0;
  v_limit integer := 1;
  v_used integer := 0;
  v_existing priv.srd_aoo_reaction_ledger%rowtype;
  v_new priv.srd_aoo_reaction_ledger%rowtype;
  v_token jsonb;
  v_stats jsonb;
  v_monster_feats text;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode autorizar e registrar uma reação de ataque de oportunidade.';
  end if;
  if nullif(btrim(p_actor_token_id),'') is null
     or nullif(btrim(p_trigger_key),'') is null
     or length(p_trigger_key)>160 then
    raise exception 'Identificador do combatente ou do evento provocador inválido.';
  end if;

  select combat_data into v_combat
  from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce((select state from public.campaigns where id=p_campaign_id),''))<>'COMBATE'
     or coalesce((v_combat->>'active')::boolean,false) is not true then
    raise exception 'A iniciativa precisa estar ativa para registrar uma reação.';
  end if;
  if coalesce(v_combat->>'round','') !~ '^[0-9]+$' then
    raise exception 'A rodada atual é inválida.';
  end if;
  v_phase:=case when coalesce(v_combat->'surprise'->>'phase','')='surprise_round'
    then 'surprise_round' else 'normal' end;
  v_round:=greatest(1,(v_combat->>'round')::integer);

  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_actor_token_id));
  if v_profile is null or (v_profile->>'character_id' is null and v_profile->>'size_rank' is null) then
    raise exception 'Não foi possível validar o combatente que pretende reagir.';
  end if;
  if coalesce(v_profile->>'dexterity_modifier','') ~ '^-?[0-9]+$' then
    v_dex_mod:=(v_profile->>'dexterity_modifier')::integer;
  end if;
  v_character_id:=nullif(v_profile->>'character_id','')::bigint;

  if v_character_id is not null then
    select coalesce(talentos,'[]'::jsonb) into v_feats
    from public.srd_character_sheets where character_id=v_character_id;
    v_has_combat_reflexes:=exists(
      select 1 from jsonb_array_elements(
        case when jsonb_typeof(v_feats)='array' then v_feats else '[]'::jsonb end
      ) f
      where lower(coalesce(f->>'id','')) in
        ('reflexos_de_combate','combat_reflexes','srd35_feat_combat_reflexes')
        or lower(coalesce(f->>'nome','')) in ('reflexos de combate','combat reflexes')
    );
  else
    select t into v_token
    from public.campaigns c,
      lateral jsonb_array_elements(case when jsonb_typeof(c.cba_data->'tokens')='array'
        then c.cba_data->'tokens' else '[]'::jsonb end) t
    where c.id=p_campaign_id and (t->>'id'=btrim(p_actor_token_id) or t->>'key'=btrim(p_actor_token_id))
    limit 1;
    if v_token is null then raise exception 'Token reator não existe mais na cena.'; end if;
    v_stats:=coalesce(v_token->'monsterStats','{}'::jsonb);
    v_monster_feats:=concat_ws(',',
      nullif(v_stats->>'feats',''),
      nullif(v_stats->>'talentos',''),
      nullif(v_stats->'dados_tecnicos'->'statblock'->>'feats',''),
      nullif(v_stats->'dados_tecnicos'->>'feats','')
    );
    v_has_combat_reflexes:=coalesce(v_monster_feats,'') ~*
      '(^|[,;[:space:]])combat[[:space:]]+reflexesb?([,;[:space:]]|$)';
  end if;

  if p_actor_flat_footed and not v_has_combat_reflexes then
    raise exception 'Este combatente está surpreso/desprevenido e não possui Reflexos de Combate para reagir.';
  end if;
  if v_has_combat_reflexes then
    v_limit:=1+greatest(0,v_dex_mod);
  end if;

  select * into v_existing
  from priv.srd_aoo_reaction_ledger
  where campaign_id=p_campaign_id and combat_phase=v_phase and combat_round=v_round
    and actor_token_id=btrim(p_actor_token_id) and trigger_key=btrim(p_trigger_key);
  if found then
    return jsonb_build_object('reserved',true,'duplicate',true,
      'reaction_id',v_existing.reaction_id,'round',v_round,
      'used',v_existing.reaction_number,'limit',v_existing.max_reactions,
      'combat_reflexes',v_has_combat_reflexes,'dexterity_modifier',v_dex_mod);
  end if;

  select count(*)::integer into v_used
  from priv.srd_aoo_reaction_ledger
  where campaign_id=p_campaign_id and combat_phase=v_phase and combat_round=v_round
    and actor_token_id=btrim(p_actor_token_id);
  if v_used>=v_limit then
    raise exception 'Limite de ataques de oportunidade atingido nesta rodada (%/%).',v_used,v_limit;
  end if;

  insert into priv.srd_aoo_reaction_ledger(
    campaign_id,combat_phase,combat_round,actor_token_id,trigger_key,reaction_number,max_reactions
  ) values (
    p_campaign_id,v_phase,v_round,btrim(p_actor_token_id),btrim(p_trigger_key),v_used+1,v_limit
  ) returning * into v_new;

  return jsonb_build_object('reserved',true,'duplicate',false,
    'reaction_id',v_new.reaction_id,'round',v_round,
    'used',v_new.reaction_number,'limit',v_limit,
    'combat_reflexes',v_has_combat_reflexes,'dexterity_modifier',v_dex_mod,
    'flat_footed_allowed',v_has_combat_reflexes);
end;
$function$
;

-- srd_reservar_reacao_movimento_aoo_impl(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)
CREATE OR REPLACE FUNCTION priv.srd_reservar_reacao_movimento_aoo_impl(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_profile jsonb;
  v_character_id text;
  v_confused_engagement boolean:=false;
  v_token_type text;
  v_flat_footed boolean:=false;
  v_has_combat_reflexes boolean:=false;
  v_disabled boolean:=false;
  v_index bigint;
  v_reaction jsonb;
  v_reactor_token jsonb;
  v_trigger text;
  v_reservation jsonb;
  v_updated jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode autorizar a reação.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then raise exception 'Movimento não está aguardando reações.'; end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
    or coalesce(v_campaign.combat_data->>'active','false')<>'true'
    or coalesce(v_campaign.combat_data->>'round','') !~ '^[0-9]+$'
    or greatest(1,(v_campaign.combat_data->>'round')::integer)<>v_pending.combat_round
    or coalesce(v_campaign.combat_data->>'current_turn','') !~ '^[0-9]+$'
    or (v_campaign.combat_data->>'current_turn')::integer<>v_pending.current_turn then
    raise exception 'O combate avançou desde a solicitação; o movimento precisa ser reavaliado.';
  end if;
  select ordinality,value into v_index,v_reaction
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality
  where coalesce(value->>'reactor_token_id','')=btrim(p_reactor_token_id) limit 1;
  if v_reaction is null then raise exception 'Este token não está entre os combatentes ameaçadores detectados.'; end if;
  if v_reaction->>'status'='reserved' then
    return jsonb_build_object('reserved',true,'duplicate',true,
      'reservation_id',v_reaction->>'reservation_id','pending_id',p_pending_id,
      'reactor_token_id',p_reactor_token_id);
  end if;
  if v_reaction->>'status'<>'waiting' then raise exception 'Esta reação já foi processada.'; end if;
  select t->>'tipo' into v_token_type
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id) limit 1;
  if v_token_type is null then raise exception 'Token reator não existe mais na cena.'; end if;
  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_reactor_token_id));
  v_character_id:=v_profile->>'character_id';

  v_confused_engagement:=priv.srd_condition_has_flag(
    p_campaign_id,'token',btrim(p_reactor_token_id),'no_aoo_against_unengaged');
  if nullif(v_character_id,'') is not null then
    v_confused_engagement:=v_confused_engagement or priv.srd_condition_has_flag(
      p_campaign_id,'character',v_character_id,'no_aoo_against_unengaged');
  end if;
  if v_confused_engagement and not priv.srd_confusion_aoo_engaged(
    p_campaign_id,btrim(p_reactor_token_id),v_character_id,v_pending.mover_token_id) then
    update priv.srd_aoo_pending_movements
    set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],
      v_reaction||jsonb_build_object('status','ineligible','reason','confused_target_not_engaged'),
      false),updated_at=now()
    where pending_id=p_pending_id;
    return jsonb_build_object('reserved',false,'ineligible',true,
      'reason','confused_target_not_engaged','reactor_token_id',p_reactor_token_id);
  end if;

  v_disabled :=
    priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'no_actions')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'helpless')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stunned')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'unconscious')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dying')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stable')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dead')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'no_threaten_squares')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'cannot_attack');
  if v_character_id is not null then
    v_disabled:=v_disabled
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_actions')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'helpless')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'stunned')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'unconscious')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'dying')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'stable')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'dead')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_threaten_squares')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'cannot_attack');
  end if;
  if v_disabled then
    update priv.srd_aoo_pending_movements
    set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],
      v_reaction||jsonb_build_object('status','ineligible','reason','reactor_condition_prevents_aoo'),
      false),updated_at=now()
    where pending_id=p_pending_id;
    return jsonb_build_object('reserved',false,'ineligible',true,
      'reason','reactor_condition_prevents_aoo','reactor_token_id',p_reactor_token_id);
  end if;

  v_flat_footed:=priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'no_aoo');
  if v_character_id is not null then
    v_flat_footed:=v_flat_footed
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_aoo');
  end if;
  if v_flat_footed then
    if v_character_id is not null then
      select exists(
        select 1 from public.srd_character_sheets sh
        cross join lateral jsonb_array_elements(
          case when jsonb_typeof(sh.talentos)='array' then sh.talentos else '[]'::jsonb end
        ) feat
        where sh.character_id::text=v_character_id
          and (lower(coalesce(feat->>'id','')) in
            ('reflexos_de_combate','combat_reflexes','srd35_feat_combat_reflexes')
            or lower(coalesce(feat->>'nome','')) in ('reflexos de combate','combat reflexes'))
      ) into v_has_combat_reflexes;
    else
      select t into v_reactor_token
      from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
      where t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id) limit 1;
      v_has_combat_reflexes:=concat_ws(',',
        v_reactor_token->'monsterStats'->>'feats',
        v_reactor_token->'monsterStats'->>'talentos',
        v_reactor_token->'monsterStats'->'dados_tecnicos'->'statblock'->>'feats',
        v_reactor_token->'monsterStats'->'dados_tecnicos'->>'feats'
      ) ~* '(^|[,;[:space:]])combat[[:space:]]+reflexesb?([,;[:space:]]|$)';
    end if;
    if not v_has_combat_reflexes then
      update priv.srd_aoo_pending_movements
      set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],
        v_reaction||jsonb_build_object('status','ineligible',
          'reason','flat_footed_without_combat_reflexes'),false),updated_at=now()
      where pending_id=p_pending_id;
      return jsonb_build_object('reserved',false,'ineligible',true,
        'reason','flat_footed_without_combat_reflexes','reactor_token_id',p_reactor_token_id);
    end if;
  end if;

  v_trigger:=v_reaction->>'trigger_key';
  v_reservation:=public.srd_reservar_ataque_oportunidade_srd(
    p_campaign_id,btrim(p_reactor_token_id),v_trigger,v_flat_footed);
  v_updated:=v_reaction||jsonb_build_object(
    'status','reserved','reservation_id',v_reservation->>'reaction_id',
    'reservation_number',v_reservation->'used','reservation_limit',v_reservation->'limit',
    'flat_footed',v_flat_footed);
  update priv.srd_aoo_pending_movements
  set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],v_updated,false),
      updated_at=now()
  where pending_id=p_pending_id;
  return jsonb_build_object('reserved',true,
    'duplicate',coalesce((v_reservation->>'duplicate')::boolean,false),
    'reservation',v_reservation,'pending_id',p_pending_id,
    'reactor_token_id',p_reactor_token_id,'reaction',v_updated);
end;
$function$
;

-- srd_resolve_confusion_turn_impl(p_campaign_id bigint, p_target_kind text, p_target_id text, p_request_id uuid, p_manual_d100 integer)
CREATE OR REPLACE FUNCTION priv.srd_resolve_confusion_turn_impl(p_campaign_id bigint, p_target_kind text, p_target_id text, p_request_id uuid, p_manual_d100 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
 v_condition public.srd_campaign_conditions%rowtype;
 v_campaign public.campaigns%rowtype;
 v_actor jsonb;
 v_order jsonb;
 v_name text;
 v_outcome text;
 v_description text;
 v_existing integer;
 v_caster_id text;
 v_caster_present boolean:=false;
 v_actor_token_id text;
 v_caster_token_id text;
 v_selected_target_token_id text;
 v_caster_token_count integer:=0;
begin
 if auth.uid() is null then raise exception 'É necessário estar autenticado.'; end if;
 if p_target_kind not in ('character','token') or nullif(btrim(p_target_id),'') is null then
   raise exception 'Alvo da condição Confuso inválido.';
 end if;
 if p_manual_d100 is null or p_manual_d100 not between 1 and 100 then
   raise exception 'O comportamento aleatório exige uma rolagem física de D100 entre 1 e 100.';
 end if;
 select * into v_campaign from public.campaigns where id=p_campaign_id for update;
 if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
   or coalesce(v_campaign.combat_data->>'active','false')<>'true' then
   raise exception 'A campanha não está em combate ativo.';
 end if;
 v_order:=case when jsonb_typeof(v_campaign.combat_data->'turn_order')='array'
   then v_campaign.combat_data->'turn_order' else '[]'::jsonb end;
 if coalesce(v_campaign.combat_data->>'current_turn','') !~ '^[0-9]+$' then
   raise exception 'O turno atual é inválido.';
 end if;
 v_actor:=v_order->(v_campaign.combat_data->>'current_turn')::integer;
 if v_actor->>'id' is distinct from p_target_id
   or (case when coalesce((v_actor->>'is_monster')::boolean,false) then 'token' else 'character' end)<>p_target_kind then
   raise exception 'A rolagem só pode ser registrada no turno do combatente confuso.';
 end if;
 if p_target_kind='token' then
   if public.my_role(p_campaign_id) is distinct from 'GM' then
     raise exception 'Somente o Mestre pode rolar pelo NPC ou monstro.';
   end if;
 else
   if not exists(select 1 from public.characters ch
     where ch.id::text=p_target_id and ch.campaign_id=p_campaign_id
       and (ch.user_id=auth.uid() or public.my_role(p_campaign_id)='GM')) then
     raise exception 'Somente o dono da ficha ou o Mestre pode registrar esta rolagem.';
   end if;
 end if;
 select * into v_condition from public.srd_campaign_conditions
 where campaign_id=p_campaign_id and target_kind=p_target_kind
   and target_id=p_target_id and condition_id='confused' and active=true
 order by condition_instance_id desc limit 1 for update;
 if not found then raise exception 'O combatente não possui a condição Confuso ativa.'; end if;

 if v_condition.notes->>'confusion_last_request_id'=p_request_id::text then
   v_existing:=nullif(v_condition.notes->>'confusion_last_d100','')::integer;
   if v_existing=p_manual_d100 then
     return coalesce(v_condition.notes->'confusion_last_result','{}'::jsonb)||jsonb_build_object('replayed',true);
   end if;
   raise exception 'Esta solicitação já foi respondida com outro resultado.';
 end if;
 if v_condition.notes->>'confusion_pending_request_id' is distinct from p_request_id::text then
   raise exception 'A solicitação de comportamento aleatório expirou ou não corresponde ao turno atual.';
 end if;

 v_name:=coalesce(v_actor->>'name',v_actor->>'nome','Combatente confuso');
 v_caster_id:=coalesce(nullif(v_condition.source_actor_id,''),nullif(v_condition.notes->>'caster_character_id',''));
 SELECT t.token->>'id' INTO v_actor_token_id
 FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t(token)
 WHERE t.token->>'id'=p_target_id OR t.token->>'sourceCharacterId'=p_target_id
 ORDER BY CASE WHEN t.token->>'id'=p_target_id THEN 0 ELSE 1 END
 LIMIT 1;
 IF v_caster_id IS NOT NULL THEN
   v_caster_present:=EXISTS(
     SELECT 1 FROM jsonb_array_elements(v_order) e(entry)
     WHERE e.entry->>'id'=v_caster_id
        OR EXISTS(SELECT 1 FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t(token)
                  WHERE t.token->>'id'=e.entry->>'id' AND t.token->>'sourceCharacterId'=v_caster_id)
   );
   SELECT count(*)::integer,(array_agg(t.token->>'id'))[1]
   INTO v_caster_token_count,v_caster_token_id
   FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t(token)
   WHERE t.token->>'id'=v_caster_id OR t.token->>'sourceCharacterId'=v_caster_id;
   IF v_caster_token_count<>1 THEN v_caster_token_id:=NULL; END IF;
 END IF;
 if p_manual_d100 between 1 and 10 then
   IF v_caster_id IS NOT NULL AND v_caster_present AND v_caster_token_id IS NOT NULL THEN
     v_outcome:='attack_caster';
     v_selected_target_token_id:=v_caster_token_id;
     v_description:='Ataca o conjurador responsável pela condição. Alvo obrigatório: token '||v_caster_token_id||'. O Mestre deve confirmar alcance e possibilidade de ataque.';
   ELSE
     v_outcome:='babble';
     v_description:='Não foi possível identificar o conjurador na iniciativa; balbucia incoerentemente e não age.';
   END IF;
 elsif p_manual_d100 between 11 and 20 then
   v_outcome:='act_normally';
   v_description:='Age normalmente neste turno.';
 elsif p_manual_d100 between 21 and 50 then
   v_outcome:='babble';
   v_description:='Fica balbuciando incoerentemente, sem realizar ações.';
 elsif p_manual_d100 between 51 and 70 then
   IF v_caster_id IS NOT NULL AND v_caster_present AND v_caster_token_id IS NOT NULL THEN
     v_outcome:='flee';
     v_selected_target_token_id:=v_caster_token_id;
     v_description:='Foge do conjurador responsável pela condição em velocidade máxima. Referência para afastamento: token '||v_caster_token_id||'. O Mestre deve determinar uma rota desimpedida.';
   ELSE
     v_outcome:='babble';
     v_description:='Não foi possível identificar o conjurador na iniciativa; balbucia incoerentemente e não age.';
   END IF;
 else
   SELECT NULLIF(BTRIM(priv.srd_confusion_nearest_target_id(p_campaign_id,v_actor_token_id)),'')
     INTO v_selected_target_token_id;
   IF v_selected_target_token_id IS NOT NULL THEN
     v_outcome:='attack_nearest';
     v_description:='Ataca a criatura mais próxima. Alvo determinado pela mesa: token '||v_selected_target_token_id||'.';
   ELSE
     v_outcome:='babble';
     v_description:='Não há outra criatura com posição válida na grade; balbucia incoerentemente e não age.';
   END IF;
 end if;

 update public.srd_campaign_conditions
 set notes=coalesce(notes,'{}'::jsonb)
   - 'confusion_pending_request_id' - 'confusion_pending_round' - 'confusion_pending_turn' - 'confusion_pending_at'
   || jsonb_build_object(
     'confusion_last_request_id',p_request_id::text,
     'confusion_last_round',greatest(0,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0)),
     'confusion_last_d100',p_manual_d100,
     'confusion_last_outcome',v_outcome,'confusion_last_selected_target_token_id',v_selected_target_token_id,
     'confusion_last_result',jsonb_build_object(
       'target_kind',p_target_kind,'target_id',p_target_id,'name',v_name,
       'd100',p_manual_d100,'outcome',v_outcome,'description',v_description,
       'caster_character_id',v_caster_id,'caster_present_in_initiative',v_caster_present,'selected_target_token_id',v_selected_target_token_id,
       'round',greatest(0,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0)),
       'request_id',p_request_id::text
     )
   )
 where condition_instance_id=v_condition.condition_instance_id;

 insert into public.campaign_log(campaign_id,type,visibilidade,data)
 values(p_campaign_id,'system_event','PUBLIC',jsonb_build_object(
   'event','confusion_turn_resolved',
   'target_kind',p_target_kind,'target_id',p_target_id,'name',v_name,
   'd100',p_manual_d100,'outcome',v_outcome,'description',v_description,
   'round',greatest(0,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0)),
   'request_id',p_request_id::text
 ));

 return jsonb_build_object('target_kind',p_target_kind,'target_id',p_target_id,
   'name',v_name,'d100',p_manual_d100,'outcome',v_outcome,
   'description',v_description,'caster_character_id',v_caster_id,'selected_target_token_id',v_selected_target_token_id,
   'caster_present_in_initiative',v_caster_present,
   'request_id',p_request_id::text,'replayed',false);
end;
$function$
;

-- srd_resolver_derrubar_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_defender_firm_ground boolean)
CREATE OR REPLACE FUNCTION priv.srd_resolver_derrubar_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_defender_firm_ground boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE v_pending priv.srd_aoo_pending_movements%ROWTYPE; v_defender text; v_result jsonb;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode concluir Derrubar após a reação.';
  END IF;
  SELECT * INTO v_pending FROM priv.srd_aoo_pending_movements
   WHERE campaign_id=p_campaign_id AND pending_id=p_pending_id FOR UPDATE;
  IF NOT FOUND OR v_pending.status<>'waiting_reactions'
     OR NOT (v_pending.threats @> jsonb_build_array(jsonb_build_object('maneuver_event','trip'))) THEN
    RAISE EXCEPTION 'Evento de Derrubar aguardando reação não encontrado.';
  END IF;
  IF EXISTS (SELECT 1 FROM jsonb_array_elements(v_pending.pending_reactions) r
    WHERE r->>'status' IN ('waiting','reserved','attack_started','hit_pending_damage')) THEN
    RAISE EXCEPTION 'Ainda existem reações de oportunidade não resolvidas.';
  END IF;
  v_defender:=v_pending.pending_reactions->0->>'reactor_token_id';
  PERFORM set_config('app.srd_trip_aoo_pending_id',p_pending_id::text,true);
  v_result:=public.srd_resolver_derrubar_srd(
    p_campaign_id,v_pending.mover_token_id,v_defender,p_attacker_d20,p_defender_d20,
    false,p_defender_firm_ground,false
  );
  PERFORM set_config('app.srd_trip_aoo_pending_id','',true);
  RETURN v_result;
EXCEPTION WHEN OTHERS THEN
  PERFORM set_config('app.srd_trip_aoo_pending_id','',true);
  RAISE;
END;
$function$
;

-- srd_resolver_derrubar_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_attacker_d20 integer, p_defender_d20 integer, p_defender_uses_dex boolean, p_defender_firm_ground boolean, p_trip_using_weapon boolean)
CREATE OR REPLACE FUNCTION priv.srd_resolver_derrubar_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_attacker_d20 integer, p_defender_d20 integer, p_defender_uses_dex boolean DEFAULT false, p_defender_firm_ground boolean DEFAULT false, p_trip_using_weapon boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_campaign public.campaigns%ROWTYPE;
  v_combat jsonb;
  v_order jsonb;
  v_actor jsonb;
  v_round integer;
  v_calc jsonb;
  v_attacker_total integer;
  v_defender_total integer;
  v_success boolean;
  v_action_state jsonb;
  v_by_character jsonb;
  v_actions jsonb;
  v_key text;
  v_prone boolean;
  v_condition_instance bigint;
  v_phase text;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode resolver esta manobra.';
  END IF;
  IF p_attacker_d20 NOT BETWEEN 1 AND 20 OR p_defender_d20 NOT BETWEEN 1 AND 20 THEN
    RAISE EXCEPTION 'Ambas as rolagens precisam ser resultados físicos de D20 entre 1 e 20.';
  END IF;
  IF NULLIF(BTRIM(p_attacker_token_id),'') IS NULL
     OR NULLIF(BTRIM(p_defender_token_id),'') IS NULL
     OR BTRIM(p_attacker_token_id)=BTRIM(p_defender_token_id) THEN
    RAISE EXCEPTION 'Selecione atacante e defensor diferentes.';
  END IF;

  SELECT * INTO v_campaign FROM public.campaigns
   WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND OR upper(coalesce(v_campaign.state,''))<>'COMBATE' THEN
    RAISE EXCEPTION 'Derrubar só pode ser resolvido durante o combate.';
  END IF;
  v_combat:=coalesce(v_campaign.combat_data,'{}'::jsonb);
  IF coalesce(v_combat->>'active','false')<>'true' THEN
    RAISE EXCEPTION 'A iniciativa não está ativa.';
  END IF;
  v_phase:=lower(coalesce(v_combat->'surprise'->>'phase','normal'));
  IF v_phase IN ('surprise','surprise_round') THEN
    RAISE EXCEPTION 'Manobras de ação padrão não podem ser usadas na rodada surpresa.';
  END IF;
  IF coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$' THEN
    RAISE EXCEPTION 'O turno atual é inválido.';
  END IF;
  v_order:=CASE WHEN jsonb_typeof(v_combat->'turn_order')='array' THEN v_combat->'turn_order' ELSE '[]'::jsonb END;
  v_actor:=v_order->(v_combat->>'current_turn')::integer;
  IF v_actor->>'id' IS DISTINCT FROM BTRIM(p_attacker_token_id) THEN
    RAISE EXCEPTION 'O atacante precisa estar no turno ativo.';
  END IF;

  v_calc:=public.srd_consultar_modificadores_manobra_srd(
    p_campaign_id,p_attacker_token_id,p_defender_token_id,'trip',
    coalesce(p_defender_firm_ground,false),coalesce(p_trip_using_weapon,false)
  );
  IF coalesce(v_calc->>'maneuver','')<>'trip' THEN
    RAISE EXCEPTION 'O cálculo retornou uma manobra inválida.';
  END IF;
  IF coalesce(v_calc->>'aoo_status','')='provokes' THEN
    IF NULLIF(current_setting('app.srd_trip_aoo_pending_id',true),'') IS NULL THEN
      RAISE EXCEPTION 'Esta tentativa provoca ataque de oportunidade; resolva a reação do defensor primeiro.';
    END IF;
    IF NOT EXISTS (
      SELECT 1 FROM priv.srd_aoo_pending_movements p
      WHERE p.pending_id=current_setting('app.srd_trip_aoo_pending_id',true)::uuid
        AND p.campaign_id=p_campaign_id AND p.mover_token_id=BTRIM(p_attacker_token_id)
        AND p.status='waiting_reactions'
        AND p.threats @> jsonb_build_array(jsonb_build_object('maneuver_event','trip','defender_token_id',BTRIM(p_defender_token_id)))
        AND NOT EXISTS (
          SELECT 1 FROM jsonb_array_elements(p.pending_reactions) r
          WHERE r->>'status' IN ('waiting','reserved','attack_started','hit_pending_damage')
        )
    ) THEN
      RAISE EXCEPTION 'A reação de oportunidade ainda não foi concluída ou não corresponde a esta manobra.';
    END IF;
  END IF;
  IF coalesce(v_calc->>'aoo_status','') NOT IN ('not_provoked_by_armed_trip','suppressed_by_feat','provokes') THEN
    RAISE EXCEPTION 'Não foi possível confirmar a situação do ataque de oportunidade.';
  END IF;

  v_round:=CASE WHEN coalesce(v_combat->>'round','') ~ '^[0-9]+$'
    THEN greatest(1,(v_combat->>'round')::integer) ELSE 1 END;
  IF priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_attacker_token_id),'no_actions')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_attacker_token_id),'only_move_action')
     OR priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_attacker_token_id),'no_actions')
     OR priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_attacker_token_id),'only_move_action')
     OR (nullif(v_calc->'attacker'->>'character_id','') IS NOT NULL AND (
       priv.srd_condition_has_flag(p_campaign_id,'character',v_calc->'attacker'->>'character_id','no_actions')
       OR priv.srd_condition_has_flag(p_campaign_id,'character',v_calc->'attacker'->>'character_id','only_move_action')
     )) THEN
    RAISE EXCEPTION 'As condições do atacante impedem uma ação padrão.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM public.srd_campaign_conditions
     WHERE campaign_id=p_campaign_id AND target_kind='token'
       AND target_id=BTRIM(p_defender_token_id) AND condition_id='prone' AND active
  ) THEN
    RAISE EXCEPTION 'O alvo já está Caído.';
  END IF;

  v_action_state:=v_combat->'action_economy';
  IF jsonb_typeof(v_action_state)='object'
     AND coalesce(v_action_state->>'round','')=v_round::text
     AND jsonb_typeof(v_action_state->'by_character')='object' THEN
    v_by_character:=v_action_state->'by_character';
  ELSE
    v_by_character:='{}'::jsonb;
  END IF;
  v_key:=BTRIM(p_attacker_token_id);
  v_actions:=CASE WHEN jsonb_typeof(v_by_character->v_key)='object'
    THEN v_by_character->v_key ELSE '{}'::jsonb END;
  IF coalesce((v_actions->>'padrao')::boolean,false) THEN
    RAISE EXCEPTION 'O atacante já gastou sua ação padrão nesta rodada.';
  END IF;
  IF priv.srd_condition_has_flag(p_campaign_id,'token',v_key,'one_move_or_standard')
     AND coalesce((v_actions->>'movimento')::boolean,false) THEN
    RAISE EXCEPTION 'A condição do atacante não permite combinar ação de movimento e ação padrão.';
  END IF;

  v_actions:=v_actions||jsonb_build_object('padrao',true);
  v_by_character:=jsonb_set(v_by_character,ARRAY[v_key],v_actions,true);
  v_action_state:=jsonb_build_object('round',v_round,'by_character',v_by_character);
  v_combat:=v_combat||jsonb_build_object('action_economy',v_action_state);

  v_attacker_total:=p_attacker_d20+(v_calc->>'attacker_modifier')::integer;
  v_defender_total:=p_defender_d20+
    CASE WHEN coalesce(p_defender_uses_dex,false)
      THEN (v_calc->'defender'->>'dexterity_modifier')::integer
      ELSE (v_calc->'defender'->>'strength_modifier')::integer END
    - (v_calc->>'size_difference_modifier')::integer
    + (v_calc->>'dwarf_stability_bonus')::integer;
  v_success:=v_attacker_total>v_defender_total;

  IF v_success THEN
    v_condition_instance:=priv.srd_apply_campaign_condition(
      p_campaign_id,'token',BTRIM(p_defender_token_id),'prone',NULL,
      jsonb_build_object(
        'source','combat_maneuver','maneuver','trip',
        'attacker_token_id',BTRIM(p_attacker_token_id),
        'attacker_d20',p_attacker_d20,'attacker_modifier',(v_calc->>'attacker_modifier')::integer,
        'defender_d20',p_defender_d20,'defender_modifier',
          CASE WHEN coalesce(p_defender_uses_dex,false)
            THEN (v_calc->'defender'->>'dexterity_modifier')::integer
            ELSE (v_calc->'defender'->>'strength_modifier')::integer END,
        'defender_uses_dex',coalesce(p_defender_uses_dex,false),
        'attacker_total',v_attacker_total,'defender_total',v_defender_total
      ),NULL
    );
  END IF;

  UPDATE public.campaigns SET combat_data=v_combat WHERE id=p_campaign_id;
  PERFORM priv.log(p_campaign_id,'COMBAT_MANEUVER',jsonb_build_object(
    'maneuver','trip','attacker_token_id',BTRIM(p_attacker_token_id),
    'defender_token_id',BTRIM(p_defender_token_id),
    'attacker_d20',p_attacker_d20,'attacker_modifier',(v_calc->>'attacker_modifier')::integer,
    'attacker_total',v_attacker_total,'defender_d20',p_defender_d20,
    'defender_modifier',v_defender_total-p_defender_d20,
    'defender_total',v_defender_total,'defender_uses_dex',coalesce(p_defender_uses_dex,false),
    'success',v_success,'condition_instance_id',v_condition_instance,'round',v_round
  ));
  IF NULLIF(current_setting('app.srd_trip_aoo_pending_id',true),'') IS NOT NULL THEN
    UPDATE priv.srd_aoo_pending_movements SET status='committed',committed_at=now(),updated_at=now()
    WHERE pending_id=current_setting('app.srd_trip_aoo_pending_id',true)::uuid
      AND campaign_id=p_campaign_id AND status='waiting_reactions';
  END IF;
  RETURN jsonb_build_object(
    'ok',true,'resolved',true,'maneuver','trip','success',v_success,
    'attacker_d20',p_attacker_d20,'attacker_modifier',(v_calc->>'attacker_modifier')::integer,
    'attacker_total',v_attacker_total,'defender_d20',p_defender_d20,
    'defender_total',v_defender_total,'defender_modifier',v_defender_total-p_defender_d20,
    'defender_uses_dex',coalesce(p_defender_uses_dex,false),
    'condition_applied',v_success,'condition_instance_id',v_condition_instance,
    'action_consumed','padrao','round',v_round,'aoo_status',v_calc->>'aoo_status'
  );
END;
$function$
;

-- srd_resolver_derrubar_srd_api(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_attacker_d20 integer, p_defender_d20 integer, p_defender_firm_ground boolean, p_trip_using_weapon boolean)
CREATE OR REPLACE FUNCTION priv.srd_resolver_derrubar_srd_api(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_attacker_d20 integer, p_defender_d20 integer, p_defender_firm_ground boolean DEFAULT false, p_trip_using_weapon boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_defender jsonb;
  v_use_dex boolean;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode resolver esta manobra.';
  END IF;
  v_defender:=priv.srd35_maneuver_profile(p_campaign_id,p_defender_token_id);
  v_use_dex:=(v_defender->>'dexterity_modifier')::integer >
             (v_defender->>'strength_modifier')::integer;
  RETURN priv.srd_resolver_derrubar_srd(
    p_campaign_id,p_attacker_token_id,p_defender_token_id,
    p_attacker_d20,p_defender_d20,v_use_dex,
    p_defender_firm_ground,p_trip_using_weapon
  );
END;
$function$
;

-- srd_resolver_encontrao_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_follow boolean)
CREATE OR REPLACE FUNCTION priv.srd_resolver_encontrao_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_follow boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  p priv.srd_aoo_pending_movements%ROWTYPE;
  c public.campaigns%ROWTYPE;
  calc jsonb;
  tokens jsonb;
  a jsonb;
  d jsonb;
  ax integer; ay integer;
  attx integer; atty integer;
  dx integer; dy integer;
  old_dx integer; old_dy integer;
  sx integer; sy integer;
  nx integer; ny integer;
  candidate_ax integer; candidate_ay integer;
  moved integer:=0;
  blocked boolean:=false;
  follow_blocked boolean:=false;
  follower_active boolean:=true;
  footprint integer;
  af integer;
  total_a integer;
  total_d integer;
  success boolean;
  rnd integer;
  v_combat jsonb;
  state jsonb;
  bychar jsonb;
  actions jsonb;
  vkey text;
  arr jsonb;
  idx integer;
  aidx integer;
  followed boolean:=false;
  remaining_push_ft integer;
  push_step_cost integer;
  diagonal_count integer:=0;
  v_speed_m numeric:=0;
  v_used_squares integer:=0;
  v_used_diagonal_steps integer:=0;
  v_available_move_ft integer:=0;
  v_follow_remaining_ft integer:=0;
  v_follow_step_cost integer;
  v_follow_steps integer:=0;
  v_follow_diagonal_steps integer:=0;
  v_follow_cost_ft integer:=0;
  v_new_moved_squares integer;
  v_new_diagonal_steps integer;
  v_usage jsonb;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode resolver Encontrão.';
  END IF;
  IF p_attacker_d20 NOT BETWEEN 1 AND 20 OR p_defender_d20 NOT BETWEEN 1 AND 20 THEN
    RAISE EXCEPTION 'Use resultados físicos de D20 entre 1 e 20.';
  END IF;

  SELECT * INTO p
    FROM priv.srd_aoo_pending_movements
   WHERE campaign_id=p_campaign_id AND pending_id=p_pending_id
   FOR UPDATE;
  IF NOT FOUND OR p.status<>'waiting_reactions'
     OR NOT (p.threats @> '[{"maneuver_event":"bull_rush"}]'::jsonb) THEN
    RAISE EXCEPTION 'Encontrão pendente não encontrado.';
  END IF;
  IF EXISTS(
    SELECT 1 FROM jsonb_array_elements(p.pending_reactions) r
     WHERE r->>'status' IN ('waiting','reserved','attack_started','hit_pending_damage')
  ) THEN RAISE EXCEPTION 'Resolva todas as reações antes do teste resistido.'; END IF;

  SELECT * INTO c FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF upper(coalesce(c.state,''))<>'COMBATE'
     OR coalesce(c.combat_data->>'active','false')<>'true'
     OR greatest(1,coalesce(nullif(c.combat_data->>'round','')::integer,0))<>p.combat_round
     OR coalesce(nullif(c.combat_data->>'current_turn','')::integer,-1)<>p.current_turn THEN
    RAISE EXCEPTION 'O turno ou a rodada mudou; manobra cancelada.';
  END IF;

  calc:=public.srd_consultar_modificadores_manobra_srd(
    p_campaign_id,p.mover_token_id,p.threats->0->>'defender_token_id','bull_rush',false
  );
  total_a:=p_attacker_d20+(calc->>'attacker_modifier')::integer;
  total_d:=p_defender_d20+(calc->>'defender_modifier')::integer;
  success:=total_a>total_d;

  rnd:=p.combat_round;
  vkey:=p.mover_token_id;
  v_combat:=coalesce(c.combat_data,'{}'::jsonb);
  state:=coalesce(v_combat->'action_economy','{}'::jsonb);
  IF jsonb_typeof(state)='object' AND coalesce(state->>'round','')=rnd::text THEN
    bychar:=coalesce(state->'by_character','{}'::jsonb);
  ELSE
    bychar:='{}'::jsonb;
  END IF;
  actions:=CASE WHEN jsonb_typeof(bychar->vkey)='object' THEN bychar->vkey ELSE '{}'::jsonb END;
  IF coalesce((actions->>'padrao')::boolean,false) THEN RAISE EXCEPTION 'A ação padrão já foi consumida.'; END IF;
  IF priv.srd_condition_has_flag(p_campaign_id,'token',vkey,'no_actions')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',vkey,'only_move_action')
     OR priv.srd_condition_has_flag(p_campaign_id,'character',vkey,'no_actions')
     OR priv.srd_condition_has_flag(p_campaign_id,'character',vkey,'only_move_action')
     OR (nullif(calc->'attacker'->>'character_id','') IS NOT NULL AND (
       priv.srd_condition_has_flag(p_campaign_id,'character',calc->'attacker'->>'character_id','no_actions')
       OR priv.srd_condition_has_flag(p_campaign_id,'character',calc->'attacker'->>'character_id','only_move_action')
     )) THEN
    RAISE EXCEPTION 'As condições impedem Encontrão.';
  END IF;
  actions:=actions||jsonb_build_object('padrao',true);
  bychar:=jsonb_set(bychar,ARRAY[vkey],actions,true);
  v_combat:=v_combat||jsonb_build_object(
    'action_economy',jsonb_build_object('round',rnd,'by_character',bychar)
  );

  IF success THEN
    tokens:=coalesce(c.cba_data->'tokens','[]'::jsonb);
    SELECT t,ordinality INTO d,idx
      FROM jsonb_array_elements(tokens) WITH ORDINALITY t
     WHERE t->>'id'=p.threats->0->>'defender_token_id'
        OR t->>'key'=p.threats->0->>'defender_token_id'
     LIMIT 1;
    SELECT t,ordinality INTO a,aidx
      FROM jsonb_array_elements(tokens) WITH ORDINALITY t
     WHERE t->>'id'=p.mover_token_id OR t->>'key'=p.mover_token_id
     LIMIT 1;
    IF d IS NULL OR a IS NULL THEN RAISE EXCEPTION 'Um dos tokens saiu da cena antes da resolução.'; END IF;
    IF coalesce(a->>'gridX','') !~ '^[0-9]{1,3}$' OR coalesce(a->>'gridY','') !~ '^[0-9]{1,3}$'
       OR coalesce(d->>'gridX','') !~ '^[0-9]{1,3}$' OR coalesce(d->>'gridY','') !~ '^[0-9]{1,3}$' THEN
      RAISE EXCEPTION 'A posição de um dos tokens é inválida.';
    END IF;

    ax:=(a->>'gridX')::integer;
    ay:=(a->>'gridY')::integer;
    attx:=ax; atty:=ay;
    dx:=(d->>'gridX')::integer;
    dy:=(d->>'gridY')::integer;
    old_dx:=dx; old_dy:=dy;
    af:=priv.srd_token_grid_footprint(p_campaign_id,p.mover_token_id);
    footprint:=priv.srd_token_grid_footprint(p_campaign_id,p.threats->0->>'defender_token_id');
    sx:=CASE WHEN dx>ax+af-1 THEN 1 WHEN dx+footprint-1<ax THEN -1 ELSE 0 END;
    sy:=CASE WHEN dy>ay+af-1 THEN 1 WHEN dy+footprint-1<ay THEN -1 ELSE 0 END;

    remaining_push_ft:=5+floor(greatest(0,total_a-total_d)::numeric/5)::integer*5;

    IF p_follow
       AND NOT priv.srd_condition_has_flag(p_campaign_id,'token',vkey,'no_move')
       AND NOT (priv.srd_condition_has_flag(p_campaign_id,'token',vkey,'no_actions')
                AND NOT priv.srd_condition_has_flag(p_campaign_id,'token',vkey,'flee'))
       AND NOT (a->>'tipo'='player' AND priv.srd_condition_has_flag(p_campaign_id,'character',vkey,'no_move'))
       AND NOT (a->>'tipo'='player'
                AND priv.srd_condition_has_flag(p_campaign_id,'character',vkey,'no_actions')
                AND NOT priv.srd_condition_has_flag(p_campaign_id,'character',vkey,'flee')) THEN
      v_speed_m:=priv.srd_effective_token_speed_m(p_campaign_id,vkey);
      v_usage:=coalesce(v_combat->'movement_usage','{}'::jsonb);
      IF v_usage->>'character_id'=vkey
         AND v_usage->>'round'=rnd::text
         AND v_usage->>'current_turn'=p.current_turn::text
         AND coalesce(v_usage->>'moved_squares','') ~ '^[0-9]+$' THEN
        v_used_squares:=(v_usage->>'moved_squares')::integer;
        IF coalesce(v_usage->>'diagonal_steps','') ~ '^[0-9]+$' THEN
          v_used_diagonal_steps:=(v_usage->>'diagonal_steps')::integer;
        END IF;
      END IF;
      v_available_move_ft:=greatest(0,floor(v_speed_m/1.5)::integer*5-v_used_squares*5);
      v_follow_remaining_ft:=v_available_move_ft;
      IF v_speed_m<=0 OR v_available_move_ft<5 THEN
        follower_active:=false;
        follow_blocked:=true;
      END IF;
    ELSE
      follower_active:=false;
      IF p_follow THEN follow_blocked:=true; END IF;
    END IF;

    WHILE remaining_push_ft>=5 AND (sx<>0 OR sy<>0) LOOP
      push_step_cost:=CASE WHEN sx<>0 AND sy<>0 AND mod(diagonal_count,2)=1 THEN 10 ELSE 5 END;
      IF remaining_push_ft<push_step_cost THEN EXIT; END IF;

      nx:=dx+sx;
      ny:=dy+sy;
      IF nx<0 OR ny<0 OR nx+footprint>200 OR ny+footprint>200 THEN
        blocked:=true;
        EXIT;
      END IF;

      IF EXISTS(
        SELECT 1 FROM jsonb_array_elements(tokens) t
         WHERE t->>'id' IS DISTINCT FROM p.threats->0->>'defender_token_id'
           AND t->>'key' IS DISTINCT FROM p.threats->0->>'defender_token_id'
           AND t->>'id' IS DISTINCT FROM p.mover_token_id
           AND t->>'key' IS DISTINCT FROM p.mover_token_id
           AND coalesce(t->>'gridX','') ~ '^[0-9]{1,3}$'
           AND coalesce(t->>'gridY','') ~ '^[0-9]{1,3}$'
           AND nx<(t->>'gridX')::integer+priv.srd_token_grid_footprint(p_campaign_id,coalesce(t->>'id',t->>'key'))
           AND nx+footprint>(t->>'gridX')::integer
           AND ny<(t->>'gridY')::integer+priv.srd_token_grid_footprint(p_campaign_id,coalesce(t->>'id',t->>'key'))
           AND ny+footprint>(t->>'gridY')::integer
      ) THEN
        blocked:=true;
        EXIT;
      END IF;

      IF follower_active THEN
        candidate_ax:=dx;
        candidate_ay:=dy;
        v_follow_step_cost:=CASE
          WHEN sx<>0 AND sy<>0 AND mod(v_used_diagonal_steps+v_follow_diagonal_steps,2)=1 THEN 10
          ELSE 5
        END;
        IF v_follow_remaining_ft<v_follow_step_cost
           OR candidate_ax<0 OR candidate_ay<0
           OR candidate_ax+af>200 OR candidate_ay+af>200
           OR (candidate_ax<nx+footprint AND candidate_ax+af>nx
               AND candidate_ay<ny+footprint AND candidate_ay+af>ny)
           OR EXISTS(
             SELECT 1 FROM jsonb_array_elements(tokens) t
              WHERE t->>'id' IS DISTINCT FROM p.mover_token_id
                AND t->>'key' IS DISTINCT FROM p.mover_token_id
                AND t->>'id' IS DISTINCT FROM p.threats->0->>'defender_token_id'
                AND t->>'key' IS DISTINCT FROM p.threats->0->>'defender_token_id'
                AND coalesce(t->>'gridX','') ~ '^[0-9]{1,3}$'
                AND coalesce(t->>'gridY','') ~ '^[0-9]{1,3}$'
                AND candidate_ax<(t->>'gridX')::integer+priv.srd_token_grid_footprint(p_campaign_id,coalesce(t->>'id',t->>'key'))
                AND candidate_ax+af>(t->>'gridX')::integer
                AND candidate_ay<(t->>'gridY')::integer+priv.srd_token_grid_footprint(p_campaign_id,coalesce(t->>'id',t->>'key'))
                AND candidate_ay+af>(t->>'gridY')::integer
           ) THEN
          follower_active:=false;
          follow_blocked:=true;
        ELSE
          attx:=candidate_ax;
          atty:=candidate_ay;
          v_follow_steps:=v_follow_steps+1;
          v_follow_cost_ft:=v_follow_cost_ft+v_follow_step_cost;
          v_follow_remaining_ft:=v_follow_remaining_ft-v_follow_step_cost;
          IF sx<>0 AND sy<>0 THEN
            v_follow_diagonal_steps:=v_follow_diagonal_steps+1;
          END IF;
          followed:=true;
        END IF;
      END IF;

      dx:=nx;
      dy:=ny;
      moved:=moved+1;
      remaining_push_ft:=remaining_push_ft-push_step_cost;
      IF sx<>0 AND sy<>0 THEN diagonal_count:=diagonal_count+1; END IF;
    END LOOP;

    IF followed THEN
      v_new_diagonal_steps:=v_used_diagonal_steps+v_follow_diagonal_steps;
      v_new_moved_squares:=v_used_squares+v_follow_steps
        +floor(v_new_diagonal_steps/2.0)::integer
        -floor(v_used_diagonal_steps/2.0)::integer;
      v_combat:=v_combat||jsonb_build_object(
        'movement_usage',jsonb_build_object(
          'round',rnd,
          'current_turn',p.current_turn,
          'character_id',vkey,
          'moved_squares',v_new_moved_squares,
          'diagonal_steps',v_new_diagonal_steps
        )
      );
    END IF;

    SELECT jsonb_agg(
      CASE
        WHEN ordinality=idx THEN d||jsonb_build_object('gridX',dx,'gridY',dy)
        WHEN ordinality=aidx AND followed THEN a||jsonb_build_object('gridX',attx,'gridY',atty)
        ELSE value
      END ORDER BY ordinality
    ) INTO arr
    FROM jsonb_array_elements(tokens) WITH ORDINALITY;

    UPDATE public.campaigns
       SET cba_data=coalesce(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',arr),
           combat_data=v_combat
     WHERE id=p_campaign_id;
  ELSE
    UPDATE public.campaigns SET combat_data=v_combat WHERE id=p_campaign_id;
  END IF;

  UPDATE priv.srd_aoo_pending_movements
     SET status='committed',committed_at=now(),updated_at=now()
   WHERE pending_id=p_pending_id;

  PERFORM priv.log(
    p_campaign_id,'COMBAT_MANEUVER',
    jsonb_build_object(
      'maneuver','bull_rush',
      'attacker_token_id',p.mover_token_id,
      'defender_token_id',p.threats->0->>'defender_token_id',
      'attacker_total',total_a,
      'defender_total',total_d,
      'success',success,
      'squares_pushed',moved,
      'remaining_push_ft',remaining_push_ft,
      'blocked',blocked,
      'follow_requested',p_follow,
      'attacker_followed',followed,
      'attacker_follow_squares',v_follow_steps,
      'attacker_follow_ft',v_follow_cost_ft,
      'follow_blocked',follow_blocked,
      'remaining_movement_ft',greatest(0,v_follow_remaining_ft)
    )
  );

  RETURN jsonb_build_object(
    'ok',true,
    'resolved',true,
    'maneuver','bull_rush',
    'success',success,
    'attacker_total',total_a,
    'defender_total',total_d,
    'squares_pushed',moved,
    'remaining_push_ft',remaining_push_ft,
    'blocked',blocked,
    'attacker_followed',followed,
    'attacker_follow_squares',v_follow_steps,
    'attacker_follow_ft',v_follow_cost_ft,
    'follow_blocked',follow_blocked,
    'remaining_movement_ft',greatest(0,v_follow_remaining_ft),
    'action_consumed','padrao'
  );
END;
$function$
;

-- srd_resolver_levantar_caido_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid)
CREATE OR REPLACE FUNCTION priv.srd_resolver_levantar_caido_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_pending priv.srd_aoo_pending_movements%ROWTYPE;
  v_campaign public.campaigns%ROWTYPE;
  v_token jsonb; v_count integer;
  v_round integer; v_actions jsonb; v_by jsonb; v_token_actions jsonb;
  v_key text; v_condition_count integer; v_profile jsonb; v_character_id text;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT * INTO v_pending FROM priv.srd_aoo_pending_movements
  WHERE campaign_id=p_campaign_id AND pending_id=p_pending_id FOR UPDATE;
  IF NOT FOUND OR v_pending.status<>'waiting_reactions'
     OR NOT (v_pending.threats @> '[{"standing_event":"stand_up"}]'::jsonb) THEN
    RAISE EXCEPTION 'Levantamento pendente não encontrado.';
  END IF;
  IF EXISTS(SELECT 1 FROM jsonb_array_elements(v_pending.pending_reactions) r
    WHERE r->>'status' IN ('waiting','reserved','attack_started','hit_pending_damage')) THEN
    RAISE EXCEPTION 'Resolva todas as reações de oportunidade antes de concluir o levantamento.';
  END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND OR upper(coalesce(v_campaign.state,''))<>'COMBATE'
     OR coalesce(v_campaign.combat_data->>'active','false')<>'true'
     OR greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
     OR coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn THEN
    RAISE EXCEPTION 'O combate avançou; o levantamento precisa ser reavaliado.';
  END IF;
  SELECT count(*)::integer,(array_agg(t))[1] INTO v_count,v_token
  FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  WHERE t->>'id'=v_pending.mover_token_id OR t->>'key'=v_pending.mover_token_id;
  IF v_count<>1 THEN RAISE EXCEPTION 'Token do levantamento ausente ou duplicado.'; END IF;
  IF public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' AND NOT (
    v_token->>'tipo'='player' AND EXISTS(
      SELECT 1 FROM public.characters ch WHERE ch.id::text=v_pending.mover_token_id
        AND ch.campaign_id=p_campaign_id AND ch.user_id=auth.uid()
    )
  ) THEN RAISE EXCEPTION 'Somente o Mestre ou o jogador dono do personagem pode concluir o levantamento.'; END IF;
  IF priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'no_actions')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'no_move')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'dying')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'stable')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'dead')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'unconscious')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'helpless') THEN
    RAISE EXCEPTION 'O alvo não pode levantar-se após as reações.';
  END IF;
  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,v_pending.mover_token_id);
  v_character_id:=v_profile->>'character_id';
  IF v_character_id IS NOT NULL AND (
    priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_actions')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_move')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'dying')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'stable')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'dead')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'unconscious')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'helpless')
  ) THEN
    RAISE EXCEPTION 'A ficha do personagem não permite levantar-se.';
  END IF;
  IF NOT EXISTS(SELECT 1 FROM public.srd_campaign_conditions
    WHERE campaign_id=p_campaign_id AND target_kind='token'
      AND target_id IN (v_pending.mover_token_id,coalesce(v_token->>'key',v_token->>'id'))
      AND condition_id='prone' AND active=true) THEN
    RAISE EXCEPTION 'O alvo não está mais Caído.';
  END IF;

  v_round:=v_pending.combat_round;
  v_actions:=v_campaign.combat_data->'action_economy';
  IF jsonb_typeof(v_actions)='object' AND coalesce(v_actions->>'round','')=v_round::text
     AND jsonb_typeof(v_actions->'by_character')='object' THEN
    v_by:=v_actions->'by_character';
  ELSE v_by:='{}'::jsonb; END IF;
  v_key:=v_pending.mover_token_id;
  v_token_actions:=CASE WHEN jsonb_typeof(v_by->v_key)='object' THEN v_by->v_key ELSE '{}'::jsonb END;
  IF coalesce((v_token_actions->>'movimento')::boolean,false) THEN
    RAISE EXCEPTION 'A ação de movimento deste combatente já foi usada.';
  END IF;
  IF priv.srd_condition_has_flag(p_campaign_id,'token',v_key,'one_move_or_standard')
     AND coalesce((v_token_actions->>'padrao')::boolean,false) THEN
    RAISE EXCEPTION 'As condições impedem gastar movimento depois de uma ação padrão.';
  END IF;
  v_token_actions:=v_token_actions||jsonb_build_object('movimento',true);
  v_by:=jsonb_set(v_by,ARRAY[v_key],v_token_actions,true);
  v_actions:=jsonb_build_object('round',v_round,'by_character',v_by);
  UPDATE public.campaigns SET combat_data=coalesce(combat_data,'{}'::jsonb)||
    jsonb_build_object('action_economy',v_actions) WHERE id=p_campaign_id;

  UPDATE public.srd_campaign_conditions SET active=false
  WHERE campaign_id=p_campaign_id AND target_kind='token'
    AND target_id IN (v_pending.mover_token_id,coalesce(v_token->>'key',v_token->>'id'))
    AND condition_id='prone' AND active=true;
  UPDATE priv.srd_aoo_pending_movements SET status='committed',committed_at=now(),updated_at=now()
  WHERE pending_id=p_pending_id AND campaign_id=p_campaign_id;
  PERFORM priv.log(p_campaign_id,'COMBAT_CONDITION',jsonb_build_object(
    'condition','prone','action','removed','reason','stand_up',
    'token_id',v_pending.mover_token_id,'action_consumed','movimento',
    'round',v_round,'reactions',v_pending.pending_reactions
  ));
  RETURN jsonb_build_object('ok',true,'stood_up',true,'token_id',v_pending.mover_token_id,
    'action_consumed','movimento','round',v_round,'reactions',v_pending.pending_reactions);
END;
$function$
;

-- srd_restore_surprised_flatfooted(p_campaign_id bigint, p_turn_order jsonb, p_aware_ids text[])
CREATE OR REPLACE FUNCTION priv.srd_restore_surprised_flatfooted(p_campaign_id bigint, p_turn_order jsonb, p_aware_ids text[])
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE v_entry jsonb;v_id text;v_kind text;v_count integer:=0;
BEGIN
 FOR v_entry IN SELECT value FROM jsonb_array_elements(coalesce(p_turn_order,'[]'::jsonb)) q(value)
 LOOP
  v_id:=nullif(btrim(v_entry->>'id'),'');
  IF v_id IS NULL OR v_id=ANY(coalesce(p_aware_ids,ARRAY[]::text[])) THEN CONTINUE; END IF;
  v_kind:=CASE WHEN coalesce((v_entry->>'is_monster')::boolean,false) THEN 'token' ELSE 'character' END;
  IF NOT EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc WHERE cc.campaign_id=p_campaign_id
    AND cc.target_kind=v_kind AND cc.target_id=v_id AND cc.condition_id='flatfooted'
    AND cc.active=true AND cc.notes->>'source_feature'='combat_flatfooted') THEN
   INSERT INTO public.srd_campaign_conditions(campaign_id,target_kind,target_id,condition_id,source_actor_id,started_round,active,notes)
   VALUES(p_campaign_id,v_kind,v_id,'flatfooted',null,1,true,
    jsonb_build_object('source_feature','combat_flatfooted','rule','until_first_normal_turn','surprise_round',true));
   v_count:=v_count+1;
  END IF;
 END LOOP;
 RETURN v_count;
END;
$function$
;

-- srd_saving_throw_bonus(p_campaign_id bigint, p_target_kind text, p_target_id text, p_save_type text, p_context text)
CREATE OR REPLACE FUNCTION priv.srd_saving_throw_bonus(p_campaign_id bigint, p_target_kind text, p_target_id text, p_save_type text, p_context text DEFAULT NULL::text)
 RETURNS integer
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_save text:=lower(COALESCE(p_save_type,''));
  v_ability text;
  v_score integer;
  v_base integer:=0;
  v_bonus integer:=0;
  v_save_text text;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_token jsonb; v_token_count integer;
  v_feats jsonb; v_ability_effect text; v_charisma_score integer; v_paladin_level integer:=0; v_barbarian_level integer:=0; v_rogue_level integer:=0; v_monk_level integer:=0;
BEGIN
  IF v_save NOT IN ('fortitude','reflex','will') THEN RAISE EXCEPTION 'Tipo de resistência inválido.'; END IF;
  IF p_target_kind='character' THEN
    SELECT sh.* INTO v_sheet
    FROM public.srd_character_sheets sh
    JOIN public.characters ch ON ch.id=sh.character_id
    WHERE ch.id::text=BTRIM(p_target_id) AND ch.campaign_id=p_campaign_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Ficha do alvo não encontrada para calcular resistência.'; END IF;
    v_ability:=CASE v_save WHEN 'fortitude' THEN 'CON' WHEN 'reflex' THEN 'DES' ELSE 'SAB' END;
    v_score:=COALESCE(NULLIF(v_sheet.atributos->>v_ability,'')::integer,10);
    v_ability_effect:=CASE v_save WHEN 'fortitude' THEN 'constitution' WHEN 'reflex' THEN 'dexterity' ELSE 'wisdom' END;
    v_score:=v_score+priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_target_id),v_ability_effect);
    v_feats:=COALESCE(v_sheet.talentos,'[]'::jsonb);
    SELECT COALESCE(sum(CASE v_save WHEN 'fortitude' THEN pr.base_fortitude WHEN 'reflex' THEN pr.base_reflex ELSE pr.base_will END),0)::integer
      INTO v_base
      FROM public.srd_character_class_levels cl
      JOIN public.srd_class_level_progressions pr ON pr.class_id=cl.class_id AND pr.class_level=cl.class_level
     WHERE cl.character_id=v_sheet.character_id;
    IF NOT EXISTS(SELECT 1 FROM public.srd_character_class_levels WHERE character_id=v_sheet.character_id) THEN
      SELECT CASE v_save WHEN 'fortitude' THEN pr.base_fortitude WHEN 'reflex' THEN pr.base_reflex ELSE pr.base_will END
        INTO v_base
        FROM public.srd_class_level_progressions pr
       WHERE pr.class_id=v_sheet.classe_id AND pr.class_level=v_sheet.nivel;
      IF v_base IS NULL THEN
        SELECT CASE v_save
          WHEN 'fortitude' THEN CASE WHEN cl.fort_bom THEN floor(v_sheet.nivel/2.0)::integer+2 ELSE floor(v_sheet.nivel/3.0)::integer END
          WHEN 'reflex' THEN CASE WHEN cl.ref_bom THEN floor(v_sheet.nivel/2.0)::integer+2 ELSE floor(v_sheet.nivel/3.0)::integer END
          ELSE CASE WHEN cl.von_bom THEN floor(v_sheet.nivel/2.0)::integer+2 ELSE floor(v_sheet.nivel/3.0)::integer END
        END INTO v_base FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
      END IF;
    END IF;
    v_bonus:=COALESCE(v_base,0)+FLOOR((v_score-10)::numeric/2)::integer;
    -- Bônus passivos de resistência vêm dos efeitos mecânicos estruturados dos talentos.
    v_bonus:=v_bonus+priv.srd_feat_saving_throw_modifier(v_feats,v_save);
  ELSIF p_target_kind='token' THEN
    SELECT count(*)::integer,(array_agg(t.value))[1] INTO v_token_count,v_token
    FROM public.campaigns c
    CROSS JOIN LATERAL jsonb_array_elements(CASE WHEN jsonb_typeof(c.cba_data->'tokens')='array' THEN c.cba_data->'tokens' ELSE '[]'::jsonb END) t(value)
    WHERE c.id=p_campaign_id AND (t.value->>'id'=BTRIM(p_target_id) OR t.value->>'key'=BTRIM(p_target_id));
    IF v_token_count<>1 THEN RAISE EXCEPTION 'Token-alvo ausente ou duplicado para calcular resistência.'; END IF;
    IF NULLIF(v_token->>'sourceCharacterId','') IS NOT NULL THEN
      SELECT sh.* INTO v_sheet FROM public.srd_character_sheets sh
      JOIN public.characters ch ON ch.id=sh.character_id
      WHERE ch.id::text=NULLIF(v_token->>'sourceCharacterId','')
        AND ch.campaign_id=p_campaign_id;
    END IF;
    IF v_sheet.character_id IS NOT NULL THEN
      v_ability:=CASE v_save WHEN 'fortitude' THEN 'CON' WHEN 'reflex' THEN 'DES' ELSE 'SAB' END;
      v_score:=COALESCE(NULLIF(v_sheet.atributos->>v_ability,'')::integer,10);
      v_ability_effect:=CASE v_save WHEN 'fortitude' THEN 'constitution' WHEN 'reflex' THEN 'dexterity' ELSE 'wisdom' END;
      v_score:=v_score+priv.srd_effective_modifier(p_campaign_id,'token',BTRIM(p_target_id),v_ability_effect);
      v_feats:=COALESCE(v_sheet.talentos,'[]'::jsonb);
      SELECT COALESCE(sum(CASE v_save WHEN 'fortitude' THEN pr.base_fortitude WHEN 'reflex' THEN pr.base_reflex ELSE pr.base_will END),0)::integer
        INTO v_base FROM public.srd_character_class_levels cl
        JOIN public.srd_class_level_progressions pr ON pr.class_id=cl.class_id AND pr.class_level=cl.class_level
       WHERE cl.character_id=v_sheet.character_id;
      IF NOT EXISTS(SELECT 1 FROM public.srd_character_class_levels WHERE character_id=v_sheet.character_id) THEN
        SELECT CASE v_save WHEN 'fortitude' THEN pr.base_fortitude WHEN 'reflex' THEN pr.base_reflex ELSE pr.base_will END
          INTO v_base FROM public.srd_class_level_progressions pr
         WHERE pr.class_id=v_sheet.classe_id AND pr.class_level=v_sheet.nivel;
        IF v_base IS NULL THEN
          SELECT CASE v_save
            WHEN 'fortitude' THEN CASE WHEN cl.fort_bom THEN floor(v_sheet.nivel/2.0)::integer+2 ELSE floor(v_sheet.nivel/3.0)::integer END
            WHEN 'reflex' THEN CASE WHEN cl.ref_bom THEN floor(v_sheet.nivel/2.0)::integer+2 ELSE floor(v_sheet.nivel/3.0)::integer END
            ELSE CASE WHEN cl.von_bom THEN floor(v_sheet.nivel/2.0)::integer+2 ELSE floor(v_sheet.nivel/3.0)::integer END END
            INTO v_base FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
        END IF;
      END IF;
      v_bonus:=COALESCE(v_base,0)+FLOOR((v_score-10)::numeric/2)::integer+priv.srd_feat_saving_throw_modifier(v_feats,v_save);
    ELSE
    v_save_text:=CASE v_save
      WHEN 'fortitude' THEN COALESCE(v_token->'monsterStats'->>'fortitude',v_token->'monsterStats'->>'fort')
      WHEN 'reflex' THEN COALESCE(v_token->'monsterStats'->>'reflexos',v_token->'monsterStats'->>'reflex')
      ELSE COALESCE(v_token->'monsterStats'->>'vontade',v_token->'monsterStats'->>'will') END;
    v_base:=COALESCE(NULLIF(substring(COALESCE(v_save_text,'') FROM '[-+]?[0-9]+'),'')::integer,0);
    v_bonus:=v_base;
    END IF;
  ELSE
    RAISE EXCEPTION 'Tipo de alvo inválido para resistência.';
  END IF;
  -- D&D 3.5: Graça Divina também usa a ficha vinculada quando o alvo é um NPC.
  IF v_sheet.character_id IS NOT NULL THEN
    SELECT COALESCE(MAX(cl.class_level),0) INTO v_paladin_level
      FROM public.srd_character_class_levels cl
      JOIN public.srd_classes cls ON cls.id=cl.class_id
     WHERE cl.character_id=v_sheet.character_id AND cls.class_key='paladin';
    IF v_paladin_level=0 AND NOT EXISTS (SELECT 1 FROM public.srd_character_class_levels WHERE character_id=v_sheet.character_id)
       AND v_sheet.classe_id='paladino' THEN
      v_paladin_level:=v_sheet.nivel;
    END IF;
    IF v_paladin_level>=2 THEN
      v_charisma_score:=COALESCE(NULLIF(v_sheet.atributos->>'CAR','')::integer,10)
        +priv.srd_effective_modifier(p_campaign_id,p_target_kind,BTRIM(p_target_id),'charisma');
      v_bonus:=v_bonus+GREATEST(0,FLOOR((v_charisma_score-10)::numeric/2)::integer);
    END IF;
  END IF;
  v_bonus:=v_bonus
    +priv.srd_effective_modifier(p_campaign_id,p_target_kind,BTRIM(p_target_id),v_save)
    +priv.srd_effective_modifier(p_campaign_id,p_target_kind,BTRIM(p_target_id),'saving_throw');
  IF lower(COALESCE(p_context,'')) LIKE '%fear%' THEN
    v_bonus:=v_bonus+priv.srd_effective_modifier(p_campaign_id,p_target_kind,BTRIM(p_target_id),'fear_saving_throw');
  END IF;
  -- Trap Sense: Bárbaro e Ladino recebem +1 em CA e Reflexos contra armadilhas a cada três níveis; os bônus não se acumulam.
  IF v_save='reflex' AND lower(COALESCE(p_context,'')) LIKE '%trap%'
     AND v_sheet.character_id IS NOT NULL THEN
    SELECT COALESCE(
      MAX(cl.class_level) FILTER (WHERE cls.class_key='barbarian'),
      CASE WHEN NOT EXISTS (SELECT 1 FROM public.srd_character_class_levels any_level WHERE any_level.character_id=v_sheet.character_id)
        AND v_sheet.classe_id='barbaro' THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
    ),
    COALESCE(
      MAX(cl.class_level) FILTER (WHERE cls.class_key='rogue'),
      CASE WHEN NOT EXISTS (SELECT 1 FROM public.srd_character_class_levels any_level WHERE any_level.character_id=v_sheet.character_id)
        AND v_sheet.classe_id='ladino' THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
    )
      INTO v_barbarian_level,v_rogue_level
      FROM public.srd_character_sheets sh
      LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
      LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
     WHERE sh.character_id=v_sheet.character_id
     GROUP BY sh.character_id,sh.classe_id,sh.nivel;
    v_bonus:=v_bonus+GREATEST(
      FLOOR(COALESCE(v_barbarian_level,0)/3.0)::integer,
      FLOOR(COALESCE(v_rogue_level,0)/3.0)::integer
    );
  END IF;

  -- Indomitable Will (Bárbaro 14): +4 contra magias da escola Encantamento,
  -- enquanto estiver em Fúria. É bônus separado e acumula com o bônus moral da Fúria.
  IF v_save='will' AND lower(COALESCE(p_context,'')) LIKE '%enchantment%'
     AND v_sheet.character_id IS NOT NULL
     AND priv.srd_effect_has_flag(p_campaign_id,p_target_kind,BTRIM(p_target_id),'rage_active') THEN
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
    IF COALESCE(v_barbarian_level,0)>=14 THEN v_bonus:=v_bonus+4; END IF;
  END IF;
  -- Mente Tranquila (Monge 3): +2 em Vontade contra magias e efeitos de Encantamento.
  IF v_save='will' AND lower(COALESCE(p_context,'')) LIKE '%enchantment%'
     AND v_sheet.character_id IS NOT NULL THEN
    SELECT COALESCE(
      MAX(cl.class_level) FILTER (WHERE cls.class_key='monk'),
      CASE WHEN NOT EXISTS (
        SELECT 1 FROM public.srd_character_class_levels any_level
         WHERE any_level.character_id=v_sheet.character_id
      ) AND v_sheet.classe_id='monge'
      THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
    )
      INTO v_monk_level
      FROM public.srd_character_sheets sh
      LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
      LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
     WHERE sh.character_id=v_sheet.character_id
     GROUP BY sh.character_id,sh.classe_id,sh.nivel;
    IF COALESCE(v_monk_level,0)>=3 THEN v_bonus:=v_bonus+2; END IF;
  END IF;

  -- D&D 3.5 Livro do Jogador, Cap. 2: resistências raciais para fichas e NPCs vinculados.
  IF v_sheet.character_id IS NOT NULL THEN
    -- Anão: +2 contra venenos e magias/efeitos similares a magia.
    IF v_sheet.raca_id='anao'
       AND (lower(COALESCE(p_context,'')) LIKE '%poison%'
         OR lower(COALESCE(p_context,'')) LIKE '%spell%') THEN
      v_bonus:=v_bonus+2;
    END IF;
    -- Halfling: +1 em todos os testes de resistência; +2 moral adicional contra medo.
    IF v_sheet.raca_id='halfling' THEN
      v_bonus:=v_bonus+1;
      IF lower(COALESCE(p_context,'')) LIKE '%fear%' THEN
        v_bonus:=v_bonus+2;
      END IF;
    END IF;
    -- Elfo e meio-elfo: +2 contra magias/efeitos de Encantamento.
    IF v_sheet.raca_id IN ('elfo','meio_elfo')
       AND lower(COALESCE(p_context,'')) LIKE '%enchantment%' THEN
      v_bonus:=v_bonus+2;
    END IF;
    -- Gnomo: +2 contra ilusões.
    IF v_sheet.raca_id='gnomo'
       AND lower(COALESCE(p_context,'')) LIKE '%illusion%' THEN
      v_bonus:=v_bonus+2;
    END IF;
  END IF;

  RETURN v_bonus;
END;
$function$
;

-- srd_spell_penetration_feat_bonus(p_character_id text)
CREATE OR REPLACE FUNCTION priv.srd_spell_penetration_feat_bonus(p_character_id text)
 RETURNS integer
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  SELECT COALESCE(SUM(per_feat.value),0)::integer
  FROM (
    SELECT feat.id, MAX((effect.value->>'value')::integer) AS value
    FROM public.srd_character_sheets AS sheet
    CROSS JOIN LATERAL jsonb_array_elements(
      CASE WHEN jsonb_typeof(sheet.talentos)='array'
        THEN sheet.talentos ELSE '[]'::jsonb END
    ) AS chosen(value)
    JOIN public.srd_feats AS feat
      ON feat.id=COALESCE(chosen.value->>'id',chosen.value #>> '{}')
    CROSS JOIN LATERAL jsonb_array_elements(
      CASE WHEN jsonb_typeof(feat.mechanics#>'{resolution,effects}')='array'
        THEN feat.mechanics#>'{resolution,effects}' ELSE '[]'::jsonb END
    ) AS effect(value)
    WHERE sheet.character_id::text=BTRIM(p_character_id)
      AND feat.mechanics->>'engine_status' IN ('ready','implemented')
      AND feat.mechanics->'activation'->>'mode'='passive'
      AND effect.value->>'kind'='modifier'
      AND effect.value->>'stat'='spell_penetration'
      AND COALESCE(effect.value->>'value','') ~ '^[0-9]+$'
    GROUP BY feat.id
  ) AS per_feat;
$function$
;

-- srd_spell_resistance_value(p_campaign_id bigint, p_target_kind text, p_target_id text)
CREATE OR REPLACE FUNCTION priv.srd_spell_resistance_value(p_campaign_id bigint, p_target_kind text, p_target_id text)
 RETURNS integer
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_text text;
  v_token jsonb;
  v_token_count integer;
  v_qualities text;
  v_match text[];
  v_value integer;
BEGIN
  IF p_campaign_id IS NULL OR NULLIF(BTRIM(p_target_id),'') IS NULL THEN
    RAISE EXCEPTION 'Alvo inválido para resistência à magia.';
  END IF;

  IF p_target_kind='character' THEN
    IF NOT EXISTS (
      SELECT 1 FROM public.characters ch
      WHERE ch.id::text=BTRIM(p_target_id)
        AND ch.campaign_id=p_campaign_id
    ) THEN
      RAISE EXCEPTION 'Personagem-alvo não encontrado na campanha.';
    END IF;
    RETURN GREATEST(0,priv.srd_effective_modifier(
      p_campaign_id,'character',BTRIM(p_target_id),'spell_resistance'
    ));
  ELSIF p_target_kind<>'token' THEN
    RAISE EXCEPTION 'Tipo de alvo inválido para resistência à magia.';
  END IF;

  SELECT count(*)::integer, (array_agg(t.value))[1]
    INTO v_token_count,v_token
  FROM public.campaigns c
  CROSS JOIN LATERAL jsonb_array_elements(
    CASE WHEN jsonb_typeof(c.cba_data->'tokens')='array'
      THEN c.cba_data->'tokens' ELSE '[]'::jsonb END
  ) t(value)
  WHERE c.id=p_campaign_id
    AND (t.value->>'id'=BTRIM(p_target_id) OR t.value->>'key'=BTRIM(p_target_id));

  IF v_token_count<>1 THEN
    RAISE EXCEPTION 'Token-alvo ausente ou duplicado ao verificar resistência à magia.';
  END IF;

  v_text:=COALESCE(
    v_token->'monsterStats'->>'spell_resistance',
    v_token->'monsterStats'->>'resistencia_magia'
  );
  v_value:=COALESCE(
    NULLIF(substring(COALESCE(v_text,'') FROM '[0-9]+'),'')::integer,
    0
  );
  v_qualities:=lower(COALESCE(
    v_token->'monsterStats'->'qualidades_especiais'->>'special_qualities',
    v_token->'monsterStats'->'dados_tecnicos'->'statblock'->>'special_qualities',
    v_token->'monsterStats'->>'special_qualities',
    ''
  ));

  IF v_value=0 THEN
    v_match:=regexp_match(v_qualities,'spell resistance[[:space:]]+([0-9]+)');
    IF v_match IS NOT NULL THEN
      v_value:=v_match[1]::integer;
    END IF;
  END IF;

  RETURN GREATEST(0,COALESCE(v_value,0));
END;
$function$
;

-- srd_start_combat_flatfooted(p_campaign_id bigint, p_turn_order jsonb, p_first_turn integer)
CREATE OR REPLACE FUNCTION priv.srd_start_combat_flatfooted(p_campaign_id bigint, p_turn_order jsonb, p_first_turn integer DEFAULT 0)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare v_entry jsonb; v_kind text; v_id text; v_added integer:=0; v_first jsonb;
begin
 if jsonb_typeof(p_turn_order) is distinct from 'array' then raise exception 'Fila de iniciativa inválida.'; end if;
 for v_entry in select value from jsonb_array_elements(p_turn_order) as entries(value)
 loop
  v_id:=nullif(btrim(v_entry->>'id'),'');
  if v_id is null then continue; end if;
  v_kind:=case when coalesce((v_entry->>'is_monster')::boolean,false) then 'token' else 'character' end;
  if not exists(select 1 from public.srd_campaign_conditions cc where cc.campaign_id=p_campaign_id
    and cc.target_kind=v_kind and cc.target_id=v_id and cc.condition_id='flatfooted' and cc.active=true) then
   insert into public.srd_campaign_conditions(campaign_id,target_kind,target_id,condition_id,source_actor_id,started_round,expires_round,active,notes)
   values(p_campaign_id,v_kind,v_id,'flatfooted',null,1,null,true,
    jsonb_build_object('source_feature','combat_flatfooted','rule','until_first_turn','initiative_id',v_id));
   v_added:=v_added+1;
  end if;
 end loop;
 if jsonb_array_length(p_turn_order)>0 then
  v_first:=p_turn_order->greatest(0,least(jsonb_array_length(p_turn_order)-1,coalesce(p_first_turn,0)));
  perform priv.srd_clear_combat_flatfooted_actor(p_campaign_id,v_first);
 end if;
 return jsonb_build_object('applied',v_added,'first_actor_id',v_first->>'id');
end;
$function$
;

-- srd_sync_character_vital_condition(p_character_id text, p_pv integer, p_stabilize boolean)
CREATE OR REPLACE FUNCTION priv.srd_sync_character_vital_condition(p_character_id text, p_pv integer, p_stabilize boolean DEFAULT false)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_campaign_id bigint;
  v_round integer;
  v_condition text;
BEGIN
  SELECT campaign_id INTO v_campaign_id
  FROM public.characters
  WHERE id::text=BTRIM(p_character_id);
  IF NOT FOUND OR v_campaign_id IS NULL THEN RETURN NULL; END IF;

  v_condition:=CASE
    WHEN p_pv<=-10 THEN 'dead'
    WHEN p_pv<0 AND p_stabilize THEN 'stable'
    WHEN p_pv<0 THEN 'dying'
    WHEN p_pv=0 THEN 'disabled'
    ELSE NULL END;

  UPDATE public.srd_campaign_conditions
     SET active=false
   WHERE campaign_id=v_campaign_id
     AND target_kind='character'
     AND target_id=BTRIM(p_character_id)
     AND condition_id IN ('dead','dying','disabled','stable')
     AND active=true;

  IF v_condition IS NULL THEN RETURN NULL; END IF;

  SELECT GREATEST(1,COALESCE(NULLIF(combat_data->>'round','')::integer,1))
    INTO v_round
    FROM public.campaigns WHERE id=v_campaign_id;

  INSERT INTO public.srd_campaign_conditions(
    campaign_id,target_kind,target_id,condition_id,started_round,expires_round,active,notes
  ) VALUES (
    v_campaign_id,'character',BTRIM(p_character_id),v_condition,
    COALESCE(v_round,1),NULL,true,
    jsonb_build_object('source','hp_state_engine','pv',p_pv,'stabilized',p_stabilize)
  );
  RETURN v_condition;
END;
$function$
;

-- srd_sync_linked_npc_token_vitals(p_campaign_id bigint, p_token_id text, p_token_hp integer, p_token_max_hp integer)
CREATE OR REPLACE FUNCTION priv.srd_sync_linked_npc_token_vitals(p_campaign_id bigint, p_token_id text, p_token_hp integer, p_token_max_hp integer)
 RETURNS jsonb
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  SELECT priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,p_token_hp,p_token_max_hp,false);
$function$
;

-- srd_sync_linked_npc_token_vitals(p_campaign_id bigint, p_token_id text, p_token_hp integer, p_token_max_hp integer, p_stabilize boolean)
CREATE OR REPLACE FUNCTION priv.srd_sync_linked_npc_token_vitals(p_campaign_id bigint, p_token_id text, p_token_hp integer, p_token_max_hp integer, p_stabilize boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_campaign public.campaigns%ROWTYPE; v_tokens jsonb; v_token jsonb; v_index bigint;
  v_count integer; v_source_id text; v_actual_id text; v_token_key text;
  v_sheet_id bigint; v_rage_bonus integer:=0; v_base_max integer; v_hp integer;
  v_round integer; v_state text; v_dead boolean:=false; v_last_resolved_round integer;
  v_notes jsonb;
BEGIN
  IF p_campaign_id IS NULL OR NULLIF(BTRIM(p_token_id),'') IS NULL
     OR p_token_hp IS NULL OR p_token_max_hp IS NULL OR p_token_max_hp<1 OR p_token_max_hp>100000 THEN
    RAISE EXCEPTION 'Dados de sincronização de PV do NPC inválidos.';
  END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END;
  SELECT count(*)::integer,min(t.ordinality),(array_agg(t.token ORDER BY t.ordinality))[1]
    INTO v_count,v_index,v_token
  FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality)
  WHERE (t.token->>'id'=BTRIM(p_token_id) OR t.token->>'key'=BTRIM(p_token_id)) AND t.token->>'tipo'='npc';
  IF v_count IS DISTINCT FROM 1 THEN RETURN jsonb_build_object('synced',false,'reason','not_a_unique_npc_token'); END IF;
  v_actual_id:=NULLIF(BTRIM(v_token->>'id'),'');
  v_token_key:=NULLIF(BTRIM(v_token->>'key'),'');
  v_source_id:=NULLIF(BTRIM(v_token->>'sourceCharacterId'),'');
  IF v_actual_id IS NULL OR v_source_id IS NULL OR v_source_id !~ '^[0-9]+$' THEN
    RETURN jsonb_build_object('synced',false,'reason','npc_not_linked_to_source_sheet');
  END IF;
  SELECT sh.character_id INTO v_sheet_id
  FROM public.characters ch JOIN public.srd_character_sheets sh ON sh.character_id=ch.id
  WHERE ch.id::text=v_source_id AND (
    ch.user_id=v_campaign.owner_id OR EXISTS(
      SELECT 1 FROM public.members m WHERE m.campaign_id=p_campaign_id AND m.user_id=ch.user_id AND m.role='GM'
    )
  ) FOR UPDATE OF sh;
  IF NOT FOUND THEN RETURN jsonb_build_object('synced',false,'reason','source_sheet_not_owned_by_campaign_gm'); END IF;
  SELECT EXISTS(
    SELECT 1 FROM public.srd_campaign_conditions cc
    WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='token'
      AND cc.target_id IN (v_actual_id,COALESCE(v_token_key,v_actual_id))
      AND cc.condition_id='dead' AND cc.active=true
  ) INTO v_dead;
  SELECT COALESCE(max(NULLIF(e.effect_data->>'rage_hp_bonus','')::integer),0) INTO v_rage_bonus
  FROM public.srd_campaign_effects e
  WHERE e.campaign_id=p_campaign_id AND e.target_kind='token'
    AND e.target_id=v_actual_id AND e.active=true AND e.effect_data->>'source_feature'='barbarian_rage';
  SELECT max(NULLIF(cc.notes->>'last_resolved_round','')::integer)
    INTO v_last_resolved_round
  FROM public.srd_campaign_conditions cc
  WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='token'
    AND cc.target_id IN (v_actual_id,COALESCE(v_token_key,v_actual_id))
    AND cc.condition_id IN ('dead','dying','stable','disabled') AND cc.active=true;
  v_base_max:=GREATEST(1,p_token_max_hp-GREATEST(0,v_rage_bonus));
  v_hp:=CASE WHEN v_dead THEN -10 ELSE GREATEST(-10,LEAST(v_base_max,p_token_hp)) END;
  v_token:=v_token||jsonb_build_object('hp',v_hp,'maxHp',p_token_max_hp);
  SELECT COALESCE(jsonb_agg(CASE WHEN t.ordinality=v_index THEN v_token ELSE t.token END ORDER BY t.ordinality),'[]'::jsonb)
    INTO v_tokens FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality);
  UPDATE public.campaigns SET cba_data=COALESCE(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens) WHERE id=p_campaign_id;
  UPDATE public.srd_character_sheets SET pv_max=v_base_max,pv_atual=GREATEST(-10,LEAST(v_base_max,v_hp)) WHERE character_id=v_sheet_id;
  v_state:=CASE WHEN v_hp<=-10 THEN 'dead' WHEN v_hp<0 AND p_stabilize THEN 'stable'
    WHEN v_hp<0 THEN 'dying' WHEN v_hp=0 THEN 'disabled' ELSE NULL END;
  UPDATE public.srd_campaign_conditions SET active=false
  WHERE campaign_id=p_campaign_id AND target_kind='token'
    AND target_id IN (v_actual_id,COALESCE(v_token_key,v_actual_id))
    AND condition_id IN ('dead','dying','stable','disabled') AND active=true;
  IF v_state IS NOT NULL THEN
    v_round:=GREATEST(1,COALESCE(NULLIF(v_campaign.combat_data->>'round','')::integer,1));
    v_notes:=jsonb_build_object('source','npc_hp_state_engine','pv',v_hp,'stabilized',v_state='stable');
    IF v_last_resolved_round IS NOT NULL THEN
      v_notes:=v_notes||jsonb_build_object('last_resolved_round',v_last_resolved_round);
    END IF;
    INSERT INTO public.srd_campaign_conditions(campaign_id,target_kind,target_id,condition_id,started_round,expires_round,active,notes)
    VALUES(p_campaign_id,'token',v_actual_id,v_state,v_round,NULL,true,v_notes);
  END IF;
  RETURN jsonb_build_object('synced',true,'source_character_id',v_source_id,'token_id',v_actual_id,
    'pv_atual',v_hp,'pv_max',v_base_max,'token_max_hp',p_token_max_hp,'condition',v_state,
    'rage_hp_bonus_excluded',GREATEST(0,v_rage_bonus));
END;
$function$
;

-- srd_token_grid_footprint(p_campaign_id bigint, p_token_id text)
CREATE OR REPLACE FUNCTION priv.srd_token_grid_footprint(p_campaign_id bigint, p_token_id text)
 RETURNS integer
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare v_token jsonb; v_count integer; v_type text; v_size text;
begin
  select count(*)::integer,(array_agg(t))[1] into v_count,v_token
  from jsonb_array_elements(coalesce((select cba_data->'tokens' from public.campaigns where id=p_campaign_id),'[]'::jsonb)) t
  where t->>'id'=btrim(p_token_id) or t->>'key'=btrim(p_token_id);
  if v_count<>1 then raise exception 'Token inexistente ou duplicado ao calcular ocupação na grade.'; end if;
  v_type:=v_token->>'tipo';
  select coalesce(nullif(v_token->'monsterStats'->>'tamanho',''),
                  nullif(v_token->'monsterStats'->>'size',''),
                  nullif(v_token->>'tamanho',''),
                  nullif(v_token->>'size',''),
                  r.tamanho,'Médio')
  into v_size
  from (select 1) seed
  left join lateral (
    select sr.tamanho
    from public.srd_character_sheets sh
    join public.srd_races sr on sr.id::text=sh.raca_id::text
    where sh.character_id::text=coalesce(nullif(v_token->>'sourceCharacterId',''),
      case when v_type='player' then v_token->>'id' end)
    limit 1
  ) r on true;
  v_size:=public.srd35_normalizar_parametro_talento(coalesce(v_size,'medio'));
  return case
    when v_size like 'colossal%' then 6
    when v_size like 'gargantuan%' or v_size like 'imenso%' then 4
    when v_size like 'huge%' or v_size like 'enorme%' then 3
    when v_size like 'large%' or v_size like 'grande%' then 2
    else 1 end;
end;
$function$
;

-- srd_validate_aoo_pending_movement_preview()
CREATE OR REPLACE FUNCTION priv.srd_validate_aoo_pending_movement_preview()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare v_preview jsonb;
begin
  perform set_config('app.srd_aoo_pending_commit',new.pending_id::text,true);
  begin
    if new.movement_controller='player' then
      v_preview:=public.mover_token_player_cba(
        new.campaign_id,new.mover_token_id,new.destination_x,new.destination_y
      );
    else
      v_preview:=public.mover_token_gm_cba_srd(
        new.campaign_id,new.mover_token_id,new.destination_x,new.destination_y
      );
    end if;
    raise exception using errcode='P0001',message='__SRD_AOO_PREVIEW_ROLLBACK__';
  exception when others then
    if sqlerrm='__SRD_AOO_PREVIEW_ROLLBACK__' then
      null;
    else
      raise;
    end if;
  end;
  return new;
end;
$function$
;

-- srd_validate_surprise_action(p_campaign_id bigint, p_actor_id text, p_action text)
CREATE OR REPLACE FUNCTION priv.srd_validate_surprise_action(p_campaign_id bigint, p_actor_id text, p_action text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
 v_combat jsonb;v_surprise jsonb;v_order jsonb;v_idx integer;v_actor jsonb;v_aware jsonb;
 v_used jsonb;v_economy jsonb;v_by_actor jsonb;v_movement jsonb;
BEGIN
 SELECT combat_data INTO v_combat FROM public.campaigns WHERE id=p_campaign_id;
 v_surprise:=coalesce(v_combat->'surprise','{}'::jsonb);
 IF coalesce(v_surprise->>'phase','')<>'surprise_round' THEN RETURN; END IF;
 v_order:=CASE WHEN jsonb_typeof(v_combat->'turn_order')='array' THEN v_combat->'turn_order' ELSE '[]'::jsonb END;
 IF coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$' THEN RAISE EXCEPTION 'Turno da rodada surpresa inválido.'; END IF;
 v_idx:=(v_combat->>'current_turn')::integer;
 IF v_idx<0 OR v_idx>=jsonb_array_length(v_order) THEN RAISE EXCEPTION 'Índice do turno inválido na rodada surpresa.'; END IF;
 v_actor:=v_order->v_idx;
 IF v_actor->>'id' IS DISTINCT FROM btrim(p_actor_id) THEN RAISE EXCEPTION 'Somente o participante ativo pode agir na rodada surpresa.'; END IF;
 v_aware:=CASE WHEN jsonb_typeof(v_surprise->'aware_ids')='array' THEN v_surprise->'aware_ids' ELSE '[]'::jsonb END;
 IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements_text(v_aware) x(id) WHERE x.id=btrim(p_actor_id)) THEN
  RAISE EXCEPTION 'Este participante foi surpreendido e não pode agir na rodada surpresa.';
 END IF;
 IF p_action NOT IN ('padrao','movimento') THEN
  RAISE EXCEPTION 'Na rodada surpresa, somente uma ação padrão ou uma ação de movimento é permitida.';
 END IF;
 v_economy:=v_combat->'action_economy';
 v_by_actor:=CASE WHEN jsonb_typeof(v_economy->'by_character')='object' THEN v_economy->'by_character' ELSE '{}'::jsonb END;
 v_used:=v_by_actor->btrim(p_actor_id);
 IF jsonb_typeof(v_used)='object' AND
   (coalesce(v_used->>'padrao','false')='true' OR coalesce(v_used->>'movimento','false')='true') THEN
  RAISE EXCEPTION 'Na rodada surpresa, cada participante consciente pode realizar somente uma ação padrão ou de movimento.';
 END IF;
 v_movement:=v_combat->'movement_usage';
 IF p_action='padrao' AND jsonb_typeof(v_movement)='object'
   AND v_movement->>'character_id'=btrim(p_actor_id)
   AND coalesce(v_movement->>'moved_squares','0') ~ '^[0-9]+$'
   AND (v_movement->>'moved_squares')::integer>0 THEN
  RAISE EXCEPTION 'O participante já utilizou sua ação de movimento na rodada surpresa.';
 END IF;
END;
$function$
;

-- srd_weapon_proficiency(p_details jsonb, p_weapon_name text)
CREATE OR REPLACE FUNCTION priv.srd_weapon_proficiency(p_details jsonb, p_weapon_name text)
 RETURNS text
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO 'pg_catalog'
AS $function$
DECLARE
  v_prof text:=lower(btrim(coalesce(p_details->>'weapon_proficiency','')));
  v_group text:=lower(btrim(coalesce(p_details->>'weapon_group','')));
  v_text text;
BEGIN
  IF v_prof LIKE '%exotic%' THEN RETURN 'exotic'; END IF;
  IF v_prof LIKE '%martial%' THEN RETURN 'martial'; END IF;
  IF v_prof LIKE '%simple%' THEN RETURN 'simple'; END IF;

  IF v_group LIKE '%exotic%' THEN RETURN 'exotic'; END IF;
  IF v_group LIKE '%martial%' THEN RETURN 'martial'; END IF;
  IF v_group LIKE '%simple%' THEN RETURN 'simple'; END IF;

  v_text:=lower(translate(
    concat_ws(' ',coalesce(p_weapon_name,''),coalesce(p_details->'campos_catalogo'->>'descricao_origem','')),
    'áàâãäéèêëíìîïóòôõöúùûüç','aaaaaeeeeiiiiooooouuuuc'
  ));

  -- Specific weapons whose SRD text defines an exceptional base weapon.
  IF v_text LIKE '%sun blade%' OR v_text LIKE '%luck blade%' THEN
    RETURN 'martial';
  END IF;

  IF v_text ~ '(^|[^a-z])(bastard sword|two[- ]bladed sword|orc double axe|dwarven waraxe|waraxe|urgrosh|spiked chain|hand crossbow|repeating crossbow|dire flail|gnome hooked hammer|kama|nunchaku|sai|shuriken|siangham|bolas|net|whip)([^a-z]|$)' THEN
    RETURN 'exotic';
  END IF;

  IF v_text ~ '(^|[^a-z])(dagger|javelin|heavy mace|light mace|mace|heavy crossbow|light crossbow|crossbow|club|dart|gauntlet|light hammer|morningstar|quarterstaff|sickle|spear|longspear|shortspear|sling|bolt|arrow|unarmed strike)([^a-z]|$)' THEN
    RETURN 'simple';
  END IF;

  IF v_text ~ '(^|[^a-z])(battleaxe|longsword|greatsword|greataxe|warhammer|rapier|scimitar|trident|longbow|shortbow|glaive|halberd|flail|guisarme|ranseur|lance|falchion|kukri|handaxe|throwing axe|heavy pick|light pick|short sword|shortsword|sap)([^a-z]|$)' THEN
    RETURN 'martial';
  END IF;

  RETURN '';
END;
$function$
;

