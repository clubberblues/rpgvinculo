-- Authorize private CBA assets using the actual campaigns/{id}/... path.
-- Reads are available to campaign members; writes/deletes are GM-only.
-- Write authorization locks the campaign row until the Storage metadata transaction
-- commits, serializing upload completion against campaign deletion preparation.
BEGIN;

CREATE OR REPLACE FUNCTION priv.cba_media_campaign_access(
  p_name text,
  p_write boolean DEFAULT false
) RETURNS boolean
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path TO public, priv, storage, pg_temp
AS $function$
DECLARE
  v_user uuid := auth.uid();
  v_campaign_id bigint;
  v_owner_id uuid;
  v_is_gm boolean;
BEGIN
  IF v_user IS NULL OR p_name IS NULL THEN
    RETURN false;
  END IF;

  -- Reject alternate prefixes, missing filenames, traversal, empty segments
  -- and Windows separators before converting the campaign id.
  IF p_name !~ '^campaigns/[0-9]+/.+$'
     OR p_name LIKE '%//%'
     OR p_name ~ '(^|/)\.\.?(/|$)'
     OR strpos(p_name, chr(92)) > 0 THEN
    RETURN false;
  END IF;

  BEGIN
    v_campaign_id := substring(p_name FROM '^campaigns/([0-9]+)/')::bigint;
  EXCEPTION WHEN numeric_value_out_of_range THEN
    RETURN false;
  END;

  IF p_write THEN
    SELECT c.owner_id INTO v_owner_id
      FROM public.campaigns c
     WHERE c.id = v_campaign_id
     FOR KEY SHARE;
  ELSE
    SELECT c.owner_id INTO v_owner_id
      FROM public.campaigns c
     WHERE c.id = v_campaign_id;
  END IF;

  IF NOT FOUND THEN
    RETURN false;
  END IF;

  -- A cleanup marker closes new reads and all writes while deletion is pending.
  IF EXISTS (
    SELECT 1 FROM priv.campaign_deletion_cleanup d
    WHERE d.campaign_id = v_campaign_id
  ) THEN
    RETURN false;
  END IF;

  IF v_owner_id = v_user THEN
    RETURN true;
  END IF;

  SELECT EXISTS (
    SELECT 1 FROM public.members m
    WHERE m.campaign_id = v_campaign_id
      AND m.user_id = v_user
      AND (NOT p_write OR m.role = 'GM')
  ) INTO v_is_gm;

  RETURN v_is_gm;
END
$function$;

REVOKE ALL ON FUNCTION priv.cba_media_campaign_access(text, boolean)
  FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION priv.cba_media_campaign_access(text, boolean)
  TO authenticated;

DROP POLICY IF EXISTS mesa_media_ler ON storage.objects;
DROP POLICY IF EXISTS mesa_media_enviar ON storage.objects;
DROP POLICY IF EXISTS mesa_media_trocar ON storage.objects;
DROP POLICY IF EXISTS mesa_media_apagar ON storage.objects;

CREATE POLICY mesa_media_ler ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'mesa-media'
    AND priv.cba_media_campaign_access(name, false)
  );

CREATE POLICY mesa_media_enviar ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'mesa-media'
    AND priv.cba_media_campaign_access(name, true)
  );

CREATE POLICY mesa_media_trocar ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'mesa-media'
    AND priv.cba_media_campaign_access(name, true)
  )
  WITH CHECK (
    bucket_id = 'mesa-media'
    AND priv.cba_media_campaign_access(name, true)
  );

CREATE POLICY mesa_media_apagar ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'mesa-media'
    AND priv.cba_media_campaign_access(name, true)
  );

COMMIT;
