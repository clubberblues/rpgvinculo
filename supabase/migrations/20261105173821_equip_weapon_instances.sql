CREATE SCHEMA IF NOT EXISTS private;
REVOKE ALL ON SCHEMA private FROM PUBLIC,anon;
GRANT USAGE ON SCHEMA private TO authenticated;
CREATE OR REPLACE FUNCTION private.equipar_arma_instancia_personagem_impl(p_character_id text,p_instance_id uuid,p_hand_slot text,p_equipado boolean)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'pg_catalog','public'
AS $function$
DECLARE v_campaign_id bigint; v_role text; v_instance public.srd_character_weapon_instances%rowtype; v_item public.srd_equipment%rowtype; v_two_handed boolean;
BEGIN
 IF (SELECT auth.uid()) IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
 IF p_hand_slot NOT IN ('main_hand','off_hand') THEN RAISE EXCEPTION 'Mão inválida.'; END IF;
 SELECT ch.campaign_id INTO v_campaign_id FROM public.characters ch WHERE ch.id::text=btrim(p_character_id) FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Ficha não encontrada.'; END IF;
 SELECT member.role INTO v_role FROM public.members member WHERE member.campaign_id=v_campaign_id AND member.user_id=(SELECT auth.uid()) LIMIT 1;
 IF NOT EXISTS (SELECT 1 FROM public.characters ch WHERE ch.id::text=btrim(p_character_id) AND (ch.user_id=(SELECT auth.uid()) OR v_role='GM')) THEN RAISE EXCEPTION 'Sem permissão para alterar esta ficha.'; END IF;
 SELECT * INTO v_instance FROM public.srd_character_weapon_instances WHERE instance_id=p_instance_id AND character_id=btrim(p_character_id) FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Instância de arma não encontrada nesta ficha.'; END IF;
 SELECT * INTO v_item FROM public.srd_equipment WHERE id=v_instance.equipment_id;
 IF public.srd35_equipment_slot(v_item.categoria,v_item.nome)<>'arma' THEN RAISE EXCEPTION 'O item não é uma arma.'; END IF;
 v_two_handed:=coalesce(v_item.detalhes->>'weapon_two_handed','false')='true';
 IF coalesce(p_equipado,false) THEN
  IF p_hand_slot='off_hand' AND v_two_handed THEN RAISE EXCEPTION 'Arma de duas mãos não pode ocupar a mão secundária.'; END IF;
  IF p_hand_slot='main_hand' AND v_two_handed AND EXISTS (SELECT 1 FROM public.srd_character_weapon_instances WHERE character_id=btrim(p_character_id) AND equipado AND hand_slot='off_hand') THEN RAISE EXCEPTION 'Desequipe a arma secundária antes de usar uma arma de duas mãos.'; END IF;
  IF p_hand_slot='off_hand' AND EXISTS (SELECT 1 FROM public.srd_character_weapon_instances i JOIN public.srd_equipment e ON e.id=i.equipment_id WHERE i.character_id=btrim(p_character_id) AND i.equipado AND i.hand_slot='main_hand' AND coalesce(e.detalhes->>'weapon_two_handed','false')='true') THEN RAISE EXCEPTION 'Arma principal de duas mãos impede arma secundária.'; END IF;
  UPDATE public.srd_character_weapon_instances SET equipado=false,hand_slot=NULL WHERE character_id=btrim(p_character_id) AND equipado AND (hand_slot=p_hand_slot OR instance_id=p_instance_id);
  UPDATE public.srd_character_weapon_instances SET equipado=true,hand_slot=p_hand_slot WHERE instance_id=p_instance_id AND character_id=btrim(p_character_id);
 ELSE
  UPDATE public.srd_character_weapon_instances SET equipado=false,hand_slot=NULL WHERE instance_id=p_instance_id AND character_id=btrim(p_character_id) AND equipado AND hand_slot=p_hand_slot;
  IF NOT FOUND THEN RAISE EXCEPTION 'Esta instância não está equipada nesta mão.'; END IF;
 END IF;
 RETURN jsonb_build_object('character_id',btrim(p_character_id),'instance_id',p_instance_id,'equipment_id',v_instance.equipment_id,'hand_slot',p_hand_slot,'equipado',coalesce(p_equipado,false));
