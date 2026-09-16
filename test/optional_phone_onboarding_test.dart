import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('phone onboarding skip remains optional and distinct from verification',
      () {
    final authRouter = File(
      'lib/welcom_pages/auth_router/auth_router_widget.dart',
    ).readAsStringSync();
    final phoneInput = File(
      'lib/welcom_pages/phone_number_input/phone_number_input_widget.dart',
    ).readAsStringSync();

    expect(authRouter, contains('walletRow.isPhoneVerified != true'));
    expect(authRouter, contains('walletRow.phoneOnboardingSkippedAt == null'));
    expect(phoneInput, contains("text: 'Skip for Now'"));
    expect(phoneInput, contains("'phone_onboarding_skipped_at':"));
    expect(
      phoneInput,
      contains('BiometricVerificationWidget.routeName'),
    );

    final skipStart = phoneInput.indexOf("text: 'Skip for Now'");
    final skipActionStart = phoneInput.lastIndexOf('onPressed:', skipStart);
    final skipBlock = phoneInput.substring(skipActionStart, skipStart);
    expect(skipBlock, isNot(contains('UserConsentsTable().insert')));
    expect(skipBlock, isNot(contains("'is_phone_verified': true")));
  });

  test('phone submission retains SMS consent and verification flow', () {
    final phoneInput = File(
      'lib/welcom_pages/phone_number_input/phone_number_input_widget.dart',
    ).readAsStringSync();

    expect(phoneInput, contains("'feature': 'sms_terms'"));
    expect(phoneInput, contains("'accepted_sms_terms': true"));
    expect(phoneInput, contains('PhoneNumberVerificationWidget.routeName'));
    expect(phoneInput, contains('See SMS Terms and Privacy Policy.'));

    final verification = File(
      'lib/welcom_pages/phone_number_verification/'
      'phone_number_verification_widget.dart',
    ).readAsStringSync();
    expect(
      RegExp("'phone_onboarding_skipped_at':\\s*null")
          .allMatches(verification)
          .length,
      greaterThanOrEqualTo(2),
    );
  });

  test('blank personal phone clears safely without entering verification', () {
    final personalInfo = File(
      'lib/emergancy_contact_information/personal_information/'
      'personal_information_widget.dart',
    ).readAsStringSync();

    expect(personalInfo, contains('if (edited.isEmpty)'));
    expect(personalInfo, contains("'is_phone_verified': false"));
    expect(personalInfo, contains("'phone_e164_hash': null"));
    expect(personalInfo, contains("(_model.changedPhone ?? '')"));
    expect(personalInfo, contains('.isNotEmpty &&'));
  });

  test('database change is additive and leaves existing rows untouched', () {
    final migration = File(
      'supabase/migrations/'
      '20260916210000_add_phone_onboarding_skipped_at.sql',
    ).readAsStringSync();

    expect(migration, contains('add column if not exists'));
    expect(migration, contains('phone_onboarding_skipped_at timestamptz'));
    expect(
        migration.toLowerCase(), isNot(contains('update public.decoy_wallet')));
  });
}
