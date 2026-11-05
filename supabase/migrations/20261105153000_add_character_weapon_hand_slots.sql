-- Permite equipar uma arma em cada mão sem a regra antiga de desequipar
-- automaticamente toda arma da mesma categoria.
-- A execução dos talentos de duas armas permanece bloqueada até a sequência
-- mista de ataques ser implementada e validada ponta a ponta.
BEGIN;

ALTER TABLE public.srd_character_equipment
  ADD COLUMN IF NOT EXISTS hand_slot TEXT;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid='public.srd_character_equipment'::regclass
      AND conname='srd_character_equipment_hand_slot_check'
  ) THEN
    ALTER TABLE public.srd_character_equipment
      ADD CONSTRAINT srd_character_equipment_hand_slot_check
      CHECK (hand_slot IS NULL OR hand_slot IN ('main_hand','off_hand'));
  END IF;
END $$;

UPDATE public.srd_character_equipment held
SET hand_slot='main_hand'
FROM public.srd_equipment gear
WHERE held.equipment_id=gear.id
  AND held.equipado=true
  AND public.srd35_equipment_slot(gear.categoria,gear.nome)='arma'
  AND held.hand_slot IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS srd_character_equipment_one_weapon_per_hand
  ON public.srd_character_equipment(character_id,hand_slot)
  WHERE equipado=true AND hand_slot IS NOT NULL;

CREATE OR REPLACE FUNCTION public.equipar_item_srd_maos(
  p_character_id TEXT,
  p_equipment_id TEXT,
  p_hand_slot TEXT,
  p_equipado BOOLEAN
)
RETURNS JSONB
LANGUAGE plpgsql
SET search_path = 'pg_catalog','public'
AS $function$
DECLARE
  v_campaign_id BIGINT;
  v_item public.srd_equipment%ROWTYPE;
  v_two_handed BOOLEAN;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF p_hand_slot IS NULL OR p_hand_slot NOT IN ('main_hand','off_hand') THEN
    RAISE EXCEPTION 'Mão inválida. Escolha mão principal ou secundária.';
  END IF;

  SELECT ch.campaign_id INTO v_campaign_id
  FROM public.characters ch WHERE ch.id::TEXT=BTRIM(p_character_id);
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha não encontrada.'; END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.characters ch
    WHERE ch.id::TEXT=BTRIM(p_character_id)
      AND (ch.user_id=auth.uid() OR public.my_role(v_campaign_id)='GM')
  ) THEN
    RAISE EXCEPTION 'Somente o dono da ficha ou o Mestre desta campanha pode alterar o equipamento.';
  END IF;

  SELECT * INTO v_item FROM public.srd_equipment WHERE id=p_equipment_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Equipamento não encontrado.'; END IF;
  IF public.srd35_equipment_slot(v_item.categoria,v_item.nome)<>'arma' THEN
    RAISE EXCEPTION 'Somente armas podem ocupar uma das mãos.';
  END IF;

  v_two_handed:=COALESCE(v_item.detalhes->>'weapon_two_handed','false')='true';
  IF COALESCE(p_equipado,FALSE) THEN
    IF p_hand_slot='off_hand' AND v_two_handed THEN
      RAISE EXCEPTION 'Uma arma de duas mãos não pode ser equipada na mão secundária.';
    END IF;
    IF p_hand_slot='main_hand' AND v_two_handed AND EXISTS (
      SELECT 1 FROM public.srd_character_equipment held
      WHERE held.character_id=BTRIM(p_character_id)
        AND held.equipado=TRUE AND held.hand_slot='off_hand'
    ) THEN
      RAISE EXCEPTION 'Desequipe a arma da mão secundária antes de equipar uma arma de duas mãos.';
    END IF;
    IF p_hand_slot='off_hand' AND EXISTS (
      SELECT 1 FROM public.srd_character_equipment held
      JOIN public.srd_equipment main_weapon ON main_weapon.id=held.equipment_id
      WHERE held.character_id=BTRIM(p_character_id)
        AND held.equipado=TRUE AND held.hand_slot='main_hand'
        AND COALESCE(main_weapon.detalhes->>'weapon_two_handed','false')='true'
    ) THEN
      RAISE EXCEPTION 'Uma arma de duas mãos na mão principal impede equipar outra arma na mão secundária.';
    END IF;

    UPDATE public.srd_character_equipment
       SET equipado=FALSE
     WHERE character_id=BTRIM(p_character_id) AND equipado=TRUE
       AND (hand_slot=p_hand_slot OR equipment_id=p_equipment_id);

    UPDATE public.srd_character_equipment
       SET equipado=TRUE,hand_slot=p_hand_slot
     WHERE character_id=BTRIM(p_character_id) AND equipment_id=p_equipment_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'O item não está no inventário desta ficha.'; END IF;
  ELSE
    UPDATE public.srd_character_equipment
       SET equipado=FALSE
     WHERE character_id=BTRIM(p_character_id)
       AND equipment_id=p_equipment_id AND hand_slot=p_hand_slot;
    IF NOT FOUND THEN RAISE EXCEPTION 'A arma não está equipada nesta mão.'; END IF;
  END IF;

  RETURN jsonb_build_object(
    'character_id',BTRIM(p_character_id),
    'equipment_id',p_equipment_id,
    'hand_slot',p_hand_slot,
    'equipado',COALESCE(p_equipado,FALSE)
  );
