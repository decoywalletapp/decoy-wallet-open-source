// index.js - decoy-watcher (CommonJS)
// OUTBOUND ONLY + MEMPOOL + RECENT CONFIRMED CATCHUP
// Creates SEED_DECOY trigger when an outbound spend from any watched address appears in the
// address history endpoint. That endpoint includes mempool txs plus recent confirmed txs, so
// the watcher still has a second chance if the mempool lookup flakes before confirmation.
// Baseline: when (re)armed, mark only pre-arm outbound txs as seen so it does not immediately
// fire on existing activity. Post-arm outbound txs discovered during baseline are real triggers.
//
// Tank changes
// - Do NOT store plaintext txid in decoy_seen_txs. Store txid_hmac instead.
// - Do NOT store plaintext txid in decoy_triggers. Store txid as NULL.
// - Do NOT store raw_event (it includes txids + other sensitive details)
// - Requires env var TXID_HMAC_KEY

const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const crypto = require('crypto');

const app = express();
app.use(express.json({ limit: process.env.JSON_BODY_LIMIT || '1mb' }));

const PORT = process.env.PORT || 8080;

const supabaseUrl = process.env.ENV_SUPABASE_URL;
const supabaseServiceKey = process.env.ENV_SUPABASE_SERVICE_ROLE_KEY;

const DEFAULT_ESPLORA_BASE_URLS = 'https://blockstream.info,https://mempool.space';
const ESPLORA_BASE_URLS = parseBaseUrls(
  process.env.ESPLORA_BASE_URLS || process.env.MEMPOOL_BASE_URLS || process.env.MEMPOOL_BASE_URL || DEFAULT_ESPLORA_BASE_URLS
);
const BLOCKBOOK_BASE_URLS = parseOptionalBaseUrls(
  process.env.BLOCKBOOK_BASE_URLS ||
    process.env.BLOCKBOOK_BASE_URL ||
    process.env.QUICKNODE_BLOCKBOOK_BASE_URL ||
    process.env.BTC_BLOCKBOOK_BASE_URL
).map(normalizeBlockbookBaseUrl);
const SMS_WORKER_RUN_URL = (process.env.SMS_WORKER_RUN_URL || '').trim();

const FETCH_RETRIES = Number(process.env.FETCH_RETRIES || 3);
const FETCH_TIMEOUT_MS = Number(process.env.FETCH_TIMEOUT_MS || 8000);
const ADDRESS_FETCH_DELAY_MS = Number(process.env.ADDRESS_FETCH_DELAY_MS || 1200);
const WATCHER_RUN_MAX_MS = Number(process.env.WATCHER_RUN_MAX_MS || 55000);
const WATCH_KEY_FAST_PASSES = Math.max(
  1,
  Math.min(8, Number(process.env.WATCH_KEY_FAST_PASSES || process.env.WATCHER_WATCH_KEY_FAST_PASSES || 1))
);
const WATCH_KEY_FAST_INTERVAL_MS = Math.max(
  1000,
  Math.min(
    30000,
    Number(process.env.WATCH_KEY_FAST_INTERVAL_MS || process.env.WATCHER_WATCH_KEY_FAST_INTERVAL_MS || 10000)
  )
);
const WATCH_KEY_UTXO_ENABLED = parseEnvBool(process.env.WATCH_KEY_UTXO_ENABLED, true);
const BLOCKCHAIN_MULTIADDR_URL = (process.env.BLOCKCHAIN_MULTIADDR_URL || 'https://blockchain.info/multiaddr').trim();
const BLOCKCHAIN_MULTIADDR_LIMIT = Number(process.env.BLOCKCHAIN_MULTIADDR_LIMIT || 50);
const BLOCKBOOK_ADDRESS_PAGE_SIZE = Math.max(1, Math.min(1000, Number(process.env.BLOCKBOOK_ADDRESS_PAGE_SIZE || 25)));
const BLOCKBOOK_MAX_TXIDS_PER_ADDRESS = Math.max(1, Math.min(100, Number(process.env.BLOCKBOOK_MAX_TXIDS_PER_ADDRESS || 25)));
const BLOCKBOOK_ADDRESS_CONCURRENCY = Math.max(1, Math.min(50, Number(process.env.BLOCKBOOK_ADDRESS_CONCURRENCY || 2)));
const BLOCKBOOK_TX_CONCURRENCY = Math.max(1, Math.min(25, Number(process.env.BLOCKBOOK_TX_CONCURRENCY || 2)));
const BLOCKBOOK_ADDRESS_DETAILS = (process.env.BLOCKBOOK_ADDRESS_DETAILS || 'txids').trim();
const BLOCKBOOK_FROM_HEIGHT = (process.env.BLOCKBOOK_FROM_HEIGHT || '').trim();
const BLOCKBOOK_ADDRESS_BATCH_ENABLED = parseEnvBool(process.env.BLOCKBOOK_ADDRESS_BATCH_ENABLED, false);
const BLOCKBOOK_USAGE_MODE = String(process.env.BLOCKBOOK_USAGE_MODE || 'fallback_only').trim().toLowerCase();
const BLOCKBOOK_MAX_REQUESTS_PER_RUN = Math.max(
  0,
  Math.min(200, Number(process.env.BLOCKBOOK_MAX_REQUESTS_PER_RUN || 2))
);
const BLOCKBOOK_DISABLE_ON_429_MS = Math.max(
  0,
  Math.min(24 * 60 * 60 * 1000, Number(process.env.BLOCKBOOK_DISABLE_ON_429_MS || 60 * 60 * 1000))
);
const CHAIN_EVENT_INGEST_ENABLED = parseEnvBool(process.env.CHAIN_EVENT_INGEST_ENABLED, false);
const CHAIN_EVENT_SHADOW_MODE = parseEnvBool(process.env.CHAIN_EVENT_SHADOW_MODE, true);
const CHAIN_EVENT_SECRET = (process.env.CHAIN_EVENT_SECRET || '').trim();
const CHAIN_EVENT_MAX_TXS = Math.max(1, Math.min(5000, Number(process.env.CHAIN_EVENT_MAX_TXS || 500)));
const CHAIN_EVENT_MATCH_LOG_LIMIT = Math.max(0, Math.min(50, Number(process.env.CHAIN_EVENT_MATCH_LOG_LIMIT || 10)));

// Required for tank txid storage
const TXID_HMAC_KEY = (process.env.TXID_HMAC_KEY || '').trim();

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('[decoy-watcher] Missing ENV_SUPABASE_URL / ENV_SUPABASE_SERVICE_ROLE_KEY');
  process.exit(1);
}

if (!TXID_HMAC_KEY) {
  console.error('[decoy-watcher] Missing TXID_HMAC_KEY');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: { persistSession: false },
});

function log(...args) {
  console.log('[decoy-watcher]', ...args);
}

function parseEnvBool(value, fallback) {
  if (value === undefined || value === null || value === '') return fallback;
  return ['1', 'true', 'yes', 'on'].includes(String(value).trim().toLowerCase());
}

function healthLog(level, tag, payload) {
  const line = JSON.stringify(payload);
  if (level === 'error') {
    console.error('[decoy-watcher]', tag, line);
    return;
  }
  if (level === 'warn') {
    console.warn('[decoy-watcher]', tag, line);
    return;
  }
  log(tag, line);
}

function incrementCounter(map, key) {
  const safeKey = key || 'unknown';
  map[safeKey] = (map[safeKey] || 0) + 1;
}

let runInProgress = false;
let activeBlockbookRunBudget = null;
let blockbookDisabledUntilMs = 0;
let blockbookRateLimitedThisRun = false;

app.get('/', (req, res) => {
  res.json({ ok: true, service: 'decoy-watcher' });
});

app.post('/chain-event', async (req, res) => {
  try {
    const result = await processChainEventRequest(req);
    res.status(result.status).json(result.body);
  } catch (e) {
    console.error('[decoy-watcher] chain event ingest failed', e && e.message ? e.message : e);
    res.status(500).json({ ok: false, error: 'chain event ingest failed' });
  }
});

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function parseBaseUrls(value) {
  const urls = String(value || '')
    .split(',')
    .map((url) => url.trim().replace(/\/+$/, ''))
    .filter(Boolean);

  if (urls.length) return [...new Set(urls)];

  return [...new Set(DEFAULT_ESPLORA_BASE_URLS.split(',').map((url) => url.trim()))];
}

function parseOptionalBaseUrls(value) {
  const urls = String(value || '')
    .split(',')
    .map((url) => url.trim().replace(/\/+$/, ''))
    .filter(Boolean);

  return [...new Set(urls)];
}

function normalizeBlockbookBaseUrl(baseUrl) {
  try {
    const url = new URL(baseUrl);
    const path = url.pathname.replace(/\/+$/, '');
    const base = `${url.origin}${path && path !== '/' ? path : ''}`;

    if (url.hostname.includes('quiknode.pro') || url.hostname.includes('quicknode.com')) {
      if (base.includes('/addon/3/api/v2')) return base;
      return `${base}/addon/3/api/v2`;
    }

    if (path && path !== '/') return base;

    return `${url.origin}/api/v2`;
  } catch {
    return baseUrl;
  }
}

function providerLabel(baseUrl) {
  try {
    return new URL(baseUrl).hostname;
  } catch {
    return baseUrl;
  }
}

function errorMessage(error) {
  if (!error) return null;
  return error && error.message ? error.message : String(error);
}

function blockbookModeIsDisabled() {
  return ['off', 'disabled', 'false', '0', 'none'].includes(BLOCKBOOK_USAGE_MODE);
}

function blockbookModeAllowsPrimary() {
  return ['primary', 'primary_watch_key', 'watch_key_primary'].includes(BLOCKBOOK_USAGE_MODE);
}

function blockbookModeAllowsFallback() {
  if (blockbookModeIsDisabled()) return false;
  return [
    'fallback',
    'fallback_only',
    'reserve',
    'primary',
    'primary_watch_key',
    'watch_key_primary',
  ].includes(BLOCKBOOK_USAGE_MODE);
}

function blockbookModeIsReserveOnly() {
  return ['fallback', 'fallback_only', 'reserve'].includes(BLOCKBOOK_USAGE_MODE);
}

