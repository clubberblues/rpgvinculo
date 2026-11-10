
DO $correct_slow_save_metadata$
DECLARE
  v_save text;
BEGIN
  SELECT saving_throw INTO v_save
  FROM public.srd_spell_effects
  WHERE spell_id='srd35_spell_slow' AND effect_index=1
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Efeito da magia Lentidão não encontrado.';
  END IF;

  IF v_save NOT IN ('reflex','will') THEN
    RAISE EXCEPTION 'Valor inesperado de teste de resistência para Lentidão: %',v_save;
  END IF;

  UPDATE public.srd_spell_effects
  SET saving_throw='will'
  WHERE spell_id='srd35_spell_slow'
    AND effect_index=1
    AND saving_throw='reflex';

  IF NOT FOUND AND v_save<>'will' THEN
    RAISE EXCEPTION 'Não foi possível corrigir o teste de resistência de Lentidão.';
  END IF;
END;
$correct_slow_save_metadata$;
