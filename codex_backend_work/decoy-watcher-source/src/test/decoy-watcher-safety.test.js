const assert = require('node:assert/strict');
const fs = require('node:fs');
const test = require('node:test');

const { shouldProcessOutboundTx, shouldTriggerMissingUtxo } = require('../watcher_tx_filter');
const logRedaction = require('../watcher_log_redaction');
const watchAddressFingerprint = require('../watch_address_fingerprint');
const txDestinations = require('../watcher_tx_destinations');

const watchedAddress = 'bc1qwatchedaddress0000000000000000000000000000000';
const otherAddress = 'bc1qotheraddress00000000000000000000000000000000';
const destinationAddress = 'bc1qdestination000000000000000000000000000000';
const watcherSource = fs.readFileSync('codex_backend_work/decoy-watcher-source/src/index.js', 'utf8');

function outboundTx({ confirmed = false, blockTime = new Date(), address = watchedAddress } = {}) {
  return {
    txid: `tx-${confirmed ? 'confirmed' : 'mempool'}-${blockTime.getTime()}-${address}`,
    vin: [
      {
        prevout: {
          scriptpubkey_address: address,
        },
      },
    ],
    status: confirmed
      ? {
          confirmed: true,
          block_time: Math.floor(blockTime.getTime() / 1000),
        }
      : {
          confirmed: false,
        },
  };
}

function inboundOnlyTx({ confirmed = false, blockTime = new Date(), address = watchedAddress } = {}) {
  return {
    txid: `receive-${confirmed ? 'confirmed' : 'mempool'}-${blockTime.getTime()}-${address}`,
    vin: [
      {
        prevout: {
          scriptpubkey_address: otherAddress,
        },
      },
    ],
    vout: [
      {
        scriptpubkey_address: address,
      },
    ],
    status: confirmed
      ? {
          confirmed: true,
          block_time: Math.floor(blockTime.getTime() / 1000),
        }
      : {
          confirmed: false,
        },
  };
}

function shouldAlert(tx, armedAt, baselineAt) {
  return shouldProcessOutboundTx(tx, watchedAddress, armedAt, baselineAt, {
    confirmedCatchupMaxAgeMs: 2 * 60 * 60 * 1000,
  });
}

test('unconfirmed outbound transactions trigger immediately when seen', () => {
  const tx = outboundTx({ confirmed: false });
  const armedAt = new Date(Date.now() - 60 * 60 * 1000);

  assert.equal(shouldAlert(tx, armedAt, armedAt), true);
});

test('recent confirmed outbound transactions after baseline trigger', () => {
  const blockTime = new Date(Date.now() - 10 * 60 * 1000);
  const baselineAt = new Date(Date.now() - 30 * 60 * 1000);
  const tx = outboundTx({ confirmed: true, blockTime });

  assert.equal(shouldAlert(tx, baselineAt, baselineAt), true);
});

test('stale confirmed outbound transactions after baseline do not trigger', () => {
  const blockTime = new Date(Date.now() - 11 * 24 * 60 * 60 * 1000);
  const baselineAt = new Date(blockTime.getTime() - 30 * 60 * 1000);
  const tx = outboundTx({ confirmed: true, blockTime });

  assert.equal(shouldAlert(tx, baselineAt, baselineAt), false);
});

test('confirmed outbound transactions before baseline do not trigger', () => {
  const blockTime = new Date(Date.now() - 10 * 60 * 1000);
  const baselineAt = new Date(Date.now() - 5 * 60 * 1000);
  const tx = outboundTx({ confirmed: true, blockTime });

  assert.equal(shouldAlert(tx, baselineAt, baselineAt), false);
});

test('transactions that do not spend the watched address do not trigger', () => {
  const tx = outboundTx({ confirmed: false, address: otherAddress });
  const armedAt = new Date(Date.now() - 60 * 60 * 1000);

  assert.equal(shouldAlert(tx, armedAt, armedAt), false);
});

test('receive-only transactions to the watched address do not trigger', () => {
  const tx = inboundOnlyTx({ confirmed: false });
  const armedAt = new Date(Date.now() - 60 * 60 * 1000);

  assert.equal(shouldAlert(tx, armedAt, armedAt), false);
});

test('destination extraction includes external outputs and excludes watched inputs', () => {
  const tx = {
    vin: [
      {
        prevout: {
          scriptpubkey_address: watchedAddress,
        },
      },
    ],
    vout: [
      { scriptpubkey_address: destinationAddress },
      { scriptpubkey_address: watchedAddress },
    ],
  };

  assert.deepEqual(
    txDestinations.destinationAddressCandidates(tx, [watchedAddress]),
    [destinationAddress]
  );
});

