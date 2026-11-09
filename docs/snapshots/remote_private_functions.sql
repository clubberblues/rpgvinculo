-- REMOTE FUNCTION EXPORT
-- Project: grrgwxcagvvafdmzsmro
-- Captured: 2026-11-09
-- Schema: private
-- Count: 8
-- Source: pg_get_functiondef; definitions only, not a restore script.

-- consultar_inventario_npc_vinculado_impl(p_campaign_id bigint, p_token_id text)
CREATE OR REPLACE FUNCTION private.consultar_inventario_npc_vinculado_impl(p_campaign_id bigint, p_token_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
declare
  v_campaign public.campaigns%rowtype;
  v_token jsonb;
  v_character_id text;
  v_owner uuid;
  v_items jsonb;
  v_instances jsonb;
  v_attributes jsonb;
  v_race_id text;
  v_level integer;
begin
  if auth.uid() is null then raise exception 'Autenticação obrigatória.'; end if;
  if public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode consultar o inventário de NPC vinculado.';
  end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id;
  if not found then raise exception 'Campanha não encontrada.'; end if;
  select t.value into v_token
  from jsonb_array_elements(case when jsonb_typeof(v_campaign.cba_data->'tokens')='array'
    then v_campaign.cba_data->'tokens' else '[]'::jsonb end) t(value)
  where t.value->>'id'=btrim(p_token_id) and t.value->>'tipo'='npc'
  limit 1;
  if v_token is null or nullif(v_token->>'sourceCharacterId','') is null then
    raise exception 'NPC não está vinculado a uma ficha de personagem.';
  end if;
  v_character_id:=v_token->>'sourceCharacterId';
  select ch.user_id into v_owner from public.characters ch where ch.id::text=v_character_id;
  if not found or not exists (
    select 1 from public.members gm
    where gm.campaign_id=p_campaign_id and gm.user_id=v_owner and gm.role='GM'
  ) then raise exception 'A ficha vinculada não pertence ao Mestre desta campanha.'; end if;
  select sh.atributos,sh.raca_id,sh.nivel
    into v_attributes,v_race_id,v_level
  from public.srd_character_sheets sh
  where sh.character_id::text=v_character_id;
  if not found then raise exception 'Ficha SRD vinculada não encontrada.'; end if;
  select coalesce(jsonb_agg(
    jsonb_build_object('equipment_id',ce.equipment_id,'quantidade',ce.quantidade,
      'equipado',ce.equipado,'equipment',to_jsonb(eq))
    order by eq.nome
  ),'[]'::jsonb) into v_items
  from public.srd_character_equipment ce
  join public.srd_equipment eq on eq.id=ce.equipment_id
  where ce.character_id=v_character_id;
  select coalesce(jsonb_agg(
    jsonb_build_object('instance_id',wi.instance_id,'equipment_id',wi.equipment_id,
      'equipado',wi.equipado,'hand_slot',wi.hand_slot)
    order by wi.created_at,wi.instance_id
  ),'[]'::jsonb) into v_instances
  from public.srd_character_weapon_instances wi
  where wi.character_id=v_character_id;
  return jsonb_build_object('character_id',v_character_id,'attributes',coalesce(v_attributes,'{}'::jsonb),
    'race_id',v_race_id,'level',v_level,'items',v_items,'weapon_instances',v_instances);
end;
$function$
;

-- equipar_arma_instancia_npc_vinculado_impl(p_campaign_id bigint, p_token_id text, p_instance_id uuid, p_hand_slot text, p_equipado boolean)
CREATE OR REPLACE FUNCTION private.equipar_arma_instancia_npc_vinculado_impl(p_campaign_id bigint, p_token_id text, p_instance_id uuid, p_hand_slot text, p_equipado boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
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
$function$
;

-- equipar_arma_instancia_personagem_impl(p_character_id text, p_instance_id uuid, p_hand_slot text, p_equipado boolean)
CREATE OR REPLACE FUNCTION private.equipar_arma_instancia_personagem_impl(p_character_id text, p_instance_id uuid, p_hand_slot text, p_equipado boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
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
 UPDATE public.srd_character_equipment ce SET equipado=EXISTS (SELECT 1 FROM public.srd_character_weapon_instances wi WHERE wi.character_id=ce.character_id AND wi.equipment_id=ce.equipment_id AND wi.equipado), hand_slot=(SELECT wi.hand_slot FROM public.srd_character_weapon_instances wi WHERE wi.character_id=ce.character_id AND wi.equipment_id=ce.equipment_id AND wi.equipado ORDER BY CASE wi.hand_slot WHEN 'main_hand' THEN 0 ELSE 1 END LIMIT 1) WHERE ce.character_id=btrim(p_character_id) AND ce.equipment_id=v_instance.equipment_id;
 RETURN jsonb_build_object('character_id',btrim(p_character_id),'instance_id',p_instance_id,'equipment_id',v_instance.equipment_id,'hand_slot',p_hand_slot,'equipado',coalesce(p_equipado,false));
END;
$function$
;

-- equipar_arma_instancia_token_impl(p_campaign_id bigint, p_token_id text, p_instance_id uuid, p_hand_slot text, p_equipado boolean)
CREATE OR REPLACE FUNCTION private.equipar_arma_instancia_token_impl(p_campaign_id bigint, p_token_id text, p_instance_id uuid, p_hand_slot text, p_equipado boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
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
 UPDATE public.srd_cba_token_equipment ce SET equipado=EXISTS (SELECT 1 FROM public.srd_cba_token_weapon_instances wi WHERE wi.campaign_id=ce.campaign_id AND wi.token_id=ce.token_id AND wi.equipment_id=ce.equipment_id AND wi.equipado), hand_slot=(SELECT wi.hand_slot FROM public.srd_cba_token_weapon_instances wi WHERE wi.campaign_id=ce.campaign_id AND wi.token_id=ce.token_id AND wi.equipment_id=ce.equipment_id AND wi.equipado ORDER BY CASE wi.hand_slot WHEN 'main_hand' THEN 0 ELSE 1 END LIMIT 1) WHERE ce.campaign_id=p_campaign_id AND ce.token_id=btrim(p_token_id) AND ce.equipment_id=v_instance.equipment_id;
 RETURN jsonb_build_object('campaign_id',p_campaign_id,'token_id',btrim(p_token_id),'instance_id',p_instance_id,'equipment_id',v_instance.equipment_id,'hand_slot',p_hand_slot,'equipado',coalesce(p_equipado,false),'cba_data',v_campaign.cba_data);
END;
$function$
;

-- equipar_item_npc_vinculado_impl(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_equipado boolean)
CREATE OR REPLACE FUNCTION private.equipar_item_npc_vinculado_impl(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_equipado boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
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
$function$
;

-- equipar_item_token_srd_maos_impl(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_hand_slot text, p_equipado boolean)
CREATE OR REPLACE FUNCTION private.equipar_item_token_srd_maos_impl(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_hand_slot text, p_equipado boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
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
$function$
;

-- sync_character_weapon_instances_from_inventory()
CREATE OR REPLACE FUNCTION private.sync_character_weapon_instances_from_inventory()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
DECLARE v_slot text; v_delta integer; v_removed integer;
BEGIN
 IF TG_OP='DELETE' THEN
  DELETE FROM public.srd_character_weapon_instances WHERE character_id=OLD.character_id AND equipment_id=OLD.equipment_id;
  RETURN OLD;
 END IF;
 SELECT public.srd35_equipment_slot(e.categoria,e.nome) INTO v_slot FROM public.srd_equipment e WHERE e.id=NEW.equipment_id;
 IF v_slot IS DISTINCT FROM 'arma' THEN RETURN NEW; END IF;
 IF TG_OP='INSERT' THEN v_delta:=NEW.quantidade;
 ELSE v_delta:=NEW.quantidade-OLD.quantidade; END IF;
 IF v_delta>0 THEN
  INSERT INTO public.srd_character_weapon_instances(character_id,equipment_id)
  SELECT NEW.character_id,NEW.equipment_id FROM generate_series(1,v_delta);
 ELSIF v_delta<0 THEN
  DELETE FROM public.srd_character_weapon_instances
   WHERE instance_id IN (
    SELECT instance_id FROM public.srd_character_weapon_instances
    WHERE character_id=NEW.character_id AND equipment_id=NEW.equipment_id AND NOT equipado
    ORDER BY created_at DESC LIMIT abs(v_delta)
   );
  GET DIAGNOSTICS v_removed=ROW_COUNT;
  IF v_removed<abs(v_delta) THEN RAISE EXCEPTION 'Não é possível reduzir a quantidade: há armas equipadas ou instâncias em uso.'; END IF;
 END IF;
 UPDATE public.srd_character_equipment ce SET equipado=EXISTS (SELECT 1 FROM public.srd_character_weapon_instances wi WHERE wi.character_id=ce.character_id AND wi.equipment_id=ce.equipment_id AND wi.equipado), hand_slot=(SELECT wi.hand_slot FROM public.srd_character_weapon_instances wi WHERE wi.character_id=ce.character_id AND wi.equipment_id=ce.equipment_id AND wi.equipado ORDER BY CASE wi.hand_slot WHEN 'main_hand' THEN 0 ELSE 1 END LIMIT 1) WHERE ce.character_id=NEW.character_id AND ce.equipment_id=NEW.equipment_id;
 RETURN NEW;
END;
$function$
;

-- sync_token_weapon_instances_from_inventory()
CREATE OR REPLACE FUNCTION private.sync_token_weapon_instances_from_inventory()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
DECLARE v_slot text; v_delta integer; v_removed integer;
BEGIN
 IF TG_OP='DELETE' THEN
  DELETE FROM public.srd_cba_token_weapon_instances WHERE campaign_id=OLD.campaign_id AND token_id=OLD.token_id AND equipment_id=OLD.equipment_id;
  RETURN OLD;
 END IF;
 SELECT public.srd35_equipment_slot(e.categoria,e.nome) INTO v_slot FROM public.srd_equipment e WHERE e.id=NEW.equipment_id;
 IF v_slot IS DISTINCT FROM 'arma' THEN RETURN NEW; END IF;
 IF TG_OP='INSERT' THEN v_delta:=NEW.quantidade;
 ELSE v_delta:=NEW.quantidade-OLD.quantidade; END IF;
 IF v_delta>0 THEN
  INSERT INTO public.srd_cba_token_weapon_instances(campaign_id,token_id,equipment_id)
  SELECT NEW.campaign_id,NEW.token_id,NEW.equipment_id FROM generate_series(1,v_delta);
 ELSIF v_delta<0 THEN
  DELETE FROM public.srd_cba_token_weapon_instances
   WHERE instance_id IN (
    SELECT instance_id FROM public.srd_cba_token_weapon_instances
    WHERE campaign_id=NEW.campaign_id AND token_id=NEW.token_id AND equipment_id=NEW.equipment_id AND NOT equipado
    ORDER BY created_at DESC LIMIT abs(v_delta)
   );
  GET DIAGNOSTICS v_removed=ROW_COUNT;
  IF v_removed<abs(v_delta) THEN RAISE EXCEPTION 'Não é possível reduzir a quantidade: há armas equipadas ou instâncias em uso.'; END IF;
 END IF;
 UPDATE public.srd_cba_token_equipment ce SET equipado=EXISTS (SELECT 1 FROM public.srd_cba_token_weapon_instances wi WHERE wi.campaign_id=ce.campaign_id AND wi.token_id=ce.token_id AND wi.equipment_id=ce.equipment_id AND wi.equipado), hand_slot=(SELECT wi.hand_slot FROM public.srd_cba_token_weapon_instances wi WHERE wi.campaign_id=ce.campaign_id AND wi.token_id=ce.token_id AND wi.equipment_id=ce.equipment_id AND wi.equipado ORDER BY CASE wi.hand_slot WHEN 'main_hand' THEN 0 ELSE 1 END LIMIT 1) WHERE ce.campaign_id=NEW.campaign_id AND ce.token_id=NEW.token_id AND ce.equipment_id=NEW.equipment_id;
 RETURN NEW;
END;
$function$
;

