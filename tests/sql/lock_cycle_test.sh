#!/usr/bin/env bash
set -euo pipefail

: "${PGHOST:=127.0.0.1}"
: "${PGPORT:=5432}"
: "${PGUSER:=postgres}"
: "${PGDATABASE:=vinculo_test}"
: "${PGPASSWORD:=postgres}"
export PGHOST PGPORT PGUSER PGDATABASE PGPASSWORD

psql -v ON_ERROR_STOP=1 -f tests/sql/lock_cycle_setup.sql

# Disposable NPC token lifecycle contract (separate from lock-cycle RPC models).
psql -v ON_ERROR_STOP=1 -f tests/sql/npc_lifecycle_test.sql

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
DO $own$
DECLARE v_attempt integer:=0; v_acquired boolean;
BEGIN
  LOOP
    v_acquired:=pg_try_advisory_lock(8675309);
    IF NOT v_acquired THEN EXIT; END IF;
    PERFORM pg_advisory_unlock(8675309);
    v_attempt:=v_attempt+1;
    IF v_attempt>100 THEN RAISE EXCEPTION 'timed out waiting for second transfer to pass stale owner check'; END IF;
    PERFORM pg_sleep(0.02);
  END LOOP;
END $own$;
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
SELECT pg_advisory_lock(8675309);
UPDATE lock_fixture.ownership_members SET role='PLAYER' WHERE campaign_id=1 AND user_id='owner-a';
UPDATE lock_fixture.ownership_members SET role='GM' WHERE campaign_id=1 AND user_id='player-c';
UPDATE lock_fixture.ownership_campaigns SET owner_id='player-c' WHERE id=1;
COMMIT;
SELECT pg_advisory_unlock(8675309);
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
DO $own$
DECLARE v_attempt integer:=0; v_acquired boolean;
BEGIN
  LOOP
    v_acquired:=pg_try_advisory_lock(8675309);
    IF NOT v_acquired THEN EXIT; END IF;
    PERFORM pg_advisory_unlock(8675309);
    v_attempt:=v_attempt+1;
    IF v_attempt>100 THEN RAISE EXCEPTION 'timed out waiting for second transfer to pass stale owner check'; END IF;
    PERFORM pg_sleep(0.02);
  END LOOP;
END $own$;
UPDATE lock_fixture.ownership_members SET role='GM' WHERE campaign_id=1 AND user_id='player-b';
UPDATE lock_fixture.ownership_campaigns SET owner_id='player-b' WHERE id=1;
COMMIT;
SQL
  local a=$!
  sleep 0.1
  psql -v ON_ERROR_STOP=1 >"$tmp/b.log" 2>&1 <<'SQL' &
BEGIN;
SELECT pg_advisory_lock(8675309);
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


# GM-role TOCTOU in authenticated inventory RPCs. Synthetic only; production RPCs
# are not executed. Both competing operations remain inside real transactions.
run_expected_stale_gm_inventory_race() {
  local tmp role item_count sa sb
  tmp="$(mktemp -d)"
  psql -v ON_ERROR_STOP=1 -c "UPDATE lock_fixture.gm_gate_members SET role='GM' WHERE campaign_id=1 AND user_id='gm-a'; UPDATE lock_fixture.gm_gate_inventory SET item_count=0 WHERE campaign_id=1 AND user_id='player-x';" >/dev/null
  psql -v ON_ERROR_STOP=1 -c "BEGIN; DO \$\$ DECLARE v_role text; BEGIN SELECT role INTO v_role FROM lock_fixture.gm_gate_members WHERE campaign_id=1 AND user_id='gm-a'; IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'initial GM check failed'; END IF; END \$\$; SELECT pg_sleep(0.4); UPDATE lock_fixture.gm_gate_inventory SET item_count=item_count+1 WHERE campaign_id=1 AND user_id='player-x'; COMMIT;" >"$tmp/a.log" 2>&1 &
  local a=$!
  sleep 0.1
  psql -v ON_ERROR_STOP=1 -c "UPDATE lock_fixture.gm_gate_members SET role='PLAYER' WHERE campaign_id=1 AND user_id='gm-a'" >"$tmp/b.log" 2>&1 &
  local b=$!
  set +e
  wait "$a"; sa=$?
  wait "$b"; sb=$?
  set -e
  role="$(psql -Atq -c "SELECT role FROM lock_fixture.gm_gate_members WHERE campaign_id=1 AND user_id='gm-a'")"
  item_count="$(psql -Atq -c "SELECT item_count FROM lock_fixture.gm_gate_inventory WHERE campaign_id=1 AND user_id='player-x'")"
  if [[ "$sa" -ne 0 || "$sb" -ne 0 || "$role" != "PLAYER" || "$item_count" != "1" ]]; then
    echo "FAIL: stale GM role check race was not reproduced"
    cat "$tmp/a.log" "$tmp/b.log"
    echo "role=$role item_count=$item_count statuses=$sa/$sb"
    rm -rf "$tmp"
    exit 1
  fi
  echo "passed synthetic stale GM inventory authorization race: role=$role, inventory_change=$item_count"
  rm -rf "$tmp"
}

run_expected_serialized_gm_inventory_rejection() {
  local tmp role item_count sa sb
  tmp="$(mktemp -d)"
  psql -v ON_ERROR_STOP=1 -c "UPDATE lock_fixture.gm_gate_members SET role='GM' WHERE campaign_id=1 AND user_id='gm-a'; UPDATE lock_fixture.gm_gate_inventory SET item_count=0 WHERE campaign_id=1 AND user_id='player-x';" >/dev/null
  psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT id FROM lock_fixture.gm_gate_campaigns WHERE id=1 FOR UPDATE; SELECT pg_sleep(0.4); UPDATE lock_fixture.gm_gate_members SET role='PLAYER' WHERE campaign_id=1 AND user_id='gm-a'; COMMIT;" >"$tmp/a.log" 2>&1 &
  local a=$!
  sleep 0.1
  psql -v ON_ERROR_STOP=1 -c "SELECT pg_sleep(0.1); BEGIN; SELECT id FROM lock_fixture.gm_gate_campaigns WHERE id=1 FOR UPDATE; DO \$\$ DECLARE v_role text; BEGIN SELECT role INTO v_role FROM lock_fixture.gm_gate_members WHERE campaign_id=1 AND user_id='gm-a'; IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'GM authorization lost'; END IF; END \$\$; UPDATE lock_fixture.gm_gate_inventory SET item_count=item_count+1 WHERE campaign_id=1 AND user_id='player-x'; COMMIT;" >"$tmp/b.log" 2>&1 &
  local b=$!
  set +e
  wait "$a"; sa=$?
  wait "$b"; sb=$?
  set -e
  role="$(psql -Atq -c "SELECT role FROM lock_fixture.gm_gate_members WHERE campaign_id=1 AND user_id='gm-a'")"
  item_count="$(psql -Atq -c "SELECT item_count FROM lock_fixture.gm_gate_inventory WHERE campaign_id=1 AND user_id='player-x'")"
  if [[ "$sa" -ne 0 || "$sb" -eq 0 || "$role" != "PLAYER" || "$item_count" != "0" ]] ||
     ! grep -qi 'GM authorization lost' "$tmp/b.log"; then
    echo "FAIL: campaign-first stale GM request was not rejected"
    cat "$tmp/a.log" "$tmp/b.log"
    echo "role=$role item_count=$item_count statuses=$sa/$sb"
    rm -rf "$tmp"
    exit 1
  fi
  echo "passed campaign-first GM authorization control: stale request rejected, role=$role, inventory_change=$item_count"
  rm -rf "$tmp"
}

