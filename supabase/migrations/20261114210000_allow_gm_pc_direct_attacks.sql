-- Permite ao Mestre resolver ataques simples com ficha de PC sem alterar ownership.
BEGIN;
DO $migration$
DECLARE v_signature text; v_definition text; v_count integer; v_item record;
 v_pattern text := 'ch\.user_id\s*=\s*v_user';
 v_replacement text := 'priv.srd_can_control_campaign_character(ch.campaign_id, ch.id::text)';
BEGIN
 IF to_regprocedure('priv.srd_can_control_campaign_character(bigint,text)') IS NULL THEN
  RAISE EXCEPTION 'Missing priv.srd_can_control_campaign_character(bigint,text).';
 END IF;
 FOR v_item IN SELECT signature FROM (VALUES
  ('public.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer)'),
  ('public.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer,integer,integer)')
 ) AS targets(signature)
 LOOP
  v_signature:=v_item.signature;
  IF to_regprocedure(v_signature) IS NULL THEN RAISE EXCEPTION 'Missing direct-attack function: %',v_signature; END IF;
  SELECT pg_get_functiondef(to_regprocedure(v_signature)) INTO v_definition;
  v_count:=regexp_count(v_definition,v_pattern,1,'i');
  IF v_count<>2 THEN RAISE EXCEPTION 'Expected exactly two ownership guards in %, found %.',v_signature,v_count; END IF;
  v_definition:=regexp_replace(v_definition,v_pattern,v_replacement,'gi');
  EXECUTE v_definition;
 END LOOP;
END
$migration$;
COMMIT;
