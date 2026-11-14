DROP POLICY IF EXISTS mesa_media_trocar ON storage.objects;

CREATE POLICY mesa_media_trocar
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'mesa-media'
  AND priv.pasta_gm(name)
)
WITH CHECK (
  bucket_id = 'mesa-media'
  AND priv.pasta_gm(name)
);
