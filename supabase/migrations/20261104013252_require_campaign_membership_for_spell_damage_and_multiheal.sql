DO $patch_magic_missile$
DECLARE
  v_definition text;
  v_marker text := '  SELECT sh.* INTO v_sheet';
  v_guard text := $guard$
  IF NOT EXISTS (
    SELECT 1 FROM public.members m
    WHERE m.campaign_id = v_character.campaign_id
      AND m.user_id = auth.uid()
    UNION ALL
    SELECT 1 FROM public.campaigns c
    WHERE c.id = v_character.campaign_id
      AND c.owner_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'O personagem não pertence a uma campanha da qual você participa.';
  END IF;

$guard$;
BEGIN
  SELECT pg_get_functiondef(
    'public.conjurar_missil_magico_srd(text,text,smallint,text,integer)'::regprocedure
  ) INTO v_definition;
  IF position(v_marker IN v_definition) = 0 THEN
    RAISE EXCEPTION 'Não foi possível localizar o ponto de validação de Míssil Mágico.';
  END IF;
  v_definition := replace(v_definition, v_marker, v_guard || v_marker);
  EXECUTE v_definition;
END
$patch_magic_missile$;

DO $patch_multi_heal$
DECLARE
  v_definition text;
  v_marker text := '  SELECT s.* INTO v_sheet';
  v_guard text := $guard$
  IF NOT EXISTS (
    SELECT 1 FROM public.members m
    WHERE m.campaign_id = v_campaign_id
      AND m.user_id = auth.uid()
    UNION ALL
    SELECT 1 FROM public.campaigns c
    WHERE c.id = v_campaign_id
      AND c.owner_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'O personagem não pertence a uma campanha da qual você participa.';
  END IF;

$guard$;
BEGIN
  SELECT pg_get_functiondef(
    'public.conjurar_magia_srd_multialvo_v3(text,text,smallint,text[],integer[])'::regprocedure
  ) INTO v_definition;
  IF position(v_marker IN v_definition) = 0 THEN
    RAISE EXCEPTION 'Não foi possível localizar o ponto de validação da cura múltipla.';
  END IF;
  v_definition := replace(v_definition, v_marker, v_guard || v_marker);
  EXECUTE v_definition;
END
$patch_multi_heal$;