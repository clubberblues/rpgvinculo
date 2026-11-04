-- Compatibilidade entre o esquema SRD já existente e os campos usados pela mesa D&D 3.5.
-- O catálogo original usa nomes legados; estas colunas mantêm compatibilidade e preservam os dados.

ALTER TABLE public.srd_equipment
  ADD COLUMN IF NOT EXISTS categoria TEXT,
  ADD COLUMN IF NOT EXISTS bonus_ca INTEGER,
  ADD COLUMN IF NOT EXISTS bonus_max_des INTEGER,
  ADD COLUMN IF NOT EXISTS custo_po NUMERIC(10,2),
  ADD COLUMN IF NOT EXISTS detalhes JSONB NOT NULL DEFAULT '{}'::JSONB;

UPDATE public.srd_equipment
SET categoria = CASE tipo
  WHEN 'arma' THEN 'arma'
  WHEN 'armadura' THEN 'armadura'
  WHEN 'escudo' THEN 'escudo'
  WHEN 'pocao' THEN 'consumivel'
  ELSE 'outro'
END,
bonus_ca = COALESCE(bonus_ca, ca_bonus, 0),
bonus_max_des = COALESCE(bonus_max_des, max_des),
custo_po = COALESCE(custo_po, preco, 0),
detalhes = COALESCE(detalhes, '{}'::JSONB)
  || jsonb_strip_nulls(jsonb_build_object('critico', critico))
WHERE categoria IS NULL OR bonus_ca IS NULL OR custo_po IS NULL OR detalhes = '{}'::JSONB;

ALTER TABLE public.srd_equipment
  ALTER COLUMN categoria SET NOT NULL,
  ALTER COLUMN bonus_ca SET DEFAULT 0,
  ALTER COLUMN custo_po SET DEFAULT 0,
  ALTER COLUMN detalhes SET DEFAULT '{}'::JSONB;

ALTER TABLE public.srd_races
  ADD COLUMN IF NOT EXISTS briefing TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS imagem_url TEXT,
  ADD COLUMN IF NOT EXISTS srd_source_url TEXT;

ALTER TABLE public.srd_classes
  ADD COLUMN IF NOT EXISTS imagem_url TEXT;

UPDATE public.srd_races
SET srd_source_url = 'https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/races.md'
WHERE srd_source_url IS NULL;

UPDATE public.srd_equipment
SET srd_source_url = 'https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/equipment.md'
WHERE srd_source_url IS NULL;

-- A relation uses text character IDs to match the current client and bigint character IDs.
CREATE TABLE IF NOT EXISTS public.srd_character_equipment (
  character_id TEXT NOT NULL,
  equipment_id TEXT NOT NULL REFERENCES public.srd_equipment(id) ON DELETE RESTRICT,
  quantidade INTEGER NOT NULL DEFAULT 1 CHECK (quantidade > 0),
  equipado BOOLEAN NOT NULL DEFAULT FALSE,
  criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (character_id, equipment_id)
);

CREATE INDEX IF NOT EXISTS idx_srd_character_equipment_equipment_id
  ON public.srd_character_equipment(equipment_id);

ALTER TABLE public.srd_character_equipment ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON public.srd_character_equipment TO authenticated;

DROP POLICY IF EXISTS srd_character_equipment_owner_select ON public.srd_character_equipment;
CREATE POLICY srd_character_equipment_owner_select
ON public.srd_character_equipment
FOR SELECT TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.characters AS ch
  WHERE ch.id::TEXT = srd_character_equipment.character_id
    AND ch.user_id = (SELECT auth.uid())
));

DROP POLICY IF EXISTS srd_character_equipment_campaign_gm_select ON public.srd_character_equipment;
CREATE POLICY srd_character_equipment_campaign_gm_select
ON public.srd_character_equipment
FOR SELECT TO authenticated
USING (EXISTS (
  SELECT 1
  FROM public.characters AS ch
  JOIN public.members AS member ON member.campaign_id = ch.campaign_id
  WHERE ch.id::TEXT = srd_character_equipment.character_id
    AND member.user_id = (SELECT auth.uid())
    AND member.role = 'GM'
));

