// index.js - decoy-sms-worker
// Sends ONE SMS per alert_id (dedupes duplicate sms_queue rows).
// Recipients come ONLY from encrypted emergency contacts stored in decoy_wallet.
// No fallback recipients. If contacts are missing or decrypt fails, it will log and do nothing.
//
// Patch:
// - Gate sends on Control Center toggles stored in decoy_wallet
// - No cooldown logic

import express from 'express';
import Twilio from 'twilio';
import { createClient } from '@supabase/supabase-js';
import crypto from 'crypto';

const PORT = process.env.PORT || 8080;

// --- Supabase setup ---
const SUPABASE_URL = process.env.ENV_SUPABASE_URL || process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY =
  process.env.ENV_SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error(
    '[sms-worker] Missing Supabase env vars. Expected ENV_SUPABASE_URL and ENV_SUPABASE_SERVICE_ROLE_KEY or SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY'
  );
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
  auth: { persistSession: false }
});

// --- Twilio setup ---
const TWILIO_ACCOUNT_SID = process.env.TWILIO_ACCOUNT_SID;
const TWILIO_AUTH_TOKEN = process.env.TWILIO_AUTH_TOKEN;
const TWILIO_FROM = process.env.TWILIO_FROM;

if (!TWILIO_ACCOUNT_SID || !TWILIO_AUTH_TOKEN || !TWILIO_FROM) {
  console.error(
    '[sms-worker] Missing Twilio env vars. Need TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_FROM'
  );
  process.exit(1);
}

const twilioClient = Twilio(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN);

const app = express();
app.use(express.json());

// ---------- Base64 + AES GCM helpers ----------

function decodeB64Any(s) {
  if (!s) return null;
  let norm = s.replace(/-/g, '+').replace(/_/g, '/');
  const pad = norm.length % 4;
  if (pad) norm += '='.repeat(4 - pad);
  return Buffer.from(norm, 'base64');
}

// IMPORTANT: wrapdatakey enforces allowed caller by email.
// Cloud Run metadata identity tokens need includeEmail=true so payload.email exists.
async function getCloudRunIdentityToken(audienceUrl) {
  try {
    const aud = (audienceUrl || '').replace(/\/+$/, '');
    if (!aud) return null;

    const mdUrl =
      'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity' +
      `?audience=${encodeURIComponent(aud)}&format=full&includeEmail=true`;

    const resp = await fetch(mdUrl, {
      headers: { 'Metadata-Flavor': 'Google' }
    });

    if (!resp.ok) {
      console.error('[sms-worker] failed to get metadata identity token', resp.status);
      return null;
    }

    return await resp.text();
  } catch (e) {
    console.error('[sms-worker] getCloudRunIdentityToken failed', e);
    return null;
  }
}

async function unwrapDataKey(wrappedDataKeyB64) {
  try {
    const WRAP_URL = (process.env.WRAPDATAKEY_URL || '').replace(/\/+$/, '');
    if (!WRAP_URL) {
      console.error('[sms-worker] WRAPDATAKEY_URL not set');
      return null;
    }

    const token = await getCloudRunIdentityToken(WRAP_URL);
    if (!token) return null;

    // wrapdatakey expects wrappedB64 for unwrap mode
    const resp = await fetch(`${WRAP_URL}/`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ wrappedB64: wrappedDataKeyB64 })
    });

    if (!resp.ok) {
      const t = await resp.text().catch(() => '');
      console.error('[sms-worker] wrapdatakey unwrap failed', resp.status, t);
      return null;
    }

    const j = await resp.json().catch(() => null);

    const rawKeyB64 =
      j?.dataKeyB64 ||
      j?.rawKeyB64 ||
      j?.raw_datakey ||
      j?.data_key ||
      j?.datakey ||
      j?.key;

    if (!rawKeyB64) {
      console.error('[sms-worker] wrapdatakey response missing dataKeyB64');
      return null;
    }

    return rawKeyB64;
  } catch (e) {
    console.error('[sms-worker] unwrapDataKey failed', e);
    return null;
  }
}

function decryptAesGcmJson(ciphertextB64, nonceB64, rawKeyB64) {
  const data = decodeB64Any(ciphertextB64);
  const nonce = decodeB64Any(nonceB64);
  const key = decodeB64Any(rawKeyB64);

  if (!data || !nonce || !key) return null;
  if (data.length < 17) return null;

  const ctLen = data.length - 16;
  const ct = data.subarray(0, ctLen);
  const tag = data.subarray(ctLen);

  const algo = key.length === 32 ? 'aes-256-gcm' : key.length === 16 ? 'aes-128-gcm' : null;
  if (!algo) {
    console.error('[sms-worker] Invalid key length for AES GCM:', key.length);
    return null;
  }

  const decipher = crypto.createDecipheriv(algo, key, nonce);
  decipher.setAuthTag(tag);

  const decrypted = Buffer.concat([decipher.update(ct), decipher.final()]);
  return JSON.parse(decrypted.toString('utf8'));
}

