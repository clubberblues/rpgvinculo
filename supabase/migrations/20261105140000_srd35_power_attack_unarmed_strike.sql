-- D&D 3.5 Power Attack also applies to unarmed strikes and natural weapons.
-- The previous guard incorrectly rejected every attack with no equipment row,
-- even though the SRD explicitly permits Power Attack with unarmed strikes.

DO $migration$
DECLARE
  v_function RECORD;
  v_definition TEXT;
  v_old TEXT := $old$OR v_weapon.id IS NULL OR COALESCE(v_weapon.detalhes->>'weapon_light','false')='true'$old$;
  v_new TEXT := $new$OR (v_weapon.id IS NOT NULL AND COALESCE(v_weapon.detalhes->>'weapon_light','false')='true'$new$;
  v_updated INTEGER := 0;
BEGIN
  FOR v_function IN
    SELECT p.oid
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='public'
      AND p.proname='aplicar_dano_token_ataque_srd_v2'
  LOOP
    v_definition := pg_get_functiondef(v_function.oid);
    IF position(v_old IN v_definition)=0 THEN
      RAISE EXCEPTION 'Guard de Ataque Poderoso não encontrado na função %.',v_function.oid::regprocedure;
    END IF;
    v_definition := replace(v_definition,v_old,v_new);
    EXECUTE v_definition;
    v_updated := v_updated+1;
  END LOOP;

  IF v_updated=0 THEN
    RAISE EXCEPTION 'Nenhuma versão de aplicar_dano_token_ataque_srd_v2 foi encontrada.';
  END IF;
END;
$migration$;

NOTIFY pgrst, 'reload schema';
