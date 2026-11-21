DO $migration$
DECLARE
  v_definition text;
  v_old text;
  v_new text;
BEGIN
  SELECT pg_get_functiondef('public.salvar_grimorio_srd(text,jsonb)'::regprocedure)
    INTO v_definition;

  v_old := $old$v_capacity:=CASE WHEN v_score>=11 THEN greatest(0,3+floor((v_score-10)/2)::integer) ELSE 0 END;$old$;
  v_new := $new$v_capacity:=greatest(3,3+floor((v_score-10)/2)::integer);$new$;
  IF position(v_old IN v_definition)=0 THEN RAISE EXCEPTION 'Quota inicial do grimório não encontrada.'; END IF;
  v_definition:=replace(v_definition,v_old,v_new);

  v_old := $old$IF v_score < 10+v_spell_level THEN RAISE EXCEPTION 'Atributo insuficiente para conhecer a magia: %',v_spell_id; END IF;$old$;
  v_new := $new$IF v_score < 10+v_spell_level AND NOT (v_class='wizard' AND v_level=1 AND v_spell_level IN (0,1)) THEN RAISE EXCEPTION 'Atributo insuficiente para conhecer a magia: %',v_spell_id; END IF;$new$;
  IF position(v_old IN v_definition)=0 THEN RAISE EXCEPTION 'Validação de atributo do grimório não encontrada.'; END IF;
  v_definition:=replace(v_definition,v_old,v_new);

  v_old := $old$IF v_new_ordinal<=v_old_expended THEN$old$;
  v_new := $new$IF v_class<>'wizard' AND v_new_ordinal<=v_old_expended THEN$new$;
  IF position(v_old IN v_definition)=0 THEN RAISE EXCEPTION 'Preservação de ocorrência gasta não encontrada.'; END IF;
  v_definition:=replace(v_definition,v_old,v_new);

  v_old := $old$IF v_new_ordinal<v_old_expended THEN$old$;
  v_new := $new$IF v_class<>'wizard' AND v_new_ordinal<v_old_expended THEN$new$;
  IF position(v_old IN v_definition)=0 THEN RAISE EXCEPTION 'Restauração de ocorrência gasta não encontrada.'; END IF;
  v_definition:=replace(v_definition,v_old,v_new);

  v_old := $old$'expended',coalesce((v_entry->>'expended')::boolean,false)$old$;
  v_new := $new$'expended',CASE WHEN v_class='wizard' THEN false ELSE coalesce((v_entry->>'expended')::boolean,false) END$new$;
  IF position(v_old IN v_definition)=0 THEN RAISE EXCEPTION 'Campo de gasto de preparação não encontrado.'; END IF;
  v_definition:=replace(v_definition,v_old,v_new);

  v_old := $old$IF v_count>v_capacity THEN RAISE EXCEPTION 'Preparadas excedem espaços diários do círculo % (% > %)',v_circle,v_count,v_capacity; END IF;$old$;
  v_new := $new$IF v_class<>'wizard' AND v_count>v_capacity THEN RAISE EXCEPTION 'Preparadas excedem espaços diários do círculo % (% > %)',v_circle,v_count,v_capacity; END IF;$new$;
  IF position(v_old IN v_definition)=0 THEN RAISE EXCEPTION 'Limite diário de preparações não encontrado.'; END IF;
  v_definition:=replace(v_definition,v_old,v_new);

  v_old := $old$IF v_class='wizard' AND v_count>v_base_capacity THEN$old$;
  v_new := $new$IF false THEN$new$;
  IF position(v_old IN v_definition)=0 THEN RAISE EXCEPTION 'Limite de espaço especializado não encontrado.'; END IF;
  v_definition:=replace(v_definition,v_old,v_new);

  EXECUTE v_definition;

  SELECT pg_get_functiondef('public.finalizar_criacao_personagem_srd(text,text,text,jsonb,jsonb,jsonb,jsonb,jsonb,jsonb,text[],jsonb,text,jsonb,jsonb)'::regprocedure)
    INTO v_definition;
  v_old := $old$  PERFORM public.salvar_idiomas_personagem_srd(v_character_id, p_idiomas);$old$;
  v_new := $new$  -- Idiomas são texto livre em p_identidade->'idiomas_livres'; sem catálogo ou validação.$new$;
  IF position(v_old IN v_definition)=0 THEN RAISE EXCEPTION 'Chamada de validação de idiomas na criação não encontrada.'; END IF;
  v_definition:=replace(v_definition,v_old,v_new);
  EXECUTE v_definition;
END
$migration$;

CREATE OR REPLACE FUNCTION public.salvar_idiomas_livres_personagem_srd(
  p_character_id text,
  p_idiomas_livres text
)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog','public','auth','pg_temp'
AS $function$
DECLARE
  v_user uuid := auth.uid();
  v_character_id bigint;
  v_value text := coalesce(p_idiomas_livres,'');
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF NULLIF(BTRIM(p_character_id),'') IS NULL OR length(v_value)>5000 THEN
    RAISE EXCEPTION 'Informe o personagem e um texto de idiomas com até 5000 caracteres.';
  END IF;

  SELECT ch.id INTO v_character_id
    FROM public.characters ch
    LEFT JOIN public.campaigns campaign ON campaign.id=ch.campaign_id
   WHERE ch.id::text=BTRIM(p_character_id)
     AND (ch.user_id=v_user OR campaign.owner_id=v_user OR public.my_role(ch.campaign_id)='GM')
   FOR UPDATE OF ch;

  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou sem autorização.'; END IF;

  UPDATE public.srd_character_sheets
     SET identidade=jsonb_set(coalesce(identidade,'{}'::jsonb),'{idiomas_livres}',to_jsonb(v_value),true)
   WHERE character_id=v_character_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha D&D 3.5 não encontrada.'; END IF;
  RETURN v_value;
END;
$function$;

REVOKE ALL ON FUNCTION public.salvar_idiomas_livres_personagem_srd(text,text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.salvar_idiomas_livres_personagem_srd(text,text) TO authenticated;
