#!/usr/bin/env bash
set -euo pipefail

: "${PGHOST:=127.0.0.1}"
: "${PGPORT:=5432}"
: "${PGUSER:=postgres}"
: "${PGDATABASE:=vinculo_test}"
: "${PGPASSWORD:=postgres}"
export PGHOST PGPORT PGUSER PGDATABASE PGPASSWORD

psql -v ON_ERROR_STOP=1 -f tests/sql/lock_cycle_setup.sql

# Synthetic lock-order regressions. Each pair models a documented reachable
# prefix or an explicitly conditional future path; none executes production RPCs.
run_expected_deadlock() {
  local label="$1"
  local session_a="$2"
  local session_b="$3"
  local tmp
  tmp="$(mktemp -d)"
  psql -v ON_ERROR_STOP=1 >"$tmp/a.log" 2>&1 <<<"$session_a" &
  local a=$!
  sleep 0.2
  psql -v ON_ERROR_STOP=1 >"$tmp/b.log" 2>&1 <<<"$session_b" &
  local b=$!
  set +e
  wait "$a"; local sa=$?
  wait "$b"; local sb=$?
  set -e
  if [[ "$sa" -eq 0 && "$sb" -eq 0 ]] || [[ "$sa" -ne 0 && "$sb" -ne 0 ]] ||
     ! grep -qi 'deadlock detected' "$tmp/a.log" "$tmp/b.log"; then
    echo "FAIL: $label did not produce exactly one PostgreSQL deadlock victim"
    cat "$tmp/a.log" "$tmp/b.log"
    rm -rf "$tmp"
    exit 1
  fi
  echo "passed synthetic lock inversion: $label"
  rm -rf "$tmp"
}


run_expected_deadlock "campaign -> weapon instance versus weapon instance -> campaign (iterative attack start versus resolution)" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
UPDATE lock_fixture.campaigns SET round_number=round_number+1 WHERE id=1;
SELECT pg_sleep(0.6);
SELECT id FROM lock_fixture.weapon_instances WHERE id=1 FOR SHARE;
COMMIT;
" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
SELECT id FROM lock_fixture.weapon_instances WHERE id=1 FOR UPDATE;
SELECT pg_sleep(0.3);
UPDATE lock_fixture.campaigns SET round_number=round_number+1 WHERE id=1;
COMMIT;
"

run_expected_deadlock "campaign -> character versus character -> campaign" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
UPDATE lock_fixture.campaigns SET round_number=round_number+1 WHERE id=1;
SELECT pg_sleep(0.6);
SELECT id FROM lock_fixture.characters WHERE id=1 FOR UPDATE;
COMMIT;
" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
SELECT id FROM lock_fixture.characters WHERE id=1 FOR UPDATE;
SELECT pg_sleep(0.3);
UPDATE lock_fixture.campaigns SET round_number=round_number+1 WHERE id=1;
COMMIT;
"

run_expected_deadlock "campaign -> pending versus pending -> campaign" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
UPDATE lock_fixture.campaigns SET round_number=round_number+1 WHERE id=1;
SELECT pg_sleep(0.6);
UPDATE lock_fixture.pending_movements SET status='expired' WHERE id=1;
COMMIT;
" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
SELECT id FROM lock_fixture.pending_movements WHERE id=1 FOR UPDATE;
SELECT pg_sleep(0.3);
UPDATE lock_fixture.campaigns SET round_number=round_number+1 WHERE id=1;
COMMIT;
"

run_expected_deadlock "pending -> attack versus attack -> pending" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
SELECT id FROM lock_fixture.pending_movements WHERE id=1 FOR UPDATE;
SELECT pg_sleep(0.6);
SELECT id FROM lock_fixture.aoo_attacks WHERE id=1 FOR UPDATE;
COMMIT;
" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
SELECT id FROM lock_fixture.aoo_attacks WHERE id=1 FOR UPDATE;
SELECT pg_sleep(0.3);
SELECT id FROM lock_fixture.pending_movements WHERE id=1 FOR UPDATE;
COMMIT;
"

run_expected_deadlock "campaign -> character -> sheet -> feature resource versus character -> sheet -> resource -> campaign" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
UPDATE lock_fixture.campaigns SET round_number=round_number+1 WHERE id=1;
SELECT pg_sleep(0.6);
SELECT id FROM lock_fixture.characters WHERE id=1 FOR UPDATE;
SELECT id FROM lock_fixture.sheets WHERE id=1 FOR UPDATE;
SELECT pg_sleep(0.6);
SELECT id FROM lock_fixture.feature_resources WHERE id=1 FOR UPDATE;
COMMIT;
" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
SELECT id FROM lock_fixture.characters WHERE id=1 FOR UPDATE;
SELECT id FROM lock_fixture.sheets WHERE id=1 FOR UPDATE;
SELECT id FROM lock_fixture.feature_resources WHERE id=1 FOR UPDATE;
SELECT pg_sleep(0.3);
UPDATE lock_fixture.campaigns SET round_number=round_number+1 WHERE id=1;
COMMIT;
"

