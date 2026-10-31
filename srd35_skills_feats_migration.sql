-- Vínculo · integração D&D 3.5 (SRD): perícias e talentos.
-- Migration idempotente; não executa nem altera dados fora deste esquema.
-- Proficiência com armas não é validada aqui porque os esquemas SRD atuais
-- não contêm metadados de proficiência por classe ou por talento.

BEGIN;

ALTER TABLE public.srd_character_sheets
  ADD COLUMN IF NOT EXISTS pericias JSONB NOT NULL DEFAULT '{}'::JSONB,
  ADD COLUMN IF NOT EXISTS talentos JSONB NOT NULL DEFAULT '[]'::JSONB;

-- Completa perícias citadas pelas classes SRD mas ausentes do catálogo inicial.
INSERT INTO public.srd_skills (id, nome, atributo, treinada_apenas, penalidade_armadura)
VALUES
  ('cavalgar', 'Cavalgar', 'DES', FALSE, FALSE),
  ('conhecimento_arquitetura', 'Conhecimento (Arquitetura)', 'INT', TRUE, FALSE),
  ('conhecimento_masmorras', 'Conhecimento (Masmorras)', 'INT', TRUE, FALSE),
  ('conhecimento_geografia', 'Conhecimento (Geografia)', 'INT', TRUE, FALSE),
  ('conhecimento_local', 'Conhecimento (Local)', 'INT', TRUE, FALSE),
  ('conhecimento_nobreza', 'Conhecimento (Nobreza)', 'INT', TRUE, FALSE),
  ('conhecimento_planos', 'Conhecimento (Planos)', 'INT', TRUE, FALSE),
  ('oficio', 'Ofício', 'INT', TRUE, FALSE)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS public.srd_feats (
  id TEXT PRIMARY KEY,
  nome TEXT NOT NULL,
  descricao TEXT NOT NULL,
  requisitos JSONB NOT NULL DEFAULT '{}'::JSONB,
  exige_parametro BOOLEAN NOT NULL DEFAULT FALSE
);

ALTER TABLE public.srd_feats ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON TABLE public.srd_feats TO anon, authenticated;
DROP POLICY IF EXISTS srd_feats_public_select ON public.srd_feats;
CREATE POLICY srd_feats_public_select
  ON public.srd_feats
  FOR SELECT
  TO anon, authenticated
  USING (TRUE);

INSERT INTO public.srd_feats (id, nome, descricao, requisitos, exige_parametro)
VALUES
  ('iniciativa_aprimorada', 'Iniciativa Aprimorada', 'Recebe +4 em testes de Iniciativa.', '{}'::JSONB, FALSE),
  ('ataque_poderoso', 'Ataque Poderoso', 'Permite trocar precisão de ataque por dano em combate corpo a corpo.', '{"for_min":13}'::JSONB, FALSE),
  ('foco_em_arma', 'Foco em Arma', 'Recebe +1 nas jogadas de ataque com uma arma escolhida.', '{"bab_min":1}'::JSONB, TRUE),
  ('esquiva', 'Esquiva', 'Recebe +1 na CA contra um oponente escolhido.', '{"des_min":13}'::JSONB, FALSE),
  ('tenacidade', 'Tenacidade', 'Recebe 3 pontos de vida adicionais.', '{}'::JSONB, FALSE),
  ('reflexos_de_combate', 'Reflexos de Combate', 'Pode realizar ataques de oportunidade adicionais conforme o modificador de Destreza.', '{"des_min":13}'::JSONB, FALSE)
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  descricao = EXCLUDED.descricao,
  requisitos = EXCLUDED.requisitos,
  exige_parametro = EXCLUDED.exige_parametro;

CREATE OR REPLACE FUNCTION public.salvar_pericias_srd(
  p_character_id TEXT,
  p_pericias JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
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
  -- Nível 1 recebe quatro vezes os pontos por nível; níveis seguintes
  -- recebem o valor normal por nível.
  v_budget := GREATEST(1, v_class.pericias_por_nivel + v_int_mod)::NUMERIC * (v_level + 3);
  IF v_race.id = 'humano' THEN
    -- Bônus humano: +4 pontos no nível 1 e +1 por nível adicional.
    v_budget := v_budget + 4 + GREATEST(v_level - 1, 0);
  END IF;

  FOR v_entry IN SELECT key, value FROM jsonb_each(p_pericias)
  LOOP
    SELECT sk.* INTO v_skill
    FROM public.srd_skills AS sk
    WHERE sk.id = v_entry.key;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Perícia desconhecida: %.', v_entry.key;
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
    );

    IF v_is_class_skill THEN
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
$$;

REVOKE ALL ON FUNCTION public.salvar_pericias_srd(TEXT, JSONB) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.salvar_pericias_srd(TEXT, JSONB) TO authenticated;

