-- Nova frente "mesa livre": movimento de token sem regras automáticas.
-- ADITIVA: cria apenas uma função nova. Não altera nem remove nenhuma função existente.
-- Mestre (members.role = 'GM') move qualquer token; jogador move só o token do próprio personagem.
-- Não valida turno, deslocamento, ocupação de quadrado nem condições: o grupo conduz isso pelo Discord.
BEGIN;

CREATE OR REPLACE FUNCTION public.mover_token_livre_mesa(
  p_campaign_id BIGINT,
  p_token_id TEXT,
  p_grid_x INTEGER,
  p_grid_y INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_role TEXT;
  v_scene JSONB;
  v_tokens JSONB;
  v_token JSONB;
  v_idx BIGINT;
  v_count INTEGER;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  IF NULLIF(BTRIM(p_token_id), '') IS NULL THEN RAISE EXCEPTION 'O token é obrigatório.'; END IF;
  IF p_grid_x IS NULL OR p_grid_y IS NULL OR p_grid_x < 0 OR p_grid_y < 0
     OR p_grid_x > 199 OR p_grid_y > 199 THEN
    RAISE EXCEPTION 'A posição deve estar na grade (0 a 199).';
  END IF;

  SELECT m.role INTO v_role FROM public.members AS m
   WHERE m.campaign_id = p_campaign_id AND m.user_id = auth.uid() LIMIT 1;
  IF v_role IS NULL THEN RAISE EXCEPTION 'Você não participa desta campanha.'; END IF;

  SELECT c.cba_data INTO v_scene FROM public.campaigns AS c
   WHERE c.id = p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;

  v_tokens := CASE WHEN jsonb_typeof(v_scene->'tokens') = 'array' THEN v_scene->'tokens' ELSE '[]'::JSONB END;
  SELECT count(*)::INTEGER, min(q.ordinality) INTO v_count, v_idx
    FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS q(token, ordinality)
   WHERE q.token->>'id' = BTRIM(p_token_id);
  IF v_count = 0 THEN RAISE EXCEPTION 'Token não encontrado na cena.'; END IF;
  IF v_count > 1 THEN RAISE EXCEPTION 'Há mais de um token com esse identificador na cena.'; END IF;
  v_token := v_tokens->(v_idx::INTEGER - 1);

  IF v_role <> 'GM' THEN
    IF v_token->>'tipo' IS DISTINCT FROM 'player' THEN
      RAISE EXCEPTION 'Você só pode mover o token do seu personagem.';
    END IF;
    IF NOT EXISTS (
      SELECT 1 FROM public.characters ch
       WHERE ch.id::TEXT = BTRIM(p_token_id)
         AND ch.campaign_id = p_campaign_id AND ch.user_id = auth.uid()
    ) THEN
      RAISE EXCEPTION 'Este token não pertence a um personagem seu.';
    END IF;
  END IF;

  v_token := v_token || jsonb_build_object('gridX', p_grid_x, 'gridY', p_grid_y);
  v_scene := COALESCE(v_scene, '{}'::JSONB)
    || jsonb_build_object('tokens', jsonb_set(v_tokens, ARRAY[(v_idx - 1)::TEXT], v_token, FALSE));
  UPDATE public.campaigns SET cba_data = v_scene WHERE id = p_campaign_id;
  RETURN jsonb_build_object('cba_data', v_scene);
END;
$$;

REVOKE ALL ON FUNCTION public.mover_token_livre_mesa(BIGINT, TEXT, INTEGER, INTEGER) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.mover_token_livre_mesa(BIGINT, TEXT, INTEGER, INTEGER) TO authenticated;
NOTIFY pgrst, 'reload schema';
COMMIT;
