-- Ofício e Profissão aceitam especialidades abertas, cada uma com graduações próprias.
CREATE OR REPLACE FUNCTION public.salvar_pericias_srd(p_character_id text, p_pericias jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_class public.srd_classes%ROWTYPE;
  v_race public.srd_races%ROWTYPE;
  v_entry RECORD;
  v_skill public.srd_skills%ROWTYPE;
  v_rank NUMERIC;
  v_is_class_skill BOOLEAN;
  v_level INTEGER;
  v_int_mod INTEGER;
  v_budget NUMERIC;
  v_spent NUMERIC := 0;
  v_skill_specialization JSONB;
  v_skill_base_id TEXT;
  v_skill_specialization_name TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF p_character_id IS NULL OR BTRIM(p_character_id) = '' THEN
    RAISE EXCEPTION 'Identificador de personagem inválido.';
  END IF;
  IF p_pericias IS NULL OR jsonb_typeof(p_pericias) <> 'object' THEN
    RAISE EXCEPTION 'As perícias devem ser informadas como um objeto JSON.';
  END IF;

  SELECT sh.* INTO v_sheet
  FROM public.srd_character_sheets AS sh
  JOIN public.characters AS ch
    ON ch.id::TEXT = sh.character_id::TEXT
  WHERE sh.character_id::TEXT = BTRIM(p_character_id)
    AND ch.user_id = auth.uid();
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Ficha não encontrada ou não pertence ao usuário.';
  END IF;

  SELECT cl.* INTO v_class
  FROM public.srd_classes AS cl
  WHERE cl.id = v_sheet.classe_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Classe SRD da ficha não encontrada.';
  END IF;
  SELECT ra.* INTO v_race
  FROM public.srd_races AS ra
  WHERE ra.id = v_sheet.raca_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Raça SRD da ficha não encontrada.';
  END IF;

  v_level := v_sheet.nivel;
  IF v_level IS NULL OR v_level < 1 THEN
    RAISE EXCEPTION 'Nível da ficha inválido.';
  END IF;
  IF v_class.pericias_por_nivel IS NULL OR v_sheet.atributos IS NULL
     OR jsonb_typeof(v_sheet.atributos) <> 'object'
     OR (v_sheet.atributos->>'INT') IS NULL
     OR (v_sheet.atributos->>'INT') !~ '^-?[0-9]+$' THEN
    RAISE EXCEPTION 'A classe ou os atributos da ficha não permitem calcular o orçamento de perícias.';
  END IF;

  v_int_mod := FLOOR((((v_sheet.atributos->>'INT')::NUMERIC - 10) / 2))::INTEGER;
  v_budget := GREATEST(1, v_class.pericias_por_nivel + v_int_mod)::NUMERIC * (v_level + 3);
  IF v_race.id = 'humano' THEN
    v_budget := v_budget + 4 + GREATEST(v_level - 1, 0);
  END IF;

  FOR v_entry IN SELECT key, value FROM jsonb_each(p_pericias)
  LOOP
    v_skill_specialization := NULL;
    v_skill_specialization_name := NULL;
    v_skill_base_id := NULL;
    IF v_entry.key ~ '^srd35_skill_(oficio|profissao)_[a-z0-9_]+$' THEN
      v_skill_base_id := CASE WHEN v_entry.key LIKE 'srd35_skill_oficio_%' THEN 'oficio' ELSE 'profissao' END;
      SELECT spec.value INTO v_skill_specialization
      FROM jsonb_array_elements(
        CASE WHEN jsonb_typeof(v_sheet.identidade->'skill_specializations')='array'
             THEN v_sheet.identidade->'skill_specializations' ELSE '[]'::jsonb END
      ) AS spec(value)
      WHERE spec.value->>'key'=v_entry.key
        AND spec.value->>'type'=v_skill_base_id;
      IF NOT FOUND THEN
        RAISE EXCEPTION 'Especialidade de perícia não cadastrada na identidade: %.',v_entry.key;
      END IF;
      v_skill_specialization_name := NULLIF(BTRIM(v_skill_specialization->>'name'),'');
      IF v_skill_specialization_name IS NULL OR length(v_skill_specialization_name)>60 THEN
        RAISE EXCEPTION 'Nome inválido para a especialidade %.',v_entry.key;
      END IF;
      SELECT sk.* INTO v_skill FROM public.srd_skills AS sk WHERE sk.id=v_skill_base_id;
    ELSE
      SELECT sk.* INTO v_skill FROM public.srd_skills AS sk WHERE sk.id=v_entry.key;
    END IF;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Perícia ou especialidade desconhecida: %.', v_entry.key;
    END IF;
    IF jsonb_typeof(v_entry.value) <> 'number'
       OR (v_entry.value #>> '{}') !~ '^(0|[1-9][0-9]*)(\.5)?$' THEN
      RAISE EXCEPTION 'Graduações inválidas para a perícia %; use zero ou valores em incrementos de 0,5.', v_entry.key;
    END IF;
    v_rank := (v_entry.value #>> '{}')::NUMERIC;
    v_is_class_skill := EXISTS (
      SELECT 1
      FROM jsonb_array_elements_text(COALESCE(v_class.pericias_classe, '[]'::JSONB)) AS class_skill(nome)
      WHERE regexp_replace(
              translate(LOWER(BTRIM(class_skill.nome)), 'áàâãäéèêëíìîïóòôõöúùûüç', 'aaaaaeeeeiiiiooooouuuuc'),
              '[^a-z0-9]+', ' ', 'g'
            ) = regexp_replace(
              translate(LOWER(BTRIM(v_skill.nome)), 'áàâãäéèêëíìîïóòôõöúùûüç', 'aaaaaeeeeiiiiooooouuuuc'),
              '[^a-z0-9]+', ' ', 'g'
            )
         OR (LOWER(BTRIM(class_skill.nome)) = 'fuga' AND v_skill.id = 'fuga')
         OR (
           regexp_replace(
             translate(LOWER(BTRIM(class_skill.nome)), 'áàâãäéèêëíìîïóòôõöúùûüç', 'aaaaaeeeeiiiiooooouuuuc'),
             '[^a-z0-9]+', ' ', 'g'
           ) = 'conhecimento qualquer'
           AND regexp_replace(
             translate(LOWER(BTRIM(v_skill.nome)), 'áàâãäéèêëíìîïóòôõöúùûüç', 'aaaaaeeeeiiiiooooouuuuc'),
             '[^a-z0-9]+', ' ', 'g'
           ) LIKE 'conhecimento %'
         )
         OR (
           v_skill.id IN ('oficio','profissao')
           AND regexp_replace(
             translate(LOWER(BTRIM(class_skill.nome)), 'áàâãäéèêëíìîïóòôõöúùûüç', 'aaaaaeeeeiiiiooooouuuuc'),
             '[^a-z0-9]+', ' ', 'g'
           ) LIKE (
             regexp_replace(
               translate(LOWER(BTRIM(v_skill.nome)), 'áàâãäéèêëíìîïóòôõöúùûüç', 'aaaaaeeeeiiiiooooouuuuc'),
               '[^a-z0-9]+', ' ', 'g'
             ) || ' %'
           )
         )
    );

    IF v_entry.key = 'srd35_skill_speak_language' THEN
      -- Falar Idioma não usa graduações nem limite de perícia: cada idioma
      -- adicional custa 1 ponto de perícia, independentemente da classe.
      IF v_rank <> TRUNC(v_rank) THEN
        RAISE EXCEPTION 'Falar Idioma exige pontos inteiros (um ponto por idioma).';
      END IF;
      v_spent := v_spent + v_rank;
    ELSIF v_is_class_skill THEN
      IF v_rank <> TRUNC(v_rank) THEN
        RAISE EXCEPTION 'Perícias de classe exigem graduações inteiras (%).', v_skill.nome;
      END IF;
      IF v_rank > v_level + 3 THEN
        RAISE EXCEPTION 'Graduações acima do limite de classe para % (máximo %).', v_skill.nome, v_level + 3;
      END IF;
      v_spent := v_spent + v_rank;
    ELSE
      IF v_rank * 2 <> TRUNC(v_rank * 2) THEN
        RAISE EXCEPTION 'Perícias cross-class exigem graduações em incrementos de 0,5 (%).', v_skill.nome;
      END IF;
      IF v_rank > (v_level + 3)::NUMERIC / 2 THEN
        RAISE EXCEPTION 'Graduações acima do limite cross-class para % (máximo %).', v_skill.nome, (v_level + 3)::NUMERIC / 2;
      END IF;
      v_spent := v_spent + (v_rank * 2);
    END IF;
  END LOOP;

  IF v_spent > v_budget THEN
    RAISE EXCEPTION 'Perícias usam % pontos; o orçamento disponível é %.', v_spent, v_budget;
  END IF;

  UPDATE public.srd_character_sheets AS sh
  SET pericias = p_pericias
  WHERE sh.character_id::TEXT = BTRIM(p_character_id);
  RETURN p_pericias;
END;
$function$
;