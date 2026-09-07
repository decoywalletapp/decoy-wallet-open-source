const assert = require('node:assert/strict');
const fs = require('node:fs');
const test = require('node:test');

const source = fs.readFileSync(
  'supabase/functions/manage-decoy-monitors/index.ts',
  'utf8'
);

test('manage-decoy-monitors requires an authenticated Supabase user', () => {
  assert.match(source, /Authorization/);
  assert.match(source, /auth\.getUser\(\)/);
  assert.match(source, /Unauthorized/);
});

test('manage-decoy-monitors scopes every mutation to the signed-in user', () => {
  assert.match(source, /\.eq\("user_id", user\.id\)/);
  assert.match(source, /\.eq\("id", monitorId\)/);
  assert.match(source, /Monitor not found/);
});

test('manage-decoy-monitors only changes monitor participation rows', () => {
  assert.match(source, /action === "setActive"/);
  assert.match(source, /\.update\(\{ active: asBoolean\(body\.active\) \}\)/);
  assert.match(source, /action === "delete"/);
  assert.match(source, /action === "bulkSave"/);
  assert.match(source, /deleteMonitorIds/);
  assert.match(source, /activeMonitorIds/);
  assert.match(source, /inactiveMonitorIds/);
  assert.match(source, /loadOwnedMonitorIds/);
  assert.match(source, /archived_at: new Date\(\)\.toISOString\(\)/);
  assert.doesNotMatch(source, /sms_queue/);
  assert.doesNotMatch(source, /alert_logs/);
  assert.doesNotMatch(source, /decoy_triggers/);
  const decoyWalletStatements =
    source.match(/\.from\("decoy_wallet"\)[\s\S]*?;/g) || [];
  assert.ok(decoyWalletStatements.length > 0);
  for (const statement of decoyWalletStatements) {
    assert.doesNotMatch(statement, /\.update/);
  }
});
