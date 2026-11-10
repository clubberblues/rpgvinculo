CREATE OR REPLACE FUNCTION priv.srd_expire_barbarian_rage_on_round_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_old_round integer;
  v_new_round integer;
  v_rage record;
  v_result jsonb;
BEGIN
  IF TG_OP <> 'UPDATE'
     OR UPPER(COALESCE(OLD.state,'')) <> 'COMBATE'
     OR UPPER(COALESCE(NEW.state,'')) <> 'COMBATE'
     OR COALESCE(NEW.combat_data->>'active','false') <> 'true'
     OR COALESCE(OLD.combat_data->>'round','') !~ '^[0-9]+$'
     OR COALESCE(NEW.combat_data->>'round','') !~ '^[0-9]+$' THEN
    RETURN NEW;
  END IF;

  v_old_round := (OLD.combat_data->>'round')::integer;
  v_new_round := (NEW.combat_data->>'round')::integer;
  IF v_new_round <= v_old_round THEN
    RETURN NEW;
  END IF;

  FOR v_rage IN
    SELECT effect_instance_id, target_id
      FROM public.srd_campaign_effects
     WHERE campaign_id=NEW.id
       AND target_kind='character'
       AND active=true
       AND effect_data->>'source_feature'='barbarian_rage'
       AND expires_round IS NOT NULL
       AND expires_round <= v_new_round
     ORDER BY effect_instance_id
     FOR UPDATE
  LOOP
    v_result := priv.srd_end_barbarian_rage(NEW.id,v_rage.target_id,true);
    IF COALESCE((v_result->>'ended')::boolean,false) THEN
      PERFORM priv.log(NEW.id,'CLASS_FEATURE',jsonb_build_object(
        'feature_key','barbarian_rage',
        'action','expire',
        'character_id',v_rage.target_id,
        'effect_instance_id',v_rage.effect_instance_id,
        'round',v_new_round,
        'rage_hp_removed',v_result->'rage_hp_removed',
        'fatigue_applied',v_result->'fatigue_applied'
      ));
    END IF;
  END LOOP;

  RETURN NEW;
END;
$function$;

REVOKE ALL ON FUNCTION priv.srd_expire_barbarian_rage_on_round_change() FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS trg_expire_barbarian_rage_on_round_change ON public.campaigns;
CREATE TRIGGER trg_expire_barbarian_rage_on_round_change
AFTER UPDATE OF combat_data ON public.campaigns
FOR EACH ROW
WHEN (OLD.combat_data IS DISTINCT FROM NEW.combat_data)
EXECUTE FUNCTION priv.srd_expire_barbarian_rage_on_round_change();

COMMENT ON FUNCTION priv.srd_expire_barbarian_rage_on_round_change()
IS 'Encerra automaticamente Fúria quando a rodada de expiração é alcançada, removendo PV temporários e aplicando fadiga conforme o nível de Bárbaro.';