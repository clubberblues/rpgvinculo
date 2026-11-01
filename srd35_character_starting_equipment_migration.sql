-- D&D 3.5: escolha do equipamento inicial na criação da ficha.
-- Executada no projeto Supabase Vínculo em 01/11/2026.
ALTER TABLE public.srd_character_sheets
  ADD COLUMN IF NOT EXISTS equipamento_inicial jsonb NOT NULL DEFAULT '{}'::jsonb;

CREATE TABLE IF NOT EXISTS public.srd_starting_packages (
  class_id text PRIMARY KEY,
  nome text NOT NULL,
  items jsonb NOT NULL CHECK (jsonb_typeof(items) = 'array'),
  observacao text NOT NULL DEFAULT ''
);
ALTER TABLE public.srd_starting_packages ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS srd_starting_packages_read ON public.srd_starting_packages;
CREATE POLICY srd_starting_packages_read ON public.srd_starting_packages
  FOR SELECT TO authenticated USING (true);
GRANT SELECT ON public.srd_starting_packages TO authenticated;

INSERT INTO public.srd_starting_packages(class_id,nome,items,observacao) VALUES
('barbaro','Kit do Bárbaro','[{"id":"machado_grande","quantidade":1},{"id":"armadura_couro","quantidade":1},{"id":"mochila","quantidade":1},{"id":"cantil","quantidade":1},{"id":"pederneira","quantidade":1},{"id":"saco_dormir","quantidade":1},{"id":"srd35_equipment_gear_rations_trail_per_day","quantidade":2},{"id":"srd35_equipment_gear_explorer_s_outfit","quantidade":1}]','Sugestão inicial do Vínculo baseada nas opções e preços do catálogo D&D 3.5.'),
('bardo','Kit do Bardo','[{"id":"rapieira","quantidade":1},{"id":"armadura_couro","quantidade":1},{"id":"srd35_equipment_gear_musical_instrument_common","quantidade":1},{"id":"mochila","quantidade":1},{"id":"cantil","quantidade":1},{"id":"pederneira","quantidade":1},{"id":"saco_dormir","quantidade":1},{"id":"srd35_equipment_gear_rations_trail_per_day","quantidade":2},{"id":"srd35_equipment_gear_explorer_s_outfit","quantidade":1}]','Sugestão inicial do Vínculo baseada nas opções e preços do catálogo D&D 3.5.'),
('clerigo','Kit do Clérigo','[{"id":"maca_pesada","quantidade":1},{"id":"armadura_couro","quantidade":1},{"id":"escudo_pesado_madeira","quantidade":1},{"id":"mochila","quantidade":1},{"id":"cantil","quantidade":1},{"id":"pederneira","quantidade":1},{"id":"saco_dormir","quantidade":1},{"id":"srd35_equipment_gear_rations_trail_per_day","quantidade":2},{"id":"srd35_equipment_gear_explorer_s_outfit","quantidade":1}]','Sugestão inicial do Vínculo baseada nas opções e preços do catálogo D&D 3.5.'),
('druida','Kit da Druida','[{"id":"cimitarra","quantidade":1},{"id":"armadura_couro","quantidade":1},{"id":"escudo_leve_madeira","quantidade":1},{"id":"mochila","quantidade":1},{"id":"cantil","quantidade":1},{"id":"pederneira","quantidade":1},{"id":"saco_dormir","quantidade":1},{"id":"srd35_equipment_gear_rations_trail_per_day","quantidade":2},{"id":"srd35_equipment_gear_explorer_s_outfit","quantidade":1}]','Sugestão inicial do Vínculo baseada nas opções e preços do catálogo D&D 3.5.'),
('feiticeiro','Kit do Feiticeiro','[{"id":"besta_leve","quantidade":1},{"id":"adaga","quantidade":1},{"id":"srd35_equipment_gear_spell_component_pouch","quantidade":1},{"id":"mochila","quantidade":1},{"id":"cantil","quantidade":1},{"id":"pederneira","quantidade":1},{"id":"saco_dormir","quantidade":1},{"id":"srd35_equipment_gear_rations_trail_per_day","quantidade":2},{"id":"srd35_equipment_gear_explorer_s_outfit","quantidade":1}]','Sugestão inicial do Vínculo baseada nas opções e preços do catálogo D&D 3.5.'),
('guerreiro','Kit do Guerreiro','[{"id":"espada_longa","quantidade":1},{"id":"armadura_couro","quantidade":1},{"id":"escudo_pesado_madeira","quantidade":1},{"id":"arco_curto","quantidade":1},{"id":"mochila","quantidade":1},{"id":"cantil","quantidade":1},{"id":"pederneira","quantidade":1},{"id":"saco_dormir","quantidade":1},{"id":"srd35_equipment_gear_rations_trail_per_day","quantidade":2},{"id":"srd35_equipment_gear_explorer_s_outfit","quantidade":1}]','Sugestão inicial do Vínculo baseada nas opções e preços do catálogo D&D 3.5.'),
('ladino','Kit do Ladino','[{"id":"espada_curta","quantidade":1},{"id":"armadura_couro","quantidade":1},{"id":"kit_ladrao","quantidade":1},{"id":"arco_curto","quantidade":1},{"id":"mochila","quantidade":1},{"id":"cantil","quantidade":1},{"id":"pederneira","quantidade":1},{"id":"saco_dormir","quantidade":1},{"id":"srd35_equipment_gear_rations_trail_per_day","quantidade":2},{"id":"srd35_equipment_gear_explorer_s_outfit","quantidade":1}]','Sugestão inicial do Vínculo baseada nas opções e preços do catálogo D&D 3.5.'),
('mago','Kit do Mago','[{"id":"bordao","quantidade":1},{"id":"adaga","quantidade":1},{"id":"srd35_equipment_gear_spellbook_wizard_s_blank","quantidade":1},{"id":"srd35_equipment_gear_spell_component_pouch","quantidade":1},{"id":"mochila","quantidade":1},{"id":"cantil","quantidade":1},{"id":"pederneira","quantidade":1},{"id":"saco_dormir","quantidade":1},{"id":"srd35_equipment_gear_rations_trail_per_day","quantidade":2},{"id":"srd35_equipment_gear_explorer_s_outfit","quantidade":1}]','Sugestão inicial do Vínculo baseada nas opções e preços do catálogo D&D 3.5.'),
('monge','Kit do Monge','[{"id":"bordao","quantidade":1},{"id":"funda","quantidade":1},{"id":"mochila","quantidade":1},{"id":"cantil","quantidade":1},{"id":"pederneira","quantidade":1},{"id":"saco_dormir","quantidade":1},{"id":"srd35_equipment_gear_rations_trail_per_day","quantidade":2},{"id":"srd35_equipment_gear_monk_s_outfit","quantidade":1}]','Sugestão inicial do Vínculo baseada nas opções e preços do catálogo D&D 3.5.'),
('paladino','Kit do Paladino','[{"id":"espada_longa","quantidade":1},{"id":"armadura_couro","quantidade":1},{"id":"escudo_pesado_madeira","quantidade":1},{"id":"arco_curto","quantidade":1},{"id":"mochila","quantidade":1},{"id":"cantil","quantidade":1},{"id":"pederneira","quantidade":1},{"id":"saco_dormir","quantidade":1},{"id":"srd35_equipment_gear_rations_trail_per_day","quantidade":2},{"id":"srd35_equipment_gear_explorer_s_outfit","quantidade":1}]','Sugestão inicial do Vínculo baseada nas opções e preços do catálogo D&D 3.5.'),
('ranger','Kit do Ranger','[{"id":"arco_longo","quantidade":1},{"id":"espada_curta","quantidade":1},{"id":"armadura_couro","quantidade":1},{"id":"mochila","quantidade":1},{"id":"cantil","quantidade":1},{"id":"pederneira","quantidade":1},{"id":"saco_dormir","quantidade":1},{"id":"srd35_equipment_gear_rations_trail_per_day","quantidade":2},{"id":"srd35_equipment_gear_explorer_s_outfit","quantidade":1}]','Sugestão inicial do Vínculo baseada nas opções e preços do catálogo D&D 3.5.')
ON CONFLICT(class_id) DO UPDATE SET nome=EXCLUDED.nome,items=EXCLUDED.items,observacao=EXCLUDED.observacao;

