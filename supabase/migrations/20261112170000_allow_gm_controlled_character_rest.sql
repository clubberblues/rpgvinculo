-- The approved rest workflow is initiated by the GM from a selected token.
-- Preserve all SRD rest checks; only permit the campaign GM to operate on a
-- character owned by another player. Character ownership is never transferred.
BEGIN;

DO $migration$
DECLARE
  v_definition text;
  v_old text := 'IF v_owner IS DISTINCT FROM auth.uid() THEN';
  v_new text := 'IF v_owner IS DISTINCT FROM auth.uid() AND public.my_role(p_campaign_id) IS DISTINCT FROM ''GM'' THEN';
BEGIN
  SELECT pg_get_functiondef(
    'public.descanso_longo_personagem_srd(bigint,text)'::regprocedure
  ) INTO v_definition;

  IF position(v_old IN v_definition) = 0 THEN
    RAISE EXCEPTION 'Expected owner-only guard not found in descanso_longo_personagem_srd; refusing to patch an unknown definition.';
  END IF;

  v_definition := replace(v_definition, v_old, v_new);
  EXECUTE v_definition;
END
$migration$;

COMMIT;
