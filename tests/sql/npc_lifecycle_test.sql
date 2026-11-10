-- Disposable contract test for NPC token removal and source-character deletion.
-- This models the required invariants; it does NOT execute production RPCs.
BEGIN;

CREATE TEMP TABLE npc_fixture_campaigns (
  id integer PRIMARY KEY,
  cba_data jsonb NOT NULL,
  combat_data jsonb NOT NULL
) ON COMMIT DROP;
CREATE TEMP TABLE npc_fixture_characters (
  id integer PRIMARY KEY,
  campaign_id integer
) ON COMMIT DROP;
CREATE TEMP TABLE npc_fixture_sequences (
  id integer PRIMARY KEY,
  campaign_id integer NOT NULL,
  actor_character_id integer NOT NULL REFERENCES npc_fixture_characters(id) ON DELETE RESTRICT,
  actor_token_id text NOT NULL,
  status text NOT NULL
) ON COMMIT DROP;
CREATE TEMP TABLE npc_fixture_attempts (
  id integer PRIMARY KEY,
  sequence_id integer NOT NULL REFERENCES npc_fixture_sequences(id) ON DELETE CASCADE,
  status text NOT NULL
) ON COMMIT DROP;
CREATE TEMP TABLE npc_fixture_equipment (
  campaign_id integer NOT NULL,
  token_id text NOT NULL,
  item_id text NOT NULL,
  PRIMARY KEY (campaign_id,token_id,item_id)
) ON COMMIT DROP;
CREATE TEMP TABLE npc_fixture_weapon_instances (
  campaign_id integer NOT NULL,
  token_id text NOT NULL,
  instance_id text NOT NULL,
  PRIMARY KEY (campaign_id,token_id,instance_id)
) ON COMMIT DROP;
CREATE TEMP TABLE npc_fixture_conditions (
  campaign_id integer NOT NULL,
  target_kind text NOT NULL,
  target_id text NOT NULL,
  condition_id text NOT NULL,
  PRIMARY KEY (campaign_id,target_kind,target_id,condition_id)
) ON COMMIT DROP;
CREATE TEMP TABLE npc_fixture_effects (
  campaign_id integer NOT NULL,
  target_kind text NOT NULL,
  target_id text NOT NULL,
  source_actor_id text,
  concentration_actor_id text,
  active boolean NOT NULL DEFAULT true,
  PRIMARY KEY (campaign_id,target_kind,target_id)
) ON COMMIT DROP;
CREATE TEMP TABLE npc_fixture_spell_pending (
  campaign_id integer NOT NULL,
  target_kind text NOT NULL,
  target_id text NOT NULL,
  status text NOT NULL
) ON COMMIT DROP;
CREATE TEMP TABLE npc_fixture_aoo_pending (
  campaign_id integer NOT NULL,
  mover_token_id text,
  turn_actor_id text,
  status text NOT NULL
) ON COMMIT DROP;

INSERT INTO npc_fixture_characters VALUES (678,NULL),(681,NULL);
INSERT INTO npc_fixture_campaigns VALUES
(129,
 jsonb_build_object('tokens',jsonb_build_array(
   jsonb_build_object('id','npc-a','tipo','npc','sourceCharacterId','678'),
   jsonb_build_object('id','npc-b','tipo','npc','sourceCharacterId','678'),
   jsonb_build_object('id','npc-other','tipo','npc','sourceCharacterId','681')
 )),
 jsonb_build_object('turn_order',jsonb_build_array('npc-a','npc-b','npc-other'),'current_turn',0)),
(131,
 jsonb_build_object('tokens',jsonb_build_array(
   jsonb_build_object('id','npc-c','tipo','npc','sourceCharacterId','681')
 )),
 jsonb_build_object('turn_order',jsonb_build_array('npc-c'),'current_turn',0));

INSERT INTO npc_fixture_sequences VALUES
(1,129,678,'npc-a','active'),
(2,129,681,'npc-other','active');
INSERT INTO npc_fixture_attempts VALUES (11,1,'pending'),(22,2,'pending');
INSERT INTO npc_fixture_equipment VALUES
(129,'npc-a','sword'),(129,'npc-other','shield');
INSERT INTO npc_fixture_weapon_instances VALUES
(129,'npc-a','weapon-a'),(129,'npc-other','weapon-other');
INSERT INTO npc_fixture_conditions VALUES
(129,'token','npc-a','prone'),(129,'token','npc-other','fatigued');
INSERT INTO npc_fixture_effects VALUES
(129,'token','npc-a','npc-other',NULL,true),
(129,'token','npc-other','npc-a',NULL,true);
INSERT INTO npc_fixture_spell_pending VALUES
(129,'token','npc-a','awaiting_save'),(129,'token','npc-other','awaiting_save');
INSERT INTO npc_fixture_aoo_pending VALUES
(129,'npc-a','npc-a','waiting_reactions'),
(129,'npc-other','npc-other','waiting_reactions');

