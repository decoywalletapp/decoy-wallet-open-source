import { execFileSync } from 'node:child_process';
import crypto from 'node:crypto';

const gcloud =
  '/Users/mitchellwleblanc/Documents/Codex/2026-04-26/i-need-help-connecting-my-entire/tools/google-cloud-sdk/bin/gcloud';
const python =
  '/Users/mitchellwleblanc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3.12';

function loadCloudRunEnv() {
  const json = execFileSync(
    gcloud,
    [
      'run',
      'services',
      'describe',
      'decoy-watcher',
      '--project',
      'decoywallet-a283b',
      '--region',
      'us-central1',
      '--format=json',
    ],
    {
      encoding: 'utf8',
      env: { ...process.env, CLOUDSDK_PYTHON: python },
      stdio: ['ignore', 'pipe', 'pipe'],
    }
  );

  const service = JSON.parse(json);
  const env =
    service?.spec?.template?.spec?.containers?.[0]?.env ||
    service?.template?.spec?.containers?.[0]?.env ||
    [];
  const map = new Map(env.map((entry) => [entry.name, entry.value]));
  const supabaseUrl = map.get('ENV_SUPABASE_URL');
  const serviceKey = map.get('ENV_SUPABASE_SERVICE_ROLE_KEY');
  if (!supabaseUrl || !serviceKey) {
    throw new Error('Could not load Supabase env from decoy-watcher Cloud Run service.');
  }
  return { supabaseUrl: supabaseUrl.replace(/\/+$/, ''), serviceKey };
}

async function fetchAll({ supabaseUrl, serviceKey }, table, select, extra = {}) {
  const pageSize = 1000;
  let offset = 0;
  const rows = [];

  for (;;) {
    const params = new URLSearchParams({ select, limit: String(pageSize), offset: String(offset), ...extra });
    const res = await fetch(`${supabaseUrl}/rest/v1/${table}?${params}`, {
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
      },
    });
    const body = await res.text();
    if (!res.ok) {
      throw new Error(`${table} query failed ${res.status}: ${body}`);
    }

    const page = JSON.parse(body);
    rows.push(...page);
    if (page.length < pageSize) break;
    offset += pageSize;
  }

  return rows;
}

function parseDate(value) {
  const date = value ? new Date(value) : null;
  return date && !Number.isNaN(date.getTime()) ? date : null;
}

function maxIso(rows, field) {
  let max = null;
  for (const row of rows) {
    const d = parseDate(row[field]);
    if (d && (!max || d > max)) max = d;
  }
  return max ? max.toISOString() : null;
}

function minIso(rows, field) {
  let min = null;
  for (const row of rows) {
    const d = parseDate(row[field]);
    if (d && (!min || d < min)) min = d;
  }
  return min ? min.toISOString() : null;
}

function ageMinutes(iso) {
  if (!iso) return null;
  return Math.round((Date.now() - new Date(iso).getTime()) / 60000);
}

function addressCount(addresses) {
  return Array.isArray(addresses) ? addresses.filter(Boolean).length : 0;
}

function countBy(rows, keyFn) {
  const out = {};
  for (const row of rows) {
    const key = keyFn(row);
    out[key] = (out[key] || 0) + 1;
  }
  return out;
}

function ref(value) {
  return crypto.createHash('sha256').update(`decoy-audit:${value || ''}`).digest('hex').slice(0, 10);
}

const creds = loadCloudRunEnv();

const [seeds, wallets, baselines, scanStates, triggers, alerts, smsQueue, consents, seenTxs] = await Promise.all([
  fetchAll(creds, 'armed_decoy_seeds', 'user_id,decoy_id,addresses'),
  fetchAll(
    creds,
    'decoy_wallet',
    'user_id,decoy_seed_armed,decoy_seed_armed_at,decoy_seed_decoy_id,decoy_seed_contacts_enabled,decoy_seed_last_triggered_at'
  ),
  fetchAll(creds, 'decoy_seed_baselines', 'decoy_id,baselined_at'),
  fetchAll(creds, 'decoy_seed_scan_state', 'decoy_id,last_index,updated_at'),
  fetchAll(creds, 'decoy_triggers', 'decoy_id,user_id,trigger_type,observed_at,txid_hmac'),
  fetchAll(creds, 'alert_logs', 'user_id,trigger_type,success,error_message,created_at,txid_hmac'),
  fetchAll(creds, 'sms_queue', 'user_id,alert_id,created_at,processed'),
  fetchAll(creds, 'emergency_contact_consents', 'user_id,status,confirmed_at,denied_at,opted_out_at'),
  fetchAll(creds, 'decoy_seen_txs', 'decoy_id,first_seen_at,txid_hmac'),
]);

