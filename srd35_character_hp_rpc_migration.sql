-- Corrige no schema cache o RPC usado pelo Mestre para ajustar PV de personagens SRD.
-- Aplicar depois de vtt_dnd35_final_migration.sql.
BEGIN;

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
  v_role TEXT;
  v_pv_atual INTEGER;
  v_pv_max INTEGER;
  v_pv_novo INTEGER;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  IF p_variacao IS NULL OR p_variacao = 0 THEN RAISE EXCEPTION 'A variação de PV é obrigatória.'; END IF;
  SELECT m.role INTO v_role FROM public.members AS m
  WHERE m.campaign_id=p_campaign_id AND m.user_id=auth.uid() LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'Somente o Mestre da campanha pode alterar os PV.'; END IF;
  PERFORM 1 FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  SELECT s.pv_atual,s.pv_max INTO v_pv_atual,v_pv_max
  FROM public.characters AS c
  JOIN public.srd_character_sheets AS s ON s.character_id::TEXT=c.id::TEXT
  WHERE c.id::TEXT=BTRIM(p_character_id) AND c.campaign_id=p_campaign_id
  FOR UPDATE OF s;
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem SRD não encontrado nesta campanha.'; END IF;
  IF v_pv_max IS NULL OR v_pv_max<1 THEN RAISE EXCEPTION 'A ficha não possui um PV máximo válido.'; END IF;
  v_pv_novo:=GREATEST(0,LEAST(v_pv_max,COALESCE(v_pv_atual,v_pv_max)+p_variacao));
  UPDATE public.srd_character_sheets SET pv_atual=v_pv_novo
  WHERE character_id::TEXT=BTRIM(p_character_id);
  RETURN jsonb_build_object('character_id',BTRIM(p_character_id),'pv_atual',v_pv_novo,'pv_max',v_pv_max,'variacao_solicitada',p_variacao);
END;
$$;
REVOKE ALL ON FUNCTION public.alterar_pv_personagem(BIGINT,TEXT,INTEGER) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.alterar_pv_personagem(BIGINT,TEXT,INTEGER) TO authenticated;
NOTIFY pgrst,'reload schema';
COMMIT;
