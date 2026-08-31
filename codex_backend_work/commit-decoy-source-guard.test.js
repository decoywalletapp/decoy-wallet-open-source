const assert = require('node:assert/strict');
const fs = require('node:fs');
const test = require('node:test');

const source = fs.readFileSync(
  'supabase/functions/commit-decoy/index.ts',
  'utf8'
);

test('commit-decoy accepts address-list watches without changing xpub/zpub validation', () => {
  assert.match(source, /function isWatchPublicKey/);
  assert.match(source, /function isAddressListWatchType/);
  assert.match(source, /cleanString\(v\) === "bitcoin-address-list"/);
  assert.match(
    source,
    /watchPublicKey && !addressListWatch && !isWatchPublicKey\(watchPublicKey\)/
  );
  assert.match(source, /xpub: isWatchPublicKey\(xpub\) \? xpub : null/);
  assert.match(source, /zpub: isWatchPublicKey\(zpub\) \? zpub : null/);
  assert.match(source, /watch_public_key: addressListWatch/);
  assert.match(source, /addresses\.join\("\\n"\)/);
});

test('commit-decoy still restores previously active decoys on commit failure', () => {
  assert.match(source, /restorePreviouslyActiveDecoys/);
  assert.match(source, /await restorePreviouslyActiveDecoys\(\)/);
});
