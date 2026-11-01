-- Cleric domain choices and separate daily domain spell slots.
BEGIN;

CREATE OR REPLACE FUNCTION public.salvar_dominios_personagem_srd(p_character_id text,p_domain_ids text[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog','public'
AS $function$
DECLARE
  v_character_id public.characters.id%TYPE;
  v_class_key text;
  v_choices jsonb;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória'; END IF;
  IF p_domain_ids IS NULL OR cardinality(p_domain_ids)<>2
     OR p_domain_ids[1] IS NULL OR p_domain_ids[2] IS NULL
     OR p_domain_ids[1]=p_domain_ids[2] THEN
    RAISE EXCEPTION 'O clérigo deve escolher dois domínios diferentes';
  END IF;
  SELECT c.id,public._srd35_class_key(cl.nome)
    INTO v_character_id,v_class_key
    FROM public.characters c
    JOIN public.srd_character_sheets sh ON sh.character_id=c.id
    JOIN public.srd_classes cl ON cl.id=sh.classe_id
   WHERE c.id::text=p_character_id AND c.user_id=auth.uid()
   FOR UPDATE OF c,sh;
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou sem autorização'; END IF;
  IF v_class_key<>'cleric' THEN RAISE EXCEPTION 'Somente personagens clérigos escolhem domínios'; END IF;
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
$function$;
CREATE OR REPLACE FUNCTION public.salvar_grimorio_srd(p_character_id text, p_estado jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_doc jsonb; v_class text; v_level integer; v_score integer;
  v_known jsonb; v_prepared jsonb; v_usos jsonb; v_old jsonb;
  v_spell record; v_entry jsonb; v_spell_id text; v_circle integer; v_slot integer;
  v_expended boolean; v_capacity integer; v_count integer; v_count_known integer;
  v_old_expended integer; v_new_ordinal integer; v_slot_key text; v_prepared_out jsonb := '[]'::jsonb;
  v_known_out jsonb := '[]'::jsonb; v_usos_out jsonb := '{}'::jsonb;
  v_key text; v_count_value integer; v_known_limits jsonb;
  v_domain_input jsonb; v_domain_out jsonb := '[]'::jsonb; v_domain_id text; v_domain_spell_id text;
  v_domain_level integer; v_domain_expended boolean; v_has_domain boolean;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.characters c
                  WHERE c.id::text=p_character_id AND c.user_id=auth.uid()) THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem autorização';
  END IF;
  SELECT s.* INTO v_sheet FROM public.srd_character_sheets s
   WHERE s.character_id::text=p_character_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada'; END IF;
  v_old := coalesce(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
  IF p_estado IS NULL OR jsonb_typeof(p_estado) <> 'object' OR p_estado->>'version' <> '1'
     OR jsonb_typeof(p_estado->'conhecidas') <> 'array'
     OR jsonb_typeof(p_estado->'preparadas') <> 'array'
     OR jsonb_typeof(p_estado->'usos') <> 'object' THEN
    RAISE EXCEPTION 'Formato inválido; esperado {version:1, conhecidas:[], preparadas:[], usos:{}}';
  END IF;
  v_doc := to_jsonb(v_sheet);
  SELECT public._srd35_class_key(cl.nome) INTO v_class FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe SRD referenciada por classe_id não encontrada ou incompatível'; END IF;
  v_level := v_sheet.nivel;
  IF v_level IS NULL OR v_level NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Nível de classe ausente ou fora de 1..20'; END IF;
  v_score := CASE v_class
    WHEN 'wizard' THEN public._srd35_attr(v_doc,ARRAY['INT','inteligencia','intelligence','int_score','score_inteligencia'])::integer
    WHEN 'sorcerer' THEN public._srd35_attr(v_doc,ARRAY['CAR','carisma','charisma','cha','cha_score','score_carisma'])::integer
    ELSE public._srd35_attr(v_doc,ARRAY['SAB','sabedoria','wisdom','wis','wis_score','score_sabedoria'])::integer END;
  IF v_score IS NULL OR v_score < 1 THEN RAISE EXCEPTION 'Atributo-chave ausente ou inválido'; END IF;
  v_known := p_estado->'conhecidas'; v_prepared := p_estado->'preparadas'; v_usos := p_estado->'usos';
  v_domain_input := coalesce(p_estado->'dominio_preparadas',v_old->'dominio_preparadas','[]'::jsonb);
  IF EXISTS (SELECT 1 FROM jsonb_array_elements(v_known) AS x(value) WHERE jsonb_typeof(x.value) <> 'string')
     OR EXISTS (SELECT 1 FROM jsonb_array_elements(v_prepared) AS x(value) WHERE jsonb_typeof(x.value) <> 'object') THEN
    RAISE EXCEPTION 'Conhecidas deve conter IDs string e preparadas deve conter objetos';
  END IF;
  IF jsonb_typeof(v_domain_input)<>'array' THEN RAISE EXCEPTION 'dominio_preparadas deve ser uma lista'; END IF;
  IF v_class<>'cleric' AND jsonb_array_length(v_domain_input)>0 THEN RAISE EXCEPTION 'Somente clérigos têm espaços de domínio'; END IF;
  IF (SELECT count(*) FROM jsonb_array_elements_text(v_known)) <>
     (SELECT count(DISTINCT x) FROM jsonb_array_elements_text(v_known) AS t(x)) THEN
    RAISE EXCEPTION 'IDs duplicados em conhecidas';
  END IF;
  FOR v_spell_id IN SELECT x FROM jsonb_array_elements_text(v_known) AS t(x) LOOP
    SELECT id,circulo,classes INTO v_spell FROM public.srd_spells WHERE id=v_spell_id;
    IF NOT FOUND OR v_spell.circulo NOT BETWEEN 0 AND 9
       OR NOT public._srd35_spell_class_ok(v_spell.classes,v_class) THEN
      RAISE EXCEPTION 'Magia conhecida inexistente, nível inválido ou incompatível: %',v_spell_id;
    END IF;
    IF coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_spell.circulo)::integer
                   FROM public.srd_spell_progressions WHERE class_key=v_class),0)=0 THEN
      RAISE EXCEPTION 'Círculo não acessível neste nível: %',v_spell_id;
    END IF;
    IF v_score < 10+v_spell.circulo THEN RAISE EXCEPTION 'Atributo insuficiente para conhecer a magia: %',v_spell_id; END IF;
    v_known_out := v_known_out || to_jsonb(v_spell_id);
  END LOOP;
  IF v_class='sorcerer' THEN
    SELECT known_by_level -> (v_level-1) INTO v_known_limits
      FROM public.srd_spell_progressions WHERE class_key='sorcerer';
    FOR v_circle IN 0..9 LOOP
      SELECT count(*) INTO v_count_known
        FROM jsonb_array_elements_text(v_known) AS k(spell_id)
        JOIN public.srd_spells sp ON sp.id=k.spell_id WHERE sp.circulo=v_circle;
      v_capacity := coalesce((v_known_limits ->> v_circle)::integer,0);
      IF v_count_known > v_capacity THEN RAISE EXCEPTION 'Magias conhecidas excedem o limite do círculo %',v_circle; END IF;
    END LOOP;
  ELSIF v_usos <> '{}'::jsonb THEN
    RAISE EXCEPTION 'O mapa usos só é aceito para feiticeiro';
  END IF;
  IF v_class='sorcerer' AND (jsonb_object_length(v_usos)>0 OR jsonb_object_length(coalesce(v_old->'usos','{}'::jsonb))>0) THEN
    FOR v_key,v_count_value IN
      SELECT k, greatest(coalesce((v_usos->>k)::integer,0),coalesce((v_old->'usos'->>k)::integer,0))
        FROM (SELECT key AS k FROM jsonb_each(v_usos)
              UNION SELECT key AS k FROM jsonb_each(coalesce(v_old->'usos','{}'::jsonb))) AS all_keys
    LOOP
      IF v_key !~ '^(0|[1-9])$' OR v_count_value<0 THEN RAISE EXCEPTION 'Usos deve mapear círculos 0..9 a inteiros não negativos'; END IF;
      v_circle := v_key::integer;
      IF coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_circle)::integer
                     FROM public.srd_spell_progressions WHERE class_key='sorcerer'),0)=0
         OR v_count_value > public._srd35_slots(v_class,v_level,v_score,v_circle) THEN
        RAISE EXCEPTION 'Usos excedem os espaços diários no círculo %',v_circle;
      END IF;
      v_usos_out := jsonb_set(v_usos_out,ARRAY[v_key],to_jsonb(v_count_value),true);
    END LOOP;
  END IF;
  FOR v_entry IN SELECT value FROM jsonb_array_elements(v_prepared) LOOP
    v_spell_id := v_entry->>'spell_id';
    IF v_spell_id IS NULL OR jsonb_typeof(v_entry->'slot_level') <> 'number'
       OR jsonb_typeof(v_entry->'expended') <> 'boolean' THEN
      RAISE EXCEPTION 'Cada preparado requer spell_id, slot_level inteiro e expended boolean';
    END IF;
    IF (v_entry->>'slot_level') !~ '^(0|[1-9])$' THEN RAISE EXCEPTION 'slot_level deve estar entre 0 e 9'; END IF;
    v_slot := (v_entry->>'slot_level')::integer;
    SELECT id,circulo,classes INTO v_spell FROM public.srd_spells WHERE id=v_spell_id;
    IF NOT FOUND OR v_spell.circulo NOT BETWEEN 0 AND 9 OR v_slot < v_spell.circulo
       OR NOT public._srd35_spell_class_ok(v_spell.classes,v_class) THEN
      RAISE EXCEPTION 'Magia preparada inexistente, nível/slot inválido ou incompatível: %',v_spell_id;
    END IF;
    IF v_class='sorcerer' THEN RAISE EXCEPTION 'Feiticeiro usa conhecidas/usos, não prepara magias'; END IF;
    IF v_class='wizard' AND NOT (v_known ? v_spell_id) THEN
      RAISE EXCEPTION 'Mago só pode preparar magias conhecidas/no grimório: %',v_spell_id;
    END IF;
    IF coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_spell.circulo)::integer
                   FROM public.srd_spell_progressions WHERE class_key=v_class),0)=0 THEN
      RAISE EXCEPTION 'Círculo da magia não acessível neste nível: %',v_spell_id;
    END IF;
    IF v_score < 10+v_spell.circulo THEN RAISE EXCEPTION 'Atributo insuficiente para preparar a magia: %',v_spell_id; END IF;
    v_prepared_out := v_prepared_out || jsonb_build_array(jsonb_build_object(
      'spell_id',v_spell_id,'slot_level',v_slot,'expended',coalesce((v_entry->>'expended')::boolean,false)));
  END LOOP;
  -- Domain slots are a separate daily slot, one per accessible circle for clerics.
  IF v_class='cleric' THEN
    IF (SELECT count(*) FROM jsonb_array_elements(v_domain_input)) <>
       (SELECT count(DISTINCT (value->>'slot_level')::integer) FROM jsonb_array_elements(v_domain_input)) THEN
      RAISE EXCEPTION 'Há mais de uma preparação no mesmo espaço de domínio';
    END IF;
    FOR v_entry IN SELECT value FROM jsonb_array_elements(v_domain_input) LOOP
      v_domain_id:=v_entry->>'domain_id'; v_domain_spell_id:=v_entry->>'spell_id';
      IF v_domain_id IS NULL OR v_domain_spell_id IS NULL
         OR jsonb_typeof(v_entry->'slot_level')<>'number'
         OR jsonb_typeof(v_entry->'expended')<>'boolean'
         OR (v_entry->>'slot_level') !~ '^[1-9]
  FOR v_count IN 0..jsonb_array_length(v_prepared_out)-1 LOOP
    v_entry := v_prepared_out -> v_count;
    v_spell_id := v_entry->>'spell_id'; v_slot := (v_entry->>'slot_level')::integer;
    v_slot_key := v_spell_id || ':' || v_slot::text;
    SELECT count(*) INTO v_new_ordinal FROM jsonb_array_elements(v_prepared_out) WITH ORDINALITY q(value,ord)
      WHERE value->>'spell_id'=v_spell_id AND (value->>'slot_level')::integer=v_slot AND ord<=v_count+1;
    SELECT count(*) INTO v_old_expended FROM jsonb_array_elements(coalesce(v_old->'preparadas','[]'::jsonb)) q(value)
      WHERE value->>'spell_id'=v_spell_id AND (value->>'slot_level')::integer=v_slot
        AND coalesce((value->>'expended')::boolean,false);
    IF v_new_ordinal<=v_old_expended THEN
      v_prepared_out := jsonb_set(v_prepared_out,ARRAY[v_count::text,'expended'],'true'::jsonb,true);
    END IF;
  END LOOP;
  -- Preserve previously expended slots even if the client submits a different spell list.
  FOR v_entry IN SELECT value FROM jsonb_array_elements(coalesce(v_old->'preparadas','[]'::jsonb)) q(value)
    WHERE coalesce((value->>'expended')::boolean,false)
  LOOP
    v_spell_id:=v_entry->>'spell_id'; v_slot:=(v_entry->>'slot_level')::integer;
    SELECT count(*) INTO v_old_expended FROM jsonb_array_elements(coalesce(v_old->'preparadas','[]'::jsonb)) q(value)
      WHERE value->>'spell_id'=v_spell_id AND (value->>'slot_level')::integer=v_slot
        AND coalesce((value->>'expended')::boolean,false);
    SELECT count(*) INTO v_new_ordinal FROM jsonb_array_elements(v_prepared_out) q(value)
      WHERE value->>'spell_id'=v_spell_id AND (value->>'slot_level')::integer=v_slot
        AND coalesce((value->>'expended')::boolean,false);
    IF v_new_ordinal<v_old_expended THEN
      v_prepared_out:=v_prepared_out||jsonb_build_array(jsonb_set(v_entry,'{expended}','true'::jsonb,true));
    END IF;
  END LOOP;
  FOR v_circle IN 0..9 LOOP
    SELECT count(*) INTO v_count FROM jsonb_array_elements(v_prepared_out) e
      WHERE (e->>'slot_level')::integer=v_circle;
    v_capacity := public._srd35_slots(v_class,v_level,v_score,v_circle);
    IF v_count>v_capacity THEN RAISE EXCEPTION 'Preparadas excedem espaços diários do círculo % (% > %)',v_circle,v_count,v_capacity; END IF;
  END LOOP;
  UPDATE public.srd_character_sheets
     SET magias_preparadas=jsonb_build_object('version',1,'conhecidas',v_known_out,'preparadas',v_prepared_out,'dominio_preparadas',v_domain_out,'usos',v_usos_out)
   WHERE character_id::text=p_character_id;
  RETURN jsonb_build_object('version',1,'conhecidas',v_known_out,'preparadas',v_prepared_out,'dominio_preparadas',v_domain_out,'usos',v_usos_out);