test('destination extraction normalizes common provider output shapes', () => {
  const rawOutputs = txDestinations.normalizeTxOutputs([
    { scriptPubKey: { addresses: [destinationAddress] } },
    { addr: otherAddress },
  ]);

  assert.deepEqual(rawOutputs, [
    { scriptpubkey_address: destinationAddress },
    { scriptpubkey_address: otherAddress },
  ]);
});

test('destination extraction dedupes and limits output addresses', () => {
  const tx = {
    vin: [],
    vout: [
      { scriptpubkey_address: destinationAddress.toUpperCase() },
      { scriptpubkey_address: destinationAddress },
      { scriptpubkey_address: otherAddress },
    ],
  };

  assert.deepEqual(
    txDestinations.destinationAddressCandidates(tx, [], { maxCount: 1 }),
    [destinationAddress.toUpperCase()]
  );
});

test('one transient missing watch-key UTXO snapshot does not trigger immediately', () => {
  const nowMs = Date.parse('2026-08-06T23:13:10Z');
  const row = {
    first_seen_at: '2026-08-06T23:12:10Z',
    last_seen_at: '2026-08-06T23:12:10Z',
  };

  assert.equal(shouldTriggerMissingUtxo(row, nowMs, 3 * 60 * 1000), false);
});

test('missing watch-key UTXO can trigger after the confirmation window', () => {
  const nowMs = Date.parse('2026-08-06T23:16:11Z');
  const row = {
    first_seen_at: '2026-08-06T23:12:10Z',
    last_seen_at: '2026-08-06T23:12:10Z',
  };

  assert.equal(shouldTriggerMissingUtxo(row, nowMs, 3 * 60 * 1000), true);
});

test('watcher log references do not expose raw addresses or row ids', () => {
  const address = 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kygt080';
  const rowId = '1f0wrdg4v0dhn2ct-row-id';
  const hmacKey = 'test-hmac-key-for-log-redaction';

  const addressRef = logRedaction.sensitiveRef('addr', address, hmacKey);
  const idRef = logRedaction.sensitiveRef('id', rowId, hmacKey);

  assert.match(addressRef, /^addr:[a-f0-9]{16}$/);
  assert.match(idRef, /^id:[a-f0-9]{16}$/);
  assert.doesNotMatch(addressRef, /bc1q|w508d6|ygt080/);
  assert.doesNotMatch(idRef, /1f0wrd|row-id|v0dhn/);
});

test('watcher error text redacts public wallet identifiers', () => {
  const text = [
    'provider rejected bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kygt080',
    'legacy 1BoatSLRHtKNngkdXEeobR76b53LETtpyT',
    'watch zpub6qQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ',
  ].join(' ');

  const redacted = logRedaction.redactSensitiveText(text);

  assert.doesNotMatch(redacted, /bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kygt080/);
  assert.doesNotMatch(redacted, /1BoatSLRHtKNngkdXEeobR76b53LETtpyT/);
  assert.doesNotMatch(redacted, /zpub6qQQQQ/);
  assert.match(redacted, /\[redacted-watch-data\]/);
});

test('watch address fingerprinting is deterministic and case-safe for bech32', () => {
  const key = 'test-watch-address-hmac-key';
  const lower = 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kygt080';
  const upper = lower.toUpperCase();
  const legacy = '1BoatSLRHtKNngkdXEeobR76b53LETtpyT';

  assert.equal(watchAddressFingerprint.FINGERPRINT_VERSION, 'watch-address-v1');
  assert.equal(watchAddressFingerprint.normalizeWatchAddress(upper), lower);
  assert.equal(watchAddressFingerprint.hmacWatchAddress(lower, key), watchAddressFingerprint.hmacWatchAddress(upper, key));
  assert.match(watchAddressFingerprint.hmacWatchAddress(lower, key), /^[a-f0-9]{64}$/);
  assert.notEqual(
    watchAddressFingerprint.normalizeWatchAddress(legacy),
    watchAddressFingerprint.normalizeWatchAddress(legacy).toLowerCase()
  );
});

test('watch address fingerprint shadow path never records seed triggers directly', () => {
  assert.match(watcherSource, /WATCH_ADDRESS_FINGERPRINT_SHADOW_MATCH/);
  assert.match(watcherSource, /WATCH_ADDRESS_FINGERPRINT_SHADOW_MISMATCH/);

  const start = watcherSource.indexOf('for (const address of inputAddresses)');
  const livePath = watcherSource.indexOf('const addressWatches = watchesByAddress.get(address)', start);
  assert.ok(start > 0);
  assert.ok(livePath > start);

  const fingerprintBlock = watcherSource.slice(start, livePath);
  assert.doesNotMatch(fingerprintBlock, /recordSeedTrigger/);
  assert.doesNotMatch(fingerprintBlock, /kickSmsWorkerIfConfigured/);
});
