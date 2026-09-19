#!/usr/bin/env node

const secretKey = process.env.STRIPE_SECRET_KEY;
if (!secretKey) throw new Error('Missing STRIPE_SECRET_KEY');

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
  if (!response.ok) throw new Error(body?.error?.message ?? 'Stripe request failed');
  return body;
}

const coupons = await stripe('/v1/coupons?limit=100');
let coupon = coupons.data.find(
  (item) =>
    item.percent_off === 100 &&
    item.duration === 'forever' &&
    item.metadata?.purpose === 'decoy_membership_redemption_staging',
);

if (!coupon) {
  const body = new URLSearchParams();
  body.set('percent_off', '100');
  body.set('duration', 'forever');
  body.set('name', 'Decoy Membership Redemption - Staging');
  body.set('metadata[purpose]', 'decoy_membership_redemption_staging');
  body.set('metadata[environment]', 'staging');
  coupon = await stripe('/v1/coupons', { method: 'POST', body });
}

process.stdout.write(`${coupon.id}\n`);