END;
$function$;
REVOKE ALL ON FUNCTION private.equipar_arma_instancia_personagem_impl(text,uuid,text,boolean) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION private.equipar_arma_instancia_personagem_impl(text,uuid,text,boolean) TO authenticated;
CREATE OR REPLACE FUNCTION public.equipar_arma_instancia_personagem(p_character_id text,p_instance_id uuid,p_hand_slot text,p_equipado boolean)
RETURNS jsonb LANGUAGE sql SECURITY INVOKER SET search_path TO 'pg_catalog','public','private'
AS $function$ SELECT private.equipar_arma_instancia_personagem_impl($1,$2,$3,$4); $function$;
REVOKE ALL ON FUNCTION public.equipar_arma_instancia_personagem(text,uuid,text,boolean) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.equipar_arma_instancia_personagem(text,uuid,text,boolean) TO authenticated;
CREATE OR REPLACE FUNCTION private.equipar_arma_instancia_token_impl(p_campaign_id bigint,p_token_id text,p_instance_id uuid,p_hand_slot text,p_equipado boolean)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'pg_catalog','public'
AS $function$
DECLARE v_role text; v_campaign public.campaigns%rowtype; v_token jsonb; v_instance public.srd_cba_token_weapon_instances%rowtype; v_item public.srd_equipment%rowtype; v_two_handed boolean;
BEGIN
 IF (SELECT auth.uid()) IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
 SELECT member.role INTO v_role FROM public.members member WHERE member.campaign_id=p_campaign_id AND member.user_id=(SELECT auth.uid()) LIMIT 1;
 IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'Somente o Mestre pode alterar equipamento de NPCs e monstros.'; END IF;
 IF p_hand_slot NOT IN ('main_hand','off_hand') THEN RAISE EXCEPTION 'Mão inválida.'; END IF;
 SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Mesa não encontrada.'; END IF;
 SELECT t.value INTO v_token FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END) t(value) WHERE t.value->>'id'=btrim(p_token_id) LIMIT 1;
 IF v_token IS NULL OR v_token->>'tipo' NOT IN ('npc','monstro') THEN RAISE EXCEPTION 'Token de NPC/monstro não encontrado.'; END IF;
 SELECT * INTO v_instance FROM public.srd_cba_token_weapon_instances WHERE campaign_id=p_campaign_id AND token_id=btrim(p_token_id) AND instance_id=p_instance_id FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Instância de arma não encontrada neste token.'; END IF;
 SELECT * INTO v_item FROM public.srd_equipment WHERE id=v_instance.equipment_id;
 v_two_handed:=coalesce(v_item.detalhes->>'weapon_two_handed','false')='true';
 IF coalesce(p_equipado,false) THEN
  IF p_hand_slot='off_hand' AND v_two_handed THEN RAISE EXCEPTION 'Arma de duas mãos não pode ocupar a mão secundária.'; END IF;
  IF p_hand_slot='main_hand' AND v_two_handed AND EXISTS (SELECT 1 FROM public.srd_cba_token_weapon_instances WHERE campaign_id=p_campaign_id AND token_id=btrim(p_token_id) AND equipado AND hand_slot='off_hand') THEN RAISE EXCEPTION 'Desequipe a arma secundária antes de usar uma arma de duas mãos.'; END IF;
  IF p_hand_slot='off_hand' AND EXISTS (SELECT 1 FROM public.srd_cba_token_weapon_instances i JOIN public.srd_equipment e ON e.id=i.equipment_id WHERE i.campaign_id=p_campaign_id AND i.token_id=btrim(p_token_id) AND i.equipado AND i.hand_slot='main_hand' AND coalesce(e.detalhes->>'weapon_two_handed','false')='true') THEN RAISE EXCEPTION 'Arma principal de duas mãos impede arma secundária.'; END IF;
  UPDATE public.srd_cba_token_weapon_instances SET equipado=false,hand_slot=NULL WHERE campaign_id=p_campaign_id AND token_id=btrim(p_token_id) AND equipado AND (hand_slot=p_hand_slot OR instance_id=p_instance_id);
  UPDATE public.srd_cba_token_weapon_instances SET equipado=true,hand_slot=p_hand_slot WHERE campaign_id=p_campaign_id AND token_id=btrim(p_token_id) AND instance_id=p_instance_id;
 ELSE
  UPDATE public.srd_cba_token_weapon_instances SET equipado=false,hand_slot=NULL WHERE campaign_id=p_campaign_id AND token_id=btrim(p_token_id) AND instance_id=p_instance_id AND equipado AND hand_slot=p_hand_slot;
  IF NOT FOUND THEN RAISE EXCEPTION 'Esta instância não está equipada nesta mão.'; END IF;
 END IF;
 RETURN jsonb_build_object('campaign_id',p_campaign_id,'token_id',btrim(p_token_id),'instance_id',p_instance_id,'equipment_id',v_instance.equipment_id,'hand_slot',p_hand_slot,'equipado',coalesce(p_equipado,false),'cba_data',v_campaign.cba_data);
END;
$function$;
REVOKE ALL ON FUNCTION private.equipar_arma_instancia_token_impl(bigint,text,uuid,text,boolean) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION private.equipar_arma_instancia_token_impl(bigint,text,uuid,text,boolean) TO authenticated;
CREATE OR REPLACE FUNCTION public.equipar_arma_instancia_token(p_campaign_id bigint,p_token_id text,p_instance_id uuid,p_hand_slot text,p_equipado boolean)
RETURNS jsonb LANGUAGE sql SECURITY INVOKER SET search_path TO 'pg_catalog','public','private'
AS $function$ SELECT private.equipar_arma_instancia_token_impl($1,$2,$3,$4,$5); $function$;
REVOKE ALL ON FUNCTION public.equipar_arma_instancia_token(bigint,text,uuid,text,boolean) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.equipar_arma_instancia_token(bigint,text,uuid,text,boolean) TO authenticated;