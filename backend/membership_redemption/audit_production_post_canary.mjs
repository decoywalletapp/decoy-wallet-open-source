#!/usr/bin/env node

import fs from 'node:fs';

const servicePath = process.env.PAYMENT_SERVICE_JSON;
if (!servicePath) throw new Error('Missing PAYMENT_SERVICE_JSON');

const service = JSON.parse(fs.readFileSync(servicePath, 'utf8'));
const env = Object.fromEntries(
  (service.spec?.template?.spec?.containers?.[0]?.env ?? [])
    .filter((entry) => typeof entry.value === 'string')
    .map((entry) => [entry.name, entry.value]),
);
const supabaseUrl = String(env.SUPABASE_URL ?? '').replace(/\/+$/, '');
const serviceKey = env.SUPABASE_SERVICE_ROLE_KEY;
if (!supabaseUrl || !serviceKey) throw new Error('Missing Supabase configuration');

const headers = {
  apikey: serviceKey,
  authorization: `Bearer ${serviceKey}`,
};

async function get(path) {
  const response = await fetch(`${supabaseUrl}${path}`, { headers });
  const body = await response.json();
  if (!response.ok) {
    throw new Error(`Audit request failed for ${path} (${response.status})`);
  }
  return body;
}

const now = Date.now();
const entitlements = await get(
  '/rest/v1/user_entitlements?entitlement=eq.decoy_wallet&select=user_id,is_active,current_period_end,teardown_grace_until,pending_provider,pending_starts_at,pending_provider_subscription_id,promotional_access_until',
);

function isFuture(value) {
  return value != null && Date.parse(value) > now;
}

function legacyAccess(row) {
  return (
    row.is_active === true &&
    (isFuture(row.current_period_end) ||
      isFuture(row.teardown_grace_until) ||
      (row.current_period_end == null && row.promotional_access_until == null) ||
      (['stripe', 'btcpay'].includes(
        String(row.pending_provider ?? '').toLowerCase(),
      ) &&
        row.pending_starts_at != null &&
        String(row.pending_provider_subscription_id ?? '') !== ''))
  );
}

function unifiedAccess(row) {
  return isFuture(row.promotional_access_until) || legacyAccess(row);
}

const mismatches = entitlements.filter(
  (row) => legacyAccess(row) !== unifiedAccess(row),
);
const populatedPromotions = entitlements.filter(
  (row) => row.promotional_access_until != null,
);
const users = await get('/auth/v1/admin/users?page=1&per_page=1000');
const temporaryUsers = (users.users ?? []).filter((user) =>
  String(user.email ?? '').startsWith('decoy-db-alert-'),
);
const promoCodes = await get(
  '/rest/v1/promo_codes?select=id,redeemed_at',
);
const redemptions = await get('/rest/v1/promo_redemptions?select=id');
const sessions = await get('/rest/v1/promo_redemption_sessions?select=id');

const result = {
  entitlementRows: entitlements.length,
  legacyAllowed: entitlements.filter(legacyAccess).length,
  unifiedAllowed: entitlements.filter(unifiedAccess).length,
  accessDecisionMismatches: mismatches.length,
  populatedPromotions: populatedPromotions.length,
  temporaryUsers: temporaryUsers.length,
  promoCodes: promoCodes.length,
  redeemedPromoCodes: promoCodes.filter((row) => row.redeemed_at != null).length,
  retainedRedemptions: redemptions.length,
  retainedSessions: sessions.length,
};

if (
  result.accessDecisionMismatches !== 0 ||
  result.temporaryUsers !== 0 ||
  result.retainedRedemptions !== 0 ||
  result.retainedSessions !== 0
) {
  throw new Error(`Post-canary audit failed: ${JSON.stringify(result)}`);
}

process.stdout.write(`${JSON.stringify(result)}\n`);
