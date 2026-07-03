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

const candidateAddresses = String(process.env.CANDIDATE_ADDRESSES || '')
  .split(',')
  .map((value) => value.trim())
  .filter(Boolean);

function gcloud(args) {
  return execFileSync(GCLOUD, args, {
    encoding: 'utf8',
    env: { ...process.env, CLOUDSDK_PYTHON },
    stdio: ['ignore', 'pipe', 'pipe'],
  });
}

function shortRef(prefix, value, length = 10) {
  return crypto
    .createHash('sha256')
    .update(`${prefix}:${value || ''}`)
    .digest('hex')
    .slice(0, length);
}

function parseDate(value) {
  const date = value ? new Date(value) : null;
  return date && !Number.isNaN(date.getTime()) ? date : null;
}

function ageMinutes(value) {
  const date = parseDate(value);
  if (!date) return null;
  return Math.round((Date.now() - date.getTime()) / 60000);
}

function isWatchPublicKey(value) {
  return /^(xpub|ypub|zpub|tpub|upub|vpub)/i.test(String(value || '').trim());
}

function normalizeStatus(value) {
  return String(value || '').trim().toLowerCase();
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

  if (!supabaseUrl || !serviceKey) {
    throw new Error('Could not load Supabase credentials from decoy-watcher.');
  }

  return { supabaseUrl, serviceKey };
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

async function fetchOptionalAll(creds, table, select) {
  try {
    return { available: true, rows: await fetchAll(creds, table, select) };
  } catch (error) {
    const message = String(error && error.message ? error.message : error).toLowerCase();
    if (
      message.includes('could not find the table') ||
      message.includes('relation') ||
      message.includes('does not exist') ||
      message.includes('404')
    ) {
      return { available: false, rows: [], error: error.message || String(error) };
    }
    throw error;
  }
}

function candidateMatches(seeds) {
  return candidateAddresses.map((address, candidateIndex) => {
    const exactMatches = [];
    const fuzzyMatches = [];

    for (const seed of seeds) {
      const addresses = Array.isArray(seed.addresses) ? seed.addresses : [];
      const exactIndex = addresses.indexOf(address);
      if (exactIndex >= 0) {
        exactMatches.push({
          userRef: shortRef('user', seed.user_id),
          decoyRef: shortRef('decoy', seed.decoy_id),
          index: exactIndex,
        });
      }

      for (let i = 0; i < addresses.length; i += 1) {
        const stored = addresses[i];
        if (!stored) continue;
        const prefixLength = Math.min(12, stored.length, address.length);
        const suffixLength = Math.min(8, stored.length, address.length);
        const prefixMatch = stored.slice(0, prefixLength) === address.slice(0, prefixLength);
        const suffixMatch = stored.slice(-suffixLength) === address.slice(-suffixLength);
        if (prefixMatch || suffixMatch) {
          fuzzyMatches.push({
            userRef: shortRef('user', seed.user_id),
            decoyRef: shortRef('decoy', seed.decoy_id),
            index: i,
            prefixMatch,
            suffixMatch,
          });
        }
      }
    }

    return {
      candidateIndex,
      candidateRef: shortRef('address', address, 12),
      addressLength: address.length,
      exactMatchCount: exactMatches.length,
      exactMatches,
      fuzzyMatchCount: fuzzyMatches.length,
      fuzzyMatches: fuzzyMatches.slice(0, 5),
    };
  });
}

const creds = loadWatcherEnv();
const [seeds, decoys, wallets, consents, baselines, scanStates, triggers, smsQueue] = await Promise.all([
  fetchAll(creds, 'armed_decoy_seeds', 'user_id,decoy_id,addresses'),
  fetchAll(creds, 'decoys', 'id,xpub,zpub,watch_public_key,watch_public_key_type,created_at'),
  fetchAll(
    creds,
    'decoy_wallet',
    'user_id,decoy_seed_armed,decoy_seed_armed_at,decoy_seed_decoy_id,decoy_seed_contacts_enabled,decoy_seed_last_triggered_at'
  ),
  fetchAll(creds, 'emergency_contact_consents', 'user_id,status,confirmed_at,opted_out_at'),
  fetchAll(creds, 'decoy_seed_baselines', 'decoy_id,baselined_at'),
  fetchAll(creds, 'decoy_seed_scan_state', 'decoy_id,last_index,updated_at'),
  fetchAll(creds, 'decoy_triggers', 'decoy_id,user_id,trigger_type,observed_at,txid_hmac'),
  fetchAll(creds, 'sms_queue', 'user_id,created_at,processed'),
]);
const utxoState = await fetchOptionalAll(
  creds,
  'decoy_seed_utxo_state',
  'decoy_id,outpoint_hmac,first_seen_at,last_seen_at,spent_at,trigger_recorded_at'
);

const decoyById = new Map(decoys.map((row) => [row.id, row]));
const walletByUser = new Map(wallets.map((row) => [row.user_id, row]));
const baselineByDecoy = new Map(baselines.map((row) => [row.decoy_id, row]));
const scanByDecoy = new Map(scanStates.map((row) => [row.decoy_id, row]));
const confirmedContactsByUser = new Map();
const openUtxoStateByDecoy = new Map();

for (const row of utxoState.rows || []) {
  if (row.spent_at) continue;
  openUtxoStateByDecoy.set(row.decoy_id, (openUtxoStateByDecoy.get(row.decoy_id) || 0) + 1);
}

for (const consent of consents) {
  if (normalizeStatus(consent.status) !== 'confirmed') continue;
  confirmedContactsByUser.set(consent.user_id, (confirmedContactsByUser.get(consent.user_id) || 0) + 1);
}

const perSeed = seeds.map((seed) => {
  const wallet = walletByUser.get(seed.user_id) || {};
  const decoy = decoyById.get(seed.decoy_id) || {};
  const baseline = baselineByDecoy.get(seed.decoy_id) || {};
  const scan = scanByDecoy.get(seed.decoy_id) || {};
  const addressCount = Array.isArray(seed.addresses) ? seed.addresses.filter(Boolean).length : 0;
  const watchPublicKey = decoy.watch_public_key || decoy.zpub || decoy.xpub || '';
  const hasWatchPublicKey = isWatchPublicKey(watchPublicKey);
  const openUtxoStateCount = openUtxoStateByDecoy.get(seed.decoy_id) || 0;
  const armed = wallet.decoy_seed_armed === true;
  const contactsEnabled = wallet.decoy_seed_contacts_enabled === true;
  const confirmedContactCount = confirmedContactsByUser.get(seed.user_id) || 0;
  const canSendSmsIfTriggerCreated = armed && contactsEnabled && confirmedContactCount > 0;
  const canTriggerAnyDerivedSpend = canSendSmsIfTriggerCreated && hasWatchPublicKey;
  const canTriggerStoredAddressSpend = canSendSmsIfTriggerCreated && addressCount > 0;
  const blockers = [];

  if (!armed) blockers.push('not_armed');
  if (!contactsEnabled) blockers.push('seed_contacts_disabled');
  if (confirmedContactCount === 0) blockers.push('no_confirmed_contacts');
  if (addressCount === 0) blockers.push('no_stored_addresses');
  if (!hasWatchPublicKey) blockers.push('missing_public_watch_key_limited_to_stored_addresses');

  return {
    userRef: shortRef('user', seed.user_id),
    decoyRef: shortRef('decoy', seed.decoy_id),
    addressCount,
    armed,
    hasArmedAt: !!wallet.decoy_seed_armed_at,
    contactsEnabled,
    confirmedContactCount,
    hasWatchPublicKey,
    watchPublicKeyType: decoy.watch_public_key_type || null,
    openUtxoStateCount,
    hasOpenUtxoState: openUtxoStateCount > 0,
    canSendSmsIfTriggerCreated,
    canTriggerStoredAddressSpend,
    canTriggerAnyDerivedSpend,
    requiresRegeneratedSeedForFullCoverage: canSendSmsIfTriggerCreated && !hasWatchPublicKey,
    blockers,
    baselineAgeMinutes: ageMinutes(baseline.baselined_at),
    scanAgeMinutes: ageMinutes(scan.updated_at),
    scanLastIndex: typeof scan.last_index === 'number' ? scan.last_index : null,
  };
});

const seedTriggers = triggers.filter((row) => row.trigger_type === 'SEED_DECOY');
const unprocessedSms = smsQueue.filter((row) => row.processed !== true);

const output = {
  checkedAt: new Date().toISOString(),
  summary: {
    activeSeedRows: seeds.length,
    armedSeedRows: perSeed.filter((row) => row.armed).length,
    rowsWithConfirmedContacts: perSeed.filter((row) => row.confirmedContactCount > 0).length,
    rowsWithPublicWatchKey: perSeed.filter((row) => row.hasWatchPublicKey).length,
    rowsWithOpenUtxoState: perSeed.filter((row) => row.hasOpenUtxoState).length,
    rowsAddressOnly: perSeed.filter((row) => !row.hasWatchPublicKey).length,
    rowsAbleToSendSmsIfTriggerCreated: perSeed.filter((row) => row.canSendSmsIfTriggerCreated).length,
    rowsAbleToTriggerStoredAddressSpend: perSeed.filter((row) => row.canTriggerStoredAddressSpend).length,
    rowsAbleToTriggerAnyDerivedSpend: perSeed.filter((row) => row.canTriggerAnyDerivedSpend).length,
    rowsNeedingRegeneratedSeedForFullCoverage: perSeed.filter((row) => row.requiresRegeneratedSeedForFullCoverage)
      .length,
    seedTriggersRecorded: seedTriggers.length,
    unprocessedSmsRows: unprocessedSms.length,
    utxoStateTableAvailable: utxoState.available,
    openUtxoStateRows: (utxoState.rows || []).filter((row) => !row.spent_at).length,
  },
  perSeed,
  candidateAddressMatches: candidateAddresses.length ? candidateMatches(seeds) : [],
};

console.log(JSON.stringify(output, null, 2));
