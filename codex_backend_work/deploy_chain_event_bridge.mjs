#!/usr/bin/env node

import { execFileSync } from 'node:child_process';
import crypto from 'node:crypto';

const GCLOUD =
  '/Users/mitchellwleblanc/Documents/Codex/2026-04-26/i-need-help-connecting-my-entire/tools/google-cloud-sdk/bin/gcloud';
const NODE = '/Users/mitchellwleblanc/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node';
const PROJECT = 'decoywallet-a283b';
const REGION = 'us-central1';
const WATCHER_SERVICE = 'decoy-watcher';
const BRIDGE_SERVICE = 'decoy-chain-event-bridge';
const SOURCE_DIR =
  '/Users/mitchellwleblanc/Documents/GitHub/mobile-app-android/codex_backend_work/chain-event-bridge-source/src';
const CLOUDSDK_PYTHON =
  '/Users/mitchellwleblanc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3.12';
const DEFAULT_COMPUTE_SERVICE_ACCOUNT = '866378207353-compute@developer.gserviceaccount.com';

const env = { ...process.env, CLOUDSDK_PYTHON };

function run(cmd, args, options = {}) {
  return execFileSync(cmd, args, {
    encoding: 'utf8',
    env,
    stdio: options.stdio || ['ignore', 'pipe', 'pipe'],
  });
}

function gcloud(args, options = {}) {
  return run(GCLOUD, args, options);
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

function tryServiceJson(name) {
  try {
    return serviceJson(name);
  } catch (_) {
    return null;
  }
}

function envMap(service) {
  const envList = service?.spec?.template?.spec?.containers?.[0]?.env || [];
  return new Map(envList.map((item) => [item.name, item.value || '']));
}

run(NODE, ['--check', `${SOURCE_DIR}/index.js`]);

const watcher = serviceJson(WATCHER_SERVICE);
const watcherUrl = watcher?.status?.url || watcher?.status?.address?.url;
const watcherEnv = envMap(watcher);
const watcherSecret = (watcherEnv.get('CHAIN_EVENT_SECRET') || '').trim();
const existingBridge = tryServiceJson(BRIDGE_SERVICE);
const existingBridgeEnv = envMap(existingBridge);
const bridgeSecret = (existingBridgeEnv.get('CHAIN_EVENT_BRIDGE_SECRET') || '').trim() || crypto.randomBytes(32).toString('hex');

if (!watcherUrl || !watcherSecret) {
  throw new Error('decoy-watcher must have a URL and CHAIN_EVENT_SECRET before deploying the bridge');
}

gcloud([
  'run',
  'deploy',
  BRIDGE_SERVICE,
  '--source',
  SOURCE_DIR,
  '--project',
  PROJECT,
  '--region',
  REGION,
  '--allow-unauthenticated',
  '--set-env-vars',
  [
    `WATCHER_URL=${watcherUrl}`,
    `WATCHER_CHAIN_EVENT_SECRET=${watcherSecret}`,
    `CHAIN_EVENT_BRIDGE_SECRET=${bridgeSecret}`,
    'JSON_BODY_LIMIT_BYTES=1048576',
    'FORWARD_TIMEOUT_MS=15000',
    'CODEX_DEPLOY_MARKER=chain-event-bridge-shadow-20260628',
  ].join(','),
  '--quiet',
]);

gcloud(
  [
    'run',
    'services',
    'add-iam-policy-binding',
    WATCHER_SERVICE,
    '--project',
    PROJECT,
    '--region',
    REGION,
    '--member',
    `serviceAccount:${DEFAULT_COMPUTE_SERVICE_ACCOUNT}`,
    '--role',
    'roles/run.invoker',
    '--quiet',
  ],
  { stdio: ['ignore', 'pipe', 'pipe'] }
);

const bridge = serviceJson(BRIDGE_SERVICE);
const bridgeUrl = bridge?.status?.url || bridge?.status?.address?.url || null;

console.log(
  JSON.stringify(
    {
      ok: !!bridgeUrl,
      bridgeService: BRIDGE_SERVICE,
      bridgeUrl,
      publicIngress: true,
      bridgeSecretPresent: true,
      watcherService: WATCHER_SERVICE,
      watcherPrivateTargetConfigured: !!watcherUrl,
      watcherSecretPresent: true,
      invokerBindingRequestedFor: DEFAULT_COMPUTE_SERVICE_ACCOUNT,
    },
    null,
    2
  )
);
