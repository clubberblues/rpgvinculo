-- Deriva níveis de magia por classe a partir do campo SRD "Level" e lê o nível real da classe conjuradora.
CREATE OR REPLACE FUNCTION public._srd35_spell_level_for_class(p_levels text, p_class_key text, p_fallback integer DEFAULT 0)
 RETURNS integer
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
DECLARE
  v_key text:=lower(COALESCE(p_class_key,''));
  v_pattern text;
  v_match text[];
BEGIN
  v_pattern:=CASE v_key
    WHEN 'wizard' THEN '(^|,)[[:space:]]*(wiz|sor/wiz)[[:space:]]+([0-9]+)'
    WHEN 'sorcerer' THEN '(^|,)[[:space:]]*(sor|sor/wiz)[[:space:]]+([0-9]+)'
    WHEN 'bard' THEN '(^|,)[[:space:]]*brd[[:space:]]+([0-9]+)'
    WHEN 'cleric' THEN '(^|,)[[:space:]]*clr[[:space:]]+([0-9]+)'
    WHEN 'druid' THEN '(^|,)[[:space:]]*drd[[:space:]]+([0-9]+)'
    WHEN 'paladin' THEN '(^|,)[[:space:]]*pal[[:space:]]+([0-9]+)'
    WHEN 'ranger' THEN '(^|,)[[:space:]]*rgr[[:space:]]+([0-9]+)'
    ELSE NULL
  END;
  IF v_pattern IS NOT NULL THEN
    v_match:=regexp_match(lower(COALESCE(p_levels,'')),v_pattern);
    IF v_match IS NOT NULL THEN
      RETURN v_match[array_length(v_match,1)]::integer;
    END IF;
  END IF;
  RETURN GREATEST(0,COALESCE(p_fallback,0));
END;
$function$
;
CREATE OR REPLACE FUNCTION public._srd35_character_class_level(p_character_id text, p_class_key text, p_primary_class_id text, p_total_level integer)
 RETURNS integer
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
DECLARE
  v_level integer;
  v_primary_key text;
BEGIN
  SELECT MAX(cl.class_level)::integer INTO v_level
  FROM public.srd_character_class_levels cl
  JOIN public.srd_classes cls ON cls.id=cl.class_id
  WHERE cl.character_id::text=BTRIM(p_character_id)
    AND public._srd35_class_key(cls.nome)=p_class_key;
  IF v_level IS NOT NULL THEN RETURN v_level; END IF;

  SELECT public._srd35_class_key(cls.nome) INTO v_primary_key
  FROM public.srd_classes cls WHERE cls.id=p_primary_class_id;
  IF v_primary_key=p_class_key THEN RETURN GREATEST(0,COALESCE(p_total_level,0)); END IF;
  RETURN 0;
END;
$function$
;
REVOKE ALL ON FUNCTION public._srd35_spell_level_for_class(text,text,integer) FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION public._srd35_character_class_level(text,text,text,integer) FROM PUBLIC,anon,authenticated;
UPDATE public.srd_spells s
SET dados_tecnicos=jsonb_set(
  COALESCE(s.dados_tecnicos,'{}'::jsonb),
  '{class_levels}',
  COALESCE((
    SELECT jsonb_object_agg(class_key,public._srd35_spell_level_for_class(s.nivel,class_key,s.circulo))
    FROM unnest(s.classes) AS class_key
  ),'{}'::jsonb),
  true
)
WHERE s.classes IS NOT NULL AND cardinality(s.classes)>0;
