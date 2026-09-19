#!/usr/bin/env node

import crypto from 'node:crypto';
import fs from 'node:fs';

const paymentServicePath = process.env.PAYMENT_SERVICE_JSON;
const alertServicePath = process.env.ALERT_SERVICE_JSON;
const alertCanaryUrl = String(process.env.ALERT_CANARY_URL ?? '').replace(
  /\/+$/,
  '',
);
const entitlementKind = process.env.ENTITLEMENT_KIND ?? 'promotional';
if (!['paid', 'promotional'].includes(entitlementKind)) {
  throw new Error('ENTITLEMENT_KIND must be paid or promotional');
}
if (!paymentServicePath || !alertServicePath || !alertCanaryUrl) {
  throw new Error('Missing alert canary smoke configuration');
}

function serviceEnv(path) {
  const service = JSON.parse(fs.readFileSync(path, 'utf8'));
  return Object.fromEntries(
    (service.spec?.template?.spec?.containers?.[0]?.env ?? [])
      .filter((entry) => typeof entry.value === 'string')
      .map((entry) => [entry.name, entry.value]),
  );
}

async function jsonFetch(url, options = {}) {
  const response = await fetch(url, options);
  const text = await response.text();
  let body;
  try {
    body = text ? JSON.parse(text) : null;
  } catch {
    body = { raw: text };
  }
  return { response, body };
}

const paymentEnv = serviceEnv(paymentServicePath);
const alertEnv = serviceEnv(alertServicePath);
const supabaseUrl = String(paymentEnv.SUPABASE_URL ?? '').replace(/\/+$/, '');
const serviceKey = paymentEnv.SUPABASE_SERVICE_ROLE_KEY;
const anonKey = alertEnv.SUPABASE_ANON_KEY;
if (!supabaseUrl || !serviceKey || !anonKey) {
  throw new Error('Production services are missing required Supabase settings');
}

const adminHeaders = {
  apikey: serviceKey,
  authorization: `Bearer ${serviceKey}`,
  'content-type': 'application/json',
};
const nonce = crypto.randomBytes(12).toString('hex');
const email = `decoy-alert-canary-${nonce}@example.invalid`;
const password = `${crypto.randomBytes(24).toString('base64url')}Aa1!`;
let userId;
let alertId;

try {
  const created = await jsonFetch(`${supabaseUrl}/auth/v1/admin/users`, {
    method: 'POST',
    headers: adminHeaders,
    body: JSON.stringify({ email, password, email_confirm: true }),
  });
  if (!created.response.ok || !created.body?.id) {
    throw new Error(`Temporary user creation failed (${created.response.status})`);
  }
  userId = created.body.id;

  const entitlement = await jsonFetch(`${supabaseUrl}/rest/v1/user_entitlements`, {
    method: 'POST',
    headers: {
      ...adminHeaders,
      prefer: 'resolution=merge-duplicates,return=minimal',
    },
    body: JSON.stringify({
      user_id: userId,
      entitlement: 'decoy_wallet',
      is_active: entitlementKind === 'paid',
      ...(entitlementKind === 'paid'
        ? {
            current_period_end: new Date(
              Date.now() + 24 * 60 * 60 * 1000,
            ).toISOString(),
          }
        : {
            promotional_access_until: new Date(
              Date.now() + 24 * 60 * 60 * 1000,
            ).toISOString(),
          }),
    }),
  });
  if (!entitlement.response.ok) {
    throw new Error(`Temporary entitlement failed (${entitlement.response.status})`);
  }

  const signedIn = await jsonFetch(
    `${supabaseUrl}/auth/v1/token?grant_type=password`,
    {
      method: 'POST',
      headers: { apikey: anonKey, 'content-type': 'application/json' },
      body: JSON.stringify({ email, password }),
    },
  );
  const jwt = signedIn.body?.access_token;
  if (!signedIn.response.ok || !jwt) {
    throw new Error(`Temporary user sign-in failed (${signedIn.response.status})`);
  }

  const alert = await jsonFetch(`${alertCanaryUrl}/sendEmergencyAlerts`, {
    method: 'POST',
    headers: {
      authorization: `Bearer ${jwt}`,
      'content-type': 'application/json',
    },
    body: JSON.stringify({ triggerType: 'SEED_DECOY' }),
  });
  if (!alert.response.ok || alert.body?.ok !== true || !alert.body?.alertId) {
    throw new Error(`Promotional alert failed (${alert.response.status})`);
  }
  alertId = alert.body.alertId;

  const queue = await jsonFetch(
    `${supabaseUrl}/rest/v1/sms_queue?alert_id=eq.${encodeURIComponent(alertId)}&select=alert_id`,
    { headers: adminHeaders },
  );
  if (!queue.response.ok || queue.body?.length !== 1) {
    throw new Error('Promotional alert was not queued exactly once');
  }

  process.stdout.write(
    `${JSON.stringify({
      entitlementKind,
      alertAccepted: true,
      queuedExactlyOnce: true,
    })}\n`,
  );
} finally {
  if (alertId) {
    await fetch(
      `${supabaseUrl}/rest/v1/sms_queue?alert_id=eq.${encodeURIComponent(alertId)}`,
      { method: 'DELETE', headers: adminHeaders },
    );
    await fetch(
      `${supabaseUrl}/rest/v1/alert_logs?id=eq.${encodeURIComponent(alertId)}`,
      { method: 'DELETE', headers: adminHeaders },
    );
  }
  if (userId) {
    await fetch(
      `${supabaseUrl}/rest/v1/user_entitlements?user_id=eq.${encodeURIComponent(userId)}&entitlement=eq.decoy_wallet`,
      { method: 'DELETE', headers: adminHeaders },
    );
    const cleanup = await fetch(`${supabaseUrl}/auth/v1/admin/users/${userId}`, {
      method: 'DELETE',
      headers: adminHeaders,
    });
    if (!cleanup.ok) {
      process.stderr.write(
        `Temporary alert canary user cleanup failed (${cleanup.status})\n`,
      );
      process.exitCode = 1;
    }
  }
}
