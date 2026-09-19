#!/usr/bin/env node

import crypto from 'node:crypto';
import fs from 'node:fs';

const baseUrl = String(process.env.STAGING_REDEMPTION_BASE_URL ?? '').replace(/\/+$/, '');
const supabaseUrl = String(process.env.STAGING_SUPABASE_URL ?? '').replace(/\/+$/, '');
const serviceRoleKey = process.env.STAGING_SUPABASE_SERVICE_ROLE_KEY;
const codeCsv = process.env.STAGING_MEMBERSHIP_CODE_CSV;

if (!baseUrl || !supabaseUrl || !serviceRoleKey || !codeCsv) {
  throw new Error('Missing staging redemption smoke-test configuration');
}

const code = fs.readFileSync(codeCsv, 'utf8').trim().split(/\r?\n/)[1]?.split(',')[1]?.trim();
if (!code) throw new Error('The private code CSV contains no membership code');

async function supabase(path, init = {}) {
  const response = await fetch(`${supabaseUrl}${path}`, {
    ...init,
    headers: {
      apikey: serviceRoleKey,
      Authorization: `Bearer ${serviceRoleKey}`,
      'Content-Type': 'application/json',
      ...(init.headers ?? {}),
    },
  });
  const text = await response.text();
  const data = text ? JSON.parse(text) : null;
  if (!response.ok) throw new Error(`Supabase request failed (${response.status})`);
  return data;
}

const suffix = crypto.randomUUID().slice(0, 8);
const email = `staging-redemption-smoke-${suffix}@decoywalletapp.com`;
const password = `StagingRedemption-${crypto.randomUUID()}!`;
const user = await supabase('/auth/v1/admin/users', {
  method: 'POST',
  body: JSON.stringify({ email, password, email_confirm: true }),
});
const session = await supabase('/auth/v1/token?grant_type=password', {
  method: 'POST',
  body: JSON.stringify({ email, password }),
});

async function createRedemptionSession() {
  const response = await fetch(`${baseUrl}/create-redemption-session`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${session.access_token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ return_to: 'manage' }),
  });
  const data = await response.json();
  if (!response.ok) throw new Error(`Session creation failed (${response.status})`);
  return new URL(data.url).searchParams.get('session');
}

async function redeem(sessionToken) {
  const response = await fetch(`${baseUrl}/redeem-membership-code`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ session: sessionToken, code }),
  });
  return { status: response.status, data: await response.json() };
}

const first = await redeem(await createRedemptionSession());
if (first.status !== 200 || first.data.ok !== true) {
  throw new Error(`First redemption failed (${first.status})`);
}

const entitlementRows = await supabase(
  `/rest/v1/user_entitlements?user_id=eq.${user.id}&entitlement=eq.decoy_wallet&select=promotional_access_until`,
);
const endsAt = Date.parse(entitlementRows?.[0]?.promotional_access_until ?? '');
const days = (endsAt - Date.now()) / 86400000;
if (days < 364.9 || days > 365.1) throw new Error(`Unexpected promotional duration: ${days}`);

const second = await redeem(await createRedemptionSession());
if (second.status !== 409) throw new Error(`Code reuse was not rejected (${second.status})`);

const codeRows = await supabase(
  '/rest/v1/promo_codes?select=status',
  { headers: { Prefer: 'count=exact' } },
);
const availableCount = codeRows.filter((row) => row.status === 'available').length;
const redeemedCount = codeRows.filter((row) => row.status === 'redeemed').length;

process.stdout.write(`${JSON.stringify({
  ok: true,
  userId: user.id,
  promotionalDays: Number(days.toFixed(3)),
  reuseStatus: second.status,
  availableCount,
  redeemedCount,
}, null, 2)}\n`);
