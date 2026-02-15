import 'dart:async';

import 'serialization_util.dart';

import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';


final _handledMessageIds = <String?>{};

class PushNotificationsHandler extends StatefulWidget {
  const PushNotificationsHandler({Key? key, required this.child})
      : super(key: key);

  final Widget child;

  @override
  _PushNotificationsHandlerState createState() =>
      _PushNotificationsHandlerState();
}

class _PushNotificationsHandlerState extends State<PushNotificationsHandler> {
  bool _loading = false;

  Future handleOpenedPushNotification() async {
    if (isWeb) {
      return;
    }

    final notification = await FirebaseMessaging.instance.getInitialMessage();
    if (notification != null) {
      await _handlePushNotification(notification);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handlePushNotification);
  }

  Future _handlePushNotification(RemoteMessage message) async {
    if (_handledMessageIds.contains(message.messageId)) {
      return;
    }
    _handledMessageIds.add(message.messageId);

    safeSetState(() => _loading = true);
    try {
      final initialPageName = message.data['initialPageName'] as String;
      final initialParameterData = getInitialParameterData(message.data);
      final parametersBuilder = parametersBuilderMap[initialPageName];
      if (parametersBuilder != null) {
        final parameterData = await parametersBuilder(initialParameterData);
        if (mounted) {
          context.pushNamed(
            initialPageName,
            pathParameters: parameterData.pathParameters,
            extra: parameterData.extra,
          );
        } else {
          appNavigatorKey.currentContext?.pushNamed(
            initialPageName,
            pathParameters: parameterData.pathParameters,
            extra: parameterData.extra,
          );
        }
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      safeSetState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      handleOpenedPushNotification();
    });
  }

  @override
  Widget build(BuildContext context) => _loading
      ? Center(
          child: LinearProgressIndicator(
            color: FlutterFlowTheme.of(context).primary,
          ),
        )
      : widget.child;
}

class ParameterData {
  const ParameterData(
      {this.requiredParams = const {}, this.allParams = const {}});
  final Map<String, String?> requiredParams;
  final Map<String, dynamic> allParams;