const seedUsers = new Set(seeds.map((s) => s.user_id).filter(Boolean));
const seedDecoys = new Set(seeds.map((s) => s.decoy_id).filter(Boolean));
const walletByUser = new Map(wallets.map((w) => [w.user_id, w]));
const baselineByDecoy = new Map(baselines.map((b) => [b.decoy_id, b]));
const scanByDecoy = new Map(scanStates.map((s) => [s.decoy_id, s]));

const seedRowsWithNoAddresses = seeds.filter((s) => addressCount(s.addresses) === 0).length;
const seedAddressCounts = seeds.map((s) => addressCount(s.addresses));
const totalWatchedAddresses = seedAddressCounts.reduce((sum, n) => sum + n, 0);
const maxAddressesPerSeed = seedAddressCounts.length ? Math.max(...seedAddressCounts) : 0;
const avgAddressesPerSeed = seedAddressCounts.length
  ? Number((totalWatchedAddresses / seedAddressCounts.length).toFixed(2))
  : 0;

const activeSeedWallets = [...seedUsers].map((userId) => walletByUser.get(userId)).filter(Boolean);
const missingWalletForSeedUser = [...seedUsers].filter((userId) => !walletByUser.has(userId)).length;
const armedSeedUsers = activeSeedWallets.filter((w) => w.decoy_seed_armed === true);
const armedSeedUsersWithArmedAt = armedSeedUsers.filter((w) => !!w.decoy_seed_armed_at);
const armedSeedUsersMissingArmedAt = armedSeedUsers.filter((w) => !w.decoy_seed_armed_at).length;
const seedUsersNotArmed = activeSeedWallets.filter((w) => w.decoy_seed_armed !== true).length;
const contactsEnabledForArmedSeedUsers = armedSeedUsers.filter((w) => w.decoy_seed_contacts_enabled === true).length;

const baselineMissingForSeedDecoy = [...seedDecoys].filter((decoyId) => !baselineByDecoy.has(decoyId)).length;
const scanMissingForSeedDecoy = [...seedDecoys].filter((decoyId) => !scanByDecoy.has(decoyId)).length;

const latestScanUpdatedAt = maxIso(scanStates, 'updated_at');
const oldestScanUpdatedAt = minIso(scanStates, 'updated_at');
const latestBaselineAt = maxIso(baselines, 'baselined_at');
const latestSeenTxAt = maxIso(seenTxs, 'first_seen_at');

const seedTriggers = triggers.filter((t) => t.trigger_type === 'SEED_DECOY');
const pinTriggers = triggers.filter((t) => t.trigger_type === 'PIN_DECOY');
const seedAlerts = alerts.filter((a) => a.trigger_type === 'SEED_DECOY');
const pinAlerts = alerts.filter((a) => a.trigger_type === 'PIN_DECOY');
const recentCutoff = Date.now() - 24 * 60 * 60 * 1000;
const last24h = (rows, field) => rows.filter((r) => {
  const d = parseDate(r[field]);
  return d && d.getTime() >= recentCutoff;
});

const confirmedConsentUsers = new Set(
  consents.filter((c) => String(c.status || '').toLowerCase() === 'confirmed').map((c) => c.user_id)
);
const armedSeedUsersWithConfirmedContact = armedSeedUsers.filter((w) => confirmedConsentUsers.has(w.user_id)).length;
const confirmedContactCountByUser = new Map();
for (const consent of consents) {
  if (String(consent.status || '').toLowerCase() !== 'confirmed') continue;
  confirmedContactCountByUser.set(consent.user_id, (confirmedContactCountByUser.get(consent.user_id) || 0) + 1);
}

