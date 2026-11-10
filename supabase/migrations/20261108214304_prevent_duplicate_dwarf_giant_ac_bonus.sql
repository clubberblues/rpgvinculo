DO $migration$
DECLARE
  v_definition text;
  v_old text := $old$IF v_target->>'tipo'<>'player' AND v_actor_is_giant THEN$old$;
  v_new text := $new$IF v_target->>'tipo'<>'player'
     AND NOT (v_target->>'tipo'='npc' AND NULLIF(v_target->>'sourceCharacterId','') IS NOT NULL)
     AND v_actor_is_giant THEN$new$;
BEGIN
  v_definition := pg_get_functiondef('priv.npc_resolver_ataque_iterativo_impl(bigint,uuid)'::regprocedure);
  IF position(v_old in v_definition)=0 THEN
    RAISE EXCEPTION 'Trecho esperado não encontrado; migration abortada sem alteração.';
  END IF;
  IF (length(v_definition)-length(replace(v_definition,v_old,'')))/length(v_old) <> 1 THEN
    RAISE EXCEPTION 'Trecho esperado não é único; migration abortada sem alteração.';
  END IF;
  EXECUTE replace(v_definition,v_old,v_new);
END
$migration$;