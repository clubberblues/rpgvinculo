CREATE OR REPLACE FUNCTION public._srd35_class_key(p_value text)
RETURNS text
LANGUAGE sql
IMMUTABLE
PARALLEL SAFE
SET search_path TO 'pg_catalog','public'
AS $function$
  SELECT CASE translate(lower(trim(coalesce(p_value,''))), 'áéíóúãõâêôç', 'aeiouaoaeoc')
    WHEN 'wizard' THEN 'wizard' WHEN 'mago' THEN 'wizard'
    WHEN 'sorcerer' THEN 'sorcerer' WHEN 'feiticeiro' THEN 'sorcerer'
    WHEN 'cleric' THEN 'cleric' WHEN 'clerigo' THEN 'cleric' WHEN 'sacerdote' THEN 'cleric'
    WHEN 'druid' THEN 'druid' WHEN 'druida' THEN 'druid'
    WHEN 'bard' THEN 'bard' WHEN 'bardo' THEN 'bard'
    WHEN 'paladin' THEN 'paladin' WHEN 'paladino' THEN 'paladin'
    WHEN 'ranger' THEN 'ranger' WHEN 'patrulheiro' THEN 'ranger'
    ELSE NULL
  END
$function$;