-- Keep the SRD familiar choices aligned between the creation UI and server validation.
-- The existing function is preserved verbatim except for the basic familiar allowlist.
DO $migration$
DECLARE
  v_definition text;
  v_old text := $old$('','snake_small_viper','cat','lizard','rat','badger','owl','raven','hawk','bat','toad')$old$;
  v_new text := $new$('','snake_small_viper','cat','lizard','rat','weasel','owl','raven','hawk','bat','toad')$new$;
BEGIN
  SELECT pg_get_functiondef(
    'public.criar_personagem_srd_completo(text,text,text,jsonb,jsonb,jsonb,jsonb)'::regprocedure
  ) INTO v_definition;

  IF position(v_old IN v_definition) = 0 THEN
    RAISE EXCEPTION 'A allowlist de familiares esperada não foi encontrada; migração cancelada sem alterar a função.';
  END IF;

  IF position(v_new IN v_definition) > 0 THEN
    RAISE NOTICE 'A allowlist já aceita Doninha; nenhuma alteração necessária.';
  ELSE
    v_definition := replace(v_definition, v_old, v_new);
    EXECUTE v_definition;
  END IF;
END
$migration$;

-- Narrow RPC for the six free-text equipment note groups.
-- No UPDATE privilege is granted on srd_character_sheets itself.
CREATE OR REPLACE FUNCTION public.salvar_anotacoes_equipamento_srd(
  p_character_id text,
  p_equipment_notes jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public', 'auth', 'pg_temp'
AS $function$
DECLARE
  v_user uuid := auth.uid();
  v_character_id bigint;
  v_clean jsonb := '{}'::jsonb;
  v_section record;
  v_entry jsonb;
  v_items jsonb;
  v_key text;
BEGIN
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'Autenticação obrigatória.';
  END IF;

  IF NULLIF(BTRIM(p_character_id), '') IS NULL
     OR p_equipment_notes IS NULL
     OR jsonb_typeof(p_equipment_notes) <> 'object' THEN
    RAISE EXCEPTION 'Informe o personagem e as anotações em formato válido.';
  END IF;

  SELECT ch.id
    INTO v_character_id
    FROM public.characters ch
    LEFT JOIN public.campaigns c ON c.id = ch.campaign_id
   WHERE ch.id::text = BTRIM(p_character_id)
     AND (
       ch.user_id = v_user
       OR c.owner_id = v_user
       OR public.my_role(ch.campaign_id) = 'GM'
     )
   FOR UPDATE OF ch;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem autorização.';
  END IF;

  FOR v_section IN SELECT key, value FROM jsonb_each(p_equipment_notes)
  LOOP
    v_key := v_section.key;
    IF v_key NOT IN ('weapons','ammunition','protection','gear','magic','treasure') THEN
      RAISE EXCEPTION 'Grupo de anotações inválido: %.', v_key;
    END IF;
    IF jsonb_typeof(v_section.value) <> 'array' THEN
      RAISE EXCEPTION 'O grupo % precisa ser uma lista.', v_key;
    END IF;

    v_items := '[]'::jsonb;
    FOR v_entry IN SELECT value FROM jsonb_array_elements(v_section.value)
    LOOP
      IF jsonb_typeof(v_entry) <> 'object' THEN
        RAISE EXCEPTION 'Cada registro de % precisa ser um objeto.', v_key;
      END IF;
      IF (v_entry ? 'nome' AND jsonb_typeof(v_entry->'nome') NOT IN ('string','null'))
         OR (v_entry ? 'quantidade' AND jsonb_typeof(v_entry->'quantidade') NOT IN ('string','null'))
         OR (v_entry ? 'detalhes' AND jsonb_typeof(v_entry->'detalhes') NOT IN ('string','null')) THEN
        RAISE EXCEPTION 'Nome, quantidade e detalhes precisam ser textos.';
      END IF;

      v_items := v_items || jsonb_build_array(jsonb_build_object(
        'nome', COALESCE(v_entry->>'nome',''),
        'quantidade', COALESCE(v_entry->>'quantidade',''),
        'detalhes', COALESCE(v_entry->>'detalhes','')
      ));
    END LOOP;
    v_clean := jsonb_set(v_clean, ARRAY[v_key], v_items, true);
  END LOOP;

  -- Preserve a stable shape for all six visual groups.
  FOREACH v_key IN ARRAY ARRAY['weapons','ammunition','protection','gear','magic','treasure']
  LOOP
    IF NOT (v_clean ? v_key) THEN
      v_clean := jsonb_set(v_clean, ARRAY[v_key], '[]'::jsonb, true);
    END IF;
  END LOOP;

  UPDATE public.srd_character_sheets
     SET identidade = jsonb_set(
       COALESCE(identidade, '{}'::jsonb),
       '{equipment_notes}',
       v_clean,
       true
     )
   WHERE character_id = v_character_id;

  RETURN v_clean;
END
$function$;

REVOKE ALL ON FUNCTION public.salvar_anotacoes_equipamento_srd(text, jsonb) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.salvar_anotacoes_equipamento_srd(text, jsonb) TO authenticated;
