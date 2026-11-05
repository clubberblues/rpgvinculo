-- Aplica o bônus de Toughness (+3 PV) quando o talento é adquirido.
-- Cada cópia acumula; alterações de talentos ajustam PV máximo e PV atual.
-- O gatilho observa apenas alterações na lista de talentos e não recalcula fichas antigas.
CREATE OR REPLACE FUNCTION public.srd_apply_toughness_hp_delta()
RETURNS trigger
LANGUAGE plpgsql
SET search_path TO 'pg_catalog','public','pg_temp'
AS $function$
DECLARE
  v_old_count integer := 0;
  v_new_count integer := 0;
  v_delta integer := 0;
  v_new_max integer := 0;
  v_new_current integer := 0;
BEGIN
  IF TG_OP='UPDATE' THEN
    SELECT count(*)::integer INTO v_old_count
      FROM jsonb_array_elements(
        CASE WHEN jsonb_typeof(OLD.talentos)='array' THEN OLD.talentos ELSE '[]'::jsonb END
      ) AS feat(value)
     WHERE COALESCE(feat.value->>'id',feat.value #>> '{}')='tenacidade';
  END IF;

  SELECT count(*)::integer INTO v_new_count
    FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(NEW.talentos)='array' THEN NEW.talentos ELSE '[]'::jsonb END
    ) AS feat(value)
   WHERE COALESCE(feat.value->>'id',feat.value #>> '{}')='tenacidade';

  v_delta := (v_new_count-v_old_count)*3;
  IF v_delta=0 THEN RETURN NEW; END IF;

  v_new_max := COALESCE(NEW.pv_max,CASE WHEN TG_OP='UPDATE' THEN OLD.pv_max END,0);
  v_new_current := COALESCE(
    NEW.pv_atual,
    CASE WHEN TG_OP='UPDATE' THEN OLD.pv_atual END,
    v_new_max
  );

  NEW.pv_max := GREATEST(1,v_new_max+v_delta);
  NEW.pv_atual := GREATEST(0,LEAST(NEW.pv_max,v_new_current+v_delta));
  RETURN NEW;
END;
$function$;

DROP TRIGGER IF EXISTS trg_srd_toughness_hp_delta ON public.srd_character_sheets;
CREATE TRIGGER trg_srd_toughness_hp_delta
BEFORE INSERT OR UPDATE OF talentos
ON public.srd_character_sheets
FOR EACH ROW
EXECUTE FUNCTION public.srd_apply_toughness_hp_delta();
