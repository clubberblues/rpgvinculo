DO $migration$
DECLARE v_oid oid; v_def text; v_old text; v_new text; v_count integer:=0;
BEGIN
 v_old:='v_attack_total:=p_d20+v_expected_bonus+v_effective_attack_modifier;';
 v_new:='v_attack_total:=p_d20+p_bonus_ataque+v_effective_attack_modifier;';
 FOR v_oid IN
   SELECT p.oid FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
   WHERE n.nspname='public' AND p.proname='aplicar_dano_token_ataque_srd_v2' AND p.pronargs IN (9,11)
 LOOP
   v_def:=pg_get_functiondef(v_oid);
   IF position(v_new in v_def)>0 THEN
     CONTINUE;
   END IF;
   IF position(v_old in v_def)=0 THEN
     RAISE EXCEPTION 'Expressão de total de ataque não encontrada no overload %.',pg_get_function_identity_arguments(v_oid);
   END IF;
   EXECUTE replace(v_def,v_old,v_new);
   v_count:=v_count+1;
 END LOOP;
 IF v_count=0 AND NOT EXISTS (
   SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
   WHERE n.nspname='public' AND p.proname='aplicar_dano_token_ataque_srd_v2' AND p.pronargs IN (9,11)
     AND position(v_new in pg_get_functiondef(p.oid))>0
 ) THEN
   RAISE EXCEPTION 'Nenhum overload atualizado ou já corrigido.';
 END IF;
END;
$migration$;