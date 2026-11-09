# PostgreSQL fixture tests

These tests run against a disposable PostgreSQL service inside a standard GitHub Actions runner. They do not connect to Supabase and do not read or mutate campaign data.

## Current scope

- The footprint fixture copies the current remote definitions of `public.srd35_normalizar_parametro_talento` and `priv.srd_token_grid_footprint` (captured 2026-11-09).
- Assertions cover D&D 3.5 grid footprint categories, Portuguese size aliases, linked player-race fallback, key lookup, unknown-size fallback, and duplicate-token rejection.
- This validates the canonical footprint helper only. It does **not** yet prove that movement, attack, spawn, or AOO RPCs all call the helper; the audit has confirmed those call sites still contain divergent logic.
- Fixture SQL is not a migration and must never be applied to the connected Supabase project.

- The lock-cycle script now also models two additional inversions found during the read-only audit: campaign → weapon versus weapon → campaign, and campaign → character versus character → campaign. These are synthetic PostgreSQL lock-pattern tests, not executions of the remote RPG functions. A passing test proves PostgreSQL detects the deliberately constructed cycle; it does not prove that the corresponding production RPC pair deadlocked in use.

- The lock-cycle fixture additionally models two AOO-related inversions observed in installed function bodies: campaign → pending versus pending → campaign, and pending → attack versus attack → pending. As with the other cases, these are deliberately synthetic lock patterns, not production RPC executions.

- CI follow-up: run 42673083206 ended with workflow conclusion `failure`, but GitHub returned zero jobs and no step logs; it is not evidence of an SQL assertion failure. A fresh run is required to diagnose the expanded fixture set.

- The fixture now also models inventory-trigger order (equipment row → weapon instance) versus direct weapon-instance equip order (weapon instance → equipment summary). It remains a synthetic lock-pattern test, not an execution of the production inventory trigger or RPC.

- The lock-cycle fixture now models a class-resource inversion observed in the remote definitions: campaign → feature resource (NPC rage/rest paths) versus feature resource → campaign (class-feature path). This is a synthetic pattern only; the actual pair's reachability for the same linked character/campaign still requires confirmation, and no production RPC is executed.

- A further synthetic pair models the spell-resolution order campaign → character sheet versus multi-target spell-casting order character sheet → campaign. The production bodies show these conflicting prefixes, but the fixture still models only PostgreSQL locks; it does not execute spell RPCs or establish a reproduced production deadlock.



- Added a positive-control concurrency case: two sessions both acquire campaign before effect and must complete without a deadlock. This guards against a harness that only proves deliberately inverted patterns fail; it still tests the PostgreSQL lock protocol in isolation, not production RPC bodies.
- The latest read-only frontend scan confirmed that `mesa.html` directly invokes the multi-target damage/effect spell RPCs and the manual Magic Missile wrapper. The exact removal RPC names were not found in the seven tracked interface/script files; this is not proof that no external or indirect caller exists.


- Validation for PR #74: PostgreSQL fixture run [42718608566](https://github.com/clubberblues/rpgvinculo/actions/runs/42718608566) completed successfully after the reachability cleanup. The harness ran eight synthetic inverted lock patterns plus one positive control for consistent campaign → effect ordering. The run does not execute Supabase RPCs or test production data.

- A new AOO regression models the active combat-state transition prefix `campaign → attack` against the exposed opportunity-attack resolver prefix `attack → pending movement → campaign`. The UI calls `alternar_estado_campanha` and the AOO cancellation/resolution RPCs; these are live authenticated paths. The test remains synthetic and does not execute the remote RPC bodies.

- The generic campaign ↔ effect and compound rage effect-first scenarios were removed from the active fixture after call-site reachability review: all authenticated/current callers acquire campaign before invoking the rage end helper; the only effect-first caller is legacy `end_combat`, with no EXECUTE for authenticated/anon and no caller found in current SQL/interface files. The dormant path remains documented for re-evaluation if re-exposed.

- The active character/sheet → campaign inversion is broader than spell casting: the current UI also calls multi-target spell RPCs, usar_habilidade_classe_srd (Lay on Hands), and usar_imposicao_maos_mortos_vivos_srd. These lock character/sheet (and in one path feature resources) before calling consumir_acao_turno_srd, which locks campaign first. The existing campaign ↔ sheet fixture models this order synthetically; it still does not execute those RPCs.

- Expanded AOO reachability review: the current mesa.html also calls opportunity-attack damage application, concealment resolution, trip-after-AOO, stand-up-after-AOO, and grapple/overrun-style encounter resolution. Their production bodies include attack → pending → campaign or pending → campaign prefixes. The existing AOO synthetic cases cover these shared lock-order patterns, not the individual RPC semantics.
- The AFTER INSERT pending-movement preview trigger invokes the movement RPC inside a caught sentinel-exception subtransaction. Current pending writers already hold the campaign lock before INSERT; do not count the preview trigger as an independent pending → campaign edge.

- Resource-lock refinement: class-feature and undead-touch RPCs lock the character feature-resource row before campaign, while linked-NPC rage/rest paths lock campaign → character → sheet → feature resource. The campaign/resource fixture covers the lock pattern only; the real cycle depends on the token and operation referring to the same linked character.
