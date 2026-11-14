-- Resolve SRD Magic Missile as an automatic-hit spell with 1d4+1 per missile.
CREATE OR REPLACE FUNCTION public.conjurar_missil_magico_srd(
  p_character_id TEXT,
  p_spell_id TEXT,
  p_slot_level SMALLINT,
  p_target_token_key TEXT,
  p_damage INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_character public.characters%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_cast JSONB;
  v_campaign public.campaigns%ROWTYPE;
  v_scene JSONB;
  v_tokens JSONB;
  v_token JSONB;
  v_index BIGINT;
  v_count INTEGER;
  v_type TEXT;
  v_missiles INTEGER;
  v_min INTEGER;
  v_max INTEGER;
  v_hp INTEGER;
  v_max_hp INTEGER;
  v_new_hp INTEGER;
  v_name TEXT;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_spell_id IS DISTINCT FROM 'srd35_magic_missile' THEN RAISE EXCEPTION 'Esta resolução aceita somente Míssil Mágico.'; END IF;
  IF NULLIF(BTRIM(p_target_token_key),'') IS NULL THEN RAISE EXCEPTION 'Selecione um alvo.'; END IF;
  SELECT ch.* INTO v_character FROM public.characters ch
   WHERE ch.id::TEXT=BTRIM(p_character_id) AND ch.user_id=auth.uid() FOR UPDATE;
  IF NOT FOUND OR v_character.campaign_id IS NULL THEN RAISE EXCEPTION 'Ficha própria em campanha não encontrada.'; END IF;
  SELECT sh.* INTO v_sheet FROM public.srd_character_sheets sh
   WHERE sh.character_id::TEXT=BTRIM(p_character_id) FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada.'; END IF;
  IF v_sheet.nivel IS NULL OR v_sheet.nivel<1 OR v_sheet.nivel>20 THEN RAISE EXCEPTION 'Nível de conjurador inválido.'; END IF;
  v_missiles:=LEAST(5,CEIL(v_sheet.nivel/2.0)::INTEGER);
  v_min:=2*v_missiles; v_max:=5*v_missiles;
  IF p_damage IS NULL OR p_damage<v_min OR p_damage>v_max THEN
    RAISE EXCEPTION 'Dano inválido para % míssil(is): esperado de % a %.',v_missiles,v_min,v_max;
  END IF;
  v_cast:=public.conjurar_magia_com_acao_srd(p_character_id,p_spell_id,p_slot_level,p_target_token_key);
  SELECT c.* INTO v_campaign FROM public.campaigns c
   WHERE c.id=v_character.campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  v_scene:=COALESCE(v_campaign.cba_data,'{}'::JSONB);
  v_tokens:=CASE WHEN jsonb_typeof(v_scene->'tokens')='array' THEN v_scene->'tokens' ELSE '[]'::JSONB END;
  SELECT count(*)::INTEGER,min(e.ordinality),min(e.token->>'tipo'),min(e.token->>'nome')
    INTO v_count,v_index,v_type,v_name
    FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
   WHERE e.token->>'key'=BTRIM(p_target_token_key);
  IF v_count<>1 THEN RAISE EXCEPTION 'Token-alvo ausente ou duplicado nesta campanha.'; END IF;
  v_token:=v_tokens->(v_index::INTEGER-1);
  IF v_type='player' THEN
    SELECT sh.pv_atual,sh.pv_max INTO v_hp,v_max_hp
      FROM public.characters ch
      JOIN public.members m ON m.campaign_id=ch.campaign_id AND m.user_id=ch.user_id AND m.role='PLAYER'
      JOIN public.srd_character_sheets sh ON sh.character_id::TEXT=ch.id::TEXT
     WHERE ch.id::TEXT=v_token->>'id' AND ch.campaign_id=v_character.campaign_id
     FOR UPDATE OF sh;
    IF NOT FOUND OR v_max_hp IS NULL OR v_max_hp<1 THEN RAISE EXCEPTION 'Ficha do alvo jogador inválida.'; END IF;
    v_new_hp:=GREATEST(0,COALESCE(v_hp,v_max_hp)-p_damage);
    UPDATE public.srd_character_sheets SET pv_atual=v_new_hp WHERE character_id::TEXT=v_token->>'id';
    v_tokens:=jsonb_set(v_tokens,ARRAY[(v_index-1)::TEXT],v_token||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp),FALSE);
  ELSIF v_type IN ('npc','monstro') THEN
    IF COALESCE(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN RAISE EXCEPTION 'O token precisa ter PV máximo cadastrado.'; END IF;
    v_max_hp:=(v_token->>'maxHp')::INTEGER;
    IF v_max_hp>100000 THEN RAISE EXCEPTION 'PV máximo do token excede o limite.'; END IF;
    v_hp:=CASE WHEN COALESCE(v_token->>'hp','') ~ '^[0-9]{1,6}$' THEN (v_token->>'hp')::INTEGER ELSE v_max_hp END;
    v_new_hp:=GREATEST(0,v_hp-p_damage);
    v_tokens:=jsonb_set(v_tokens,ARRAY[(v_index-1)::TEXT],v_token||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp),FALSE);
  ELSE
    RAISE EXCEPTION 'Tipo de token incompatível com Míssil Mágico.';
  END IF;
  v_scene:=v_scene||jsonb_build_object('tokens',v_tokens);
  UPDATE public.campaigns SET cba_data=v_scene WHERE id=v_character.campaign_id;
  RETURN COALESCE(v_cast,'{}'::JSONB)||jsonb_build_object(
    'cba_data',v_scene,'target_name',COALESCE(v_name,'Alvo'),'damage',p_damage,
    'pv_atual',v_new_hp,'pv_max',v_max_hp,'missiles',v_missiles,'spell_resistance_pending',true
  );
END;
$$;
REVOKE ALL ON FUNCTION public.conjurar_missil_magico_srd(TEXT,TEXT,SMALLINT,TEXT,INTEGER) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.conjurar_missil_magico_srd(TEXT,TEXT,SMALLINT,TEXT,INTEGER) TO authenticated;
NOTIFY pgrst,'reload schema';