run_expected_stale_gm_inventory_race
run_expected_serialized_gm_inventory_rejection

# Owner-authorized membership administration (gm_set_role/gm_kick) after transfer.
# Synthetic only; this does not invoke production RPCs or priv.need_owner.
run_expected_stale_owner_admin_action() {
  local tmp owner target_role sa sb
  tmp="$(mktemp -d)"
  psql -v ON_ERROR_STOP=1 -c "UPDATE lock_fixture.ownership_campaigns SET owner_id='owner-a' WHERE id=1; UPDATE lock_fixture.ownership_members SET role=CASE user_id WHEN 'owner-a' THEN 'GM' ELSE 'PLAYER' END WHERE campaign_id=1; INSERT INTO lock_fixture.ownership_members(campaign_id,user_id,role) VALUES (1,'player-c','PLAYER') ON CONFLICT(campaign_id,user_id) DO UPDATE SET role='PLAYER';" >/dev/null
  psql -v ON_ERROR_STOP=1 -c "BEGIN; DO \$\$ DECLARE v_owner text; BEGIN SELECT owner_id INTO v_owner FROM lock_fixture.ownership_campaigns WHERE id=1; IF v_owner IS DISTINCT FROM 'owner-a' THEN RAISE EXCEPTION 'initial owner check failed'; END IF; END \$\$; SELECT pg_sleep(0.4); DELETE FROM lock_fixture.ownership_members WHERE campaign_id=1 AND user_id='player-c'; COMMIT;" >"$tmp/a.log" 2>&1 &
  local a=$!
  sleep 0.1
  psql -v ON_ERROR_STOP=1 -c "BEGIN; UPDATE lock_fixture.ownership_campaigns SET owner_id='player-b' WHERE id=1; UPDATE lock_fixture.ownership_members SET role=CASE user_id WHEN 'owner-a' THEN 'PLAYER' WHEN 'player-b' THEN 'GM' ELSE role END WHERE campaign_id=1; COMMIT;" >"$tmp/b.log" 2>&1 &
  local b=$!
  set +e
  wait "$a"; sa=$?
  wait "$b"; sb=$?
  set -e
  owner="$(psql -Atq -c "SELECT owner_id FROM lock_fixture.ownership_campaigns WHERE id=1")"
  target_role="$(psql -Atq -c "SELECT COALESCE((SELECT role FROM lock_fixture.ownership_members WHERE campaign_id=1 AND user_id='player-c'),'MISSING')")"
  if [[ "$sa" -ne 0 || "$sb" -ne 0 || "$owner" != "player-b" || "$target_role" != "MISSING" ]]; then
    echo "FAIL: stale owner admin action race was not reproduced"
    cat "$tmp/a.log" "$tmp/b.log"
    echo "owner=$owner target_role=$target_role statuses=$sa/$sb"
    rm -rf "$tmp"
    exit 1
  fi
  echo "passed synthetic stale owner administration race: owner=$owner, kicked_member=$target_role"
  rm -rf "$tmp"
}

run_expected_serialized_owner_admin_rejection() {
  local tmp owner target_role sa sb
  tmp="$(mktemp -d)"
  psql -v ON_ERROR_STOP=1 -c "UPDATE lock_fixture.ownership_campaigns SET owner_id='owner-a' WHERE id=1; UPDATE lock_fixture.ownership_members SET role=CASE user_id WHEN 'owner-a' THEN 'GM' ELSE 'PLAYER' END WHERE campaign_id=1; INSERT INTO lock_fixture.ownership_members(campaign_id,user_id,role) VALUES (1,'player-c','PLAYER') ON CONFLICT(campaign_id,user_id) DO UPDATE SET role='PLAYER';" >/dev/null
  psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT id FROM lock_fixture.ownership_campaigns WHERE id=1 FOR UPDATE; SELECT pg_sleep(0.4); UPDATE lock_fixture.ownership_campaigns SET owner_id='player-b' WHERE id=1; UPDATE lock_fixture.ownership_members SET role=CASE user_id WHEN 'owner-a' THEN 'PLAYER' WHEN 'player-b' THEN 'GM' ELSE role END WHERE campaign_id=1; COMMIT;" >"$tmp/a.log" 2>&1 &
  local a=$!
  sleep 0.1
  psql -v ON_ERROR_STOP=1 -c "SELECT pg_sleep(0.1); BEGIN; SELECT id FROM lock_fixture.ownership_campaigns WHERE id=1 FOR UPDATE; DO \$\$ DECLARE v_owner text; BEGIN SELECT owner_id INTO v_owner FROM lock_fixture.ownership_campaigns WHERE id=1; IF v_owner IS DISTINCT FROM 'owner-a' THEN RAISE EXCEPTION 'owner authorization lost'; END IF; END \$\$; DELETE FROM lock_fixture.ownership_members WHERE campaign_id=1 AND user_id='player-c'; COMMIT;" >"$tmp/b.log" 2>&1 &
  local b=$!
  set +e
  wait "$a"; sa=$?
  wait "$b"; sb=$?
  set -e
  owner="$(psql -Atq -c "SELECT owner_id FROM lock_fixture.ownership_campaigns WHERE id=1")"
  target_role="$(psql -Atq -c "SELECT COALESCE((SELECT role FROM lock_fixture.ownership_members WHERE campaign_id=1 AND user_id='player-c'),'MISSING')")"
  if [[ "$sa" -ne 0 || "$sb" -eq 0 || "$owner" != "player-b" || "$target_role" != "PLAYER" ]] ||
     ! grep -qi 'owner authorization lost' "$tmp/b.log"; then
    echo "FAIL: campaign-first stale owner admin request was not rejected"
    cat "$tmp/a.log" "$tmp/b.log"
    echo "owner=$owner target_role=$target_role statuses=$sa/$sb"
    rm -rf "$tmp"
    exit 1
  fi
  echo "passed campaign-first owner administration control: stale request rejected, owner=$owner, member=$target_role"
  rm -rf "$tmp"
}

run_expected_stale_owner_admin_action
run_expected_serialized_owner_admin_rejection

