import 'dart:async';
import 'dart:convert';

import 'package:decoy_wallet_app/auth/auth_link_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_link_service_test.dart' show linkSession;

void main() {
  late GoTrueClient auth;
  late AuthLinkService service;
  late MockClient client;
  late DateTime now;
  final calls = <http.Request>[];
  final signupGates = <String, Completer<void>>{};
  final failedSignups = <String>{};
  final usedTokens = <String>{};
  var target = 'recipient';
  var confirmed = true;
  var allowed = true;
  var prompts = 0;
  Completer<void>? verificationGate;

  AuthLinkService newService() => AuthLinkService(
      auth: auth,
      authUrl: 'https://test.invalid/auth/v1',
      anonKey: 'synthetic-anon',
      clientFactory: () => client,
      now: () => now);
  Future<AuthResponse> signup([String email = 'recipient@example.invalid']) =>
      service.signUp(email: email, password: 'synthetic-password');
  Future<AcceptedAuthLink?> accept(
          [String payload = '?type=signup&token_hash=synthetic']) =>
      service.accept(Uri.parse('/loginPage$payload'),
          mayContinue: () => allowed,
          requestEmail: () async {
            prompts++;
            return 'other@example.invalid';
          });

  setUp(() {
    now = DateTime.utc(2026, 10, 30);
    calls.clear();
    signupGates.clear();
    failedSignups.clear();
    usedTokens.clear();
    target = 'recipient';
    confirmed = allowed = true;
    prompts = 0;
    verificationGate = null;
    client = MockClient((request) async {
      expect(request.url.host, 'test.invalid');
      calls.add(request);
      if (request.url.path.endsWith('/signup')) {
        final email = jsonDecode(request.body)['email'] as String;
        final fail = failedSignups.contains(email);
        await signupGates[email]?.future;
        return http.Response(
            fail
                ? '{"msg":"synthetic rejection"}'
                : jsonEncode({
                    ...linkSession('recipient')['user'] as Map,
                    'email': email,
                    'email_confirmed_at': null
                  }),
            fail ? 400 : 200,
            headers: {'content-type': 'application/json'});
      }
      if (request.url.path.endsWith('/logout')) return http.Response('', 204);
      if (request.url.path.endsWith('/recover'))
        return http.Response('{}', 200);
      if (request.url.path.endsWith('/verify')) {
        final token = jsonDecode(request.body)['token_hash'] as String;
        if (!usedTokens.add(token)) return http.Response('{"msg":"used"}', 403);
      }
      final reply = linkSession(target);
      if (!confirmed) {
        reply['user'] = <String, dynamic>{
          ...reply['user'] as Map,
          'email_confirmed_at': null,
        };
      }
      await verificationGate?.future;
      return http.Response(
          jsonEncode(
              request.url.path.endsWith('/user') ? reply['user'] : reply),
          200,
          headers: {'content-type': 'application/json'});
    });
    auth = GoTrueClient(
        url: 'https://test.invalid/auth/v1',
        autoRefreshToken: false,
        httpClient: client,
        flowType: AuthFlowType.implicit);
    service = newService();
  });
  tearDown(() => auth.dispose());

  for (final payload in [
    '?type=signup&token_hash=synthetic',
    '?type=signup&tokenHash=synthetic',
    '#type=signup&token=synthetic',
    '?type=signup&refresh_token=synthetic',
    '#?type=signup&refreshToken=synthetic',
    '?type=signup&refreshToken=synthetic&accessToken=synthetic',
    '?token_hash=synthetic',
  ]) {
    test('locally submitted signup accepts without re-entry: $payload',
        () async {
      await signup('  RECIPIENT@example.invalid  ');
      final result = await accept(payload);
      expect(result?.userId, 'recipient');
      expect(prompts, 0);
    });
    test('local signup cannot be overridden by another account: $payload',
        () async {
      await signup();
      target = 'other';
      await expectLater(accept(payload), throwsA(isA<AuthException>()));
      expect(prompts, 0);
      expect(auth.currentSession, isNull);
    });
  }

  for (final context in ['none', 'restart', 'expired', 'cancelled', 'failed']) {
    test('$context context goes to normal login without consuming a retry',
        () async {
      if (context != 'none') await signup();
      if (context == 'restart') service = newService();
      if (context == 'expired') now = now.add(const Duration(minutes: 15));
      if (context == 'cancelled') service.cancelPending();
      if (context == 'failed') {
        failedSignups.add('recipient@example.invalid');
        await expectLater(signup(), throwsA(isA<AuthException>()));
      }
      await expectLater(
          accept(
              '?type=signup&token_hash=once&email=recipient@example.invalid'),
          throwsA(isA<AuthLinkSignInRequired>()));
      expect(prompts, 0);
      expect(auth.currentSession, isNull);
      expect(await accept('?type=signup&token_hash=once&email=other@invalid'),
          isNull);
      expect(usedTokens, {'once'});
      // Confirmation has finished. The one-time link is not needed to log in.
      await auth.signInWithPassword(
          email: 'recipient@example.invalid', password: 'synthetic-password');
      expect(auth.currentUser?.id, 'recipient');
    });
  }

  test('wrong link leaves the intended signup usable', () async {
    await signup();
    target = 'other';
    await expectLater(
        accept('?type=signup&token_hash=wrong'), throwsA(isA<AuthException>()));
    target = 'recipient';
    expect(
        (await accept('?type=signup&token_hash=right'))?.userId, 'recipient');
    expect(prompts, 0);
  });

  test('signup intent cannot authorize a recovery session', () async {
    await signup();
    await expectLater(accept('?type=recovery&token_hash=other-purpose'),
        throwsA(isA<AuthException>()));
    expect(prompts, 1);
    expect(auth.currentSession, isNull);
  });

  test('recovery intent cannot authorize signup', () async {
    await service.sendPasswordResetEmail('recipient@example.invalid');
    await expectLater(accept(), throwsA(isA<AuthLinkSignInRequired>()));
    expect(prompts, 0);
    expect(auth.currentSession, isNull);
  });

  for (final cancellation in ['logout', 'new signup', 'new login', 'decoy']) {
    test('late signup verification cannot override $cancellation', () async {
      await signup();
      verificationGate = Completer<void>();
      final pending = accept();
      await Future<void>.delayed(Duration.zero);
      if (cancellation == 'logout') service.cancelPending();
      if (cancellation == 'new signup') await signup('other@example.invalid');
      if (cancellation == 'new login') {
        await auth.setInitialSession(jsonEncode(linkSession('other')));
      }
      if (cancellation == 'decoy') allowed = false;
      final before = auth.currentSession;
      verificationGate!.complete();
      expect(await pending, isNull);
      expect(auth.currentSession, same(before));
      expect(prompts, 0);
    });
  }

  test('a delayed older signup cannot replace the newest intent', () async {
    final gate = signupGates['other@example.invalid'] = Completer<void>();
    final old = signup('other@example.invalid');
    await signup();
    gate.complete();
    await old;
    expect((await accept())?.userId, 'recipient');
    expect(prompts, 0);
  });

  test('cancelled delayed signup cannot resurrect intent', () async {
    final gate = signupGates['recipient@example.invalid'] = Completer<void>();
    final pending = signup();
    service.cancelPending();
    gate.complete();
    await pending;
    await expectLater(accept(), throwsA(isA<AuthLinkSignInRequired>()));
    expect(auth.currentSession, isNull);
  });

  test('expiry during verification uses normal login rather than adoption',
      () async {
    await signup();
    verificationGate = Completer<void>();
    final result = accept();
    final checked = expectLater(result, throwsA(isA<AuthLinkSignInRequired>()));
    await Future<void>.delayed(Duration.zero);
    now = now.add(const Duration(minutes: 15));
    verificationGate!.complete();
    await checked;
    expect(auth.currentSession, isNull);
    expect(prompts, 0);
  });

  for (final local in [false, true]) {
    test('unconfirmed provider response is never called confirmed: $local',
        () async {
      if (local) await signup();
      confirmed = false;
      await expectLater(
          accept(),
          throwsA(isA<AuthException>()
              .having((e) => e.message, 'message', contains('could not'))));
      expect(auth.currentSession, isNull);
      expect(prompts, 0);
    });
  }

  test('signed-in account remains authoritative over a remembered signup',
      () async {
    await signup();
    await auth.setInitialSession(jsonEncode(linkSession('other')));
    final original = auth.currentSession;
    await expectLater(accept(), throwsA(isA<AuthException>()));
    expect(auth.currentSession, same(original));
    expect(prompts, 0);
  });

  test('equivalent signup callbacks exchange and route once', () async {
    await signup();
    verificationGate = Completer<void>();
    final first = accept('?type=signup&tokenHash=once');
    final repeat = accept('#type=signup&token_hash=once');
    verificationGate!.complete();
    expect(await repeat, same(await first));
    expect(usedTokens, {'once'});
    expect(await accept('?type=signup&token_hash=once'), isNull);
    expect(prompts, 0);
  });
}