CREATE OR REPLACE FUNCTION public.salvar_talentos_srd(
  p_character_id TEXT,
  p_talentos JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_class public.srd_classes%ROWTYPE;
  v_race public.srd_races%ROWTYPE;
  v_entry JSONB;
  v_feat public.srd_feats%ROWTYPE;
  v_feat_id TEXT;
  v_parameter TEXT;
  v_required INTEGER;
  v_bab INTEGER;
  v_level INTEGER;
  v_count INTEGER;
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
  v_count := jsonb_array_length(p_talentos);
  IF v_count <> CASE WHEN v_race.id = 'humano' THEN 2 ELSE 1 END THEN
    RAISE EXCEPTION 'A ficha deve possuir exatamente % talento(s).', CASE WHEN v_race.id = 'humano' THEN 2 ELSE 1 END;
  END IF;

  IF (SELECT COUNT(DISTINCT elem->>'id') FROM jsonb_array_elements(p_talentos) AS elem) <> v_count THEN
    RAISE EXCEPTION 'Não é permitido escolher talentos duplicados.';
  END IF;

  CASE LOWER(COALESCE(v_class.bab_progression, ''))
    WHEN 'good' THEN v_bab := v_level;
    WHEN 'bom' THEN v_bab := v_level;
    WHEN 'average' THEN v_bab := FLOOR((3 * v_level)::NUMERIC / 4)::INTEGER;
    WHEN 'medium' THEN v_bab := FLOOR((3 * v_level)::NUMERIC / 4)::INTEGER;
    WHEN 'medio' THEN v_bab := FLOOR((3 * v_level)::NUMERIC / 4)::INTEGER;
    WHEN 'médio' THEN v_bab := FLOOR((3 * v_level)::NUMERIC / 4)::INTEGER;
    WHEN 'poor' THEN v_bab := FLOOR(v_level::NUMERIC / 2)::INTEGER;
    WHEN 'ruim' THEN v_bab := FLOOR(v_level::NUMERIC / 2)::INTEGER;
    ELSE RAISE EXCEPTION 'Progressão de BBA desconhecida para a classe.';
  END CASE;

  FOR v_entry IN SELECT value FROM jsonb_array_elements(p_talentos)
  LOOP
    IF jsonb_typeof(v_entry) <> 'object'
       OR jsonb_typeof(v_entry->'id') <> 'string' THEN
      RAISE EXCEPTION 'Cada talento deve ser um objeto com um identificador id.';
    END IF;
    v_feat_id := NULLIF(BTRIM(v_entry->>'id'), '');
    IF v_feat_id IS NULL THEN
      RAISE EXCEPTION 'Identificador de talento inválido.';
    END IF;

    SELECT f.* INTO v_feat
    FROM public.srd_feats AS f
    WHERE f.id = v_feat_id;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Talento desconhecido: %.', v_feat_id;
    END IF;

    v_parameter := NULLIF(BTRIM(v_entry->>'parametro'), '');
    IF v_feat.exige_parametro AND v_parameter IS NULL THEN
      RAISE EXCEPTION 'O talento % exige um parâmetro (por exemplo, a arma escolhida).', v_feat.nome;
    END IF;
    IF NOT v_feat.exige_parametro AND v_parameter IS NOT NULL THEN
      RAISE EXCEPTION 'O talento % não aceita parâmetro.', v_feat.nome;
    END IF;

    IF v_feat.requisitos ? 'for_min' THEN
      IF (v_sheet.atributos->>'FOR') IS NULL
         OR (v_sheet.atributos->>'FOR') !~ '^-?[0-9]+$' THEN
        RAISE EXCEPTION 'A ficha não possui um valor FOR válido.';
      END IF;
      v_required := (v_feat.requisitos->>'for_min')::INTEGER;
      IF (v_sheet.atributos->>'FOR')::INTEGER < v_required THEN
        RAISE EXCEPTION 'O talento % exige FOR %.', v_feat.nome, v_required;
      END IF;
    END IF;
    IF v_feat.requisitos ? 'des_min' THEN
      IF (v_sheet.atributos->>'DES') IS NULL
         OR (v_sheet.atributos->>'DES') !~ '^-?[0-9]+$' THEN
        RAISE EXCEPTION 'A ficha não possui um valor DES válido.';
      END IF;
      v_required := (v_feat.requisitos->>'des_min')::INTEGER;
      IF (v_sheet.atributos->>'DES')::INTEGER < v_required THEN
        RAISE EXCEPTION 'O talento % exige DES %.', v_feat.nome, v_required;
      END IF;
    END IF;
    IF v_feat.requisitos ? 'bab_min' THEN
      v_required := (v_feat.requisitos->>'bab_min')::INTEGER;
      IF v_bab < v_required THEN
        RAISE EXCEPTION 'O talento % exige BBA %.', v_feat.nome, v_required;
      END IF;
    END IF;
  END LOOP;

  UPDATE public.srd_character_sheets AS sh
  SET talentos = p_talentos
  WHERE sh.character_id::TEXT = BTRIM(p_character_id);
  RETURN p_talentos;
END;
$$;

REVOKE ALL ON FUNCTION public.salvar_talentos_srd(TEXT, JSONB) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.salvar_talentos_srd(TEXT, JSONB) TO authenticated;

CREATE OR REPLACE FUNCTION public.criar_personagem_srd_completo(
  p_nome TEXT,
  p_raca_id TEXT,
  p_classe_id TEXT,
  p_atributos JSONB,
  p_pericias JSONB,
  p_talentos JSONB
)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_character_id TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  -- Chamadas na mesma transação: qualquer erro nas perícias/talentos reverte
  -- também a criação do personagem e da ficha.
  v_character_id := public.criar_personagem_srd(
    p_nome, p_raca_id, p_classe_id, p_atributos
  );
  PERFORM public.salvar_pericias_srd(v_character_id, p_pericias);
  PERFORM public.salvar_talentos_srd(v_character_id, p_talentos);
  RETURN v_character_id;
END;
$$;

REVOKE ALL ON FUNCTION public.criar_personagem_srd_completo(TEXT, TEXT, TEXT, JSONB, JSONB, JSONB) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.criar_personagem_srd_completo(TEXT, TEXT, TEXT, JSONB, JSONB, JSONB) TO authenticated;

COMMIT;