run_expected_deadlock "campaign -> character -> sheet versus character -> sheet -> campaign" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
UPDATE lock_fixture.campaigns SET round_number=round_number+1 WHERE id=1;
SELECT pg_sleep(0.6);
SELECT id FROM lock_fixture.characters WHERE id=1 FOR UPDATE;
SELECT pg_sleep(0.6);
SELECT id FROM lock_fixture.sheets WHERE id=1 FOR UPDATE;
COMMIT;
" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
SELECT id FROM lock_fixture.characters WHERE id=1 FOR UPDATE;
SELECT id FROM lock_fixture.sheets WHERE id=1 FOR UPDATE;
SELECT pg_sleep(0.3);
UPDATE lock_fixture.campaigns SET round_number=round_number+1 WHERE id=1;
COMMIT;
"




# Positive control: a consistent campaign -> effect order must complete.
run_expected_success() {
  local label="$1"
  local session_a="$2"
  local session_b="$3"
  local tmp
  tmp="$(mktemp -d)"
  psql -v ON_ERROR_STOP=1 >"$tmp/a.log" 2>&1 <<<"$session_a" &
  local a=$!
  sleep 0.1
  psql -v ON_ERROR_STOP=1 >"$tmp/b.log" 2>&1 <<<"$session_b" &
  local b=$!
  set +e
  wait "$a"; local sa=$?
  wait "$b"; local sb=$?
  set -e
  if [[ "$sa" -ne 0 || "$sb" -ne 0 ]] ||
     grep -qi 'deadlock detected' "$tmp/a.log" "$tmp/b.log"; then
    echo "FAIL: $label should complete without a deadlock"
    cat "$tmp/a.log" "$tmp/b.log"
    rm -rf "$tmp"
    exit 1
  fi
  echo "passed consistent lock order: $label"
  rm -rf "$tmp"
}

run_expected_success "campaign -> effect in both sessions" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
UPDATE lock_fixture.campaigns SET round_number=round_number+1 WHERE id=1;
SELECT pg_sleep(0.4);
UPDATE lock_fixture.effects SET active=false WHERE id=1;
COMMIT;
" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
UPDATE lock_fixture.campaigns SET round_number=round_number+1 WHERE id=1;
UPDATE lock_fixture.effects SET active=true WHERE id=1;
COMMIT;
"



run_expected_deadlock "campaign -> attack versus attack -> pending -> campaign (combat state change versus AOO resolution)" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
UPDATE lock_fixture.campaigns SET round_number=round_number+1 WHERE id=1;
SELECT pg_sleep(0.6);
SELECT id FROM lock_fixture.aoo_attacks WHERE id=1 FOR UPDATE;
COMMIT;
" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
SELECT id FROM lock_fixture.aoo_attacks WHERE id=1 FOR UPDATE;
SELECT id FROM lock_fixture.pending_movements WHERE id=1 FOR UPDATE;
SELECT pg_sleep(0.3);
UPDATE lock_fixture.campaigns SET round_number=round_number+1 WHERE id=1;
COMMIT;
"

run_expected_deadlock "NPC iterative roll sequence -> campaign versus NPC resolution campaign -> attempt -> sequence" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
SELECT id FROM lock_fixture.npc_sequences WHERE id=1 FOR UPDATE;
SELECT pg_sleep(0.6);
UPDATE lock_fixture.campaigns SET round_number=round_number+1 WHERE id=1;
COMMIT;
" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
UPDATE lock_fixture.campaigns SET round_number=round_number+1 WHERE id=1;
SELECT pg_sleep(0.3);
SELECT id FROM lock_fixture.npc_attempts WHERE id=1 FOR UPDATE;
SELECT id FROM lock_fixture.npc_sequences WHERE id=1 FOR UPDATE;
COMMIT;
"


