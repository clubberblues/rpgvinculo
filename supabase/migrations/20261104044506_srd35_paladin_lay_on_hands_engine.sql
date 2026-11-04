-- Recursos diários de habilidades de classe e motor de Imposição das Mãos.
CREATE TABLE IF NOT EXISTS public.srd_character_feature_resources (
  character_id bigint NOT NULL REFERENCES public.characters(id) ON DELETE CASCADE,
  feature_key text NOT NULL,
  uses_spent integer NOT NULL DEFAULT 0 CHECK (uses_spent >= 0),
  resource_spent integer NOT NULL DEFAULT 0 CHECK (resource_spent >= 0),
  last_reset_at timestamptz NOT NULL DEFAULT now(),
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  PRIMARY KEY (character_id,feature_key)
);
ALTER TABLE public.srd_character_feature_resources ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.srd_character_feature_resources FROM PUBLIC,anon,authenticated;

CREATE OR REPLACE FUNCTION public.usar_habilidade_classe_srd(p_character_id text, p_feature_key text, p_target_token_key text DEFAULT NULL::text, p_amount integer DEFAULT NULL::integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_character public.characters%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_target_sheet public.srd_character_sheets%ROWTYPE;
  v_campaign public.campaigns%ROWTYPE;
  v_token jsonb;
  v_tokens jsonb;
  v_token_index bigint;
  v_token_count integer;
  v_paladin_level integer:=0;
  v_charisma integer:=10;
  v_charisma_mod integer:=0;
  v_pool integer:=0;
  v_spent integer:=0;
  v_remaining integer:=0;
  v_requested integer:=0;
  v_healing integer:=0;
  v_hp integer:=0;
  v_max_hp integer:=0;
  v_target_kind text:='character';
  v_target_id text;
  v_target_name text;
  v_scene jsonb;
  v_feature public.srd_character_feature_resources%ROWTYPE;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF NULLIF(BTRIM(p_character_id),'') IS NULL THEN RAISE EXCEPTION 'Personagem inválido.'; END IF;
  IF p_feature_key IS DISTINCT FROM 'lay_on_hands' THEN
    RAISE EXCEPTION 'Habilidade de classe ainda não disponível no motor: %.',p_feature_key;
  END IF;

  SELECT * INTO v_character
  FROM public.characters
  WHERE id::text=BTRIM(p_character_id) AND user_id=auth.uid()
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou não pertence ao usuário.'; END IF;

  SELECT * INTO v_sheet
  FROM public.srd_character_sheets
  WHERE character_id=v_character.id
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD do personagem não encontrada.'; END IF;

  SELECT COALESCE(
    MAX(cl.class_level) FILTER (WHERE cl.class_id='paladino'),
    CASE WHEN v_sheet.classe_id='paladino' THEN v_sheet.nivel ELSE 0 END
  )
  INTO v_paladin_level
  FROM public.srd_character_class_levels cl
  WHERE cl.character_id=v_sheet.character_id;
  IF COALESCE(v_paladin_level,0)<2 THEN
    RAISE EXCEPTION 'Imposição das Mãos exige pelo menos 2 níveis de Paladino.';
  END IF;

  v_charisma:=COALESCE(NULLIF(v_sheet.atributos->>'CAR','')::integer,10);
  v_charisma_mod:=FLOOR((v_charisma-10)::numeric/2)::integer;
  v_pool:=v_paladin_level*GREATEST(0,v_charisma_mod);
  IF v_pool<=0 THEN RAISE EXCEPTION 'O modificador de Carisma não concede pontos para Imposição das Mãos.'; END IF;

  INSERT INTO public.srd_character_feature_resources(character_id,feature_key)
  VALUES(v_sheet.character_id,'lay_on_hands')
  ON CONFLICT(character_id,feature_key) DO NOTHING;

  SELECT * INTO v_feature
  FROM public.srd_character_feature_resources
  WHERE character_id=v_sheet.character_id AND feature_key='lay_on_hands'
  FOR UPDATE;

  v_spent:=COALESCE(v_feature.resource_spent,0);
  v_remaining:=GREATEST(0,v_pool-v_spent);
  IF v_remaining<=0 THEN RAISE EXCEPTION 'Todos os pontos diários de Imposição das Mãos já foram usados.'; END IF;
  v_requested:=COALESCE(p_amount,v_remaining);
  IF v_requested<1 OR v_requested>v_remaining THEN
    RAISE EXCEPTION 'Quantidade inválida. Restam % pontos de cura hoje.',v_remaining;
  END IF;

  v_target_id:=v_character.id::text;
  v_target_name:=v_character.nome;
  IF NULLIF(BTRIM(p_target_token_key),'') IS NOT NULL THEN
    IF v_character.campaign_id IS NULL THEN RAISE EXCEPTION 'O personagem precisa estar em uma campanha para escolher outro alvo.'; END IF;
    SELECT * INTO v_campaign FROM public.campaigns WHERE id=v_character.campaign_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Campanha do personagem não encontrada.'; END IF;

    v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END;
    SELECT COUNT(*)::integer,MIN(t.ordinality),(array_agg(t.token ORDER BY t.ordinality))[1]
      INTO v_token_count,v_token_index,v_token
    FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(token,ordinality)
    WHERE t.token->>'id'=BTRIM(p_target_token_key) OR t.token->>'key'=BTRIM(p_target_token_key);
    IF v_token_count<>1 THEN RAISE EXCEPTION 'Alvo ausente ou duplicado no campo de batalha.'; END IF;

    v_target_name:=COALESCE(v_token->>'nome',v_token->>'name','Alvo');
    IF v_token->>'tipo'='player' THEN
      v_target_kind:='character';
      v_target_id:=v_token->>'id';
      SELECT sh.* INTO v_target_sheet
      FROM public.characters ch
      JOIN public.srd_character_sheets sh ON sh.character_id=ch.id
      WHERE ch.id::text=v_target_id AND ch.campaign_id=v_character.campaign_id
      FOR UPDATE OF sh;
      IF NOT FOUND THEN RAISE EXCEPTION 'Ficha do personagem-alvo não encontrada nesta campanha.'; END IF;
      v_hp:=COALESCE(v_target_sheet.pv_atual,v_target_sheet.pv_max);
      v_max_hp:=v_target_sheet.pv_max;
    ELSIF v_token->>'tipo' IN ('npc','monstro') THEN
      IF lower(COALESCE(v_token->'monsterStats'->>'tipo',v_token->'monsterStats'->>'type','')) LIKE '%undead%' THEN
        RAISE EXCEPTION 'Imposição das Mãos não cura mortos-vivos; o uso ofensivo exige uma rolagem de ataque e ainda não está implementado.';
      END IF;
      v_target_kind:='token';
      v_target_id:=COALESCE(v_token->>'key',v_token->>'id');
      IF COALESCE(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN RAISE EXCEPTION 'Alvo sem PV máximo válido.'; END IF;
      v_max_hp:=(v_token->>'maxHp')::integer;
      v_hp:=CASE WHEN COALESCE(v_token->>'hp','') ~ '^[0-9]{1,6}$' THEN (v_token->>'hp')::integer ELSE v_max_hp END;
    ELSE
      RAISE EXCEPTION 'Tipo de alvo inválido para Imposição das Mãos.';
    END IF;
  ELSE
    v_hp:=COALESCE(v_sheet.pv_atual,v_sheet.pv_max);
    v_max_hp:=v_sheet.pv_max;
  END IF;

  IF v_max_hp IS NULL OR v_max_hp<1 THEN RAISE EXCEPTION 'PV máximo do alvo inválido.'; END IF;
  IF v_hp>=v_max_hp THEN RAISE EXCEPTION 'O alvo já está com PV máximo.'; END IF;
  v_healing:=LEAST(v_requested,v_max_hp-v_hp);
  IF v_healing<=0 THEN RAISE EXCEPTION 'Não há PV a recuperar neste alvo.'; END IF;

  IF v_character.campaign_id IS NOT NULL THEN
    SELECT * INTO v_campaign FROM public.campaigns WHERE id=v_character.campaign_id FOR UPDATE;
    IF UPPER(COALESCE(v_campaign.state,''))='COMBATE' THEN
      PERFORM public.consumir_acao_turno_srd(v_character.campaign_id,v_character.id::text,'padrao');
    END IF;
  END IF;

  IF v_target_kind='character' THEN
    UPDATE public.srd_character_sheets
       SET pv_atual=LEAST(pv_max,GREATEST(-10,COALESCE(pv_atual,pv_max)+v_healing))
     WHERE character_id::text=v_target_id
     RETURNING pv_atual,pv_max INTO v_hp,v_max_hp;
    PERFORM priv.srd_sync_character_vital_condition(v_target_id,v_hp,false);
  ELSE
    v_token:=v_token||jsonb_build_object('hp',LEAST(v_max_hp,v_hp+v_healing),'maxHp',v_max_hp);
    v_tokens:=jsonb_set(v_tokens,ARRAY[(v_token_index-1)::text],v_token,false);
    UPDATE public.campaigns
       SET cba_data=COALESCE(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens)
     WHERE id=v_character.campaign_id
     RETURNING cba_data INTO v_scene;
    v_hp:=LEAST(v_max_hp,v_hp+v_healing);
  END IF;

  UPDATE public.srd_character_feature_resources
     SET resource_spent=v_spent+v_healing,last_reset_at=COALESCE(last_reset_at,now())
   WHERE character_id=v_sheet.character_id AND feature_key='lay_on_hands';

  RETURN jsonb_build_object(
    'feature_key','lay_on_hands',
    'character_id',v_character.id,
    'target_kind',v_target_kind,
    'target_id',v_target_id,
    'target_name',v_target_name,
    'healing',v_healing,
    'pv_atual',v_hp,
    'pv_max',v_max_hp,
    'resource_pool',v_pool,
    'resource_spent',v_spent+v_healing,
    'resource_remaining',v_pool-v_spent-v_healing,
    'cba_data',v_scene
  );
END;
$function$
;
REVOKE ALL ON FUNCTION public.usar_habilidade_classe_srd(text,text,text,integer) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.usar_habilidade_classe_srd(text,text,text,integer) TO authenticated;

CREATE OR REPLACE FUNCTION public.descanso_longo_personagem_srd(p_campaign_id bigint, p_character_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE v_owner UUID; v_campaign BIGINT; v_state TEXT; v_level INTEGER; v_hp INTEGER; v_max INTEGER; v_new_hp INTEGER; v_last_rest TIMESTAMPTZ; v_spell_state JSONB;
BEGIN
 IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
 SELECT c.user_id,c.campaign_id INTO v_owner,v_campaign FROM public.characters c WHERE c.id::TEXT=BTRIM(p_character_id) FOR UPDATE;
 IF NOT FOUND OR v_campaign IS DISTINCT FROM p_campaign_id THEN RAISE EXCEPTION 'Personagem não encontrado nesta campanha.'; END IF;
 IF v_owner IS DISTINCT FROM auth.uid() THEN RAISE EXCEPTION 'Somente o dono da ficha pode realizar descanso.'; END IF;
 SELECT state INTO v_state FROM public.campaigns WHERE id=p_campaign_id;
 IF UPPER(COALESCE(v_state,''))='COMBATE' THEN RAISE EXCEPTION 'Não é possível descansar durante um combate.'; END IF;
 SELECT s.nivel,s.pv_atual,s.pv_max,s.magias_descanso_em INTO v_level,v_hp,v_max,v_last_rest FROM public.srd_character_sheets s WHERE s.character_id::TEXT=BTRIM(p_character_id) FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada.'; END IF;
 IF v_last_rest IS NOT NULL AND v_last_rest>clock_timestamp()-INTERVAL '8 hours' THEN RAISE EXCEPTION 'O descanso longo exige 8 horas entre descansos.'; END IF;
 v_level:=GREATEST(1,COALESCE(v_level,1)); IF v_max IS NULL OR v_max<1 THEN RAISE EXCEPTION 'PV máximo inválido.'; END IF;
 v_new_hp:=LEAST(v_max,COALESCE(v_hp,v_max)+v_level);
 PERFORM public.repor_magias_srd(BTRIM(p_character_id));
 UPDATE public.srd_character_feature_resources SET uses_spent=0,resource_spent=0,last_reset_at=clock_timestamp() WHERE character_id=(SELECT id FROM public.characters WHERE id::text=BTRIM(p_character_id));
 UPDATE public.srd_character_sheets SET pv_atual=v_new_hp WHERE character_id::TEXT=BTRIM(p_character_id) RETURNING magias_preparadas INTO v_spell_state;
 RETURN jsonb_build_object('character_id',BTRIM(p_character_id),'pv_atual',v_new_hp,'pv_max',v_max,'cura',v_new_hp-COALESCE(v_hp,v_max),'magias_repostas',TRUE,'recursos_classe_repostos',TRUE,'descanso_em',clock_timestamp());
END; $function$
;