END
$function$
 THEN
        RAISE EXCEPTION 'Cada espaço de domínio requer domain_id, spell_id, círculo 1..9 e expended';
      END IF;
      v_domain_level:=(v_entry->>'slot_level')::integer;
      SELECT EXISTS (
        SELECT 1 FROM public.srd_character_domain_choices choice
        JOIN public.srd_domain_spells ds USING (domain_id)
        WHERE choice.character_id::text=p_character_id AND choice.domain_id=v_domain_id
          AND ds.spell_id=v_domain_spell_id AND ds.spell_level=v_domain_level
      ) INTO v_has_domain;
      IF NOT v_has_domain THEN RAISE EXCEPTION 'A magia não pertence a um domínio escolhido ou círculo informado'; END IF;
      IF coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_domain_level)::integer
                     FROM public.srd_spell_progressions WHERE class_key='cleric'),0)=0
         OR v_score < 10+v_domain_level THEN
        RAISE EXCEPTION 'O círculo de domínio não está acessível para este nível/atributo';
      END IF;
      v_domain_expended:=coalesce((v_entry->>'expended')::boolean,false);
      IF EXISTS (SELECT 1 FROM jsonb_array_elements(coalesce(v_old->'dominio_preparadas','[]'::jsonb)) old_slot
                   WHERE (old_slot->>'slot_level')::integer=v_domain_level
                     AND coalesce((old_slot->>'expended')::boolean,false)) THEN
        v_domain_expended:=true;
      END IF;
      v_domain_out:=v_domain_out||jsonb_build_array(jsonb_build_object(
        'domain_id',v_domain_id,'spell_id',v_domain_spell_id,'slot_level',v_domain_level,'expended',v_domain_expended));
    END LOOP;
    -- A spent domain slot cannot be restored by changing its spell; only a daily rest resets it.
    FOR v_entry IN SELECT value FROM jsonb_array_elements(coalesce(v_old->'dominio_preparadas','[]'::jsonb)) old_slot(value)
      WHERE coalesce((value->>'expended')::boolean,false) LOOP
      IF NOT EXISTS (SELECT 1 FROM jsonb_array_elements(v_domain_out) x(value)
                     WHERE (value->>'slot_level')::integer=(v_entry->>'slot_level')::integer) THEN
        v_domain_out:=v_domain_out||jsonb_build_array(v_entry);
      END IF;
    END LOOP;
  END IF;
  -- Preserve previously expended slots by occurrence of the same spell/slot pair.
  FOR v_count IN 0..jsonb_array_length(v_prepared_out)-1 LOOP
    v_entry := v_prepared_out -> v_count;
    v_spell_id := v_entry->>'spell_id'; v_slot := (v_entry->>'slot_level')::integer;
    v_slot_key := v_spell_id || ':' || v_slot::text;
    SELECT count(*) INTO v_new_ordinal FROM jsonb_array_elements(v_prepared_out) WITH ORDINALITY q(value,ord)
      WHERE value->>'spell_id'=v_spell_id AND (value->>'slot_level')::integer=v_slot AND ord<=v_count+1;
    SELECT count(*) INTO v_old_expended FROM jsonb_array_elements(coalesce(v_old->'preparadas','[]'::jsonb)) q(value)
      WHERE value->>'spell_id'=v_spell_id AND (value->>'slot_level')::integer=v_slot
        AND coalesce((value->>'expended')::boolean,false);
    IF v_new_ordinal<=v_old_expended THEN
      v_prepared_out := jsonb_set(v_prepared_out,ARRAY[v_count::text,'expended'],'true'::jsonb,true);
    END IF;
  END LOOP;
  -- Preserve previously expended slots even if the client submits a different spell list.
  FOR v_entry IN SELECT value FROM jsonb_array_elements(coalesce(v_old->'preparadas','[]'::jsonb)) q(value)
    WHERE coalesce((value->>'expended')::boolean,false)
  LOOP
    v_spell_id:=v_entry->>'spell_id'; v_slot:=(v_entry->>'slot_level')::integer;
    SELECT count(*) INTO v_old_expended FROM jsonb_array_elements(coalesce(v_old->'preparadas','[]'::jsonb)) q(value)
      WHERE value->>'spell_id'=v_spell_id AND (value->>'slot_level')::integer=v_slot
        AND coalesce((value->>'expended')::boolean,false);
    SELECT count(*) INTO v_new_ordinal FROM jsonb_array_elements(v_prepared_out) q(value)
      WHERE value->>'spell_id'=v_spell_id AND (value->>'slot_level')::integer=v_slot
        AND coalesce((value->>'expended')::boolean,false);
    IF v_new_ordinal<v_old_expended THEN
      v_prepared_out:=v_prepared_out||jsonb_build_array(jsonb_set(v_entry,'{expended}','true'::jsonb,true));
    END IF;
  END LOOP;
  FOR v_circle IN 0..9 LOOP
    SELECT count(*) INTO v_count FROM jsonb_array_elements(v_prepared_out) e
      WHERE (e->>'slot_level')::integer=v_circle;
    v_capacity := public._srd35_slots(v_class,v_level,v_score,v_circle);
    IF v_count>v_capacity THEN RAISE EXCEPTION 'Preparadas excedem espaços diários do círculo % (% > %)',v_circle,v_count,v_capacity; END IF;
  END LOOP;
  UPDATE public.srd_character_sheets
     SET magias_preparadas=jsonb_build_object('version',1,'conhecidas',v_known_out,'preparadas',v_prepared_out,'usos',v_usos_out)
   WHERE character_id::text=p_character_id;
  RETURN jsonb_build_object('version',1,'conhecidas',v_known_out,'preparadas',v_prepared_out,'usos',v_usos_out);
END
$function$;

REVOKE ALL ON FUNCTION public.salvar_dominios_personagem_srd(text,text[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.salvar_dominios_personagem_srd(text,text[]) TO authenticated;

COMMIT;