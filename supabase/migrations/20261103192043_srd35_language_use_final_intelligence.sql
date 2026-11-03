CREATE OR REPLACE FUNCTION public.salvar_idiomas_personagem_srd(p_character_id text, p_idiomas jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'auth'
AS $function$
DECLARE
  v_user UUID:=auth.uid();
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_race public.srd_races%ROWTYPE;
  v_class public.srd_classes%ROWTYPE;
  v_language_line TEXT;
  v_auto_text TEXT;
  v_bonus_text TEXT;
  v_auto_expected TEXT[]:=ARRAY[]::TEXT[];
  v_bonus_allowed TEXT[]:=ARRAY[]::TEXT[];
  v_auto_submitted TEXT[]:=ARRAY[]::TEXT[];
  v_bonus_submitted TEXT[]:=ARRAY[]::TEXT[];
  v_purchased_submitted TEXT[]:=ARRAY[]::TEXT[];
  v_all_submitted TEXT[]:=ARRAY[]::TEXT[];
  v_any_bonus BOOLEAN:=FALSE;
  v_int_mod INTEGER:=0;
  v_language_ranks INTEGER:=0;
  v_distinct_count INTEGER:=0;
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'Autenticação necessária.'; END IF;
  IF jsonb_typeof(p_idiomas)<>'object' THEN RAISE EXCEPTION 'Estrutura de idiomas inválida.'; END IF;
  IF jsonb_typeof(p_idiomas->'automaticos')<>'array'
     OR jsonb_typeof(p_idiomas->'bonus_inteligencia')<>'array'
     OR jsonb_typeof(p_idiomas->'comprados_falar_idioma')<>'array' THEN
    RAISE EXCEPTION 'As listas de idiomas precisam ser arrays.';
  END IF;

  SELECT sh.* INTO v_sheet
  FROM public.characters ch
  JOIN public.srd_character_sheets sh ON sh.character_id=ch.id
  WHERE ch.id::TEXT=BTRIM(p_character_id) AND ch.user_id=v_user;
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou sem permissão.'; END IF;

  SELECT * INTO v_race FROM public.srd_races WHERE id=v_sheet.raca_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Raça do personagem não encontrada.'; END IF;
  SELECT * INTO v_class FROM public.srd_classes WHERE id=v_sheet.classe_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Classe do personagem não encontrada.'; END IF;

  SELECT elem INTO v_language_line
  FROM jsonb_array_elements_text(v_race.habilidades_raciais) elem
  WHERE elem ILIKE '%idioma%automático%:%'
  LIMIT 1;
  IF v_language_line IS NULL THEN RAISE EXCEPTION 'A raça não possui regra de idiomas automáticos cadastrada.'; END IF;

  v_auto_text:=split_part(regexp_replace(v_language_line,'^.*idiomas? automáticos?:\s*','','i'),'.',1);
  v_auto_text:=regexp_replace(v_auto_text,'\s+e\s+',',','gi');
  SELECT COALESCE(array_agg(BTRIM(x)),ARRAY[]::TEXT[]) INTO v_auto_expected
  FROM unnest(string_to_array(v_auto_text,',')) x WHERE BTRIM(x)<>'';
  IF v_class.id='druida' AND NOT ('Druídico'=ANY(v_auto_expected)) THEN
    v_auto_expected:=array_append(v_auto_expected,'Druídico');
  END IF;

  v_any_bonus:=v_language_line ILIKE '%qualquer idioma%'
    OR v_language_line ILIKE '%pode escolher idiomas adicionais%';
  v_bonus_text:='';
  IF v_language_line ILIKE '%idiomas adicionais:%' THEN
    v_bonus_text:=split_part(regexp_replace(v_language_line,'^.*idiomas adicionais:\s*','','i'),'.',1);
  END IF;
  v_bonus_text:=regexp_replace(v_bonus_text,'\s+e\s+',',','gi');
  IF NOT v_any_bonus THEN
    SELECT COALESCE(array_agg(BTRIM(x)),ARRAY[]::TEXT[]) INTO v_bonus_allowed
    FROM unnest(string_to_array(v_bonus_text,',')) x WHERE BTRIM(x)<>'';
  END IF;

  SELECT COALESCE(array_agg(value),ARRAY[]::TEXT[]) INTO v_auto_submitted
  FROM jsonb_array_elements_text(p_idiomas->'automaticos') AS t(value);
  SELECT COALESCE(array_agg(value),ARRAY[]::TEXT[]) INTO v_bonus_submitted
  FROM jsonb_array_elements_text(p_idiomas->'bonus_inteligencia') AS t(value);
  SELECT COALESCE(array_agg(value),ARRAY[]::TEXT[]) INTO v_purchased_submitted
  FROM jsonb_array_elements_text(p_idiomas->'comprados_falar_idioma') AS t(value);

  IF cardinality(v_auto_submitted)<>cardinality(v_auto_expected)
     OR EXISTS(SELECT 1 FROM unnest(v_auto_expected) x WHERE NOT (x=ANY(v_auto_submitted))) THEN
    RAISE EXCEPTION 'Os idiomas automáticos não correspondem à raça e à classe.';
  END IF;

  v_int_mod:=GREATEST(0,FLOOR((COALESCE(NULLIF(v_sheet.atributos->>'INT','')::NUMERIC,10)-10)/2)::INTEGER);
  IF cardinality(v_bonus_submitted)>v_int_mod THEN
    RAISE EXCEPTION 'A quantidade de idiomas bônus excede o modificador de Inteligência.';
  END IF;
  IF NOT v_any_bonus AND EXISTS(SELECT 1 FROM unnest(v_bonus_submitted) x WHERE NOT (x=ANY(v_bonus_allowed))) THEN
    RAISE EXCEPTION 'Um dos idiomas bônus não pertence à lista permitida pela raça.';
  END IF;

  v_language_ranks:=CASE WHEN COALESCE(v_sheet.pericias->>'srd35_skill_speak_language','') ~ '^[0-9]+$'
    THEN (v_sheet.pericias->>'srd35_skill_speak_language')::INTEGER ELSE 0 END;
  IF cardinality(v_purchased_submitted)<>v_language_ranks THEN
    RAISE EXCEPTION 'A quantidade de idiomas comprados precisa corresponder aos pontos investidos em Falar Idioma.';
  END IF;

  IF EXISTS(
    SELECT 1 FROM unnest(v_auto_submitted) x
    WHERE NOT EXISTS(SELECT 1 FROM public.srd_languages l WHERE l.nome=x)
  ) THEN RAISE EXCEPTION 'Idioma automático ausente do catálogo.'; END IF;
  IF EXISTS(
    SELECT 1 FROM unnest(v_bonus_submitted||v_purchased_submitted) x
    WHERE NOT EXISTS(SELECT 1 FROM public.srd_languages l WHERE l.nome=x AND l.is_secret=FALSE)
  ) THEN RAISE EXCEPTION 'Idioma bônus ou comprado inválido ou secreto.'; END IF;

  v_all_submitted:=v_auto_submitted||v_bonus_submitted||v_purchased_submitted;
  SELECT COUNT(DISTINCT lower(x)) INTO v_distinct_count FROM unnest(v_all_submitted) x;
  IF v_distinct_count<>cardinality(v_all_submitted) THEN RAISE EXCEPTION 'O mesmo idioma não pode ser selecionado mais de uma vez.'; END IF;

  UPDATE public.srd_character_sheets
  SET idiomas_conhecidos=p_idiomas
  WHERE character_id=v_sheet.character_id;
  RETURN p_idiomas;
END;
$function$
;
