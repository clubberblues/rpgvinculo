
DO $patch$
DECLARE v_def text;
BEGIN
  v_def:=pg_get_functiondef('priv.srd_iniciar_levantar_caido_srd(bigint,text)'::regprocedure);
  v_def:=replace(v_def,
    $old$  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode coordenar o levantamento nesta versão.';
  END IF;$old$,
    $new$  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;$new$
  );
  v_def:=replace(v_def,
    $old$  IF v_count<>1 THEN RAISE EXCEPTION 'Token ausente ou duplicado.'; END IF;
  v_token_id:=coalesce(v_token->>'key',v_token->>'id');$old$,
    $new$  IF v_count<>1 THEN RAISE EXCEPTION 'Token ausente ou duplicado.'; END IF;
  IF public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' AND NOT (
    v_token->>'tipo'='player' AND EXISTS(
      SELECT 1 FROM public.characters ch WHERE ch.id::text=v_token->>'id'
        AND ch.campaign_id=p_campaign_id AND ch.user_id=auth.uid()
    )
  ) THEN RAISE EXCEPTION 'Somente o Mestre ou o jogador dono do personagem pode iniciar o levantamento.'; END IF;
  v_token_id:=coalesce(v_token->>'key',v_token->>'id');$new$
  );
  IF position('jogador dono do personagem pode iniciar' in v_def)=0 THEN
    RAISE EXCEPTION 'Falha ao autorizar o dono da ficha.';
  END IF;
  EXECUTE v_def;
END;
$patch$;
