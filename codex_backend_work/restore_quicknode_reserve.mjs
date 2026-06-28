#!/usr/bin/env node

import { execFileSync } from 'node:child_process';

const gcloud =
  '/Users/mitchellwleblanc/Documents/Codex/2026-04-26/i-need-help-connecting-my-entire/tools/google-cloud-sdk/bin/gcloud';
const python =
  '/Users/mitchellwleblanc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3.12';

const project = 'decoywallet-a283b';
const region = 'us-central1';
const service = 'decoy-watcher';
const sourceRevision = process.env.SOURCE_REVISION || 'decoy-watcher-00063-pht';

function runGcloud(args, options = {}) {
  return execFileSync(gcloud, args, {
    encoding: 'utf8',
    stdio: options.stdio || ['ignore', 'pipe', 'pipe'],
    env: { ...process.env, CLOUDSDK_PYTHON: python },
  });
}

function readJson(args) {
  return JSON.parse(runGcloud([...args, '--format=json']));
}

function envMapFromResource(resource) {
  const env =
    resource?.spec?.containers?.[0]?.env ||
    resource?.spec?.template?.spec?.containers?.[0]?.env ||
    resource?.template?.spec?.containers?.[0]?.env ||
    [];
  return new Map(env.map((entry) => [entry.name, entry.value]));
}

function redactedHost(rawUrl) {
  try {
    const host = new URL(rawUrl).hostname;
    if (host.length <= 16) return host;
    return `${host.slice(0, 8)}...${host.slice(-12)}`;
  } catch {
    return 'unknown-host';
  }
}

const source = readJson([
  'run',
  'revisions',
  'describe',
  sourceRevision,
  '--project',
  project,
  '--region',
  region,
]);

const sourceEnv = envMapFromResource(source);
const blockbookUrl =
  sourceEnv.get('BLOCKBOOK_BASE_URL') ||
  sourceEnv.get('BLOCKBOOK_BASE_URLS') ||
  sourceEnv.get('QUICKNODE_BLOCKBOOK_BASE_URL') ||
  sourceEnv.get('BTC_BLOCKBOOK_BASE_URL') ||
  '';

if (!blockbookUrl.trim()) {
  throw new Error(`No Blockbook URL found on source revision ${sourceRevision}.`);
}

console.log(`Restoring QuickNode reserve config from ${sourceRevision}.`);
console.log(`Provider: ${redactedHost(blockbookUrl)}`);
console.log('Mode: fallback_only, max 1 request per watcher run, address batch disabled.');

const previousRevision = runGcloud([
  'run',
  'services',
  'describe',
  service,
  '--project',
  project,
  '--region',
  region,
  '--format=value(status.traffic[0].revisionName)',
]).trim();

runGcloud(
  [
    'run',
    'services',
    'update',
    service,
    '--project',
    project,
    '--region',
    region,
    '--update-env-vars',
    [
      `BLOCKBOOK_BASE_URL=${blockbookUrl}`,
      'BLOCKBOOK_USAGE_MODE=fallback_only',
      'BLOCKBOOK_MAX_REQUESTS_PER_RUN=1',
      'BLOCKBOOK_DISABLE_ON_429_MS=3600000',
      'BLOCKBOOK_ADDRESS_BATCH_ENABLED=false',
      'WATCH_KEY_FAST_PASSES=1',
      'CODEX_DEPLOY_MARKER=watcher-quicknode-reserve-20260628',
    ].join(','),
    '--quiet',
  ],
  { stdio: ['ignore', 'inherit', 'inherit'] }
);

const targetRevision = runGcloud([
  'run',
  'services',
  'describe',
  service,
  '--project',
  project,
  '--region',
  region,
  '--format=value(status.latestCreatedRevisionName)',
]).trim();

if (!targetRevision) throw new Error('Could not determine target revision.');

runGcloud(
  [
    'run',
    'services',
    'update-traffic',
    service,
    '--project',
    project,
    '--region',
    region,
    '--to-revisions',
    `${targetRevision}=100`,
    '--quiet',
  ],
  { stdio: ['ignore', 'inherit', 'inherit'] }
);

const servingRevision = runGcloud([
  'run',
  'services',
  'describe',
  service,
  '--project',
  project,
  '--region',
  region,
  '--format=value(status.traffic[0].revisionName)',
]).trim();

console.log(`Previous revision: ${previousRevision || 'unknown'}`);
console.log(`Serving revision: ${servingRevision || 'unknown'}`);
console.log('Rollback if needed:');
console.log(
  `${gcloud} run services update-traffic ${service} --project ${project} --region ${region} --to-revisions ${previousRevision}=100`
);
