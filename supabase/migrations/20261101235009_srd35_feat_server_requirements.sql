CREATE OR REPLACE FUNCTION public.salvar_talentos_srd(p_character_id text, p_talentos jsonb)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_class public.srd_classes%ROWTYPE;
  v_race public.srd_races%ROWTYPE;
  v_entry JSONB;
  v_feat public.srd_feats%ROWTYPE;
  v_req JSONB;
  v_pair RECORD;
  v_feat_id TEXT;
  v_prereq_id TEXT;
  v_parameter TEXT;
  v_prereq_parameter TEXT;
  v_parameter_norm TEXT;
  v_prereq_norm TEXT;
  v_value_text TEXT;
  v_required INTEGER;
  v_bab INTEGER;
  v_level INTEGER;
  v_caster_level INTEGER;
  v_count INTEGER;
  v_skill_id TEXT;
  v_skill_required NUMERIC;
  v_skill_value NUMERIC;
  v_feature TEXT;
  v_has_prerequisite BOOLEAN;
  v_stat_key TEXT;
  v_parameter_source TEXT;
  v_normalized_parameter TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF p_character_id IS NULL OR BTRIM(p_character_id) = '' THEN
    RAISE EXCEPTION 'Identificador de personagem inválido.';
  END IF;
  IF p_talentos IS NULL OR jsonb_typeof(p_talentos) <> 'array' THEN
    RAISE EXCEPTION 'Os talentos devem ser informados como um array JSON.';
  END IF;

  SELECT sh.* INTO v_sheet
  FROM public.srd_character_sheets AS sh
  JOIN public.characters AS ch ON ch.id::TEXT = sh.character_id::TEXT
  WHERE sh.character_id::TEXT = BTRIM(p_character_id)
    AND ch.user_id = auth.uid();
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Ficha não encontrada ou não pertence ao usuário.';
  END IF;

  SELECT cl.* INTO v_class FROM public.srd_classes AS cl WHERE cl.id = v_sheet.classe_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Classe SRD da ficha não encontrada.'; END IF;
  SELECT ra.* INTO v_race FROM public.srd_races AS ra WHERE ra.id = v_sheet.raca_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Raça SRD da ficha não encontrada.'; END IF;

  v_level := v_sheet.nivel;
  IF v_level IS NULL OR v_level < 1 THEN RAISE EXCEPTION 'Nível da ficha inválido.'; END IF;
  v_count := jsonb_array_length(p_talentos);
  IF v_count <> (CASE WHEN v_race.id = 'humano' THEN 2 ELSE 1 END) THEN
    RAISE EXCEPTION 'A ficha deve possuir exatamente % talento(s).',
      CASE WHEN v_race.id = 'humano' THEN 2 ELSE 1 END;
  END IF;
  IF (SELECT COUNT(DISTINCT elem->>'id') FROM jsonb_array_elements(p_talentos) AS elem) <> v_count THEN
    RAISE EXCEPTION 'Não é permitido escolher talentos duplicados.';
  END IF;

  CASE LOWER(COALESCE(v_class.bab_progression, ''))
    WHEN 'good' THEN v_bab := v_level;
    WHEN 'average' THEN v_bab := FLOOR((3 * v_level)::NUMERIC / 4)::INTEGER;
    WHEN 'medium' THEN v_bab := FLOOR((3 * v_level)::NUMERIC / 4)::INTEGER;
    WHEN 'poor' THEN v_bab := FLOOR(v_level::NUMERIC / 2)::INTEGER;
    ELSE RAISE EXCEPTION 'Progressão de BBA desconhecida para a classe.';
  END CASE;

  v_caster_level := CASE COALESCE(v_class.class_key, '')
    WHEN 'wizard' THEN v_level
    WHEN 'sorcerer' THEN v_level
    WHEN 'cleric' THEN v_level
    WHEN 'druid' THEN v_level
    WHEN 'bard' THEN v_level
    WHEN 'paladin' THEN GREATEST(v_level - 3, 0)
    WHEN 'ranger' THEN GREATEST(v_level - 3, 0)
    ELSE 0
  END;

  FOR v_entry IN SELECT value FROM jsonb_array_elements(p_talentos)
  LOOP
    IF jsonb_typeof(v_entry) <> 'object' OR jsonb_typeof(v_entry->'id') <> 'string' THEN
      RAISE EXCEPTION 'Cada talento deve ser um objeto com um identificador id.';
    END IF;
    v_feat_id := NULLIF(BTRIM(v_entry->>'id'), '');
    IF v_feat_id IS NULL THEN RAISE EXCEPTION 'Identificador de talento inválido.'; END IF;

    SELECT f.* INTO v_feat FROM public.srd_feats AS f WHERE f.id = v_feat_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Talento desconhecido: %.', v_feat_id; END IF;
    v_req := COALESCE(v_feat.requisitos, '{}'::JSONB);
    v_parameter := NULLIF(BTRIM(v_entry->>'parametro'), '');

    IF v_feat.exige_parametro AND v_parameter IS NULL THEN
      RAISE EXCEPTION 'O talento % exige um parâmetro (por exemplo, a escolha indicada na ficha).', v_feat.nome;
    END IF;
    IF NOT COALESCE(v_feat.exige_parametro, false)
       AND v_parameter IS NOT NULL
       AND v_feat.id <> 'srd35_feat_spell_mastery' THEN
      RAISE EXCEPTION 'O talento % não aceita parâmetro.', v_feat.nome;
    END IF;

    FOREACH v_stat_key IN ARRAY ARRAY['FOR','DES','CON','INT','SAB','CAR']
    LOOP
      IF v_req ? (LOWER(v_stat_key) || '_min') THEN
        v_value_text := v_sheet.atributos->>v_stat_key;
        IF v_value_text IS NULL OR v_value_text !~ '^-?[0-9]+$' THEN
          RAISE EXCEPTION 'A ficha não possui um valor % válido.', v_stat_key;
        END IF;
        v_required := (v_req->>(LOWER(v_stat_key) || '_min'))::INTEGER;
        IF v_value_text::INTEGER < v_required THEN
          RAISE EXCEPTION 'O talento % exige % %.', v_feat.nome, v_stat_key, v_required;
        END IF;
      END IF;
    END LOOP;

    IF v_req ? 'bab_min' THEN
      v_required := (v_req->>'bab_min')::INTEGER;
      IF v_bab < v_required THEN RAISE EXCEPTION 'O talento % exige BBA +%.', v_feat.nome, v_required; END IF;
    END IF;
    IF v_req ? 'character_level_min' THEN
      v_required := (v_req->>'character_level_min')::INTEGER;
      IF v_level < v_required THEN RAISE EXCEPTION 'O talento % exige nível de personagem %.', v_feat.nome, v_required; END IF;
    END IF;
    IF v_req ? 'class_level_min' THEN
      v_required := (v_req->>'class_level_min')::INTEGER;
      IF (v_req ? 'class_key_required' AND COALESCE(v_req->>'class_key_required','') <> COALESCE(v_class.class_key,''))
         OR v_level < v_required THEN
        RAISE EXCEPTION 'O talento % exige nível % na classe indicada.', v_feat.nome, v_required;
      END IF;
    END IF;
    IF v_req ? 'caster_level_min' THEN
      v_required := (v_req->>'caster_level_min')::INTEGER;
      IF v_caster_level < v_required THEN
        RAISE EXCEPTION 'O talento % exige nível de conjurador %.', v_feat.nome, v_required;
      END IF;
    END IF;

    IF jsonb_typeof(v_req->'skill_ranks') = 'object' THEN
      FOR v_pair IN SELECT key, value FROM jsonb_each(v_req->'skill_ranks')
      LOOP
        v_skill_id := v_pair.key;
        v_skill_required := CASE WHEN jsonb_typeof(v_pair.value)='number' THEN (v_pair.value::TEXT)::NUMERIC ELSE (v_pair.value#>>'{}')::NUMERIC END;
        v_value_text := COALESCE(v_sheet.pericias,'{}'::JSONB)->>v_skill_id;
        IF v_value_text IS NULL OR v_value_text !~ '^-?[0-9]+([.][0-9]+)?$' THEN
          v_skill_value := 0;
        ELSE
          v_skill_value := v_value_text::NUMERIC;
        END IF;
        IF v_skill_value < v_skill_required THEN
          RAISE EXCEPTION 'O talento % exige % graduação(ões) na perícia %.', v_feat.nome, v_skill_required, v_skill_id;
        END IF;
      END LOOP;
    END IF;

    IF jsonb_typeof(v_req->'feat_ids') = 'array' THEN
      FOR v_prereq_id IN SELECT jsonb_array_elements_text(v_req->'feat_ids')
      LOOP
        IF v_prereq_id = v_feat_id THEN RAISE EXCEPTION 'Pré-requisito circular no talento %.',v_feat.nome; END IF;
        v_has_prerequisite :=
          EXISTS (SELECT 1 FROM jsonb_array_elements(p_talentos) AS picked(value) WHERE picked.value->>'id'=v_prereq_id)
          OR EXISTS (SELECT 1 FROM jsonb_array_elements(COALESCE(v_sheet.talentos,'[]'::JSONB)) AS saved(value) WHERE saved.value->>'id'=v_prereq_id);
        IF NOT v_has_prerequisite THEN
          SELECT nome INTO v_value_text FROM public.srd_feats WHERE id=v_prereq_id;
          RAISE EXCEPTION 'O talento % exige o talento %.',v_feat.nome,COALESCE(v_value_text,v_prereq_id);
        END IF;
      END LOOP;
    END IF;

    IF jsonb_typeof(v_req->'feat_parameters')='object' THEN
      FOR v_pair IN SELECT key, value FROM jsonb_each_text(v_req->'feat_parameters')
      LOOP
        v_prereq_id := v_pair.key;
        v_has_prerequisite :=
          EXISTS (SELECT 1 FROM jsonb_array_elements(p_talentos) AS picked(value) WHERE picked.value->>'id'=v_prereq_id)
          OR EXISTS (SELECT 1 FROM jsonb_array_elements(COALESCE(v_sheet.talentos,'[]'::JSONB)) AS saved(value) WHERE saved.value->>'id'=v_prereq_id);
        IF NOT v_has_prerequisite THEN RAISE EXCEPTION 'O talento % exige o talento pré-requisito %.',v_feat.nome,v_prereq_id; END IF;
        SELECT picked.value->>'parametro' INTO v_prereq_parameter
          FROM jsonb_array_elements(p_talentos) AS picked(value)
          WHERE picked.value->>'id'=v_prereq_id LIMIT 1;
        IF v_prereq_parameter IS NULL THEN
          SELECT saved.value->>'parametro' INTO v_prereq_parameter
            FROM jsonb_array_elements(COALESCE(v_sheet.talentos,'[]'::JSONB)) AS saved(value)
            WHERE saved.value->>'id'=v_prereq_id LIMIT 1;
        END IF;
        v_parameter_norm := regexp_replace(lower(translate(COALESCE(v_parameter,''),'ÁÀÂÃÉÊÍÓÔÕÚÜÇáàâãéêíóôõúüç','AAAAEEIOOOUUCaaaaeeiooouuc')),'[^a-z0-9]+','','g');
        v_prereq_norm := regexp_replace(lower(translate(COALESCE(v_prereq_parameter,''),'ÁÀÂÃÉÊÍÓÔÕÚÜÇáàâãéêíóôõúüç','AAAAEEIOOOUUCaaaaeeiooouuc')),'[^a-z0-9]+','','g');
        IF v_parameter_norm <> v_prereq_norm OR v_parameter_norm = '' THEN
          RAISE EXCEPTION 'O talento % exige que o parâmetro de % seja %.',v_feat.nome,v_prereq_id,v_pair.value;
        END IF;
      END LOOP;
    END IF;

    IF jsonb_typeof(v_req->'feat_parameter_matches')='array' THEN
      FOR v_prereq_id IN SELECT jsonb_array_elements_text(v_req->'feat_parameter_matches')
      LOOP
        v_has_prerequisite :=
          EXISTS (SELECT 1 FROM jsonb_array_elements(p_talentos) AS picked(value) WHERE picked.value->>'id'=v_prereq_id)
          OR EXISTS (SELECT 1 FROM jsonb_array_elements(COALESCE(v_sheet.talentos,'[]'::JSONB)) AS saved(value) WHERE saved.value->>'id'=v_prereq_id);
        IF NOT v_has_prerequisite THEN RAISE EXCEPTION 'O talento % exige o talento pré-requisito %.',v_feat.nome,v_prereq_id; END IF;
        SELECT picked.value->>'parametro' INTO v_prereq_parameter
          FROM jsonb_array_elements(p_talentos) AS picked(value)
          WHERE picked.value->>'id'=v_prereq_id LIMIT 1;
        IF v_prereq_parameter IS NULL THEN
          SELECT saved.value->>'parametro' INTO v_prereq_parameter
            FROM jsonb_array_elements(COALESCE(v_sheet.talentos,'[]'::JSONB)) AS saved(value)
            WHERE saved.value->>'id'=v_prereq_id LIMIT 1;
        END IF;
        v_parameter_norm := regexp_replace(lower(translate(COALESCE(v_parameter,''),'ÁÀÂÃÉÊÍÓÔÕÚÜÇáàâãéêíóôõúüç','AAAAEEIOOOUUCaaaaeeiooouuc')),'[^a-z0-9]+','','g');
        v_prereq_norm := regexp_replace(lower(translate(COALESCE(v_prereq_parameter,''),'ÁÀÂÃÉÊÍÓÔÕÚÜÇáàâãéêíóôõúüç','AAAAEEIOOOUUCaaaaeeiooouuc')),'[^a-z0-9]+','','g');
        IF v_parameter_norm <> v_prereq_norm OR v_parameter_norm = '' THEN
          RAISE EXCEPTION 'O talento % exige a mesma arma ou escola do talento pré-requisito %.',v_feat.nome,v_prereq_id;
        END IF;
      END LOOP;
    END IF;

    IF jsonb_typeof(v_req->'conditional_ability_min')='object' THEN
      FOR v_pair IN SELECT key, value FROM jsonb_each(v_req->'conditional_ability_min')
      LOOP
        v_stat_key := v_pair.key;
        v_required := (v_pair.value->>'minimum')::INTEGER;
        IF EXISTS (
          SELECT 1 FROM jsonb_array_elements_text(COALESCE(v_pair.value->'parameters','[]'::JSONB)) AS parameter(value)
          WHERE regexp_replace(lower(translate(parameter.value,'ÁÀÂÃÉÊÍÓÔÕÚÜÇáàâãéêíóôõúüç','AAAAEEIOOOUUCaaaaeeiooouuc')),'[^a-z0-9]+','','g')
              = regexp_replace(lower(translate(COALESCE(v_parameter,''),'ÁÀÂÃÉÊÍÓÔÕÚÜÇáàâãéêíóôõúüç','AAAAEEIOOOUUCaaaaeeiooouuc')),'[^a-z0-9]+','','g')
        ) THEN
          v_value_text := v_sheet.atributos->>v_stat_key;
          IF v_value_text IS NULL OR v_value_text !~ '^-?[0-9]+$' OR v_value_text::INTEGER < v_required THEN
            RAISE EXCEPTION 'O parâmetro escolhido para % exige % %.',v_feat.nome,v_stat_key,v_required;
          END IF;
        END IF;
      END LOOP;
    END IF;

    IF jsonb_typeof(v_req->'special_ability_required')='string' THEN
      v_feature := v_req->>'special_ability_required';
      IF v_feature='wild_shape' AND NOT (v_class.class_key='druid' AND v_level>=5) THEN
        RAISE EXCEPTION 'O talento % exige Forma Selvagem, disponível na progressão básica de druida a partir do nível 5.',v_feat.nome;
      ELSIF v_feature='turn_or_rebuke_creatures' AND NOT ((v_class.class_key='cleric' AND v_level>=1) OR (v_class.class_key='paladin' AND v_level>=4)) THEN
        RAISE EXCEPTION 'O talento % exige habilidade de expulsar ou fascinar mortos-vivos.',v_feat.nome;
      ELSIF v_feature='familiar' AND NOT (v_class.class_key IN ('wizard','sorcerer') AND v_level>=1) THEN
        RAISE EXCEPTION 'O talento % exige uma classe com habilidade de adquirir familiar.',v_feat.nome;
      ELSIF v_feature NOT IN ('wild_shape','turn_or_rebuke_creatures','familiar') THEN
        RAISE EXCEPTION 'Não foi possível validar o pré-requisito especial % do talento %.',v_feature,v_feat.nome;
      END IF;
    END IF;
  END LOOP;

  UPDATE public.srd_character_sheets AS sh
  SET talentos = p_talentos
  WHERE sh.character_id::TEXT = BTRIM(p_character_id);
  RETURN p_talentos;
END;
$function$;