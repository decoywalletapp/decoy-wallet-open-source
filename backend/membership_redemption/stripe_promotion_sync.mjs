import { buildStripePromotionPlan } from './redemption_core.mjs';

function phaseItems(items) {
  return items.map((item) => ({
    price: typeof item.price === 'string' ? item.price : item.price.id,
    quantity: item.quantity ?? 1,
  }));
}

export function createStripePromotionSync({
  stripe,
  supabaseAdmin,
  hundredPercentCouponId,
}) {
  if (!hundredPercentCouponId) {
    throw new Error('STRIPE_PROMO_100_COUPON_ID is required');
  }

  return async function syncStripePromotion({ userId, redemption }) {
    const { data: entitlement, error } = await supabaseAdmin
      .from('user_entitlements')
      .select('provider,provider_subscription_id,cancel_at_period_end')
      .eq('user_id', userId)
      .eq('entitlement', 'decoy_wallet')
      .maybeSingle();
    if (error) throw error;

    const plan = buildStripePromotionPlan({
      provider: entitlement?.provider,
      subscriptionId: entitlement?.provider_subscription_id,
      cancelAtPeriodEnd: entitlement?.cancel_at_period_end,
      accessStartsAt: redemption.access_started_at,
      accessEndsAt: redemption.access_ends_at,
    });
    if (!plan.required) return plan;

    const subscription = await stripe.subscriptions.retrieve(
      plan.subscriptionId,
      { expand: ['schedule', 'items.data.price'] },
    );
    if (subscription.cancel_at_period_end) {
      return { required: false, reason: 'canceling_subscription' };
    }
    if (subscription.schedule) {
      throw new Error(
        'existing_subscription_schedule_requires_manual_review',
      );
    }

    const schedule = await stripe.subscriptionSchedules.create(
      { from_subscription: subscription.id },
      { idempotencyKey: `promo-schedule-${redemption.redemption_id}` },
    );
    const current = schedule.phases.at(-1);
    if (!current?.end_date || !current.items?.length) {
      throw new Error('stripe_schedule_missing_current_phase');
    }

    const items = phaseItems(current.items);
    const freeEnd = Math.floor(
      new Date(redemption.access_ends_at).getTime() / 1000,
    );
    if (!Number.isFinite(freeEnd) || freeEnd <= current.end_date) {
      throw new Error('invalid_promotional_phase_dates');
    }

    await stripe.subscriptionSchedules.update(
      schedule.id,
      {
        end_behavior: 'release',
        proration_behavior: 'none',
        phases: [
          {
            start_date: current.start_date,
            end_date: current.end_date,
            items,
          },
          {
            start_date: current.end_date,
            end_date: freeEnd,
            items,
            discounts: [{ coupon: hundredPercentCouponId }],
            metadata: {
              decoy_promo_redemption_id: redemption.redemption_id,
            },
          },
          {
            start_date: freeEnd,
            items,
          },
        ],
        metadata: {
          decoy_promo_redemption_id: redemption.redemption_id,
          decoy_promo_user_id: userId,
        },
      },
      { idempotencyKey: `promo-schedule-update-${redemption.redemption_id}` },
    );

    return { required: true, scheduleId: schedule.id, complete: true };
  };
}
