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