# Ownership TOCTOU regression. This models gm_transfer/need_owner in disposable tables.
run_expected_stale_owner_race() {
  local tmp owner gm_count sa sb
  tmp="$(mktemp -d)"
  psql -v ON_ERROR_STOP=1 >"$tmp/a.log" 2>&1 <<'SQL' &
BEGIN;
DO $$
DECLARE v_owner text;
BEGIN
  SELECT owner_id INTO v_owner FROM lock_fixture.ownership_campaigns WHERE id=1;
  IF v_owner IS DISTINCT FROM 'owner-a' THEN RAISE EXCEPTION 'owner precheck failed'; END IF;
END $$;
UPDATE lock_fixture.ownership_members SET role='PLAYER' WHERE campaign_id=1 AND user_id='owner-a';
SELECT pg_sleep(0.8);
UPDATE lock_fixture.ownership_members SET role='GM' WHERE campaign_id=1 AND user_id='player-b';
UPDATE lock_fixture.ownership_campaigns SET owner_id='player-b' WHERE id=1;
COMMIT;
SQL
  local a=$!
  sleep 0.1
  psql -v ON_ERROR_STOP=1 >"$tmp/b.log" 2>&1 <<'SQL' &
BEGIN;
DO $$
DECLARE v_owner text;
BEGIN
  SELECT owner_id INTO v_owner FROM lock_fixture.ownership_campaigns WHERE id=1;
  IF v_owner IS DISTINCT FROM 'owner-a' THEN RAISE EXCEPTION 'owner precheck failed'; END IF;
END $$;
SELECT pg_sleep(0.2);
UPDATE lock_fixture.ownership_members SET role='PLAYER' WHERE campaign_id=1 AND user_id='owner-a';
UPDATE lock_fixture.ownership_members SET role='GM' WHERE campaign_id=1 AND user_id='player-c';
UPDATE lock_fixture.ownership_campaigns SET owner_id='player-c' WHERE id=1;
COMMIT;
SQL
  local b=$!
  set +e
  wait "$a"; sa=$?
  wait "$b"; sb=$?
  set -e
  owner="$(psql -Atq -c "SELECT owner_id FROM lock_fixture.ownership_campaigns WHERE id=1")"
  gm_count="$(psql -Atq -c "SELECT count(*) FROM lock_fixture.ownership_members WHERE campaign_id=1 AND role='GM'")"
  if [[ "$sa" -ne 0 || "$sb" -ne 0 || "$owner" != "player-c" || "$gm_count" != "2" ]]; then
    echo "FAIL: stale owner check race was not reproduced as expected"
    cat "$tmp/a.log" "$tmp/b.log"
    echo "owner=$owner gm_count=$gm_count statuses=$sa/$sb"
    rm -rf "$tmp"
    exit 1
  fi
  echo "passed synthetic stale owner authorization race: two prevalidated transfers, owner=$owner, gm_count=$gm_count"
  rm -rf "$tmp"
}

run_expected_serialized_owner_transfer() {
  local tmp owner gm_count sa sb
  tmp="$(mktemp -d)"
  psql -v ON_ERROR_STOP=1 -c "UPDATE lock_fixture.ownership_campaigns SET owner_id='owner-a' WHERE id=1; UPDATE lock_fixture.ownership_members SET role=CASE user_id WHEN 'owner-a' THEN 'GM' ELSE 'PLAYER' END WHERE campaign_id=1;" >/dev/null
  psql -v ON_ERROR_STOP=1 >"$tmp/a.log" 2>&1 <<'SQL' &
BEGIN;
SELECT owner_id FROM lock_fixture.ownership_campaigns WHERE id=1 FOR UPDATE;
DO $$
DECLARE v_owner text;
BEGIN
  SELECT owner_id INTO v_owner FROM lock_fixture.ownership_campaigns WHERE id=1;
  IF v_owner IS DISTINCT FROM 'owner-a' THEN RAISE EXCEPTION 'authorization lost'; END IF;
END $$;
UPDATE lock_fixture.ownership_members SET role='PLAYER' WHERE campaign_id=1 AND user_id='owner-a';
SELECT pg_sleep(0.8);
UPDATE lock_fixture.ownership_members SET role='GM' WHERE campaign_id=1 AND user_id='player-b';
UPDATE lock_fixture.ownership_campaigns SET owner_id='player-b' WHERE id=1;
COMMIT;
SQL
  local a=$!
  sleep 0.1
  psql -v ON_ERROR_STOP=1 >"$tmp/b.log" 2>&1 <<'SQL' &
BEGIN;
SELECT owner_id FROM lock_fixture.ownership_campaigns WHERE id=1 FOR UPDATE;
DO $$
DECLARE v_owner text;
BEGIN
  SELECT owner_id INTO v_owner FROM lock_fixture.ownership_campaigns WHERE id=1;
  IF v_owner IS DISTINCT FROM 'owner-a' THEN RAISE EXCEPTION 'authorization lost'; END IF;
END $$;
UPDATE lock_fixture.ownership_members SET role='PLAYER' WHERE campaign_id=1 AND user_id='owner-a';
UPDATE lock_fixture.ownership_members SET role='GM' WHERE campaign_id=1 AND user_id='player-c';
UPDATE lock_fixture.ownership_campaigns SET owner_id='player-c' WHERE id=1;
COMMIT;
SQL
  local b=$!
  set +e
  wait "$a"; sa=$?
  wait "$b"; sb=$?
  set -e
  owner="$(psql -Atq -c "SELECT owner_id FROM lock_fixture.ownership_campaigns WHERE id=1")"
  gm_count="$(psql -Atq -c "SELECT count(*) FROM lock_fixture.ownership_members WHERE campaign_id=1 AND role='GM'")"
  if [[ "$sa" -ne 0 || "$sb" -eq 0 || "$owner" != "player-b" || "$gm_count" != "1" ]] || ! grep -qi 'authorization lost' "$tmp/b.log"; then
    echo "FAIL: campaign-first ownership transfer did not reject stale authority"
    cat "$tmp/a.log" "$tmp/b.log"
    echo "owner=$owner gm_count=$gm_count statuses=$sa/$sb"
    rm -rf "$tmp"
    exit 1
  fi
  echo "passed serialized ownership transfer: second stale request rejected, owner=$owner, gm_count=$gm_count"
  rm -rf "$tmp"
}

run_expected_stale_owner_race
run_expected_serialized_owner_transfer
