import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

const workshopPreviewQr = 'DECOY-WORKSHOP-UI-PREVIEW-V1-NO-ACCESS';

enum WorkshopClaimFailure {
  invalidQr,
  signedOut,
  closed,
  rateLimited,
  unavailable,
}

class WorkshopClaimException implements Exception {
  const WorkshopClaimException(this.failure);
  final WorkshopClaimFailure failure;
}

class WorkshopClaimReceipt {
  const WorkshopClaimReceipt({
    required this.accessEndsAt,
    required this.alreadyClaimed,
  });
  final DateTime accessEndsAt;
  final bool alreadyClaimed;
}

String parseWorkshopQr(String value) {
  final match = RegExp(r'^decoy-workshop:v1:([A-Za-z0-9_-]{43})$')
      .firstMatch(value.trim());
  if (match == null) {
    throw const WorkshopClaimException(WorkshopClaimFailure.invalidQr);
  }
  return match.group(1)!;
}

/// Only the configured server can authorize access. QR content is never a URL.
class WorkshopClaimClient {
  WorkshopClaimClient({required this.endpoint, required this.client});

  final Uri endpoint;
  final http.Client client;

  Future<WorkshopClaimReceipt> claim({
    required String qr,
    required String jwt,
  }) async {
    final token = parseWorkshopQr(qr);
    if (jwt.trim().isEmpty) {
      throw const WorkshopClaimException(WorkshopClaimFailure.signedOut);
    }
    if (endpoint.scheme != 'https' ||
        endpoint.host.isEmpty ||
        endpoint.userInfo.isNotEmpty ||
        endpoint.hasQuery ||
        endpoint.hasFragment) {
      throw const WorkshopClaimException(WorkshopClaimFailure.unavailable);
    }
    try {
      final request = http.Request('POST', endpoint)
        ..followRedirects = false
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        })
        ..body = jsonEncode({'token': token});
      final response = await (() async {
        final streamed = await client.send(request);
        return http.Response.fromStream(streamed);
      })()
          .timeout(const Duration(seconds: 20));
      switch (response.statusCode) {
        case 401:
          throw const WorkshopClaimException(WorkshopClaimFailure.signedOut);
        case 400:
          throw const WorkshopClaimException(WorkshopClaimFailure.invalidQr);
        case 403:
        case 409:
        case 410:
          throw const WorkshopClaimException(WorkshopClaimFailure.closed);
        case 429:
          throw const WorkshopClaimException(WorkshopClaimFailure.rateLimited);
      }
      if (response.statusCode != 200) {
        throw const WorkshopClaimException(WorkshopClaimFailure.unavailable);
      }
      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic> ||
          body['ok'] != true ||
          body['grant_id'] is! String ||
          (body['grant_id'] as String).isEmpty ||
          body['already_claimed'] is! bool ||
          body['access_ends_at'] is! String) {
        throw const WorkshopClaimException(WorkshopClaimFailure.unavailable);
      }
      final end = DateTime.tryParse(body['access_ends_at'] as String);
      if (end == null) {
        throw const WorkshopClaimException(WorkshopClaimFailure.unavailable);
      }
      return WorkshopClaimReceipt(
        accessEndsAt: end,
        alreadyClaimed: body['already_claimed'] as bool,
      );
    } on WorkshopClaimException {
      rethrow;
    } catch (_) {
      // Never surface a QR, account token, or backend response in error text.
      throw const WorkshopClaimException(WorkshopClaimFailure.unavailable);
    }
  }
}
