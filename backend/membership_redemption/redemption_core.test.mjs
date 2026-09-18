import assert from 'node:assert/strict';
import test from 'node:test';
import {
  buildStripePromotionPlan,
  hashSecret,
  isMembershipCodeFormatValid,
  normalizeMembershipCode,
} from './redemption_core.mjs';

test('normalizes handwritten membership codes', () => {
  assert.equal(normalizeMembershipCode(' mwbs-7k9d-p4xm-q2vt '), 'MWBS-7K9D-P4XM-Q2VT');
  assert.equal(isMembershipCodeFormatValid('MWBS-7K9D-P4XM-Q2VT'), true);
  assert.equal(isMembershipCodeFormatValid('MWBS-OOOO-1111-IIII'), false);
});

test('hashes codes without retaining plaintext', () => {
  const hash = hashSecret('MWBS-7K9D-P4XM-Q2VT', 'test-pepper');
  assert.equal(hash.length, 64);
  assert.equal(hash.includes('MWBS'), false);
});

test('active recurring Stripe requires a free billing phase', () => {
  const plan = buildStripePromotionPlan({
    provider: 'stripe',
    subscriptionId: 'sub_123',
    cancelAtPeriodEnd: false,
    accessStartsAt: '2026-10-01T00:00:00Z',
    accessEndsAt: '2027-10-01T00:00:00Z',
  });
  assert.equal(plan.required, true);
  assert.equal(plan.discountPercent, 100);
  assert.equal(plan.resumeBillingAfter, '2027-10-01T00:00:00Z');
});

test('canceling Stripe is never silently reactivated', () => {
  const plan = buildStripePromotionPlan({
    provider: 'stripe',
    subscriptionId: 'sub_123',
    cancelAtPeriodEnd: true,
  });
  assert.deepEqual(plan, { required: false, reason: 'non_recurring_or_canceling' });
});