function beginBlockbookRunBudget() {
  activeBlockbookRunBudget = {
    max: BLOCKBOOK_MAX_REQUESTS_PER_RUN,
    used: 0,
  };
  blockbookRateLimitedThisRun = false;
}

function blockbookRuntimeDisabledReason() {
  if (!BLOCKBOOK_BASE_URLS.length) return 'blockbook source disabled';
  if (blockbookModeIsDisabled()) return `blockbook usage mode ${BLOCKBOOK_USAGE_MODE}`;
  if (blockbookDisabledUntilMs > Date.now()) {
    return `blockbook paused after rate limit until ${new Date(blockbookDisabledUntilMs).toISOString()}`;
  }
  if (activeBlockbookRunBudget && activeBlockbookRunBudget.used >= activeBlockbookRunBudget.max) {
    return `blockbook run budget exhausted (${activeBlockbookRunBudget.max})`;
  }
  return null;
}

function consumeBlockbookRunBudget() {
  const reason = blockbookRuntimeDisabledReason();
  if (reason) return { ok: false, reason };

  if (activeBlockbookRunBudget) activeBlockbookRunBudget.used += 1;
  return { ok: true, reason: null };
}

function blockbookRunBudgetSnapshot() {
  return activeBlockbookRunBudget || {
    max: BLOCKBOOK_MAX_REQUESTS_PER_RUN,
    used: 0,
  };
}

async function mapWithConcurrency(items, limit, mapper) {
  const cleanItems = Array.isArray(items) ? items : [];
  const results = new Array(cleanItems.length);
  let nextIndex = 0;

  async function worker() {
    while (nextIndex < cleanItems.length) {
      const index = nextIndex;
      nextIndex += 1;
      results[index] = await mapper(cleanItems[index], index);
    }
  }

  const workerCount = Math.min(Math.max(1, limit), cleanItems.length);
  await Promise.all(Array.from({ length: workerCount }, worker));
  return results;
}

async function fetchWithTimeout(url, ms) {
  const controller = new AbortController();
  const t = setTimeout(() => controller.abort(), ms);
  try {
    return await fetch(url, { signal: controller.signal });
  } finally {
    clearTimeout(t);
  }
}

async function fetchJsonWithRetry(url, label, options = {}) {
  const retry429 = options.retry429 !== false;
  let lastErr = null;

  for (let attempt = 0; attempt <= FETCH_RETRIES; attempt += 1) {
    try {
      const resp = await fetchWithTimeout(url, FETCH_TIMEOUT_MS);

      if (resp.status === 429) {
        if (!retry429) throw new Error(`${label} 429 Too Many Requests`);

        const retryAfter = resp.headers.get('retry-after');
        const waitMs = retryAfter ? Number(retryAfter) * 1000 : (800 + attempt * 1200);
        if (attempt < FETCH_RETRIES) {
          await sleep(waitMs);
          continue;
        }
        throw new Error(`${label} 429 Too Many Requests`);
      }

      if (!resp.ok) {
        const bodyText = await resp.text().catch(() => '');
        throw new Error(`${label} ${resp.status}: ${bodyText || 'bad response'}`);
      }

      return await resp.json();
    } catch (e) {
      lastErr = e;
      if (attempt < FETCH_RETRIES) {
        await sleep(400 + attempt * 800);
        continue;
      }
    }
  }

  throw lastErr || new Error('fetch failed');
}

async function fetchJsonFromProviders(path, label, address) {
  let lastErr = null;

  for (const baseUrl of ESPLORA_BASE_URLS) {
    const url = `${baseUrl}${path}`;
    try {
      const data = await fetchJsonWithRetry(url, `${label} ${providerLabel(baseUrl)}`);
      return { ok: true, data, provider: providerLabel(baseUrl) };
    } catch (e) {
      lastErr = e;
      console.warn(
        '[decoy-watcher]',
        label,
        'failed',
        addressLabel(address),
        providerLabel(baseUrl),
        e && e.message ? e.message : e
      );
    }
  }

  return { ok: false, data: [], provider: null, error: lastErr };
}

function buildProviderUrl(baseUrl, path, params = {}) {
  const joiner = path.startsWith('/') ? '' : '/';
  const url = new URL(`${baseUrl}${joiner}${path}`);

  for (const [key, value] of Object.entries(params)) {
    if (value === null || value === undefined || value === '') continue;
    url.searchParams.set(key, String(value));
  }

  return url.toString();
}

async function fetchJsonFromBlockbookProviders(path, params, label, address) {
  let lastErr = null;

  for (const baseUrl of BLOCKBOOK_BASE_URLS) {
    const budget = consumeBlockbookRunBudget();
    if (!budget.ok) {
      return { ok: false, data: null, provider: null, error: new Error(budget.reason) };
    }

    const url = buildProviderUrl(baseUrl, path, params);
    try {
      const data = await fetchJsonWithRetry(url, `${label} ${providerLabel(baseUrl)}`, { retry429: false });
      return { ok: true, data, provider: `blockbook:${providerLabel(baseUrl)}` };
    } catch (e) {
      lastErr = e;
      if (String(errorMessage(e) || '').includes('429 Too Many Requests') && BLOCKBOOK_DISABLE_ON_429_MS > 0) {
        blockbookDisabledUntilMs = Date.now() + BLOCKBOOK_DISABLE_ON_429_MS;
        blockbookRateLimitedThisRun = true;
      }
      console.warn(
        '[decoy-watcher]',
        label,
        'failed',
        addressLabel(address),
        providerLabel(baseUrl),
        e && e.message ? e.message : e
      );
    }
  }

  return { ok: false, data: null, provider: null, error: lastErr };
}

// Address history returns recent mempool txs plus recent confirmed txs.
async function fetchAddressCandidateTxs(address) {
  const path = `/api/address/${address}/txs`;
  const result = await fetchJsonFromProviders(path, 'address-history-endpoint', address);
  const txs = Array.isArray(result.data) ? result.data : [];
  return { ...result, txs };
}

function firstAddress(value) {
  if (!value) return null;
  if (typeof value === 'string') return value;
  if (Array.isArray(value)) return value.find((item) => typeof item === 'string' && item) || null;
  return null;
}

function blockbookInputAddress(input) {
  if (!input) return null;

  const arrayCandidates = [
    input.addresses,
    input.prevout && input.prevout.addresses,
    input.scriptPubKey && input.scriptPubKey.addresses,
  ];

  for (const candidate of arrayCandidates) {
    const address = firstAddress(candidate);
    if (address) return address;
  }

  const stringCandidates = [
    input.addr,
    input.address,
    input.prevout && input.prevout.scriptpubkey_address,
    input.prevout && input.prevout.addr,
    input.prevout && input.prevout.address,
    input.scriptPubKey && input.scriptPubKey.address,
  ];

  return firstAddress(stringCandidates);
}

function normalizeBlockbookTx(tx) {
  const txid = tx && (tx.txid || tx.txId || tx.hash || tx.id);
  const confirmations = Number(tx && tx.confirmations);
  const blockHeight = Number(tx && (tx.blockHeight || tx.block_height));
  const blockTime = Number(tx && (tx.blockTime || tx.blocktime || tx.time));
  const confirmed =
    (Number.isFinite(confirmations) && confirmations > 0) || (Number.isFinite(blockHeight) && blockHeight > 0);

  return {
    txid,
    vin: Array.isArray(tx && tx.vin)
      ? tx.vin.map((input) => ({
          prevout: {
            scriptpubkey_address: blockbookInputAddress(input),
          },
        }))
      : [],
    status: {
      confirmed,
      block_time: Number.isFinite(blockTime) && blockTime > 0 ? blockTime : null,
    },
  };
}

function normalizeBlockchainTx(tx) {
  const blockHeight = Number(tx && tx.block_height);
  const time = Number(tx && tx.time);
  const confirmed = Number.isFinite(blockHeight) && blockHeight > 0;

  return {
    txid: tx && tx.hash,
    vin: Array.isArray(tx && tx.inputs)
      ? tx.inputs.map((input) => ({
          prevout: {
            scriptpubkey_address:
              input && input.prev_out ? input.prev_out.addr || input.prev_out.address || null : null,
          },
        }))
      : [],
    status: {
      confirmed,
      block_time: Number.isFinite(time) && time > 0 ? time : null,
    },
  };
}

function txidFromEventTx(tx) {
  return tx && (tx.txid || tx.txId || tx.hash || tx.id);
}

function eventInputAddress(input) {
  return (
    blockbookInputAddress(input) ||
    firstAddress(input && input.prev_out && [input.prev_out.addr, input.prev_out.address]) ||
    firstAddress(input && [input.scriptpubkey_address, input.scriptPubKeyAddress])
  );
}

function normalizeEventTx(tx) {
  if (!tx || typeof tx !== 'object') return null;

  const nested = tx.tx || tx.transaction || null;
  if (nested && typeof nested === 'object' && !txidFromEventTx(tx)) {
    return normalizeEventTx(nested);
  }

  const txid = txidFromEventTx(tx);
  if (!txid) return null;

  const rawInputs = Array.isArray(tx.vin)
    ? tx.vin
    : Array.isArray(tx.inputs)
      ? tx.inputs
      : Array.isArray(tx.ins)
        ? tx.ins
        : [];

  const confirmations = Number(tx.confirmations);
  const blockHeight = Number(tx.blockHeight || tx.block_height || tx.block);
  const blockTime = Number(tx.blockTime || tx.blocktime || tx.block_time || tx.time);
  const confirmed =
    (tx.status && tx.status.confirmed === true) ||
    (Number.isFinite(confirmations) && confirmations > 0) ||
    (Number.isFinite(blockHeight) && blockHeight > 0);

  return {
    txid,
    vin: rawInputs.map((input) => ({
      prevout: {
        scriptpubkey_address: eventInputAddress(input),
      },
    })),
    status: {
      confirmed,
      block_time: Number.isFinite(blockTime) && blockTime > 0 ? blockTime : null,
    },
  };
}

function collectEventTxs(value, out = [], depth = 0) {
  if (out.length >= CHAIN_EVENT_MAX_TXS || depth > 5 || value === null || value === undefined) return out;

  if (Array.isArray(value)) {
    for (const item of value) {
      if (out.length >= CHAIN_EVENT_MAX_TXS) break;
      collectEventTxs(item, out, depth + 1);
    }
    return out;
  }

  if (typeof value !== 'object') return out;

  const normalized = normalizeEventTx(value);
  if (normalized) {
    out.push(normalized);
    return out;
  }

  for (const key of ['tx', 'transaction', 'transactions', 'txs', 'data', 'event', 'events', 'result', 'body']) {
    if (Object.prototype.hasOwnProperty.call(value, key)) {
      collectEventTxs(value[key], out, depth + 1);
    }
  }

  return out;
}

