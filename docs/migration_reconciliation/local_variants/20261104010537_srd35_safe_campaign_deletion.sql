-- Two-phase, owner-only campaign deletion with Storage cleanup through the Storage API.
CREATE TABLE IF NOT EXISTS priv.campaign_deletion_cleanup (
  campaign_id bigint PRIMARY KEY,
  owner_id uuid NOT NULL,
  requested_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE priv.campaign_deletion_cleanup ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE priv.campaign_deletion_cleanup FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION priv.can_write_midia(p_name text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv
AS $function$
DECLARE
  v_uid uuid := auth.uid();
  v_match text[];
BEGIN
  IF v_uid IS NULL OR p_name IS NULL THEN RETURN false; END IF;
  IF split_part(p_name, '/', 1) = 'avatars' THEN
    RETURN split_part(p_name, '/', 2) = v_uid::text AND split_part(p_name, '/', 3) <> '';
  END IF;
  IF left(p_name, length('retratos/temp-' || v_uid::text || '-')) = 'retratos/temp-' || v_uid::text || '-'
     OR left(p_name, length('headers/temp-bg-' || v_uid::text || '-')) = 'headers/temp-bg-' || v_uid::text || '-' THEN
    RETURN true;
  END IF;
  v_match := regexp_match(p_name, '^retratos/([0-9]+)-foto-');
  IF v_match IS NOT NULL THEN
    RETURN EXISTS (SELECT 1 FROM public.characters c WHERE c.id::text = v_match[1] AND c.user_id = v_uid);
  END IF;
  v_match := regexp_match(p_name, '^headers/([0-9]+)-bg-');
  IF v_match IS NOT NULL THEN
    RETURN EXISTS (SELECT 1 FROM public.characters c WHERE c.id::text = v_match[1] AND c.user_id = v_uid);
  END IF;
  v_match := regexp_match(p_name, '^capas_mesas/mesa-([0-9]+)-');
  IF v_match IS NOT NULL THEN
    RETURN EXISTS (SELECT 1 FROM public.campaigns c WHERE c.id::text = v_match[1] AND c.owner_id = v_uid);
  END IF;
  v_match := regexp_match(p_name, '^campaigns/([0-9]+)/');
  IF v_match IS NOT NULL THEN
    RETURN EXISTS (SELECT 1 FROM public.campaigns c WHERE c.id::text = v_match[1] AND c.owner_id = v_uid)
      OR EXISTS (SELECT 1 FROM public.members m WHERE m.campaign_id::text = v_match[1] AND m.user_id = v_uid AND m.role = 'GM');
  END IF;
  RETURN false;
END;
$function$;

CREATE OR REPLACE FUNCTION priv.can_delete_midia(p_name text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv
AS $function$
DECLARE
  v_uid uuid := auth.uid();
  v_match text[];
BEGIN
  IF v_uid IS NULL OR p_name IS NULL THEN RETURN false; END IF;
  IF priv.can_write_midia(p_name) THEN RETURN true; END IF;
  v_match := regexp_match(p_name, '^campaigns/([0-9]+)/');
  IF v_match IS NOT NULL THEN
    RETURN EXISTS (SELECT 1 FROM priv.campaign_deletion_cleanup d WHERE d.campaign_id::text = v_match[1] AND d.owner_id = v_uid);
  END IF;
  RETURN false;
END;
$function$;

REVOKE ALL ON FUNCTION priv.can_write_midia(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION priv.can_write_midia(text) TO authenticated;
REVOKE ALL ON FUNCTION priv.can_delete_midia(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION priv.can_delete_midia(text) TO authenticated;

DROP POLICY IF EXISTS midia_delete_scoped ON storage.objects;
CREATE POLICY midia_delete_scoped ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'midia' AND priv.can_delete_midia(name));

CREATE OR REPLACE FUNCTION public.preparar_exclusao_campanha_propria(p_campaign_id bigint)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, priv, pg_temp AS $function$
DECLARE v_owner uuid;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT c.owner_id INTO v_owner FROM public.campaigns c WHERE c.id = p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  IF v_owner IS DISTINCT FROM auth.uid() THEN RAISE EXCEPTION 'Somente o proprietário pode excluir esta campanha.'; END IF;
  INSERT INTO priv.campaign_deletion_cleanup(campaign_id, owner_id, requested_at)
  VALUES (p_campaign_id, auth.uid(), now())
  ON CONFLICT (campaign_id) DO UPDATE SET owner_id = EXCLUDED.owner_id, requested_at = EXCLUDED.requested_at;
  RETURN jsonb_build_object('ok', true, 'campaign_id', p_campaign_id);
END;
$function$;

CREATE OR REPLACE FUNCTION public.finalizar_exclusao_campanha_propria(p_campaign_id bigint)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, priv, pg_temp AS $function$
DECLARE v_owner uuid; v_pending_owner uuid;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT d.owner_id INTO v_pending_owner FROM priv.campaign_deletion_cleanup d WHERE d.campaign_id = p_campaign_id FOR UPDATE;
  IF NOT FOUND OR v_pending_owner IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'Não existe uma exclusão autorizada para esta campanha.';
  END IF;
  SELECT c.owner_id INTO v_owner FROM public.campaigns c WHERE c.id = p_campaign_id FOR UPDATE;
  IF FOUND THEN
    IF v_owner IS DISTINCT FROM auth.uid() THEN RAISE EXCEPTION 'Somente o proprietário pode excluir esta campanha.'; END IF;
    DELETE FROM public.campaigns WHERE id = p_campaign_id;
  END IF;
  DELETE FROM priv.campaign_deletion_cleanup WHERE campaign_id = p_campaign_id AND owner_id = auth.uid();
  RETURN jsonb_build_object('ok', true, 'campaign_id', p_campaign_id, 'deleted', true);
END;
$function$;

REVOKE ALL ON FUNCTION public.preparar_exclusao_campanha_propria(bigint) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.preparar_exclusao_campanha_propria(bigint) TO authenticated;
REVOKE ALL ON FUNCTION public.finalizar_exclusao_campanha_propria(bigint) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.finalizar_exclusao_campanha_propria(bigint) TO authenticated;
