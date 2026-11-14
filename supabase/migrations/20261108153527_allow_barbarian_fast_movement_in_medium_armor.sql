
DO $migration$
DECLARE v_def text;v_old text;v_new text;v_count integer;
BEGIN
 v_def:=pg_get_functiondef('public.srd35_deslocamento_personagem(text,numeric)'::regprocedure);
 v_old:='IF v_barbarian_level>=1 AND NOT v_medium_heavy_armor AND v_load<>''heavy'' THEN';
 v_new:='IF v_barbarian_level>=1 AND NOT v_heavy_armor AND v_load<>''heavy'' THEN';
 v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
 IF v_count<>1 THEN RAISE EXCEPTION 'Regra de armadura do Deslocamento Rápido não é única: %.',v_count; END IF;
 v_def:=replace(v_def,v_old,v_new);
 v_old:='-- Barbarian Fast Movement: +3 m with light/no armor; medium load is';
 v_new:='-- Barbarian Fast Movement: +3 m with no/light/medium armor; medium load is';
 v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
 IF v_count<>1 THEN RAISE EXCEPTION 'Comentário de Deslocamento Rápido não é único: %.',v_count; END IF;
 v_def:=replace(v_def,v_old,v_new);
 v_old:='-- allowed, but medium/heavy armor and heavy load suppress the bonus.';
 v_new:='-- allowed; heavy armor and heavy load suppress the bonus.';
 v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
 IF v_count<>1 THEN RAISE EXCEPTION 'Comentário de restrição do Deslocamento Rápido não é único: %.',v_count; END IF;
 v_def:=replace(v_def,v_old,v_new);
 EXECUTE v_def;
END;
$migration$;
