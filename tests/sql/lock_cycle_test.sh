#!/usr/bin/env bash
set -euo pipefail

: "${PGHOST:=127.0.0.1}"
: "${PGPORT:=5432}"
: "${PGUSER:=postgres}"
: "${PGDATABASE:=vinculo_test}"
: "${PGPASSWORD:=postgres}"
export PGHOST PGPORT PGUSER PGDATABASE PGPASSWORD

psql -v ON_ERROR_STOP=1 -f tests/sql/lock_cycle_setup.sql

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

# Session A models the AFTER UPDATE trigger: campaign row first, effect second.
psql -v ON_ERROR_STOP=1 >"$tmpdir/session-a.log" 2>&1 <<'SQL' &
SET deadlock_timeout = '100ms';
SET lock_timeout = '5s';
BEGIN;
UPDATE lock_fixture.campaigns SET round_number = round_number + 1 WHERE id = 1;
SELECT pg_sleep(1.0);
UPDATE lock_fixture.effects SET active = false WHERE id = 1;
COMMIT;
SQL
pid_a=$!

# Start after A owns campaigns; B owns the effect before requesting campaigns.
sleep 0.2
psql -v ON_ERROR_STOP=1 >"$tmpdir/session-b.log" 2>&1 <<'SQL' &
SET deadlock_timeout = '100ms';
SET lock_timeout = '5s';
BEGIN;
SELECT id FROM lock_fixture.effects WHERE id = 1 FOR UPDATE;
SELECT pg_sleep(0.3);
UPDATE lock_fixture.campaigns SET round_number = round_number + 1 WHERE id = 1;
COMMIT;
SQL
pid_b=$!

set +e
wait "$pid_a"; status_a=$?
wait "$pid_b"; status_b=$?
set -e

if [[ "$status_a" -eq 0 && "$status_b" -eq 0 ]]; then
  echo "FAIL: expected the inverted lock order to produce a deadlock"
  cat "$tmpdir/session-a.log" "$tmpdir/session-b.log"
  exit 1
fi
if [[ "$status_a" -ne 0 && "$status_b" -ne 0 ]]; then
  echo "FAIL: both sessions failed; expected PostgreSQL to abort one deadlock participant"
  cat "$tmpdir/session-a.log" "$tmpdir/session-b.log"
  exit 1
fi

if ! grep -qi 'deadlock detected' "$tmpdir/session-a.log" "$tmpdir/session-b.log"; then
  echo "FAIL: a session failed, but not because PostgreSQL detected the expected deadlock"
  cat "$tmpdir/session-a.log" "$tmpdir/session-b.log"
  exit 1
fi

echo "lock inversion regression passed: PostgreSQL detected and aborted one participant"

# Additional synthetic lock-order regressions. Each pair deliberately models
# the exact conflicting prefixes found in remote function bodies; it does not
# execute those RPCs or prove a production deadlock occurred.
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

run_expected_deadlock "campaign -> weapon versus weapon -> campaign" "
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

run_expected_deadlock "equipment -> weapon instance versus weapon instance -> equipment" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
UPDATE lock_fixture.equipment SET quantity=quantity+1 WHERE id=1;
SELECT pg_sleep(0.6);
SELECT id FROM lock_fixture.weapon_instances WHERE id=1 FOR UPDATE;
COMMIT;
" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
SELECT id FROM lock_fixture.weapon_instances WHERE id=1 FOR UPDATE;
SELECT pg_sleep(0.3);
UPDATE lock_fixture.equipment SET quantity=quantity+1 WHERE id=1;
COMMIT;
"

run_expected_deadlock "campaign -> feature resource versus feature resource -> campaign" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
UPDATE lock_fixture.campaigns SET round_number=round_number+1 WHERE id=1;
SELECT pg_sleep(0.6);
UPDATE lock_fixture.feature_resources SET uses_spent=uses_spent+1 WHERE id=1;
COMMIT;
" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
SELECT id FROM lock_fixture.feature_resources WHERE id=1 FOR UPDATE;
SELECT pg_sleep(0.3);
UPDATE lock_fixture.campaigns SET round_number=round_number+1 WHERE id=1;
COMMIT;
"

run_expected_deadlock "campaign -> character sheet versus character sheet -> campaign" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
UPDATE lock_fixture.campaigns SET round_number=round_number+1 WHERE id=1;
SELECT pg_sleep(0.6);
UPDATE lock_fixture.sheets SET pv=pv-1 WHERE id=1;
COMMIT;
" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
SELECT id FROM lock_fixture.sheets WHERE id=1 FOR UPDATE;
SELECT pg_sleep(0.3);
UPDATE lock_fixture.campaigns SET round_number=round_number+1 WHERE id=1;
COMMIT;
"