function blockbookTxidsFromAddressData(data) {
  const candidates = [];

  if (Array.isArray(data && data.txids)) candidates.push(...data.txids);
  if (Array.isArray(data && data.txs)) {
    candidates.push(...data.txs.map((tx) => (typeof tx === 'string' ? tx : tx && (tx.txid || tx.txId || tx.id))));
  }
  if (Array.isArray(data && data.transactions)) {
    candidates.push(
      ...data.transactions.map((tx) => (typeof tx === 'string' ? tx : tx && (tx.txid || tx.txId || tx.id)))
    );
  }

  return [...new Set(candidates.filter((txid) => typeof txid === 'string' && txid))];
}

function blockbookTxsFromAddressData(data) {
  const txs = [];

  if (Array.isArray(data && data.txs)) txs.push(...data.txs.filter((tx) => tx && typeof tx === 'object'));
  if (Array.isArray(data && data.transactions)) {
    txs.push(...data.transactions.filter((tx) => tx && typeof tx === 'object'));
  }

  return txs.map(normalizeBlockbookTx).filter((tx) => tx.txid);
}

function blockbookTxsFromXpubData(data) {
  return blockbookTxsFromAddressData(data);
}

function normalizeBlockbookUtxo(utxo) {
  if (!utxo || typeof utxo !== 'object') return null;

  const txid = utxo.txid || utxo.txId || utxo.hash || utxo.transactionHash || utxo.transaction_id;
  const rawVout = utxo.vout ?? utxo.n ?? utxo.index ?? utxo.outputIndex ?? utxo.output_index;
  const vout = Number(rawVout);
  if (!txid || !Number.isInteger(vout) || vout < 0) return null;

  const confirmations = Number(utxo.confirmations);
  const height = Number(utxo.height || utxo.blockHeight || utxo.block_height);
  const value = utxo.value ?? utxo.satoshis ?? utxo.amount ?? null;
  const address = firstAddress([
    utxo.address,
    utxo.addr,
    utxo.addresses,
    utxo.scriptPubKey && utxo.scriptPubKey.address,
    utxo.scriptPubKey && utxo.scriptPubKey.addresses,
  ]);

  return {
    txid: String(txid),
    vout,
    outpoint: `${txid}:${vout}`,
    address,
    value,
    path: utxo.path || utxo.derivationPath || utxo.derivation_path || null,
    confirmed: (Number.isFinite(confirmations) && confirmations > 0) || (Number.isFinite(height) && height > 0),
  };
}

function blockbookUtxosFromData(data) {
  const candidates = [];
  if (Array.isArray(data)) candidates.push(...data);
  if (Array.isArray(data && data.utxos)) candidates.push(...data.utxos);
  if (Array.isArray(data && data.unspent)) candidates.push(...data.unspent);
  if (Array.isArray(data && data.unspentOutputs)) candidates.push(...data.unspentOutputs);
  if (Array.isArray(data && data.outputs)) candidates.push(...data.outputs);

  const seen = new Set();
  const out = [];
  for (const item of candidates) {
    const utxo = normalizeBlockbookUtxo(item);
    if (!utxo || seen.has(utxo.outpoint)) continue;
    seen.add(utxo.outpoint);
    out.push(utxo);
  }
  return out;
}

function isWatchPublicKey(value) {
  return /^(xpub|ypub|zpub|tpub|upub|vpub)/i.test(String(value || '').trim());
}

function normalizeSeedWatch(seedOrAddresses) {
  if (Array.isArray(seedOrAddresses)) {
    return {
      addresses: seedOrAddresses.filter(Boolean),
      watchPublicKey: '',
      watchPublicKeyType: '',
      derivationPath: '',
    };
  }

  const seed = seedOrAddresses || {};
  const addresses = Array.isArray(seed.addresses) ? seed.addresses.filter(Boolean) : [];
  const watchPublicKeyCandidates = [
    seed.watch_public_key,
    seed.watchPublicKey,
    seed.zpub,
    seed.xpub,
    seed.account_xpub,
    seed.accountXpub,
  ];
  const watchPublicKey =
    watchPublicKeyCandidates.map((value) => String(value || '').trim()).find((value) => isWatchPublicKey(value)) || '';

  return {
    addresses,
    watchPublicKey,
    watchPublicKeyType: String(seed.watch_public_key_type || seed.watchPublicKeyType || '').trim(),
    derivationPath: String(seed.derivation_path || seed.derivationPath || '').trim(),
  };
}

async function fetchBlockbookTx(txid) {
  const path = `/tx/${encodeURIComponent(txid)}`;
  const result = await fetchJsonFromBlockbookProviders(path, {}, 'blockbook-tx', txid);
  if (!result.ok) return { ...result, tx: null };

  const tx = normalizeBlockbookTx(result.data);
  return { ...result, tx: tx.txid ? tx : null };
}

async function fetchBlockbookAddressCandidateTxs(address) {
  if (!BLOCKBOOK_BASE_URLS.length) {
    return { ok: false, txs: [], provider: null, error: new Error('blockbook source disabled') };
  }

  const params = {
    page: 1,
    size: BLOCKBOOK_ADDRESS_PAGE_SIZE,
    details: BLOCKBOOK_ADDRESS_DETAILS,
  };

  if (BLOCKBOOK_FROM_HEIGHT) params.fromHeight = BLOCKBOOK_FROM_HEIGHT;

  const addressResult = await fetchJsonFromBlockbookProviders(
    `/address/${encodeURIComponent(address)}`,
    params,
    'blockbook-address',
    address
  );

  if (!addressResult.ok) return { ...addressResult, txs: [] };

  const directTxs = blockbookTxsFromAddressData(addressResult.data);
  if (directTxs.length) return { ...addressResult, txs: directTxs };

  const txids = blockbookTxidsFromAddressData(addressResult.data).slice(0, BLOCKBOOK_MAX_TXIDS_PER_ADDRESS);
  if (!txids.length) return { ...addressResult, txs: [] };

  const txs = [];
  const txResults = await mapWithConcurrency(txids, BLOCKBOOK_TX_CONCURRENCY, (txid) => fetchBlockbookTx(txid));
  let failures = 0;

  for (const txResult of txResults) {
    if (!txResult.ok || !txResult.tx) {
      failures += 1;
      continue;
    }

    txs.push(txResult.tx);
  }

  if (failures > 0) {
    return {
      ok: false,
      txs,
      provider: addressResult.provider,
      error: new Error(`blockbook tx detail failures: ${failures}`),
    };
  }

  return { ...addressResult, txs };
}

async function fetchBlockbookWatchKeyCandidateTxs(watch) {
  const cleanWatch = normalizeSeedWatch(watch);
  const watchPublicKey = cleanWatch.watchPublicKey;
  if (!watchPublicKey || !BLOCKBOOK_BASE_URLS.length) {
    return { ok: false, txs: [], provider: null, error: new Error('blockbook watch-key source disabled') };
  }

  const params = {
    page: 1,
    size: BLOCKBOOK_ADDRESS_PAGE_SIZE,
    details: BLOCKBOOK_ADDRESS_DETAILS,
  };

  if (BLOCKBOOK_FROM_HEIGHT) params.fromHeight = BLOCKBOOK_FROM_HEIGHT;

  const watchKeyResult = await fetchJsonFromBlockbookProviders(
    `/xpub/${encodeURIComponent(watchPublicKey)}`,
    params,
    'blockbook-watch-key',
    'watch-key'
  );

  if (!watchKeyResult.ok) return { ...watchKeyResult, txs: [] };

  const directTxs = blockbookTxsFromXpubData(watchKeyResult.data);
  if (directTxs.length) {
    return {
      ...watchKeyResult,
      txs: directTxs,
      provider: (watchKeyResult.provider || 'blockbook').replace('blockbook:', 'blockbook-watch-key:'),
    };
  }

  const txids = blockbookTxidsFromAddressData(watchKeyResult.data).slice(0, BLOCKBOOK_MAX_TXIDS_PER_ADDRESS);
  if (!txids.length) {
    return {
      ...watchKeyResult,
      txs: [],
      provider: (watchKeyResult.provider || 'blockbook').replace('blockbook:', 'blockbook-watch-key:'),
    };
  }

  const txs = [];
  const txResults = await mapWithConcurrency(txids, BLOCKBOOK_TX_CONCURRENCY, (txid) => fetchBlockbookTx(txid));
  let failures = 0;

  for (const txResult of txResults) {
    if (!txResult.ok || !txResult.tx) {
      failures += 1;
      continue;
    }

    txs.push(txResult.tx);
  }

  if (failures > 0) {
    return {
      ok: false,
      txs,
      provider: (watchKeyResult.provider || 'blockbook').replace('blockbook:', 'blockbook-watch-key:'),
      error: new Error(`blockbook watch-key tx detail failures: ${failures}`),
    };
  }

  return {
    ...watchKeyResult,
    txs,
    provider: (watchKeyResult.provider || 'blockbook').replace('blockbook:', 'blockbook-watch-key:'),
  };
}

async function fetchBlockbookWatchKeyUtxos(watch) {
  const cleanWatch = normalizeSeedWatch(watch);
  const watchPublicKey = cleanWatch.watchPublicKey;
  if (!WATCH_KEY_UTXO_ENABLED || !watchPublicKey || !BLOCKBOOK_BASE_URLS.length) {
    return { ok: false, utxos: [], provider: null, error: new Error('blockbook watch-key utxo source disabled') };
  }

  const utxoResult = await fetchJsonFromBlockbookProviders(
    `/utxo/${encodeURIComponent(watchPublicKey)}`,
    { confirmed: 'false' },
    'blockbook-watch-key-utxo',
    'watch-key'
  );

  if (!utxoResult.ok) return { ...utxoResult, utxos: [] };

  return {
    ...utxoResult,
    utxos: blockbookUtxosFromData(utxoResult.data),
    provider: (utxoResult.provider || 'blockbook').replace('blockbook:', 'blockbook-watch-key-utxo:'),
  };
}

