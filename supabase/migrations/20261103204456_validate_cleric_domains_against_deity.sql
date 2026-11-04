CREATE OR REPLACE FUNCTION public.salvar_dominios_personagem_srd(p_character_id text, p_domain_ids text[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_character_id public.characters.id%TYPE;
  v_class_key text;
  v_choices jsonb;
  v_identity jsonb;
  v_deity_id text;
  v_allowed_domains text[];
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória'; END IF;
  IF p_domain_ids IS NULL OR cardinality(p_domain_ids)<>2
     OR p_domain_ids[1] IS NULL OR p_domain_ids[2] IS NULL
     OR p_domain_ids[1]=p_domain_ids[2] THEN
    RAISE EXCEPTION 'O clérigo deve escolher dois domínios diferentes';
  END IF;
  SELECT c.id,public._srd35_class_key(cl.nome),sh.identidade
    INTO v_character_id,v_class_key,v_identity
    FROM public.characters c
    JOIN public.srd_character_sheets sh ON sh.character_id=c.id
    JOIN public.srd_classes cl ON cl.id=sh.classe_id
   WHERE c.id::text=p_character_id AND c.user_id=auth.uid()
   FOR UPDATE OF c,sh;
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou sem autorização'; END IF;
  IF v_class_key<>'cleric' THEN RAISE EXCEPTION 'Somente personagens clérigos escolhem domínios'; END IF;
  v_deity_id := nullif(v_identity->>'cleric_deity_id','');
  IF v_deity_id IS NOT NULL THEN
    SELECT domains INTO v_allowed_domains FROM public.srd_deities WHERE deity_id=v_deity_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Divindade do Clérigo não encontrada.'; END IF;
    IF NOT (p_domain_ids[1]=ANY(v_allowed_domains) AND p_domain_ids[2]=ANY(v_allowed_domains)) THEN
      RAISE EXCEPTION 'Os domínios escolhidos não pertencem à divindade selecionada.';
    END IF;
  END IF;
  IF (SELECT count(*) FROM public.srd_domains WHERE domain_id=ANY(p_domain_ids))<>2 THEN
    RAISE EXCEPTION 'Um dos domínios não existe no catálogo SRD';
  END IF;
  DELETE FROM public.srd_character_domain_choices WHERE character_id=v_character_id;
  INSERT INTO public.srd_character_domain_choices(character_id,domain_slot,domain_id)
  VALUES (v_character_id,1,p_domain_ids[1]),(v_character_id,2,p_domain_ids[2]);
  SELECT jsonb_agg(jsonb_build_object('domain_slot',domain_slot,'domain_id',domain_id) ORDER BY domain_slot)
    INTO v_choices FROM public.srd_character_domain_choices WHERE character_id=v_character_id;
  RETURN coalesce(v_choices,'[]'::jsonb);
END
$function$
;
revoke all on function public.salvar_dominios_personagem_srd(text,text[]) from public;
grant execute on function public.salvar_dominios_personagem_srd(text,text[]) to authenticated;
