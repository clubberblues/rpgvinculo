-- Normaliza categorias importadas do SRD para permitir equipar armas, armaduras,
-- escudos e itens vestíveis sem reescrever as categorias de origem do catálogo.
BEGIN;

CREATE OR REPLACE FUNCTION public.srd35_equipment_slot(p_categoria TEXT,p_nome TEXT)
RETURNS TEXT
LANGUAGE SQL IMMUTABLE
SET search_path = ''
AS $$
  SELECT CASE
    WHEN lower(btrim(COALESCE(p_categoria,''))) IN ('arma','weapon','specific_weapons')
      OR lower(COALESCE(p_categoria,'')) LIKE '%weapon%'
      THEN 'arma'
    WHEN lower(btrim(COALESCE(p_categoria,''))) IN ('armadura','light armor','medium armor','heavy armor','specific_armors')
      THEN 'armadura'
    WHEN lower(btrim(COALESCE(p_categoria,''))) IN ('escudo','shields','specific_shields')
      THEN 'escudo'
    WHEN lower(btrim(COALESCE(p_categoria,'')))='armor_and_shields'
      THEN CASE WHEN lower(COALESCE(p_nome,'')) LIKE '%shield%' THEN 'escudo' ELSE 'armadura' END
    WHEN lower(btrim(COALESCE(p_categoria,''))) IN ('acessorio','rings','rods','staffs','wands','wondrous_items')
      THEN 'acessorio'
    ELSE ''
  END;
$$;

CREATE OR REPLACE FUNCTION public.srd35_equipment_ca_bonus(p_equipment_id TEXT)
RETURNS INTEGER
LANGUAGE SQL STABLE
SET search_path = ''
AS $$
  SELECT COALESCE(
    NULLIF(gear.bonus_ca,0),
    NULLIF(gear.ca_bonus,0),
    CASE WHEN lower(COALESCE(gear.categoria,''))='armor_and_shields'
               AND gear.nome ~ '\+[0-9]+'
         THEN substring(gear.nome FROM '\+([0-9]+)')::INTEGER END,
    0
  )::INTEGER
  FROM public.srd_equipment AS gear WHERE gear.id=p_equipment_id;
$$;

CREATE OR REPLACE FUNCTION public.entregar_item_token_srd(
  p_campaign_id BIGINT,p_token_id TEXT,p_equipment_id TEXT,p_quantidade INTEGER DEFAULT 1
)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  v_role TEXT; v_item public.srd_equipment%ROWTYPE; v_campaign public.campaigns%ROWTYPE;
  v_tokens JSONB; v_token JSONB; v_type TEXT; v_has_bag BOOLEAN; v_equipped BOOLEAN;
  v_slot TEXT; v_index BIGINT; v_base_ac NUMERIC; v_bonus INTEGER;
