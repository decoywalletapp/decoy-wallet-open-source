#!/usr/bin/env node

import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';

const GCLOUD =
  '/Users/mitchellwleblanc/Documents/Codex/2026-04-26/i-need-help-connecting-my-entire/tools/google-cloud-sdk/bin/gcloud';
const PROJECT = 'decoywallet-a283b';
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

function gcloudJson(args) {
  const raw = gcloud([...args, '--format=json']);
  return raw.trim() ? JSON.parse(raw) : null;
}

function applyLogMetric({ name, description, filter }) {
  const commonArgs = [
    name,
    '--project',
    PROJECT,
    '--description',
    description,
    '--log-filter',
    filter,
  ];

  try {
    gcloud(['logging', 'metrics', 'describe', name, '--project', PROJECT]);
    gcloud(['logging', 'metrics', 'update', ...commonArgs]);
    return { name, action: 'updated' };
  } catch {
    gcloud(['logging', 'metrics', 'create', ...commonArgs]);
    return { name, action: 'created' };
  }
}

function findPolicyByDisplayName(displayName) {
  const policies = gcloudJson([
    'monitoring',
    'policies',
    'list',
    '--project',
    PROJECT,
    '--filter',
    `displayName="${displayName}"`,
  ]);

  return Array.isArray(policies) ? policies.find((policy) => policy.displayName === displayName) : null;
}

function applyPolicy(policyPath) {
  const policy = JSON.parse(readFileSync(policyPath, 'utf8'));
  const existing = findPolicyByDisplayName(policy.displayName);

  if (existing && existing.name) {
    gcloud([
      'monitoring',
      'policies',
      'update',
      existing.name,
      '--project',
      PROJECT,
      '--policy-from-file',
      policyPath,
    ]);
    return { displayName: policy.displayName, action: 'updated', name: existing.name };
  }

  const created = gcloudJson([
    'monitoring',
    'policies',
    'create',
    '--project',
    PROJECT,
    '--policy-from-file',
    policyPath,
  ]);

  return { displayName: policy.displayName, action: 'created', name: created?.name || null };
}

const metrics = [
  applyLogMetric({
    name: 'decoy_quicknode_reserve_used',
    description: 'Decoy watcher used QuickNode reserve/fallback provider',
    filter:
      'resource.type="cloud_run_revision" AND resource.labels.service_name="decoy-watcher" AND textPayload:"WATCHER_QUICKNODE_RESERVE_USED"',
  }),
  applyLogMetric({
    name: 'decoy_quicknode_rate_limit',
    description: 'Decoy watcher hit a QuickNode rate limit',
    filter:
      'resource.type="cloud_run_revision" AND resource.labels.service_name="decoy-watcher" AND textPayload:"WATCHER_QUICKNODE_RATE_LIMIT"',
  }),
  applyLogMetric({
    name: 'decoy_watch_key_capacity',
    description: 'Decoy watcher reached a watch-key capacity threshold',
    filter:
      'resource.type="cloud_run_revision" AND resource.labels.service_name="decoy-watcher" AND (textPayload:"WATCHER_WATCH_KEY_CAPACITY_WARN" OR textPayload:"WATCHER_WATCH_KEY_CAPACITY_URGENT" OR textPayload:"WATCHER_WATCH_KEY_CAPACITY_EXHAUSTED")',
  }),
  applyLogMetric({
    name: 'decoy_stale_seed_checks',
    description: 'Decoy watcher found armed seed records that were not checked within the stale window',
    filter:
      'resource.type="cloud_run_revision" AND resource.labels.service_name="decoy-watcher" AND textPayload:"WATCHER_STALE_SEED_CHECKS"',
  }),
];

const policies = [
  applyPolicy('codex_backend_work/decoy_quicknode_reserve_usage_policy.json'),
  applyPolicy('codex_backend_work/decoy_quicknode_rate_limit_policy.json'),
  applyPolicy('codex_backend_work/decoy_watch_key_capacity_policy.json'),
  applyPolicy('codex_backend_work/decoy_stale_seed_checks_policy.json'),
];

console.log(JSON.stringify({ ok: true, metrics, policies }, null, 2));
