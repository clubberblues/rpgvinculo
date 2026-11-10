
DO $migration$
DECLARE
  v_definition text;
  v_old text := $old$
    COALESCE(SUM(COALESCE(eq.peso,0)*
      CASE WHEN POSITION('lb' IN LOWER(COALESCE(eq.detalhes->>'weight',''))) > 0
             OR eq.detalhes->>'source_dataset'='olimot/srd-v3.5-md'
           THEN 0.5 ELSE 1 END*GREATEST(1,ce.quantidade)),0),
$old$;
  v_new text := $new$
    COALESCE(SUM(COALESCE(eq.peso,0)*
      CASE WHEN eq.detalhes ? 'weight_lb'
             OR POSITION('lb' IN LOWER(COALESCE(eq.detalhes->>'weight',''))) > 0
             OR POSITION('lb' IN LOWER(COALESCE(eq.detalhes->>'weight_text',''))) > 0
             OR eq.detalhes->>'source_dataset'='olimot/srd-v3.5-md'
           THEN 0.5 ELSE 1 END*GREATEST(1,ce.quantidade)),0),
$new$;
BEGIN
  v_definition:=pg_get_functiondef('public.srd35_deslocamento_personagem(text,numeric)'::regprocedure);
  IF position(v_old in v_definition)=0 THEN
    RAISE EXCEPTION 'A expressão de conversão de peso mudou; migration abortada sem alterações.';
  END IF;
  v_definition:=replace(v_definition,v_old,v_new);
  EXECUTE v_definition;
END;
$migration$;
