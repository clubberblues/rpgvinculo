# PostgreSQL fixture tests

These tests run against a disposable PostgreSQL service inside a standard GitHub Actions runner. They do not connect to Supabase and do not read or mutate campaign data.

## Current scope

- The footprint fixture copies the current remote definitions of `public.srd35_normalizar_parametro_talento` and `priv.srd_token_grid_footprint` (captured 2026-11-09).
- Assertions cover D&D 3.5 grid footprint categories, Portuguese size aliases, linked player-race fallback, key lookup, unknown-size fallback, and duplicate-token rejection.
- This validates the canonical footprint helper only. It does **not** yet prove that movement, attack, spawn, or AOO RPCs all call the helper; the audit has confirmed those call sites still contain divergent logic.
- The lock-cycle fixture creates two synthetic tables and two concurrent PostgreSQL sessions to prove that the observed order campaign → effect versus effect → campaign is deadlock-prone. It tests the database lock pattern only; it does **not** execute production RPC bodies or claim a production deadlock was reproduced.
- Fixture SQL is not a migration and must never be applied to the connected Supabase project.

- The lock-cycle script now also models two additional inversions found during the read-only audit: campaign → weapon versus weapon → campaign, and campaign → character versus character → campaign. These are synthetic PostgreSQL lock-pattern tests, not executions of the remote RPG functions. A passing test proves PostgreSQL detects the deliberately constructed cycle; it does not prove that the corresponding production RPC pair deadlocked in use.

- The lock-cycle fixture additionally models two AOO-related inversions observed in installed function bodies: campaign → pending versus pending → campaign, and pending → attack versus attack → pending. As with the other cases, these are deliberately synthetic lock patterns, not production RPC executions.

- CI follow-up: run 42673083206 ended with workflow conclusion `failure`, but GitHub returned zero jobs and no step logs; it is not evidence of an SQL assertion failure. A fresh run is required to diagnose the expanded fixture set.

- The fixture now also models inventory-trigger order (equipment row → weapon instance) versus direct weapon-instance equip order (weapon instance → equipment summary). It remains a synthetic lock-pattern test, not an execution of the production inventory trigger or RPC.

- The lock-cycle fixture now models a class-resource inversion observed in the remote definitions: campaign → feature resource (NPC rage/rest paths) versus feature resource → campaign (class-feature path). This is a synthetic pattern only; the actual pair's reachability for the same linked character/campaign still requires confirmation, and no production RPC is executed.

- A further synthetic pair models the spell-resolution order campaign → character sheet versus multi-target spell-casting order character sheet → campaign. The production bodies show these conflicting prefixes, but the fixture still models only PostgreSQL locks; it does not execute spell RPCs or establish a reproduced production deadlock.
