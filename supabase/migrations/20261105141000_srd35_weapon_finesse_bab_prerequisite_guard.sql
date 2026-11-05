-- Enforce Weapon Finesse's SRD base attack bonus +1 prerequisite in the
-- authoritative attack resolver, even if an invalid sheet contains the feat.

DO $migration$
DECLARE
  v_function RECORD;
  v_definition TEXT;
  v_old TEXT := $old$IF v_has_finesse AND (v_weapon.id IS NULL OR COALESCE(v_weapon.detalhes->>'weapon_finesse_eligible','false')='true') THEN v_ability_key:='DES'; ELSE v_ability_key:='FOR'; END IF;$old$;
  v_new TEXT := $new$IF v_has_finesse AND v_bab<1 THEN RAISE EXCEPTION 'Acuidade com Arma exige bônus base de ataque +1.'; END IF;
 IF v_has_finesse AND (v_weapon.id IS NULL OR COALESCE(v_weapon.detalhes->>'weapon_finesse_eligible','false')='true') THEN v_ability_key:='DES'; ELSE v_ability_key:='FOR'; END IF;$new$;
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
      RAISE EXCEPTION 'Ponto de validação de Acuidade com Arma não encontrado na função %.',v_function.oid::regprocedure;
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
