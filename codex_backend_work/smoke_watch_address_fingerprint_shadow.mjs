#!/usr/bin/env node

import { execFileSync } from 'node:child_process';
import crypto from 'node:crypto';

const GCLOUD =
  '/Users/mitchellwleblanc/Documents/Codex/2026-04-26/i-need-help-connecting-my-entire/tools/google-cloud-sdk/bin/gcloud';
const CLOUDSDK_PYTHON =
  '/Users/mitchellwleblanc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3.12';
const PROJECT = 'decoywallet-a283b';
const REGION = 'us-central1';
const WATCHER_SERVICE = 'decoy-watcher';
const BRIDGE_SERVICE = 'decoy-chain-event-bridge';

const env = { ...process.env, CLOUDSDK_PYTHON };

function gcloud(args) {
  return execFileSync(GCLOUD, args, {
    encoding: 'utf8',
    env,
    stdio: ['ignore', 'pipe', 'pipe'],
  });
}

function serviceEnv(name) {
  const service = JSON.parse(
    gcloud([
      'run',
      'services',
      'describe',
      name,
      '--project',
      PROJECT,
      '--region',
      REGION,
      '--format=json',
    ])
  );
  const envList = service?.spec?.template?.spec?.containers?.[0]?.env || [];
  return {
    url: service?.status?.url || service?.status?.address?.url || '',
    values: new Map(envList.map((item) => [item.name, item.value || ''])),
  };
}

function ref(value) {
  return crypto.createHash('sha256').update(`watch-address-fingerprint-smoke:${value || ''}`).digest('hex').slice(0, 10);
}

async function fetchAll({ supabaseUrl, serviceKey }, table, select) {
  const res = await fetch(`${supabaseUrl}/rest/v1/${table}?select=${encodeURIComponent(select)}&limit=1000`, {
    headers: {
      apikey: serviceKey,
      Authorization: `Bearer ${serviceKey}`,
    },
  });
  const text = await res.text();
  if (!res.ok) throw new Error(`${table} query failed ${res.status}: ${text}`);
  return JSON.parse(text);
}

const watcher = serviceEnv(WATCHER_SERVICE);
const bridge = serviceEnv(BRIDGE_SERVICE);

if (watcher.values.get('CHAIN_EVENT_INGEST_ENABLED') !== 'true') {
  throw new Error('Watcher chain-event ingest is not enabled.');
}

if (watcher.values.get('CHAIN_EVENT_SHADOW_MODE') !== 'true') {
  throw new Error('Refusing to run smoke because chain-event shadow mode is not true.');
}

if (watcher.values.get('WATCH_ADDRESS_FINGERPRINT_SHADOW_ENABLED') !== 'true') {
  throw new Error('Watcher watch-address fingerprint shadow mode is not enabled.');
}

if (!watcher.values.get('WATCH_ADDRESS_HMAC_KEY') && !watcher.values.get('DECOY_WATCH_ADDRESS_HMAC_KEY')) {
  throw new Error('Watcher watch-address HMAC key is not configured.');
}

const supabaseUrl = (watcher.values.get('ENV_SUPABASE_URL') || '').replace(/\/+$/, '');
const serviceKey = watcher.values.get('ENV_SUPABASE_SERVICE_ROLE_KEY') || '';
const bridgeSecret = (bridge.values.get('CHAIN_EVENT_BRIDGE_SECRET') || '').trim();

if (!supabaseUrl || !serviceKey) throw new Error('Missing Supabase credentials from watcher service.');
if (!bridge.url || !bridgeSecret) throw new Error('Missing chain-event bridge URL or secret.');

const creds = { supabaseUrl, serviceKey };
const [seeds, wallets, fingerprints] = await Promise.all([
  fetchAll(creds, 'armed_decoy_seeds', 'user_id,decoy_id,addresses'),
  fetchAll(creds, 'decoy_wallet', 'user_id,decoy_seed_armed'),
  fetchAll(creds, 'decoy_watch_address_fingerprints', 'decoy_id,address_hmac'),
]);

const armedUsers = new Set(wallets.filter((row) => row.decoy_seed_armed === true).map((row) => row.user_id));
const decoysWithFingerprints = new Set(fingerprints.map((row) => row.decoy_id).filter(Boolean));
const seed = seeds.find((row) => {
  const addresses = Array.isArray(row.addresses) ? row.addresses.filter(Boolean) : [];
  return armedUsers.has(row.user_id) && decoysWithFingerprints.has(row.decoy_id) && addresses.length > 0;
});

if (!seed) throw new Error('No armed seed with watch-address fingerprints is available for smoke testing.');

const address = seed.addresses.filter(Boolean)[0];
const txid = `codex-watch-address-fingerprint-smoke-${Date.now()}-${crypto.randomBytes(4).toString('hex')}`;

const response = await fetch(`${bridge.url}/chain-event`, {
  method: 'POST',
  headers: {
    'content-type': 'application/json',
    'x-decoy-chain-event-secret': bridgeSecret,
    'x-decoy-chain-event-source': 'codex-watch-address-fingerprint-smoke',
  },
  body: JSON.stringify({
    transactions: [
      {
        txid,
        vin: [{ prevout: { scriptpubkey_address: address } }],
        status: { confirmed: false },
      },
    ],
  }),
});

const body = await response.json().catch(() => null);
const ok =
  response.status === 200 &&
  body?.ok === true &&
  body?.shadowMode === true &&
  body?.watchAddressFingerprintShadow?.enabled === true &&
  body?.watchAddressFingerprintShadow?.keyConfigured === true &&
  Number(body?.watchAddressFingerprintShadow?.rows || 0) > 0 &&
  Number(body?.matchedInputs || 0) > 0 &&
  Number(body?.candidateTriggers || 0) > 0 &&
  Number(body?.fingerprintShadowMatchedInputs || 0) > 0 &&
  Number(body?.fingerprintShadowCandidateTriggers || 0) > 0 &&
  Number(body?.livePairsMissingFromFingerprint || 0) === 0 &&
  Number(body?.fingerprintPairsMissingFromLive || 0) === 0 &&
  Number(body?.newTriggers || 0) === 0;

console.log(
  JSON.stringify(
    {
      ok,
      status: response.status,
      shadowMode: body?.shadowMode,
      matchedInputs: body?.matchedInputs,
      candidateTriggers: body?.candidateTriggers,
      newTriggers: body?.newTriggers,
      watchAddressFingerprintShadow: {
        enabled: body?.watchAddressFingerprintShadow?.enabled,
        keyConfigured: body?.watchAddressFingerprintShadow?.keyConfigured,
        rows: body?.watchAddressFingerprintShadow?.rows,
        tableUnavailable: body?.watchAddressFingerprintShadow?.tableUnavailable,
        loadFailed: body?.watchAddressFingerprintShadow?.loadFailed,
      },
      fingerprintShadowMatchedInputs: body?.fingerprintShadowMatchedInputs,
      fingerprintShadowCandidateTriggers: body?.fingerprintShadowCandidateTriggers,
      livePairsMissingFromFingerprint: body?.livePairsMissingFromFingerprint,
      fingerprintPairsMissingFromLive: body?.fingerprintPairsMissingFromLive,
      userRef: ref(seed.user_id),
      decoyRef: ref(seed.decoy_id),
      txidRef: ref(txid),
    },
    null,
    2
  )
);

if (!ok) process.exit(1);
