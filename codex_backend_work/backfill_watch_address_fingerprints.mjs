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
const FINGERPRINT_VERSION = 'watch-address-v1';
const APPLY = process.env.APPLY_WATCH_ADDRESS_FINGERPRINT_BACKFILL === '1';

function gcloud(args) {
  return execFileSync(GCLOUD, args, {
    encoding: 'utf8',
    env: { ...process.env, CLOUDSDK_PYTHON },
    stdio: ['ignore', 'pipe', 'pipe'],
  });
}

function loadWatcherEnv() {
  const service = JSON.parse(
    gcloud([
      'run',
      'services',
      'describe',
      WATCHER_SERVICE,
      '--project',
      PROJECT,
      '--region',
      REGION,
      '--format=json',
    ])
  );

  const envList = service?.spec?.template?.spec?.containers?.[0]?.env || [];
  const env = new Map(envList.map((item) => [item.name, item.value || '']));
  const supabaseUrl = (env.get('ENV_SUPABASE_URL') || '').replace(/\/+$/, '');
  const serviceKey = env.get('ENV_SUPABASE_SERVICE_ROLE_KEY') || '';
  const hmacKey = env.get('WATCH_ADDRESS_HMAC_KEY') || env.get('DECOY_WATCH_ADDRESS_HMAC_KEY') || '';

  if (!supabaseUrl || !serviceKey) {
    throw new Error('Could not load Supabase credentials from decoy-watcher.');
  }
  if (!hmacKey) {
    throw new Error('WATCH_ADDRESS_HMAC_KEY is not configured on decoy-watcher.');
  }

  return { supabaseUrl, serviceKey, hmacKey };
}

async function fetchAll({ supabaseUrl, serviceKey }, table, select) {
  const rows = [];
  const pageSize = 1000;
  let offset = 0;

  for (;;) {
    const params = new URLSearchParams({
      select,
      limit: String(pageSize),
      offset: String(offset),
    });
    const res = await fetch(`${supabaseUrl}/rest/v1/${table}?${params}`, {
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
      },
    });
    const text = await res.text();
    if (!res.ok) throw new Error(`${table} query failed ${res.status}: ${text}`);
    const page = JSON.parse(text);
    rows.push(...page);
    if (page.length < pageSize) break;
    offset += pageSize;
  }

  return rows;
}

function normalizeWatchAddress(value) {
  const clean = String(value || '').trim();
  if (/^(bc1|tb1|bcrt1)/i.test(clean)) return clean.toLowerCase();
  return clean;
}

function hmacWatchAddress(address, key) {
  return crypto
    .createHmac('sha256', key)
    .update(`${FINGERPRINT_VERSION}:${normalizeWatchAddress(address)}`)
    .digest('hex');
}

async function upsertRows({ supabaseUrl, serviceKey }, rows) {
  if (!rows.length) return;

  const params = new URLSearchParams({
    on_conflict: 'decoy_id,address_hmac',
  });
  const res = await fetch(`${supabaseUrl}/rest/v1/decoy_watch_address_fingerprints?${params}`, {
    method: 'POST',
    headers: {
      apikey: serviceKey,
      Authorization: `Bearer ${serviceKey}`,
      'Content-Type': 'application/json',
      Prefer: 'resolution=merge-duplicates,return=minimal',
    },
    body: JSON.stringify(rows),
  });

  const text = await res.text();
  if (!res.ok) throw new Error(`fingerprint upsert failed ${res.status}: ${text}`);
}

const creds = loadWatcherEnv();
const armedSeeds = await fetchAll(creds, 'armed_decoy_seeds', 'decoy_id,user_id,addresses');
const rows = [];
const seen = new Set();

for (const seed of armedSeeds) {
  const decoyId = seed && seed.decoy_id;
  const addresses = Array.isArray(seed && seed.addresses) ? seed.addresses : [];
  if (!decoyId || !addresses.length) continue;

  for (let i = 0; i < addresses.length; i += 1) {
    const address = normalizeWatchAddress(addresses[i]);
    if (!address) continue;

    const addressHmac = hmacWatchAddress(address, creds.hmacKey);
    const rowKey = `${decoyId}:${addressHmac}`;
    if (seen.has(rowKey)) continue;
    seen.add(rowKey);

    rows.push({
      decoy_id: decoyId,
      address_hmac: addressHmac,
      fingerprint_version: FINGERPRINT_VERSION,
      source_type: 'backfill-armed-seed',
      address_index: i,
    });
  }
}

if (APPLY) {
  const chunkSize = 500;
  for (let i = 0; i < rows.length; i += chunkSize) {
    await upsertRows(creds, rows.slice(i, i + chunkSize));
  }
}

console.log(
  JSON.stringify(
    {
      ok: true,
      mode: APPLY ? 'apply' : 'dry-run',
      armedSeedRows: armedSeeds.length,
      fingerprintRowsPrepared: rows.length,
      uniqueDecoys: new Set(rows.map((row) => row.decoy_id)).size,
    },
    null,
    2
  )
);
