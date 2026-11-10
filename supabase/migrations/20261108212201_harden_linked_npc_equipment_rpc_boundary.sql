
ALTER FUNCTION public.equipar_item_npc_vinculado_srd(bigint,text,text,boolean) SET SCHEMA private;
ALTER FUNCTION private.equipar_item_npc_vinculado_srd(bigint,text,text,boolean) RENAME TO equipar_item_npc_vinculado_impl;
ALTER FUNCTION public.equipar_arma_instancia_npc_vinculado_srd(bigint,text,uuid,text,boolean) SET SCHEMA private;
ALTER FUNCTION private.equipar_arma_instancia_npc_vinculado_srd(bigint,text,uuid,text,boolean) RENAME TO equipar_arma_instancia_npc_vinculado_impl;

CREATE OR REPLACE FUNCTION private.equipar_item_npc_vinculado_impl(
  p_campaign_id bigint,p_token_id text,p_equipment_id text,p_equipado boolean
) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path=pg_catalog,public,pg_temp
AS $function$
DECLARE v_campaign public.campaigns%ROWTYPE; v_token jsonb; v_character_id text; v_owner uuid;
  v_item public.srd_equipment%ROWTYPE; v_slot text;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'Somente o Mestre pode equipar itens de NPCs vinculados.'; END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  SELECT t.value INTO v_token FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END) t(value)
  WHERE t.value->>'id'=btrim(p_token_id) AND t.value->>'tipo'='npc' LIMIT 1;
  IF v_token IS NULL OR NULLIF(v_token->>'sourceCharacterId','') IS NULL THEN RAISE EXCEPTION 'NPC não está vinculado a uma ficha de personagem.'; END IF;
  v_character_id:=v_token->>'sourceCharacterId';
  SELECT ch.user_id INTO v_owner FROM public.characters ch WHERE ch.id::text=v_character_id;
  IF NOT FOUND OR NOT EXISTS (SELECT 1 FROM public.members gm WHERE gm.campaign_id=p_campaign_id AND gm.user_id=v_owner AND gm.role='GM') THEN
    RAISE EXCEPTION 'A ficha vinculada não pertence ao Mestre desta campanha.';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.srd_character_sheets sh WHERE sh.character_id::text=v_character_id) THEN RAISE EXCEPTION 'Ficha SRD vinculada não encontrada.'; END IF;
  SELECT * INTO v_item FROM public.srd_equipment WHERE id=p_equipment_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Equipamento não encontrado.'; END IF;
  v_slot:=public.srd35_equipment_slot(v_item.categoria,v_item.nome);
  IF v_slot IS NULL OR v_slot='' OR v_slot='arma' THEN RAISE EXCEPTION 'Este item não pode ser equipado por esta operação; armas exigem seleção de instância.'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.srd_character_equipment ce WHERE ce.character_id=v_character_id AND ce.equipment_id=p_equipment_id) THEN
    RAISE EXCEPTION 'O item não está no inventário da ficha vinculada.';
  END IF;
  IF coalesce(p_equipado,false) AND v_slot<>'acessorio' THEN
    UPDATE public.srd_character_equipment ce SET equipado=false FROM public.srd_equipment old
    WHERE ce.character_id=v_character_id AND ce.equipment_id=old.id AND public.srd35_equipment_slot(old.categoria,old.nome)=v_slot;
  END IF;
  UPDATE public.srd_character_equipment SET equipado=coalesce(p_equipado,false)
  WHERE character_id=v_character_id AND equipment_id=p_equipment_id;
  RETURN jsonb_build_object('campaign_id',p_campaign_id,'token_id',btrim(p_token_id),'character_id',v_character_id,'equipment_id',p_equipment_id,'equipado',coalesce(p_equipado,false));
END;
$function$;

