#!/usr/bin/env node

import crypto from 'node:crypto';
import fs from 'node:fs';

const baseUrl = String(process.env.STAGING_REDEMPTION_BASE_URL ?? '').replace(/\/+$/, '');
const supabaseUrl = String(process.env.STAGING_SUPABASE_URL ?? '').replace(/\/+$/, '');
const serviceKey = process.env.STAGING_SUPABASE_SERVICE_ROLE_KEY;
const stripeKey = process.env.STAGING_STRIPE_SECRET_KEY;
const stripePriceId = process.env.STAGING_STRIPE_PRICE_ID;
const couponId = process.env.STAGING_STRIPE_COUPON_ID;
const csvPath = process.env.STAGING_MEMBERSHIP_CODE_CSV;
const cancelingMode = process.env.STAGING_STRIPE_CANCELING === 'true';
const codeIndex = Number(process.env.STAGING_CODE_INDEX ?? 7);
if (![baseUrl, supabaseUrl, serviceKey, stripeKey, stripePriceId, couponId, csvPath].every(Boolean)) {
  throw new Error('Missing staging Stripe smoke-test configuration');
}
const code = fs.readFileSync(csvPath, 'utf8').trim().split(/\r?\n/)[codeIndex]?.split(',')[1]?.trim();
if (!code) throw new Error(`Staging code ${codeIndex} is required`);

async function admin(path, init = {}) {
  const response = await fetch(`${supabaseUrl}${path}`, {
    ...init,
    headers: { apikey: serviceKey, Authorization: `Bearer ${serviceKey}`, 'Content-Type': 'application/json', ...(init.headers ?? {}) },
  });
  const text = await response.text();
  const data = text ? JSON.parse(text) : null;
  if (!response.ok) throw new Error(`Staging database request failed (${response.status})`);
  return data;
}

async function stripe(path, values = {}, method = 'POST') {
  const response = await fetch(`https://api.stripe.com/v1${path}`, {
    method,
    headers: { Authorization: `Bearer ${stripeKey}`, 'Content-Type': 'application/x-www-form-urlencoded' },
    body: method === 'GET' ? undefined : new URLSearchParams(values),
  });
  const data = await response.json();
  if (!response.ok) {
    throw new Error(
      `Stripe test request failed for ${path} (${response.status}): ${data.error?.code ?? data.error?.type ?? 'unknown'} - ${data.error?.message ?? 'no message'}`,
    );
  }
  return data;
}

const nonce = crypto.randomUUID();
const email = `staging-redemption-stripe-${nonce.slice(0, 8)}@decoywalletapp.com`;
const password = `StagingStripeRedemption-${nonce}!`;
const user = await admin('/auth/v1/admin/users', {
  method: 'POST', body: JSON.stringify({ email, password, email_confirm: true }),
});
const auth = await admin('/auth/v1/token?grant_type=password', {
  method: 'POST', body: JSON.stringify({ email, password }),
});

const customer = await stripe('/customers', { email, 'metadata[supabase_user_id]': user.id });
const paymentMethod = await stripe('/payment_methods', { type: 'card', 'card[token]': 'tok_visa' });
await stripe(`/payment_methods/${paymentMethod.id}/attach`, { customer: customer.id });
let subscription = await stripe('/subscriptions', {
  customer: customer.id,
  'items[0][price]': stripePriceId,
  default_payment_method: paymentMethod.id,
  payment_behavior: 'error_if_incomplete',
  'billing_mode[type]': 'classic',
  'metadata[supabase_user_id]': user.id,
});
if (cancelingMode) {
  subscription = await stripe(`/subscriptions/${subscription.id}`, { cancel_at_period_end: 'true' });
}
const currentPeriodEnd = subscription.current_period_end ?? subscription.items?.data?.[0]?.current_period_end;
if (!currentPeriodEnd) throw new Error('Stripe test subscription did not expose a current period end');

await admin('/rest/v1/user_entitlements', {
  method: 'POST', headers: { Prefer: 'resolution=merge-duplicates' },
  body: JSON.stringify({
    user_id: user.id,
    entitlement: 'decoy_wallet',
    is_active: true,
    provider: 'stripe',
    provider_customer_id: customer.id,
    provider_subscription_id: subscription.id,
    provider_status: subscription.status,
    current_period_end: new Date(currentPeriodEnd * 1000).toISOString(),
    cancel_at_period_end: cancelingMode,
  }),
});

const sessionResponse = await fetch(`${baseUrl}/create-redemption-session`, {
  method: 'POST',
  headers: { Authorization: `Bearer ${auth.access_token}`, 'Content-Type': 'application/json' },
  body: JSON.stringify({ return_to: 'manage' }),
});
const sessionData = await sessionResponse.json();
if (!sessionResponse.ok) throw new Error(`Session creation failed (${sessionResponse.status})`);
const sessionToken = new URL(sessionData.url).searchParams.get('session');
const redemptionResponse = await fetch(`${baseUrl}/redeem-membership-code`, {
  method: 'POST', headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ session: sessionToken, code }),
});
const redemption = await redemptionResponse.json();
if (!redemptionResponse.ok) throw new Error(`Stripe redemption failed (${redemptionResponse.status})`);

const refreshedSubscription = await stripe(`/subscriptions/${subscription.id}?expand[]=schedule`, {}, 'GET');
const scheduleId = typeof refreshedSubscription.schedule === 'string' ? refreshedSubscription.schedule : refreshedSubscription.schedule?.id;
let schedule;
if (cancelingMode) {
  if (!refreshedSubscription.cancel_at_period_end || scheduleId) {
    throw new Error('Canceling Stripe subscription was reactivated or rescheduled');
  }
} else {
  if (!scheduleId) throw new Error('Stripe test subscription has no promotion schedule');
  schedule = await stripe(`/subscription_schedules/${scheduleId}`, {}, 'GET');
  if (schedule.phases?.length !== 3) throw new Error(`Expected three Stripe phases, received ${schedule.phases?.length ?? 0}`);
  const freePhase = schedule.phases[1];
  const freeCoupon = freePhase.discounts?.[0]?.coupon;
  const freeCouponId = typeof freeCoupon === 'string' ? freeCoupon : freeCoupon?.id;
  if (freeCouponId !== couponId) throw new Error('Stripe free phase does not use the staging promotion coupon');
}

const rows = await admin(`/rest/v1/promo_redemptions?user_id=eq.${user.id}&select=billing_sync_status,access_ends_at`);
const expectedSyncStatus = cancelingMode ? 'not_required' : 'complete';
if (rows[0]?.billing_sync_status !== expectedSyncStatus) {
  throw new Error(`Unexpected Stripe billing synchronization status: ${rows[0]?.billing_sync_status}`);
}

process.stdout.write(`${JSON.stringify({
  ok: true,
  redemptionStatus: redemptionResponse.status,
  subscriptionStatus: refreshedSubscription.status,
  cancelAtPeriodEnd: refreshedSubscription.cancel_at_period_end,
  schedulePhases: schedule?.phases?.length ?? 0,
  billingSyncStatus: rows[0].billing_sync_status,
  accessEndsAt: rows[0].access_ends_at,
}, null, 2)}\n`);
