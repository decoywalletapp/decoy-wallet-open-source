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