CREATE OR REPLACE FUNCTION private.equipar_arma_instancia_npc_vinculado_impl(
  p_campaign_id bigint,p_token_id text,p_instance_id uuid,p_hand_slot text,p_equipado boolean
) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path=pg_catalog,public,pg_temp
AS $function$
DECLARE v_campaign public.campaigns%ROWTYPE; v_token jsonb; v_character_id text; v_owner uuid;
  v_instance public.srd_character_weapon_instances%ROWTYPE; v_item public.srd_equipment%ROWTYPE; v_two_handed boolean;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'Somente o Mestre pode equipar armas de NPCs vinculados.'; END IF;
  IF p_hand_slot IS NULL OR p_hand_slot NOT IN ('main_hand','off_hand') THEN RAISE EXCEPTION 'Mão inválida.'; END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  SELECT t.value INTO v_token FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END) t(value)
  WHERE t.value->>'id'=btrim(p_token_id) AND t.value->>'tipo'='npc' LIMIT 1;
  IF v_token IS NULL OR NULLIF(v_token->>'sourceCharacterId','') IS NULL THEN RAISE EXCEPTION 'NPC não está vinculado a uma ficha de personagem.'; END IF;
  v_character_id:=v_token->>'sourceCharacterId';
  SELECT ch.user_id INTO v_owner FROM public.characters ch WHERE ch.id::text=v_character_id;
  IF NOT FOUND OR NOT EXISTS (SELECT 1 FROM public.members gm WHERE gm.campaign_id=p_campaign_id AND gm.user_id=v_owner AND gm.role='GM') THEN
    RAISE EXCEPTION 'A ficha vinculada não pertence ao Mestre desta campanha.';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.srd_character_sheets sh WHERE sh.character_id::text=v_character_id) THEN RAISE EXCEPTION 'Ficha SRD vinculada não encontrada.'; END IF;
  SELECT * INTO v_instance FROM public.srd_character_weapon_instances WHERE instance_id=p_instance_id AND character_id=v_character_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Instância de arma não encontrada na ficha vinculada.'; END IF;
  SELECT * INTO v_item FROM public.srd_equipment WHERE id=v_instance.equipment_id;
  IF NOT FOUND OR public.srd35_equipment_slot(v_item.categoria,v_item.nome)<>'arma' THEN RAISE EXCEPTION 'A instância selecionada não corresponde a uma arma válida.'; END IF;
  v_two_handed:=coalesce(v_item.detalhes->>'weapon_two_handed','false')='true';
  IF coalesce(p_equipado,false) THEN
    IF p_hand_slot='off_hand' AND v_two_handed THEN RAISE EXCEPTION 'Arma de duas mãos não pode ocupar a mão secundária.'; END IF;
    IF p_hand_slot='main_hand' AND v_two_handed AND EXISTS (SELECT 1 FROM public.srd_character_weapon_instances WHERE character_id=v_character_id AND equipado AND hand_slot='off_hand') THEN
      RAISE EXCEPTION 'Desequipe a arma secundária antes de usar uma arma de duas mãos.';
    END IF;
    IF p_hand_slot='off_hand' AND EXISTS (
      SELECT 1 FROM public.srd_character_weapon_instances wi JOIN public.srd_equipment eq ON eq.id=wi.equipment_id
      WHERE wi.character_id=v_character_id AND wi.equipado AND wi.hand_slot='main_hand' AND coalesce(eq.detalhes->>'weapon_two_handed','false')='true'
    ) THEN RAISE EXCEPTION 'Arma principal de duas mãos impede arma secundária.'; END IF;
    UPDATE public.srd_character_weapon_instances SET equipado=false,hand_slot=NULL
    WHERE character_id=v_character_id AND equipado AND (hand_slot=p_hand_slot OR instance_id=p_instance_id);
    UPDATE public.srd_character_weapon_instances SET equipado=true,hand_slot=p_hand_slot
    WHERE character_id=v_character_id AND instance_id=p_instance_id;
  ELSE
    UPDATE public.srd_character_weapon_instances SET equipado=false,hand_slot=NULL
    WHERE character_id=v_character_id AND instance_id=p_instance_id AND equipado AND hand_slot=p_hand_slot;
    IF NOT FOUND THEN RAISE EXCEPTION 'Esta instância não está equipada nesta mão.'; END IF;
  END IF;
  UPDATE public.srd_character_equipment ce SET equipado=EXISTS (
    SELECT 1 FROM public.srd_character_weapon_instances wi WHERE wi.character_id=ce.character_id AND wi.equipment_id=ce.equipment_id AND wi.equipado
  ),hand_slot=(
    SELECT wi.hand_slot FROM public.srd_character_weapon_instances wi WHERE wi.character_id=ce.character_id AND wi.equipment_id=ce.equipment_id AND wi.equipado
    ORDER BY CASE wi.hand_slot WHEN 'main_hand' THEN 0 ELSE 1 END LIMIT 1
  ) WHERE ce.character_id=v_character_id AND ce.equipment_id=v_instance.equipment_id;
  RETURN jsonb_build_object('campaign_id',p_campaign_id,'token_id',btrim(p_token_id),'character_id',v_character_id,
    'instance_id',p_instance_id,'equipment_id',v_instance.equipment_id,'hand_slot',p_hand_slot,'equipado',coalesce(p_equipado,false));
END;
$function$;

CREATE OR REPLACE FUNCTION public.equipar_item_npc_vinculado_srd(bigint,text,text,boolean)
RETURNS jsonb LANGUAGE sql SECURITY INVOKER SET search_path=pg_catalog,public,private
AS $function$ SELECT private.equipar_item_npc_vinculado_impl($1,$2,$3,$4); $function$;
CREATE OR REPLACE FUNCTION public.equipar_arma_instancia_npc_vinculado_srd(bigint,text,uuid,text,boolean)
RETURNS jsonb LANGUAGE sql SECURITY INVOKER SET search_path=pg_catalog,public,private
AS $function$ SELECT private.equipar_arma_instancia_npc_vinculado_impl($1,$2,$3,$4,$5); $function$;

REVOKE ALL ON FUNCTION public.equipar_item_npc_vinculado_srd(bigint,text,text,boolean) FROM PUBLIC,anon;
REVOKE ALL ON FUNCTION public.equipar_arma_instancia_npc_vinculado_srd(bigint,text,uuid,text,boolean) FROM PUBLIC,anon;
REVOKE ALL ON FUNCTION private.equipar_item_npc_vinculado_impl(bigint,text,text,boolean) FROM PUBLIC,anon;
REVOKE ALL ON FUNCTION private.equipar_arma_instancia_npc_vinculado_impl(bigint,text,uuid,text,boolean) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.equipar_item_npc_vinculado_srd(bigint,text,text,boolean) TO authenticated;
GRANT EXECUTE ON FUNCTION public.equipar_arma_instancia_npc_vinculado_srd(bigint,text,uuid,text,boolean) TO authenticated;
GRANT EXECUTE ON FUNCTION private.equipar_item_npc_vinculado_impl(bigint,text,text,boolean) TO authenticated;
GRANT EXECUTE ON FUNCTION private.equipar_arma_instancia_npc_vinculado_impl(bigint,text,uuid,text,boolean) TO authenticated;
