import 'dart:convert';

import 'package:decoy_wallet_app/auth/supabase_auth/email_auth.dart';
import 'package:decoy_wallet_app/backend/supabase/supabase.dart';
import 'package:decoy_wallet_app/custom_code/actions/supa_email_sign_up.dart';
import 'package:decoy_wallet_app/custom_code/actions/supa_sign_up_with_redirect.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_link_service_test.dart' show linkSession;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockClient client;
  final requests = <http.Request>[];
  var target = 'recipient';
  var prompts = 0;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    client = MockClient((request) async {
      expect(request.url.host, 'test.invalid');
      requests.add(request);
      if (request.url.path == '/auth/v1/logout') return http.Response('', 204);
      if (request.url.path == '/auth/v1/signup') {
        return http.Response(
            jsonEncode({
              ...linkSession('recipient')['user'] as Map,
              'email_confirmed_at': null,
            }),
            200,
            headers: {'content-type': 'application/json'});
      }
      if (request.url.path == '/auth/v1/verify') {
        return http.Response(jsonEncode(linkSession(target)), 200,
            headers: {'content-type': 'application/json'});
      }
      throw StateError('Unexpected synthetic auth request');
    });
    await Supabase.initialize(
      url: 'https://test.invalid',
      anonKey: 'synthetic-anon',
      httpClient: client,
      debug: false,
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: false,
        detectSessionInUri: false,
        authFlowType: AuthFlowType.implicit,
        localStorage: EmptyLocalStorage(),
      ),
    );
  });
  tearDownAll(() => Supabase.instance.dispose());
  setUp(() async {
    await SupaFlow.client.auth.signOut();
    SupaFlow.configureAuthLinks(
        url: 'https://test.invalid',
        anonKey: 'synthetic-anon',
        clientFactory: () => client);
    requests.clear();
    target = 'recipient';
    prompts = 0;
  });

  for (final entry in ['standard action', 'redirect action', 'auth manager']) {
    Future<void> signup() async {
      switch (entry) {
        case 'standard action':
          expect(
              await supaEmailSignUp('recipient@example.invalid',
                  'synthetic-password', 'https://test.invalid/verify'),
              'ok');
        case 'redirect action':
          await supaSignUpWithRedirect(
              'recipient@example.invalid', 'synthetic-password');
        case 'auth manager':
          await emailCreateAccountFunc(
              'recipient@example.invalid', 'synthetic-password');
      }
    }

    test('$entry signup confirmation never asks for the email again', () async {
      await signup();
      expect(SupaFlow.client.auth.currentSession, isNull);
      final result = await SupaFlow.authLinks.accept(
        Uri.parse('/loginPage?type=signup&token_hash=synthetic'),
        requestEmail: () async {
          prompts++;
          return null;
        },
        mayContinue: () => true,
      );
      expect(prompts, 0);
      expect(result?.userId, 'recipient');
      expect(SupaFlow.client.auth.currentUser?.id, 'recipient');
    });

    test('$entry signup still rejects another account', () async {
      await signup();
      target = 'other';
      await expectLater(
        SupaFlow.authLinks.accept(
          Uri.parse('/loginPage?type=signup&token_hash=wrong'),
          requestEmail: () async {
            prompts++;
            return 'other@example.invalid';
          },
          mayContinue: () => true,
        ),
        throwsA(isA<AuthException>()),
      );
      expect(prompts, 0);
      expect(SupaFlow.client.auth.currentSession, isNull);
    });
  }
}