# Exact trigger-order regression for public.enforce_campaign_member_role.
# It models the installed trigger logic and gm_transfer statement order.
run_expected_current_transfer_order_is_rewritten_by_trigger() {
  local tmp owner old_role new_role
  tmp="$(mktemp -d)"
  psql -v ON_ERROR_STOP=1 -c "UPDATE lock_fixture.transfer_trigger_campaigns SET owner_id='owner-a' WHERE id=1; UPDATE lock_fixture.transfer_trigger_members SET role=CASE user_id WHEN 'owner-a' THEN 'GM' ELSE 'PLAYER' END WHERE campaign_id=1;" >/dev/null
  psql -v ON_ERROR_STOP=1 -c "BEGIN; UPDATE lock_fixture.transfer_trigger_members SET role='PLAYER' WHERE campaign_id=1 AND user_id='owner-a'; UPDATE lock_fixture.transfer_trigger_members SET role='GM' WHERE campaign_id=1 AND user_id='player-b'; UPDATE lock_fixture.transfer_trigger_campaigns SET owner_id='player-b' WHERE id=1; COMMIT;" >/dev/null
  owner="$(psql -Atq -c "SELECT owner_id FROM lock_fixture.transfer_trigger_campaigns WHERE id=1")"
  old_role="$(psql -Atq -c "SELECT role FROM lock_fixture.transfer_trigger_members WHERE campaign_id=1 AND user_id='owner-a'")"
  new_role="$(psql -Atq -c "SELECT role FROM lock_fixture.transfer_trigger_members WHERE campaign_id=1 AND user_id='player-b'")"
  if [[ "$owner" != "player-b" || "$old_role" != "GM" || "$new_role" != "PLAYER" ]]; then
    echo "FAIL: current transfer order did not reproduce trigger rewrite"
    echo "owner=$owner old_role=$old_role new_role=$new_role"
    rm -rf "$tmp"
    exit 1
  fi
  echo "passed transfer trigger-order reproduction: owner=$owner, old_owner_role=$old_role, new_owner_role=$new_role"
  rm -rf "$tmp"
}

run_expected_owner_first_transfer_order_satisfies_trigger() {
  local tmp owner old_role new_role
  tmp="$(mktemp -d)"
  psql -v ON_ERROR_STOP=1 -c "UPDATE lock_fixture.transfer_trigger_campaigns SET owner_id='owner-a' WHERE id=1; UPDATE lock_fixture.transfer_trigger_members SET role=CASE user_id WHEN 'owner-a' THEN 'GM' ELSE 'PLAYER' END WHERE campaign_id=1;" >/dev/null
  psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT id FROM lock_fixture.transfer_trigger_campaigns WHERE id=1 FOR UPDATE; UPDATE lock_fixture.transfer_trigger_campaigns SET owner_id='player-b' WHERE id=1; UPDATE lock_fixture.transfer_trigger_members SET role='PLAYER' WHERE campaign_id=1 AND user_id='owner-a'; UPDATE lock_fixture.transfer_trigger_members SET role='GM' WHERE campaign_id=1 AND user_id='player-b'; COMMIT;" >/dev/null
  owner="$(psql -Atq -c "SELECT owner_id FROM lock_fixture.transfer_trigger_campaigns WHERE id=1")"
  old_role="$(psql -Atq -c "SELECT role FROM lock_fixture.transfer_trigger_members WHERE campaign_id=1 AND user_id='owner-a'")"
  new_role="$(psql -Atq -c "SELECT role FROM lock_fixture.transfer_trigger_members WHERE campaign_id=1 AND user_id='player-b'")"
  if [[ "$owner" != "player-b" || "$old_role" != "PLAYER" || "$new_role" != "GM" ]]; then
    echo "FAIL: owner-first transfer did not satisfy role trigger"
    echo "owner=$owner old_role=$old_role new_role=$new_role"
    rm -rf "$tmp"
    exit 1
  fi
  echo "passed owner-first transfer trigger control: owner=$owner, old_owner_role=$old_role, new_owner_role=$new_role"
  rm -rf "$tmp"
}

run_expected_current_transfer_order_is_rewritten_by_trigger
run_expected_owner_first_transfer_order_satisfies_trigger

# Mirrors srd_apply_campaign_effect/condition: role check, then helper locks campaign.
run_expected_stale_gm_effect_after_campaign_wait() {
  local tmp role effects sa sb
  tmp="$(mktemp -d)"
  psql -v ON_ERROR_STOP=1 -c "UPDATE lock_fixture.gm_gate_members SET role='GM' WHERE campaign_id=1 AND user_id='gm-a'; UPDATE lock_fixture.gm_gate_effects SET effect_count=0 WHERE campaign_id=1 AND target_id='target-a';" >/dev/null
  psql -v ON_ERROR_STOP=1 -c "BEGIN; DO \$\$ DECLARE v_role text; BEGIN SELECT role INTO v_role FROM lock_fixture.gm_gate_members WHERE campaign_id=1 AND user_id='gm-a'; IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'initial GM check failed'; END IF; END \$\$; SELECT pg_sleep(0.4); SELECT id FROM lock_fixture.gm_gate_campaigns WHERE id=1 FOR UPDATE; UPDATE lock_fixture.gm_gate_effects SET effect_count=effect_count+1 WHERE campaign_id=1 AND target_id='target-a'; COMMIT;" >"$tmp/a.log" 2>&1 &
  local a=$!
  sleep 0.1
  psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT id FROM lock_fixture.gm_gate_campaigns WHERE id=1 FOR UPDATE; UPDATE lock_fixture.gm_gate_members SET role='PLAYER' WHERE campaign_id=1 AND user_id='gm-a'; COMMIT;" >"$tmp/b.log" 2>&1 &
  local b=$!
  set +e
  wait "$a"; sa=$?
  wait "$b"; sb=$?
  set -e
  role="$(psql -Atq -c "SELECT role FROM lock_fixture.gm_gate_members WHERE campaign_id=1 AND user_id='gm-a'")"
  effects="$(psql -Atq -c "SELECT effect_count FROM lock_fixture.gm_gate_effects WHERE campaign_id=1 AND target_id='target-a'")"
  if [[ "$sa" -ne 0 || "$sb" -ne 0 || "$role" != "PLAYER" || "$effects" != "1" ]]; then
    echo "FAIL: stale GM effect after campaign wait was not reproduced"
    cat "$tmp/a.log" "$tmp/b.log"
    echo "role=$role effects=$effects statuses=$sa/$sb"
    rm -rf "$tmp"
    exit 1
  fi
  echo "passed synthetic stale GM effect after campaign wait: role=$role, effect_change=$effects"
  rm -rf "$tmp"
}

