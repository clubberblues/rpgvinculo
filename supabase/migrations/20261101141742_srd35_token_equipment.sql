-- Inventário de combatentes do CBA e entrega automática conforme presença de mochila.
-- Execute depois de vtt_dnd35_final_migration.sql e srd35_compendium_migration.sql.
BEGIN;

UPDATE public.srd_equipment SET categoria='mochila'
WHERE id='srd35_equipment_gear_backpack_empty';

CREATE TABLE IF NOT EXISTS public.srd_cba_token_equipment (
  campaign_id BIGINT NOT NULL REFERENCES public.campaigns(id) ON DELETE CASCADE,
  token_id TEXT NOT NULL,
  equipment_id TEXT NOT NULL REFERENCES public.srd_equipment(id) ON DELETE RESTRICT,
  quantidade INTEGER NOT NULL DEFAULT 1 CHECK (quantidade > 0),
  equipado BOOLEAN NOT NULL DEFAULT FALSE,
  criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (campaign_id,token_id,equipment_id)
);
ALTER TABLE public.srd_cba_token_equipment ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON public.srd_cba_token_equipment TO authenticated;
DROP POLICY IF EXISTS srd_cba_token_equipment_member_read ON public.srd_cba_token_equipment;
CREATE POLICY srd_cba_token_equipment_member_read ON public.srd_cba_token_equipment
  FOR SELECT TO authenticated USING (EXISTS (
    SELECT 1 FROM public.members AS member
    WHERE member.campaign_id=srd_cba_token_equipment.campaign_id AND member.user_id=(SELECT auth.uid())
  ));

CREATE OR REPLACE FUNCTION public.entregar_item_token_srd(
  p_campaign_id BIGINT,p_token_id TEXT,p_equipment_id TEXT,p_quantidade INTEGER DEFAULT 1
)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  v_role TEXT; v_item public.srd_equipment%ROWTYPE; v_campaign public.campaigns%ROWTYPE;
  v_tokens JSONB; v_token JSONB; v_type TEXT; v_has_bag BOOLEAN; v_equipped BOOLEAN;
  v_index BIGINT; v_base_ac NUMERIC; v_bonus INTEGER;
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
      AND (gear.categoria='mochila' OR gear.id='srd35_equipment_gear_backpack_empty' OR gear.id='backpack')) INTO v_has_bag;
  v_equipped:=NOT v_has_bag AND v_item.categoria IN ('arma','armadura','escudo','acessorio');
  IF v_equipped THEN
    UPDATE public.srd_cba_token_equipment AS held SET equipado=FALSE FROM public.srd_equipment AS old
    WHERE held.campaign_id=p_campaign_id AND held.token_id=BTRIM(p_token_id) AND held.equipment_id=old.id AND old.categoria=v_item.categoria;
  END IF;
  INSERT INTO public.srd_cba_token_equipment(campaign_id,token_id,equipment_id,quantidade,equipado)
  VALUES(p_campaign_id,BTRIM(p_token_id),p_equipment_id,p_quantidade,v_equipped)
  ON CONFLICT(campaign_id,token_id,equipment_id) DO UPDATE SET quantidade=srd_cba_token_equipment.quantidade+EXCLUDED.quantidade,
    equipado=srd_cba_token_equipment.equipado OR EXCLUDED.equipado;
  IF v_equipped THEN
    SELECT COALESCE(SUM(gear.bonus_ca),0)::INTEGER INTO v_bonus
    FROM public.srd_cba_token_equipment AS held JOIN public.srd_equipment AS gear ON gear.id=held.equipment_id
    WHERE held.campaign_id=p_campaign_id AND held.token_id=BTRIM(p_token_id) AND held.equipado
      AND gear.categoria IN ('armadura','escudo','acessorio');
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
  v_tokens JSONB; v_token JSONB; v_type TEXT; v_index BIGINT; v_count INTEGER; v_base_ac NUMERIC; v_bonus INTEGER;
