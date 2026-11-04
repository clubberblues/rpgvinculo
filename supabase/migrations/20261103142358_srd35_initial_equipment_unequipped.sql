CREATE OR REPLACE FUNCTION public.finalizar_equipamento_inicial_srd(p_character_id text, p_metodo text, p_resultados jsonb DEFAULT '[]'::jsonb, p_itens jsonb DEFAULT '[]'::jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_user UUID := auth.uid();
  v_character public.characters%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_package public.srd_starting_packages%ROWTYPE;
  v_items JSONB;
  v_item JSONB;
  v_equipment public.srd_equipment%ROWTYPE;
  v_class TEXT;
  v_dice INTEGER;
  v_multiplier NUMERIC;
  v_expected NUMERIC;
  v_roll_total INTEGER := 0;
  v_faces INTEGER[];
  v_qty INTEGER;
  v_cost NUMERIC := 0;
  v_remaining NUMERIC;
  v_slot TEXT;
  v_used_slots TEXT[] := ARRAY[]::TEXT[];
  v_equipped BOOLEAN;
  v_saved JSONB;
  v_face JSONB;
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT * INTO v_character FROM public.characters WHERE id::TEXT=BTRIM(p_character_id) AND user_id=v_user FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'A ficha não pertence a esta conta.'; END IF;
  SELECT * INTO v_sheet FROM public.srd_character_sheets WHERE character_id=v_character.id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'A ficha D&D 3.5 não existe.'; END IF;
  IF COALESCE(v_sheet.equipamento_inicial,'{}'::JSONB)->>'concluido'='true' THEN
    RETURN v_sheet.equipamento_inicial;
  END IF;

  v_class:=lower(COALESCE(v_sheet.classe_id,''));
  v_dice:=CASE WHEN v_class IN ('barbaro','bardo') THEN 4 WHEN v_class IN ('clerigo','ladino') THEN 5
    WHEN v_class='druida' THEN 2 WHEN v_class IN ('guerreiro','paladino','ranger','patrulheiro') THEN 6
    WHEN v_class='monge' THEN 5 WHEN v_class IN ('feiticeiro','sorcerer','mago','wizard') THEN 3 ELSE 0 END;
  v_multiplier:=CASE WHEN v_class='monge' THEN 1 ELSE 10 END;
  IF v_dice=0 THEN RAISE EXCEPTION 'A classe não possui regra de riqueza inicial cadastrada.'; END IF;
  v_expected:=v_dice*2.5*v_multiplier;

  IF p_metodo='pacote' THEN
    SELECT * INTO v_package FROM public.srd_starting_packages WHERE class_id=v_class;
    IF NOT FOUND THEN RAISE EXCEPTION 'Pacote da classe não cadastrado.'; END IF;
    v_items:=v_package.items;
  ELSIF p_metodo='ouro' THEN
    IF jsonb_typeof(COALESCE(p_resultados,'[]'::JSONB))<>'array'
      OR jsonb_array_length(COALESCE(p_resultados,'[]'::JSONB))<>v_dice THEN
      RAISE EXCEPTION 'A rolagem precisa conter % dados de quatro faces.',v_dice;
    END IF;
    FOR v_face IN SELECT value FROM jsonb_array_elements(p_resultados) LOOP
      IF COALESCE(v_face#>>'{}','') !~ '^[1-4]$' THEN RAISE EXCEPTION 'Cada resultado de d4 deve estar entre 1 e 4.'; END IF;
      v_roll_total:=v_roll_total+(v_face#>>'{}')::INTEGER;
    END LOOP;
    v_expected:=v_roll_total*v_multiplier;
    v_items:=COALESCE(p_itens,'[]'::JSONB);
  ELSE
    RAISE EXCEPTION 'Escolha o pacote da classe ou a compra com ouro.';
  END IF;

  IF jsonb_typeof(v_items)<>'array' THEN RAISE EXCEPTION 'Lista de itens inválida.'; END IF;
  IF jsonb_array_length(v_items)>60 THEN RAISE EXCEPTION 'A lista de itens excede o limite permitido.'; END IF;

  FOR v_item IN SELECT value FROM jsonb_array_elements(v_items) LOOP
    IF COALESCE(v_item->>'id','')='' OR COALESCE(v_item->>'quantidade','') !~ '^[1-9][0-9]{0,2}$' THEN
      RAISE EXCEPTION 'Um item inicial possui ID ou quantidade inválida.';
    END IF;
    v_qty:=(v_item->>'quantidade')::INTEGER;
    SELECT * INTO v_equipment FROM public.srd_equipment WHERE id=v_item->>'id';
    IF NOT FOUND THEN RAISE EXCEPTION 'Item inicial % não está no catálogo.',v_item->>'id'; END IF;
    IF lower(COALESCE(v_equipment.categoria,'')) IN ('rings','rods','staffs','wands','wondrous_items','potions_and_oils')
      OR lower(COALESCE(v_equipment.categoria,'')) LIKE 'specific_%'
      OR lower(COALESCE(v_equipment.categoria,''))='specific_cursed_items' THEN
      RAISE EXCEPTION 'Itens mágicos não fazem parte das compras iniciais de 1º nível.';
    END IF;
    IF COALESCE(v_equipment.custo_po,v_equipment.preco) IS NULL THEN
      RAISE EXCEPTION 'O item % está sem preço cadastrado.',v_equipment.nome;
    END IF;
    v_cost:=v_cost+COALESCE(v_equipment.custo_po,v_equipment.preco)*v_qty;
  END LOOP;

  IF v_cost>v_expected THEN
    RAISE EXCEPTION 'O pacote/compras custam % po, acima do limite de % po.',v_cost,v_expected;
  END IF;
  v_remaining:=GREATEST(0,v_expected-v_cost);
  FOREACH v_face IN ARRAY ARRAY[]::JSONB[] LOOP NULL; END LOOP;
  v_faces:=ARRAY[]::INTEGER[];
  IF p_metodo='ouro' THEN
    SELECT array_agg((value#>>'{}')::INTEGER ORDER BY ordinality) INTO v_faces
    FROM jsonb_array_elements(p_resultados) WITH ORDINALITY;
  END IF;

  FOR v_item IN SELECT value FROM jsonb_array_elements(v_items) LOOP
    SELECT * INTO v_equipment FROM public.srd_equipment WHERE id=v_item->>'id';
    -- Initial equipment always enters the backpack unequipped.
    -- The player decides which weapon, armor and shield to equip after creation.
    v_slot:=public.srd35_equipment_slot(v_equipment.categoria,v_equipment.nome);
    v_equipped:=FALSE;
    INSERT INTO public.srd_character_equipment(character_id,equipment_id,quantidade,equipado)
    VALUES(v_character.id::TEXT,v_equipment.id,(v_item->>'quantidade')::INTEGER,v_equipped)
    ON CONFLICT(character_id,equipment_id) DO UPDATE SET
      quantidade=public.srd_character_equipment.quantidade+EXCLUDED.quantidade,
      equipado=public.srd_character_equipment.equipado OR EXCLUDED.equipado;
  END LOOP;

  v_saved:=jsonb_build_object('concluido',TRUE,'metodo',p_metodo,'resultados',to_jsonb(v_faces),
    'ouro_inicial',v_expected,'valor_itens',v_cost,'ouro_restante',v_remaining,
    'pacote_id',CASE WHEN p_metodo='pacote' THEN v_class ELSE NULL END,'itens',v_items);
  UPDATE public.srd_character_sheets SET ouro=v_remaining,equipamento_inicial=v_saved
  WHERE character_id=v_character.id;
  UPDATE public.characters SET ouro=FLOOR(v_remaining)::INTEGER WHERE id=v_character.id;
  RETURN v_saved;
END;
$function$