-- Source deletion must be rejected while any campaign JSON token still references it,
-- including references in campaigns other than characters.campaign_id.
DO $fixture$
DECLARE linked_count integer;
BEGIN
  SELECT count(*) INTO linked_count
  FROM npc_fixture_campaigns c
  CROSS JOIN LATERAL jsonb_array_elements(c.cba_data->'tokens') t
  WHERE t->>'sourceCharacterId'='678';
  IF linked_count <> 2 THEN
    RAISE EXCEPTION 'expected two cross-campaign source references, found %',linked_count;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM npc_fixture_sequences WHERE actor_character_id=678) THEN
    RAISE EXCEPTION 'RESTRICT dependency fixture missing';
  END IF;
END $fixture$;

-- Exercise the JSON reference guard itself: the character row has no FK from
-- cba_data, so the deletion contract must reject it explicitly.
DO $fixture$
DECLARE rejected boolean := false;
BEGIN
  BEGIN
    IF EXISTS (
      SELECT 1
      FROM npc_fixture_campaigns c
      CROSS JOIN LATERAL jsonb_array_elements(c.cba_data->'tokens') t
      WHERE t->>'sourceCharacterId'='678'
    ) THEN
      RAISE EXCEPTION USING ERRCODE='P0001', MESSAGE='source_character_has_linked_tokens';
    END IF;
    DELETE FROM npc_fixture_characters WHERE id=678;
  EXCEPTION WHEN SQLSTATE 'P0001' THEN
    IF SQLERRM <> 'source_character_has_linked_tokens' THEN RAISE; END IF;
    rejected := true;
  END;
  IF NOT rejected OR NOT EXISTS (SELECT 1 FROM npc_fixture_characters WHERE id=678) THEN
    RAISE EXCEPTION 'source deletion was not blocked while JSON token references exist';
  END IF;
END $fixture$;

-- Model the atomic "remove NPC token" contract for npc-a only:
-- remove scene/initiative entries, clear token-scoped rows, cancel pending work,
-- and terminate effects for which the removed token was the source/concentrator.
UPDATE npc_fixture_campaigns
SET cba_data = jsonb_set(
      cba_data,
      '{tokens}',
      COALESCE((
        SELECT jsonb_agg(t ORDER BY ord)
        FROM jsonb_array_elements(cba_data->'tokens') WITH ORDINALITY x(t,ord)
        WHERE t->>'id' <> 'npc-a'
      ),'[]'::jsonb)
    ),
    combat_data = jsonb_set(
      combat_data,
      '{turn_order}',
      COALESCE((
        SELECT jsonb_agg(v ORDER BY ord)
        FROM jsonb_array_elements_text(combat_data->'turn_order') WITH ORDINALITY x(v,ord)
        WHERE v <> 'npc-a'
      ),'[]'::jsonb)
    )
WHERE id=129;

DELETE FROM npc_fixture_equipment WHERE campaign_id=129 AND token_id='npc-a';
DELETE FROM npc_fixture_weapon_instances WHERE campaign_id=129 AND token_id='npc-a';
DELETE FROM npc_fixture_conditions WHERE campaign_id=129 AND target_kind='token' AND target_id='npc-a';
DELETE FROM npc_fixture_effects
 WHERE campaign_id=129 AND target_kind='token' AND target_id='npc-a';
UPDATE npc_fixture_effects
SET active=false
WHERE campaign_id=129 AND (source_actor_id='npc-a' OR concentration_actor_id='npc-a');
UPDATE npc_fixture_spell_pending
SET status='cancelled'
WHERE campaign_id=129 AND target_kind='token' AND target_id='npc-a'
  AND status NOT IN ('resolved','saved','resisted','expired','cancelled');
UPDATE npc_fixture_aoo_pending
SET status='cancelled'
WHERE campaign_id=129 AND (mover_token_id='npc-a' OR turn_actor_id='npc-a')
  AND status NOT IN ('resolved','expired','cancelled');
DELETE FROM npc_fixture_sequences WHERE campaign_id=129 AND actor_token_id='npc-a';
-- Attempts are removed only by the sequence FK cascade.