run_expected_campaign_first_gm_effect_rejection() {
  local tmp role effects sa sb
  tmp="$(mktemp -d)"
  psql -v ON_ERROR_STOP=1 -c "UPDATE lock_fixture.gm_gate_members SET role='GM' WHERE campaign_id=1 AND user_id='gm-a'; UPDATE lock_fixture.gm_gate_effects SET effect_count=0 WHERE campaign_id=1 AND target_id='target-a';" >/dev/null
  psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT id FROM lock_fixture.gm_gate_campaigns WHERE id=1 FOR UPDATE; SELECT pg_sleep(0.4); UPDATE lock_fixture.gm_gate_members SET role='PLAYER' WHERE campaign_id=1 AND user_id='gm-a'; COMMIT;" >"$tmp/a.log" 2>&1 &
  local a=$!
  sleep 0.1
  psql -v ON_ERROR_STOP=1 -c "SELECT pg_sleep(0.1); BEGIN; SELECT id FROM lock_fixture.gm_gate_campaigns WHERE id=1 FOR UPDATE; DO \$\$ DECLARE v_role text; BEGIN SELECT role INTO v_role FROM lock_fixture.gm_gate_members WHERE campaign_id=1 AND user_id='gm-a'; IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'GM authorization lost after campaign lock'; END IF; END \$\$; UPDATE lock_fixture.gm_gate_effects SET effect_count=effect_count+1 WHERE campaign_id=1 AND target_id='target-a'; COMMIT;" >"$tmp/b.log" 2>&1 &
  local b=$!
  set +e
  wait "$a"; sa=$?
  wait "$b"; sb=$?
  set -e
  role="$(psql -Atq -c "SELECT role FROM lock_fixture.gm_gate_members WHERE campaign_id=1 AND user_id='gm-a'")"
  effects="$(psql -Atq -c "SELECT effect_count FROM lock_fixture.gm_gate_effects WHERE campaign_id=1 AND target_id='target-a'")"
  if [[ "$sa" -ne 0 || "$sb" -eq 0 || "$role" != "PLAYER" || "$effects" != "0" ]] ||
     ! grep -qi 'GM authorization lost after campaign lock' "$tmp/b.log"; then
    echo "FAIL: campaign-first GM effect control did not reject stale role"
    cat "$tmp/a.log" "$tmp/b.log"
    echo "role=$role effects=$effects statuses=$sa/$sb"
    rm -rf "$tmp"
    exit 1
  fi
  echo "passed campaign-first GM effect control: stale request rejected, role=$role, effect_change=$effects"
  rm -rf "$tmp"
}

run_expected_stale_gm_effect_after_campaign_wait
run_expected_campaign_first_gm_effect_rejection

# Mirrors gm_set_code and gm_set_role: need_owner check without campaign lock.
run_expected_stale_owner_set_code_after_transfer() {
  local tmp owner code sa sb
  tmp="$(mktemp -d)"
  psql -v ON_ERROR_STOP=1 -c "UPDATE lock_fixture.ownership_campaigns SET owner_id='owner-a' WHERE id=1; UPDATE lock_fixture.owner_gate_codes SET code='1111' WHERE campaign_id=1;" >/dev/null
  psql -v ON_ERROR_STOP=1 -c "BEGIN; DO \$\$ DECLARE v_owner text; BEGIN SELECT owner_id INTO v_owner FROM lock_fixture.ownership_campaigns WHERE id=1; IF v_owner IS DISTINCT FROM 'owner-a' THEN RAISE EXCEPTION 'initial owner check failed'; END IF; END \$\$; SELECT pg_sleep(0.4); UPDATE lock_fixture.owner_gate_codes SET code='2222' WHERE campaign_id=1; COMMIT;" >"$tmp/a.log" 2>&1 &
  local a=$!
  sleep 0.1
  psql -v ON_ERROR_STOP=1 -c "BEGIN; UPDATE lock_fixture.ownership_campaigns SET owner_id='player-b' WHERE id=1; UPDATE lock_fixture.ownership_members SET role=CASE user_id WHEN 'owner-a' THEN 'PLAYER' WHEN 'player-b' THEN 'GM' ELSE role END WHERE campaign_id=1; COMMIT;" >"$tmp/b.log" 2>&1 &
  local b=$!
  set +e
  wait "$a"; sa=$?
  wait "$b"; sb=$?
  set -e
  owner="$(psql -Atq -c "SELECT owner_id FROM lock_fixture.ownership_campaigns WHERE id=1")"
  code="$(psql -Atq -c "SELECT code FROM lock_fixture.owner_gate_codes WHERE campaign_id=1")"
  if [[ "$sa" -ne 0 || "$sb" -ne 0 || "$owner" != "player-b" || "$code" != "2222" ]]; then
    echo "FAIL: stale owner code mutation was not reproduced"
    cat "$tmp/a.log" "$tmp/b.log"
    echo "owner=$owner code=$code statuses=$sa/$sb"
    rm -rf "$tmp"
    exit 1
  fi
  echo "passed synthetic stale owner code mutation: owner=$owner, code=$code"
  rm -rf "$tmp"
}

run_expected_campaign_first_owner_code_rejection() {
  local tmp owner code sa sb
  tmp="$(mktemp -d)"
  psql -v ON_ERROR_STOP=1 -c "UPDATE lock_fixture.ownership_campaigns SET owner_id='owner-a' WHERE id=1; UPDATE lock_fixture.owner_gate_codes SET code='1111' WHERE campaign_id=1;" >/dev/null
  psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT id FROM lock_fixture.ownership_campaigns WHERE id=1 FOR UPDATE; SELECT pg_sleep(0.4); UPDATE lock_fixture.ownership_campaigns SET owner_id='player-b' WHERE id=1; UPDATE lock_fixture.ownership_members SET role=CASE user_id WHEN 'owner-a' THEN 'PLAYER' WHEN 'player-b' THEN 'GM' ELSE role END WHERE campaign_id=1; COMMIT;" >"$tmp/a.log" 2>&1 &
  local a=$!
  sleep 0.1
  psql -v ON_ERROR_STOP=1 -c "SELECT pg_sleep(0.1); BEGIN; SELECT id FROM lock_fixture.ownership_campaigns WHERE id=1 FOR UPDATE; DO \$\$ DECLARE v_owner text; BEGIN SELECT owner_id INTO v_owner FROM lock_fixture.ownership_campaigns WHERE id=1; IF v_owner IS DISTINCT FROM 'owner-a' THEN RAISE EXCEPTION 'owner authorization lost after campaign lock'; END IF; END \$\$; UPDATE lock_fixture.owner_gate_codes SET code='2222' WHERE campaign_id=1; COMMIT;" >"$tmp/b.log" 2>&1 &
  local b=$!
  set +e
  wait "$a"; sa=$?
  wait "$b"; sb=$?
  set -e
  owner="$(psql -Atq -c "SELECT owner_id FROM lock_fixture.ownership_campaigns WHERE id=1")"
  code="$(psql -Atq -c "SELECT code FROM lock_fixture.owner_gate_codes WHERE campaign_id=1")"
  if [[ "$sa" -ne 0 || "$sb" -eq 0 || "$owner" != "player-b" || "$code" != "1111" ]] ||
     ! grep -qi 'owner authorization lost after campaign lock' "$tmp/b.log"; then
    echo "FAIL: campaign-first owner code control did not reject stale owner"
    cat "$tmp/a.log" "$tmp/b.log"
    echo "owner=$owner code=$code statuses=$sa/$sb"
    rm -rf "$tmp"
    exit 1
  fi
  echo "passed campaign-first owner code control: stale request rejected, owner=$owner, code=$code"
  rm -rf "$tmp"
}

run_expected_stale_owner_set_code_after_transfer
run_expected_campaign_first_owner_code_rejection

