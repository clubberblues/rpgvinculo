CREATE OR REPLACE FUNCTION public.iniciar_sequencia_ataque_iterativo_srd(
  p_campaign_id bigint,
  p_character_id text,
  p_target_token_id text,
  p_attack_type text,
  p_weapon_instance_id uuid,
  p_weapon_hand_slot text,
  p_weapon_end text
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, priv, pg_temp
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
$function$;

REVOKE ALL ON FUNCTION public.iniciar_sequencia_ataque_iterativo_srd(bigint,text,text,text,uuid,text,text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.iniciar_sequencia_ataque_iterativo_srd(bigint,text,text,text,uuid,text,text) TO authenticated;