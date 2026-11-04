-- D&D 3.5 Paladin: Divine Grace verification
-- Safe, read-only verification. Does not create or modify characters.
DO $verify_divine_grace$
DECLARE
  v_expected integer;
  v_score integer;
  v_cases integer := 0;
BEGIN
  FOR v_score, v_expected IN
    SELECT * FROM (VALUES
      (8, 0),
      (10, 0),
      (12, 1),
      (14, 2),
      (18, 4),
      (20, 5)
    ) AS cases(charisma_score, expected_bonus)
  LOOP
    IF GREATEST(0, FLOOR((v_score - 10)::numeric / 2)::integer) <> v_expected THEN
      RAISE EXCEPTION 'Divine Grace formula failed for Charisma %', v_score;
    END IF;
    v_cases := v_cases + 1;
  END LOOP;

  IF NOT EXISTS (
    SELECT 1
    FROM public.srd_class_level_features
    WHERE class_id = 'paladino'
      AND class_level = 2
      AND feature_key = 'features'
      AND mechanics->'implemented_features' ? 'divine_grace'
      AND mechanics->'pending_features' ? 'lay_on_hands'
  ) THEN
    RAISE EXCEPTION 'Paladin level 2 feature catalog is not marked with the expected partial implementation.';
  END IF;

  IF position(
    'v_paladin_level>=2'
    IN pg_get_functiondef('priv.srd_saving_throw_bonus(bigint,text,text,text,text)'::regprocedure)
  ) = 0 THEN
    RAISE EXCEPTION 'Divine Grace is not connected to the saving throw resolver.';
  END IF;

  RAISE NOTICE 'Divine Grace verification passed: % Charisma cases.', v_cases;
END;
$verify_divine_grace$;