BEGIN
  IF (SELECT auth.uid()) IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT member.role INTO v_role FROM public.members AS member
  WHERE member.campaign_id=p_campaign_id AND member.user_id=(SELECT auth.uid()) LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'Somente o Mestre pode alterar equipamento de NPCs e monstros.'; END IF;
  SELECT * INTO v_item FROM public.srd_equipment WHERE id=p_equipment_id;
  IF NOT FOUND OR v_item.categoria NOT IN ('arma','armadura','escudo','acessorio') THEN RAISE EXCEPTION 'Este item não pode ser equipado.'; END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Mesa não encontrada.'; END IF;
  v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::JSONB END;
  SELECT t.value,t.ordinality INTO v_token,v_index FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(value,ordinality)
  WHERE t.value->>'id'=BTRIM(p_token_id) LIMIT 1;
  IF v_token IS NULL OR v_token->>'tipo' NOT IN ('npc','monstro') THEN RAISE EXCEPTION 'Token de NPC/monstro não encontrado.'; END IF;
  SELECT COUNT(*)::INTEGER INTO v_count FROM public.srd_cba_token_equipment
  WHERE campaign_id=p_campaign_id AND token_id=BTRIM(p_token_id) AND equipment_id=p_equipment_id;
  IF v_count=0 THEN RAISE EXCEPTION 'O item não está no inventário deste token.'; END IF;
  IF COALESCE(p_equipado,FALSE) THEN
    UPDATE public.srd_cba_token_equipment AS held SET equipado=FALSE FROM public.srd_equipment AS old
    WHERE held.campaign_id=p_campaign_id AND held.token_id=BTRIM(p_token_id) AND held.equipment_id=old.id AND old.categoria=v_item.categoria;
  END IF;
  UPDATE public.srd_cba_token_equipment SET equipado=COALESCE(p_equipado,FALSE)
  WHERE campaign_id=p_campaign_id AND token_id=BTRIM(p_token_id) AND equipment_id=p_equipment_id;
  SELECT COALESCE(SUM(gear.bonus_ca),0)::INTEGER INTO v_bonus
  FROM public.srd_cba_token_equipment AS held JOIN public.srd_equipment AS gear ON gear.id=held.equipment_id
  WHERE held.campaign_id=p_campaign_id AND held.token_id=BTRIM(p_token_id) AND held.equipado AND gear.categoria IN ('armadura','escudo','acessorio');
  v_base_ac:=COALESCE(NULLIF(v_token->>'baseAc','')::NUMERIC,NULLIF(v_token->>'ac','')::NUMERIC,
    NULLIF(v_token->'monsterStats'->>'ca','')::NUMERIC,10);
  v_token:=v_token||jsonb_build_object('baseAc',v_base_ac,'ac',v_base_ac+v_bonus);
  v_tokens:=jsonb_set(v_tokens,ARRAY[(v_index-1)::TEXT],v_token,FALSE);
  UPDATE public.campaigns SET cba_data=v_campaign.cba_data||jsonb_build_object('tokens',v_tokens) WHERE id=p_campaign_id;
  RETURN jsonb_build_object('campaign_id',p_campaign_id,'token_id',BTRIM(p_token_id),'equipment_id',p_equipment_id,
    'equipado',COALESCE(p_equipado,FALSE),'ac',v_base_ac+v_bonus,'cba_data',v_campaign.cba_data||jsonb_build_object('tokens',v_tokens));
END; $$;

CREATE OR REPLACE FUNCTION public.entregar_item_srd(
  p_campaign_id BIGINT,p_character_id TEXT,p_equipment_id TEXT,p_quantidade INTEGER DEFAULT 1
)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  v_role TEXT; v_item public.srd_equipment%ROWTYPE; v_has_bag BOOLEAN; v_equipped BOOLEAN;
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
      AND (gear.categoria='mochila' OR gear.id='srd35_equipment_gear_backpack_empty' OR gear.id='backpack')) INTO v_has_bag;
  v_equipped:=NOT v_has_bag AND v_item.categoria IN ('arma','armadura','escudo','acessorio');
  IF v_equipped THEN
    UPDATE public.srd_character_equipment AS held SET equipado=FALSE FROM public.srd_equipment AS old
    WHERE held.character_id=BTRIM(p_character_id) AND held.equipment_id=old.id AND old.categoria=v_item.categoria;
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
GRANT EXECUTE ON FUNCTION public.entregar_item_token_srd(BIGINT,TEXT,TEXT,INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION public.equipar_item_token_srd(BIGINT,TEXT,TEXT,BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION public.entregar_item_srd(BIGINT,TEXT,TEXT,INTEGER) TO authenticated;

DO $$
DECLARE v_table TEXT;
BEGIN
  IF EXISTS(SELECT 1 FROM pg_publication WHERE pubname='supabase_realtime') THEN
    FOREACH v_table IN ARRAY ARRAY['campaigns','members','characters','srd_character_sheets','srd_character_equipment','srd_cba_token_equipment','campaign_log'] LOOP
      IF to_regclass('public.'||v_table) IS NOT NULL AND NOT EXISTS(
        SELECT 1 FROM pg_publication_tables WHERE pubname='supabase_realtime' AND schemaname='public' AND tablename=v_table
      ) THEN EXECUTE format('ALTER PUBLICATION supabase_realtime ADD TABLE public.%I',v_table); END IF;
    END LOOP;
  END IF;
END $$;
COMMIT;