BEGIN
  IF (SELECT auth.uid()) IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT member.role INTO v_role FROM public.members AS member
  WHERE member.campaign_id=p_campaign_id AND member.user_id=(SELECT auth.uid()) LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'Somente o Mestre pode entregar equipamento.'; END IF;
  IF p_quantidade IS NULL OR p_quantidade<1 OR p_quantidade>99 THEN RAISE EXCEPTION 'Quantidade inválida.'; END IF;
  SELECT * INTO v_item FROM public.srd_equipment WHERE id=p_equipment_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Equipamento não encontrado.'; END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Mesa não encontrada.'; END IF;
  v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::JSONB END;
  SELECT t.value,t.ordinality INTO v_token,v_index FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(value,ordinality)
  WHERE t.value->>'id'=BTRIM(p_token_id) LIMIT 1;
  IF v_token IS NULL THEN RAISE EXCEPTION 'Token não encontrado nesta mesa.'; END IF;
  v_type:=v_token->>'tipo';
  IF v_type='player' THEN RAISE EXCEPTION 'Use a entrega de ficha para um token de jogador.'; END IF;
  IF v_type NOT IN ('npc','monstro') THEN RAISE EXCEPTION 'Tipo de token inválido.'; END IF;
  SELECT EXISTS(SELECT 1 FROM public.srd_cba_token_equipment AS bag JOIN public.srd_equipment AS gear ON gear.id=bag.equipment_id
    WHERE bag.campaign_id=p_campaign_id AND bag.token_id=BTRIM(p_token_id) AND bag.quantidade>0
      AND (gear.categoria='mochila' OR gear.id='srd35_equipment_gear_backpack_empty')) INTO v_has_bag;
  v_slot:=public.srd35_equipment_slot(v_item.categoria,v_item.nome);
  v_equipped:=NOT v_has_bag AND v_slot<>'';
  IF v_equipped AND v_slot<>'acessorio' THEN
    UPDATE public.srd_cba_token_equipment AS held SET equipado=FALSE FROM public.srd_equipment AS old
    WHERE held.campaign_id=p_campaign_id AND held.token_id=BTRIM(p_token_id) AND held.equipment_id=old.id
      AND public.srd35_equipment_slot(old.categoria,old.nome)=v_slot;
  END IF;
  INSERT INTO public.srd_cba_token_equipment(campaign_id,token_id,equipment_id,quantidade,equipado)
  VALUES(p_campaign_id,BTRIM(p_token_id),p_equipment_id,p_quantidade,v_equipped)
  ON CONFLICT(campaign_id,token_id,equipment_id) DO UPDATE SET quantidade=srd_cba_token_equipment.quantidade+EXCLUDED.quantidade,
    equipado=srd_cba_token_equipment.equipado OR EXCLUDED.equipado;
  IF v_equipped THEN
    SELECT COALESCE(SUM(public.srd35_equipment_ca_bonus(held.equipment_id)),0)::INTEGER INTO v_bonus
    FROM public.srd_cba_token_equipment AS held
    WHERE held.campaign_id=p_campaign_id AND held.token_id=BTRIM(p_token_id) AND held.equipado;
    v_base_ac:=COALESCE(NULLIF(v_token->>'baseAc','')::NUMERIC,NULLIF(v_token->>'ac','')::NUMERIC,
      NULLIF(v_token->'monsterStats'->>'ca','')::NUMERIC,10);
    v_token:=v_token||jsonb_build_object('baseAc',v_base_ac,'ac',v_base_ac+v_bonus);
    v_tokens:=jsonb_set(v_tokens,ARRAY[(v_index-1)::TEXT],v_token,FALSE);
    UPDATE public.campaigns SET cba_data=v_campaign.cba_data||jsonb_build_object('tokens',v_tokens) WHERE id=p_campaign_id;
  END IF;
  RETURN jsonb_build_object('campaign_id',p_campaign_id,'token_id',BTRIM(p_token_id),'equipment_id',p_equipment_id,
    'quantidade',p_quantidade,'equipado',v_equipped,'guardado_na_mochila',v_has_bag,
    'ac',CASE WHEN v_equipped THEN v_base_ac+v_bonus ELSE NULL END,
    'cba_data',CASE WHEN v_equipped THEN v_campaign.cba_data||jsonb_build_object('tokens',v_tokens) ELSE NULL END);
END; $$;

CREATE OR REPLACE FUNCTION public.equipar_item_token_srd(
  p_campaign_id BIGINT,p_token_id TEXT,p_equipment_id TEXT,p_equipado BOOLEAN
)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  v_role TEXT; v_item public.srd_equipment%ROWTYPE; v_campaign public.campaigns%ROWTYPE;
  v_tokens JSONB; v_token JSONB; v_index BIGINT; v_count INTEGER; v_slot TEXT; v_base_ac NUMERIC; v_bonus INTEGER;
