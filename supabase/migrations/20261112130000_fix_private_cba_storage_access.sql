-- Authorize private CBA assets using the actual campaigns/{id}/... path.
-- Players read only the active map and explicitly visible token portraits.
-- GM writes/deletes are serialized against campaign deletion via FOR KEY SHARE.
-- Deletes remain possible during cleanup; new reads/writes do not.
BEGIN;

DROP POLICY IF EXISTS mesa_media_ler ON storage.objects;
DROP POLICY IF EXISTS mesa_media_enviar ON storage.objects;
DROP POLICY IF EXISTS mesa_media_trocar ON storage.objects;
DROP POLICY IF EXISTS mesa_media_apagar ON storage.objects;

DROP FUNCTION IF EXISTS priv.cba_media_campaign_access(text, boolean);

CREATE OR REPLACE FUNCTION priv.cba_media_campaign_access(
  p_name text,
  p_write boolean DEFAULT false,
  p_delete boolean DEFAULT false
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
  v_cba_data jsonb;
  v_is_gm boolean;
  v_is_member boolean;
  v_cleanup boolean;
BEGIN
  IF v_user IS NULL OR p_name IS NULL OR (p_delete AND NOT p_write) THEN
    RETURN false;
  END IF;

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
    SELECT c.owner_id, c.cba_data INTO v_owner_id, v_cba_data
      FROM public.campaigns c
     WHERE c.id = v_campaign_id
     FOR KEY SHARE;
  ELSE
    SELECT c.owner_id, c.cba_data INTO v_owner_id, v_cba_data
      FROM public.campaigns c
     WHERE c.id = v_campaign_id;
  END IF;

  IF NOT FOUND THEN
    RETURN false;
  END IF;

  SELECT EXISTS (
    SELECT 1 FROM priv.campaign_deletion_cleanup d
    WHERE d.campaign_id = v_campaign_id
  ) INTO v_cleanup;

  IF v_owner_id = v_user THEN
    RETURN NOT v_cleanup OR p_delete;
  END IF;

  SELECT EXISTS (
    SELECT 1 FROM public.members m
    WHERE m.campaign_id = v_campaign_id
      AND m.user_id = v_user
      AND m.role = 'GM'
  ) INTO v_is_gm;

  IF v_is_gm THEN
    RETURN NOT v_cleanup OR p_delete;
  END IF;

  IF v_cleanup OR p_write THEN
    RETURN false;
  END IF;

  SELECT EXISTS (
    SELECT 1 FROM public.members m
    WHERE m.campaign_id = v_campaign_id
      AND m.user_id = v_user
  ) INTO v_is_member;

  IF NOT v_is_member THEN
    RETURN false;
  END IF;

  IF v_cba_data->>'backgroundPath' = p_name THEN
    RETURN true;
  END IF;

  RETURN EXISTS (
    SELECT 1
      FROM jsonb_array_elements(
        CASE WHEN jsonb_typeof(v_cba_data->'tokens') = 'array'
             THEN v_cba_data->'tokens' ELSE '[]'::jsonb END
      ) AS token(value)
     WHERE token.value->>'imagemPath' = p_name
       AND token.value->>'visivel' = 'true'
  );
END
$function$;

REVOKE ALL ON FUNCTION priv.cba_media_campaign_access(text, boolean, boolean)
  FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION priv.cba_media_campaign_access(text, boolean, boolean)
  TO authenticated;

CREATE POLICY mesa_media_ler ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'mesa-media'
    AND priv.cba_media_campaign_access(name, false, false)
  );

CREATE POLICY mesa_media_enviar ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'mesa-media'
    AND priv.cba_media_campaign_access(name, true, false)
  );

CREATE POLICY mesa_media_trocar ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'mesa-media'
    AND priv.cba_media_campaign_access(name, true, false)
  )
  WITH CHECK (
    bucket_id = 'mesa-media'
    AND priv.cba_media_campaign_access(name, true, false)
  );

CREATE POLICY mesa_media_apagar ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'mesa-media'
    AND priv.cba_media_campaign_access(name, true, true)
  );

COMMIT;
