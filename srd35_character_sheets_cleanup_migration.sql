-- Vínculo · saneamento após a remoção de public.character_sheets
-- Execute no SQL Editor do Supabase depois de confirmar que as tabelas
-- public.srd_character_sheets e public.vinculo_character_sheets existem.
-- O script não apaga personagens nem dados.

BEGIN;

-- 1) Diagnóstico: triggers públicos cuja função referencia a relação antiga exata.
SELECT
  table_schema.nspname AS trigger_schema,
  table_name.relname AS trigger_table,
  trigger_row.tgname AS trigger_name,
  function_row.oid::REGPROCEDURE AS trigger_function,
  pg_get_triggerdef(trigger_row.oid) AS trigger_definition,
  pg_get_functiondef(function_row.oid) AS function_definition
FROM pg_trigger AS trigger_row
JOIN pg_class AS table_name ON table_name.oid = trigger_row.tgrelid
JOIN pg_namespace AS table_schema ON table_schema.oid = table_name.relnamespace
JOIN pg_proc AS function_row ON function_row.oid = trigger_row.tgfoid
WHERE NOT trigger_row.tgisinternal
  AND table_schema.nspname = 'public'
  AND pg_get_functiondef(function_row.oid) ~* '(^|[^[:alnum:]_])(public[.])?"?character_sheets"?([^[:alnum:]_]|$)';

-- 2) Remove apenas triggers cujo corpo referencia a relação antiga exata.
-- Limites de identificador impedem correspondência com srd_character_sheets
-- e vinculo_character_sheets.
DO $$
DECLARE
  stale_trigger RECORD;
BEGIN
  FOR stale_trigger IN
    SELECT
      table_schema.nspname AS table_schema,
      table_name.relname AS table_name,
      trigger_row.tgname AS trigger_name,
      function_row.oid::REGPROCEDURE AS function_name
    FROM pg_trigger AS trigger_row
    JOIN pg_class AS table_name ON table_name.oid = trigger_row.tgrelid
    JOIN pg_namespace AS table_schema ON table_schema.oid = table_name.relnamespace
    JOIN pg_proc AS function_row ON function_row.oid = trigger_row.tgfoid
    WHERE NOT trigger_row.tgisinternal
      AND table_schema.nspname = 'public'
      AND pg_get_functiondef(function_row.oid) ~* '(^|[^[:alnum:]_])(public[.])?"?character_sheets"?([^[:alnum:]_]|$)'
  LOOP
    RAISE NOTICE 'Removendo trigger obsoleto %.% (%), função %',
      stale_trigger.table_schema,
      stale_trigger.table_name,
      stale_trigger.trigger_name,
      stale_trigger.function_name;
    EXECUTE format(
      'DROP TRIGGER %I ON %I.%I',
      stale_trigger.trigger_name,
      stale_trigger.table_schema,
      stale_trigger.table_name
    );
  END LOOP;
END;
$$;

-- 3) Lista os triggers remanescentes de public.characters. O trigger SRD
-- correto de limpeza ocorre BEFORE DELETE e usa srd_character_sheets.
SELECT
  trigger_row.tgname AS trigger_name,
  function_row.oid::REGPROCEDURE AS trigger_function,
  pg_get_triggerdef(trigger_row.oid) AS trigger_definition,
  pg_get_functiondef(function_row.oid) AS function_definition
FROM pg_trigger AS trigger_row
JOIN pg_class AS table_name ON table_name.oid = trigger_row.tgrelid
JOIN pg_namespace AS table_schema ON table_schema.oid = table_name.relnamespace
JOIN pg_proc AS function_row ON function_row.oid = trigger_row.tgfoid
WHERE NOT trigger_row.tgisinternal
  AND table_schema.nspname = 'public'
  AND table_name.relname = 'characters'
ORDER BY trigger_row.tgname;

-- 4) Diagnóstico de RPCs/helpers públicos que ainda mencionem a relação antiga.
-- Não os remove automaticamente: revise qualquer linha retornada antes de
-- permitir que essa função volte a ser chamada.
SELECT
  namespace_row.nspname AS function_schema,
  function_row.oid::REGPROCEDURE AS function_signature,
  pg_get_functiondef(function_row.oid) AS function_definition
FROM pg_proc AS function_row
JOIN pg_namespace AS namespace_row ON namespace_row.oid = function_row.pronamespace
WHERE namespace_row.nspname = 'public'
  AND function_row.prokind IN ('f', 'p')
  AND pg_get_functiondef(function_row.oid) ~* '(^|[^[:alnum:]_])(public[.])?"?character_sheets"?([^[:alnum:]_]|$)'
ORDER BY function_row.proname;

COMMIT;