END;
$function$;

CREATE OR REPLACE FUNCTION public.equipar_item_srd(
  p_character_id TEXT,
  p_equipment_id TEXT,
  p_equipado BOOLEAN
)
RETURNS JSONB
LANGUAGE plpgsql
SET search_path TO 'pg_catalog','public'
AS $function$
DECLARE
  v_campaign_id BIGINT;
  v_item public.srd_equipment%ROWTYPE;
  v_slot TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  SELECT ch.campaign_id INTO v_campaign_id
  FROM public.characters ch WHERE ch.id::TEXT=BTRIM(p_character_id);
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha não encontrada.'; END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.characters ch
    WHERE ch.id::TEXT=BTRIM(p_character_id)
      AND (ch.user_id=auth.uid() OR public.my_role(v_campaign_id)='GM')
  ) THEN
    RAISE EXCEPTION 'Somente o dono da ficha ou o Mestre desta campanha pode alterar o equipamento.';
  END IF;

  SELECT * INTO v_item FROM public.srd_equipment WHERE id=p_equipment_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Equipamento não encontrado.'; END IF;
  v_slot:=public.srd35_equipment_slot(v_item.categoria,v_item.nome);
  IF v_slot IS NULL OR v_slot='' THEN
    RAISE EXCEPTION 'Este item não pode ser equipado.';
  END IF;

  IF v_slot='arma' THEN
    RETURN public.equipar_item_srd_maos(p_character_id,p_equipment_id,'main_hand',p_equipado);
  END IF;

  IF COALESCE(p_equipado,FALSE) THEN
    UPDATE public.srd_character_equipment held
       SET equipado=FALSE
      FROM public.srd_equipment old
     WHERE held.character_id=BTRIM(p_character_id)
       AND held.equipment_id=old.id
       AND public.srd35_equipment_slot(old.categoria,old.nome)=v_slot;
  END IF;

  UPDATE public.srd_character_equipment
     SET equipado=COALESCE(p_equipado,FALSE)
   WHERE character_id=BTRIM(p_character_id) AND equipment_id=p_equipment_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'O item não está no inventário desta ficha.'; END IF;

  RETURN jsonb_build_object(
    'character_id',BTRIM(p_character_id),
    'equipment_id',p_equipment_id,
    'equipado',COALESCE(p_equipado,FALSE)
  );
END;
$function$;

REVOKE ALL ON FUNCTION public.equipar_item_srd_maos(TEXT,TEXT,TEXT,BOOLEAN) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.equipar_item_srd_maos(TEXT,TEXT,TEXT,BOOLEAN) TO authenticated;

COMMIT;
