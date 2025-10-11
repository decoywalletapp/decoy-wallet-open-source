import 'dart:convert';
import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'package:ff_commons/api_requests/api_manager.dart';


export 'package:ff_commons/api_requests/api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class SendVerificationCodeCall {
  static Future<ApiCallResponse> call({
    String? cleanPhone = '',
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

class SetPhoneAuthCall {
  static Future<ApiCallResponse> call({
    String? cleanPhone = '',
    String? jwt = '',
  }) async {
    final ffApiRequestBody = '''
{ "phone": "${escapeStringForJson(cleanPhone)}" }''';
    return ApiManager.instance.makeApiCall(
      callName: 'setPhoneAuth',
      apiUrl: 'https://vxmrthyumzrfgtuvjqmr.supabase.co/functions/v1/set-phone',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer <Id token (JWT token)>',
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
        'Authorization': 'Bearer \${Supabase Auth JWT}',
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
  "pin": "${escapeStringForJson(pin)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'verifyPIN',
      apiUrl: 'https://vxmrthyumzrfgtuvjqmr.supabase.co/functions/v1/verifyPin',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer \${Supabase Auth JWT}',
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
