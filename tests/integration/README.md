# CBA Storage API integration test

This test uses the real Supabase Storage HTTP API and separate GM/player/external JWTs. It is intentionally not wired to production or to CI by default.

Run only against a disposable staging project/campaign after applying the candidate Storage and snapshot migrations:

```bash
SUPABASE_URL=... \
SUPABASE_ANON_KEY=... \
TEST_CAMPAIGN_ID=... \
TEST_GM_JWT=... \
TEST_PLAYER_JWT=... \
TEST_EXTERNAL_JWT=... \
node tests/integration/storage-cba-api.mjs
```

The GM JWT must belong to the campaign owner or a GM member. The player JWT must belong to a player member with a seated character. The external JWT must belong to an authenticated user with no membership. The campaign should contain at least one visible and one hidden token portrait to exercise both branches; the map branch is exercised when a background path exists.

The script:
- signs published map/portrait URLs for the player;
- rejects full-map signing while fog is enabled;
- rejects hidden portrait signing and all external-user signing;
- uploads an isolated PNG as GM;
- rejects player upsert and delete;
- creates a GM signed URL and removes the test object in a finally block.

This is a staging contract test, not proof of execution. No JWTs or credentials are committed. Do not use a production campaign or service-role key.
