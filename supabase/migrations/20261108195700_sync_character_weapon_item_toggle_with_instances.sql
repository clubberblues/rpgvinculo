
CREATE OR REPLACE FUNCTION public.equipar_item_srd_maos(
  p_character_id text,
  p_equipment_id text,
  p_hand_slot text,
  p_equipado boolean
)
RETURNS jsonb
LANGUAGE plpgsql
SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  v_campaign_id bigint;
  v_item public.srd_equipment%rowtype;
  v_instance_id uuid;
  v_count integer;
  v_equipped record;
  v_result jsonb;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF p_hand_slot IS NULL OR p_hand_slot NOT IN ('main_hand','off_hand') THEN
    RAISE EXCEPTION 'Mão inválida. Escolha mão principal ou secundária.';
  END IF;

  SELECT ch.campaign_id INTO v_campaign_id
  FROM public.characters ch
  WHERE ch.id::text=btrim(p_character_id);
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha não encontrada.'; END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.characters ch
    WHERE ch.id::text=btrim(p_character_id)
      AND (ch.user_id=auth.uid() OR public.my_role(v_campaign_id)='GM')
  ) THEN
    RAISE EXCEPTION 'Somente o dono da ficha ou o Mestre desta campanha pode alterar o equipamento.';
  END IF;

  SELECT * INTO v_item
  FROM public.srd_equipment
  WHERE id=p_equipment_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Equipamento não encontrado.'; END IF;
  IF public.srd35_equipment_slot(v_item.categoria,v_item.nome)<>'arma' THEN
    RAISE EXCEPTION 'Somente armas podem ocupar uma das mãos.';
  END IF;

  SELECT count(*), min(instance_id)
    INTO v_count, v_instance_id
  FROM public.srd_character_weapon_instances
  WHERE character_id=btrim(p_character_id)
    AND equipment_id=p_equipment_id;

  IF v_count=0 THEN
    RAISE EXCEPTION 'Não existe instância desta arma vinculada à ficha.';
  END IF;

  IF coalesce(p_equipado,false) THEN
    IF v_count<>1 THEN
      RAISE EXCEPTION 'Há múltiplas instâncias desta arma. Selecione a instância específica no inventário.';
    END IF;
    v_result := public.equipar_arma_instancia_personagem(
      btrim(p_character_id),v_instance_id,p_hand_slot,true
    );
    RETURN v_result;
  END IF;

  FOR v_equipped IN
    SELECT instance_id,hand_slot
    FROM public.srd_character_weapon_instances
    WHERE character_id=btrim(p_character_id)
      AND equipment_id=p_equipment_id
      AND equipado=true
  LOOP
    v_result := public.equipar_arma_instancia_personagem(
      btrim(p_character_id),v_equipped.instance_id,v_equipped.hand_slot,false
    );
  END LOOP;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Esta arma não está equipada.';
  END IF;

  RETURN jsonb_build_object(
    'character_id',btrim(p_character_id),
    'equipment_id',p_equipment_id,
    'hand_slot',p_hand_slot,
    'equipado',false
  );
END;
$function$;

REVOKE ALL ON FUNCTION public.equipar_item_srd_maos(text,text,text,boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.equipar_item_srd_maos(text,text,text,boolean) TO authenticated;
