#!/usr/bin/env node

import { execFileSync } from 'node:child_process';
import crypto from 'node:crypto';

const GCLOUD =
  '/Users/mitchellwleblanc/Documents/Codex/2026-04-26/i-need-help-connecting-my-entire/tools/google-cloud-sdk/bin/gcloud';
const PROJECT = 'decoywallet-a283b';
const REGION = 'us-central1';
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

function envMap(service) {
  const envList = service?.spec?.template?.spec?.containers?.[0]?.env || [];
  return new Map(envList.map((item) => [item.name, item.value || '']));
}

const bridge = serviceJson(BRIDGE_SERVICE);
const bridgeUrl = bridge?.status?.url || bridge?.status?.address?.url;
const values = envMap(bridge);
const bridgeSecret = (values.get('CHAIN_EVENT_BRIDGE_SECRET') || '').trim();
const quicknodeStreamSecurityToken = (values.get('QUICKNODE_STREAM_SECURITY_TOKEN') || '').trim();

if (!bridgeUrl || !bridgeSecret) {
  throw new Error('Missing bridge URL or bridge secret');
}

const unauthorized = await fetch(`${bridgeUrl}/chain-event`, {
  method: 'POST',
  headers: { 'content-type': 'application/json' },
  body: JSON.stringify({ transactions: [] }),
});

const authorized = await fetch(`${bridgeUrl}/chain-event`, {
  method: 'POST',
  headers: {
    'content-type': 'application/json',
    'x-decoy-chain-event-secret': bridgeSecret,
    'x-decoy-chain-event-source': 'codex-bridge-smoke',
  },
  body: JSON.stringify({
    transactions: [
      {
        txid: `codex-bridge-smoke-${Date.now()}`,
        vin: [{ prevout: { scriptpubkey_address: 'bc1qcodexbridgeunmatched000000000000000000000000' } }],
        status: { confirmed: false },
      },
    ],
  }),
});

const authorizedBody = await authorized.json().catch(() => null);

let hmacStatus = null;
let hmacBody = null;
if (quicknodeStreamSecurityToken) {
  const hmacPayload = JSON.stringify({
    transactions: [
      {
        txid: `codex-bridge-hmac-smoke-${Date.now()}`,
        vin: [{ prevout: { scriptpubkey_address: 'bc1qcodexbridgehmac0000000000000000000000000' } }],
        status: { confirmed: false },
      },
    ],
  });
  const nonce = crypto.randomBytes(16).toString('hex');
  const timestamp = String(Date.now());
  const signature = crypto
    .createHmac('sha256', Buffer.from(quicknodeStreamSecurityToken))
    .update(Buffer.from(nonce + timestamp + hmacPayload))
    .digest('hex');

  const hmacAuthorized = await fetch(`${bridgeUrl}/chain-event`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      'x-qn-nonce': nonce,
      'x-qn-timestamp': timestamp,
      'x-qn-signature': signature,
      'x-decoy-chain-event-source': 'codex-bridge-hmac-smoke',
    },
    body: hmacPayload,
  });
  hmacStatus = hmacAuthorized.status;
  hmacBody = await hmacAuthorized.json().catch(() => null);
}

console.log(
  JSON.stringify(
    {
      ok:
        unauthorized.status === 401 &&
        authorized.status === 200 &&
        authorizedBody?.ok === true &&
        authorizedBody?.shadowMode === true &&
        authorizedBody?.newTriggers === 0 &&
        (!quicknodeStreamSecurityToken ||
          (hmacStatus === 200 && hmacBody?.ok === true && hmacBody?.shadowMode === true && hmacBody?.newTriggers === 0)),
      unauthorizedStatus: unauthorized.status,
      authorizedStatus: authorized.status,
      authorizedBody,
      hmacConfigured: !!quicknodeStreamSecurityToken,
      hmacStatus,
      hmacBody,
    },
    null,
    2
  )
);
