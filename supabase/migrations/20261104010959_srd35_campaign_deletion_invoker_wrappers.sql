-- Keep privileged deletion logic in the non-exposed schema; public RPCs are invoker wrappers.
CREATE OR REPLACE FUNCTION priv.preparar_exclusao_campanha_propria(p_campaign_id bigint)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, priv, pg_temp
AS $function$
DECLARE
  v_owner uuid;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT c.owner_id INTO v_owner
  FROM public.campaigns c
  WHERE c.id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  IF v_owner IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'Somente o proprietário pode excluir esta campanha.';
  END IF;
  INSERT INTO priv.campaign_deletion_cleanup(campaign_id, owner_id, requested_at)
  VALUES (p_campaign_id, auth.uid(), now())
  ON CONFLICT (campaign_id) DO UPDATE
    SET owner_id = EXCLUDED.owner_id, requested_at = EXCLUDED.requested_at;
  RETURN jsonb_build_object('ok', true, 'campaign_id', p_campaign_id, 'deletion_pending', true);
END;
$function$;

CREATE OR REPLACE FUNCTION priv.finalizar_exclusao_campanha_propria(p_campaign_id bigint)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, priv, pg_temp
AS $function$
DECLARE
  v_owner uuid;
  v_pending_owner uuid;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT d.owner_id INTO v_pending_owner
  FROM priv.campaign_deletion_cleanup d
  WHERE d.campaign_id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND OR v_pending_owner IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'Não existe uma exclusão autorizada para esta campanha.';
  END IF;
  SELECT c.owner_id INTO v_owner
  FROM public.campaigns c
  WHERE c.id = p_campaign_id
  FOR UPDATE;
  IF FOUND THEN
    IF v_owner IS DISTINCT FROM auth.uid() THEN
      RAISE EXCEPTION 'Somente o proprietário pode excluir esta campanha.';
    END IF;
    DELETE FROM public.campaigns WHERE id = p_campaign_id;
  END IF;
  DELETE FROM priv.campaign_deletion_cleanup
  WHERE campaign_id = p_campaign_id AND owner_id = auth.uid();
  RETURN jsonb_build_object('ok', true, 'campaign_id', p_campaign_id, 'deleted', true);
END;
$function$;

REVOKE ALL ON FUNCTION priv.preparar_exclusao_campanha_propria(bigint) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION priv.preparar_exclusao_campanha_propria(bigint) TO authenticated;
REVOKE ALL ON FUNCTION priv.finalizar_exclusao_campanha_propria(bigint) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION priv.finalizar_exclusao_campanha_propria(bigint) TO authenticated;

CREATE OR REPLACE FUNCTION public.preparar_exclusao_campanha_propria(p_campaign_id bigint)
RETURNS jsonb
LANGUAGE sql
SECURITY INVOKER
SET search_path = public, priv, pg_temp
AS $function$
  SELECT priv.preparar_exclusao_campanha_propria(p_campaign_id);
$function$;

CREATE OR REPLACE FUNCTION public.finalizar_exclusao_campanha_propria(p_campaign_id bigint)
RETURNS jsonb
LANGUAGE sql
SECURITY INVOKER
SET search_path = public, priv, pg_temp
AS $function$
  SELECT priv.finalizar_exclusao_campanha_propria(p_campaign_id);
$function$;

REVOKE ALL ON FUNCTION public.preparar_exclusao_campanha_propria(bigint) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.preparar_exclusao_campanha_propria(bigint) TO authenticated;
REVOKE ALL ON FUNCTION public.finalizar_exclusao_campanha_propria(bigint) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.finalizar_exclusao_campanha_propria(bigint) TO authenticated;