run_expected_stale_owner_set_role_after_transfer() {
  local tmp owner role sa sb
  tmp="$(mktemp -d)"
  psql -v ON_ERROR_STOP=1 -c "UPDATE lock_fixture.ownership_campaigns SET owner_id='owner-a' WHERE id=1; UPDATE lock_fixture.ownership_members SET role=CASE user_id WHEN 'owner-a' THEN 'GM' ELSE 'PLAYER' END WHERE campaign_id=1;" >/dev/null
  psql -v ON_ERROR_STOP=1 -c "BEGIN; DO \$\$ DECLARE v_owner text; BEGIN SELECT owner_id INTO v_owner FROM lock_fixture.ownership_campaigns WHERE id=1; IF v_owner IS DISTINCT FROM 'owner-a' THEN RAISE EXCEPTION 'initial owner check failed'; END IF; END \$\$; SELECT pg_sleep(0.4); UPDATE lock_fixture.ownership_members SET role='OBSERVER' WHERE campaign_id=1 AND user_id='player-c'; COMMIT;" >"$tmp/a.log" 2>&1 &
  local a=$!
  sleep 0.1
  psql -v ON_ERROR_STOP=1 -c "BEGIN; UPDATE lock_fixture.ownership_campaigns SET owner_id='player-b' WHERE id=1; UPDATE lock_fixture.ownership_members SET role=CASE user_id WHEN 'owner-a' THEN 'PLAYER' WHEN 'player-b' THEN 'GM' ELSE role END WHERE campaign_id=1; COMMIT;" >"$tmp/b.log" 2>&1 &
  local b=$!
  set +e
  wait "$a"; sa=$?
  wait "$b"; sb=$?
  set -e
  owner="$(psql -Atq -c "SELECT owner_id FROM lock_fixture.ownership_campaigns WHERE id=1")"
  role="$(psql -Atq -c "SELECT role FROM lock_fixture.ownership_members WHERE campaign_id=1 AND user_id='player-c'")"
  if [[ "$sa" -ne 0 || "$sb" -ne 0 || "$owner" != "player-b" || "$role" != "OBSERVER" ]]; then
    echo "FAIL: stale owner role mutation was not reproduced"
    cat "$tmp/a.log" "$tmp/b.log"
    echo "owner=$owner role=$role statuses=$sa/$sb"
    rm -rf "$tmp"
    exit 1
  fi
  echo "passed synthetic stale owner role mutation: owner=$owner, target_role=$role"
  rm -rf "$tmp"
}

run_expected_campaign_first_owner_role_rejection() {
  local tmp owner role sa sb
  tmp="$(mktemp -d)"
  psql -v ON_ERROR_STOP=1 -c "UPDATE lock_fixture.ownership_campaigns SET owner_id='owner-a' WHERE id=1; UPDATE lock_fixture.ownership_members SET role=CASE user_id WHEN 'owner-a' THEN 'GM' ELSE 'PLAYER' END WHERE campaign_id=1;" >/dev/null
  psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT id FROM lock_fixture.ownership_campaigns WHERE id=1 FOR UPDATE; SELECT pg_sleep(0.4); UPDATE lock_fixture.ownership_campaigns SET owner_id='player-b' WHERE id=1; UPDATE lock_fixture.ownership_members SET role=CASE user_id WHEN 'owner-a' THEN 'PLAYER' WHEN 'player-b' THEN 'GM' ELSE role END WHERE campaign_id=1; COMMIT;" >"$tmp/a.log" 2>&1 &
  local a=$!
  sleep 0.1
  psql -v ON_ERROR_STOP=1 -c "SELECT pg_sleep(0.1); BEGIN; SELECT id FROM lock_fixture.ownership_campaigns WHERE id=1 FOR UPDATE; DO \$\$ DECLARE v_owner text; BEGIN SELECT owner_id INTO v_owner FROM lock_fixture.ownership_campaigns WHERE id=1; IF v_owner IS DISTINCT FROM 'owner-a' THEN RAISE EXCEPTION 'owner authorization lost after campaign lock'; END IF; END \$\$; UPDATE lock_fixture.ownership_members SET role='OBSERVER' WHERE campaign_id=1 AND user_id='player-c'; COMMIT;" >"$tmp/b.log" 2>&1 &
  local b=$!
  set +e
  wait "$a"; sa=$?
  wait "$b"; sb=$?
  set -e
  owner="$(psql -Atq -c "SELECT owner_id FROM lock_fixture.ownership_campaigns WHERE id=1")"
  role="$(psql -Atq -c "SELECT role FROM lock_fixture.ownership_members WHERE campaign_id=1 AND user_id='player-c'")"
  if [[ "$sa" -ne 0 || "$sb" -eq 0 || "$owner" != "player-b" || "$role" != "PLAYER" ]] ||
     ! grep -qi 'owner authorization lost after campaign lock' "$tmp/b.log"; then
    echo "FAIL: campaign-first owner role control did not reject stale owner"
    cat "$tmp/a.log" "$tmp/b.log"
    echo "owner=$owner role=$role statuses=$sa/$sb"
    rm -rf "$tmp"
    exit 1
  fi
  echo "passed campaign-first owner role control: stale request rejected, owner=$owner, target_role=$role"
  rm -rf "$tmp"
}

run_expected_stale_owner_set_role_after_transfer
run_expected_campaign_first_owner_role_rejection

# Mirrors gm_reopen_sheet/gm_set_bonus stale GM authorization on character sheets.
run_expected_stale_gm_sheet_mutation_after_revocation() {
  local tmp role is_open bonus sa sb
  tmp="$(mktemp -d)"
  psql -v ON_ERROR_STOP=1 -c "UPDATE lock_fixture.gm_gate_members SET role='GM' WHERE campaign_id=1 AND user_id='gm-a'; UPDATE lock_fixture.gm_gate_sheets SET is_open=false,bonus=0 WHERE campaign_id=1 AND character_id='character-a';" >/dev/null
  psql -v ON_ERROR_STOP=1 -c "BEGIN; DO \$\$ DECLARE v_role text; BEGIN SELECT role INTO v_role FROM lock_fixture.gm_gate_members WHERE campaign_id=1 AND user_id='gm-a'; IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'initial GM check failed'; END IF; END \$\$; SELECT pg_sleep(0.4); UPDATE lock_fixture.gm_gate_sheets SET is_open=true,bonus=5 WHERE campaign_id=1 AND character_id='character-a'; COMMIT;" >"$tmp/a.log" 2>&1 &
  local a=$!
  sleep 0.1
  psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT id FROM lock_fixture.gm_gate_campaigns WHERE id=1 FOR UPDATE; UPDATE lock_fixture.gm_gate_members SET role='PLAYER' WHERE campaign_id=1 AND user_id='gm-a'; COMMIT;" >"$tmp/b.log" 2>&1 &
  local b=$!
  set +e
  wait "$a"; sa=$?
  wait "$b"; sb=$?
  set -e
  role="$(psql -Atq -c "SELECT role FROM lock_fixture.gm_gate_members WHERE campaign_id=1 AND user_id='gm-a'")"
  is_open="$(psql -Atq -c "SELECT is_open FROM lock_fixture.gm_gate_sheets WHERE campaign_id=1 AND character_id='character-a'")"
  bonus="$(psql -Atq -c "SELECT bonus FROM lock_fixture.gm_gate_sheets WHERE campaign_id=1 AND character_id='character-a'")"
  if [[ "$sa" -ne 0 || "$sb" -ne 0 || "$role" != "PLAYER" || "$is_open" != "t" || "$bonus" != "5" ]]; then
    echo "FAIL: stale GM sheet mutation was not reproduced"
    cat "$tmp/a.log" "$tmp/b.log"
    echo "role=$role is_open=$is_open bonus=$bonus statuses=$sa/$sb"
    rm -rf "$tmp"
    exit 1
  fi
  echo "passed synthetic stale GM sheet mutation: role=$role, is_open=$is_open, bonus=$bonus"
  rm -rf "$tmp"
}

