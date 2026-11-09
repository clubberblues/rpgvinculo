# PostgreSQL fixture tests

These tests run against a disposable PostgreSQL service inside a standard GitHub Actions runner. They do not connect to Supabase and do not read or mutate campaign data.

## Current scope

- The fixture copies the current remote definitions of `public.srd35_normalizar_parametro_talento` and `priv.srd_token_grid_footprint` (captured 2026-11-09).
- Assertions cover D&D 3.5 grid footprint categories, Portuguese size aliases, linked player-race fallback, key lookup, unknown-size fallback, and duplicate-token rejection.
- This validates the canonical footprint helper only. It does **not** yet prove that movement, attack, spawn, or AOO RPCs all call the helper; the audit has confirmed those call sites still contain divergent logic.
- Fixture SQL is not a migration and must never be applied to the connected Supabase project.
