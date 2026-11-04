import 'dart:convert';
import 'package:decoy_wallet_app/workshop/workshop_claim_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final token = List.filled(43, 'A').join();
final qr = 'decoy-workshop:v1:$token';

void main() {
  Matcher fails(WorkshopClaimFailure value) => throwsA(
      isA<WorkshopClaimException>().having((e) => e.failure, 'failure', value));

  test('billing confirmation is explicit and never sent with an ordinary scan',
      () async {
    var count = 0;
    final service = WorkshopClaimClient(
      endpoint: Uri.parse('https://test.invalid/claim-workshop-access'),
      client: MockClient((request) async {
        final body = jsonDecode(request.body);
        if (count++ == 0) {
          expect(body, {'token': token});
          return http.Response(
              '{"error":"billing_confirmation_required"}', 409);
        }
        expect(body, {'token': token, 'confirm_cancel_renewal': true});
        return http.Response(
            jsonEncode({
              'ok': true,
              'grant_id': 'confirmed-grant',
              'access_ends_at': '2126-11-09T00:00:00Z',
              'already_claimed': false,
            }),
            200);
      }),
    );
    await expectLater(service.claim(qr: qr, jwt: 'synthetic-jwt'),
        fails(WorkshopClaimFailure.billingConfirmationRequired));
    expect(
        (await service.claim(
          qr: qr,
          jwt: 'synthetic-jwt',
          confirmCancelRenewal: true,
        ))
            .alreadyClaimed,
        isFalse);
  });

  test('billing conflict is distinct from a closed workshop', () async {
    final service = WorkshopClaimClient(
      endpoint: Uri.parse('https://test.invalid/claim-workshop-access'),
      client: MockClient(
          (_) async => http.Response('{"error":"billing_conflict"}', 409)),
    );
    await expectLater(service.claim(qr: qr, jwt: 'synthetic-jwt'),
        fails(WorkshopClaimFailure.billingConflict));
  });

  test('only accepts the workshop version and fixed token format', () {
    expect(parseWorkshopQr(' $qr\n'), token);
    for (final value in [
      '',
      workshopPreviewQr,
      'https://attacker.invalid/$token',
      '$qr?days=36500',
      'decoy-workshop:v2:$token',
      'decoy-workshop:v1:short',
      'bitcoin:address',
    ]) {
      expect(
          () => parseWorkshopQr(value), fails(WorkshopClaimFailure.invalidQr));
    }
  });

  test('authenticated fixed-endpoint POST has no user-supplied access duration',
      () async {
    final service = WorkshopClaimClient(
      endpoint: Uri.parse('https://test.invalid/claim-workshop-access'),
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.host, 'test.invalid');
        expect(request.followRedirects, isFalse);
        expect(request.headers['Authorization'], 'Bearer synthetic-jwt');
        expect(jsonDecode(request.body), {'token': token});
        return http.Response(
            jsonEncode({
              'ok': true,
              'grant_id': 'synthetic-grant',
              'access_ends_at': '2126-11-09T00:00:00Z',
              'already_claimed': false,
            }),
            200);
      }),
    );
    final result = await service.claim(qr: qr, jwt: 'synthetic-jwt');
    expect(result.accessEndsAt.year, 2126);
    expect(result.alreadyClaimed, isFalse);
  });

  test('completed claims may return the same durable receipt', () async {
    final service = WorkshopClaimClient(
      endpoint: Uri.parse('https://test.invalid/claim-workshop-access'),
      client: MockClient((_) async => http.Response(
          jsonEncode({
            'ok': true,
            'grant_id': 'original-grant',
            'access_ends_at': '2126-11-09T00:00:00Z',
            'already_claimed': true,
          }),
          200)),
    );
    expect((await service.claim(qr: qr, jwt: 'synthetic-jwt')).alreadyClaimed,
        isTrue);
  });

  for (final entry in {
    400: WorkshopClaimFailure.invalidQr,
    401: WorkshopClaimFailure.signedOut,
    403: WorkshopClaimFailure.closed,
    409: WorkshopClaimFailure.closed,
    410: WorkshopClaimFailure.closed,
    429: WorkshopClaimFailure.rateLimited,
    302: WorkshopClaimFailure.unavailable,
    404: WorkshopClaimFailure.unavailable,
    503: WorkshopClaimFailure.unavailable,
  }.entries) {
    test('handles HTTP ${entry.key} without treating it as a grant', () async {
      final service = WorkshopClaimClient(
        endpoint: Uri.parse('https://test.invalid/claim-workshop-access'),
        client: MockClient(
            (_) async => http.Response('private server message', entry.key)),
      );
      await expectLater(
          service.claim(qr: qr, jwt: 'synthetic-jwt'), fails(entry.value));
    });
  }

  for (final body in [
    'not json',
    '[]',
    '{"ok":true}',
    jsonEncode({
      'ok': true,
      'grant_id': 'g',
      'access_ends_at': 'bad',
      'already_claimed': false,
    })
  ]) {
    test('malformed receipt is never successful: $body', () async {
      final service = WorkshopClaimClient(
        endpoint: Uri.parse('https://test.invalid/claim-workshop-access'),
        client: MockClient((_) async => http.Response(body, 200)),
      );
      await expectLater(service.claim(qr: qr, jwt: 'synthetic-jwt'),
          fails(WorkshopClaimFailure.unavailable));
    });
  }

  test('rejects missing sign-in and unsafe endpoint before network use',
      () async {
    var requests = 0;
    final client = MockClient((_) async {
      requests++;
      return http.Response('', 200);
    });
    await expectLater(
        WorkshopClaimClient(
          endpoint: Uri.parse('https://test.invalid/claim-workshop-access'),
          client: client,
        ).claim(qr: qr, jwt: ''),
        fails(WorkshopClaimFailure.signedOut));
    for (final endpoint in [
      'http://test.invalid',
      'https://user@test.invalid',
      'https://test.invalid?token=value',
      'https://test.invalid#fragment'
    ]) {
      await expectLater(
          WorkshopClaimClient(endpoint: Uri.parse(endpoint), client: client)
              .claim(qr: qr, jwt: 'synthetic-jwt'),
          fails(WorkshopClaimFailure.unavailable));
    }
    expect(requests, 0);
  });

  test('connection failure remains retryable and does not leak details',
      () async {
    final service = WorkshopClaimClient(
      endpoint: Uri.parse('https://test.invalid/claim-workshop-access'),
      client: MockClient((_) async => throw Exception('secret')),
    );
    await expectLater(service.claim(qr: qr, jwt: 'synthetic-jwt'),
        fails(WorkshopClaimFailure.unavailable));
  });
}
