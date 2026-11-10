
DO $migration$
DECLARE
  v_def text;
  v_old text;
  v_new text;
BEGIN
  v_def:=pg_get_functiondef('priv.npc_consultar_ataque_iterativo_impl(bigint,text,text)'::regprocedure);
  v_old:=$old$    'eligible',v_bab>=6,
    'reason',case when v_bab<6 then 'bab_below_6' when jsonb_array_length(v_weapons)=0 then 'no_equipped_weapon' else null end,$old$;
  v_new:=$new$    'eligible',v_bab>=1,
    'reason',case when v_bab<1 then 'bab_below_1' when jsonb_array_length(v_weapons)=0 then 'no_equipped_weapon' else null end,$new$;
  IF position(v_old in v_def)=0 THEN RAISE EXCEPTION 'Regra de elegibilidade BBA do perfil NPC não corresponde ao esperado.'; END IF;
  v_def:=replace(v_def,v_old,v_new);
  EXECUTE v_def;
END
$migration$;
