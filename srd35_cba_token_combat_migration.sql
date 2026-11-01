-- Preserve combat statistics for CBA tokens and provide the GM-only token HP RPC.
-- Apply after srd35_token_equipment_migration.sql and the base CBA migration.

CREATE OR REPLACE FUNCTION public.adicionar_token_cba_completo(
  p_campaign_id bigint,
  p_token jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_scene jsonb;
  v_key text;
  v_id text;
  v_extra jsonb;
  v_base_ac numeric;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF jsonb_typeof(p_token) IS DISTINCT FROM 'object' THEN
    RAISE EXCEPTION 'O token enviado é inválido.';
  END IF;

  -- The existing routine validates GM membership, token identity, and free grid cell.
  v_scene := public.adicionar_token_cba(p_campaign_id, p_token);
  v_key := LEFT(BTRIM(COALESCE(p_token->>'key','')),160);
  v_id := LEFT(BTRIM(COALESCE(p_token->>'id','')),120);
  v_base_ac := CASE WHEN COALESCE(p_token->>'ac','') ~ '^[0-9]+(\.[0-9]+)?$'
    THEN (p_token->>'ac')::numeric ELSE NULL END;

  v_extra := jsonb_build_object(
    'monsterId', p_token->'monsterId',
    'monsterStats', CASE WHEN jsonb_typeof(p_token->'monsterStats')='object' THEN p_token->'monsterStats' ELSE NULL END,
    'srdSourceUrl', CASE WHEN COALESCE(p_token->>'srdSourceUrl','') ~* '^https?://' THEN p_token->'srdSourceUrl' ELSE '""'::jsonb END,
    'hp', CASE WHEN COALESCE(p_token->>'hp','') ~ '^-?[0-9]+$' THEN to_jsonb(GREATEST(0,(p_token->>'hp')::integer)) ELSE 'null'::jsonb END,
    'maxHp', CASE WHEN COALESCE(p_token->>'maxHp','') ~ '^[0-9]+$' THEN to_jsonb(GREATEST(1,(p_token->>'maxHp')::integer)) ELSE 'null'::jsonb END,
    'dexMod', CASE WHEN COALESCE(p_token->>'dexMod','') ~ '^-?[0-9]+$' THEN to_jsonb(GREATEST(-20,LEAST(20,(p_token->>'dexMod')::integer))) ELSE 'null'::jsonb END,
    'ac', COALESCE(to_jsonb(v_base_ac),'null'::jsonb),
    'baseAc', COALESCE(to_jsonb(v_base_ac),'null'::jsonb),
    'sourceCharacterId', p_token->'sourceCharacterId',
    'attackBonus', p_token->'attackBonus',
    'damageDice', p_token->'damageDice',
    'spellState', CASE WHEN jsonb_typeof(p_token->'spellState')='object' THEN p_token->'spellState' ELSE NULL END
  );
  UPDATE public.campaigns c
  SET cba_data = jsonb_set(c.cba_data, '{tokens}',
    (SELECT jsonb_agg(CASE WHEN t->>'key'=v_key AND t->>'id'=v_id THEN t || v_extra ELSE t END ORDER BY ord)
     FROM jsonb_array_elements(c.cba_data->'tokens') WITH ORDINALITY AS e(t,ord)), true)
  WHERE c.id=p_campaign_id
  RETURNING c.cba_data INTO v_scene;
  IF v_scene IS NULL THEN RAISE EXCEPTION 'A cena não foi atualizada.'; END IF;
  RETURN v_scene;
END;
$$;

REVOKE ALL ON FUNCTION public.adicionar_token_cba_completo(bigint,jsonb) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.adicionar_token_cba_completo(bigint,jsonb) TO authenticated;

CREATE OR REPLACE FUNCTION public.alterar_pv_token_cba(
  p_campaign_id bigint,
  p_token_id text,
  p_variacao integer,
  p_pv_max integer DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_scene jsonb;
  v_tokens jsonb;
  v_token jsonb;
  v_hp integer;
  v_max integer;
  v_found boolean := false;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.members m
    WHERE m.campaign_id=p_campaign_id AND m.user_id=auth.uid() AND m.role='GM'
  ) THEN RAISE EXCEPTION 'Somente o Mestre pode alterar PV dos tokens.'; END IF;

  SELECT cba_data INTO v_scene
  FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  v_tokens := CASE WHEN jsonb_typeof(v_scene->'tokens')='array' THEN v_scene->'tokens' ELSE '[]'::jsonb END;
  SELECT t INTO v_token FROM jsonb_array_elements(v_tokens) AS x(t)
  WHERE t->>'id'=p_token_id AND COALESCE(t->>'tipo','') IN ('npc','monstro')
  LIMIT 1;
  IF NOT FOUND THEN RAISE EXCEPTION 'Token não encontrado ou não é uma criatura controlada pelo Mestre.'; END IF;

  v_max := COALESCE(p_pv_max, NULLIF(v_token->>'maxHp','')::integer, NULLIF(v_token->>'hp','')::integer, 1);
  v_max := GREATEST(1,LEAST(100000,v_max));
  v_hp := COALESCE(NULLIF(v_token->>'hp','')::integer,v_max);
  v_hp := GREATEST(0,LEAST(v_max,v_hp+COALESCE(p_variacao,0)));
  SELECT jsonb_agg(CASE WHEN t->>'id'=p_token_id AND COALESCE(t->>'tipo','') IN ('npc','monstro')
    THEN t || jsonb_build_object('hp',v_hp,'maxHp',v_max) ELSE t END ORDER BY ord)
  INTO v_tokens FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS e(t,ord);
  v_scene := jsonb_set(v_scene,'{tokens}',COALESCE(v_tokens,'[]'::jsonb),true);
  UPDATE public.campaigns SET cba_data=v_scene WHERE id=p_campaign_id;
  RETURN jsonb_build_object('cba_data',v_scene,'hp',v_hp,'max_hp',v_max);
END;
$$;

REVOKE ALL ON FUNCTION public.alterar_pv_token_cba(bigint,text,integer,integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.alterar_pv_token_cba(bigint,text,integer,integer) TO authenticated;
NOTIFY pgrst, 'reload schema';
