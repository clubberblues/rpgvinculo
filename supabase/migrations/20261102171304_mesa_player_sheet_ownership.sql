-- Only a sheet owner may adjust their own character's HP.
CREATE OR REPLACE FUNCTION public.alterar_pv_personagem(
  p_campaign_id BIGINT,
  p_character_id TEXT,
  p_variacao INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_owner UUID;
  v_campaign_id BIGINT;
  v_pv_atual INTEGER;
  v_pv_max INTEGER;
  v_pv_novo INTEGER;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  IF p_variacao IS NULL OR p_variacao = 0 THEN RAISE EXCEPTION 'A variação de PV é obrigatória.'; END IF;
  SELECT c.user_id,c.campaign_id,s.pv_atual,s.pv_max
    INTO v_owner,v_campaign_id,v_pv_atual,v_pv_max
  FROM public.characters c
  JOIN public.srd_character_sheets s ON s.character_id::TEXT=c.id::TEXT
  WHERE c.id::TEXT=BTRIM(p_character_id)
  FOR UPDATE OF s;
  IF NOT FOUND OR v_campaign_id IS DISTINCT FROM p_campaign_id THEN
    RAISE EXCEPTION 'Personagem SRD não encontrado nesta campanha.';
  END IF;
  IF v_owner IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'Somente o dono da ficha pode ajustar os próprios PV.';
  END IF;
  IF v_pv_max IS NULL OR v_pv_max<1 THEN RAISE EXCEPTION 'A ficha não possui um PV máximo válido.'; END IF;
  v_pv_novo:=GREATEST(0,LEAST(v_pv_max,COALESCE(v_pv_atual,v_pv_max)+p_variacao));
  UPDATE public.srd_character_sheets SET pv_atual=v_pv_novo
  WHERE character_id::TEXT=BTRIM(p_character_id);
  RETURN jsonb_build_object('character_id',BTRIM(p_character_id),'pv_atual',v_pv_novo,'pv_max',v_pv_max,'variacao_solicitada',p_variacao);
END;
$$;
REVOKE ALL ON FUNCTION public.alterar_pv_personagem(BIGINT,TEXT,INTEGER) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.alterar_pv_personagem(BIGINT,TEXT,INTEGER) TO authenticated;

-- Combat damage from a GM-controlled NPC/monster is a separate operation from manual HP changes.
CREATE OR REPLACE FUNCTION public.aplicar_dano_token_gm_personagem_srd(
  p_campaign_id BIGINT,
  p_token_id TEXT,
  p_character_id TEXT,
  p_dano INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_campaign public.campaigns%ROWTYPE;
  v_combat JSONB;
  v_order JSONB;
  v_current INTEGER;
  v_actor JSONB;
  v_hp INTEGER;
  v_max_hp INTEGER;
  v_new_hp INTEGER;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  IF p_dano IS NULL OR p_dano<1 OR p_dano>1000 THEN RAISE EXCEPTION 'Dano inválido.'; END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.members m
    WHERE m.campaign_id=p_campaign_id AND m.user_id=auth.uid() AND m.role='GM'
  ) THEN RAISE EXCEPTION 'Somente o Mestre da campanha pode resolver dano de criatura.'; END IF;
  SELECT c.* INTO v_campaign FROM public.campaigns c WHERE c.id=p_campaign_id FOR UPDATE;
  IF NOT FOUND OR UPPER(COALESCE(v_campaign.state,''))<>'COMBATE' THEN RAISE EXCEPTION 'A campanha não está em combate.'; END IF;
  v_combat:=COALESCE(v_campaign.combat_data,'{}'::JSONB);
  IF COALESCE(v_combat->>'active','false')<>'true' THEN RAISE EXCEPTION 'A iniciativa não está ativa.'; END IF;
  v_order:=CASE WHEN jsonb_typeof(v_combat->'turn_order')='array' THEN v_combat->'turn_order' ELSE '[]'::JSONB END;
  IF COALESCE(v_combat->>'current_turn','') !~ '^[0-9]+$' THEN RAISE EXCEPTION 'O turno atual é inválido.'; END IF;
  v_current:=(v_combat->>'current_turn')::INTEGER;
  v_actor:=v_order->v_current;
  IF COALESCE(v_actor->>'is_monster','false')<>'true' OR v_actor->>'id' IS DISTINCT FROM BTRIM(p_token_id) THEN
    RAISE EXCEPTION 'O token atacante não pertence ao turno ativo do Mestre.';
  END IF;
  SELECT s.pv_atual,s.pv_max INTO v_hp,v_max_hp
  FROM public.characters c
  JOIN public.members m ON m.campaign_id=c.campaign_id AND m.user_id=c.user_id AND m.role='PLAYER'
  JOIN public.srd_character_sheets s ON s.character_id::TEXT=c.id::TEXT
  WHERE c.id::TEXT=BTRIM(p_character_id) AND c.campaign_id=p_campaign_id
  FOR UPDATE OF s;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha de jogador não encontrada nesta campanha.'; END IF;
  IF v_max_hp IS NULL OR v_max_hp<1 THEN RAISE EXCEPTION 'A ficha não possui um PV máximo válido.'; END IF;
  v_new_hp:=GREATEST(0,LEAST(v_max_hp,COALESCE(v_hp,v_max_hp)-p_dano));
  UPDATE public.srd_character_sheets SET pv_atual=v_new_hp WHERE character_id::TEXT=BTRIM(p_character_id);
  RETURN jsonb_build_object('character_id',BTRIM(p_character_id),'pv_atual',v_new_hp,'pv_max',v_max_hp,'dano',p_dano);
END;
$$;
REVOKE ALL ON FUNCTION public.aplicar_dano_token_gm_personagem_srd(BIGINT,TEXT,TEXT,INTEGER) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.aplicar_dano_token_gm_personagem_srd(BIGINT,TEXT,TEXT,INTEGER) TO authenticated;
NOTIFY pgrst,'reload schema';
