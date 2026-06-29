#!/usr/bin/env node

import { execFileSync } from 'node:child_process';
import crypto from 'node:crypto';

const GCLOUD =
  '/Users/mitchellwleblanc/Documents/Codex/2026-04-26/i-need-help-connecting-my-entire/tools/google-cloud-sdk/bin/gcloud';
const PROJECT = 'decoywallet-a283b';
const REGION = 'us-central1';
const WATCHER_SERVICE = 'decoy-watcher';
const BRIDGE_SERVICE = 'decoy-chain-event-bridge';
const CLOUDSDK_PYTHON =
  '/Users/mitchellwleblanc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3.12';

const env = { ...process.env, CLOUDSDK_PYTHON };

function gcloud(args) {
  return execFileSync(GCLOUD, args, {
    encoding: 'utf8',
    env,
    stdio: ['ignore', 'pipe', 'pipe'],
  });
}

function serviceJson(name) {
  return JSON.parse(
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
}

function serviceEnv(name) {
  const service = serviceJson(name);
  const envList = service?.spec?.template?.spec?.containers?.[0]?.env || [];
  return {
    url: service?.status?.url || service?.status?.address?.url || '',
    values: new Map(envList.map((item) => [item.name, item.value || ''])),
  };
}

function ref(value) {
  return crypto.createHash('sha256').update(`decoy-shadow-smoke:${value || ''}`).digest('hex').slice(0, 10);
}

async function fetchAll({ supabaseUrl, serviceKey }, table, select) {
  const res = await fetch(`${supabaseUrl}/rest/v1/${table}?select=${encodeURIComponent(select)}&limit=1000`, {
    headers: {
      apikey: serviceKey,
      Authorization: `Bearer ${serviceKey}`,
    },
  });
  const body = await res.text();
  if (!res.ok) throw new Error(`${table} query failed ${res.status}: ${body}`);
  return JSON.parse(body);
}

const watcher = serviceEnv(WATCHER_SERVICE);
const bridge = serviceEnv(BRIDGE_SERVICE);

if (watcher.values.get('CHAIN_EVENT_INGEST_ENABLED') !== 'true') {
  throw new Error('Watcher chain-event ingest is not enabled.');
}

if (watcher.values.get('CHAIN_EVENT_SHADOW_MODE') !== 'true') {
  throw new Error('Refusing to run shadow smoke because CHAIN_EVENT_SHADOW_MODE is not true.');
}

const supabaseUrl = (watcher.values.get('ENV_SUPABASE_URL') || '').replace(/\/+$/, '');
const serviceKey = watcher.values.get('ENV_SUPABASE_SERVICE_ROLE_KEY') || '';
const bridgeSecret = (bridge.values.get('CHAIN_EVENT_BRIDGE_SECRET') || '').trim();

if (!supabaseUrl || !serviceKey) throw new Error('Missing Supabase credentials from watcher service.');
if (!bridge.url || !bridgeSecret) throw new Error('Missing chain-event bridge URL or secret.');

const [seeds, wallets] = await Promise.all([
  fetchAll({ supabaseUrl, serviceKey }, 'armed_decoy_seeds', 'user_id,decoy_id,addresses'),
  fetchAll({ supabaseUrl, serviceKey }, 'decoy_wallet', 'user_id,decoy_seed_armed'),
]);

const armedUsers = new Set(wallets.filter((row) => row.decoy_seed_armed === true).map((row) => row.user_id));
const seed = seeds.find(
  (row) => armedUsers.has(row.user_id) && Array.isArray(row.addresses) && row.addresses.filter(Boolean).length > 0
);

if (!seed) throw new Error('No armed decoy seed with watched addresses is available for shadow smoke.');

const address = seed.addresses.filter(Boolean)[0];
const txid = `codex-shadow-match-${Date.now()}-${crypto.randomBytes(4).toString('hex')}`;

const response = await fetch(`${bridge.url}/chain-event`, {
  method: 'POST',
  headers: {
    'content-type': 'application/json',
    'x-decoy-chain-event-secret': bridgeSecret,
    'x-decoy-chain-event-source': 'codex-shadow-match-smoke',
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
  Number(body?.matchedInputs || 0) > 0 &&
  Number(body?.candidateTriggers || 0) > 0 &&
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
      userRef: ref(seed.user_id),
      decoyRef: ref(seed.decoy_id),
      txidRef: ref(txid),
    },
    null,
    2
  )
);

if (!ok) process.exit(1);
