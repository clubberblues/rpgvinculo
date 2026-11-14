-- Permite ao Mestre da campanha operar a economia de ações de um PC
-- sem transferir a propriedade da ficha. Depende da migration de filtragem
-- CBA que move a implementação para priv.consumir_acao_turno_srd.
BEGIN;

CREATE OR REPLACE FUNCTION priv.srd_can_control_campaign_character(
  p_campaign_id bigint,
  p_character_id text
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  SELECT
    p_campaign_id IS NOT NULL
    AND NULLIF(BTRIM(p_character_id), '') IS NOT NULL
    AND EXISTS (
      SELECT 1
        FROM public.characters ch
       WHERE ch.campaign_id = p_campaign_id
         AND ch.id::text = BTRIM(p_character_id)
         AND (
           (
             ch.user_id = auth.uid()
             AND UPPER(COALESCE(public.my_role(p_campaign_id), '')) = 'PLAYER'
           )
           OR UPPER(COALESCE(public.my_role(p_campaign_id), '')) = 'GM'
           OR EXISTS (
             SELECT 1
               FROM public.campaigns c
              WHERE c.id = p_campaign_id
                AND c.owner_id = auth.uid()
           )
         )
    )
$function$;

REVOKE ALL ON FUNCTION priv.srd_can_control_campaign_character(bigint, text)
  FROM PUBLIC, anon, authenticated;

DO $migration$
DECLARE
  v_definition text;
  v_old text := 'AND ch.user_id = auth.uid()';
  v_new text := 'AND priv.srd_can_control_campaign_character(ch.campaign_id, ch.id::text)';
  v_count integer;
BEGIN
  SELECT pg_get_functiondef(
    'priv.consumir_acao_turno_srd(bigint,text,text)'::regprocedure
  )
  INTO v_definition;

  v_count := (
    length(v_definition) - length(replace(v_definition, v_old, ''))
  ) / length(v_old);

  IF v_count <> 1 THEN
    RAISE EXCEPTION
      'Expected exactly one owner-only guard in priv.consumir_acao_turno_srd; found %. Refusing to patch an unknown function body.',
      v_count;
  END IF;

  v_definition := replace(v_definition, v_old, v_new);
  EXECUTE v_definition;
END
$migration$;

COMMIT;
