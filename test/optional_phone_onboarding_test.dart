import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('verified onboarding email link starts permission onboarding', () {
    final verifyAnyLink = File(
      'lib/custom_code/widgets/verify_any_link.dart',
    ).readAsStringSync();

    expect(verifyAnyLink, contains('BiometricVerificationWidget.routeName'));
    expect(verifyAnyLink, isNot(contains('PhoneNumberInputWidget.routeName')));
  });

  test('phone action buttons are nudged upward without changing behavior', () {
    final phoneInput = File(
      'lib/welcom_pages/phone_number_input/phone_number_input_widget.dart',
    ).readAsStringSync();

    expect(phoneInput, contains('offset: const Offset(0.0, -16.0)'));
    expect(phoneInput, contains("text: 'Save Phone Number'"));
    expect(phoneInput, contains("text: 'Skip for Now'"));
  });

  test('missing phone never blocks permission onboarding', () {
    final authRouter = File(
      'lib/welcom_pages/auth_router/auth_router_widget.dart',
    ).readAsStringSync();

    expect(authRouter, isNot(contains('walletRow.isPhoneVerified != true')));
    expect(authRouter, isNot(contains('PhoneNumberInputWidget.routeName')));
    expect(authRouter, contains('BiometricVerificationWidget.routeName'));
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
      RegExp(
        "'phone_onboarding_skipped_at':\\s*null",
      ).allMatches(verification).length,
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
      migration.toLowerCase(),
      isNot(contains('update public.decoy_wallet')),
    );
  });

  test('permission onboarding resumes at the exact unfinished screen', () {
    final authRouter = File(
      'lib/welcom_pages/auth_router/auth_router_widget.dart',
    ).readAsStringSync();
    final biometrics = File(
      'lib/welcom_pages/biometric_verification/biometric_verification_widget.dart',
    ).readAsStringSync();
    final notifications = File(
      'lib/welcom_pages/enable_notifications/enable_notifications_widget.dart',
    ).readAsStringSync();
    final location = File(
      'lib/welcom_pages/location_authorization/location_authorization_widget.dart',
    ).readAsStringSync();
    final migration = File(
      'supabase/migrations/20260916224000_add_permissions_onboarding_step.sql',
    ).readAsStringSync();

    expect(authRouter, contains("case 'notifications':"));
    expect(authRouter, contains("case 'location':"));
    expect(authRouter, contains("case 'biometrics':"));
    expect(
      biometrics,
      contains("'permissions_onboarding_step': 'notifications'"),
    );
    expect(
      notifications,
      contains("'permissions_onboarding_step': 'location'"),
    );
    expect(location, contains("'permissions_onboarding_step': 'complete'"));
    expect(migration, contains('permissions_onboarding_step text'));
  });

  test('permission onboarding pages remain reachable on short screens', () {
    for (final path in <String>[
      'lib/welcom_pages/biometric_verification/'
          'biometric_verification_widget.dart',
      'lib/welcom_pages/enable_notifications/'
          'enable_notifications_widget.dart',
      'lib/welcom_pages/location_authorization/'
          'location_authorization_widget.dart',
    ]) {
      final page = File(path).readAsStringSync();
      expect(page, contains('SingleChildScrollView'));
      expect(page, contains('AlwaysScrollableScrollPhysics'));
      expect(page, contains('ClampingScrollPhysics'));
      expect(page, contains('decoyBottomActionPadding(context)'));
      expect(page, contains('24.0, 0.0, 24.0, 140.0'));
      expect(
        page,
        contains('BoxConstraints(minHeight: constraints.maxHeight)'),
      );
      expect(page, contains('permissionPageBottomPadding'));
    }
  });

  test('personal contact phone changes retain phone verification route', () {
    final personalInfo = File(
      'lib/emergancy_contact_information/personal_information/'
      'personal_information_widget.dart',
    ).readAsStringSync();
    final phoneInput = File(
      'lib/welcom_pages/phone_number_input/phone_number_input_widget.dart',
    ).readAsStringSync();

    expect(personalInfo, contains('PhoneNumberInputWidget.routeName'));
    expect(personalInfo, contains("'initialPhone': serializeParam"));
    expect(phoneInput, contains('final String? initialPhone'));
    expect(phoneInput,
        contains("TextEditingController(text: widget.initialPhone ?? '')"));
    expect(phoneInput, contains('PhoneNumberVerificationWidget.routeName'));
  });
}
