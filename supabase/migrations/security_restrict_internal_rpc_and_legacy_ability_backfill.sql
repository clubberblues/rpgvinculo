-- Restrict trigger-only routines and add ownership/GM validation to legacy ability backfill.
REVOKE EXECUTE ON FUNCTION public.enforce_campaign_member_role() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.limpar_ficha_srd_ao_excluir_personagem() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.limpar_inventario_srd_ao_excluir_personagem() FROM anon, authenticated;

CREATE OR REPLACE FUNCTION public.learn_abilities_for_level(p_char bigint, p_nivel integer)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $function$
DECLARE
  cls text;
  reg record;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.characters c
    WHERE c.id = p_char
      AND (c.user_id = auth.uid() OR public.my_role(c.campaign_id) = 'GM')
  ) THEN
    RAISE EXCEPTION 'Sem permissão para atualizar esta ficha.';
  END IF;

  SELECT classe INTO cls
  FROM public.character_sheets
  WHERE character_id = p_char;

  IF cls IS NULL THEN
    RETURN;
  END IF;

  FOR reg IN
    SELECT id, nivel
    FROM public.abilities
    WHERE classe = cls
      AND nivel <= p_nivel
      AND id NOT IN (
        SELECT ability_id
        FROM public.character_abilities
        WHERE character_id = p_char
      )
  LOOP
    INSERT INTO public.character_abilities(character_id, ability_id, aprendida_em_nivel)
    VALUES (p_char, reg.id, reg.nivel);
  END LOOP;
END;
$function$;