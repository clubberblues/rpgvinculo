-- General character-creation picks must be General feats.
-- Spell Mastery is retained as a catalog Special exception for Wizard.
CREATE OR REPLACE FUNCTION public.criar_personagem_srd_completo(
  p_nome TEXT,
  p_raca_id TEXT,
  p_classe_id TEXT,
  p_atributos JSONB,
  p_pericias JSONB,
  p_talentos JSONB
)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_character_id TEXT;
  v_class public.srd_classes%ROWTYPE;
  v_pick JSONB;
  v_feat public.srd_feats%ROWTYPE;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF p_talentos IS NULL OR jsonb_typeof(p_talentos)<>'array' THEN
    RAISE EXCEPTION 'Os talentos precisam ser enviados como uma lista.';
  END IF;
  SELECT cl.* INTO v_class FROM public.srd_classes cl WHERE cl.id=p_classe_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Classe SRD não encontrada.'; END IF;

  FOR v_pick IN SELECT value FROM jsonb_array_elements(p_talentos) LOOP
    IF jsonb_typeof(v_pick)<>'object' OR NULLIF(BTRIM(v_pick->>'id'),'') IS NULL THEN
      RAISE EXCEPTION 'Cada escolha de talento precisa de um ID válido.';
    END IF;
    SELECT f.* INTO v_feat FROM public.srd_feats f WHERE f.id=v_pick->>'id';
    IF NOT FOUND THEN RAISE EXCEPTION 'Talento não encontrado: %.',v_pick->>'id'; END IF;
    IF COALESCE(v_feat.requisitos->>'type','General')<>'General'
       AND NOT (v_class.class_key='wizard' AND v_feat.id='srd35_feat_spell_mastery') THEN
      RAISE EXCEPTION '% não é um talento geral disponível na criação básica.',v_feat.nome;
    END IF;
  END LOOP;

  v_character_id:=public.criar_personagem_srd(p_nome,p_raca_id,p_classe_id,p_atributos);
  PERFORM public.salvar_pericias_srd(v_character_id,p_pericias);
  PERFORM public.salvar_talentos_srd(v_character_id,p_talentos);
  RETURN v_character_id;
END;
$$;

REVOKE ALL ON FUNCTION public.criar_personagem_srd_completo(TEXT,TEXT,TEXT,JSONB,JSONB,JSONB) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.criar_personagem_srd_completo(TEXT,TEXT,TEXT,JSONB,JSONB,JSONB) TO authenticated;
NOTIFY pgrst,'reload schema';
