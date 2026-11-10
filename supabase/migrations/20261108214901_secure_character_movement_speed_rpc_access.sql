DO $migration$
DECLARE
  v_definition text;
  v_old text := $old$BEGIN
  SELECT sh.atributos,sh.raca_id,COALESCE(sh.ouro,0),race.nome,race.tamanho$old$;
  v_new text := $new$BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Autenticação obrigatória.';
  END IF;
  SELECT ch.user_id,ch.campaign_id
    INTO v_character_owner,v_character_campaign_id
    FROM public.characters ch
   WHERE ch.id::text=BTRIM(p_character_id);
  IF NOT FOUND THEN RETURN v_base_speed; END IF;
  IF v_character_owner IS DISTINCT FROM auth.uid()
     AND NOT (v_character_campaign_id IS NOT NULL
       AND public.my_role(v_character_campaign_id) IN ('GM','PLAYER'))
     AND NOT EXISTS (
       SELECT 1
         FROM public.campaigns camp
         JOIN public.members member ON member.campaign_id=camp.id
        CROSS JOIN LATERAL jsonb_array_elements(
          CASE WHEN jsonb_typeof(camp.cba_data->'tokens')='array'
               THEN camp.cba_data->'tokens' ELSE '[]'::jsonb END
        ) tok(value)
        WHERE member.user_id=auth.uid()
          AND tok.value->>'tipo'='npc'
          AND tok.value->>'sourceCharacterId'=BTRIM(p_character_id)
     ) THEN
    RAISE EXCEPTION 'Você não tem acesso ao deslocamento desta ficha.';
  END IF;
  SELECT sh.atributos,sh.raca_id,COALESCE(sh.ouro,0),race.nome,race.tamanho$new$;
BEGIN
  v_definition:=pg_get_functiondef('public.srd35_deslocamento_personagem(text,numeric)'::regprocedure);
  IF position('v_character_owner uuid;' in v_definition)>0 THEN
    RAISE EXCEPTION 'A guarda de acesso já está instalada; migration abortada.';
  END IF;
  IF position('v_attrs JSONB;' in v_definition)=0 OR position(v_old in v_definition)=0 THEN
    RAISE EXCEPTION 'Estrutura esperada não encontrada; migration abortada.';
  END IF;
  v_definition:=replace(v_definition,'v_attrs JSONB;','v_attrs JSONB;'||E'\n  v_character_owner uuid;\n  v_character_campaign_id bigint;');
  v_definition:=replace(v_definition,v_old,v_new);
  v_definition:=replace(v_definition,'SET search_path TO ''public'', ''pg_temp''','SET search_path TO ''pg_catalog'', ''public'', ''priv'', ''pg_temp''');
  EXECUTE v_definition;
END
$migration$;
REVOKE ALL ON FUNCTION public.srd35_deslocamento_personagem(text,numeric) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.srd35_deslocamento_personagem(text,numeric) FROM anon;
GRANT EXECUTE ON FUNCTION public.srd35_deslocamento_personagem(text,numeric) TO authenticated;