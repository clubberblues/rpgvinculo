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
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF p_variacao IS NULL OR p_variacao = 0 THEN
    RAISE EXCEPTION 'A variação de PV é obrigatória.';
  END IF;

  SELECT c.user_id, c.campaign_id, s.pv_atual, s.pv_max
    INTO v_owner, v_campaign_id, v_pv_atual, v_pv_max
    FROM public.characters AS c
    JOIN public.srd_character_sheets AS s
      ON s.character_id::TEXT = c.id::TEXT
   WHERE c.id::TEXT = BTRIM(p_character_id)
   FOR UPDATE OF s;

  IF NOT FOUND OR v_campaign_id IS DISTINCT FROM p_campaign_id THEN
    RAISE EXCEPTION 'Personagem SRD não encontrado nesta campanha.';
  END IF;

  IF v_owner IS DISTINCT FROM auth.uid()
     AND NOT (
       EXISTS (
         SELECT 1
           FROM public.members AS member
          WHERE member.campaign_id = p_campaign_id
            AND member.user_id = auth.uid()
            AND member.role = 'GM'
       )
       OR EXISTS (
         SELECT 1
           FROM public.campaigns AS campaign
          WHERE campaign.id = p_campaign_id
            AND campaign.owner_id = auth.uid()
       )
     ) THEN
    RAISE EXCEPTION 'Somente o dono da ficha ou o Mestre desta campanha pode ajustar os PV.';
  END IF;

  IF v_pv_max IS NULL OR v_pv_max < 1 THEN
    RAISE EXCEPTION 'A ficha não possui um PV máximo válido.';
  END IF;

  v_pv_novo := GREATEST(
    0,
    LEAST(v_pv_max, COALESCE(v_pv_atual, v_pv_max) + p_variacao)
  );

  UPDATE public.srd_character_sheets
     SET pv_atual = v_pv_novo
   WHERE character_id::TEXT = BTRIM(p_character_id);

  RETURN jsonb_build_object(
    'character_id', BTRIM(p_character_id),
    'pv_atual', v_pv_novo,
    'pv_max', v_pv_max,
    'variacao_solicitada', p_variacao
  );
END;
$$;

REVOKE ALL ON FUNCTION public.alterar_pv_personagem(BIGINT, TEXT, INTEGER)
  FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.alterar_pv_personagem(BIGINT, TEXT, INTEGER)
  TO authenticated;

NOTIFY pgrst, 'reload schema';
