import crypto from 'node:crypto';

const codePattern = /^MWBS-[2-9A-HJ-NP-Z]{4}-[2-9A-HJ-NP-Z]{4}-[2-9A-HJ-NP-Z]{4}$/;

export function normalizeMembershipCode(value) {
  const compact = String(value ?? '')
    .trim()
    .toUpperCase()
    .replace(/[^A-Z0-9]/g, '');
  if (!compact.startsWith('MWBS') || compact.length !== 16) return compact;
  return `MWBS-${compact.slice(4, 8)}-${compact.slice(8, 12)}-${compact.slice(12, 16)}`;
}

export function isMembershipCodeFormatValid(value) {
  return codePattern.test(normalizeMembershipCode(value));
}

export function hashSecret(value, pepper) {
  if (!pepper) throw new Error('MEMBERSHIP_CODE_PEPPER is required');
  return crypto
    .createHmac('sha256', pepper)
    .update(String(value), 'utf8')
    .digest('hex');
}

export function createOpaqueToken() {
  return crypto.randomBytes(32).toString('base64url');
}

export function effectiveAccessBase({
  now = new Date(),
  currentPeriodEnd,
  promotionalAccessUntil,
  teardownGraceUntil,
} = {}) {
  const candidates = [now, currentPeriodEnd, promotionalAccessUntil, teardownGraceUntil]
    .map((value) => new Date(value ?? Number.NaN))
    .filter((value) => Number.isFinite(value.getTime()));
  return new Date(Math.max(...candidates.map((value) => value.getTime())));
}

export function buildStripePromotionPlan({
  provider,
  subscriptionId,
  cancelAtPeriodEnd,
  accessStartsAt,
  accessEndsAt,
}) {
  if (
    provider !== 'stripe' ||
    !subscriptionId ||
    cancelAtPeriodEnd === true
  ) {
    return { required: false, reason: 'non_recurring_or_canceling' };
  }

  return {
    required: true,
    subscriptionId,
    freePhaseStartsAt: accessStartsAt,
    freePhaseEndsAt: accessEndsAt,
    resumeBillingAfter: accessEndsAt,
    preserveCurrentBilling: true,
    discountPercent: 100,
  };
}
