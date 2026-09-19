#!/usr/bin/env node

import crypto from 'node:crypto';
import fs from 'node:fs';

const paymentServicePath = process.env.PAYMENT_SERVICE_JSON;
const alertServicePath = process.env.ALERT_SERVICE_JSON;
const canaryCsvPath = process.env.CANARY_CODE_CSV;
const canaryBaseUrl = String(process.env.CANARY_BASE_URL ?? '').replace(
  /\/+$/,
  '',
);
if (
  !paymentServicePath ||
  !alertServicePath ||
  !canaryCsvPath ||
  !canaryBaseUrl
) {
  throw new Error('Missing production canary smoke configuration');
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

const code = fs
  .readFileSync(canaryCsvPath, 'utf8')
  .trim()
  .split(/\r?\n/)[1]
  ?.split(',')[1]
  ?.trim();
if (!code) throw new Error('Canary code is missing');

const nonce = crypto.randomBytes(12).toString('hex');
const email = `decoy-redemption-canary-${nonce}@example.invalid`;
const password = `${crypto.randomBytes(24).toString('base64url')}Aa1!`;
let userId;

try {
  const created = await jsonFetch(`${supabaseUrl}/auth/v1/admin/users`, {
    method: 'POST',
    headers: {
      apikey: serviceKey,
      authorization: `Bearer ${serviceKey}`,
      'content-type': 'application/json',
    },
    body: JSON.stringify({ email, password, email_confirm: true }),
  });
  if (!created.response.ok || !created.body?.id) {
    throw new Error(`Temporary user creation failed (${created.response.status})`);
  }
  userId = created.body.id;

  const signedIn = await jsonFetch(
    `${supabaseUrl}/auth/v1/token?grant_type=password`,
    {
      method: 'POST',
      headers: {
        apikey: anonKey,
        'content-type': 'application/json',
      },
      body: JSON.stringify({ email, password }),
    },
  );
  const jwt = signedIn.body?.access_token;
  if (!signedIn.response.ok || !jwt) {
    throw new Error(`Temporary user sign-in failed (${signedIn.response.status})`);
  }

  const session = await jsonFetch(`${canaryBaseUrl}/create-redemption-session`, {
    method: 'POST',
    headers: {
      authorization: `Bearer ${jwt}`,
      'content-type': 'application/json',
    },
    body: JSON.stringify({ return_to: 'home' }),
  });
  if (!session.response.ok || !session.body?.url) {
    throw new Error(`Canary session failed (${session.response.status})`);
  }
  const sessionToken = new URL(session.body.url).searchParams.get('session');
  if (!sessionToken) throw new Error('Canary session token missing');

  const redeemed = await jsonFetch(`${canaryBaseUrl}/redeem-membership-code`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ session: sessionToken, code }),
  });
  if (!redeemed.response.ok || redeemed.body?.ok !== true) {
    throw new Error(`Canary redemption failed (${redeemed.response.status})`);
  }

  const accessEndMs = Date.parse(redeemed.body.access_ends_at);
  const grantedDays = Math.round((accessEndMs - Date.now()) / 86400000);
  if (grantedDays < 364 || grantedDays > 366) {
    throw new Error(`Unexpected promotional duration: ${grantedDays} days`);
  }

  const secondSession = await jsonFetch(
    `${canaryBaseUrl}/create-redemption-session`,
    {
      method: 'POST',
      headers: {
        authorization: `Bearer ${jwt}`,
        'content-type': 'application/json',
      },
      body: JSON.stringify({ return_to: 'home' }),
    },
  );
  const secondToken = new URL(secondSession.body.url).searchParams.get('session');
  const reused = await jsonFetch(`${canaryBaseUrl}/redeem-membership-code`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ session: secondToken, code }),
  });
  if (reused.response.status !== 409) {
    throw new Error(`Used code was not rejected (${reused.response.status})`);
  }

  const access = await jsonFetch(
    `${supabaseUrl}/rest/v1/rpc/has_active_decoy_wallet_access`,
    {
      method: 'POST',
      headers: {
        apikey: serviceKey,
        authorization: `Bearer ${serviceKey}`,
        'content-type': 'application/json',
      },
      body: JSON.stringify({ p_user_id: userId }),
    },
  );
  if (!access.response.ok || access.body !== true) {
    throw new Error('Promotional entitlement helper did not grant access');
  }

  process.stdout.write(
    `${JSON.stringify({
      temporaryUserCreated: true,
      redemptionSucceeded: true,
      grantedDays,
      reusedCodeRejected: true,
      sharedAccessGranted: true,
    })}\n`,
  );
} finally {
  if (userId) {
    const cleanup = await fetch(`${supabaseUrl}/auth/v1/admin/users/${userId}`, {
      method: 'DELETE',
      headers: {
        apikey: serviceKey,
        authorization: `Bearer ${serviceKey}`,
      },
    });
    if (!cleanup.ok) {
      process.stderr.write(
        `Temporary canary user cleanup failed (${cleanup.status})\n`,
      );
      process.exitCode = 1;
    }
  }
}
