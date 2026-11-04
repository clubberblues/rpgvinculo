DO $migration$
DECLARE
  r record;
  v_def text;
  v_old text;
  v_replacement text;
BEGIN
  -- Livro do Jogador 3.5, Cap. 2: Halfling recebe +1 nos ataques com armas
  -- de arremesso e fundas. A regra é aplicada no cálculo e na validação do servidor.
  FOR r IN
    SELECT p.oid
      FROM pg_proc p
      JOIN pg_namespace n ON n.oid=p.pronamespace
     WHERE n.nspname='public'
       AND p.proname='aplicar_dano_token_ataque_srd_v2'
       AND p.prokind='f'
  LOOP
    v_def:=pg_get_functiondef(r.oid);
    v_old:=$old$
ELSIF v_sheet.raca_id='gnomo'
   AND v_target_traits ~ '(kobold|goblin|hobgoblin|bugbear|goblinoid)' THEN
  v_racial_attack_bonus:=1;
END IF;
$old$;
    v_replacement:=$new$
ELSIF v_sheet.raca_id='gnomo'
   AND v_target_traits ~ '(kobold|goblin|hobgoblin|bugbear|goblinoid)' THEN
  v_racial_attack_bonus:=1;
ELSIF v_sheet.raca_id='halfling'
   AND p_attack_type='atk-dist'
   AND (
     COALESCE(v_weapon.detalhes->>'weapon_ranged_type','')='thrown'
     OR lower(COALESCE(v_weapon.nome,''))='funda'
   ) THEN
  v_racial_attack_bonus:=1;
END IF;
$new$;
    IF position(v_old in v_def)>0 THEN
      EXECUTE replace(v_def,v_old,v_replacement);
    ELSIF position('v_sheet.raca_id=''halfling''' in v_def)=0 THEN
      RAISE EXCEPTION 'Não foi possível inserir o bônus de ataque do Halfling no overload %.',r.oid::regprocedure;
    END IF;
  END LOOP;
END
$migration$;