async function decryptContactsPayload(ciphertextB64, nonceB64, wrappedDataKeyB64) {
  try {
    if (!ciphertextB64 || !nonceB64 || !wrappedDataKeyB64) {
      console.warn('[sms-worker] decryptContactsPayload missing input');
      return null;
    }

    const rawKeyB64 = await unwrapDataKey(wrappedDataKeyB64);
    if (!rawKeyB64) return null;

    const obj = decryptAesGcmJson(ciphertextB64, nonceB64, rawKeyB64);
    if (!obj) return null;

    if (Array.isArray(obj.contacts)) {
      obj.contacts = obj.contacts.map((c) => ({
        first: (c?.first ?? '').toString(),
        last: (c?.last ?? '').toString(),
        phone: (c?.phone ?? '').toString()
      }));
    }

    return obj;
  } catch (err) {
    console.error('[sms-worker] decryptContactsPayload failed', err);
    return null;
  }
}

// NEW: decrypt personal payload to get first and last name
async function decryptPersonalPayload(ciphertextB64, nonceB64, wrappedDataKeyB64) {
  try {
    if (!ciphertextB64 || !nonceB64 || !wrappedDataKeyB64) {
      return null;
    }

    const rawKeyB64 = await unwrapDataKey(wrappedDataKeyB64);
    if (!rawKeyB64) return null;

    const obj = decryptAesGcmJson(ciphertextB64, nonceB64, rawKeyB64);
    if (!obj) return null;

    const firstName = (obj?.firstName ?? '').toString().trim();
    const lastName = (obj?.lastName ?? '').toString().trim();

    return { firstName, lastName };
  } catch (e) {
    console.error('[sms-worker] decryptPersonalPayload failed', e);
    return null;
  }
}

// ---------- DB helpers ----------

async function getUserAlertSettings(userId) {
  try {
    const { data, error } = await supabase
      .from('decoy_wallet')
      .select('decoy_pin_contacts_enabled, decoy_seed_contacts_enabled, decoy_seed_armed')
      .eq('user_id', userId)
      .limit(1);

    if (error) {
      console.warn('[sms-worker] error loading alert settings from decoy_wallet', error);
      return {
        decoy_pin_contacts_enabled: false,
        decoy_seed_contacts_enabled: false,
        decoy_seed_armed: false
      };
    }

    const row = data && data[0] ? data[0] : null;

    return {
      decoy_pin_contacts_enabled: !!row?.decoy_pin_contacts_enabled,
      decoy_seed_contacts_enabled: !!row?.decoy_seed_contacts_enabled,
      decoy_seed_armed: !!row?.decoy_seed_armed
    };
  } catch (e) {
    console.warn('[sms-worker] getUserAlertSettings failed', e);
    return {
      decoy_pin_contacts_enabled: false,
      decoy_seed_contacts_enabled: false,
      decoy_seed_armed: false
    };
  }
}

async function getDisplayNameForUser(userId) {
  try {
    // FIRST: try decrypting from decoy_wallet personal payload
    const { data: walletRows, error: walletErr } = await supabase
      .from('decoy_wallet')
      .select('personal_ciphertext, personal_nonce, wrapped_datakey')
      .eq('user_id', userId)
      .limit(1);

    if (walletErr) {
      console.warn('[sms-worker] error querying decoy_wallet for personal payload', walletErr);
    }

    let first = '';
    let last = '';

    if (walletRows && walletRows.length > 0) {
      const row = walletRows[0];
      const p = await decryptPersonalPayload(row.personal_ciphertext, row.personal_nonce, row.wrapped_datakey);
      if (p) {
        first = p.firstName || '';
        last = p.lastName || '';
      }
    }

    // SECOND: keep your existing seed fallback (unchanged in spirit)
    if (!first && !last) {
      let { data: armedRows, error: armedErr } = await supabase
        .from('armed_decoy_seeds')
        .select('first_name, last_name')
        .eq('user_id', userId)
        .limit(1);

      if (armedErr) {
        console.warn('[sms-worker] error querying armed_decoy_seeds for name', armedErr);
      }

      if (armedRows && armedRows.length > 0) {
        first = (armedRows[0].first_name || '').toString().trim() || first;
        last = (armedRows[0].last_name || '').toString().trim() || last;
      }
    }

    if (!first && !last) {
      return { fullName: 'Decoy User', firstName: 'User' };
    }

    const fullName = [first, last].filter(Boolean).join(' ');
    const firstName = first || fullName || 'User';

    return { fullName, firstName };
  } catch (err) {
    console.error('[sms-worker] getDisplayNameForUser failed', err);
    return { fullName: 'Decoy User', firstName: 'User' };
  }
}

