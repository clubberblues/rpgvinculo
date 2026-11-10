
DO $migration$
DECLARE
  v_oid oid := 'public.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer,integer,integer)'::regprocedure;
  v_def text;
  v_old text := $old$   IF p_attack_type='atk-dist' AND v_distance_squares>6 THEN RAISE EXCEPTION 'Ataque Furtivo à distância exige até 9 metros.';
   END IF;$old$;
  v_anchor text := $anchor$v_distance_squares:=GREATEST(v_dx,v_dy)+FLOOR(LEAST(v_dx,v_dy)::NUMERIC/2)::INTEGER;$anchor$;
  v_new text;
BEGIN
  v_def := pg_get_functiondef(v_oid);
  IF position(v_old in v_def)=0 OR position(v_anchor in v_def)=0 THEN
    RAISE EXCEPTION 'Estrutura inesperada no resolvedor; migração cancelada sem alteração.';
  END IF;
  v_def := replace(v_def,v_old,'');
  v_new := v_anchor || E'\n IF p_attack_type=''atk-dist'' AND COALESCE(p_sneak_attack_dice,0)>0 AND v_distance_squares>6 THEN RAISE EXCEPTION ''Ataque Furtivo à distância exige até 9 metros.''; END IF;';
  v_def := replace(v_def,v_anchor,v_new);
  EXECUTE v_def;
END
$migration$;
