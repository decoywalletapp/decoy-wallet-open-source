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
  assert.match(source, /watch_public_key: isWatchPublicKey\(watchPublicKey\)/);
  assert.doesNotMatch(source, /addresses\.join\("\\n"\)/);
});

test('commit-decoy still restores previously active decoys on commit failure', () => {
  assert.match(source, /restorePreviouslyActiveDecoys/);
  assert.match(source, /await restorePreviouslyActiveDecoys\(\)/);
});

test('commit-decoy writes watch address fingerprints as non-blocking shadow data', () => {
  assert.match(source, /decoy_watch_address_fingerprints/);
  assert.match(source, /Deno\.env\.get\("WATCH_ADDRESS_HMAC_KEY"\)/);
  assert.match(source, /watchAddressFingerprintVersion = "watch-address-v1"/);
  assert.match(source, /watchAddressFingerprintShadow: fingerprintShadow/);
  assert.match(source, /return \{ enabled: false, stored: 0, addressCount: 0 \}/);
  assert.match(source, /error: "shadow write failed"/);
});
