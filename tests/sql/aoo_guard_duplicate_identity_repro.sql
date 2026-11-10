-- Disposable behavioral reproducer for the installed AOO movement guard.
-- This copies the current trigger algorithm from priv.srd_guard_pending_aoo_movement
-- (OID 26962) into an isolated schema. It does NOT connect to Supabase or execute
-- the installed function/RPC. A green run means the documented bypass is reproduced.
BEGIN;
DROP SCHEMA IF EXISTS aoo_fixture CASCADE;
CREATE SCHEMA aoo_fixture;

CREATE TABLE aoo_fixture.campaigns (
  id bigint PRIMARY KEY,
  cba_data jsonb NOT NULL
);
CREATE TABLE aoo_fixture.pending_movements (
  pending_id uuid PRIMARY KEY,
  campaign_id bigint NOT NULL REFERENCES aoo_fixture.campaigns(id),
  mover_token_id text NOT NULL,
  status text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE FUNCTION aoo_fixture.guard_pending_aoo_movement()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  v_pending aoo_fixture.pending_movements%ROWTYPE;
  v_old_token jsonb;
  v_new_token jsonb;
  v_commit_id text;
BEGIN
  IF NEW.cba_data IS NOT DISTINCT FROM OLD.cba_data THEN RETURN NEW; END IF;

  SELECT * INTO v_pending
  FROM aoo_fixture.pending_movements p
  WHERE p.campaign_id=NEW.id
    AND p.status IN ('waiting_reactions','ready_to_commit')
  ORDER BY p.created_at DESC
  LIMIT 1;
  IF NOT FOUND THEN RETURN NEW; END IF;

  SELECT t INTO v_old_token
  FROM jsonb_array_elements(
    CASE WHEN jsonb_typeof(OLD.cba_data->'tokens')='array'
      THEN OLD.cba_data->'tokens' ELSE '[]'::jsonb END
  ) t
  WHERE t->>'id'=v_pending.mover_token_id
     OR t->>'key'=v_pending.mover_token_id
  LIMIT 1;

  SELECT t INTO v_new_token
  FROM jsonb_array_elements(
    CASE WHEN jsonb_typeof(NEW.cba_data->'tokens')='array'
      THEN NEW.cba_data->'tokens' ELSE '[]'::jsonb END
  ) t
  WHERE t->>'id'=v_pending.mover_token_id
     OR t->>'key'=v_pending.mover_token_id
  LIMIT 1;

  v_commit_id:=current_setting('app.srd_aoo_pending_commit',true);

  IF v_old_token IS NOT NULL AND v_new_token IS NULL
     AND v_commit_id IS DISTINCT FROM v_pending.pending_id::text THEN
    RAISE EXCEPTION 'Remoção do token bloqueada: há um movimento aguardando resolução de ataques de oportunidade.';
  END IF;

  IF v_old_token IS NOT NULL AND v_new_token IS NOT NULL
     AND ((v_old_token->>'gridX') IS DISTINCT FROM (v_new_token->>'gridX')
       OR (v_old_token->>'gridY') IS DISTINCT FROM (v_new_token->>'gridY')) THEN
    IF v_commit_id IS DISTINCT FROM v_pending.pending_id::text THEN
      RAISE EXCEPTION 'Movimento bloqueado: há um ataque de oportunidade pendente de resolução.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER guard_pending_aoo
BEFORE UPDATE OF cba_data ON aoo_fixture.campaigns
FOR EACH ROW EXECUTE FUNCTION aoo_fixture.guard_pending_aoo_movement();

INSERT INTO aoo_fixture.campaigns(id,cba_data) VALUES (
  1,
  jsonb_build_object('tokens',jsonb_build_array(
    jsonb_build_object('id','mover','key','mover','gridX',1,'gridY',1,'name','Mover'),
    jsonb_build_object('id','threat','key','threat','gridX',4,'gridY',1,'name','Threat')
  ))
);
INSERT INTO aoo_fixture.pending_movements(
  pending_id,campaign_id,mover_token_id,status
) VALUES (
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',1,'mover','waiting_reactions'
);

-- Control: a unique mover cannot change coordinates through a generic writer.
DO $$
DECLARE blocked boolean:=false;
BEGIN
  BEGIN
    UPDATE aoo_fixture.campaigns
       SET cba_data=jsonb_set(cba_data,'{tokens,0,gridX}','2'::jsonb)
     WHERE id=1;
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM LIKE 'Movimento bloqueado:%' THEN blocked:=true;
    ELSE RAISE;
    END IF;
  END;
  IF NOT blocked THEN RAISE EXCEPTION 'Fixture error: unique mover coordinate change was not blocked'; END IF;
  RAISE NOTICE 'control passed: direct coordinate change of unique mover is blocked';
END;
$$;

-- Control: a non-geometric token metadata update remains allowed by the current guard.
UPDATE aoo_fixture.campaigns
SET cba_data=jsonb_set(cba_data,'{tokens,0,name}','"Mover atualizado"'::jsonb)
WHERE id=1;

-- Known bypass: requested order puts the unchanged duplicate first and the moved
-- duplicate second. The copied trigger LIMIT 1 compares only the first match.
UPDATE aoo_fixture.campaigns
SET cba_data=jsonb_set(cba_data,'{tokens}',jsonb_build_array(
  jsonb_build_object('id','mover','key','mover','gridX',1,'gridY',1,'name','Mover origem'),
  jsonb_build_object('id','mover','key','mover','gridX',2,'gridY',1,'name','Mover duplicado'),
  jsonb_build_object('id','threat','key','threat','gridX',4,'gridY',1,'name','Threat')
))
WHERE id=1;

DO $$
DECLARE n integer; moved_x text;
BEGIN
  SELECT count(*)::integer INTO n
  FROM jsonb_array_elements((SELECT cba_data->'tokens' FROM aoo_fixture.campaigns WHERE id=1)) t
  WHERE t->>'id'='mover' OR t->>'key'='mover';
  SELECT t->>'gridX' INTO moved_x
  FROM jsonb_array_elements((SELECT cba_data->'tokens' FROM aoo_fixture.campaigns WHERE id=1)) t
  WHERE (t->>'id'='mover' OR t->>'key'='mover') AND t->>'name'='Mover duplicado';
  IF n<>2 OR moved_x<>'2' THEN
    RAISE EXCEPTION 'Expected duplicate-identity bypass was not reproduced (count %, moved x %)',n,moved_x;
  END IF;
  RAISE NOTICE 'known bypass reproduced: duplicate mover identity persisted with second copy at x=%',moved_x;
END;
$$;

-- The guard also leaves other tokens' coordinates mutable while a mover is pending.
UPDATE aoo_fixture.campaigns
SET cba_data=jsonb_set(cba_data,'{tokens,2,gridX}','5'::jsonb)
WHERE id=1;

DO $$
DECLARE x text;
BEGIN
  SELECT t->>'gridX' INTO x
  FROM jsonb_array_elements((SELECT cba_data->'tokens' FROM aoo_fixture.campaigns WHERE id=1)) t
  WHERE t->>'id'='threat';
  IF x<>'5' THEN RAISE EXCEPTION 'Expected threat-token movement gap was not reproduced'; END IF;
  RAISE NOTICE 'known gap reproduced: non-mover token geometry changed while pending';
END;
$$;

-- The guard also permits changes to threat-defining faction and melee reach.
UPDATE aoo_fixture.campaigns
SET cba_data=jsonb_set(
  jsonb_set(cba_data,'{tokens,2,combat_faction}','"ally"'::jsonb,true),
  '{tokens,2,melee_reach_ft}','0'::jsonb,true
)
WHERE id=1;

DO $$
DECLARE faction text; reach text;
BEGIN
  SELECT t->>'combat_faction',t->>'melee_reach_ft' INTO faction,reach
  FROM jsonb_array_elements((SELECT cba_data->'tokens' FROM aoo_fixture.campaigns WHERE id=1)) t
  WHERE t->>'id'='threat';
  IF faction<>'ally' OR reach<>'0' THEN
    RAISE EXCEPTION 'Expected threat-profile mutation gap was not reproduced';
  END IF;
  RAISE NOTICE 'known gap reproduced: faction and melee reach changed while pending';
END;
$$;

-- A newly spawned token can also enter the scene while the movement is pending.
UPDATE aoo_fixture.campaigns
SET cba_data=jsonb_set(
  cba_data,'{tokens}',
  (cba_data->'tokens') || jsonb_build_array(
    jsonb_build_object('id','new-threat','key','new-threat','gridX',7,'gridY',1,
      'combat_faction','hostile','melee_reach_ft',10)
  ),true
)
WHERE id=1;

DO $$
DECLARE n integer;
BEGIN
  SELECT count(*)::integer INTO n
  FROM jsonb_array_elements((SELECT cba_data->'tokens' FROM aoo_fixture.campaigns WHERE id=1)) t
  WHERE t->>'id'='new-threat';
  IF n<>1 THEN RAISE EXCEPTION 'Expected token-spawn gap was not reproduced'; END IF;
  RAISE NOTICE 'known gap reproduced: new threatening token added while pending';
END;
$$;

ROLLBACK;
