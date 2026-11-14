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
  v_campaign_id BIGINT;
  v_item public.srd_equipment%ROWTYPE;
  v_slot TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  SELECT ch.campaign_id
    INTO v_campaign_id
    FROM public.characters AS ch
   WHERE ch.id::TEXT = BTRIM(p_character_id)
   FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Ficha não encontrada.';
  END IF;

  IF NOT EXISTS (
    SELECT 1
      FROM public.characters AS ch
     WHERE ch.id::TEXT = BTRIM(p_character_id)
       AND (
         ch.user_id = auth.uid()
         OR EXISTS (
           SELECT 1
             FROM public.members AS member
            WHERE member.campaign_id = v_campaign_id
              AND member.user_id = auth.uid()
              AND member.role = 'GM'
         )
       )
  ) THEN
    RAISE EXCEPTION 'Somente o dono da ficha ou o Mestre desta campanha pode alterar o equipamento.';
  END IF;

  SELECT *
    INTO v_item
    FROM public.srd_equipment
   WHERE id = p_equipment_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Equipamento não encontrado.';
  END IF;

  v_slot := public.srd35_equipment_slot(v_item.categoria, v_item.nome);
  IF v_slot IS NULL OR v_slot = '' THEN
    RAISE EXCEPTION 'Este item não pode ser equipado.';
  END IF;

  IF COALESCE(p_equipado, FALSE) AND v_slot <> 'acessorio' THEN
    UPDATE public.srd_character_equipment AS held
       SET equipado = FALSE
      FROM public.srd_equipment AS old
     WHERE held.character_id = BTRIM(p_character_id)
       AND held.equipment_id = old.id
       AND public.srd35_equipment_slot(old.categoria, old.nome) = v_slot;
  END IF;

  UPDATE public.srd_character_equipment
     SET equipado = COALESCE(p_equipado, FALSE)
   WHERE character_id = BTRIM(p_character_id)
     AND equipment_id = p_equipment_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'O item não está no inventário desta ficha.';
  END IF;

  RETURN jsonb_build_object(
    'character_id', BTRIM(p_character_id),
    'equipment_id', p_equipment_id,
    'equipado', COALESCE(p_equipado, FALSE)
  );
END;
$$;

REVOKE ALL ON FUNCTION public.equipar_item_srd(TEXT, TEXT, BOOLEAN)
  FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.equipar_item_srd(TEXT, TEXT, BOOLEAN)
  TO authenticated;

NOTIFY pgrst, 'reload schema';