  Map<String, String> get pathParameters => Map.fromEntries(
        requiredParams.entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
  Map<String, dynamic> get extra => Map.fromEntries(
        allParams.entries.where((e) => e.value != null),
      );

  static Future<ParameterData> Function(Map<String, dynamic>) none() =>
      (data) async => ParameterData();
}

final parametersBuilderMap =
    <String, Future<ParameterData> Function(Map<String, dynamic>)>{
  'LoginPage': (data) async => ParameterData(
        allParams: {
          'type': getParameter<String>(data, 'type'),
          'accessToken': getParameter<String>(data, 'accessToken'),
          'refreshToken': getParameter<String>(data, 'refreshToken'),
        },
      ),
  'CreateAccount': ParameterData.none(),
  'ForgotPasswordPage': ParameterData.none(),
  'UpdatePasswordPage': (data) async => ParameterData(
        allParams: {
          'type': getParameter<String>(data, 'type'),
          'accessToken': getParameter<String>(data, 'accessToken'),
          'refreshToken': getParameter<String>(data, 'refreshToken'),
        },
      ),
  'Settings': ParameterData.none(),
  'HomePage': ParameterData.none(),
  'CreatePin': ParameterData.none(),
  'PINPage': ParameterData.none(),
  'PhoneNumberVerification': (data) async => ParameterData(
        allParams: {
          'cleanPhone': getParameter<String>(data, 'cleanPhone'),
        },
      ),
  'DuressScanQRv2': ParameterData.none(),
  'DuressSendBTC': ParameterData.none(),
  'DuressConfirmTransactionSend': ParameterData.none(),
  'DuressTransactionInitiated': ParameterData.none(),
  'DuressProcessingTransaction': (data) async => ParameterData(
        allParams: {
          'amountBtc': getParameter<String>(data, 'amountBtc'),
          'toAddress': getParameter<String>(data, 'toAddress'),
          'feeBtc': getParameter<double>(data, 'feeBtc'),
        },
      ),
  'DuressHomePage': ParameterData.none(),
  'DuressSettingsPage': ParameterData.none(),
  'ShowDecoySeedPhrase': (data) async => ParameterData(
        allParams: {
          'mnemonic': getParameter<String>(data, 'mnemonic'),
          'decoyId': getParameter<String>(data, 'decoyId'),
        },
      ),
  'DecoySeedAcknowledgements': ParameterData.none(),
  'phoneNumberInput': ParameterData.none(),
  'confirmEmailPage': (data) async => ParameterData(
        allParams: {
          'emailEntry': getParameter<String>(data, 'emailEntry'),
        },
      ),
  'CreateAccount-B4Change': ParameterData.none(),
  'DuressScanQR': ParameterData.none(),
  'CreateDecoyPin': ParameterData.none(),
  'GenerateDecoySeedPhrase': ParameterData.none(),
  'SeedPhraseVerification': (data) async => ParameterData(
        allParams: {
          'decoyId': getParameter<String>(data, 'decoyId'),
          'mnemonic': getParameter<String>(data, 'mnemonic'),
        },
      ),
  'CreateDecoyEmergencyContactsSetup': ParameterData.none(),
  'HomeAddressEntryPage': ParameterData.none(),
  'EmergencyContacts': ParameterData.none(),
  'BiometricVerification': ParameterData.none(),
  'PersonalInformation': ParameterData.none(),
  'AuthRouter': (data) async => ParameterData(
        allParams: {
          'type': getParameter<String>(data, 'type'),
          'accessToken': getParameter<String>(data, 'accessToken'),
          'refreshToken': getParameter<String>(data, 'refreshToken'),
        },
      ),
  'changeEmailRouter': (data) async => ParameterData(
        allParams: {
          'type': getParameter<String>(data, 'type'),
        },
      ),
  'ChangePin': ParameterData.none(),
  'SupportTicket': ParameterData.none(),
  'ControlCenter': ParameterData.none(),
  'DecoyPinSystemValues': ParameterData.none(),
  'DecoySeedSystemValues': ParameterData.none(),
  'DeleteUserAccount': ParameterData.none(),
  'DuressOrderProcessed': (data) async => ParameterData(
        allParams: {
          'amountBtc': getParameter<String>(data, 'amountBtc'),
          'toAddress': getParameter<String>(data, 'toAddress'),
          'feeBtc': getParameter<double>(data, 'feeBtc'),
        },
      ),
  'TermsofUse': ParameterData.none(),
  'DecoyPinAcknowledgements': ParameterData.none(),
  'PrivacyPolicy': ParameterData.none(),
  'SubscriptionOptions': ParameterData.none(),
  'PaymentReturn': ParameterData.none(),
  'ManageSubscription': ParameterData.none(),
  'Tutorials': ParameterData.none(),
  'LocationAuthorization': ParameterData.none(),
  'letsssseeeeeoldemscontact': ParameterData.none(),
  'phoneNumberInputCopy': ParameterData.none(),
  'EMSCONTOLD': ParameterData.none(),
  'EmergencyContactsCopy': ParameterData.none(),
  'AuthRouterCopy': (data) async => ParameterData(
        allParams: {
          'type': getParameter<String>(data, 'type'),
          'accessToken': getParameter<String>(data, 'accessToken'),
          'refreshToken': getParameter<String>(data, 'refreshToken'),
        },
      ),
  'LoginPageB44444': (data) async => ParameterData(
        allParams: {
          'type': getParameter<String>(data, 'type'),
          'accessToken': getParameter<String>(data, 'accessToken'),
          'refreshToken': getParameter<String>(data, 'refreshToken'),
        },
      ),
  'DuressHomePageCopy': ParameterData.none(),
  'CreateDecoyEmergencyContactsSetupCopy': ParameterData.none(),
  'HomePageCopy': ParameterData.none(),
};

Map<String, dynamic> getInitialParameterData(Map<String, dynamic> data) {
  try {
    final parameterDataStr = data['parameterData'];
    if (parameterDataStr == null ||
        parameterDataStr is! String ||
        parameterDataStr.isEmpty) {
      return {};
    }
    return jsonDecode(parameterDataStr) as Map<String, dynamic>;
  } catch (e) {
    print('Error parsing parameter data: $e');
    return {};
  }
}