run_expected_campaign_first_gm_sheet_mutation_rejection() {
  local tmp role is_open bonus sa sb
  tmp="$(mktemp -d)"
  psql -v ON_ERROR_STOP=1 -c "UPDATE lock_fixture.gm_gate_members SET role='GM' WHERE campaign_id=1 AND user_id='gm-a'; UPDATE lock_fixture.gm_gate_sheets SET is_open=false,bonus=0 WHERE campaign_id=1 AND character_id='character-a';" >/dev/null
  psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT id FROM lock_fixture.gm_gate_campaigns WHERE id=1 FOR UPDATE; SELECT pg_sleep(0.4); UPDATE lock_fixture.gm_gate_members SET role='PLAYER' WHERE campaign_id=1 AND user_id='gm-a'; COMMIT;" >"$tmp/a.log" 2>&1 &
  local a=$!
  sleep 0.1
  psql -v ON_ERROR_STOP=1 -c "SELECT pg_sleep(0.1); BEGIN; SELECT id FROM lock_fixture.gm_gate_campaigns WHERE id=1 FOR UPDATE; DO \$\$ DECLARE v_role text; BEGIN SELECT role INTO v_role FROM lock_fixture.gm_gate_members WHERE campaign_id=1 AND user_id='gm-a'; IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'GM authorization lost after campaign lock'; END IF; END \$\$; UPDATE lock_fixture.gm_gate_sheets SET is_open=true,bonus=5 WHERE campaign_id=1 AND character_id='character-a'; COMMIT;" >"$tmp/b.log" 2>&1 &
  local b=$!
  set +e
  wait "$a"; sa=$?
  wait "$b"; sb=$?
  set -e
  role="$(psql -Atq -c "SELECT role FROM lock_fixture.gm_gate_members WHERE campaign_id=1 AND user_id='gm-a'")"
  is_open="$(psql -Atq -c "SELECT is_open FROM lock_fixture.gm_gate_sheets WHERE campaign_id=1 AND character_id='character-a'")"
  bonus="$(psql -Atq -c "SELECT bonus FROM lock_fixture.gm_gate_sheets WHERE campaign_id=1 AND character_id='character-a'")"
  if [[ "$sa" -ne 0 || "$sb" -eq 0 || "$role" != "PLAYER" || "$is_open" != "f" || "$bonus" != "0" ]] ||
     ! grep -qi 'GM authorization lost after campaign lock' "$tmp/b.log"; then
    echo "FAIL: campaign-first GM sheet control did not reject stale authorization"
    cat "$tmp/a.log" "$tmp/b.log"
    echo "role=$role is_open=$is_open bonus=$bonus statuses=$sa/$sb"
    rm -rf "$tmp"
    exit 1
  fi
  echo "passed campaign-first GM sheet control: stale request rejected, role=$role, is_open=$is_open, bonus=$bonus"
  rm -rf "$tmp"
}

run_expected_stale_gm_sheet_mutation_after_revocation
run_expected_campaign_first_gm_sheet_mutation_rejection


# Mirrors public.gm_grant: GM is checked before character lock; no campaign lock/recheck.
run_expected_stale_gm_grant_after_revocation() {
  local tmp role gold xp item_count sa sb
  tmp="$(mktemp -d)"
  psql -v ON_ERROR_STOP=1 -c "UPDATE lock_fixture.gm_gate_members SET role='GM' WHERE campaign_id=1 AND user_id='gm-a'; UPDATE lock_fixture.gm_gate_grants SET gold=0,xp=0,item_count=0 WHERE campaign_id=1 AND character_id=1;" >/dev/null
  psql -v ON_ERROR_STOP=1 -c "BEGIN; DO \$\$ DECLARE v_role text; BEGIN SELECT role INTO v_role FROM lock_fixture.gm_gate_members WHERE campaign_id=1 AND user_id='gm-a'; IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'initial GM check failed'; END IF; END \$\$; SELECT pg_sleep(0.4); SELECT id FROM lock_fixture.characters WHERE id=1 FOR UPDATE; UPDATE lock_fixture.gm_gate_grants SET gold=gold+100,xp=xp+50,item_count=item_count+1 WHERE campaign_id=1 AND character_id=1; COMMIT;" >"$tmp/a.log" 2>&1 &
  local a=$!
  sleep 0.1
  psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT id FROM lock_fixture.gm_gate_campaigns WHERE id=1 FOR UPDATE; UPDATE lock_fixture.gm_gate_members SET role='PLAYER' WHERE campaign_id=1 AND user_id='gm-a'; COMMIT;" >"$tmp/b.log" 2>&1 &
  local b=$!
  set +e
  wait "$a"; sa=$?
  wait "$b"; sb=$?
  set -e
  role="$(psql -Atq -c "SELECT role FROM lock_fixture.gm_gate_members WHERE campaign_id=1 AND user_id='gm-a'")"
  gold="$(psql -Atq -c "SELECT gold FROM lock_fixture.gm_gate_grants WHERE campaign_id=1 AND character_id=1")"
  xp="$(psql -Atq -c "SELECT xp FROM lock_fixture.gm_gate_grants WHERE campaign_id=1 AND character_id=1")"
  item_count="$(psql -Atq -c "SELECT item_count FROM lock_fixture.gm_gate_grants WHERE campaign_id=1 AND character_id=1")"
  if [[ "$sa" -ne 0 || "$sb" -ne 0 || "$role" != "PLAYER" || "$gold" != "100" || "$xp" != "50" || "$item_count" != "1" ]]; then
    echo "FAIL: stale GM grant after revocation was not reproduced"
    cat "$tmp/a.log" "$tmp/b.log"
    echo "role=$role gold=$gold xp=$xp item_count=$item_count statuses=$sa/$sb"
    rm -rf "$tmp"
    exit 1
  fi
  echo "passed synthetic stale GM grant after revocation: role=$role, gold=$gold, xp=$xp, item_count=$item_count"
  rm -rf "$tmp"
}

