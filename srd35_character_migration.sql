-- Vínculo · integração D&D 3.5 (SRD)
-- Execute uma vez no SQL Editor do Supabase antes de publicar o novo fluxo.
-- Esta migração não cria personagens nem altera registros existentes.

-- Guarda o PV máximo separado do PV atual para a ficha e os cards de mesa.
ALTER TABLE public.srd_character_sheets
  ADD COLUMN IF NOT EXISTS pv_max INTEGER;

-- Ativa RLS antes de conceder leitura autenticada.
ALTER TABLE public.srd_character_sheets ENABLE ROW LEVEL SECURITY;

-- Cria personagem e ficha SRD em uma única transação.
-- Valida compra padrão de 25 pontos (valores-base 8–18), aplica ajustes raciais
-- no servidor e calcula PV inicial com dado de vida máximo + modificador CON.
DROP FUNCTION IF EXISTS public.criar_personagem_srd(TEXT, TEXT, TEXT);
CREATE OR REPLACE FUNCTION public.criar_personagem_srd(
  p_nome TEXT,
  p_raca_id TEXT,
  p_classe_id TEXT,
  p_atributos JSONB
)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_character_id public.characters.id%TYPE;
  v_race public.srd_races%ROWTYPE;
  v_class public.srd_classes%ROWTYPE;
  v_adjustments JSONB;
  v_attributes JSONB;
  v_key TEXT;
  v_raw_score TEXT;
  v_score INTEGER;
  v_score_cost INTEGER;
  v_total_cost INTEGER := 0;
  v_con_mod INTEGER;
  v_pv INTEGER;
  v_nome TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  v_nome := NULLIF(BTRIM(p_nome), '');
  IF v_nome IS NULL THEN
    RAISE EXCEPTION 'Informe o nome do personagem.';
  END IF;
  IF CHAR_LENGTH(v_nome) > 60 THEN
    RAISE EXCEPTION 'O nome do personagem deve ter no máximo 60 caracteres.';
  END IF;

  SELECT * INTO v_race
  FROM public.srd_races
  WHERE id = NULLIF(BTRIM(p_raca_id), '');
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Raça SRD não encontrada.';
  END IF;

  SELECT * INTO v_class
  FROM public.srd_classes
  WHERE id = NULLIF(BTRIM(p_classe_id), '');
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Classe SRD não encontrada.';
  END IF;
  IF v_class.dado_vida IS NULL OR v_class.dado_vida < 1 THEN
    RAISE EXCEPTION 'A classe selecionada não possui um dado de vida válido.';
  END IF;

  IF p_atributos IS NULL OR jsonb_typeof(p_atributos) <> 'object' THEN
    RAISE EXCEPTION 'Distribuição de atributos inválida.';
  END IF;

  FOREACH v_key IN ARRAY ARRAY['FOR','DES','CON','INT','SAB','CAR'] LOOP
    v_raw_score := p_atributos->>v_key;
    IF v_raw_score IS NULL OR v_raw_score !~ '^(8|9|10|11|12|13|14|15|16|17|18)$' THEN
      RAISE EXCEPTION 'Cada atributo-base deve ser um inteiro entre 8 e 18.';
    END IF;
    v_score := v_raw_score::INTEGER;
    v_score_cost := CASE v_score
      WHEN 8 THEN 0 WHEN 9 THEN 1 WHEN 10 THEN 2 WHEN 11 THEN 3
      WHEN 12 THEN 4 WHEN 13 THEN 5 WHEN 14 THEN 6 WHEN 15 THEN 8
      WHEN 16 THEN 10 WHEN 17 THEN 13 WHEN 18 THEN 16
    END;
    v_total_cost := v_total_cost + v_score_cost;
  END LOOP;
  IF v_total_cost > 25 THEN
    RAISE EXCEPTION 'A distribuição usa % pontos; o limite é 25.', v_total_cost;
  END IF;

  v_adjustments := COALESCE(v_race.ajustes_atributos, '{}'::JSONB);
  v_attributes := jsonb_build_object(
    'FOR', (p_atributos->>'FOR')::INTEGER + COALESCE(NULLIF(v_adjustments->>'FOR', '')::INTEGER, 0),
    'DES', (p_atributos->>'DES')::INTEGER + COALESCE(NULLIF(v_adjustments->>'DES', '')::INTEGER, 0),
    'CON', (p_atributos->>'CON')::INTEGER + COALESCE(NULLIF(v_adjustments->>'CON', '')::INTEGER, 0),
    'INT', (p_atributos->>'INT')::INTEGER + COALESCE(NULLIF(v_adjustments->>'INT', '')::INTEGER, 0),
    'SAB', (p_atributos->>'SAB')::INTEGER + COALESCE(NULLIF(v_adjustments->>'SAB', '')::INTEGER, 0),
    'CAR', (p_atributos->>'CAR')::INTEGER + COALESCE(NULLIF(v_adjustments->>'CAR', '')::INTEGER, 0)
  );

  v_con_mod := FLOOR((((v_attributes->>'CON')::NUMERIC - 10) / 2))::INTEGER;
  v_pv := GREATEST(1, v_class.dado_vida + v_con_mod);

  INSERT INTO public.characters (
    user_id, nome, cultura, xp, ouro, retrato_url, campaign_id
  ) VALUES (
    auth.uid(), v_nome, 'Central', 0, 0, NULL, NULL
  )
  RETURNING id INTO v_character_id;

  INSERT INTO public.srd_character_sheets (
    character_id, classe_id, raca_id, nivel, atributos, pv_atual, pv_max, xp, ouro
  ) VALUES (
    v_character_id, v_class.id, v_race.id, 1, v_attributes, v_pv, v_pv, 0, 0
  );

  RETURN v_character_id::TEXT;