BEGIN
  IF (SELECT auth.uid()) IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT member.role INTO v_role FROM public.members AS member
  WHERE member.campaign_id=p_campaign_id AND member.user_id=(SELECT auth.uid()) LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'Somente o Mestre pode alterar equipamento de NPCs e monstros.'; END IF;
  SELECT * INTO v_item FROM public.srd_equipment WHERE id=p_equipment_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Equipamento não encontrado.'; END IF;
  v_slot:=public.srd35_equipment_slot(v_item.categoria,v_item.nome);
  IF v_slot='' THEN RAISE EXCEPTION 'Este item não pode ser equipado.'; END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Mesa não encontrada.'; END IF;
  v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::JSONB END;
  SELECT t.value,t.ordinality INTO v_token,v_index FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(value,ordinality)
  WHERE t.value->>'id'=BTRIM(p_token_id) LIMIT 1;
  IF v_token IS NULL OR v_token->>'tipo' NOT IN ('npc','monstro') THEN RAISE EXCEPTION 'Token de NPC/monstro não encontrado.'; END IF;
  SELECT COUNT(*)::INTEGER INTO v_count FROM public.srd_cba_token_equipment
  WHERE campaign_id=p_campaign_id AND token_id=BTRIM(p_token_id) AND equipment_id=p_equipment_id;
  IF v_count=0 THEN RAISE EXCEPTION 'O item não está no inventário deste token.'; END IF;
  IF COALESCE(p_equipado,FALSE) AND v_slot<>'acessorio' THEN
    UPDATE public.srd_cba_token_equipment AS held SET equipado=FALSE FROM public.srd_equipment AS old
    WHERE held.campaign_id=p_campaign_id AND held.token_id=BTRIM(p_token_id) AND held.equipment_id=old.id
      AND public.srd35_equipment_slot(old.categoria,old.nome)=v_slot;
  END IF;
  UPDATE public.srd_cba_token_equipment SET equipado=COALESCE(p_equipado,FALSE)
  WHERE campaign_id=p_campaign_id AND token_id=BTRIM(p_token_id) AND equipment_id=p_equipment_id;
  SELECT COALESCE(SUM(public.srd35_equipment_ca_bonus(held.equipment_id)),0)::INTEGER INTO v_bonus
  FROM public.srd_cba_token_equipment AS held
  WHERE held.campaign_id=p_campaign_id AND held.token_id=BTRIM(p_token_id) AND held.equipado;
  v_base_ac:=COALESCE(NULLIF(v_token->>'baseAc','')::NUMERIC,NULLIF(v_token->>'ac','')::NUMERIC,
    NULLIF(v_token->'monsterStats'->>'ca','')::NUMERIC,10);
  v_token:=v_token||jsonb_build_object('baseAc',v_base_ac,'ac',v_base_ac+v_bonus);
  v_tokens:=jsonb_set(v_tokens,ARRAY[(v_index-1)::TEXT],v_token,FALSE);
  UPDATE public.campaigns SET cba_data=v_campaign.cba_data||jsonb_build_object('tokens',v_tokens) WHERE id=p_campaign_id;
  RETURN jsonb_build_object('campaign_id',p_campaign_id,'token_id',BTRIM(p_token_id),'equipment_id',p_equipment_id,
    'equipado',COALESCE(p_equipado,FALSE),'ac',v_base_ac+v_bonus,
    'cba_data',v_campaign.cba_data||jsonb_build_object('tokens',v_tokens));
END; $$;

CREATE OR REPLACE FUNCTION public.equipar_item_srd(
  p_character_id TEXT,p_equipment_id TEXT,p_equipado BOOLEAN
)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE v_item public.srd_equipment%ROWTYPE; v_slot TEXT;
BEGIN
  IF (SELECT auth.uid()) IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.characters AS ch WHERE ch.id::TEXT=BTRIM(p_character_id) AND ch.user_id=(SELECT auth.uid()))
    THEN RAISE EXCEPTION 'A ficha não pertence à sua conta.'; END IF;
  SELECT * INTO v_item FROM public.srd_equipment WHERE id=p_equipment_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Equipamento não encontrado.'; END IF;
  v_slot:=public.srd35_equipment_slot(v_item.categoria,v_item.nome);
  IF v_slot='' THEN RAISE EXCEPTION 'Este item não pode ser equipado.'; END IF;
  IF COALESCE(p_equipado,FALSE) AND v_slot<>'acessorio' THEN
    UPDATE public.srd_character_equipment AS held SET equipado=FALSE FROM public.srd_equipment AS old
    WHERE held.character_id=BTRIM(p_character_id) AND held.equipment_id=old.id
      AND public.srd35_equipment_slot(old.categoria,old.nome)=v_slot;
  END IF;
  UPDATE public.srd_character_equipment SET equipado=COALESCE(p_equipado,FALSE)
  WHERE character_id=BTRIM(p_character_id) AND equipment_id=p_equipment_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'O item não está no inventário desta ficha.'; END IF;
  RETURN jsonb_build_object('character_id',BTRIM(p_character_id),'equipment_id',p_equipment_id,'equipado',COALESCE(p_equipado,FALSE));
