-- Autoriza o Mestre a operar perícias, recursos de classe, salvamentos e poções de PCs.
-- O helper preserva o acesso do dono inclusive fora de campanhas.
BEGIN;
DO $migration$
DECLARE v_signature text; v_definition text; v_count integer; v_item record;
 v_pattern text; v_replacement text;
BEGIN
 IF to_regprocedure('priv.srd_can_control_character(text)') IS NULL THEN
  RAISE EXCEPTION 'Missing priv.srd_can_control_character(text).';
 END IF;
 FOR v_item IN SELECT signature,pattern,expected,replacement FROM (VALUES
  ('public.srd_resolve_requested_saving_throw_srd(bigint,text,text,integer)',
   'user_id\s*=\s*auth\.uid\(\)',1,'priv.srd_can_control_character(p_character_id)'),
  ('public.srd_validar_uso_pericia_srd(text,text)',
   'where\s+id::text\s*=\s*btrim\(p_character_id\)\s+and\s+user_id\s*=\s*auth\.uid\(\)',1,
   'WHERE id::text=BTRIM(p_character_id) AND priv.srd_can_control_character(p_character_id)'),
  ('public.usar_habilidade_classe_srd(text,text,text,integer)',
   'where\s+id::text\s*=\s*btrim\(p_character_id\)\s+and\s+user_id\s*=\s*auth\.uid\(\)',1,
   'WHERE id::text=BTRIM(p_character_id) AND priv.srd_can_control_character(p_character_id)'),
  ('public.usar_imposicao_maos_mortos_vivos_srd(text,text,integer,integer)',
   'where\s+id::text\s*=\s*btrim\(p_character_id\)\s+and\s+user_id\s*=\s*auth\.uid\(\)',1,
   'WHERE id::text=BTRIM(p_character_id) AND priv.srd_can_control_character(p_character_id)'),
  ('public.usar_pocao_cura_srd_manual(text,text,integer[])',
   'user_id\s*=\s*auth\.uid\(\)',2,'priv.srd_can_control_character(p_character_id)')
 ) AS targets(signature,pattern,expected,replacement)
 LOOP
  v_signature:=v_item.signature; v_pattern:=v_item.pattern; v_replacement:=v_item.replacement;
  IF to_regprocedure(v_signature) IS NULL THEN RAISE EXCEPTION 'Missing character action RPC: %',v_signature; END IF;
  SELECT pg_get_functiondef(to_regprocedure(v_signature)) INTO v_definition;
  v_count:=regexp_count(v_definition,v_pattern,1,'i');
  IF v_count<>v_item.expected THEN
   RAISE EXCEPTION 'Expected % owner checks in %, found %.',v_item.expected,v_signature,v_count;
  END IF;
  v_definition:=regexp_replace(v_definition,v_pattern,v_replacement,'gi');
  EXECUTE v_definition;
 END LOOP;
END
$migration$;
COMMIT;
