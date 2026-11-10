DO $migration$
DECLARE v_definition text;
BEGIN
  v_definition:=pg_get_functiondef('public.usar_furia_barbaro_npc_srd(bigint,text,text)'::regprocedure);
  IF position($old$  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha de origem não encontrada.'; END IF;
  SELECT * INTO v_sheet FROM public.srd_character_sheets WHERE character_id=v_character.id FOR UPDATE;$old$ in v_definition)=0 THEN
    RAISE EXCEPTION 'Ponto de validação da Fúria NPC não encontrado.';
  END IF;
  v_definition:=replace(v_definition,
    $old$  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha de origem não encontrada.'; END IF;
  SELECT * INTO v_sheet FROM public.srd_character_sheets WHERE character_id=v_character.id FOR UPDATE;$old$,
    $new$  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha de origem não encontrada.'; END IF;
  IF v_character.user_id IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'O Mestre só pode controlar recursos da ficha NPC que pertence à sua própria conta.';
  END IF;
  SELECT * INTO v_sheet FROM public.srd_character_sheets WHERE character_id=v_character.id FOR UPDATE;$new$);
  EXECUTE v_definition;

  v_definition:=pg_get_functiondef('priv.descanso_longo_npc_vinculado_srd_impl(bigint,text)'::regprocedure);
  IF position($old$ IF NOT FOUND THEN RAISE EXCEPTION 'Ficha de origem do NPC não encontrada.'; END IF;
 SELECT * INTO v_sheet FROM public.srd_character_sheets WHERE character_id=v_character.id FOR UPDATE;$old$ in v_definition)=0 THEN
    RAISE EXCEPTION 'Ponto de validação do descanso NPC não encontrado.';
  END IF;
  v_definition:=replace(v_definition,
    $old$ IF NOT FOUND THEN RAISE EXCEPTION 'Ficha de origem do NPC não encontrada.'; END IF;
 SELECT * INTO v_sheet FROM public.srd_character_sheets WHERE character_id=v_character.id FOR UPDATE;$old$,
    $new$ IF NOT FOUND THEN RAISE EXCEPTION 'Ficha de origem do NPC não encontrada.'; END IF;
 IF v_character.user_id IS DISTINCT FROM auth.uid() THEN
   RAISE EXCEPTION 'O Mestre só pode controlar recursos da ficha NPC que pertence à sua própria conta.';
 END IF;
 SELECT * INTO v_sheet FROM public.srd_character_sheets WHERE character_id=v_character.id FOR UPDATE;$new$);
  EXECUTE v_definition;
END
$migration$;