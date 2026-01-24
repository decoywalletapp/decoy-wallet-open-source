import 'dart:convert';
import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'package:ff_commons/api_requests/api_manager.dart';


export 'package:ff_commons/api_requests/api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

/// Start DecoyAlert Group Code

class DecoyAlertGroup {
  static String getBaseUrl() =>
      'https://decoy-alert-866378207353.us-central1.run.app';
  static Map<String, String> headers = {};
  static SendEmergencyAlertsCall sendEmergencyAlertsCall =
      SendEmergencyAlertsCall();
}

class SendEmergencyAlertsCall {
  Future<ApiCallResponse> call({
    String? userId = '',
    String? triggerId = '',
    double? lat,
    double? lng,
    dynamic contactsJson,
    String? ownerName = '',
    String? jwt = '',
  }) async {
    final baseUrl = DecoyAlertGroup.getBaseUrl();

    final contacts = _serializeJson(contactsJson);
    final ffApiRequestBody = '''
{
  "userId": "${escapeStringForJson(userId)}",
  "triggerType": "${escapeStringForJson(triggerId)}",
  "ownerName": "${escapeStringForJson(ownerName)}",
  "contacts": ${contacts},
  "location": {
    "lat": ${lat},
    "lng": ${lng}
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'SendEmergencyAlerts',
      apiUrl: '${baseUrl}/sendEmergencyAlerts',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${jwt}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// End DecoyAlert Group Code

class SendVerificationCodeCall {
  static Future<ApiCallResponse> call({
    String? cleanPhone = '',
    String? jwt = '',
  }) async {
    final ffApiRequestBody = '''
{
  "phone": "${cleanPhone}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'SendVerificationCode',
      apiUrl:
          'https://us-central1-decoywallet-a283b.cloudfunctions.net/sendVerificationCode',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${jwt}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  static String? sid(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.sid''',
      ));
  static dynamic error(dynamic response) => getJsonField(
        response,
        r'''$.error''',
      );
}

class CheckVerificationCodeCall {
  static Future<ApiCallResponse> call({
    String? cleanPhone = '',
    String? code = '',
    String? jwt = '',
  }) async {
    final ffApiRequestBody = '''
{
  "phone": "${cleanPhone}",
  "code": "${code}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'CheckVerificationCode',
      apiUrl:
          'https://us-central1-decoywallet-a283b.cloudfunctions.net/checkVerificationCode',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${jwt}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  static String? status(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.status''',
      ));
  static dynamic error(dynamic response) => getJsonField(
        response,
        r'''$.error''',
      );
}

class BtcChartOneYearCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'btcChartOneYear',
      apiUrl:
          'https://vxmrthyumzrfgtuvjqmr.functions.supabase.co/coingecko-proxy?path=coins/bitcoin/market_chart&vs_currency=usd&days=365&interval=daily',
      callType: ApiCallType.GET,
      headers: {
        'Accept': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List? rows(dynamic response) => getJsonField(
        response,
        r'''$.prices''',
        true,
      ) as List?;
}

class SetPINCall {
  static Future<ApiCallResponse> call({
    String? type = '',
    String? pin = '',
    String? jwt = '',
  }) async {
    final ffApiRequestBody = '''
{
  "type": "${escapeStringForJson(type)}",
  "pin": "${escapeStringForJson(pin)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'setPIN',
      apiUrl: 'https://vxmrthyumzrfgtuvjqmr.supabase.co/functions/v1/setPin',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${jwt}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static bool? ok(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.ok''',
      ));
  static String? error(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.error''',
      ));
  static dynamic isAccount(dynamic response) => getJsonField(
        response,
        r'''$.isAccount''',
      );
  static dynamic isDecoy(dynamic response) => getJsonField(
        response,
        r'''$.isDecoy''',
      );
}

class VerifyPINCall {
  static Future<ApiCallResponse> call({
    String? pin = '',
    String? jwt = '',
  }) async {
    final ffApiRequestBody = '''
{
  "pin": "${pin}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'verifyPIN',
      apiUrl: 'https://vxmrthyumzrfgtuvjqmr.supabase.co/functions/v1/verifyPin',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${jwt}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static bool? ok(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.ok''',
      ));
  static String? error(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.error''',
      ));
  static bool? isAccount(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.isAccount''',
      ));
  static bool? isDecoy(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.isDecoy''',
      ));
}

class WrapDataKeyCall {
  static Future<ApiCallResponse> call({
    String? dataKeyB64 = '',
    String? jwt = '',
  }) async {
    final ffApiRequestBody = '''
{
  "dataKeyB64": "${escapeStringForJson(dataKeyB64)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'WrapDataKey',
      apiUrl: 'https://wrapdatakey-866378207353.us-central1.run.app',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${jwt}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? wrappedB64(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.wrappedB64''',
      ));
}

class SendSupportTicketCall {
  static Future<ApiCallResponse> call({
    String? userEmail = '',
    String? subject = '',
    String? message = '',
  }) async {
    final ffApiRequestBody = '''
{
  "userEmail": "${escapeStringForJson(userEmail)}",
  "subject": "${escapeStringForJson(subject)}",
  "message": "${escapeStringForJson(message)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'sendSupportTicket',
      apiUrl:
          'https://us-central1-decoywallet-a283b.cloudfunctions.net/sendSupportTicket',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CreateCheckoutSessionCall {
  static Future<ApiCallResponse> call({
    String? currentUserUid = '',
  }) async {
    final ffApiRequestBody = '''
{
  "user_id": "${escapeStringForJson(currentUserUid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'CreateCheckoutSession',
      apiUrl:
          'https://decoy-stripe-webhook-866378207353.us-central1.run.app/create-checkout-session',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? url(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.url''',
      ));
}

class CreateBTCPayInvoiceCall {
  static Future<ApiCallResponse> call({
    String? currentUserUid = '',
  }) async {
    final ffApiRequestBody = '''
{
  "user_id": "${escapeStringForJson(currentUserUid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'CreateBTCPayInvoice',
      apiUrl:
          'https://decoy-stripe-webhook-866378207353.us-central1.run.app/create-btcpay-invoice',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? invoiceUrl(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.url''',
      ));
}

class CreateBillingPortalSessionCall {
  static Future<ApiCallResponse> call({
    String? customerId = '',
    String? returnUrl = '',
  }) async {
    final ffApiRequestBody = '''
{
"customer_id": "${escapeStringForJson(customerId)}",
"return_url": "${escapeStringForJson(returnUrl)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'CreateBillingPortalSession',
      apiUrl:
          'https://decoy-stripe-webhook-866378207353.us-central1.run.app/create-billing-portal-session',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? url(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.url''',
      ));
}

class WrapDataKeyUnwrapCall {
  static Future<ApiCallResponse> call({
    String? wrappedB64 = '',
    String? jwt = '',
  }) async {
    final ffApiRequestBody = '''
{
  "wrappedB64": "${escapeStringForJson(wrappedB64)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'WrapDataKeyUnwrap',
      apiUrl: 'https://wrapdatakey-866378207353.us-central1.run.app',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${jwt}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetPhoneHashCall {
  static Future<ApiCallResponse> call({
    String? cleanPhone = '',
    String? jwt = '',
  }) async {
    final ffApiRequestBody = '''
{
  "cleanPhone": "${escapeStringForJson(cleanPhone)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'getPhoneHash',
      apiUrl:
          'https://us-central1-decoywallet-a283b.cloudfunctions.net/getPhoneHash',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${jwt}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? phoneHash(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.phoneHash''',
      ));
  static bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
}

class GetEmailHashCall {
  static Future<ApiCallResponse> call({
    String? email = '',
    String? jwt = '',
  }) async {
    final ffApiRequestBody = '''
{
  "email": "${escapeStringForJson(email)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'getEmailHash',
      apiUrl:
          'https://us-central1-decoywallet-a283b.cloudfunctions.net/getEmailHash',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${jwt}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static dynamic emailHash(dynamic response) => getJsonField(
        response,
        r'''$.emailHash''',
      );
  static dynamic success(dynamic response) => getJsonField(
        response,
        r'''$.success''',
      );
}

class InsertAlertLogRestCall {
  static Future<ApiCallResponse> call({
    String? userId = '',
    double? lat,
    double? lng,
    String? locCipherB64 = '',
    String? locNonceB64 = '',
    String? jwt = '',
  }) async {
    final ffApiRequestBody = '''
{
  "user_id": "${escapeStringForJson(userId)}",
  "trigger_type": "PIN_DECOY",
  "success": true,
  "lat": ${lat},
  "lng": ${lng},
  "location_ciphertext": "${escapeStringForJson(locCipherB64)}",
  "location_nonce": "${escapeStringForJson(locNonceB64)}",
  "location_version": 1
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'insertAlertLogRest',
      apiUrl: 'https://vxmrthyumzrfgtuvjqmr.supabase.co/rest/v1/alert_logs',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ4bXJ0aHl1bXpyZmd0dXZqcW1yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAyMDY2NDksImV4cCI6MjA2NTc4MjY0OX0.ZBjqtz7DKRkxnR3-rYtvtmz0JJb4-pDL4ux89qVBASc',
        'Authorization': 'Bearer ${jwt}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Prefer': 'return=minimal',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetAuthUserCall {
  static Future<ApiCallResponse> call({
    String? jwt = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'GetAuthUser',
      apiUrl: 'https://vxmrthyumzrfgtuvjqmr.supabase.co/auth/v1/user',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${jwt}',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ4bXJ0aHl1bXpyZmd0dXZqcW1yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAyMDY2NDksImV4cCI6MjA2NTc4MjY0OX0.ZBjqtz7DKRkxnR3-rYtvtmz0JJb4-pDL4ux89qVBASc',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class RegisterDecoyCall {
  static Future<ApiCallResponse> call({
    String? jwt = '',
    String? decoyId = '',
    String? addr0 = '',
  }) async {
    final ffApiRequestBody = '''
{
  "id": "${escapeStringForJson(decoyId)}",
  "derivation_path": "m/84'/0'/0'",
  "addresses": "${escapeStringForJson(addr0)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'registerDecoy',
      apiUrl:
          'https://vxmrthyumzrfgtuvjqmr.supabase.co/functions/v1/register-decoy',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${jwt}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CommitDecoyCall {
  static Future<ApiCallResponse> call({
    String? jwt = '',
    String? decoyId = '',
    String? derivationPath = '',
    List<String>? addressesList,
  }) async {
    final addresses = _serializeList(addressesList);

    final ffApiRequestBody = '''
{
  "id": "${escapeStringForJson(decoyId)}",
  "derivation_path": "${escapeStringForJson(derivationPath)}",
  "addresses": ${addresses}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'commitDecoy',
      apiUrl:
          'https://vxmrthyumzrfgtuvjqmr.supabase.co/functions/v1/commit-decoy',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${jwt}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
