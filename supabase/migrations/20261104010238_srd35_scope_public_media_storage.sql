-- Restrict writes to the public media bucket to the owning user or campaign GM.
-- Public reads remain enabled because these assets are intentionally served by public URLs.
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
  IF v_uid IS NULL OR p_name IS NULL THEN
    RETURN false;
  END IF;

  -- Profile avatars: avatars/<auth-user-id>/...
  IF split_part(p_name, '/', 1) = 'avatars' THEN
    RETURN split_part(p_name, '/', 2) = v_uid::text
       AND split_part(p_name, '/', 3) <> '';
  END IF;

  -- Temporary portraits/backgrounds created before a character exists.
  IF left(p_name, length('retratos/temp-' || v_uid::text || '-')) =
       'retratos/temp-' || v_uid::text || '-'
     OR left(p_name, length('headers/temp-bg-' || v_uid::text || '-')) =
       'headers/temp-bg-' || v_uid::text || '-' THEN
    RETURN true;
  END IF;

  -- Saved character portrait and header background: only the character owner.
  v_match := regexp_match(p_name, '^retratos/([0-9]+)-foto-');
  IF v_match IS NOT NULL THEN
    RETURN EXISTS (
      SELECT 1 FROM public.characters c
      WHERE c.id::text = v_match[1] AND c.user_id = v_uid
    );
  END IF;

  v_match := regexp_match(p_name, '^headers/([0-9]+)-bg-');
  IF v_match IS NOT NULL THEN
    RETURN EXISTS (
      SELECT 1 FROM public.characters c
      WHERE c.id::text = v_match[1] AND c.user_id = v_uid
    );
  END IF;

  -- Campaign covers: campaign owner only.
  v_match := regexp_match(p_name, '^capas_mesas/mesa-([0-9]+)-');
  IF v_match IS NOT NULL THEN
    RETURN EXISTS (
      SELECT 1 FROM public.campaigns c
      WHERE c.id::text = v_match[1] AND c.owner_id = v_uid
    );
  END IF;

  -- Battle maps and token portraits: GM of the campaign in the path.
  v_match := regexp_match(p_name, '^campaigns/([0-9]+)/');
  IF v_match IS NOT NULL THEN
    RETURN EXISTS (
      SELECT 1 FROM public.members m
      WHERE m.campaign_id::text = v_match[1]
        AND m.user_id = v_uid
        AND m.role = 'GM'
    );
  END IF;

  RETURN false;
END;
$function$;

REVOKE ALL ON FUNCTION priv.can_write_midia(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION priv.can_write_midia(text) TO authenticated;

DROP POLICY IF EXISTS "midia write" ON storage.objects;
DROP POLICY IF EXISTS "midia update" ON storage.objects;
DROP POLICY IF EXISTS midia_insert_scoped ON storage.objects;
DROP POLICY IF EXISTS midia_update_scoped ON storage.objects;
DROP POLICY IF EXISTS midia_delete_scoped ON storage.objects;

CREATE POLICY midia_insert_scoped
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'midia' AND priv.can_write_midia(name));

CREATE POLICY midia_update_scoped
ON storage.objects FOR UPDATE TO authenticated
USING (bucket_id = 'midia' AND priv.can_write_midia(name))
WITH CHECK (bucket_id = 'midia' AND priv.can_write_midia(name));

CREATE POLICY midia_delete_scoped
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'midia' AND priv.can_write_midia(name));
