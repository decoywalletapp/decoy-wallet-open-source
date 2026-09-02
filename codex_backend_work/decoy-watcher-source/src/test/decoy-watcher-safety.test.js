const assert = require('node:assert/strict');
const test = require('node:test');

const { shouldProcessOutboundTx, shouldTriggerMissingUtxo } = require('../watcher_tx_filter');
const logRedaction = require('../watcher_log_redaction');

const watchedAddress = 'bc1qwatchedaddress0000000000000000000000000000000';
const otherAddress = 'bc1qotheraddress00000000000000000000000000000000';

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
