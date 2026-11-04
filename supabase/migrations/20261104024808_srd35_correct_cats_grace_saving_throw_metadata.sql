-- D&D 3.5 SRD: Cat's Grace uses a Will save (harmless), not Reflex.
-- The canonical spell source already records "Will negates (harmless)".
DO $correct_cats_grace_save_metadata$
DECLARE
  v_save text;
BEGIN
  SELECT saving_throw INTO v_save
  FROM public.srd_spell_effects
  WHERE spell_id='srd35_spell_cat_s_grace' AND effect_index=1
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Efeito da magia Graça Felina não encontrado.';
  END IF;

  IF v_save NOT IN ('reflex','will') THEN
    RAISE EXCEPTION 'Valor inesperado de teste de resistência para Graça Felina: %',v_save;
  END IF;

  UPDATE public.srd_spell_effects
  SET saving_throw='will'
  WHERE spell_id='srd35_spell_cat_s_grace'
    AND effect_index=1
    AND saving_throw='reflex';

  IF NOT FOUND AND v_save<>'will' THEN
    RAISE EXCEPTION 'Não foi possível corrigir o teste de resistência de Graça Felina.';
  END IF;
END;
$correct_cats_grace_save_metadata$;
