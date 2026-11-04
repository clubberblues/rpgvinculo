-- Freeze new campaign media writes during the two-phase deletion process.
ALTER TABLE public.campaigns
  ADD COLUMN IF NOT EXISTS deletion_pending boolean NOT NULL DEFAULT false;

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
    RETURN EXISTS (SELECT 1 FROM public.campaigns c WHERE c.id::text = v_match[1] AND c.owner_id = v_uid AND NOT c.deletion_pending);
  END IF;
  v_match := regexp_match(p_name, '^campaigns/([0-9]+)/');
  IF v_match IS NOT NULL THEN
    RETURN EXISTS (SELECT 1 FROM public.campaigns c
      WHERE c.id::text = v_match[1] AND NOT c.deletion_pending
        AND (c.owner_id = v_uid OR EXISTS (
          SELECT 1 FROM public.members m
          WHERE m.campaign_id = c.id AND m.user_id = v_uid AND m.role = 'GM'
        )));
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
  IF v_match IS NULL THEN v_match := regexp_match(p_name, '^capas_mesas/mesa-([0-9]+)-'); END IF;
  IF v_match IS NOT NULL THEN
    RETURN EXISTS (SELECT 1 FROM priv.campaign_deletion_cleanup d
      WHERE d.campaign_id::text = v_match[1] AND d.owner_id = v_uid);
  END IF;
  RETURN false;
END;
$function$;

CREATE OR REPLACE FUNCTION public.preparar_exclusao_campanha_propria(p_campaign_id bigint)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, priv, pg_temp AS $function$
DECLARE v_owner uuid;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT c.owner_id INTO v_owner FROM public.campaigns c WHERE c.id = p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  IF v_owner IS DISTINCT FROM auth.uid() THEN RAISE EXCEPTION 'Somente o proprietário pode excluir esta campanha.'; END IF;
  UPDATE public.campaigns SET deletion_pending = true WHERE id = p_campaign_id;
  INSERT INTO priv.campaign_deletion_cleanup(campaign_id, owner_id, requested_at)
  VALUES (p_campaign_id, auth.uid(), now())
  ON CONFLICT (campaign_id) DO UPDATE SET owner_id = EXCLUDED.owner_id, requested_at = EXCLUDED.requested_at;
  RETURN jsonb_build_object('ok', true, 'campaign_id', p_campaign_id, 'deletion_pending', true);
END;
$function$;

REVOKE ALL ON FUNCTION priv.can_write_midia(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION priv.can_write_midia(text) TO authenticated;
REVOKE ALL ON FUNCTION priv.can_delete_midia(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION priv.can_delete_midia(text) TO authenticated;
REVOKE ALL ON FUNCTION public.preparar_exclusao_campanha_propria(bigint) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.preparar_exclusao_campanha_propria(bigint) TO authenticated;