async function getEmergencyPhonesForUser(userId) {
  try {
    const { data, error } = await supabase
      .from('decoy_wallet')
      .select('contacts_ciphertext, contacts_nonce, wrapped_datakey')
      .eq('user_id', userId)
      .limit(1);

    if (error) {
      console.error('[sms-worker] error loading contacts from decoy_wallet', error);
      return [];
    }

    if (!data || data.length === 0) {
      console.log('[sms-worker] no decoy_wallet row for user', userId);
      return [];
    }

    const row = data[0];

    if (!row.contacts_ciphertext || !row.contacts_nonce || !row.wrapped_datakey) {
      console.log('[sms-worker] contacts not set or missing key for user', userId);
      return [];
    }

    const payload = await decryptContactsPayload(
      row.contacts_ciphertext,
      row.contacts_nonce,
      row.wrapped_datakey
    );

    if (!payload || !Array.isArray(payload.contacts)) {
      console.log('[sms-worker] decrypted payload missing contacts list for user', userId);
      return [];
    }

    const phones = [];
    for (const c of payload.contacts) {
      if (!c) continue;
      const phone = (c.phone || '').toString().trim();
      if (phone) phones.push(phone);
    }

    const unique = [...new Set(phones)];
    console.log('[sms-worker] decrypted', unique.length, 'emergency phones for user', userId);
    return unique;
  } catch (err) {
    console.error('[sms-worker] getEmergencyPhonesForUser failed', err);
    return [];
  }
}

// ---------- Message builder ----------

function buildMessage(alert, displayName) {
  const tsIso = new Date(alert.created_at).toISOString();

  const full = (displayName.fullName || 'Decoy User').toUpperCase();
  const first = (displayName.firstName || 'User').toUpperCase();

  if (alert.trigger_type === 'PIN_DECOY') {
    const hasLocation =
      alert.lat !== null &&
      alert.lat !== undefined &&
      alert.lng !== null &&
      alert.lng !== undefined;

    let locationLine = `IF YOU BELIEVE ${first} MAY BE IN IMMEDIATE DANGER, CALL 911 NOW. LOCATION IS UNAVAILABLE IN THIS ALERT.`;
    let mapLine = 'MAP: Location unavailable';

    if (hasLocation) {
      const latText = Number(alert.lat).toFixed(6);
      const lngText = Number(alert.lng).toFixed(6);
      const mapLink = `https://maps.google.com/?q=${latText},${lngText}`;

      locationLine = `IF YOU BELIEVE ${first} MAY BE IN IMMEDIATE DANGER, CALL 911 NOW AND SHARE THIS LOCATION: ${latText}, ${lngText}`;
      mapLine = `MAP: ${mapLink}`;
    }

    const lines = [
      'DECOY WALLET ALERT:',
      '',
      `POTENTIAL DURESS OR ROBBERY ALERT FOR ${full}`,
      '',
      `*DO NOT CALL OR CONTACT ${first} DIRECTLY*`,
      '',
      locationLine,
      '',
      mapLine,
      '',
      'THIS IS AN AUTOMATED ALERT FROM DECOY WALLET.',
      '',
      'WHEN:',
      tsIso,
      '',
      'Reply STOP to opt out of Decoy Wallet text alerts.'
    ];

    return lines.join('\n');
  }

  if (alert.trigger_type === 'SEED_DECOY') {
    const lines = [
      'DECOY WALLET ALERT:',
      '',
      `POTENTIAL DURESS ALERT. WALLET ACTIVITY MAY INDICATE COERCION INVOLVING ${full}`,
      '',
      `*DO NOT CALL OR CONTACT ${first} DIRECTLY*`,
      '',
      `IF YOU BELIEVE ${first} MAY BE IN IMMEDIATE DANGER, CALL 911 NOW. OTHERWISE, CONTACT YOUR LOCAL POLICE NON EMERGENCY NUMBER.`,
      '',
      `TELL THEM YOU RECEIVED AN AUTOMATED SECURITY ALERT ABOUT ${full}.`,
      '',
      'WHEN:',
      tsIso,
      '',
      'Reply STOP to opt out of Decoy Wallet text alerts.'
    ];

    return lines.join('\n');
  }

  const lines = [
    'Decoy Wallet ALERT:',
    '',
    `Trigger: ${alert.trigger_type}`,
    `Time (UTC): ${tsIso.replace('T', ' ').replace('Z', ' UTC')}`,
    `User ID: ${alert.user_id}`,
    '',
    'Reply STOP to opt out of Decoy Wallet text alerts.'
  ];

  return lines.join('\n');
}

// ---------- Send gating ----------

