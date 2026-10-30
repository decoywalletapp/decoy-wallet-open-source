import 'dart:convert';

import 'package:decoy_wallet_app/auth/supabase_auth/email_auth.dart';
import 'package:decoy_wallet_app/backend/public_config.dart';
import 'package:decoy_wallet_app/backend/supabase/supabase.dart';
import 'package:decoy_wallet_app/custom_code/actions/supa_email_sign_up.dart';
import 'package:decoy_wallet_app/custom_code/actions/supa_sign_up_with_redirect.dart';
import 'package:decoy_wallet_app/services/account_balance.dart';
import 'package:decoy_wallet_app/services/account_balance_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final requests = <http.Request>[];
  late MockClient client;
  var rejectSignup = false;
  const id = '33333333-3333-4333-8333-333333333333';
  const email = 'balance-test@example.invalid';
  const password = 'test-only-password';
  const redirect = 'https://test.invalid/verify';

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    client = MockClient((request) async {
      requests.add(request);
      expect(request.url.path, '/auth/v1/signup');
      expect(request.method, 'POST');
      if (rejectSignup) {
        return http.Response(jsonEncode({'msg': 'signup rejected'}), 400);
      }
      return http.Response(
          jsonEncode({
            'id': id,
            'aud': 'authenticated',
            'role': 'authenticated',
            'email': email,
            'created_at': '2026-10-04T00:00:00Z',
            'app_metadata': <String, dynamic>{},
            'user_metadata': (jsonDecode(request.body) as Map)['data'],
          }),
          200,
          headers: {'content-type': 'application/json'});
    });
    await Supabase.initialize(
      url: 'https://test.invalid',
      anonKey: 'test-key',
      debug: false,
      httpClient: client,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
        autoRefreshToken: false,
        detectSessionInUri: false,
        localStorage: EmptyLocalStorage(),
      ),
    );
  });
  tearDownAll(() => Supabase.instance.dispose());
  setUp(() {
    SupaFlow.configureAuthLinks(
      url: 'https://test.invalid',
      anonKey: 'test-key',
      clientFactory: () => client,
    );
    requests.clear();
    rejectSignup = false;
  });

  void checkRequest({String? expectedRedirect}) {
    expect(requests, hasLength(1));
    final request = requests.single;
    final data = jsonDecode(request.body) as Map<String, dynamic>;
    expect(data['email'], email);
    expect(data['password'], password);
    expect(
        data['data'],
        accountBalancePilotEnabled
            ? {'decoy_balance_storage': 'account_v1'}
            : null);
    expect(request.url.queryParameters['redirect_to'], expectedRedirect);
    expect(Supabase.instance.client.auth.currentSession, isNull);
  }

  test(
      'normal signup adds only the balance preference and preserves the redirect',
      () async {
    expect(await supaEmailSignUp(' $email ', ' $password ', redirect), 'ok');
    checkRequest(expectedRedirect: redirect);
  });

  test('configured redirect signup preserves email confirmation destination',
      () async {
    await supaSignUpWithRedirect(email, password);
    checkRequest(expectedRedirect: kEmailConfirmDeepLink);
  });

  test('basic signup still returns no signed-in user before confirmation',
      () async {
    expect(await emailCreateAccountFunc(email, password), isNull);
    checkRequest();
  });

  test('existing signup validation does not send invalid credentials',
      () async {
    expect(await supaEmailSignUp('', password, redirect),
        'ERR: missing email or password');
    expect(await supaEmailSignUp(email, 'short', redirect),
        'ERR: password too short');
    expect(requests, isEmpty);
  });

  test('signup failures do not create sessions or balance requests', () async {
    rejectSignup = true;
    expect(
        await supaEmailSignUp(email, password, redirect), startsWith('ERR:'));
    expect(requests, hasLength(1));
    expect(Supabase.instance.client.auth.currentSession, isNull);
  });

  test(
      'a signed-out remote never treats a metadata preference as authentication',
      () {
    final remote = SupabaseBalanceRemote(Supabase.instance.client);
    expect(remote.startsWithAccountBalance(id), false);
  });
}
