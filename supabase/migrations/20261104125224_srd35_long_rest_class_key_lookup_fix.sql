CREATE OR REPLACE FUNCTION public.repor_magias_srd(p_character_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE v_sheet public.srd_character_sheets%ROWTYPE; v_doc jsonb; v_class text; v_state jsonb;
BEGIN
  IF auth.uid() IS NULL OR NOT EXISTS (SELECT 1 FROM public.characters c
       WHERE c.id::text=p_character_id AND c.user_id=auth.uid()) THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem autorização';
  END IF;
  SELECT s.* INTO v_sheet FROM public.srd_character_sheets s
    WHERE s.character_id::text=p_character_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada'; END IF;
  v_doc:=to_jsonb(v_sheet);
  SELECT COALESCE(NULLIF(cl.class_key,''),public._srd35_class_key(cl.nome)) INTO v_class FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe não resolvida na ficha'; END IF;
  v_state:=coalesce(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
  IF jsonb_typeof(v_state->'preparadas')<>'array' THEN RAISE EXCEPTION 'Estado de magias inválido'; END IF;
  SELECT jsonb_build_object('version',1,'conhecidas',coalesce(v_state->'conhecidas','[]'::jsonb),
      'preparadas',coalesce(jsonb_agg(jsonb_set(e.value,'{expended}','false'::jsonb,true) ORDER BY e.ord),'[]'::jsonb),
      'dominio_preparadas',coalesce((SELECT jsonb_agg(jsonb_set(d.value,'{expended}','false'::jsonb,true) ORDER BY d.ord)
        FROM jsonb_array_elements(coalesce(v_state->'dominio_preparadas','[]'::jsonb)) WITH ORDINALITY d(value,ord)),'[]'::jsonb),
      'usos',CASE WHEN v_class='sorcerer' THEN '{}'::jsonb ELSE coalesce(v_state->'usos','{}'::jsonb) END)
    INTO v_state FROM jsonb_array_elements(v_state->'preparadas') WITH ORDINALITY e(value,ord);
  UPDATE public.srd_character_sheets SET magias_preparadas=v_state,magias_descanso_em=clock_timestamp()
    WHERE character_id::text=p_character_id;
  RETURN v_state || jsonb_build_object('descanso_em',clock_timestamp());
END
$function$
;