CREATE OR REPLACE FUNCTION public.finalizar_equipamento_inicial_srd(
  p_character_id text,p_metodo text,p_resultados jsonb DEFAULT '[]'::jsonb,p_itens jsonb DEFAULT '[]'::jsonb
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'pg_catalog','public'
AS $function$
DECLARE
  v_user uuid:=auth.uid(); v_character public.characters%ROWTYPE; v_sheet public.srd_character_sheets%ROWTYPE;
  v_package public.srd_starting_packages%ROWTYPE; v_items jsonb; v_item jsonb; v_equipment public.srd_equipment%ROWTYPE;
  v_class text; v_dice integer; v_multiplier numeric; v_expected numeric; v_roll_total integer:=0;
  v_faces integer[]; v_qty integer; v_cost numeric:=0; v_remaining numeric; v_slot text;
  v_used_slots text[]:=ARRAY[]::text[]; v_equipped boolean; v_saved jsonb; v_face jsonb;
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT * INTO v_character FROM public.characters WHERE id::text=btrim(p_character_id) AND user_id=v_user FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'A ficha não pertence a esta conta.'; END IF;
  SELECT * INTO v_sheet FROM public.srd_character_sheets WHERE character_id=v_character.id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'A ficha D&D 3.5 não existe.'; END IF;
  IF COALESCE(v_sheet.equipamento_inicial,'{}'::jsonb)->>'concluido'='true' THEN RETURN v_sheet.equipamento_inicial; END IF;
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
    IF jsonb_typeof(COALESCE(p_resultados,'[]'::jsonb))<>'array' OR jsonb_array_length(COALESCE(p_resultados,'[]'::jsonb))<>v_dice
      THEN RAISE EXCEPTION 'A rolagem precisa conter % dados de quatro faces.',v_dice; END IF;
    FOR v_face IN SELECT value FROM jsonb_array_elements(p_resultados) LOOP
      IF COALESCE(v_face#>>'{}','') !~ '^[1-4]$' THEN RAISE EXCEPTION 'Cada resultado de d4 deve estar entre 1 e 4.'; END IF;
      v_roll_total:=v_roll_total+(v_face#>>'{}')::integer;
    END LOOP;
    v_expected:=v_roll_total*v_multiplier; v_items:=COALESCE(p_itens,'[]'::jsonb);
  ELSE RAISE EXCEPTION 'Escolha o pacote da classe ou a compra com ouro.'; END IF;
  IF jsonb_typeof(v_items)<>'array' THEN RAISE EXCEPTION 'Lista de itens inválida.'; END IF;
  IF jsonb_array_length(v_items)>60 THEN RAISE EXCEPTION 'A lista de itens excede o limite permitido.'; END IF;
  FOR v_item IN SELECT value FROM jsonb_array_elements(v_items) LOOP
    IF COALESCE(v_item->>'id','')='' OR COALESCE(v_item->>'quantidade','') !~ '^[1-9][0-9]{0,2}$' THEN RAISE EXCEPTION 'Um item inicial possui ID ou quantidade inválida.'; END IF;
    v_qty:=(v_item->>'quantidade')::integer;
    SELECT * INTO v_equipment FROM public.srd_equipment WHERE id=v_item->>'id';
    IF NOT FOUND THEN RAISE EXCEPTION 'Item inicial % não está no catálogo.',v_item->>'id'; END IF;
    IF lower(COALESCE(v_equipment.categoria,'')) IN ('rings','rods','staffs','wands','wondrous_items','potions_and_oils') OR lower(COALESCE(v_equipment.categoria,'')) LIKE 'specific_%' OR lower(COALESCE(v_equipment.categoria,''))='specific_cursed_items'
      THEN RAISE EXCEPTION 'Itens mágicos não fazem parte das compras iniciais de 1º nível.'; END IF;
    IF COALESCE(v_equipment.custo_po,v_equipment.preco) IS NULL THEN RAISE EXCEPTION 'O item % está sem preço cadastrado.',v_equipment.nome; END IF;
    v_cost:=v_cost+COALESCE(v_equipment.custo_po,v_equipment.preco)*v_qty;
  END LOOP;
  IF v_cost>v_expected THEN RAISE EXCEPTION 'O pacote/compras custam % po, acima do limite de % po.',v_cost,v_expected; END IF;
  v_remaining:=GREATEST(0,v_expected-v_cost); v_faces:=ARRAY[]::integer[];
  IF p_metodo='ouro' THEN SELECT array_agg((value#>>'{}')::integer ORDER BY ordinality) INTO v_faces FROM jsonb_array_elements(p_resultados) WITH ORDINALITY; END IF;
  FOR v_item IN SELECT value FROM jsonb_array_elements(v_items) LOOP
    SELECT * INTO v_equipment FROM public.srd_equipment WHERE id=v_item->>'id';
    v_slot:=public.srd35_equipment_slot(v_equipment.categoria,v_equipment.nome); v_equipped:=false;
    IF v_slot IN ('arma','armadura','escudo') AND NOT (v_slot=ANY(v_used_slots)) THEN v_equipped:=true;v_used_slots:=array_append(v_used_slots,v_slot); END IF;
    INSERT INTO public.srd_character_equipment(character_id,equipment_id,quantidade,equipado)
      VALUES(v_character.id::text,v_equipment.id,(v_item->>'quantidade')::integer,v_equipped)
      ON CONFLICT(character_id,equipment_id) DO UPDATE SET quantidade=public.srd_character_equipment.quantidade+EXCLUDED.quantidade,equipado=public.srd_character_equipment.equipado OR EXCLUDED.equipado;
  END LOOP;
  v_saved:=jsonb_build_object('concluido',true,'metodo',p_metodo,'resultados',to_jsonb(v_faces),'ouro_inicial',v_expected,'valor_itens',v_cost,'ouro_restante',v_remaining,'pacote_id',CASE WHEN p_metodo='pacote' THEN v_class ELSE NULL END,'itens',v_items);
  UPDATE public.srd_character_sheets SET ouro=v_remaining,equipamento_inicial=v_saved WHERE character_id=v_character.id;
  UPDATE public.characters SET ouro=FLOOR(v_remaining)::integer WHERE id=v_character.id;
  RETURN v_saved;
END;
$function$;
REVOKE ALL ON FUNCTION public.finalizar_equipamento_inicial_srd(text,text,jsonb,jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.finalizar_equipamento_inicial_srd(text,text,jsonb,jsonb) TO authenticated;
NOTIFY pgrst,'reload schema';