DO $fixture$
BEGIN
  IF EXISTS (
    SELECT 1 FROM npc_fixture_campaigns c
    CROSS JOIN LATERAL jsonb_array_elements(c.cba_data->'tokens') t
    WHERE c.id=129 AND t->>'id'='npc-a'
  ) THEN RAISE EXCEPTION 'removed token remains in scene'; END IF;
  IF EXISTS (
    SELECT 1 FROM npc_fixture_campaigns c
    CROSS JOIN LATERAL jsonb_array_elements_text(c.combat_data->'turn_order') v
    WHERE c.id=129 AND v='npc-a'
  ) THEN RAISE EXCEPTION 'removed token remains in initiative'; END IF;
  IF EXISTS (SELECT 1 FROM npc_fixture_equipment WHERE campaign_id=129 AND token_id='npc-a')
     OR EXISTS (SELECT 1 FROM npc_fixture_weapon_instances WHERE campaign_id=129 AND token_id='npc-a')
     OR EXISTS (SELECT 1 FROM npc_fixture_conditions WHERE campaign_id=129 AND target_id='npc-a')
     OR EXISTS (SELECT 1 FROM npc_fixture_sequences WHERE campaign_id=129 AND actor_token_id='npc-a')
     OR EXISTS (SELECT 1 FROM npc_fixture_attempts WHERE id=11) THEN
    RAISE EXCEPTION 'token-owned relational rows were not fully cleaned';
  END IF;
  IF EXISTS (SELECT 1 FROM npc_fixture_spell_pending WHERE target_id='npc-a' AND status<>'cancelled')
     OR EXISTS (SELECT 1 FROM npc_fixture_aoo_pending WHERE mover_token_id='npc-a' AND status<>'cancelled') THEN
    RAISE EXCEPTION 'pending token actions were not cancelled';
  END IF;
  IF EXISTS (SELECT 1 FROM npc_fixture_effects WHERE source_actor_id='npc-a' AND active) THEN
    RAISE EXCEPTION 'effects sourced by removed token remain active';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM npc_fixture_campaigns c
    CROSS JOIN LATERAL jsonb_array_elements(c.cba_data->'tokens') t
    WHERE c.id=129 AND t->>'id'='npc-other'
  ) OR NOT EXISTS (SELECT 1 FROM npc_fixture_equipment WHERE token_id='npc-other') THEN
    RAISE EXCEPTION 'unrelated token state was modified';
  END IF;
END $fixture$;

-- The remaining npc-b reference still prevents source-character deletion.
DO $fixture$
DECLARE linked_count integer;
BEGIN
  SELECT count(*) INTO linked_count
  FROM npc_fixture_campaigns c
  CROSS JOIN LATERAL jsonb_array_elements(c.cba_data->'tokens') t
  WHERE t->>'sourceCharacterId'='678';
  IF linked_count <> 1 THEN
    RAISE EXCEPTION 'expected one remaining source reference, found %',linked_count;
  END IF;
END $fixture$;

-- Remove the final linked token, then delete the source. The RESTRICT sequence
-- dependency must also be explicitly handled before deleting the source record.
UPDATE npc_fixture_campaigns
SET cba_data=jsonb_set(
  cba_data,'{tokens}',
  COALESCE((
    SELECT jsonb_agg(t ORDER BY ord)
    FROM jsonb_array_elements(cba_data->'tokens') WITH ORDINALITY x(t,ord)
    WHERE t->>'id' <> 'npc-b'
  ),'[]'::jsonb)
)
WHERE id=129;
-- Even after JSON references are gone, the real FK contract blocks source
-- deletion while a persisted NPC attack sequence still references it.
DO $npc$
DECLARE blocked boolean := false;
BEGIN
  BEGIN
    DELETE FROM npc_fixture_characters WHERE id=678;
  EXCEPTION WHEN foreign_key_violation THEN
    blocked := true;
  END;
  IF NOT blocked OR NOT EXISTS (SELECT 1 FROM npc_fixture_characters WHERE id=678) THEN
    RAISE EXCEPTION 'NPC sequence FK did not protect the source character';
  END IF;
END $npc$;

DELETE FROM npc_fixture_sequences WHERE actor_character_id=678;
DELETE FROM npc_fixture_characters WHERE id=678;

DO $fixture$
BEGIN
  IF EXISTS (SELECT 1 FROM npc_fixture_characters WHERE id=678) THEN
    RAISE EXCEPTION 'source character was not deleted after all guards/dependencies cleared';
  END IF;
  IF EXISTS (
    SELECT 1 FROM npc_fixture_campaigns c
    CROSS JOIN LATERAL jsonb_array_elements(c.cba_data->'tokens') t
    WHERE t->>'sourceCharacterId'='678'
  ) THEN RAISE EXCEPTION 'dangling sourceCharacterId remains'; END IF;
END $fixture$;

ROLLBACK;