async function fetchBlockbookSeedCandidateTxs(addresses) {
  const cleanAddresses = Array.isArray(addresses) ? addresses.filter(Boolean) : [];
  if (!cleanAddresses.length || !BLOCKBOOK_BASE_URLS.length) {
    return { ok: false, txs: [], provider: null, error: new Error('blockbook source disabled') };
  }

  const txById = new Map();
  let failures = 0;
  let provider = null;

  const addressResults = await mapWithConcurrency(
    cleanAddresses,
    BLOCKBOOK_ADDRESS_CONCURRENCY,
    (address) => fetchBlockbookAddressCandidateTxs(address)
  );

  for (const result of addressResults) {
    if (!result.ok) {
      failures += 1;
      continue;
    }

    if (result.provider) provider = result.provider;

    for (const tx of result.txs || []) {
      const txid = tx && (tx.txid || tx.txId || tx.id);
      if (txid && !txById.has(txid)) txById.set(txid, tx);
    }
  }

  if (failures > 0) {
    console.warn('[decoy-watcher]', 'blockbook batch failed for addresses', failures, 'of', cleanAddresses.length);
    return {
      ok: false,
      txs: [...txById.values()],
      provider,
      error: new Error(`blockbook address failures: ${failures}`),
    };
  }

  return { ok: true, txs: [...txById.values()], provider: provider || 'blockbook' };
}

async function fetchBlockchainSeedBatchCandidateTxs(addresses) {
  const cleanAddresses = Array.isArray(addresses) ? addresses.filter(Boolean) : [];
  if (!cleanAddresses.length || !BLOCKCHAIN_MULTIADDR_URL) {
    return { ok: false, txs: [], provider: null, error: new Error('batch source disabled') };
  }

  try {
    const url = new URL(BLOCKCHAIN_MULTIADDR_URL);
    url.searchParams.set('active', cleanAddresses.join('|'));
    url.searchParams.set('n', String(BLOCKCHAIN_MULTIADDR_LIMIT));

    const resp = await fetchWithTimeout(url.toString(), Math.max(FETCH_TIMEOUT_MS, 15000));
    if (resp.status === 429) throw new Error('batch-source 429 Too Many Requests');
    if (!resp.ok) {
      const bodyText = await resp.text().catch(() => '');
      throw new Error(`batch-source ${resp.status}: ${bodyText || 'bad response'}`);
    }

    const data = await resp.json();
    const txs = Array.isArray(data && data.txs) ? data.txs.map(normalizeBlockchainTx).filter((tx) => tx.txid) : [];
    return { ok: true, txs, provider: `blockchain:${providerLabel(BLOCKCHAIN_MULTIADDR_URL)}` };
  } catch (e) {
    console.warn('[decoy-watcher]', 'batch-source failed', e && e.message ? e.message : e);
    return { ok: false, txs: [], provider: null, error: e };
  }
}

async function fetchBlockbookCandidateTxs(watch, addresses, fallbackUsed) {
  let attempted = false;
  let watchKeyAttempted = false;
  let watchKeyError = null;
  let addressBatchError = null;

  if (watch.watchPublicKey) {
    attempted = true;
    watchKeyAttempted = true;
    const watchKey = await fetchBlockbookWatchKeyCandidateTxs(watch);
    if (watchKey.ok) {
      return {
        ...watchKey,
        providerTier: 'blockbook-watch-key',
        blockbookAttempted: true,
        blockbookOk: true,
        blockbookWatchKeyAttempted: true,
        blockbookWatchKeyOk: true,
        fallbackUsed,
      };
    }

    watchKeyError = errorMessage(watchKey.error);
    console.warn('[decoy-watcher]', 'blockbook watch-key source failed', watchKeyError);
  }

  if (BLOCKBOOK_ADDRESS_BATCH_ENABLED) {
    attempted = true;
    const blockbook = await fetchBlockbookSeedCandidateTxs(addresses);
    if (blockbook.ok) {
      return {
        ...blockbook,
        providerTier: 'blockbook',
        blockbookAttempted: true,
        blockbookOk: true,
        blockbookWatchKeyAttempted: watchKeyAttempted,
        blockbookWatchKeyOk: false,
        fallbackUsed,
      };
    }

    addressBatchError = errorMessage(blockbook.error);
  }

  return {
    ok: false,
    txs: [],
    provider: null,
    providerTier: null,
    blockbookAttempted: attempted,
    blockbookOk: false,
    blockbookWatchKeyAttempted: watchKeyAttempted,
    blockbookWatchKeyOk: false,
    fallbackUsed: false,
    blockbookError: [watchKeyError, addressBatchError].filter(Boolean).join('; ') || 'blockbook unavailable',
  };
}

async function fetchSeedBatchCandidateTxs(seedOrAddresses) {
  const watch = normalizeSeedWatch(seedOrAddresses);
  const addresses = watch.addresses;

  if (BLOCKBOOK_BASE_URLS.length && blockbookModeAllowsPrimary()) {
    const primaryBlockbook = await fetchBlockbookCandidateTxs(watch, addresses, false);
    if (primaryBlockbook.ok) return primaryBlockbook;
  }

  const blockchain = await fetchBlockchainSeedBatchCandidateTxs(addresses);
  if (blockchain.ok) {
    return {
      ...blockchain,
      providerTier: 'blockchain',
      blockbookAttempted: false,
      blockbookOk: false,
      blockbookWatchKeyAttempted: false,
      blockbookWatchKeyOk: false,
      fallbackUsed: false,
    };
  }

  if (BLOCKBOOK_BASE_URLS.length && blockbookModeAllowsFallback()) {
    const fallbackBlockbook = await fetchBlockbookCandidateTxs(watch, addresses, true);
    if (fallbackBlockbook.ok) return fallbackBlockbook;

    return {
      ...blockchain,
      providerTier: null,
      blockbookAttempted: fallbackBlockbook.blockbookAttempted,
      blockbookOk: false,
      blockbookWatchKeyAttempted: fallbackBlockbook.blockbookWatchKeyAttempted,
      blockbookWatchKeyOk: false,
      fallbackUsed: false,
      blockbookError: fallbackBlockbook.blockbookError,
    };
  }

  return {
    ...blockchain,
    providerTier: blockchain.ok ? 'blockchain' : null,
    blockbookAttempted: false,
    blockbookOk: false,
    blockbookWatchKeyAttempted: false,
    blockbookWatchKeyOk: false,
    fallbackUsed: false,
  };
}

// Cloud Run IAM kick for sms-worker

function normalizeWorkerAudience(urlString) {
  try {
    const u = new URL(urlString);
    return u.origin;
  } catch {
    return '';
  }
}

function normalizeWorkerRunUrl(urlString) {
  try {
    const u = new URL(urlString);
    const path = u.pathname.replace(/\/+$/, '');
    const finalPath = path.endsWith('/run') ? path : `${path}/run`;
    return `${u.origin}${finalPath}`;
  } catch {
    return '';
  }
}

async function getCloudRunIdentityToken(audience) {
  try {
    if (!audience) return null;

    const mdUrl =
      'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity' +
      `?audience=${encodeURIComponent(audience)}&format=full&includeEmail=true`;

    const resp = await fetch(mdUrl, {
      headers: { 'Metadata-Flavor': 'Google' }
    });

    if (!resp.ok) {
      const text = await resp.text().catch(() => '');
      console.error('[decoy-watcher] failed to get identity token', resp.status, text);
      return null;
    }

    return await resp.text();
  } catch (e) {
    console.error('[decoy-watcher] getCloudRunIdentityToken failed', e && e.message ? e.message : e);
    return null;
  }
}