async function shouldSendForAlert(alert) {
  const settings = await getUserAlertSettings(alert.user_id);

  if (alert.trigger_type === 'PIN_DECOY') {
    if (!settings.decoy_pin_contacts_enabled) {
      console.log(
        '[sms-worker] blocked PIN_DECOY send because decoy_pin_contacts_enabled is false for user',
        alert.user_id
      );
      return { ok: false, reason: 'pin_contacts_disabled' };
    }
    return { ok: true, reason: 'allowed' };
  }

  if (alert.trigger_type === 'SEED_DECOY') {
    if (!settings.decoy_seed_contacts_enabled || !settings.decoy_seed_armed) {
      console.log(
        '[sms-worker] blocked SEED_DECOY send because seed toggle is off or not armed for user',
        alert.user_id
      );
      return { ok: false, reason: 'seed_disabled_or_disarmed' };
    }
    return { ok: true, reason: 'allowed' };
  }

  return { ok: true, reason: 'allowed' };
}

// ---------- Core worker: process sms_queue ----------

async function processQueue() {
  console.log('[sms-worker] /run hit, checking sms_queue');

  const { data: queueRows, error } = await supabase
    .from('sms_queue')
    .select('*')
    .eq('processed', false)
    .order('created_at', { ascending: true })
    .limit(50);

  if (error) {
    console.error('[sms-worker] error querying sms_queue', error);
    return;
  }

  if (!queueRows || queueRows.length === 0) {
    console.log('[sms-worker] no pending sms_queue rows');
    return;
  }

  console.log('[sms-worker] found', queueRows.length, 'pending sms_queue rows');

  const alertIds = [...new Set(queueRows.map((q) => q.alert_id))];

  const { data: alerts, error: alertsError } = await supabase
    .from('alert_logs')
    .select('*')
    .in('id', alertIds);

  if (alertsError) {
    console.error('[sms-worker] error loading alert_logs', alertsError);
    return;
  }

  const alertsById = new Map();
  for (const a of alerts || []) alertsById.set(a.id, a);

  const canonicalByAlert = new Map();

  for (const row of queueRows) {
    const alert = alertsById.get(row.alert_id);

    if (!alert) {
      console.warn('[sms-worker] no alert_logs row for alert_id', row.alert_id);
      await supabase.from('sms_queue').update({ processed: true }).eq('id', row.id);
      continue;
    }

    if (canonicalByAlert.has(row.alert_id)) {
      console.log(
        '[sms-worker] duplicate sms_queue row for alert_id',
        row.alert_id,
        'queue_id',
        row.id,
        'marking processed without sending'
      );
      await supabase.from('sms_queue').update({ processed: true }).eq('id', row.id);
      continue;
    }

    canonicalByAlert.set(row.alert_id, { row, alert });
  }

  for (const { row, alert } of canonicalByAlert.values()) {
    const { data: claimed, error: claimErr } = await supabase
      .from('sms_queue')
      .update({ processed: true })
      .eq('id', row.id)
      .eq('processed', false)
      .select('id')
      .order('id', { ascending: true })
      .limit(1);

    if (claimErr) {
      console.error('[sms-worker] failed to claim sms_queue row', row.id, claimErr);
      continue;
    }

    if (!claimed || claimed.length === 0) {
      console.log('[sms-worker] sms_queue row already claimed by another run, skipping', row.id);
      continue;
    }

    const gate = await shouldSendForAlert(alert);
    if (!gate.ok) {
      console.log('[sms-worker] skipping send for alert_id', alert.id, 'reason', gate.reason);
      continue;
    }

    const recipients = await getEmergencyPhonesForUser(alert.user_id);
    if (!recipients.length) {
      console.warn('[sms-worker] no recipients for alert_id', alert.id, 'user_id', alert.user_id);
      continue;
    }

    const displayName = await getDisplayNameForUser(alert.user_id);
    const body = buildMessage(alert, displayName);

    for (const to of recipients) {
      try {
        console.log('[sms-worker] sending SMS for alert_id', alert.id, 'to', to);
        const resp = await twilioClient.messages.create({ to, from: TWILIO_FROM, body });
        console.log('[sms-worker] SMS sent for alert_id', alert.id, 'to', to, 'SID', resp.sid);
      } catch (err) {
        console.error('[sms-worker] error sending SMS for alert_id', alert.id, 'to', to, err);
      }
    }
  }
}

// ---------- HTTP endpoints ----------

app.post('/run', async (req, res) => {
  try {
    await processQueue();
    res.status(200).send('ok');
  } catch (err) {
    console.error('[sms-worker] error in /run', err);
    res.status(500).send('error');
  }
});

app.get('/', (req, res) => {
  res.status(200).send('decoy-sms-worker ok');
});

app.listen(PORT, () => {
  console.log('[sms-worker] listening on port', PORT);
});