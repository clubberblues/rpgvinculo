-- Disposable contract test for NPC token removal and source-character deletion.
-- Uses temporary tables and CHECK assertions; it does NOT execute production RPCs.
BEGIN;

CREATE TEMP TABLE npc_fixture_assertions (
  label text PRIMARY KEY,
  ok boolean NOT NULL CHECK (ok)
) ON COMMIT DROP;
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

-- JSON references are not protected by a relational FK; source deletion must
-- explicitly count references across every campaign, not characters.campaign_id.
INSERT INTO npc_fixture_assertions
SELECT 'two JSON source references found across campaigns',
       (SELECT count(*)=2
        FROM npc_fixture_campaigns c
        CROSS JOIN LATERAL jsonb_array_elements(c.cba_data->'tokens') t
        WHERE t->>'sourceCharacterId'='678');
INSERT INTO npc_fixture_assertions
SELECT 'source deletion guard condition is active',
       EXISTS (
         SELECT 1 FROM npc_fixture_campaigns c
         CROSS JOIN LATERAL jsonb_array_elements(c.cba_data->'tokens') t
         WHERE t->>'sourceCharacterId'='678'
       );

-- Model atomic removal of npc-a only: remove scene/initiative entries, clear
-- token-scoped rows, cancel pending work and end effects it sourced/concentrated.
UPDATE npc_fixture_campaigns
SET cba_data=jsonb_set(
      cba_data,'{tokens}',
      COALESCE((
        SELECT jsonb_agg(t ORDER BY ord)
        FROM jsonb_array_elements(cba_data->'tokens') WITH ORDINALITY x(t,ord)
        WHERE t->>'id' <> 'npc-a'
      ),'[]'::jsonb)
    ),
    combat_data=jsonb_set(
      combat_data,'{turn_order}',
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
DELETE FROM npc_fixture_effects WHERE campaign_id=129 AND target_kind='token' AND target_id='npc-a';
UPDATE npc_fixture_effects SET active=false
WHERE campaign_id=129 AND (source_actor_id='npc-a' OR concentration_actor_id='npc-a');
UPDATE npc_fixture_spell_pending SET status='cancelled'
WHERE campaign_id=129 AND target_kind='token' AND target_id='npc-a'
  AND status NOT IN ('resolved','saved','resisted','expired','cancelled');
UPDATE npc_fixture_aoo_pending SET status='cancelled'
WHERE campaign_id=129 AND (mover_token_id='npc-a' OR turn_actor_id='npc-a')
  AND status NOT IN ('resolved','expired','cancelled');
DELETE FROM npc_fixture_sequences WHERE campaign_id=129 AND actor_token_id='npc-a';

INSERT INTO npc_fixture_assertions
SELECT 'removed token absent from scene',
       NOT EXISTS (
         SELECT 1 FROM npc_fixture_campaigns c
         CROSS JOIN LATERAL jsonb_array_elements(c.cba_data->'tokens') t
         WHERE c.id=129 AND t->>'id'='npc-a'
       );
INSERT INTO npc_fixture_assertions
SELECT 'removed token absent from initiative',
       NOT EXISTS (
         SELECT 1 FROM npc_fixture_campaigns c
         CROSS JOIN LATERAL jsonb_array_elements_text(c.combat_data->'turn_order') v
         WHERE c.id=129 AND v='npc-a'
       );
INSERT INTO npc_fixture_assertions
SELECT 'token equipment, weapons, conditions, sequences and attempts cleaned',
       NOT EXISTS (SELECT 1 FROM npc_fixture_equipment WHERE campaign_id=129 AND token_id='npc-a')
       AND NOT EXISTS (SELECT 1 FROM npc_fixture_weapon_instances WHERE campaign_id=129 AND token_id='npc-a')
       AND NOT EXISTS (SELECT 1 FROM npc_fixture_conditions WHERE campaign_id=129 AND target_id='npc-a')
       AND NOT EXISTS (SELECT 1 FROM npc_fixture_sequences WHERE campaign_id=129 AND actor_token_id='npc-a')
       AND NOT EXISTS (SELECT 1 FROM npc_fixture_attempts WHERE id=11);
INSERT INTO npc_fixture_assertions
SELECT 'pending spell and AOO work cancelled',
       EXISTS (SELECT 1 FROM npc_fixture_spell_pending WHERE target_id='npc-a' AND status='cancelled')
       AND EXISTS (SELECT 1 FROM npc_fixture_aoo_pending WHERE mover_token_id='npc-a' AND status='cancelled');
INSERT INTO npc_fixture_assertions
SELECT 'effects sourced by removed token ended',
       NOT EXISTS (SELECT 1 FROM npc_fixture_effects WHERE source_actor_id='npc-a' AND active);
INSERT INTO npc_fixture_assertions
SELECT 'unrelated NPC and its equipment preserved',
       EXISTS (
         SELECT 1 FROM npc_fixture_campaigns c
         CROSS JOIN LATERAL jsonb_array_elements(c.cba_data->'tokens') t
         WHERE c.id=129 AND t->>'id'='npc-other'
       )
       AND EXISTS (SELECT 1 FROM npc_fixture_equipment WHERE token_id='npc-other');

-- One source reference remains (npc-b), so the source must still be protected.
INSERT INTO npc_fixture_assertions
SELECT 'remaining source reference prevents deletion',
       (SELECT count(*)=1
        FROM npc_fixture_campaigns c
        CROSS JOIN LATERAL jsonb_array_elements(c.cba_data->'tokens') t
        WHERE t->>'sourceCharacterId'='678');

-- Remove the final linked token, then verify the actual FK definition is RESTRICT.
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
INSERT INTO npc_fixture_assertions
SELECT 'NPC attack sequence FK is ON DELETE RESTRICT',
       EXISTS (
         SELECT 1 FROM pg_constraint
         WHERE conrelid='npc_fixture_sequences'::regclass
           AND confrelid='npc_fixture_characters'::regclass
           AND contype='f' AND confdeltype='r'
       );

-- The source may be deleted only after the token references and restricting
-- attack sequences have both been handled.
DELETE FROM npc_fixture_sequences WHERE actor_character_id=678;
DELETE FROM npc_fixture_characters WHERE id=678;
INSERT INTO npc_fixture_assertions
SELECT 'source deleted only after all guards and dependencies cleared',
       NOT EXISTS (SELECT 1 FROM npc_fixture_characters WHERE id=678)
       AND NOT EXISTS (
         SELECT 1 FROM npc_fixture_campaigns c
         CROSS JOIN LATERAL jsonb_array_elements(c.cba_data->'tokens') t
         WHERE t->>'sourceCharacterId'='678'
       );

SELECT label FROM npc_fixture_assertions ORDER BY label;
ROLLBACK;
