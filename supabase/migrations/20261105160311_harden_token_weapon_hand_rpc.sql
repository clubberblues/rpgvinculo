CREATE SCHEMA IF NOT EXISTS private;
REVOKE ALL ON SCHEMA private FROM PUBLIC, anon;
GRANT USAGE ON SCHEMA private TO authenticated;

CREATE OR REPLACE FUNCTION private.equipar_item_token_srd_maos_impl(
 p_campaign_id bigint,p_token_id text,p_equipment_id text,p_hand_slot text,p_equipado boolean
) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog','public'
AS $function$
DECLARE v_role text; v_item public.srd_equipment%rowtype; v_campaign public.campaigns%rowtype; v_token jsonb; v_two_handed boolean;
BEGIN
 IF (SELECT auth.uid()) IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
 SELECT member.role INTO v_role FROM public.members AS member WHERE member.campaign_id=p_campaign_id AND member.user_id=(SELECT auth.uid()) LIMIT 1;
 IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'Somente o Mestre pode alterar equipamento de NPCs e monstros.'; END IF;
 IF p_hand_slot IS NULL OR p_hand_slot NOT IN ('main_hand','off_hand') THEN RAISE EXCEPTION 'Mão inválida. Escolha mão principal ou secundária.'; END IF;
 SELECT * INTO v_item FROM public.srd_equipment WHERE id=p_equipment_id;
 IF NOT FOUND THEN RAISE EXCEPTION 'Equipamento não encontrado.'; END IF;
 IF public.srd35_equipment_slot(v_item.categoria,v_item.nome)<>'arma' THEN RAISE EXCEPTION 'Somente armas podem ocupar uma das mãos.'; END IF;
 v_two_handed:=coalesce(v_item.detalhes->>'weapon_two_handed','false')='true';
 SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Mesa não encontrada.'; END IF;
 SELECT t.value INTO v_token FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END) AS t(value)
 WHERE t.value->>'id'=btrim(p_token_id) LIMIT 1;
 IF v_token IS NULL OR v_token->>'tipo' NOT IN ('npc','monstro') THEN RAISE EXCEPTION 'Token de NPC/monstro não encontrado.'; END IF;
 IF NOT EXISTS (SELECT 1 FROM public.srd_cba_token_equipment WHERE campaign_id=p_campaign_id AND token_id=btrim(p_token_id) AND equipment_id=p_equipment_id) THEN RAISE EXCEPTION 'O item não está no inventário deste token.'; END IF;
 IF coalesce(p_equipado,false) THEN
  IF p_hand_slot='off_hand' AND v_two_handed THEN RAISE EXCEPTION 'Uma arma de duas mãos não pode ocupar a mão secundária.'; END IF;
  IF p_hand_slot='main_hand' AND v_two_handed AND EXISTS (SELECT 1 FROM public.srd_cba_token_equipment WHERE campaign_id=p_campaign_id AND token_id=btrim(p_token_id) AND equipado=true AND hand_slot='off_hand') THEN RAISE EXCEPTION 'Desequipe a arma da mão secundária antes de equipar uma arma de duas mãos.'; END IF;
  IF p_hand_slot='off_hand' AND EXISTS (
   SELECT 1 FROM public.srd_cba_token_equipment held JOIN public.srd_equipment main_weapon ON main_weapon.id=held.equipment_id
   WHERE held.campaign_id=p_campaign_id AND held.token_id=btrim(p_token_id) AND held.equipado=true AND held.hand_slot='main_hand'
    AND coalesce(main_weapon.detalhes->>'weapon_two_handed','false')='true'
  ) THEN RAISE EXCEPTION 'Uma arma de duas mãos na mão principal impede equipar arma secundária.'; END IF;
  UPDATE public.srd_cba_token_equipment SET equipado=false
   WHERE campaign_id=p_campaign_id AND token_id=btrim(p_token_id) AND equipado=true AND (hand_slot=p_hand_slot OR equipment_id=p_equipment_id);
  UPDATE public.srd_cba_token_equipment SET equipado=true,hand_slot=p_hand_slot
   WHERE campaign_id=p_campaign_id AND token_id=btrim(p_token_id) AND equipment_id=p_equipment_id;
 ELSE
  UPDATE public.srd_cba_token_equipment SET equipado=false
   WHERE campaign_id=p_campaign_id AND token_id=btrim(p_token_id) AND equipment_id=p_equipment_id AND hand_slot=p_hand_slot;
  IF NOT FOUND THEN RAISE EXCEPTION 'A arma não está equipada nesta mão.'; END IF;
 END IF;
 RETURN jsonb_build_object('campaign_id',p_campaign_id,'token_id',btrim(p_token_id),'equipment_id',p_equipment_id,'hand_slot',p_hand_slot,'equipado',coalesce(p_equipado,false),'cba_data',v_campaign.cba_data);
END;
$function$;
REVOKE ALL ON FUNCTION private.equipar_item_token_srd_maos_impl(bigint,text,text,text,boolean) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION private.equipar_item_token_srd_maos_impl(bigint,text,text,text,boolean) TO authenticated;

CREATE OR REPLACE FUNCTION public.equipar_item_token_srd_maos(
 p_campaign_id bigint,p_token_id text,p_equipment_id text,p_hand_slot text,p_equipado boolean
) RETURNS jsonb LANGUAGE sql SECURITY INVOKER
SET search_path TO 'pg_catalog','public','private'
AS $function$
 SELECT private.equipar_item_token_srd_maos_impl($1,$2,$3,$4,$5);
$function$;
REVOKE ALL ON FUNCTION public.equipar_item_token_srd_maos(bigint,text,text,text,boolean) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.equipar_item_token_srd_maos(bigint,text,text,text,boolean) TO authenticated;