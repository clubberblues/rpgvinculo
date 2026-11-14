import assert from "node:assert/strict";
import { randomUUID } from "node:crypto";

const required = [
  "SUPABASE_URL", "SUPABASE_ANON_KEY", "TEST_CAMPAIGN_ID",
  "TEST_GM_JWT", "TEST_PLAYER_JWT", "TEST_EXTERNAL_JWT"
];
for (const key of required) {
  if (!process.env[key]) throw new Error(`Missing required environment variable: ${key}`);
}

const base = process.env.SUPABASE_URL.replace(/\/$/, "");
const anonKey = process.env.SUPABASE_ANON_KEY;
const campaignId = String(process.env.TEST_CAMPAIGN_ID);
const gm = process.env.TEST_GM_JWT;
const player = process.env.TEST_PLAYER_JWT;
const external = process.env.TEST_EXTERNAL_JWT;
const bucket = "mesa-media";
const path = (name) => name.split("/").map(encodeURIComponent).join("/");
const url = (p) => `${base}/storage/v1/object/${p}`;
const headers = (jwt, extra = {}) => ({
  apikey: anonKey,
  Authorization: `Bearer ${jwt}`,
  ...extra
});
async function request(jwt, method, p, body, extra = {}) {
  const response = await fetch(url(p), {
    method,
    headers: headers(jwt, {
      ...(body ? { "Content-Type": "application/json" } : {}),
      ...extra
    }),
    ...(body ? { body: JSON.stringify(body) } : {})
  });
  const text = await response.text();
  let data;
  try { data = text ? JSON.parse(text) : null; } catch { data = text; }
  return { response, data };
}
async function sign(jwt, objectPath) {
  return request(jwt, "POST", `sign/${bucket}/${path(objectPath)}`, { expiresIn: 60 });
}
function expectDenied(result, label) {
  assert.ok(!result.response.ok, `${label}: expected denial, got HTTP ${result.response.status}`);
}
function expectAllowed(result, label) {
  assert.ok(result.response.ok, `${label}: expected success, got HTTP ${result.response.status}: ${JSON.stringify(result.data)}`);
}
async function expectSignedReadable(jwt, objectPath, label) {
  const result = await sign(jwt, objectPath);
  expectAllowed(result, label + " signed URL");
  const signed = result.data?.signedURL || result.data?.signedUrl;
  assert.ok(signed, `${label}: signed URL missing from response`);
  const absolute = signed.startsWith("http") ? signed : base + (signed.startsWith("/") ? signed : "/" + signed);
  const download = await fetch(absolute);
  assert.equal(download.status, 200, `${label}: signed URL download failed with HTTP ${download.status}`);
}

// Read the GM's current scene to select real published assets; this test must
// run only against a disposable/staging campaign after the candidate policies
// and snapshot migrations have been applied.
const campaignResponse = await fetch(
  `${base}/rest/v1/campaigns?id=eq.${encodeURIComponent(campaignId)}&select=cba_data`,
  { headers: headers(gm) }
);
assert.equal(campaignResponse.status, 200, "GM must be able to inspect the staging scene");
const campaigns = await campaignResponse.json();
assert.equal(campaigns.length, 1, "staging campaign must exist");
const scene = campaigns[0].cba_data || {};
const mapPath = scene.backgroundPath || null;
const visiblePortrait = (scene.tokens || []).find(t => t && t.visivel === true && t.imagemPath)?.imagemPath || null;
const hiddenPortrait = (scene.tokens || []).find(t => t && t.visivel !== true && t.imagemPath)?.imagemPath || null;

if (mapPath) {
  const mapResult = await sign(player, mapPath);
  if (scene.fogEnabled === true) expectDenied(mapResult, "player signed URL for full map while fog enabled");
  else await expectSignedReadable(player, mapPath, "player active map");
}
if (visiblePortrait) await expectSignedReadable(player, visiblePortrait, "player visible portrait");
if (hiddenPortrait) expectDenied(await sign(player, hiddenPortrait), "player signed URL for hidden portrait");
if (mapPath) expectDenied(await sign(external, mapPath), "external signed URL");

const objectPath = `campaigns/${campaignId}/tokens/storage-api-contract-${randomUUID()}.png`;
const png = Buffer.from("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/pXcAAAAASUVORK5CYII=", "base64");
const upload = await fetch(url(`${bucket}/${path(objectPath)}`), {
  method: "POST",
  headers: headers(gm, { "Content-Type": "image/png", "x-upsert": "false" }),
  body: png
});
assert.ok(upload.ok, `GM upload failed: HTTP ${upload.status} ${await upload.text()}`);
try {
  const deniedUpload = await fetch(url(`${bucket}/${path(objectPath)}`), {
    method: "POST",
    headers: headers(player, { "Content-Type": "image/png", "x-upsert": "true" }),
    body: png
  });
  expectDenied({ response: deniedUpload }, "player upsert");
  const deniedDelete = await fetch(url(`${bucket}/${path(objectPath)}`), {
    method: "DELETE", headers: headers(player)
  });
  expectDenied({ response: deniedDelete }, "player delete");
  await expectSignedReadable(gm, objectPath, "GM uploaded object");
} finally {
  const removed = await fetch(url(`${bucket}/${path(objectPath)}`), {
    method: "DELETE", headers: headers(gm)
  });
  assert.ok(removed.ok, `GM cleanup failed: HTTP ${removed.status} ${await removed.text()}`);
}

console.log("CBA Storage API authorization contract passed against the configured staging campaign.");
