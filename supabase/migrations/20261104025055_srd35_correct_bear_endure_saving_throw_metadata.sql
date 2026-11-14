
DO $correct_simple_spell_save_metadata$
DECLARE
  v_bear_save text;
  v_endure_save text;
BEGIN
  SELECT saving_throw INTO v_bear_save
  FROM public.srd_spell_effects
  WHERE spell_id='srd35_spell_bear_s_endurance' AND effect_index=1
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Efeito de Resistência do Urso não encontrado.'; END IF;
  IF v_bear_save NOT IN ('fortitude','will') THEN
    RAISE EXCEPTION 'Valor inesperado de resistência para Resistência do Urso: %',v_bear_save;
  END IF;

  SELECT saving_throw INTO v_endure_save
  FROM public.srd_spell_effects
  WHERE spell_id='srd35_spell_endure_elements' AND effect_index=1
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Efeito de Resistir aos Elementos não encontrado.'; END IF;
  IF v_endure_save NOT IN ('fortitude','will') THEN
    RAISE EXCEPTION 'Valor inesperado de resistência para Resistir aos Elementos: %',v_endure_save;
  END IF;

  UPDATE public.srd_spell_effects
  SET saving_throw='will'
  WHERE spell_id='srd35_spell_bear_s_endurance'
    AND effect_index=1
    AND saving_throw='fortitude';

  IF NOT FOUND AND v_bear_save<>'will' THEN
    RAISE EXCEPTION 'Não foi possível corrigir Resistência do Urso.';
  END IF;

  UPDATE public.srd_spell_effects
  SET saving_throw='will'
  WHERE spell_id='srd35_spell_endure_elements'
    AND effect_index=1
    AND saving_throw='fortitude';

  IF NOT FOUND AND v_endure_save<>'will' THEN
    RAISE EXCEPTION 'Não foi possível corrigir Resistir aos Elementos.';
  END IF;
END;
$correct_simple_spell_save_metadata$;
