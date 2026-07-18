import 'dart:convert';
import 'package:flutter/foundation.dart';

import '/backend/public_config.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:ff_commons/api_requests/api_manager.dart';

export 'package:ff_commons/api_requests/api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

/// Start DecoyAlert Group Code

class DecoyAlertGroup {
  static String getBaseUrl() =>
      requiredPublicConfig('DECOY_ALERT_BASE_URL', kDecoyAlertBaseUrl);
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
    final ffApiRequestBody =
        '''
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
    final ffApiRequestBody =
        '''
{
  "phone": "${cleanPhone}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'SendVerificationCode',
      apiUrl: firebaseFunctionUrl('sendVerificationCode'),
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

  static bool? success(dynamic response) =>
      castToType<bool>(getJsonField(response, r'''$.success'''));
  static String? sid(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.sid'''));
  static dynamic error(dynamic response) =>
      getJsonField(response, r'''$.error''');
}

class CheckVerificationCodeCall {
  static Future<ApiCallResponse> call({
    String? cleanPhone = '',
    String? code = '',
    String? jwt = '',
  }) async {
    final ffApiRequestBody =
        '''
{
  "phone": "${cleanPhone}",
  "code": "${code}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'CheckVerificationCode',
      apiUrl: firebaseFunctionUrl('checkVerificationCode'),
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

  static bool? success(dynamic response) =>
      castToType<bool>(getJsonField(response, r'''$.success'''));
  static String? status(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.status'''));
  static dynamic error(dynamic response) =>
      getJsonField(response, r'''$.error''');
}

class BtcChartOneYearCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'btcChartOneYear',
      apiUrl:
          '${supabaseFunctionUrl('coingecko-proxy')}?path=coins/bitcoin/market_chart&vs_currency=usd&days=365&interval=daily',
      callType: ApiCallType.GET,
      headers: {'Accept': 'application/json'},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List? rows(dynamic response) =>
      getJsonField(response, r'''$.prices''', true) as List?;
}

class BtcCurrentPriceCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'btcCurrentPrice',
      apiUrl: 'https://api.exchange.coinbase.com/products/BTC-USD/ticker',
      callType: ApiCallType.GET,
      headers: {'Accept': 'application/json'},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static double? usd(dynamic response) =>
      castToType<double>(getJsonField(response, r'''$.price'''));
  static String? lastUpdatedAt(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.time'''));
}

class BtcCoinbaseStatsCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'btcCoinbaseStats',
      apiUrl: 'https://api.exchange.coinbase.com/products/BTC-USD/stats',
      callType: ApiCallType.GET,
      headers: {'Accept': 'application/json'},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static double? open(dynamic response) =>
      castToType<double>(getJsonField(response, r'''$.open'''));
  static double? last(dynamic response) =>
      castToType<double>(getJsonField(response, r'''$.last'''));
}

class SetPINCall {
  static Future<ApiCallResponse> call({
    String? type = '',
    String? pin = '',
    String? jwt = '',
  }) async {
    final ffApiRequestBody =
        '''
{
  "type": "${escapeStringForJson(type)}",
  "pin": "${escapeStringForJson(pin)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'setPIN',
      apiUrl: supabaseFunctionUrl('setPin'),
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

  static bool? ok(dynamic response) =>
      castToType<bool>(getJsonField(response, r'''$.ok'''));
  static String? error(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.error'''));
  static dynamic isAccount(dynamic response) =>
      getJsonField(response, r'''$.isAccount''');
  static dynamic isDecoy(dynamic response) =>
      getJsonField(response, r'''$.isDecoy''');
}

class VerifyPINCall {
  static Future<ApiCallResponse> call({
    String? pin = '',
    String? jwt = '',
  }) async {
    final ffApiRequestBody =
        '''
{
  "pin": "${pin}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'verifyPIN',
      apiUrl: supabaseFunctionUrl('verifyPin'),
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

  static bool? ok(dynamic response) =>
      castToType<bool>(getJsonField(response, r'''$.ok'''));
  static String? error(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.error'''));
  static bool? isAccount(dynamic response) =>
      castToType<bool>(getJsonField(response, r'''$.isAccount'''));
  static bool? isDecoy(dynamic response) =>
      castToType<bool>(getJsonField(response, r'''$.isDecoy'''));
}