CREATE OR REPLACE FUNCTION public.equipar_item_srd(
  p_character_id TEXT,
  p_equipment_id TEXT,
  p_equipado BOOLEAN
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_category TEXT;
  v_owned INTEGER;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  IF p_equipado IS NULL THEN RAISE EXCEPTION 'Informe se o item será equipado.'; END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.characters AS ch
    WHERE ch.id::TEXT = BTRIM(p_character_id) AND ch.user_id = auth.uid()
  ) THEN RAISE EXCEPTION 'A ficha não pertence à sua conta.'; END IF;

  SELECT categoria INTO v_category FROM public.srd_equipment WHERE id = p_equipment_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Equipamento não encontrado.'; END IF;

  SELECT quantidade INTO v_owned
  FROM public.srd_character_equipment
  WHERE character_id = BTRIM(p_character_id) AND equipment_id = p_equipment_id
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'O item não está na mochila deste personagem.'; END IF;

  IF p_equipado THEN
    UPDATE public.srd_character_equipment AS inventory
    SET equipado = FALSE
    FROM public.srd_equipment AS equipment
    WHERE inventory.character_id = BTRIM(p_character_id)
      AND inventory.equipment_id = equipment.id
      AND equipment.categoria = v_category;
  END IF;

  UPDATE public.srd_character_equipment
  SET equipado = p_equipado
  WHERE character_id = BTRIM(p_character_id) AND equipment_id = p_equipment_id;

  RETURN jsonb_build_object(
    'character_id', BTRIM(p_character_id),
    'equipment_id', p_equipment_id,
    'equipado', p_equipado
  );
END;
$$;
REVOKE ALL ON FUNCTION public.equipar_item_srd(TEXT,TEXT,BOOLEAN) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.equipar_item_srd(TEXT,TEXT,BOOLEAN) TO authenticated;

CREATE OR REPLACE FUNCTION public.entregar_item_srd(
  p_campaign_id BIGINT,
  p_character_id TEXT,
  p_equipment_id TEXT,
  p_quantidade INTEGER DEFAULT 1
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_role TEXT;
  v_user_id UUID;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT role INTO v_role
  FROM public.members
  WHERE campaign_id = p_campaign_id AND user_id = auth.uid()
  LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'Somente o Mestre pode entregar equipamento.'; END IF;
  IF p_quantidade IS NULL OR p_quantidade < 1 OR p_quantidade > 99 THEN
    RAISE EXCEPTION 'Quantidade inválida.';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.srd_equipment WHERE id = p_equipment_id) THEN
    RAISE EXCEPTION 'Equipamento não encontrado.';
  END IF;

  SELECT ch.user_id INTO v_user_id
  FROM public.characters AS ch
  JOIN public.members AS player
    ON player.campaign_id = ch.campaign_id
   AND player.user_id = ch.user_id
   AND player.role = 'PLAYER'
  WHERE ch.id::TEXT = BTRIM(p_character_id)
    AND ch.campaign_id = p_campaign_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'A ficha não pertence a um jogador desta campanha.'; END IF;

  INSERT INTO public.srd_character_equipment(character_id,equipment_id,quantidade,equipado)
  VALUES (BTRIM(p_character_id),p_equipment_id,p_quantidade,FALSE)
  ON CONFLICT (character_id,equipment_id)
  DO UPDATE SET quantidade = public.srd_character_equipment.quantidade + EXCLUDED.quantidade;

  RETURN jsonb_build_object(
    'character_id', BTRIM(p_character_id),
    'equipment_id', p_equipment_id,
    'quantidade', p_quantidade
  );