run_expected_campaign_first_gm_grant_rejection() {
  local tmp role gold xp item_count sa sb
  tmp="$(mktemp -d)"
  psql -v ON_ERROR_STOP=1 -c "UPDATE lock_fixture.gm_gate_members SET role='GM' WHERE campaign_id=1 AND user_id='gm-a'; UPDATE lock_fixture.gm_gate_grants SET gold=0,xp=0,item_count=0 WHERE campaign_id=1 AND character_id=1;" >/dev/null
  psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT id FROM lock_fixture.gm_gate_campaigns WHERE id=1 FOR UPDATE; SELECT pg_sleep(0.4); UPDATE lock_fixture.gm_gate_members SET role='PLAYER' WHERE campaign_id=1 AND user_id='gm-a'; COMMIT;" >"$tmp/a.log" 2>&1 &
  local a=$!
  sleep 0.1
  psql -v ON_ERROR_STOP=1 -c "SELECT pg_sleep(0.1); BEGIN; SELECT id FROM lock_fixture.gm_gate_campaigns WHERE id=1 FOR UPDATE; DO \$\$ DECLARE v_role text; BEGIN SELECT role INTO v_role FROM lock_fixture.gm_gate_members WHERE campaign_id=1 AND user_id='gm-a'; IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'GM authorization lost after campaign lock'; END IF; END \$\$; SELECT id FROM lock_fixture.characters WHERE id=1 FOR UPDATE; UPDATE lock_fixture.gm_gate_grants SET gold=gold+100,xp=xp+50,item_count=item_count+1 WHERE campaign_id=1 AND character_id=1; COMMIT;" >"$tmp/b.log" 2>&1 &
  local b=$!
  set +e
  wait "$a"; sa=$?
  wait "$b"; sb=$?
  set -e
  role="$(psql -Atq -c "SELECT role FROM lock_fixture.gm_gate_members WHERE campaign_id=1 AND user_id='gm-a'")"
  gold="$(psql -Atq -c "SELECT gold FROM lock_fixture.gm_gate_grants WHERE campaign_id=1 AND character_id=1")"
  xp="$(psql -Atq -c "SELECT xp FROM lock_fixture.gm_gate_grants WHERE campaign_id=1 AND character_id=1")"
  item_count="$(psql -Atq -c "SELECT item_count FROM lock_fixture.gm_gate_grants WHERE campaign_id=1 AND character_id=1")"
  if [[ "$sa" -ne 0 || "$sb" -eq 0 || "$role" != "PLAYER" || "$gold" != "0" || "$xp" != "0" || "$item_count" != "0" ]] ||
     ! grep -qi 'GM authorization lost after campaign lock' "$tmp/b.log"; then
    echo "FAIL: campaign-first GM grant control did not reject stale role"
    cat "$tmp/a.log" "$tmp/b.log"
    echo "role=$role gold=$gold xp=$xp item_count=$item_count statuses=$sa/$sb"
    rm -rf "$tmp"
    exit 1
  fi
  echo "passed campaign-first GM grant control: stale request rejected, role=$role, grant unchanged"
  rm -rf "$tmp"
}

# Mirrors direct srd_remove_campaign_condition/effect: role check then table update without campaign lock.
run_expected_stale_gm_condition_effect_removal_after_revocation() {
  local tmp role condition_active effect_active sa sb
  tmp="$(mktemp -d)"
  psql -v ON_ERROR_STOP=1 -c "UPDATE lock_fixture.gm_gate_members SET role='GM' WHERE campaign_id=1 AND user_id='gm-a'; UPDATE lock_fixture.gm_gate_removals SET condition_active=true,effect_active=true WHERE campaign_id=1 AND target_id='target-a';" >/dev/null
  psql -v ON_ERROR_STOP=1 -c "BEGIN; DO \$\$ DECLARE v_role text; BEGIN SELECT role INTO v_role FROM lock_fixture.gm_gate_members WHERE campaign_id=1 AND user_id='gm-a'; IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'initial GM check failed'; END IF; END \$\$; SELECT pg_sleep(0.4); UPDATE lock_fixture.gm_gate_removals SET condition_active=false,effect_active=false WHERE campaign_id=1 AND target_id='target-a'; COMMIT;" >"$tmp/a.log" 2>&1 &
  local a=$!
  sleep 0.1
  psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT id FROM lock_fixture.gm_gate_campaigns WHERE id=1 FOR UPDATE; UPDATE lock_fixture.gm_gate_members SET role='PLAYER' WHERE campaign_id=1 AND user_id='gm-a'; COMMIT;" >"$tmp/b.log" 2>&1 &
  local b=$!
  set +e
  wait "$a"; sa=$?
  wait "$b"; sb=$?
  set -e
  role="$(psql -Atq -c "SELECT role FROM lock_fixture.gm_gate_members WHERE campaign_id=1 AND user_id='gm-a'")"
  condition_active="$(psql -Atq -c "SELECT condition_active FROM lock_fixture.gm_gate_removals WHERE campaign_id=1 AND target_id='target-a'")"
  effect_active="$(psql -Atq -c "SELECT effect_active FROM lock_fixture.gm_gate_removals WHERE campaign_id=1 AND target_id='target-a'")"
  if [[ "$sa" -ne 0 || "$sb" -ne 0 || "$role" != "PLAYER" || "$condition_active" != "f" || "$effect_active" != "f" ]]; then
    echo "FAIL: stale GM condition/effect removal was not reproduced"
    cat "$tmp/a.log" "$tmp/b.log"
    echo "role=$role condition_active=$condition_active effect_active=$effect_active statuses=$sa/$sb"
    rm -rf "$tmp"
    exit 1
  fi
  echo "passed synthetic stale GM condition/effect removal: role=$role, condition_active=$condition_active, effect_active=$effect_active"
  rm -rf "$tmp"
}

run_expected_campaign_first_gm_condition_effect_removal_rejection() {
  local tmp role condition_active effect_active sa sb
  tmp="$(mktemp -d)"
  psql -v ON_ERROR_STOP=1 -c "UPDATE lock_fixture.gm_gate_members SET role='GM' WHERE campaign_id=1 AND user_id='gm-a'; UPDATE lock_fixture.gm_gate_removals SET condition_active=true,effect_active=true WHERE campaign_id=1 AND target_id='target-a';" >/dev/null
  psql -v ON_ERROR_STOP=1 -c "BEGIN; SELECT id FROM lock_fixture.gm_gate_campaigns WHERE id=1 FOR UPDATE; SELECT pg_sleep(0.4); UPDATE lock_fixture.gm_gate_members SET role='PLAYER' WHERE campaign_id=1 AND user_id='gm-a'; COMMIT;" >"$tmp/a.log" 2>&1 &
  local a=$!
  sleep 0.1
  psql -v ON_ERROR_STOP=1 -c "SELECT pg_sleep(0.1); BEGIN; SELECT id FROM lock_fixture.gm_gate_campaigns WHERE id=1 FOR UPDATE; DO \$\$ DECLARE v_role text; BEGIN SELECT role INTO v_role FROM lock_fixture.gm_gate_members WHERE campaign_id=1 AND user_id='gm-a'; IF v_role IS DISTINCT FROM 'GM' THEN RAISE EXCEPTION 'GM authorization lost after campaign lock'; END IF; END \$\$; UPDATE lock_fixture.gm_gate_removals SET condition_active=false,effect_active=false WHERE campaign_id=1 AND target_id='target-a'; COMMIT;" >"$tmp/b.log" 2>&1 &
  local b=$!
  set +e
  wait "$a"; sa=$?
  wait "$b"; sb=$?
  set -e
  role="$(psql -Atq -c "SELECT role FROM lock_fixture.gm_gate_members WHERE campaign_id=1 AND user_id='gm-a'")"
  condition_active="$(psql -Atq -c "SELECT condition_active FROM lock_fixture.gm_gate_removals WHERE campaign_id=1 AND target_id='target-a'")"
  effect_active="$(psql -Atq -c "SELECT effect_active FROM lock_fixture.gm_gate_removals WHERE campaign_id=1 AND target_id='target-a'")"
  if [[ "$sa" -ne 0 || "$sb" -eq 0 || "$role" != "PLAYER" || "$condition_active" != "t" || "$effect_active" != "t" ]] ||
     ! grep -qi 'GM authorization lost after campaign lock' "$tmp/b.log"; then
    echo "FAIL: campaign-first GM condition/effect removal control did not reject stale role"
    cat "$tmp/a.log" "$tmp/b.log"
    echo "role=$role condition_active=$condition_active effect_active=$effect_active statuses=$sa/$sb"
    rm -rf "$tmp"
    exit 1
  fi
  echo "passed campaign-first GM condition/effect removal control: stale request rejected, role=$role, condition/effect remain active"
  rm -rf "$tmp"
}

