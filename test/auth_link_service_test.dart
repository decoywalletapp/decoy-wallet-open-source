import 'dart:async';
import 'dart:convert';

import 'package:decoy_wallet_app/auth/auth_link_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Map<String, dynamic> linkSession(String id, {String? email}) {
  String part(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return {
    'access_token': '${part({'alg': 'HS256'})}.${part({
          'sub': id,
          'iat': now,
          'exp': now + 7200,
        })}.synthetic',
    'refresh_token': 'synthetic-$id',
    'expires_in': 7200,
    'token_type': 'bearer',
    'user': {
      'id': id,
      'email': email ?? '$id@example.invalid',
      'email_confirmed_at': '2026-01-01T00:00:00Z',
      'aud': 'authenticated',
      'app_metadata': {},
      'user_metadata': {},
      'created_at': '2026-01-01T00:00:00Z',
    },
  };
}

void main() {
  late GoTrueClient auth;
  late AuthLinkService links;
  final requests = <http.Request>[];
  final authEvents = <AuthState>[];
  StreamSubscription<AuthState>? subscription;
  var candidate = 'recipient';
  String? candidateEmail;
  var accessOwner = 'recipient';
  var allowed = true;
  var prompts = 0;
  var status = 200;
  var malformed = false;
  Completer<void>? gate;

  Future<AcceptedAuthLink?> accept(String uri,
          {String? email = 'recipient@example.invalid'}) =>
      links.accept(Uri.parse(uri),
          requestEmail: () async {
            prompts++;
            return email;
          },
          mayContinue: () => allowed);

  setUp(() {
    candidate = accessOwner = 'recipient';
    candidateEmail = null;
    allowed = true;
    prompts = 0;
    status = 200;
    malformed = false;
    gate = null;
    requests.clear();
    authEvents.clear();
    final transport = MockClient((request) async {
      expect(request.url.host, 'audit.invalid');
      requests.add(request);
      if (request.url.path == '/auth/v1/logout') return http.Response('', 204);
      final replyCandidate = candidate;
      final replyEmail = candidateEmail;
      if (gate != null) await gate!.future;
      final body = request.url.path == '/auth/v1/user'
          ? linkSession(accessOwner)['user']
          : linkSession(replyCandidate, email: replyEmail);
      return http.Response(malformed ? 'not json' : jsonEncode(body), status,
          headers: {'content-type': 'application/json'});
    });
    auth = GoTrueClient(
        url: 'https://audit.invalid/auth/v1',
        autoRefreshToken: false,
        httpClient: transport,
        flowType: AuthFlowType.implicit);
    links = AuthLinkService(
        auth: auth,
        authUrl: 'https://audit.invalid/auth/v1',
        anonKey: 'synthetic-anon',
        clientFactory: () => transport);
    subscription = auth.onAuthStateChange.listen(authEvents.add);
  });
  tearDown(() async {
    await subscription?.cancel();
    auth.dispose();
  });

  Future<Session> signedIn() async {
    await auth.setInitialSession(jsonEncode(linkSession('recipient')));
    await Future<void>.delayed(Duration.zero);
    authEvents.clear();
    return auth.currentSession!;
  }

  for (final credentials in [
    '?type=recovery&token_hash=synthetic',
    '?type=recovery&tokenHash=synthetic',
    '#type=recovery&token=synthetic',
    '?type=recovery&refresh_token=synthetic',
    '#?type=recovery&refreshToken=synthetic',
    '?type=recovery&refreshToken=synthetic&accessToken=synthetic',
  ]) {
    test('different account is rejected before shared adoption: $credentials',
        () async {
      final original = await signedIn();
      candidate = accessOwner = 'other';
      await expectLater(
          accept('/loginPage$credentials'), throwsA(isA<AuthException>()));
      expect(auth.currentSession, same(original));
      expect(auth.currentUser!.id, 'recipient');
      expect(authEvents, isEmpty);
      expect(prompts, 0);
    });
    test('same account remains supported: $credentials', () async {
      await signedIn();
      final result = await accept('/loginPage$credentials');
      expect(result!.userId, 'recipient');
      expect(links.isCurrent(result), isTrue);
      expect(prompts, 0);
    });
  }

  for (final type in [
    'signup',
    'magiclink',
    'recovery',
    'invite',
    'email_change'
  ]) {
    test('cross-device $type requires matching recipient-entered email',
        () async {
      final result = await accept('/loginPage?type=$type&token_hash=synthetic',
          email: '  RECIPIENT@example.invalid  ');
      expect(result!.userId, 'recipient');
      expect(prompts, 1);
    });
    test('wrong intended email cannot adopt a $type session', () async {
      candidate = 'other';
      await expectLater(accept('/loginPage?type=$type&token_hash=synthetic'),
          throwsA(isA<AuthException>()));
      expect(auth.currentSession, isNull);
      expect(authEvents, isEmpty);
    });
  }

  test('email change binds stable user ID, not the old email', () async {
    await signedIn();
    candidateEmail = 'new-address@example.invalid';
    final result =
        await accept('/loginPage?type=email_change&token_hash=synthetic');
    expect(result!.userId, 'recipient');
    expect(auth.currentUser!.email, candidateEmail);
    expect(prompts, 0);
  });

  for (final email in <String?>[null, '', ' ']) {
    test('cancelled or empty confirmation performs no exchange: $email',
        () async {
      expect(
          await accept('/loginPage?type=recovery&refreshToken=synthetic',
              email: email),
          isNull);
      expect(requests, isEmpty);
      expect(auth.currentSession, isNull);
    });
  }

  for (final query in [
    '?token=one&token_hash=two',
    '?refreshToken=one#refresh_token=two',
    '?type=recovery&type=signup&token=one',
    '?token=one&refreshToken=two',
    '?type=unknown&token=one',
    '?accessToken=one',
  ]) {
    test('conflicting or incomplete callback fails before network: $query',
        () async {
      final original = await signedIn();
      await expectLater(Future.sync(() => accept('/loginPage$query')),
          throwsA(isA<AuthException>()));
      expect(requests, isEmpty);
      expect(auth.currentSession, same(original));
    });
  }

  test('access and refresh credentials must identify the same account',
      () async {
    final original = await signedIn();
    accessOwner = 'other';
    await expectLater(
        accept(
            '/loginPage?type=recovery&refreshToken=synthetic&accessToken=synthetic'),
        throwsA(isA<AuthException>()));
    expect(auth.currentSession, same(original));
    expect(
        requests.map((r) => r.url.path), ['/auth/v1/token', '/auth/v1/user']);
  });

  for (final cancellation in ['logout', 'new login', 'decoy']) {
    test('late verification cannot override $cancellation', () async {
      final original = await signedIn();
      gate = Completer<void>();
      final result = accept('/loginPage?type=recovery&refreshToken=synthetic');
      await Future<void>.delayed(Duration.zero);
      if (cancellation == 'logout') {
        links.cancelPending();
        await auth.signOut();
      } else if (cancellation == 'new login') {
        await auth.setInitialSession(jsonEncode(linkSession('new-login')));
      } else {
        allowed = false;
      }
      final before = auth.currentSession;
      gate!.complete();
      expect(await result, isNull);
      expect(auth.currentSession, same(before));
      if (cancellation == 'decoy') expect(before, same(original));
    });
  }

  test('newer link supersedes older delayed verification', () async {
    await signedIn();
    gate = Completer<void>();
    final firstGate = gate!;
    final old = accept('/loginPage?type=recovery&refreshToken=old');
    await Future<void>.delayed(Duration.zero);
    gate = null;
    final current = await accept('/loginPage?type=recovery&refreshToken=new');
    final session = auth.currentSession;
    firstGate.complete();
    expect(await old, isNull);
    expect(auth.currentSession, same(session));
    expect(links.isCurrent(current!), isTrue);
  });

  test('equivalent aliases exchange once and completed links do not replay',
      () async {
    await signedIn();
    gate = Completer<void>();
    final first = accept('/loginPage?type=recovery&refreshToken=synthetic');
    final duplicate =
        accept('/loginPage#refresh_token=synthetic&type=recovery');
    gate!.complete();
    expect(await duplicate, same(await first));
    expect(requests, hasLength(1));
    expect(await accept('/loginPage?type=recovery&refresh_token=synthetic'),
        isNull);
    expect(requests, hasLength(1));
  });

  for (final badResponse in ['rejected', 'malformed']) {
    test('provider $badResponse response preserves current session', () async {
      final original = await signedIn();
      status = badResponse == 'rejected' ? 401 : 200;
      malformed = badResponse == 'malformed';
      await expectLater(
          accept('/loginPage?type=recovery&refreshToken=synthetic'),
          throwsA(isA<Exception>()));
      expect(auth.currentSession, same(original));
      expect(authEvents, isEmpty);
    });
  }

  test('decoy state ignores a callback without prompting or network', () async {
    allowed = false;
    expect(await accept('/loginPage?type=recovery&refreshToken=synthetic'),
        isNull);
    expect(prompts, 0);
    expect(requests, isEmpty);
  });
}
