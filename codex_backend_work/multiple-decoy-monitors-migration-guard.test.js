const assert = require('node:assert/strict');
const fs = require('node:fs');
const test = require('node:test');

const migration = [
  fs.readFileSync(
    'supabase/migrations/20260907193000_allow_multiple_decoy_key_monitors.sql',
    'utf8'
  ),
  fs.readFileSync(
    'supabase/migrations/20260907215200_drop_legacy_single_active_decoy_constraint.sql',
    'utf8'
  ),
].join('\n');

test('migration removes the old single-active-decoy rule', () => {
  assert.match(
    migration,
    /alter\s+table\s+public\.decoys\s+drop\s+constraint\s+if\s+exists\s+one_active_decoy_per_user/i
  );
  assert.match(
    migration,
    /drop\s+index\s+if\s+exists\s+public\.one_active_decoy_per_user/i
  );
  assert.match(
    migration,
    /drop\s+index\s+if\s+exists\s+public\.decoys_one_active_per_user/i
  );
});

test('armed_decoy_seeds view returns all active unarchived monitors behind the master switch', () => {
  assert.match(
    migration,
    /create\s+or\s+replace\s+view\s+public\.armed_decoy_seeds/i
  );
  assert.match(
    migration,
    /join\s+public\.decoys\s+d\s+on\s+d\.user_id\s*=\s*dw\.user_id/i
  );
  assert.match(
    migration,
    /coalesce\(dw\.decoy_seed_armed,\s*false\)\s+is\s+true/i
  );
  assert.match(migration, /coalesce\(d\.active,\s*false\)\s+is\s+true/i);
  assert.match(migration, /d\.archived_at\s+is\s+null/i);
});

test('armed_decoy_seeds remains service-backend only', () => {
  assert.match(
    migration,
    /alter\s+view\s+public\.armed_decoy_seeds\s+set\s+\(security_invoker\s*=\s*true\)/i
  );
  assert.match(
    migration,
    /revoke\s+all\s+privileges\s+on\s+table\s+public\.armed_decoy_seeds\s+from\s+anon,\s+authenticated/i
  );
});