async function kickSmsWorkerIfConfigured() {
  try {
    if (!SMS_WORKER_RUN_URL) return { kicked: false, status: null, detail: 'SMS_WORKER_RUN_URL missing' };

    const runUrl = normalizeWorkerRunUrl(SMS_WORKER_RUN_URL);
    const audience = normalizeWorkerAudience(runUrl);

    if (!runUrl || !audience) {
      return { kicked: false, status: null, detail: `invalid SMS_WORKER_RUN_URL ${SMS_WORKER_RUN_URL}` };
    }

    const token = await getCloudRunIdentityToken(audience);
    if (!token) return { kicked: false, status: null, detail: 'missing identity token' };

    const controller = new AbortController();
    const t = setTimeout(() => controller.abort(), 8000);

    try {
      const resp = await fetch(runUrl, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}` },
        signal: controller.signal,
      });

      const text = await resp.text().catch(() => '');
      return { kicked: resp.ok, status: resp.status, detail: text.slice(0, 200) };
    } finally {
      clearTimeout(t);
    }
  } catch (e) {
    return { kicked: false, status: null, detail: e && e.message ? e.message : String(e) };
  }
}

// DB helpers

function toDateOrNull(v) {
  if (!v) return null;
  const d = new Date(v);
  return Number.isNaN(d.getTime()) ? null : d;
}

function addressLabel(address) {
  const a = String(address || '');
  if (a.length <= 14) return a;
  return `${a.slice(0, 6)}...${a.slice(-6)}`;
}

function idLabel(id) {
  const s = String(id || '');
  if (s.length <= 10) return s;
  return `${s.slice(0, 8)}...${s.slice(-4)}`;
}

function orderedAddresses(addresses, lastIndex) {
  if (!Array.isArray(addresses) || addresses.length === 0) return [];

  const safeLastIndex = Number.isInteger(lastIndex) ? lastIndex : -1;
  const start = ((safeLastIndex + 1) % addresses.length + addresses.length) % addresses.length;

  return addresses.map((address, offset) => ({
    address,
    index: (start + offset) % addresses.length,
  }));
}

function hasRunBudget(startedAtMs) {
  return Date.now() - startedAtMs < WATCHER_RUN_MAX_MS;
}

function recordBatchTelemetry(telemetry, batch) {
  if (!telemetry || !batch) return;

  if (batch.blockbookAttempted) telemetry.blockbookBatchAttempts += 1;
  if (batch.blockbookOk) telemetry.blockbookBatchSuccesses += 1;
  if (batch.blockbookAttempted && !batch.blockbookOk) telemetry.blockbookBatchFailures += 1;
  if (batch.blockbookWatchKeyAttempted) telemetry.blockbookWatchKeyAttempts += 1;
  if (batch.blockbookWatchKeyOk) telemetry.blockbookWatchKeySuccesses += 1;
  if (batch.blockbookWatchKeyAttempted && !batch.blockbookWatchKeyOk) telemetry.blockbookWatchKeyFailures += 1;
  if (batch.fallbackUsed) telemetry.blockbookFallbackSuccesses += 1;
  if (batch.providerTier === 'blockchain' && batch.ok) telemetry.blockchainBatchSuccesses += 1;
  if (batch.ok && batch.provider) incrementCounter(telemetry.providerCounts, batch.provider);
}

async function loadArmedDecoySeeds() {
  return await supabase.from('armed_decoy_seeds').select('decoy_id, user_id, addresses');
}

async function hydrateSeedWatchMetadata(seedRows) {
  const rows = Array.isArray(seedRows) ? seedRows : [];
  const decoyIds = [...new Set(rows.map((row) => row && row.decoy_id).filter(Boolean))];
  if (!decoyIds.length) return rows;

  const { data, error } = await supabase
    .from('decoys')
    .select('id, xpub, zpub, watch_public_key, watch_public_key_type, derivation_path')
    .in('id', decoyIds);

  if (error) {
    console.warn(
      '[decoy-watcher]',
      'decoys watch-key metadata unavailable; using seed rows as-is',
      error && error.message ? error.message : error
    );
    return rows;
  }

  const byId = new Map((data || []).map((row) => [row.id, row]));
  return rows.map((row) => {
    const metadata = byId.get(row && row.decoy_id);
    return metadata ? { ...row, ...metadata, decoy_id: row.decoy_id } : row;
  });
}

async function getSeedGateMap(userIds) {
  if (!userIds.length) return new Map();

  const { data, error } = await supabase
    .from('decoy_wallet')
    .select('user_id, decoy_seed_armed, decoy_seed_armed_at')
    .in('user_id', userIds);

  if (error) {
    console.error('[decoy-watcher] error loading decoy_wallet seed gate fields', error);
    return new Map();
  }

  const m = new Map();
  for (const r of data || []) {
    m.set(r.user_id, {
      armed: !!r.decoy_seed_armed,
      armedAt: r.decoy_seed_armed_at || null,
    });
  }
  return m;
}

async function getBaselineMap(decoyIds) {
  if (!decoyIds.length) return new Map();

  const { data, error } = await supabase
    .from('decoy_seed_baselines')
    .select('decoy_id, baselined_at')
    .in('decoy_id', decoyIds);

  if (error) {
    console.error('[decoy-watcher] error loading decoy_seed_baselines', error);
    return new Map();
  }

  const m = new Map();
  for (const r of data || []) m.set(r.decoy_id, r.baselined_at);
  return m;
}

async function getScanStateMap(decoyIds) {
  if (!decoyIds.length) return new Map();

  const { data, error } = await supabase
    .from('decoy_seed_scan_state')
    .select('decoy_id, last_index, updated_at')
    .in('decoy_id', decoyIds);

  if (error) {
    console.error('[decoy-watcher] error loading decoy_seed_scan_state', error);
    return new Map();
  }

  const m = new Map();
  for (const r of data || []) {
    m.set(r.decoy_id, {
      lastIndex: Number.isInteger(r.last_index) ? r.last_index : -1,
      updatedAt: r.updated_at || null,
    });
  }
  return m;
}

async function upsertScanState(decoyId, lastIndex) {
  if (!decoyId || !Number.isInteger(lastIndex)) return;

  const { error } = await supabase
    .from('decoy_seed_scan_state')
    .upsert(
      { decoy_id: decoyId, last_index: lastIndex, updated_at: new Date().toISOString() },
      { onConflict: 'decoy_id' }
    );

  if (error) {
    console.error('[decoy-watcher] error upserting decoy_seed_scan_state', error);
  }
}

async function upsertBaseline(decoyId) {
  const nowIso = new Date().toISOString();
  const { error } = await supabase
    .from('decoy_seed_baselines')
    .upsert({ decoy_id: decoyId, baselined_at: nowIso }, { onConflict: 'decoy_id' });

  if (error) {
    console.error('[decoy-watcher] error upserting decoy_seed_baselines', error);
  }
}

// Tank txid storage

function hmacTxid(txid) {
  return crypto.createHmac('sha256', TXID_HMAC_KEY).update(String(txid)).digest('hex');
}

function hmacOutpoint(outpoint) {
  return crypto.createHmac('sha256', TXID_HMAC_KEY).update(`utxo:${String(outpoint)}`).digest('hex');
}

async function markSeenTx(decoyId, txid) {
  return await markSeenHmac(decoyId, hmacTxid(txid));
}

async function markSeenHmac(decoyId, txid_hmac) {
  const nowIso = new Date().toISOString();

  const { data, error } = await supabase
    .from('decoy_seen_txs')
    .insert({ decoy_id: decoyId, txid_hmac, first_seen_at: nowIso })
    .select('txid_hmac')
    .limit(1);

  if (error) {
    if (error.code === '23505') return { isNew: false };
    console.error('[decoy-watcher] error inserting decoy_seen_txs', error);
    return { isNew: false };
  }

  return { isNew: !!(data && data.length) };
}

function isMissingRelationError(error) {
  const message = String((error && error.message) || '').toLowerCase();
  return error && (error.code === '42P01' || message.includes('relation') || message.includes('does not exist'));
}

// OUTBOUND ONLY: address appears in vin prevout.scriptpubkey_address
function isOutboundForAddress(tx, addr) {
  const vin = tx && Array.isArray(tx.vin) ? tx.vin : [];
  for (const input of vin) {
    const prevout = input && input.prevout ? input.prevout : null;
    const a = prevout && prevout.scriptpubkey_address ? prevout.scriptpubkey_address : null;
    if (a && a === addr) return true;
  }
  return false;
}

function outboundWatchedAddress(tx, addressSet) {
  const vin = tx && Array.isArray(tx.vin) ? tx.vin : [];
  for (const input of vin) {
    const prevout = input && input.prevout ? input.prevout : null;
    const addr = prevout && prevout.scriptpubkey_address ? prevout.scriptpubkey_address : null;
    if (addr && addressSet.has(addr)) return addr;
  }
  return null;
}

function isConfirmedTx(tx) {
  return !!(tx && tx.status && tx.status.confirmed === true);
}

function confirmedAt(tx) {
  if (!isConfirmedTx(tx)) return null;
  const blockTime = Number(tx.status.block_time);
  if (!Number.isFinite(blockTime) || blockTime <= 0) return null;
  const d = new Date(blockTime * 1000);
  return Number.isNaN(d.getTime()) ? null : d;
}

function shouldProcessOutboundTx(tx, addr, armedAt, baselineAt) {
  if (!isOutboundForAddress(tx, addr)) return false;

  // Unconfirmed txs are the fast path. They should trigger immediately when seen.
  if (!isConfirmedTx(tx)) return true;

  // Confirmed txs are the safety net. Only count transactions confirmed after the
  // current arm/baseline window, so old seed history cannot fire a fresh alert.
  const observedAt = confirmedAt(tx);
  const cutoff = baselineAt || armedAt;
  if (!observedAt || !cutoff) return false;

  return observedAt.getTime() > cutoff.getTime();
}

async function recordSeedTrigger(decoyId, userId, tx, source) {
  const txid = tx && (tx.txid || tx.txId || tx.id);
  if (!txid) return false;

  const seen = await markSeenTx(decoyId, txid);
  if (!seen.isNew) return false;

  // Tank: do not store plaintext txid or raw event in decoy_triggers
  const { error: insertTrigErr } = await supabase.from('decoy_triggers').insert({
    decoy_id: decoyId,
    user_id: userId,
    trigger_type: 'SEED_DECOY',
    txid: null,
    txid_hmac: hmacTxid(txid),
    observed_at: new Date().toISOString(),
    raw_event: null,
  });

  if (insertTrigErr) {
    if (insertTrigErr.code === '23505') return false;
    console.error('[decoy-watcher] error inserting decoy_triggers:', insertTrigErr);
    return false;
  }

  log('seed trigger recorded', 'source=', source, 'confirmed=', isConfirmedTx(tx));
  return true;
}

async function recordSeedUtxoTrigger(decoyId, userId, outpointHmac, source) {
  if (!outpointHmac) return false;

  const seen = await markSeenHmac(decoyId, outpointHmac);
  if (!seen.isNew) return false;

  const { error: insertTrigErr } = await supabase.from('decoy_triggers').insert({
    decoy_id: decoyId,
    user_id: userId,
    trigger_type: 'SEED_DECOY',
    txid: null,
    txid_hmac: outpointHmac,
    observed_at: new Date().toISOString(),
    raw_event: null,
  });

  if (insertTrigErr) {
    if (insertTrigErr.code === '23505') return false;
    console.error('[decoy-watcher] error inserting decoy_triggers for utxo spend:', insertTrigErr);
    return false;
  }

  log('seed utxo trigger recorded', 'source=', source);
  return true;
}

async function getOpenUtxoStateMap(decoyIds) {
  const cleanIds = [...new Set((decoyIds || []).filter(Boolean))];
  const out = new Map();
  if (!cleanIds.length) return { ok: true, unavailable: false, map: out };

  const { data, error } = await supabase
    .from('decoy_seed_utxo_state')
    .select('decoy_id, outpoint_hmac, first_seen_at, last_seen_at, spent_at, trigger_recorded_at')
    .in('decoy_id', cleanIds)
    .is('spent_at', null);

  if (error) {
    if (isMissingRelationError(error)) {
      console.warn('[decoy-watcher]', 'decoy_seed_utxo_state unavailable; falling back to address monitoring');
      return { ok: false, unavailable: true, map: out, error };
    }

    console.error('[decoy-watcher] error loading decoy_seed_utxo_state', error);
    return { ok: false, unavailable: false, map: out, error };
  }

  for (const row of data || []) {
    if (!out.has(row.decoy_id)) out.set(row.decoy_id, []);
    out.get(row.decoy_id).push(row);
  }

  return { ok: true, unavailable: false, map: out };
}

async function upsertCurrentUtxoStates(decoyId, utxos, source) {
  const nowIso = new Date().toISOString();
  const rows = (utxos || [])
    .map((utxo) => ({
      decoy_id: decoyId,
      outpoint_hmac: hmacOutpoint(utxo.outpoint),
      last_seen_at: nowIso,
      source: source || 'blockbook-watch-key-utxo',
      updated_at: nowIso,
    }))
    .filter((row) => row.decoy_id && row.outpoint_hmac);

  if (!rows.length) return { ok: true, count: 0 };

  const { error } = await supabase
    .from('decoy_seed_utxo_state')
    .upsert(rows, { onConflict: 'decoy_id,outpoint_hmac' });

  if (error) {
    console.error('[decoy-watcher] error upserting decoy_seed_utxo_state', error);
    return { ok: false, count: 0, error };
  }

  return { ok: true, count: rows.length };
}

async function markUtxoStateSpent(decoyId, outpointHmac, source) {
  const nowIso = new Date().toISOString();
  const { error } = await supabase
    .from('decoy_seed_utxo_state')
    .update({
      spent_at: nowIso,
      trigger_recorded_at: nowIso,
      source: source || 'blockbook-watch-key-utxo',
      updated_at: nowIso,
    })
    .eq('decoy_id', decoyId)
    .eq('outpoint_hmac', outpointHmac)
    .is('spent_at', null);

  if (error) {
    console.error('[decoy-watcher] error marking decoy_seed_utxo_state spent', error);
    return false;
  }

  return true;
}

async function closeUtxoStateWithoutTrigger(decoyId, outpointHmac, source) {
  const nowIso = new Date().toISOString();
  const { error } = await supabase
    .from('decoy_seed_utxo_state')
    .update({
      spent_at: nowIso,
      source: source || 'watch-key-utxo-baseline-reset',
      updated_at: nowIso,
    })
    .eq('decoy_id', decoyId)
    .eq('outpoint_hmac', outpointHmac)
    .is('spent_at', null);

  if (error) {
    console.error('[decoy-watcher] error closing decoy_seed_utxo_state without trigger', error);
    return false;
  }

  return true;
}

async function processWatchKeyUtxosForDecoy(decoyId, userId, watch, needsBaseline, priorOpenRows) {
  const fetched = await fetchBlockbookWatchKeyUtxos(watch);
  if (!fetched.ok) {
    return {
      ok: false,
      provider: fetched.provider,
      error: fetched.error,
      attempted: true,
      currentUtxos: 0,
      initialized: false,
      spentDetected: 0,
      createdTriggers: 0,
    };
  }

  const utxos = fetched.utxos || [];
  const currentHmacs = new Set(utxos.map((utxo) => hmacOutpoint(utxo.outpoint)));
  const priorRows = Array.isArray(priorOpenRows) ? priorOpenRows : [];
  const initialized = priorRows.length === 0;

  const upsert = await upsertCurrentUtxoStates(decoyId, utxos, fetched.provider || 'blockbook-watch-key-utxo');
  if (!upsert.ok) {
    return {
      ok: false,
      provider: fetched.provider,
      error: upsert.error,
      attempted: true,
      currentUtxos: utxos.length,
      initialized,
      spentDetected: 0,
      createdTriggers: 0,
    };
  }

  if (needsBaseline) {
    for (const row of priorRows) {
      const outpointHmac = row && row.outpoint_hmac;
      if (!outpointHmac || currentHmacs.has(outpointHmac)) continue;
      await closeUtxoStateWithoutTrigger(decoyId, outpointHmac, 'watch-key-utxo-baseline-reset');
    }
  }

  if (needsBaseline || initialized) {
    return {
      ok: true,
      provider: fetched.provider,
      attempted: true,
      currentUtxos: utxos.length,
      initialized,
      spentDetected: 0,
      createdTriggers: 0,
    };
  }

  let spentDetected = 0;
  let createdTriggers = 0;
  for (const row of priorRows) {
    const outpointHmac = row && row.outpoint_hmac;
    if (!outpointHmac || currentHmacs.has(outpointHmac)) continue;

    spentDetected += 1;
    const source = `watch-key-utxo-spent:${fetched.provider || 'blockbook'}`;
    const created = await recordSeedUtxoTrigger(decoyId, userId, outpointHmac, source);
    await markUtxoStateSpent(decoyId, outpointHmac, source);
    if (created) createdTriggers += 1;
  }

  return {
    ok: true,
    provider: fetched.provider,
    attempted: true,
    currentUtxos: utxos.length,
    initialized,
    spentDetected,
    createdTriggers,
  };
}

function chainEventSecretFromRequest(req) {
  const explicit = req.get('x-decoy-chain-event-secret') || req.get('x-chain-event-secret') || '';
  if (explicit) return explicit.trim();

  const authorization = req.get('authorization') || '';
  const match = authorization.match(/^Bearer\s+(.+)$/i);
  return match ? match[1].trim() : '';
}

function chainEventAuthorized(req) {
  if (!CHAIN_EVENT_SECRET) return false;

  const supplied = chainEventSecretFromRequest(req);
  if (!supplied) return false;

  const expected = Buffer.from(CHAIN_EVENT_SECRET);
  const actual = Buffer.from(supplied);
  return expected.length === actual.length && crypto.timingSafeEqual(expected, actual);
}

async function loadEligibleArmedSeedWatches() {
  const { data: seedRows, error: seedsError } = await loadArmedDecoySeeds();
  if (seedsError) throw new Error(`error loading armed_decoy_seeds: ${seedsError.message || seedsError}`);

  const seeds = await hydrateSeedWatchMetadata(seedRows || []);
  const userIds = [...new Set(seeds.map((seed) => seed.user_id).filter(Boolean))];
  const gateMap = await getSeedGateMap(userIds);
  const decoyIds = [...new Set(seeds.map((seed) => seed.decoy_id).filter(Boolean))];
  const baselineMap = await getBaselineMap(decoyIds);
  const watches = [];

  for (const seed of seeds) {
    const { decoy_id, user_id } = seed || {};
    const watch = normalizeSeedWatch(seed);
    const addresses = watch.addresses;
    if (!decoy_id || !user_id || !Array.isArray(addresses) || !addresses.length) continue;

    const gate = gateMap.get(user_id) || { armed: false, armedAt: null };
    if (gate.armed !== true) continue;

    watches.push({
      decoyId: decoy_id,
      userId: user_id,
      addresses,
      addressSet: new Set(addresses.filter(Boolean)),
      armedAt: toDateOrNull(gate.armedAt),
      lastBaseline: toDateOrNull(baselineMap.get(decoy_id)),
    });
  }

  return watches;
}

async function processChainEventRequest(req) {
  if (!CHAIN_EVENT_INGEST_ENABLED) {
    return { status: 404, body: { ok: false, error: 'chain event ingest disabled' } };
  }

  if (!CHAIN_EVENT_SECRET) {
    return { status: 503, body: { ok: false, error: 'chain event secret missing' } };
  }

  if (!chainEventAuthorized(req)) {
    return { status: 401, body: { ok: false, error: 'unauthorized' } };
  }

  const txs = collectEventTxs(req.body);
  if (!txs.length) {
    return { status: 200, body: { ok: true, txsReceived: 0, matchedInputs: 0, newTriggers: 0 } };
  }

  const watches = await loadEligibleArmedSeedWatches();
  const watchesByAddress = new Map();

  for (const watch of watches) {
    for (const address of watch.addressSet) {
      if (!watchesByAddress.has(address)) watchesByAddress.set(address, []);
      watchesByAddress.get(address).push(watch);
    }
  }

  const source =
    req.get('x-decoy-chain-event-source') ||
    req.get('x-quicknode-stream-id') ||
    req.get('x-webhook-source') ||
    'chain-event';
  const processedPairs = new Set();
  let matchedInputs = 0;
  let candidateTriggers = 0;
  let newTriggers = 0;
  let shadowMatchesLogged = 0;

  for (const tx of txs) {
    const txid = tx && (tx.txid || tx.txId || tx.id);
    if (!txid) continue;

    const inputAddresses = new Set(
      (Array.isArray(tx.vin) ? tx.vin : [])
        .map((input) => input && input.prevout && input.prevout.scriptpubkey_address)
        .filter(Boolean)
    );

    for (const address of inputAddresses) {
      const addressWatches = watchesByAddress.get(address) || [];
      if (!addressWatches.length) continue;
      matchedInputs += addressWatches.length;

      for (const watch of addressWatches) {
        if (!shouldProcessOutboundTx(tx, address, watch.armedAt, watch.lastBaseline)) continue;

        const pairKey = `${watch.decoyId}:${txid}`;
        if (processedPairs.has(pairKey)) continue;
        processedPairs.add(pairKey);

        candidateTriggers += 1;

        if (CHAIN_EVENT_SHADOW_MODE) {
          if (shadowMatchesLogged < CHAIN_EVENT_MATCH_LOG_LIMIT) {
            shadowMatchesLogged += 1;
            healthLog('info', 'CHAIN_EVENT_SHADOW_MATCH', {
              source,
              confirmed: isConfirmedTx(tx),
              decoyRef: idLabel(watch.decoyId),
              userRef: idLabel(watch.userId),
              addressRef: addressLabel(address),
              txidHmacRef: hmacTxid(txid).slice(0, 16),
            });
          }
          continue;
        }

        const created = await recordSeedTrigger(
          watch.decoyId,
          watch.userId,
          tx,
          isConfirmedTx(tx) ? `chain-event-confirmed:${source}` : `chain-event-mempool:${source}`
        );
        if (created) newTriggers += 1;
      }
    }
  }

  if (!CHAIN_EVENT_SHADOW_MODE && newTriggers > 0) {
    const kick = await kickSmsWorkerIfConfigured();
    log('sms-worker kick result:', kick);
  }

  healthLog('info', 'CHAIN_EVENT_INGEST_OK', {
    txsReceived: txs.length,
    eligibleSeedRecords: watches.length,
    shadowMode: CHAIN_EVENT_SHADOW_MODE,
    matchedInputs,
    candidateTriggers,
    newTriggers,
    shadowMatchesLogged,
  });

  return {
    status: 200,
    body: {
      ok: true,
      txsReceived: txs.length,
      eligibleSeedRecords: watches.length,
      shadowMode: CHAIN_EVENT_SHADOW_MODE,
      matchedInputs,
      candidateTriggers,
      newTriggers,
    },
  };
}

async function baselineDecoyNow(decoyId, userId, seedOrAddresses, armedAt) {
  const watch = normalizeSeedWatch(seedOrAddresses);
  const addresses = watch.addresses;
  let markedSeen = 0;
  let createdTriggers = 0;
  const addressSet = new Set((Array.isArray(addresses) ? addresses : []).filter(Boolean));

  const batch = await fetchSeedBatchCandidateTxs(watch);
  if (batch.ok) {
    const seenTxids = new Set();
    for (const tx of batch.txs) {
      const txid = tx && (tx.txid || tx.txId || tx.id);
      if (!txid || seenTxids.has(txid)) continue;
      seenTxids.add(txid);

      const addr = outboundWatchedAddress(tx, addressSet);
      if (!addr) continue;

      if (shouldProcessOutboundTx(tx, addr, armedAt, null)) {
        const created = await recordSeedTrigger(
          decoyId,
          userId,
          tx,
          isConfirmedTx(tx) ? `baseline-batch-confirmed:${batch.provider || 'unknown'}` : `baseline-batch-mempool:${batch.provider || 'unknown'}`
        );
        if (created) createdTriggers += 1;
      } else {
        const seen = await markSeenTx(decoyId, txid);
        if (seen.isNew) markedSeen += 1;
      }
    }

    return {
      ok: true,
      markedSeen,
      createdTriggers,
      batchOk: true,
      provider: batch.provider,
      providerTier: batch.providerTier,
      blockbookAttempted: batch.blockbookAttempted,
      blockbookOk: batch.blockbookOk,
      blockbookWatchKeyAttempted: batch.blockbookWatchKeyAttempted,
      blockbookWatchKeyOk: batch.blockbookWatchKeyOk,
      fallbackUsed: batch.fallbackUsed,
      blockbookError: batch.blockbookError,
    };
  }

  for (const addr of addresses) {
    if (!addr) continue;

    const { txs } = await fetchAddressCandidateTxs(addr);
    if (!txs.length) continue;

    for (const tx of txs) {
      const txid = tx && (tx.txid || tx.txId || tx.id);
      if (!txid) continue;

      if (!isOutboundForAddress(tx, addr)) continue;

      if (shouldProcessOutboundTx(tx, addr, armedAt, null)) {
        const created = await recordSeedTrigger(
          decoyId,
          userId,
          tx,
          isConfirmedTx(tx) ? 'baseline-confirmed-catchup' : 'baseline-mempool'
        );
        if (created) createdTriggers += 1;
      } else {
        const seen = await markSeenTx(decoyId, txid);
        if (seen.isNew) markedSeen += 1;
      }
    }
  }

  return {
    ok: false,
    markedSeen,
    createdTriggers,
    batchOk: false,
    provider: batch.provider,
    providerTier: batch.providerTier,
    blockbookAttempted: batch.blockbookAttempted,
    blockbookOk: batch.blockbookOk,
    blockbookWatchKeyAttempted: batch.blockbookWatchKeyAttempted,
    blockbookWatchKeyOk: batch.blockbookWatchKeyOk,
    fallbackUsed: batch.fallbackUsed,
    blockbookError: batch.blockbookError,
  };
}

async function processRun(options = {}) {
  const runMode = options.runMode || 'full';
  const watchKeyOnly = options.watchKeyOnly === true;
  const startedAtMs = Date.now();
  const nowIso = new Date().toISOString();
  beginBlockbookRunBudget();
  console.log('--------------------------------------------');
  log('/run at', nowIso, `mode=${runMode}`);
  log(
    'config',
    `providers=${ESPLORA_BASE_URLS.map(providerLabel).join(',')}`,
    `blockbookProviders=${BLOCKBOOK_BASE_URLS.length ? BLOCKBOOK_BASE_URLS.map(providerLabel).join(',') : 'disabled'}`,
    `blockbookUsageMode=${BLOCKBOOK_USAGE_MODE}`,
    `blockbookMaxRequestsPerRun=${BLOCKBOOK_MAX_REQUESTS_PER_RUN}`,
    `blockbookAddressBatchEnabled=${BLOCKBOOK_ADDRESS_BATCH_ENABLED}`,
    `blockbookAddressConcurrency=${BLOCKBOOK_ADDRESS_CONCURRENCY}`,
    `blockbookTxConcurrency=${BLOCKBOOK_TX_CONCURRENCY}`,
    `fetchRetries=${FETCH_RETRIES}`,
    `fetchTimeoutMs=${FETCH_TIMEOUT_MS}`,
    `runMaxMs=${WATCHER_RUN_MAX_MS}`,
    `watchKeyOnly=${watchKeyOnly}`,
    `watchKeyFastPasses=${WATCH_KEY_FAST_PASSES}`,
    `watchKeyFastIntervalMs=${WATCH_KEY_FAST_INTERVAL_MS}`,
    `watchKeyUtxoEnabled=${WATCH_KEY_UTXO_ENABLED}`
  );

  const { data: seedRows, error: seedsError } = await loadArmedDecoySeeds();

  if (seedsError) {
    console.error('[decoy-watcher] error loading armed_decoy_seeds:', seedsError);
    return { ok: false, error: seedsError.message };
  }

  const seeds = await hydrateSeedWatchMetadata(seedRows || []);

  if (!seeds || seeds.length === 0) {
    log('no decoy seeds rows');
    return { ok: true, processed: 0, baselinedDecoys: 0, totalAddressesChecked: 0 };
  }

  const userIds = [...new Set(seeds.map((s) => s.user_id).filter(Boolean))];
  const gateMap = await getSeedGateMap(userIds);

  const decoyIds = [...new Set(seeds.map((s) => s.decoy_id).filter(Boolean))];
  const baselineMap = await getBaselineMap(decoyIds);
  const scanStateMap = await getScanStateMap(decoyIds);

  let newTriggers = 0;
  let baselinedDecoys = 0;
  let totalAddressesChecked = 0;
  let runBudgetExhausted = false;
  let expectedAddresses = 0;
  let batchScanSuccesses = 0;
  let batchScanFailures = 0;
  let baselineBatchFailures = 0;
  const batchTelemetry = {
    blockbookBatchAttempts: 0,
    blockbookBatchSuccesses: 0,
    blockbookBatchFailures: 0,
    blockbookWatchKeyAttempts: 0,
    blockbookWatchKeySuccesses: 0,
    blockbookWatchKeyFailures: 0,
    blockbookFallbackSuccesses: 0,
    blockchainBatchSuccesses: 0,
    providerCounts: {},
  };
  const watchKeyUtxoTelemetry = {
    watchKeyRecords: 0,
    attempts: 0,
    successes: 0,
    failures: 0,
    tableUnavailable: false,
    initializedRecords: 0,
    currentUtxosSeen: 0,
    spentDetected: 0,
    createdTriggers: 0,
    providerCounts: {},
  };

  const eligibleSeeds = [];

  for (const seed of seeds) {
    const { decoy_id, user_id } = seed || {};
    const watch = normalizeSeedWatch(seed);
    const addresses = watch.addresses;
    if (!decoy_id || !user_id) continue;
    if (!addresses || !Array.isArray(addresses) || addresses.length === 0) continue;
    if (watchKeyOnly && !watch.watchPublicKey) continue;

    const gate = gateMap.get(user_id) || { armed: false, armedAt: null };
    const isArmed = gate.armed === true;
    const armedAt = toDateOrNull(gate.armedAt);

    if (!isArmed) continue;

    expectedAddresses += addresses.length;

    const lastBaseline = toDateOrNull(baselineMap.get(decoy_id));
    const needsBaseline = !!armedAt && (!lastBaseline || lastBaseline < armedAt);
    const scanState = scanStateMap.get(decoy_id) || { lastIndex: -1, updatedAt: null };
    const lastScanAt = toDateOrNull(scanState.updatedAt);

    eligibleSeeds.push({
      seed,
      watch,
      armedAt,
      lastBaseline,
      needsBaseline,
      scanState,
      lastScanAt,
    });
  }

  eligibleSeeds.sort((a, b) => {
    if (a.needsBaseline !== b.needsBaseline) return a.needsBaseline ? -1 : 1;

    // Prefer records that have never scanned, then the stalest scanned record.
    const aScan = a.lastScanAt ? a.lastScanAt.getTime() : 0;
    const bScan = b.lastScanAt ? b.lastScanAt.getTime() : 0;
    if (aScan !== bScan) return aScan - bScan;

    const aBaseline = a.lastBaseline ? a.lastBaseline.getTime() : 0;
    const bBaseline = b.lastBaseline ? b.lastBaseline.getTime() : 0;
    return aBaseline - bBaseline;
  });

  const watchKeySeedDecoyIds = eligibleSeeds
    .filter((item) => item.watch && item.watch.watchPublicKey)
    .map((item) => item.seed && item.seed.decoy_id)
    .filter(Boolean);
  watchKeyUtxoTelemetry.watchKeyRecords = watchKeySeedDecoyIds.length;

  const utxoState = WATCH_KEY_UTXO_ENABLED
    ? await getOpenUtxoStateMap(watchKeySeedDecoyIds)
    : { ok: true, unavailable: false, map: new Map() };
  const openUtxoStateMap = utxoState.map || new Map();
  watchKeyUtxoTelemetry.tableUnavailable = !!utxoState.unavailable;

  log(
    'eligible armed seed records',
    eligibleSeeds.length,
    'baselinePending',
    eligibleSeeds.filter((s) => s.needsBaseline).length,
    'watchKeyRecords',
    watchKeySeedDecoyIds.length
  );

  for (const item of eligibleSeeds) {
    const { seed, watch, armedAt, lastBaseline, needsBaseline, scanState } = item;
    const { decoy_id, user_id } = seed;
    const addresses = watch.addresses;

    if (watch.watchPublicKey && WATCH_KEY_UTXO_ENABLED && !utxoState.unavailable) {
      watchKeyUtxoTelemetry.attempts += 1;
      const utxoScan = await processWatchKeyUtxosForDecoy(
        decoy_id,
        user_id,
        watch,
        needsBaseline,
        openUtxoStateMap.get(decoy_id) || []
      );

      if (utxoScan.ok) {
        watchKeyUtxoTelemetry.successes += 1;
        watchKeyUtxoTelemetry.currentUtxosSeen += utxoScan.currentUtxos;
        watchKeyUtxoTelemetry.spentDetected += utxoScan.spentDetected;
        watchKeyUtxoTelemetry.createdTriggers += utxoScan.createdTriggers;
        if (utxoScan.initialized) watchKeyUtxoTelemetry.initializedRecords += 1;
        if (utxoScan.provider) incrementCounter(watchKeyUtxoTelemetry.providerCounts, utxoScan.provider);

        totalAddressesChecked += addresses.length;
        await upsertScanState(decoy_id, addresses.length - 1);
        newTriggers += utxoScan.createdTriggers;

        if (needsBaseline) {
          await upsertBaseline(decoy_id);
          baselinedDecoys += 1;
          log(
            'watch-key utxo baseline completed for decoy_id',
            decoy_id,
            'current_utxos',
            utxoScan.currentUtxos
          );
        } else {
          log(
            'watch-key utxo scan completed for decoy_id',
            decoy_id,
            'current_utxos',
            utxoScan.currentUtxos,
            'spent_detected',
            utxoScan.spentDetected,
            'created_triggers',
            utxoScan.createdTriggers
          );
        }

        continue;
      }

      watchKeyUtxoTelemetry.failures += 1;
      log(
        'watch-key utxo scan failed for decoy_id',
        decoy_id,
        'falling back to stored-address monitoring',
        errorMessage(utxoScan.error)
      );
    }

    if (needsBaseline) {
      const baseline = await baselineDecoyNow(decoy_id, user_id, watch, armedAt);
      recordBatchTelemetry(batchTelemetry, baseline);
      await upsertBaseline(decoy_id);

      baselinedDecoys += 1;
      newTriggers += baseline.createdTriggers;
      totalAddressesChecked += addresses.length;
      if (!baseline.batchOk) baselineBatchFailures += 1;
      log(
        'baseline completed for decoy_id',
        decoy_id,
        'marked_seen',
        baseline.markedSeen,
        'created_triggers',
        baseline.createdTriggers
      );
      continue;
    }

    const lastScanIndex = scanState.lastIndex;

    const batch = await fetchSeedBatchCandidateTxs(watch);
    recordBatchTelemetry(batchTelemetry, batch);
    if (batch.ok) {
      batchScanSuccesses += 1;
      totalAddressesChecked += addresses.length;
      await upsertScanState(decoy_id, addresses.length - 1);

      const addressSet = new Set(addresses.filter(Boolean));
      const seenTxids = new Set();
      for (const tx of batch.txs) {
        const txid = tx && (tx.txid || tx.txId || tx.id);
        if (!txid || seenTxids.has(txid)) continue;
        seenTxids.add(txid);

        const addr = outboundWatchedAddress(tx, addressSet);
        if (!addr) continue;
        if (!shouldProcessOutboundTx(tx, addr, armedAt, lastBaseline)) continue;

        const created = await recordSeedTrigger(
          decoy_id,
          user_id,
          tx,
          isConfirmedTx(tx) ? `batch-confirmed:${batch.provider || 'unknown'}` : `batch-mempool:${batch.provider || 'unknown'}`
        );
        if (created) newTriggers += 1;
      }

      continue;
    }

    batchScanFailures += 1;

    const ordered = orderedAddresses(addresses, lastScanIndex);

    for (const item of ordered) {
      if (!hasRunBudget(startedAtMs)) {
        runBudgetExhausted = true;
        log('run budget exhausted; will resume next run');
        break;
      }

      const addr = item.address;
      if (!addr) continue;

      totalAddressesChecked += 1;

      const { txs, ok, provider } = await fetchAddressCandidateTxs(addr);
      await upsertScanState(decoy_id, item.index);
      if (ADDRESS_FETCH_DELAY_MS > 0) await sleep(ADDRESS_FETCH_DELAY_MS);

      if (!ok) {
        log('address history lookup exhausted all providers for', addressLabel(addr));
      }

      if (!txs.length) continue;

      for (const tx of txs) {
        if (!shouldProcessOutboundTx(tx, addr, armedAt, lastBaseline)) continue;

        const created = await recordSeedTrigger(
          decoy_id,
          user_id,
          tx,
          isConfirmedTx(tx) ? `confirmed-catchup:${provider || 'unknown'}` : `mempool:${provider || 'unknown'}`
        );
        if (created) newTriggers += 1;
      }

    }

    if (runBudgetExhausted) break;
  }

  if (newTriggers > 0) {
    const kick = await kickSmsWorkerIfConfigured();
    log('sms-worker kick result:', kick);
  }

  log(
    'finished /run, newTriggers=',
    newTriggers,
    'baselinedDecoys=',
    baselinedDecoys,
    'totalAddressesChecked=',
    totalAddressesChecked,
    'runBudgetExhausted=',
    runBudgetExhausted
  );

  const healthPayload = {
    runMode,
    watchKeyOnly,
    eligibleSeedRecords: eligibleSeeds.length,
    expectedAddresses,
    totalAddressesChecked,
    blockbookConfigured: BLOCKBOOK_BASE_URLS.length > 0,
    blockbookBatchAttempts: batchTelemetry.blockbookBatchAttempts,
    blockbookBatchSuccesses: batchTelemetry.blockbookBatchSuccesses,
    blockbookBatchFailures: batchTelemetry.blockbookBatchFailures,
    blockbookWatchKeyAttempts: batchTelemetry.blockbookWatchKeyAttempts,
    blockbookWatchKeySuccesses: batchTelemetry.blockbookWatchKeySuccesses,
    blockbookWatchKeyFailures: batchTelemetry.blockbookWatchKeyFailures,
    blockbookFallbackSuccesses: batchTelemetry.blockbookFallbackSuccesses,
    blockchainBatchSuccesses: batchTelemetry.blockchainBatchSuccesses,
    watchKeyUtxoEnabled: WATCH_KEY_UTXO_ENABLED,
    watchKeyRecords: watchKeyUtxoTelemetry.watchKeyRecords,
    watchKeyUtxoAttempts: watchKeyUtxoTelemetry.attempts,
    watchKeyUtxoSuccesses: watchKeyUtxoTelemetry.successes,
    watchKeyUtxoFailures: watchKeyUtxoTelemetry.failures,
    watchKeyUtxoTableUnavailable: watchKeyUtxoTelemetry.tableUnavailable,
    watchKeyUtxoInitializedRecords: watchKeyUtxoTelemetry.initializedRecords,
    watchKeyUtxoCurrentUtxosSeen: watchKeyUtxoTelemetry.currentUtxosSeen,
    watchKeyUtxoSpentDetected: watchKeyUtxoTelemetry.spentDetected,
    watchKeyUtxoCreatedTriggers: watchKeyUtxoTelemetry.createdTriggers,
    watchKeyUtxoProviderCounts: watchKeyUtxoTelemetry.providerCounts,
    providerCounts: batchTelemetry.providerCounts,
    blockbookUsageMode: BLOCKBOOK_USAGE_MODE,
    blockbookRequestsUsed: blockbookRunBudgetSnapshot().used,
    blockbookMaxRequestsPerRun: blockbookRunBudgetSnapshot().max,
    blockbookPausedAfterRateLimit: blockbookDisabledUntilMs > Date.now(),
    runBudgetExhausted,
    batchScanSuccesses,
    batchScanFailures,
    baselineBatchFailures,
    newTriggers,
    baselinedDecoys,
  };

  if (
    healthPayload.blockbookRequestsUsed > 0 &&
    blockbookModeIsReserveOnly() &&
    watchKeyUtxoTelemetry.attempts === 0
  ) {
    healthLog('warn', 'WATCHER_QUICKNODE_RESERVE_USED', healthPayload);
  }

  if (blockbookRateLimitedThisRun) {
    healthLog('error', 'WATCHER_QUICKNODE_RATE_LIMIT', healthPayload);
  }

  if (
    runBudgetExhausted ||
    totalAddressesChecked < expectedAddresses ||
    batchScanFailures > 0 ||
    baselineBatchFailures > 0 ||
    watchKeyUtxoTelemetry.tableUnavailable ||
    watchKeyUtxoTelemetry.failures > 0
  ) {
    healthLog('error', 'WATCHER_HEALTH_FAIL', healthPayload);
  } else {
    if (BLOCKBOOK_BASE_URLS.length > 0 && batchTelemetry.blockbookBatchFailures > 0) {
      healthLog('warn', 'WATCHER_PRIMARY_PROVIDER_DEGRADED', healthPayload);
    }
    healthLog('info', 'WATCHER_HEALTH_OK', healthPayload);
  }

  return { ok: true, processed: newTriggers, baselinedDecoys, totalAddressesChecked, runBudgetExhausted };
}

async function processScheduledRun() {
  const results = [];
  const first = await processRun({ runMode: 'full' });
  results.push(first);

  if (!first || first.ok !== true || WATCH_KEY_FAST_PASSES <= 1) {
    return first;
  }

  for (let pass = 2; pass <= WATCH_KEY_FAST_PASSES; pass += 1) {
    await sleep(WATCH_KEY_FAST_INTERVAL_MS);
    const result = await processRun({
      runMode: `watch-key-fast-${pass}`,
      watchKeyOnly: true,
    });
    results.push(result);

    if (!result || result.ok !== true) break;
  }

  return {
    ok: results.every((result) => result && result.ok === true),
    processed: results.reduce((sum, result) => sum + Number((result && result.processed) || 0), 0),
    baselinedDecoys: results.reduce((sum, result) => sum + Number((result && result.baselinedDecoys) || 0), 0),
    totalAddressesChecked: results.reduce((sum, result) => sum + Number((result && result.totalAddressesChecked) || 0), 0),
    runBudgetExhausted: results.some((result) => !!(result && result.runBudgetExhausted)),
    passes: results.length,
    fastWatchKeyPasses: Math.max(0, results.length - 1),
  };
}

app.post('/run', async (req, res) => {
  if (runInProgress) {
    log('skipping overlapping /run request');
    return res.status(202).json({ ok: true, skipped: true, reason: 'run already in progress' });
  }

  runInProgress = true;
  try {
    const result = await processScheduledRun();
    res.json(result);
  } catch (err) {
    console.error('[decoy-watcher] fatal /run error:', err);
    res.status(500).json({ ok: false, error: 'internal error' });
  } finally {
    runInProgress = false;
  }
});

app.listen(PORT, () => {
  log(`listening on port ${PORT}`);
});
