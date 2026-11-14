-- Autoridade de controle para fichas: dono sempre; Mestre apenas na campanha.
BEGIN;
CREATE OR REPLACE FUNCTION priv.srd_can_control_character(p_character_id text)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $function$
 SELECT NULLIF(BTRIM(p_character_id),'') IS NOT NULL
   AND EXISTS (
     SELECT 1
       FROM public.characters ch
      WHERE ch.id::text=BTRIM(p_character_id)
        AND (
          ch.user_id=auth.uid()
          OR (
            ch.campaign_id IS NOT NULL
            AND (
              UPPER(COALESCE(public.my_role(ch.campaign_id),''))='GM'
              OR EXISTS (
                SELECT 1 FROM public.campaigns c
                 WHERE c.id=ch.campaign_id AND c.owner_id=auth.uid()
              )
            )
          )
        )
   )
$function$;
REVOKE ALL ON FUNCTION priv.srd_can_control_character(text) FROM PUBLIC,anon,authenticated;
COMMIT;