END;
$$;
REVOKE ALL ON FUNCTION public.entregar_item_srd(BIGINT,TEXT,TEXT,INTEGER) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.entregar_item_srd(BIGINT,TEXT,TEXT,INTEGER) TO authenticated;

CREATE OR REPLACE FUNCTION public.usar_pocao_cura_srd(
  p_character_id TEXT,
  p_equipment_id TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_count INTEGER;
  v_current_hp INTEGER;
  v_max_hp INTEGER;
  v_dice INTEGER;
  v_flat INTEGER;
  v_healing INTEGER;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.characters
    WHERE id::TEXT = BTRIM(p_character_id) AND user_id = auth.uid()
  ) THEN RAISE EXCEPTION 'A ficha não pertence à sua conta.'; END IF;

  CASE p_equipment_id
    WHEN 'pocao_cura_lig' THEN v_dice := 1; v_flat := 1;
    WHEN 'pocao_cura_mod' THEN v_dice := 2; v_flat := 3;
    WHEN 'pocao_cura_grav' THEN v_dice := 3; v_flat := 5;
    ELSE RAISE EXCEPTION 'Esta poção não tem efeito de cura automatizado.';
  END CASE;

  SELECT quantidade INTO v_count
  FROM public.srd_character_equipment
  WHERE character_id = BTRIM(p_character_id)
    AND equipment_id = p_equipment_id
    AND quantidade > 0
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Poção não encontrada na mochila.'; END IF;

  SELECT pv_atual, pv_max INTO v_current_hp, v_max_hp
  FROM public.srd_character_sheets
  WHERE character_id::TEXT = BTRIM(p_character_id)
  FOR UPDATE;
  IF NOT FOUND OR v_max_hp IS NULL THEN RAISE EXCEPTION 'Ficha SRD sem PV máximo.'; END IF;

  SELECT v_flat + COALESCE(SUM(1 + FLOOR(random() * 8)::INTEGER),0)
  INTO v_healing
  FROM generate_series(1,v_dice);

  UPDATE public.srd_character_sheets
  SET pv_atual = LEAST(v_max_hp,COALESCE(v_current_hp,0)+v_healing)
  WHERE character_id::TEXT = BTRIM(p_character_id)
  RETURNING pv_atual INTO v_current_hp;

  IF v_count = 1 THEN
    DELETE FROM public.srd_character_equipment
    WHERE character_id = BTRIM(p_character_id) AND equipment_id = p_equipment_id;
  ELSE
    UPDATE public.srd_character_equipment
    SET quantidade = quantidade - 1
    WHERE character_id = BTRIM(p_character_id) AND equipment_id = p_equipment_id;
  END IF;

  RETURN jsonb_build_object(
    'character_id', BTRIM(p_character_id),
    'healing_rolled', v_healing,
    'pv_atual', v_current_hp,
    'pv_max', v_max_hp,
    'quantidade_restante', GREATEST(v_count - 1,0)
  );
END;
$$;
REVOKE ALL ON FUNCTION public.usar_pocao_cura_srd(TEXT,TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.usar_pocao_cura_srd(TEXT,TEXT) TO authenticated;

CREATE OR REPLACE FUNCTION public.limpar_inventario_srd_ao_excluir_personagem()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
BEGIN
  DELETE FROM public.srd_character_equipment WHERE character_id = OLD.id::TEXT;
  RETURN OLD;
END;
$$;
REVOKE ALL ON FUNCTION public.limpar_inventario_srd_ao_excluir_personagem() FROM PUBLIC, anon;
DROP TRIGGER IF EXISTS trg_limpar_inventario_srd_ao_excluir_personagem ON public.characters;
CREATE TRIGGER trg_limpar_inventario_srd_ao_excluir_personagem
AFTER DELETE ON public.characters
FOR EACH ROW EXECUTE FUNCTION public.limpar_inventario_srd_ao_excluir_personagem();
