#!/usr/bin/env node

import fs from 'node:fs';

const serviceJsonPath = process.env.PRODUCTION_SERVICE_JSON;
if (!serviceJsonPath) throw new Error('Missing PRODUCTION_SERVICE_JSON');

const service = JSON.parse(fs.readFileSync(serviceJsonPath, 'utf8'));
const env = Object.fromEntries(
  (service.spec?.template?.spec?.containers?.[0]?.env ?? [])
    .filter((entry) => typeof entry.value === 'string')
    .map((entry) => [entry.name, entry.value]),
);
const secretKey = env.STRIPE_SECRET_KEY;
if (!secretKey) throw new Error('Production service has no Stripe key');

const auth = `Basic ${Buffer.from(`${secretKey}:`).toString('base64')}`;

async function stripe(path, options = {}) {
  const response = await fetch(`https://api.stripe.com${path}`, {
    ...options,
    headers: {
      authorization: auth,
      ...(options.body
        ? { 'content-type': 'application/x-www-form-urlencoded' }
        : {}),
    },
  });
  const body = await response.json();
  if (!response.ok) {
    throw new Error(body?.error?.message ?? 'Stripe request failed');
  }
  return body;
}

const coupons = await stripe('/v1/coupons?limit=100');
let coupon = coupons.data.find(
  (item) =>
    item.percent_off === 100 &&
    item.duration === 'forever' &&
    item.metadata?.purpose === 'decoy_membership_redemption',
);

if (!coupon) {
  const body = new URLSearchParams();
  body.set('percent_off', '100');
  body.set('duration', 'forever');
  body.set('name', 'Decoy Membership Redemption');
  body.set('metadata[purpose]', 'decoy_membership_redemption');
  body.set('metadata[environment]', 'production');
  coupon = await stripe('/v1/coupons', { method: 'POST', body });
}

process.stdout.write(`${coupon.id}\n`);
