import assert from 'node:assert/strict';
import test from 'node:test';
import { createStripePromotionSync } from './stripe_promotion_sync.mjs';

function supabaseFor(entitlement) {
  const chain = {
    select: () => chain,
    eq: () => chain,
    maybeSingle: async () => ({ data: entitlement, error: null }),
  };
  return { from: () => chain };
}

test('does not reactivate a subscription set to cancel', async () => {
  let stripeCalled = false;
  const sync = createStripePromotionSync({
    stripe: { subscriptions: { retrieve: async () => { stripeCalled = true; } } },
    supabaseAdmin: supabaseFor({
      provider: 'stripe',
      provider_subscription_id: 'sub_1',
      cancel_at_period_end: true,
    }),
    hundredPercentCouponId: 'coupon_free_year',
  });

  const result = await sync({
    userId: 'user_1',
    redemption: {
      redemption_id: 'redemption_1',
      access_started_at: '2026-10-01T00:00:00Z',
      access_ends_at: '2027-10-01T00:00:00Z',
    },
  });
  assert.equal(result.required, false);
  assert.equal(stripeCalled, false);
});

test('creates paid, free, then resumed phases for recurring Stripe', async () => {
  let update;
  const stripe = {
    subscriptions: {
      retrieve: async () => ({ id: 'sub_1', cancel_at_period_end: false, schedule: null }),
    },
    subscriptionSchedules: {
      create: async () => ({
        id: 'sub_sched_1',
        phases: [{
          start_date: 1790812800,
          end_date: 1793491200,
          items: [{ price: 'price_monthly', quantity: 1 }],
        }],
      }),
      update: async (_id, body) => { update = body; },
    },
  };
  const sync = createStripePromotionSync({
    stripe,
    supabaseAdmin: supabaseFor({
      provider: 'stripe',
      provider_subscription_id: 'sub_1',
      cancel_at_period_end: false,
    }),
    hundredPercentCouponId: 'coupon_free_year',
  });

  await sync({
    userId: 'user_1',
    redemption: {
      redemption_id: 'redemption_1',
      access_started_at: '2026-11-01T00:00:00Z',
      access_ends_at: '2027-11-01T00:00:00Z',
    },
  });
  assert.equal(update.phases.length, 3);
  assert.equal(update.phases[1].discounts[0].coupon, 'coupon_free_year');
  assert.equal(update.phases[2].discounts, undefined);
  assert.equal(update.end_behavior, 'release');
});

test('refuses to replace an existing Stripe subscription schedule', async () => {
  let scheduleCreated = false;
  const sync = createStripePromotionSync({
    stripe: {
      subscriptions: {
        retrieve: async () => ({
          id: 'sub_1',
          cancel_at_period_end: false,
          schedule: 'sub_sched_existing',
        }),
      },
      subscriptionSchedules: {
        create: async () => {
          scheduleCreated = true;
        },
      },
    },
    supabaseAdmin: supabaseFor({
      provider: 'stripe',
      provider_subscription_id: 'sub_1',
      cancel_at_period_end: false,
    }),
    hundredPercentCouponId: 'coupon_free_year',
  });

  await assert.rejects(
    sync({
      userId: 'user_1',
      redemption: {
        redemption_id: 'redemption_1',
        access_started_at: '2026-11-01T00:00:00Z',
        access_ends_at: '2027-11-01T00:00:00Z',
      },
    }),
    /existing_subscription_schedule_requires_manual_review/,
  );
  assert.equal(scheduleCreated, false);
});
