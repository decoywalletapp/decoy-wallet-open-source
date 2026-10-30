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
  late DateTime clock;
  var resetStatus = 200;
  final resetGates = <String, Completer<void>>{};
  final resetStatuses = <String, int>{};

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
    clock = DateTime.utc(2026, 10, 25);
    resetStatus = 200;
    resetGates.clear();
    resetStatuses.clear();
    requests.clear();
    authEvents.clear();
    final transport = MockClient((request) async {
      expect(request.url.host, 'audit.invalid');
      requests.add(request);
      if (request.url.path == '/auth/v1/logout') return http.Response('', 204);
      if (request.url.path == '/auth/v1/recover') {
        final email = jsonDecode(request.body)['email'] as String;
        final responseStatus = resetStatuses[email] ?? resetStatus;
        final resetGate = resetGates[email];
        if (resetGate != null) await resetGate.future;
        return http.Response(
            responseStatus == 200 ? '{}' : '{"msg":"synthetic reset failure"}',
            responseStatus,
            headers: {'content-type': 'application/json'});
      }
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
        clientFactory: () => transport,
        now: () => clock);
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
      if (type == 'signup') {
        await expectLater(
            accept('/loginPage?type=$type&token_hash=synthetic'),
            throwsA(isA<AuthLinkSignInRequired>()));
        expect(prompts, 0);
        expect(auth.currentSession, isNull);
        return;
      }
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

  for (final credentials in [
    '?type=recovery&token_hash=local',
    '#type=recovery&tokenHash=local',
    '?type=recovery&refresh_token=local',
    '#?type=recovery&refreshToken=local',
    '?type=recovery&accessToken=local&refreshToken=local',
  ]) {
    test(
        'local recovery uses requested email without another prompt: $credentials',
        () async {
      await links.sendPasswordResetEmail('  RECIPIENT@example.invalid  ',
          redirectTo: 'https://audit.invalid/verify');
      expect(jsonDecode(requests.single.body)['email'],
          'RECIPIENT@example.invalid');
      expect(requests.single.url.queryParameters['redirect_to'],
          'https://audit.invalid/verify');
      final result = await accept('/loginPage$credentials', email: null);
      expect(result!.userId, 'recipient');
      expect(prompts, 0);
    });
    test('local recovery rejects wrong account before adoption: $credentials',
        () async {
      await links.sendPasswordResetEmail('recipient@example.invalid');
      candidate = accessOwner = 'other';
      await expectLater(
          accept('/loginPage$credentials', email: 'other@example.invalid'),
          throwsA(isA<AuthException>()));
      expect(prompts, 0);
      expect(auth.currentSession, isNull);
      expect(authEvents, isEmpty);
    });
  }

  for (final elapsed in [
    const Duration(minutes: 15),
    const Duration(hours: 1),
    const Duration(seconds: -1),
  ]) {
    test('expired or clock-reversed intent requires confirmation: $elapsed',
        () async {
      await links.sendPasswordResetEmail('recipient@example.invalid');
      clock = clock.add(elapsed);
      final result =
          await accept('/loginPage?type=recovery&token_hash=expired');
      expect(result!.userId, 'recipient');
      expect(prompts, 1);
    });
  }

  test('intent remains usable just before its deadline', () async {
    await links.sendPasswordResetEmail('recipient@example.invalid');
    clock = clock.add(const Duration(minutes: 14, seconds: 59));
    expect(
        await accept('/loginPage?type=recovery&token_hash=fresh', email: null),
        isNotNull);
    expect(prompts, 0);
  });

  test('expiry during verification cannot adopt a session', () async {
    await links.sendPasswordResetEmail('recipient@example.invalid');
    gate = Completer<void>();
    final result =
        accept('/loginPage?type=recovery&token_hash=slow', email: null);
    await Future<void>.delayed(Duration.zero);
    clock = clock.add(const Duration(minutes: 15));
    gate!.complete();
    expect(await result, isNull);
    expect(auth.currentSession, isNull);
    expect(authEvents, isEmpty);
  });

  for (final type in ['signup', 'magiclink', 'invite', 'email_change']) {
    test('remembered recovery email cannot replace $type confirmation',
        () async {
      await links.sendPasswordResetEmail('recipient@example.invalid');
      if (type == 'signup') {
        await expectLater(
            accept('/loginPage?type=$type&token_hash=other-type', email: null),
            throwsA(isA<AuthLinkSignInRequired>()));
        expect(prompts, 0);
        expect(auth.currentSession, isNull);
        expect(requests, hasLength(2));
        return;
      }
      expect(
          await accept('/loginPage?type=$type&token_hash=other-type',
              email: null),
          isNull);
      expect(prompts, 1);
      expect(auth.currentSession, isNull);
      expect(requests, hasLength(1));
    });
  }

  test('failed resend clears earlier intent instead of reusing it', () async {
    await links.sendPasswordResetEmail('other@example.invalid');
    resetStatus = 400;
    await expectLater(links.sendPasswordResetEmail('recipient@example.invalid'),
        throwsA(isA<AuthException>()));
    expect(await accept('/loginPage?type=recovery&token_hash=failed-resend'),
        isNotNull);
    expect(prompts, 1);
  });

  test('empty request clears intent and makes no request', () async {
    await links.sendPasswordResetEmail('recipient@example.invalid');
    requests.clear();
    await expectLater(
        links.sendPasswordResetEmail(' '), throwsA(isA<AuthException>()));
    expect(requests, isEmpty);
    expect(
        await accept('/loginPage?type=recovery&token_hash=empty', email: null),
        isNull);
    expect(prompts, 1);
    expect(requests, isEmpty);
  });

  test('cancelled login boundary cannot retain or restore a delayed intent',
      () async {
    final sendGate = Completer<void>();
    resetGates['recipient@example.invalid'] = sendGate;
    final sending = links.sendPasswordResetEmail('recipient@example.invalid');
    links.cancelPending();
    sendGate.complete();
    await sending;
    expect(
        await accept('/loginPage?type=recovery&token_hash=cancelled',
            email: null),
        isNull);
    expect(prompts, 1);
    expect(auth.currentSession, isNull);
  });

  for (final oldFails in [false, true]) {
    for (final oldFinishesFirst in [false, true]) {
      test(
          'newer send owns intent: old fails $oldFails, first $oldFinishesFirst',
          () async {
        final oldGate = Completer<void>();
        final newGate = Completer<void>();
        resetGates['other@example.invalid'] = oldGate;
        resetGates['recipient@example.invalid'] = newGate;
        resetStatuses['other@example.invalid'] = oldFails ? 400 : 200;
        final old = links.sendPasswordResetEmail('other@example.invalid');
        final oldDone =
            oldFails ? expectLater(old, throwsA(isA<AuthException>())) : old;
        resetStatus = 200;
        final latest =
            links.sendPasswordResetEmail('recipient@example.invalid');
        if (oldFinishesFirst) {
          oldGate.complete();
          await oldDone;
          newGate.complete();
          await latest;
        } else {
          newGate.complete();
          await latest;
          oldGate.complete();
          await oldDone;
        }
        expect(
            await accept('/loginPage?type=recovery&token_hash=newest',
                email: null),
            isNotNull);
        expect(prompts, 0);
        expect(auth.currentUser!.id, 'recipient');
      });
    }
  }

  test('a new reset request cancels older verification', () async {
    await links.sendPasswordResetEmail('recipient@example.invalid');
    gate = Completer<void>();
    final result =
        accept('/loginPage?type=recovery&token_hash=old', email: null);
    await Future<void>.delayed(Duration.zero);
    await links.sendPasswordResetEmail('other@example.invalid');
    gate!.complete();
    expect(await result, isNull);
    expect(auth.currentSession, isNull);
    gate = null;
    candidate = accessOwner = 'other';
    expect(await accept('/loginPage?type=recovery&token_hash=new', email: null),
        isNotNull);
    expect(auth.currentUser!.id, 'other');
    expect(prompts, 0);
  });

  test('session change while sending cannot create local intent', () async {
    final sendGate = Completer<void>();
    resetGates['recipient@example.invalid'] = sendGate;
    final sending = links.sendPasswordResetEmail('recipient@example.invalid');
    await signedIn();
    sendGate.complete();
    await sending;
    await auth.signOut();
    expect(
        await accept('/loginPage?type=recovery&token_hash=changed',
            email: null),
        isNull);
    expect(prompts, 1);
  });

  test('mismatched link leaves the legitimate local recovery usable', () async {
    await links.sendPasswordResetEmail('recipient@example.invalid');
    candidate = accessOwner = 'other';
    await expectLater(
        accept('/loginPage?type=recovery&token_hash=wrong', email: null),
        throwsA(isA<AuthException>()));
    candidate = accessOwner = 'recipient';
    expect(
        await accept('/loginPage?type=recovery&token_hash=right', email: null),
        isNotNull);
    expect(prompts, 0);
  });

  test('newer link reuses local intent while older verification is pending',
      () async {
    await links.sendPasswordResetEmail('recipient@example.invalid');
    gate = Completer<void>();
    final oldGate = gate!;
    final old = accept('/loginPage?type=recovery&token_hash=old', email: null);
    await Future<void>.delayed(Duration.zero);
    gate = null;
    final latest =
        await accept('/loginPage?type=recovery&token_hash=new', email: null);
    final session = auth.currentSession;
    oldGate.complete();
    expect(await old, isNull);
    expect(latest, isNotNull);
    expect(auth.currentSession, same(session));
    expect(prompts, 0);
  });

  test('successful adoption consumes local recovery intent', () async {
    await links.sendPasswordResetEmail('recipient@example.invalid');
    expect(
        await accept('/loginPage?type=recovery&token_hash=first', email: null),
        isNotNull);
    await auth.signOut();
    expect(
        await accept('/loginPage?type=recovery&token_hash=second', email: null),
        isNull);
    expect(prompts, 1);
  });

  test('signed-in identity takes precedence over remembered email', () async {
    await links.sendPasswordResetEmail('other@example.invalid');
    final original = await signedIn();
    candidate = accessOwner = 'other';
    await expectLater(accept('/loginPage?type=recovery&token_hash=signed-in'),
        throwsA(isA<AuthException>()));
    expect(auth.currentSession, same(original));
    expect(prompts, 0);
  });

  test('new service after process restart has no recovery intent', () async {
    await links.sendPasswordResetEmail('recipient@example.invalid');
    links = AuthLinkService(
        auth: auth,
        authUrl: 'https://audit.invalid/auth/v1',
        anonKey: 'synthetic-anon',
        clientFactory: () =>
            throw StateError('No exchange before confirmation'));
    expect(
        await accept('/loginPage?type=recovery&token_hash=restart',
            email: null),
        isNull);
    expect(prompts, 1);
  });

  test('equivalent local callbacks share intent and one verification',
      () async {
    await links.sendPasswordResetEmail('recipient@example.invalid');
    requests.clear();
    gate = Completer<void>();
    final first =
        accept('/loginPage?type=recovery&refreshToken=local', email: null);
    final duplicate =
        accept('/loginPage#refresh_token=local&type=recovery', email: null);
    gate!.complete();
    expect(await duplicate, same(await first));
    expect(prompts, 0);
    expect(requests, hasLength(1));
  });

  test('local intent does not authorize recovery while in decoy', () async {
    await links.sendPasswordResetEmail('recipient@example.invalid');
    requests.clear();
    allowed = false;
    expect(
        await accept('/loginPage?type=recovery&token_hash=decoy', email: null),
        isNull);
    expect(requests, isEmpty);
    expect(prompts, 0);
    expect(auth.currentSession, isNull);
  });

  test('decoy state ignores a callback without prompting or network', () async {
    allowed = false;
    expect(await accept('/loginPage?type=recovery&refreshToken=synthetic'),
        isNull);
    expect(prompts, 0);
    expect(requests, isEmpty);
  });
}
