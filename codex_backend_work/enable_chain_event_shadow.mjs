#!/usr/bin/env node

import { execFileSync } from 'node:child_process';
import crypto from 'node:crypto';

const GCLOUD =
  '/Users/mitchellwleblanc/Documents/Codex/2026-04-26/i-need-help-connecting-my-entire/tools/google-cloud-sdk/bin/gcloud';
const PROJECT = 'decoywallet-a283b';
const REGION = 'us-central1';
const SERVICE = 'decoy-watcher';
const CLOUDSDK_PYTHON =
  '/Users/mitchellwleblanc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3.12';

const env = { ...process.env, CLOUDSDK_PYTHON };

function gcloud(args, options = {}) {
  return execFileSync(GCLOUD, args, {
    encoding: 'utf8',
    env,
    stdio: options.stdio || ['ignore', 'pipe', 'pipe'],
  });
}

function currentEnvMap() {
  const raw = gcloud([
    'run',
    'services',
    'describe',
    SERVICE,
    '--project',
    PROJECT,
    '--region',
    REGION,
    '--format=json',
  ]);
  const service = JSON.parse(raw);
  const envList = service?.spec?.template?.spec?.containers?.[0]?.env || [];
  return new Map(envList.map((item) => [item.name, item.value || '']));
}

const existing = currentEnvMap();
const existingSecret = (existing.get('CHAIN_EVENT_SECRET') || '').trim();
const secret = existingSecret || crypto.randomBytes(32).toString('hex');

gcloud(
  [
    'run',
    'services',
    'update',
    SERVICE,
    '--project',
    PROJECT,
    '--region',
    REGION,
    '--update-env-vars',
    [
      'CHAIN_EVENT_INGEST_ENABLED=true',
      'CHAIN_EVENT_SHADOW_MODE=true',
      'CHAIN_EVENT_MAX_TXS=500',
      'CHAIN_EVENT_MATCH_LOG_LIMIT=10',
      `CHAIN_EVENT_SECRET=${secret}`,
      'CODEX_DEPLOY_MARKER=watcher-chain-event-shadow-20260628',
    ].join(','),
    '--quiet',
  ],
  { stdio: ['ignore', 'pipe', 'pipe'] }
);

const after = currentEnvMap();
const enabled = after.get('CHAIN_EVENT_INGEST_ENABLED') === 'true';
const shadowMode = after.get('CHAIN_EVENT_SHADOW_MODE') === 'true';
const hasSecret = !!(after.get('CHAIN_EVENT_SECRET') || '').trim();

console.log(
  JSON.stringify(
    {
      ok: enabled && shadowMode && hasSecret,
      service: SERVICE,
      chainEventIngestEnabled: enabled,
      chainEventShadowMode: shadowMode,
      chainEventSecretPresent: hasSecret,
      chainEventSecretGenerated: !existingSecret,
      chainEventMaxTxs: after.get('CHAIN_EVENT_MAX_TXS') || null,
      chainEventMatchLogLimit: after.get('CHAIN_EVENT_MATCH_LOG_LIMIT') || null,
      deployMarker: after.get('CODEX_DEPLOY_MARKER') || null,
    },
    null,
    2
  )
);