const perSeedHealth = seeds.map((seed) => {
  const wallet = walletByUser.get(seed.user_id);
  const baseline = baselineByDecoy.get(seed.decoy_id);
  const scan = scanByDecoy.get(seed.decoy_id);
  return {
    userRef: ref(seed.user_id),
    decoyRef: ref(seed.decoy_id),
    addressCount: addressCount(seed.addresses),
    armed: wallet?.decoy_seed_armed === true,
    hasArmedAt: !!wallet?.decoy_seed_armed_at,
    contactsEnabled: wallet?.decoy_seed_contacts_enabled === true,
    confirmedContactCount: confirmedContactCountByUser.get(seed.user_id) || 0,
    hasBaseline: !!baseline,
    baselineAgeMinutes: ageMinutes(baseline?.baselined_at || null),
    hasScanState: !!scan,
    scanAgeMinutes: ageMinutes(scan?.updated_at || null),
    scanLastIndex: typeof scan?.last_index === 'number' ? scan.last_index : null,
  };
});

const output = {
  checkedAt: new Date().toISOString(),
  decoySeedRegistration: {
    armedDecoySeedRows: seeds.length,
    uniqueSeedUsers: seedUsers.size,
    uniqueSeedDecoys: seedDecoys.size,
    totalWatchedAddresses,
    avgAddressesPerSeed,
    maxAddressesPerSeed,
    seedRowsWithNoAddresses,
    missingWalletForSeedUser,
  },
  armingGate: {
    seedUsersWithWalletRows: activeSeedWallets.length,
    seedUsersNotArmed,
    armedSeedUsers: armedSeedUsers.length,
    armedSeedUsersWithArmedAt: armedSeedUsersWithArmedAt.length,
    armedSeedUsersMissingArmedAt,
    contactsEnabledForArmedSeedUsers,
    armedSeedUsersWithConfirmedContact,
  },
  watcherState: {
    baselineRows: baselines.length,
    baselineMissingForSeedDecoy,
    latestBaselineAt,
    scanStateRows: scanStates.length,
    scanMissingForSeedDecoy,
    latestScanUpdatedAt,
    latestScanAgeMinutes: ageMinutes(latestScanUpdatedAt),
    oldestScanUpdatedAt,
    oldestScanAgeMinutes: ageMinutes(oldestScanUpdatedAt),
    seenTxRows: seenTxs.length,
    latestSeenTxAt,
  },
  triggerAndAlertPipeline: {
    totalTriggers: triggers.length,
    triggerTypes: countBy(triggers, (t) => t.trigger_type || 'null'),
    seedTriggers: seedTriggers.length,
    pinTriggers: pinTriggers.length,
    seedTriggersLast24h: last24h(seedTriggers, 'observed_at').length,
    pinTriggersLast24h: last24h(pinTriggers, 'observed_at').length,
    totalAlertLogs: alerts.length,
    alertTypes: countBy(alerts, (a) => a.trigger_type || 'null'),
    seedAlerts: seedAlerts.length,
    pinAlerts: pinAlerts.length,
    seedAlertsLast24h: last24h(seedAlerts, 'created_at').length,
    pinAlertsLast24h: last24h(pinAlerts, 'created_at').length,
    alertSuccessCounts: countBy(alerts, (a) => String(a.success)),
    smsQueueRows: smsQueue.length,
    smsProcessedCounts: countBy(smsQueue, (s) => String(s.processed)),
    smsQueuedLast24h: last24h(smsQueue, 'created_at').length,
    unprocessedSmsRows: smsQueue.filter((s) => s.processed !== true).length,
  },
  contactConsent: {
    consentRows: consents.length,
    statuses: countBy(consents, (c) => String(c.status || 'null').toLowerCase()),
    usersWithAtLeastOneConfirmedContact: confirmedConsentUsers.size,
  },
  perSeedHealth,
};

console.log(JSON.stringify(output, null, 2));
