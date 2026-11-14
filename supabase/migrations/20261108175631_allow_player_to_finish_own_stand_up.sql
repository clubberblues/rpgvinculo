
DO $patch$
DECLARE v_def text;
BEGIN
  v_def:=pg_get_functiondef('priv.srd_resolver_levantar_caido_apos_aoo_srd(bigint,uuid)'::regprocedure);
  v_def:=replace(v_def,
    $old$  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode concluir o levantamento.';
  END IF;$old$,
    $new$  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;$new$
  );
  v_def:=replace(v_def,
    $old$  IF v_count<>1 THEN RAISE EXCEPTION 'Token do levantamento ausente ou duplicado.'; END IF;$old$,
    $new$  IF v_count<>1 THEN RAISE EXCEPTION 'Token do levantamento ausente ou duplicado.'; END IF;
  IF public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' AND NOT (
    v_token->>'tipo'='player' AND EXISTS(
      SELECT 1 FROM public.characters ch WHERE ch.id::text=v_pending.mover_token_id
        AND ch.campaign_id=p_campaign_id AND ch.user_id=auth.uid()
    )
  ) THEN RAISE EXCEPTION 'Somente o Mestre ou o jogador dono do personagem pode concluir o levantamento.'; END IF;$new$
  );
  IF position('jogador dono do personagem pode concluir' in v_def)=0 THEN
    RAISE EXCEPTION 'Falha ao autorizar conclusão pelo dono da ficha.';
  END IF;
  EXECUTE v_def;
END;
$patch$;
