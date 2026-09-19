import 'dart:io';

import 'package:decoy_wallet_app/flutter_flow/custom_functions.dart'
    as functions;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'promotional access keeps protection usable independently of provider',
    () {
      expect(
        functions.isEntitlementUsableForProtection(
          false,
          DateTime.now().subtract(const Duration(days: 1)),
          null,
          null,
          null,
          DateTime.now().add(const Duration(days: 365)),
        ),
        isTrue,
      );
    },
  );

  test('expired promotional access does not bypass an inactive provider', () {
    expect(
      functions.isEntitlementUsableForProtection(
        false,
        DateTime.now().subtract(const Duration(days: 1)),
        null,
        null,
        null,
        DateTime.now().subtract(const Duration(seconds: 1)),
      ),
      isFalse,
    );
  });

  test('redemption schema is additive, private, atomic, and stackable', () {
    final migration = File(
      'supabase/migrations/'
      '20260919010000_add_membership_redemption.sql',
    ).readAsStringSync();

    expect(migration, contains('promotional_access_until timestamptz'));
    expect(
      migration,
      contains('create table if not exists public.promo_codes'),
    );
    expect(migration, contains('code_hash text not null unique'));
    expect(migration, contains("status <> 'available'"));
    expect(migration, contains('for update'));
    expect(migration, contains('p_session_hash text'));
    expect(migration, contains('set consumed_at = now()'));
    expect(migration, contains('has_active_decoy_wallet_access'));
    expect(migration, contains('e.promotional_access_until > now()'));
    expect(migration, contains('e.promotional_access_until is null'));
    expect(
      migration,
      contains(
        "lower(coalesce(e.pending_provider, '')) in ('stripe', 'btcpay')",
      ),
    );
    expect(migration, contains('greatest('));
    expect(
      migration,
      contains('make_interval(days => v_campaign.duration_days)'),
    );
    expect(migration, contains('revoke all on public.promo_codes'));
    expect(migration, contains("auth.role() <> 'service_role'"));
    expect(migration.toLowerCase(), isNot(contains('drop table')));
    expect(migration.toLowerCase(), isNot(contains('delete from')));
  });

  test('all alert triggers use the shared promotional access guard', () {
    final migration = File(
      'supabase/migrations/'
      '20260919011000_promotional_alert_entitlement.sql',
    ).readAsStringSync();

    expect(migration, contains('create_alert_from_decoy_trigger'));
    expect(migration, contains('fn_alert_logs_to_sms_queue'));
    expect(
      'public.has_active_decoy_wallet_access(NEW.user_id)'
          .allMatches(migration),
      hasLength(2),
    );
    expect(migration, contains("NEW.trigger_type = 'PIN_DECOY'"));
    expect(migration, contains("NEW.trigger_type = 'SEED_DECOY'"));
    expect(migration, contains('txid_hmac = v_txid_hmac'));
    expect(migration, contains('on conflict (alert_id) do nothing'));
  });

  test('promotional alert guard preserves recipient-address handoff', () {
    final migration = File(
      'supabase/migrations/'
      '20260919012000_restore_seed_alert_destination_handoff.sql',
    ).readAsStringSync();

    expect(
      migration,
      contains('public.has_active_decoy_wallet_access(NEW.user_id)'),
    );
    expect(migration, contains('NEW.destination_addresses'));
    expect(
        migration, contains('jsonb_array_length(NEW.destination_addresses)'));
    expect(migration, contains('destination_addresses,'));
    expect(migration, contains('destination_address_count,'));
    expect(migration, contains('v_destination_addresses,'));
    expect(migration, contains('v_destination_address_count,'));
  });

  test('follow-up migration preserves legacy access and hardened alert execution', () {
    final migration = File(
      'supabase/migrations/20260919013000_preserve_alert_security_and_legacy_access.sql',
    ).readAsStringSync();
    expect(migration, contains('e.current_period_end is null'));
    expect(
      migration,
      contains('alter function public.create_alert_from_decoy_trigger() security definer'),
    );
    expect(
      migration,
      contains('alter function public.fn_alert_logs_to_sms_queue() security definer'),
    );
    expect(migration, contains('set search_path = public'));
  });

  test('redemption reserves before external billing and finalizes atomically', () {
    final migration = File(
      'supabase/migrations/20260919014000_atomic_membership_redemption.sql',
    ).readAsStringSync();
    final routes = File(
      'backend/membership_redemption/register_routes.mjs',
    ).readAsStringSync();
    expect(migration, contains('reserve_membership_code'));
    expect(migration, contains('finalize_membership_code'));
    expect(migration, contains('completed_membership_redemption'));
    expect(migration, contains("v_code.status = 'reserved'"));
    expect(migration, contains('billing_sync_incomplete'));
    expect(migration, contains('promotional_access_until = greatest'));
    expect(migration, contains('is distinct from v_session.user_id'));
    final reserveCall = routes.indexOf("'reserve_membership_code'");
    final stripeSync = routes.indexOf('await syncStripePromotion', reserveCall);
    final finalizeCall = routes.indexOf("'finalize_membership_code'", stripeSync);
    expect(reserveCall, greaterThanOrEqualTo(0));
    expect(stripeSync, greaterThan(reserveCall));
    expect(finalizeCall, greaterThan(stripeSync));
  });

  test('both subscription pages expose the same external redemption flow', () {
    for (final path in <String>[
      'lib/welcom_pages/subscription_options/'
          'subscription_options_widget.dart',
      'lib/settings_pages/manage_subscription/'
          'manage_subscription_widget.dart',
    ]) {
      final page = File(path).readAsStringSync();
      expect(page, contains('RedemptionOptionCard'));
      expect(page, contains('CreateRedemptionSessionCall'));
      expect(page, contains("returnTo: 'home'"));
    }

    final card = File(
      'lib/components/redemption_option_card.dart',
    ).readAsStringSync();
    expect(card, contains("text: 'Redeem Membership'"));
    expect(card, contains('Icons.card_giftcard_rounded'));
  });

  test('payment return recognizes promotional access', () {
    final paymentReturn = File(
      'lib/welcom_pages/payment_return/payment_return_widget.dart',
    ).readAsStringSync();
    expect(paymentReturn, contains('_hasUsableAccess'));
    expect(paymentReturn, contains('entitlement.promotionalAccessUntil'));
  });
}