END;
$$;

REVOKE ALL ON FUNCTION public.criar_personagem_srd(TEXT, TEXT, TEXT, JSONB) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.criar_personagem_srd(TEXT, TEXT, TEXT, JSONB) TO authenticated;

-- A RPC já existente excluir_ficha_propria remove characters. Este trigger
-- também apaga sua ficha SRD filha antes da exclusão do personagem, preservando
-- a exclusão de propriedade e evitando registros órfãos.
CREATE OR REPLACE FUNCTION public.limpar_ficha_srd_ao_excluir_personagem()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  DELETE FROM public.srd_character_sheets
  WHERE character_id::TEXT = OLD.id::TEXT;
  RETURN OLD;
END;
$$;

REVOKE ALL ON FUNCTION public.limpar_ficha_srd_ao_excluir_personagem() FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_limpar_ficha_srd_ao_excluir_personagem ON public.characters;
CREATE TRIGGER trg_limpar_ficha_srd_ao_excluir_personagem
BEFORE DELETE ON public.characters
FOR EACH ROW
EXECUTE FUNCTION public.limpar_ficha_srd_ao_excluir_personagem();

-- Mantém consultas da galeria e da mesa restritas ao dono da ficha ou a quem
-- compartilha a campanha (membros e proprietário). Catálogos SRD são públicos.
GRANT SELECT ON TABLE public.srd_character_sheets TO authenticated;
GRANT SELECT ON TABLE public.srd_races, public.srd_classes TO anon, authenticated;

DROP POLICY IF EXISTS srd_character_sheets_select_owner_or_campaign ON public.srd_character_sheets;
CREATE POLICY srd_character_sheets_select_owner_or_campaign
ON public.srd_character_sheets
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM public.characters AS ch
    WHERE ch.id::TEXT = srd_character_sheets.character_id::TEXT
      AND (
        ch.user_id = auth.uid()
        OR (
          ch.campaign_id IS NOT NULL
          AND (
            EXISTS (
              SELECT 1 FROM public.members AS m
              WHERE m.campaign_id::TEXT = ch.campaign_id::TEXT
                AND m.user_id = auth.uid()
            )
            OR EXISTS (
              SELECT 1 FROM public.campaigns AS c
              WHERE c.id::TEXT = ch.campaign_id::TEXT
                AND c.owner_id = auth.uid()
            )
          )
        )
      )
  )
);

