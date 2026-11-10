
DO $migration$
DECLARE
  v_definition text;
  v_updated text;
  v_old text := $old$AND COALESCE(eq.bonus_max_des,eq.max_des,0)<=3$old$;
  v_new text := $new$AND (
                COALESCE(eq.bonus_max_des,eq.max_des,0)<=3
                OR lower(COALESCE(eq.nome,'')) LIKE '%peles%'
              )$new$;
BEGIN
  SELECT pg_get_functiondef('public.srd_resolve_pending_spell_save(uuid,integer)'::regprocedure)
    INTO v_definition;
  IF position(v_old IN v_definition)=0 THEN
    RAISE EXCEPTION 'Trecho esperado da regra de armadura não encontrado; migração cancelada.';
  END IF;
  IF position(v_old IN substring(v_definition FROM position(v_old IN v_definition)+length(v_old)))>0 THEN
    RAISE EXCEPTION 'Trecho da regra de armadura aparece mais de uma vez; migração cancelada.';
  END IF;
  v_updated := replace(v_definition,v_old,v_new);
  EXECUTE v_updated;
END
$migration$;
