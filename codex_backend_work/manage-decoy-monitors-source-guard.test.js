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
  assert.match(source, /action === "deactivateAll"/);
  assert.match(source, /function deactivateAllForUser/);
  const deactivateAllFunction =
    source.match(/async function deactivateAllForUser[\s\S]*?\n}/)?.[0] || '';
  assert.doesNotMatch(deactivateAllFunction, /\.update/);
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

test('manage-decoy-monitors labels watch-key seeds as account-level monitoring', () => {
  assert.match(source, /function hasWatchPublicKey\(row: any\)/);
  assert.match(source, /if \(type === "generated-seed"\)/);
  assert.match(source, /Most Recent Decoy Seed Generated/);
  assert.match(source, /if \(hasWatchPublicKey\(row\)\) return "Account-level seed wallet monitoring"/);
  assert.match(source, /Legacy seed address monitor/);
  assert.match(source, /hasWatchPublicKey: hasWatchPublicKey\(row\)/);
});

test('manage-decoy-monitors returns full watch values for advanced controls', () => {
  assert.match(source, /if \(addresses\.length === 1\) return addresses\[0\]/);
  assert.match(source, /addresses\.join\("\\n"\)/);
  assert.match(source, /if \(watchKey\) return watchKey/);
  assert.doesNotMatch(source, /slice\(0,\s*12\)[\s\S]*slice\(-8\)/);
});

test('manage-decoy-monitors checks duplicates without exposing other users', () => {
  assert.match(source, /action === "checkDuplicate"/);
  assert.match(source, /function findDuplicateMonitor/);
  assert.match(source, /loadComparableMonitorRows\(supabase, user\.id\)/);
  assert.match(source, /duplicateType/);
  assert.match(source, /\.eq\("user_id", user\.id\)/);
  assert.match(source, /\.is\("archived_at", null\)/);
});
