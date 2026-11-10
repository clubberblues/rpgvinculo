DO $migration$
DECLARE
  v_definition text;
  v_old text := 'IF v_barbarian_level>=1 AND NOT v_heavy_armor AND v_load<>''heavy'' THEN';
  v_new text := 'IF v_barbarian_level>=1 AND NOT v_medium_heavy_armor AND v_load<>''heavy'' THEN';
BEGIN
  v_definition := pg_get_functiondef('public.srd35_deslocamento_personagem(text,numeric)'::regprocedure);
  IF position(v_old in v_definition)=0 THEN
    RAISE EXCEPTION 'Não foi possível localizar a condição original de deslocamento rápido; migration cancelada.';
  END IF;
  IF position(v_new in v_definition)>0 THEN
    RAISE NOTICE 'A condição corrigida já está presente.';
    RETURN;
  END IF;
  v_definition := replace(v_definition,v_old,v_new);
  EXECUTE v_definition;
END
$migration$;