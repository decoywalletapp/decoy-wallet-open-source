#!/usr/bin/env node

import fs from 'node:fs';

let cloudRunEnv = {};
if (process.env.AUDIT_CLOUD_RUN_SERVICE_JSON) {
  const service = JSON.parse(fs.readFileSync(process.env.AUDIT_CLOUD_RUN_SERVICE_JSON, 'utf8'));
  cloudRunEnv = Object.fromEntries(
    (service.spec?.template?.spec?.containers?.[0]?.env ?? [])
      .filter((entry) => typeof entry.value === 'string')
      .map((entry) => [entry.name, entry.value]),
  );
}

const supabaseUrl = String(process.env.AUDIT_SUPABASE_URL ?? cloudRunEnv.SUPABASE_URL ?? '').replace(/\/+$/, '');
const serviceKey = process.env.AUDIT_SUPABASE_SERVICE_ROLE_KEY ?? cloudRunEnv.SUPABASE_SERVICE_ROLE_KEY;
const stripeKey = process.env.AUDIT_STRIPE_SECRET_KEY ?? cloudRunEnv.STRIPE_SECRET_KEY;
if (!supabaseUrl || !serviceKey || !stripeKey) throw new Error('Missing production audit configuration');

const entitlementResponse = await fetch(
  `${supabaseUrl}/rest/v1/user_entitlements?provider=eq.stripe&select=is_active,cancel_at_period_end,provider_subscription_id`,
  { headers: { apikey: serviceKey, Authorization: `Bearer ${serviceKey}` } },
);
if (!entitlementResponse.ok) throw new Error(`Entitlement audit failed (${entitlementResponse.status})`);
const entitlements = await entitlementResponse.json();

const summary = {
  stripeRows: entitlements.length,
  activeRows: entitlements.filter((row) => row.is_active).length,
  cancelingRows: entitlements.filter((row) => row.cancel_at_period_end).length,
  missingSubscriptionIds: entitlements.filter((row) => !row.provider_subscription_id).length,
  stripeSubscriptionsFound: 0,
  stripeSubscriptionsMissing: 0,
  existingSchedules: 0,
  cancelStateMismatches: 0,
  nonLiveSubscriptions: 0,
};

for (const entitlement of entitlements) {
  if (!entitlement.provider_subscription_id) continue;
  const response = await fetch(
    `https://api.stripe.com/v1/subscriptions/${encodeURIComponent(entitlement.provider_subscription_id)}?expand[]=schedule`,
    { headers: { Authorization: `Bearer ${stripeKey}` } },
  );
  if (response.status === 404) {
    summary.stripeSubscriptionsMissing += 1;
    continue;
  }
  if (!response.ok) throw new Error(`Stripe audit failed (${response.status})`);
  const subscription = await response.json();
  summary.stripeSubscriptionsFound += 1;
  if (subscription.schedule) summary.existingSchedules += 1;
  if (!subscription.livemode) summary.nonLiveSubscriptions += 1;
  if (Boolean(subscription.cancel_at_period_end) !== Boolean(entitlement.cancel_at_period_end)) {
    summary.cancelStateMismatches += 1;
  }
}

process.stdout.write(`${JSON.stringify(summary, null, 2)}\n`);