END; $$;

CREATE OR REPLACE FUNCTION public.entregar_item_srd(
  p_campaign_id BIGINT,p_character_id TEXT,p_equipment_id TEXT,p_quantidade INTEGER DEFAULT 1
)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  v_role TEXT; v_item public.srd_equipment%ROWTYPE; v_has_bag BOOLEAN; v_equipped BOOLEAN; v_slot TEXT;
BEGIN
  IF (SELECT auth.uid()) IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT member.role INTO v_role FROM public.members AS member
  WHERE member.campaign_id=p_campaign_id AND member.user_id=(SELECT auth.uid()) LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'Somente o Mestre pode entregar equipamento.'; END IF;
  IF p_quantidade IS NULL OR p_quantidade<1 OR p_quantidade>99 THEN RAISE EXCEPTION 'Quantidade inválida.'; END IF;
  SELECT * INTO v_item FROM public.srd_equipment WHERE id=p_equipment_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Equipamento não encontrado.'; END IF;
  IF NOT EXISTS(SELECT 1 FROM public.characters AS character JOIN public.members AS player
    ON player.campaign_id=character.campaign_id AND player.user_id=character.user_id AND player.role='PLAYER'
    WHERE character.id::TEXT=BTRIM(p_character_id) AND character.campaign_id=p_campaign_id) THEN
    RAISE EXCEPTION 'A ficha não pertence a um jogador desta campanha.';
  END IF;
  SELECT EXISTS(SELECT 1 FROM public.srd_character_equipment AS held JOIN public.srd_equipment AS gear ON gear.id=held.equipment_id
    WHERE held.character_id=BTRIM(p_character_id) AND held.quantidade>0
      AND (gear.categoria='mochila' OR gear.id='srd35_equipment_gear_backpack_empty')) INTO v_has_bag;
  v_slot:=public.srd35_equipment_slot(v_item.categoria,v_item.nome);
  v_equipped:=NOT v_has_bag AND v_slot<>'';
  IF v_equipped AND v_slot<>'acessorio' THEN
    UPDATE public.srd_character_equipment AS held SET equipado=FALSE FROM public.srd_equipment AS old
    WHERE held.character_id=BTRIM(p_character_id) AND held.equipment_id=old.id
      AND public.srd35_equipment_slot(old.categoria,old.nome)=v_slot;
  END IF;
  INSERT INTO public.srd_character_equipment(character_id,equipment_id,quantidade,equipado)
  VALUES(BTRIM(p_character_id),p_equipment_id,p_quantidade,v_equipped)
  ON CONFLICT(character_id,equipment_id) DO UPDATE SET quantidade=srd_character_equipment.quantidade+EXCLUDED.quantidade,
    equipado=srd_character_equipment.equipado OR EXCLUDED.equipado;
  RETURN jsonb_build_object('character_id',BTRIM(p_character_id),'equipment_id',p_equipment_id,'quantidade',p_quantidade,
    'equipado',v_equipped,'guardado_na_mochila',v_has_bag);
END; $$;

REVOKE ALL ON FUNCTION public.entregar_item_token_srd(BIGINT,TEXT,TEXT,INTEGER) FROM PUBLIC,anon;
REVOKE ALL ON FUNCTION public.equipar_item_token_srd(BIGINT,TEXT,TEXT,BOOLEAN) FROM PUBLIC,anon;
REVOKE ALL ON FUNCTION public.entregar_item_srd(BIGINT,TEXT,TEXT,INTEGER) FROM PUBLIC,anon;
REVOKE ALL ON FUNCTION public.equipar_item_srd(TEXT,TEXT,BOOLEAN) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.entregar_item_token_srd(BIGINT,TEXT,TEXT,INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION public.equipar_item_token_srd(BIGINT,TEXT,TEXT,BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION public.entregar_item_srd(BIGINT,TEXT,TEXT,INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION public.equipar_item_srd(TEXT,TEXT,BOOLEAN) TO authenticated;
COMMIT;

