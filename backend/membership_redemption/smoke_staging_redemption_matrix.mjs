#!/usr/bin/env node

import crypto from 'node:crypto';
import fs from 'node:fs';

const baseUrl = String(process.env.STAGING_REDEMPTION_BASE_URL ?? '').replace(/\/+$/, '');
const supabaseUrl = String(process.env.STAGING_SUPABASE_URL ?? '').replace(/\/+$/, '');
const serviceKey = process.env.STAGING_SUPABASE_SERVICE_ROLE_KEY;
const csvPath = process.env.STAGING_MEMBERSHIP_CODE_CSV;
if (!baseUrl || !supabaseUrl || !serviceKey || !csvPath) throw new Error('Missing staging configuration');

const codes = fs.readFileSync(csvPath, 'utf8').trim().split(/\r?\n/).slice(1).map((line) => line.split(',')[1]?.trim());
if (codes.length < 5) throw new Error('At least five staging codes are required');

async function admin(path, init = {}) {
  const response = await fetch(`${supabaseUrl}${path}`, {
    ...init,
    headers: {
      apikey: serviceKey,
      Authorization: `Bearer ${serviceKey}`,
      'Content-Type': 'application/json',
      ...(init.headers ?? {}),
    },
  });
  const text = await response.text();
  const data = text ? JSON.parse(text) : null;
  if (!response.ok) throw new Error(`Staging database request failed (${response.status})`);
  return data;
}

async function createUser(label) {
  const nonce = crypto.randomUUID();
  const email = `staging-redemption-${label}-${nonce.slice(0, 8)}@decoywalletapp.com`;
  const password = `StagingRedemption-${nonce}!`;
  const user = await admin('/auth/v1/admin/users', {
    method: 'POST', body: JSON.stringify({ email, password, email_confirm: true }),
  });
  const auth = await admin('/auth/v1/token?grant_type=password', {
    method: 'POST', body: JSON.stringify({ email, password }),
  });
  return { id: user.id, accessToken: auth.access_token };
}

async function createSession(user) {
  const response = await fetch(`${baseUrl}/create-redemption-session`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${user.accessToken}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ return_to: 'manage' }),
  });
  const data = await response.json();
  if (!response.ok) throw new Error(`Session creation failed (${response.status})`);
  return new URL(data.url).searchParams.get('session');
}

async function redeem(user, code, suppliedSession) {
  const response = await fetch(`${baseUrl}/redeem-membership-code`, {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ session: suppliedSession ?? await createSession(user), code }),
  });
  return { status: response.status, data: await response.json() };
}

async function promoDays(userId) {
  const rows = await admin(`/rest/v1/user_entitlements?user_id=eq.${userId}&entitlement=eq.decoy_wallet&select=promotional_access_until`);
  return (Date.parse(rows[0].promotional_access_until) - Date.now()) / 86400000;
}

const fixedUser = await createUser('fixed');
const fixedEnd = new Date(Date.now() + 30 * 86400000).toISOString();
await admin('/rest/v1/user_entitlements', {
  method: 'POST',
  headers: { Prefer: 'resolution=merge-duplicates' },
  body: JSON.stringify({ user_id: fixedUser.id, entitlement: 'decoy_wallet', is_active: true, provider: 'btcpay', current_period_end: fixedEnd }),
});
const fixedResult = await redeem(fixedUser, codes[1]);
const fixedDays = await promoDays(fixedUser.id);
if (fixedResult.status !== 200 || fixedDays < 394.9 || fixedDays > 395.1) throw new Error('Fixed-access stacking failed');

const stackUser = await createUser('stack');
const stackFirst = await redeem(stackUser, codes[2]);
const stackSecond = await redeem(stackUser, codes[3]);
const stackDays = await promoDays(stackUser.id);
if (stackFirst.status !== 200 || stackSecond.status !== 200 || stackDays < 729.9 || stackDays > 730.1) {
  throw new Error('Promotional stacking failed');
}

const raceUser = await createUser('race');
const raceSessions = await Promise.all([createSession(raceUser), createSession(raceUser)]);
const raceResults = await Promise.all(raceSessions.map((token) => redeem(raceUser, codes[4], token)));
const raceStatuses = raceResults.map((result) => result.status).sort();
const raceDays = await promoDays(raceUser.id);
if (raceStatuses.join(',') !== '200,409' || raceDays < 364.9 || raceDays > 365.1) {
  throw new Error(`Concurrent redemption protection failed (${raceStatuses.join(',')})`);
}

process.stdout.write(`${JSON.stringify({
  ok: true,
  fixedAccessStackingDays: Number(fixedDays.toFixed(3)),
  promotionalStackingDays: Number(stackDays.toFixed(3)),
  concurrentStatuses: raceStatuses,
  concurrentAccessDays: Number(raceDays.toFixed(3)),
}, null, 2)}\n`);
