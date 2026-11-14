-- Permite ao Mestre conjurar magias usando a ficha do PC ativo na campanha.
-- A validação de espaços, condições, alvos e resolução permanece no motor existente.
BEGIN;
DO $migration$
DECLARE v_signature text; v_definition text; v_count integer; v_item record;
 v_pattern text; v_replacement text;
BEGIN
 IF to_regprocedure('priv.srd_can_control_character(text)') IS NULL THEN
  RAISE EXCEPTION 'Missing priv.srd_can_control_character(text).';
 END IF;
 FOR v_item IN SELECT signature,pattern,replacement FROM (VALUES
  ('public.conjurar_magia_com_acao_srd_manual(text,text,smallint,text,integer[])',
   'ch\.user_id\s*=\s*auth\.uid\(\)','priv.srd_can_control_character(ch.id::text)'),
  ('public.conjurar_magia_com_acao_srd_multialvo_v3(text,text,smallint,text[],integer[])',
   'ch\.user_id\s*=\s*auth\.uid\(\)','priv.srd_can_control_character(ch.id::text)'),
  ('public.conjurar_magia_dano_multialvo_srd(text,text,smallint,text[],integer[])',
   'ch\.user_id\s*=\s*auth\.uid\(\)','priv.srd_can_control_character(ch.id::text)'),
  ('public.conjurar_magia_efeitos_multialvo(text,text,smallint,text[])',
   'ch\.user_id\s*=\s*auth\.uid\(\)','priv.srd_can_control_character(ch.id::text)'),
  ('public.conjurar_magia_srd_manual(text,text,smallint,text,integer[])',
   'c\.user_id\s*=\s*auth\.uid\(\)','priv.srd_can_control_character(c.id::text)'),
  ('public.conjurar_magia_srd_multialvo_v3(text,text,smallint,text[],integer[])',
   'ch\.user_id\s*=\s*auth\.uid\(\)','priv.srd_can_control_character(ch.id::text)'),
  ('priv.conjurar_missil_magico_srd_manual(text,text,smallint,text,integer[])',
   'ch\.user_id\s*=\s*auth\.uid\(\)','priv.srd_can_control_character(ch.id::text)')
 ) AS targets(signature,pattern,replacement)
 LOOP
  v_signature:=v_item.signature; v_pattern:=v_item.pattern; v_replacement:=v_item.replacement;
  IF to_regprocedure(v_signature) IS NULL THEN RAISE EXCEPTION 'Missing spellcasting RPC: %',v_signature; END IF;
  SELECT pg_get_functiondef(to_regprocedure(v_signature)) INTO v_definition;
  v_count:=regexp_count(v_definition,v_pattern,1,'i');
  IF v_count<>1 THEN RAISE EXCEPTION 'Expected one caster ownership guard in %, found %.',v_signature,v_count; END IF;
  v_definition:=regexp_replace(v_definition,v_pattern,v_replacement,'gi');
  EXECUTE v_definition;
 END LOOP;
END
$migration$;
COMMIT;