# Mirrors the installed two-phase campaign deletion flow:
# prepare locks campaign then upserts cleanup; finalize locks cleanup then campaign.
run_expected_deadlock "campaign deletion prepare campaign -> cleanup versus finalize cleanup -> campaign" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
UPDATE lock_fixture.campaigns SET round_number=round_number+1 WHERE id=1;
SELECT pg_sleep(0.6);
INSERT INTO lock_fixture.campaign_deletion_cleanup(campaign_id,owner_id)
VALUES (1,'owner-a')
ON CONFLICT (campaign_id) DO UPDATE
SET owner_id=EXCLUDED.owner_id,requested_at=now();
COMMIT;
" "
SET deadlock_timeout='100ms'; SET lock_timeout='5s';
BEGIN;
SELECT campaign_id FROM lock_fixture.campaign_deletion_cleanup WHERE campaign_id=1 FOR UPDATE;
SELECT pg_sleep(0.3);
UPDATE lock_fixture.campaigns SET round_number=round_number+1 WHERE id=1;
COMMIT;
"

run_expected_stale_gm_grant_after_revocation
run_expected_campaign_first_gm_grant_rejection
run_expected_stale_gm_condition_effect_removal_after_revocation
run_expected_campaign_first_gm_condition_effect_removal_rejection


# Synthetic contract for the campaign lock handshake required by Storage uploads.
# It verifies both interleavings: an earlier upload must finish before prepare
# can set the marker; an earlier prepare must make the later upload reject.
run_storage_upload_cleanup_lock_contract() {
  local tmp count marker result sa sb
  tmp="$(mktemp -d)"
  psql -v ON_ERROR_STOP=1 -c "DELETE FROM lock_fixture.campaign_deletion_cleanup WHERE campaign_id=1; TRUNCATE lock_fixture.storage_objects;" >/dev/null
  psql -v ON_ERROR_STOP=1 >"$tmp/upload-first.log" 2>&1 <<'SQL' &
BEGIN;
SELECT lock_fixture.upload_if_allowed(1,'campaigns/1/upload-first.png');
SELECT pg_sleep(0.4);
COMMIT;
SQL
  local a=$!
  sleep 0.1
  psql -v ON_ERROR_STOP=1 >"$tmp/prepare-after.log" 2>&1 <<'SQL' &
BEGIN;
SELECT id FROM lock_fixture.campaigns WHERE id=1 FOR UPDATE;
INSERT INTO lock_fixture.campaign_deletion_cleanup(campaign_id,owner_id)
VALUES (1,'owner-a')
ON CONFLICT (campaign_id) DO UPDATE SET owner_id=EXCLUDED.owner_id,requested_at=now();
COMMIT;
SQL
  local b=$!
  set +e
  wait "$a"; sa=$?
  wait "$b"; sb=$?
  set -e
  count="$(psql -Atq -c "SELECT count(*) FROM lock_fixture.storage_objects WHERE campaign_id=1")"
  marker="$(psql -Atq -c "SELECT count(*) FROM lock_fixture.campaign_deletion_cleanup WHERE campaign_id=1")"
  if [[ "$sa" -ne 0 || "$sb" -ne 0 || "$count" != "1" || "$marker" != "1" ]]; then
    echo "FAIL: prepare did not wait for the earlier upload to finish"
    cat "$tmp/upload-first.log" "$tmp/prepare-after.log"
    echo "objects=$count marker=$marker statuses=$sa/$sb"
    rm -rf "$tmp"
    exit 1
  fi

  psql -v ON_ERROR_STOP=1 -c "DELETE FROM lock_fixture.campaign_deletion_cleanup WHERE campaign_id=1; TRUNCATE lock_fixture.storage_objects;" >/dev/null
  psql -v ON_ERROR_STOP=1 >"$tmp/prepare-first.log" 2>&1 <<'SQL' &
BEGIN;
SELECT id FROM lock_fixture.campaigns WHERE id=1 FOR UPDATE;
INSERT INTO lock_fixture.campaign_deletion_cleanup(campaign_id,owner_id)
VALUES (1,'owner-a')
ON CONFLICT (campaign_id) DO UPDATE SET owner_id=EXCLUDED.owner_id,requested_at=now();
SELECT pg_sleep(0.4);
COMMIT;
SQL
  a=$!
  sleep 0.1
  psql -v ON_ERROR_STOP=1 >"$tmp/upload-after.log" 2>&1 <<'SQL' &
BEGIN;
SELECT lock_fixture.upload_if_allowed(1,'campaigns/1/upload-after.png');
COMMIT;
SQL
  b=$!
  set +e
  wait "$a"; sa=$?
  wait "$b"; sb=$?
  set -e
  count="$(psql -Atq -c "SELECT count(*) FROM lock_fixture.storage_objects WHERE campaign_id=1")"
  marker="$(psql -Atq -c "SELECT count(*) FROM lock_fixture.campaign_deletion_cleanup WHERE campaign_id=1")"
  result="$(grep -Eo 'f|t' "$tmp/upload-after.log" | tail -n 1 || true)"
  if [[ "$sa" -ne 0 || "$sb" -ne 0 || "$count" != "0" || "$marker" != "1" || "$result" != "f" ]]; then
    echo "FAIL: upload after cleanup marker was not rejected"
    cat "$tmp/prepare-first.log" "$tmp/upload-after.log"
    echo "objects=$count marker=$marker result=$result statuses=$sa/$sb"
    rm -rf "$tmp"
    exit 1
  fi
  echo "passed synthetic Storage upload/cleanup lock contract: earlier upload serialized before marker; later upload rejected"
  rm -rf "$tmp"
}

run_storage_upload_cleanup_lock_contract