class WrapDataKeyCall {
  static Future<ApiCallResponse> call({
    String? dataKeyB64 = '',
    String? jwt = '',
  }) async {
    final ffApiRequestBody =
        '''
{
  "dataKeyB64": "${escapeStringForJson(dataKeyB64)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'WrapDataKey',
      apiUrl: requiredPublicConfig('DECOY_DATA_KEY_BASE_URL', kDataKeyBaseUrl),
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
      castToType<String>(getJsonField(response, r'''$.wrappedB64'''));
}

class SendSupportTicketCall {
  static Future<ApiCallResponse> call({
    String? userEmail = '',
    String? subject = '',
    String? message = '',
  }) async {
    final ffApiRequestBody =
        '''
{
  "userEmail": "${escapeStringForJson(userEmail)}",
  "subject": "${escapeStringForJson(subject)}",
  "message": "${escapeStringForJson(message)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'sendSupportTicket',
      apiUrl: firebaseFunctionUrl('sendSupportTicket'),
      callType: ApiCallType.POST,
      headers: {'Content-Type': 'application/json'},
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
    String? billingInterval = 'monthly',
    int? trialEnd,
    String? jwt = '',
  }) async {
    final ffApiRequestBody =
        '''
{
  "user_id": "${escapeStringForJson(currentUserUid)}",
  "billing_interval": "${escapeStringForJson(billingInterval)}",
  "trial_end": ${trialEnd == null ? 'null' : trialEnd}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'CreateCheckoutSession',
      apiUrl:
          '${requiredPublicConfig('DECOY_PAYMENT_BASE_URL', kPaymentBaseUrl)}/create-checkout-session',
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

  static String? url(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.url'''));

  static String? sessionId(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.session_id'''));
}

class CreateBTCPayInvoiceCall {
  static Future<ApiCallResponse> call({
    String? currentUserUid = '',
    String? billingInterval = 'monthly',
    String? jwt = '',
  }) async {
    final ffApiRequestBody =
        '''
{
  "user_id": "${escapeStringForJson(currentUserUid)}",
  "billing_interval": "${escapeStringForJson(billingInterval)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'CreateBTCPayInvoice',
      apiUrl:
          '${requiredPublicConfig('DECOY_PAYMENT_BASE_URL', kPaymentBaseUrl)}/create-btcpay-invoice',
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

  static String? invoiceUrl(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.url'''));
}

class CreateBillingPortalSessionCall {
  static Future<ApiCallResponse> call({
    String? customerId = '',
    String? userId = '',
    String? returnUrl = '',
    String? jwt = '',
  }) async {
    final ffApiRequestBody =
        '''
{
"customer_id": "${escapeStringForJson(customerId)}",
"user_id": "${escapeStringForJson(userId)}",
"return_url": "${escapeStringForJson(returnUrl)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'CreateBillingPortalSession',
      apiUrl:
          '${requiredPublicConfig('DECOY_PAYMENT_BASE_URL', kPaymentBaseUrl)}/create-billing-portal-session',
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

  static String? url(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.url'''));
}

class WrapDataKeyUnwrapCall {
  static Future<ApiCallResponse> call({
    String? wrappedB64 = '',
    String? jwt = '',
  }) async {
    final ffApiRequestBody =
        '''
{
  "wrappedB64": "${escapeStringForJson(wrappedB64)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'WrapDataKeyUnwrap',
      apiUrl: requiredPublicConfig('DECOY_DATA_KEY_BASE_URL', kDataKeyBaseUrl),
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
    final ffApiRequestBody =
        '''
{
  "cleanPhone": "${escapeStringForJson(cleanPhone)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'getPhoneHash',
      apiUrl: firebaseFunctionUrl('getPhoneHash'),
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

  static String? phoneHash(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.phoneHash'''));
  static bool? success(dynamic response) =>
      castToType<bool>(getJsonField(response, r'''$.success'''));
}

class GetEmailHashCall {
  static Future<ApiCallResponse> call({
    String? email = '',
    String? jwt = '',
  }) async {
    final ffApiRequestBody =
        '''
{
  "email": "${escapeStringForJson(email)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'getEmailHash',
      apiUrl: firebaseFunctionUrl('getEmailHash'),
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

  static dynamic emailHash(dynamic response) =>
      getJsonField(response, r'''$.emailHash''');
  static dynamic success(dynamic response) =>
      getJsonField(response, r'''$.success''');
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
    final ffApiRequestBody =
        '''
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
      apiUrl: supabaseRestUrl('alert_logs'),
      callType: ApiCallType.POST,
      headers: {
        'apikey': requiredPublicConfig(
          'DECOY_SUPABASE_ANON_KEY',
          kSupabaseAnonKey,
        ),
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
  static Future<ApiCallResponse> call({String? jwt = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'GetAuthUser',
      apiUrl: supabaseAuthUrl('user'),
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${jwt}',
        'apikey': requiredPublicConfig(
          'DECOY_SUPABASE_ANON_KEY',
          kSupabaseAnonKey,
        ),
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
    final ffApiRequestBody =
        '''
{
  "id": "${escapeStringForJson(decoyId)}",
  "derivation_path": "m/84'/0'/0'",
  "addresses": "${escapeStringForJson(addr0)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'registerDecoy',
      apiUrl: supabaseFunctionUrl('register-decoy'),
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
    String? xpub = '',
    String? watchPublicKey = '',
    String? watchPublicKeyType = '',
  }) async {
    final addresses = _serializeList(addressesList);

    final ffApiRequestBody =
        '''
{
  "decoyId": "${escapeStringForJson(decoyId)}",
  "derivation_path": "${escapeStringForJson(derivationPath)}",
  "addresses": ${addresses},
  "xpub": "${escapeStringForJson(xpub)}",
  "watch_public_key": "${escapeStringForJson(watchPublicKey)}",
  "watch_public_key_type": "${escapeStringForJson(watchPublicKeyType)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'commitDecoy',
      apiUrl: supabaseFunctionUrl('commit-decoy'),
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

class CheckPhoneTakenCall {
  static Future<ApiCallResponse> call({
    String? jwt = '',
    String? phoneHash = '',
  }) async {
    final ffApiRequestBody =
        '''
{
"phoneHash": "${escapeStringForJson(phoneHash)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'checkPhoneTaken',
      apiUrl: supabaseFunctionUrl('check_phone_taken'),
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

  static bool? taken(dynamic response) =>
      castToType<bool>(getJsonField(response, r'''$.taken'''));
}

class FinalizeStripeSwitchCall {
  static Future<ApiCallResponse> call({
    String? userId = '',
    String? sessionId = '',
    String? jwt = '',
  }) async {
    final ffApiRequestBody =
        '''
{
"user_id": "${escapeStringForJson(userId)}",
"session_id": "${escapeStringForJson(sessionId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'finalizeStripeSwitch',
      apiUrl:
          '${requiredPublicConfig('DECOY_PAYMENT_BASE_URL', kPaymentBaseUrl)}/finalize-stripe-switch',
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

class ScheduleBtcpaySwitchCall {
  static Future<ApiCallResponse> call({
    String? currentUserUid = '',
    String? jwt = '',
  }) async {
    final ffApiRequestBody =
        '''
{
  "p_user_id": "${escapeStringForJson(currentUserUid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'scheduleBtcpaySwitch',
      apiUrl: supabaseRpcUrl('schedule_btcpay_switch'),
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'apikey': requiredPublicConfig(
          'DECOY_SUPABASE_ANON_KEY',
          kSupabaseAnonKey,
        ),
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

class FinalizeBtcpaySwitchCall {
  static Future<ApiCallResponse> call({
    String? userId = '',
    String? jwt = '',
  }) async {
    final ffApiRequestBody =
        '''
{
  "user_id": "${escapeStringForJson(userId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'finalizeBtcpaySwitch',
      apiUrl:
          '${requiredPublicConfig('DECOY_PAYMENT_BASE_URL', kPaymentBaseUrl)}/finalize-btcpay-switch',
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

class RepairStripeEntitlementCall {
  static Future<ApiCallResponse> call({
    String? userId = '',
    String? jwt = '',
  }) async {
    final ffApiRequestBody =
        '''
{
  "user_id": "${escapeStringForJson(userId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'RepairStripeEntitlement',
      apiUrl:
          '${requiredPublicConfig('DECOY_PAYMENT_BASE_URL', kPaymentBaseUrl)}/repair-stripe-entitlement',
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

class CreateConsentRequestCall {
  static Future<ApiCallResponse> call({
    String? userId = '',
    int? contactSlot,
    String? firstName = '',
    String? lastName = '',
    String? phoneNumber = '',
    String? jwt = '',
  }) async {
    final ffApiRequestBody =
        '''
{
  "userId": "${escapeStringForJson(userId)}",
  "contactSlot": ${contactSlot},
  "firstName": "${escapeStringForJson(firstName)}",
  "lastName": "${escapeStringForJson(lastName)}",
  "phoneNumber": "${escapeStringForJson(phoneNumber)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'CreateConsentRequest',
      apiUrl: supabaseFunctionUrl('createConsentRequest'),
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

  static dynamic link(dynamic response) =>
      getJsonField(response, r'''$.link''');
}

class GetConsentStatusesCall {
  static Future<ApiCallResponse> call({String? jwt = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'GetConsentStatuses',
      apiUrl: supabaseFunctionUrl('getConsentStatuses'),
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${jwt}',
      },
      params: {},
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static dynamic consents(dynamic response) =>
      getJsonField(response, r'''$.consents''');
  static dynamic slot1Status(dynamic response) =>
      getJsonField(response, r'''$.slot1Status''');
  static dynamic slot2Status(dynamic response) =>
      getJsonField(response, r'''$.slot2Status''');
  static dynamic slot3Status(dynamic response) =>
      getJsonField(response, r'''$.slot3Status''');
  static dynamic slot4Status(dynamic response) =>
      getJsonField(response, r'''$.slot4Status''');
  static dynamic slot5Status(dynamic response) =>
      getJsonField(response, r'''$.slot5Status''');
  static dynamic slot1First(dynamic response) =>
      getJsonField(response, r'''$.slot1First''');
  static dynamic slot1Last(dynamic response) =>
      getJsonField(response, r'''$.slot1Last''');
  static dynamic slot1Phone(dynamic response) =>
      getJsonField(response, r'''$.slot1Phone''');
  static dynamic slot2First(dynamic response) =>
      getJsonField(response, r'''$.slot2First''');
  static dynamic slot2Last(dynamic response) =>
      getJsonField(response, r'''$.slot2Last''');
  static dynamic slot2Phone(dynamic response) =>
      getJsonField(response, r'''$.slot2Phone''');
  static dynamic slot3First(dynamic response) =>
      getJsonField(response, r'''$.slot3First''');
  static dynamic slot3Last(dynamic response) =>
      getJsonField(response, r'''$.slot3Last''');
  static dynamic slot3Phone(dynamic response) =>
      getJsonField(response, r'''$.slot3Phone''');
  static dynamic slot4First(dynamic response) =>
      getJsonField(response, r'''$.slot4First''');
  static dynamic slot4Last(dynamic response) =>
      getJsonField(response, r'''$.slot4Last''');
  static dynamic slot4Phone(dynamic response) =>
      getJsonField(response, r'''$.slot4Phone''');
  static dynamic slot5First(dynamic response) =>
      getJsonField(response, r'''$.slot5First''');
  static dynamic slot5Last(dynamic response) =>
      getJsonField(response, r'''$.slot5Last''');
  static dynamic slot5Phone(dynamic response) =>
      getJsonField(response, r'''$.slot5Phone''');
}

class SyncConsentSlotsCall {
  static Future<ApiCallResponse> call({
    String? jwt = '',
    dynamic slotsJsonJson,
  }) async {
    final slotsJson = _serializeJson(slotsJsonJson, true);
    final ffApiRequestBody =
        '''
{
  "slots": ${slotsJson}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'SyncConsentSlots',
      apiUrl: supabaseFunctionUrl('syncConsentSlots'),
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
  if (item is DocumentReference) {
    return item.path;
  }
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
