import 'dart:io';

import 'package:decoy_wallet_app/backend/environment_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const validStaging = DecoyBackendEnvironmentSnapshot(
    backendEnvironment: 'staging',
    supabaseUrl: 'https://dxsihfandgbrkreeokkm.supabase.co',
    firebaseFunctionsBaseUrl:
        'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/staging-api/firebase',
    alertBaseUrl:
        'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/staging-api/alerts',
    dataKeyBaseUrl:
        'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/staging-api/data-key',
    paymentBaseUrl:
        'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/staging-api/payment',
    verifyBaseUrl:
        'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/verify-link',
    emailConfirmUrl: '',
    emailConfirmDeepLink: 'decoywalletapp://confirm-email',
  );

  const validProduction = DecoyBackendEnvironmentSnapshot(
    backendEnvironment: 'production',
    supabaseUrl: 'https://production-project.supabase.co',
    firebaseFunctionsBaseUrl: 'https://firebase-production.example.com',
    alertBaseUrl: 'https://alerts-production.example.com',
    dataKeyBaseUrl: 'https://data-key-production.example.com',
    paymentBaseUrl: 'https://payment-production.example.com',
    verifyBaseUrl: 'https://verify-production.example.com',
    emailConfirmUrl: 'https://verify-production.example.com/confirm-email',
    emailConfirmDeepLink: 'decoywalletapp://confirm-email',
  );

  test('staging build accepts fully isolated staging routes', () {
    expect(inspectDecoyBackendEnvironment(validStaging), isEmpty);
  });

  test('staging build rejects localhost email confirmation URLs', () {
    final problems = inspectDecoyBackendEnvironment(
      const DecoyBackendEnvironmentSnapshot(
        backendEnvironment: 'staging',
        supabaseUrl: 'https://dxsihfandgbrkreeokkm.supabase.co',
        firebaseFunctionsBaseUrl:
            'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/staging-api/firebase',
        alertBaseUrl:
            'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/staging-api/alerts',
        dataKeyBaseUrl:
            'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/staging-api/data-key',
        paymentBaseUrl:
            'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/staging-api/payment',
        verifyBaseUrl:
            'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/verify-link',
        emailConfirmUrl: 'http://localhost:54321/auth/v1/verify',
        emailConfirmDeepLink: 'decoywalletapp://confirm-email',
      ),
    );

    expect(problems, contains('DECOY_EMAIL_CONFIRM_URL must be an https URL'));
    expect(problems, contains('DECOY_EMAIL_CONFIRM_URL points at localhost'));
  });

  test('staging build rejects production helper routes', () {
    final problems = inspectDecoyBackendEnvironment(
      const DecoyBackendEnvironmentSnapshot(
        backendEnvironment: 'staging',
        supabaseUrl: 'https://dxsihfandgbrkreeokkm.supabase.co',
        firebaseFunctionsBaseUrl:
            'https://us-central1-decoy-wallet.cloudfunctions.net',
        alertBaseUrl:
            'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/staging-api/alerts',
        dataKeyBaseUrl:
            'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/staging-api/data-key',
        paymentBaseUrl:
            'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/staging-api/payment',
        verifyBaseUrl:
            'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/verify-link',
        emailConfirmUrl: '',
        emailConfirmDeepLink: 'decoywalletapp://confirm-email',
      ),
    );

    expect(
      problems,
      contains(
        'DECOY_FIREBASE_FUNCTIONS_BASE_URL must point at staging-api/firebase for staging builds',
      ),
    );
  });

  test('staging build rejects non-staging verify route', () {
    final problems = inspectDecoyBackendEnvironment(
      const DecoyBackendEnvironmentSnapshot(
        backendEnvironment: 'staging',
        supabaseUrl: 'https://dxsihfandgbrkreeokkm.supabase.co',
        firebaseFunctionsBaseUrl:
            'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/staging-api/firebase',
        alertBaseUrl:
            'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/staging-api/alerts',
        dataKeyBaseUrl:
            'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/staging-api/data-key',
        paymentBaseUrl:
            'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/staging-api/payment',
        verifyBaseUrl: 'https://verify-production.example.com/confirm-email',
        emailConfirmUrl: '',
        emailConfirmDeepLink: 'decoywalletapp://confirm-email',
      ),
    );

    expect(
      problems,
      contains(
        'DECOY_VERIFY_BASE_URL must point at /functions/v1/verify-link on dxsihfandgbrkreeokkm.supabase.co for staging builds',
      ),
    );
  });

  test('production build rejects staging Supabase routes', () {
    final problems = inspectDecoyBackendEnvironment(
      const DecoyBackendEnvironmentSnapshot(
        backendEnvironment: 'production',
        supabaseUrl: 'https://dxsihfandgbrkreeokkm.supabase.co',
        firebaseFunctionsBaseUrl:
            'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/staging-api/firebase',
        alertBaseUrl: 'https://alerts-production.example.com',
        dataKeyBaseUrl: 'https://data-key-production.example.com',
        paymentBaseUrl: 'https://payment-production.example.com',
        verifyBaseUrl: 'https://verify-production.example.com',
        emailConfirmUrl: 'https://verify-production.example.com/confirm-email',
        emailConfirmDeepLink: 'decoywalletapp://confirm-email',
      ),
    );

    expect(problems,
        contains('DECOY_SUPABASE_URL points at the staging Supabase project'));
    expect(
      problems,
      contains(
        'DECOY_FIREBASE_FUNCTIONS_BASE_URL points at the staging Supabase project',
      ),
    );
    expect(
      problems,
      contains(
          'DECOY_FIREBASE_FUNCTIONS_BASE_URL points at a staging-only helper route'),
    );
  });

  test('unknown backend environment is rejected', () {
    final problems = inspectDecoyBackendEnvironment(
      const DecoyBackendEnvironmentSnapshot(
        backendEnvironment: 'demo',
        supabaseUrl: 'https://dxsihfandgbrkreeokkm.supabase.co',
        firebaseFunctionsBaseUrl:
            'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/staging-api/firebase',
        alertBaseUrl:
            'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/staging-api/alerts',
        dataKeyBaseUrl:
            'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/staging-api/data-key',
        paymentBaseUrl:
            'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/staging-api/payment',
        verifyBaseUrl:
            'https://dxsihfandgbrkreeokkm.supabase.co/functions/v1/verify-link',
        emailConfirmUrl: '',
        emailConfirmDeepLink: 'decoywalletapp://confirm-email',
      ),
    );

    expect(
        problems, contains('DECOY_BACKEND_ENV must be production or staging'));
  });

  test('AuthRouter waits for active Supabase session values', () {
    final source = File(
      'lib/welcom_pages/auth_router/auth_router_widget.dart',
    ).readAsStringSync();

    expect(source, contains('_waitForActiveSession'));
    expect(source, contains('_routingJwtToken'));
    expect(source, contains('_routingUserId'));
    expect(source, contains('_routingUserEmail'));
    expect(source, contains('_failAuthRouting'));
    expect(source, contains('_runAuthStep'));
    expect(source, contains('Staging auth stopped at:'));
    expect(source, contains('Decoy wallet account row was not available'));
    expect(source, isNot(contains('jwt: currentJwtToken')));
    expect(source, isNot(contains('userId: currentUserUid')));
  });

  test('environment guard runs before Supabase initialization', () {
    final source = File('lib/main.dart').readAsStringSync();
    final guardIndex = source.indexOf('validateDecoyBackendEnvironment()');
    final supaIndex = source.indexOf('await SupaFlow.initialize()');

    expect(guardIndex, greaterThan(-1));
    expect(supaIndex, greaterThan(-1));
    expect(guardIndex, lessThan(supaIndex));
  });

  test('production baseline is still valid for the guard helper', () {
    expect(inspectDecoyBackendEnvironment(validProduction), isEmpty);
  });

  test('staging helper calls can satisfy protected Supabase edge gateway', () {
    final source =
        File('lib/backend/api_requests/api_calls.dart').readAsStringSync();

    expect(source, contains('_isSupabaseEdgeUrl'));
    expect(source, contains('_bearerTokenForUrl'));
    expect(source, contains('_jsonHeadersForUrl'));
    expect(source, contains('_acceptHeadersForUrl'));
    expect(
      source,
      contains("requiredPublicConfig('DECOY_SUPABASE_ANON_KEY'"),
    );

    expect(
      source,
      contains("headers: _jsonHeadersForUrl(apiUrl, jwt: jwt)"),
    );
    expect(source, contains('headers: _acceptHeadersForUrl(apiUrl)'));

    for (final callName in [
      'SendVerificationCode',
      'CheckVerificationCode',
      'btcChartOneYear',
      'sendSupportTicket',
      'getPhoneHash',
      'getEmailHash',
    ]) {
      expect(source, contains("callName: '$callName'"));
    }
  });

  test('staging backend runbook keeps Supabase gateway JWT enabled', () {
    final source = File('staging_backend/README.md').readAsStringSync();

    expect(source, contains('gateway JWT verification enabled'));
    expect(source, contains('user session JWT'));
    expect(source, contains('staging Supabase anon JWT'));
    expect(
      source,
      isNot(
        contains(
          'with JWT verification disabled at the Supabase edge-function gateway',
        ),
      ),
    );
  });
}
