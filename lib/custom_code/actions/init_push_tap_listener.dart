// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/supabase/supabase.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

bool _pushTapListenerInitialized = false;

String? _routeFromMessage(RemoteMessage message) {
  final type = message.data['type']?.toString();
  if (type == 'entitlement_renewal_reminder') return 'renew_btcpay';
  if (type == 'entitlement_activated') return 'activated_btcpay';
  return null;
}

void _handleRenewalPushTap(BuildContext context) {
  FFAppState().openRenewalFromPush = true;

  if (FFAppState().isLocked == true) {
    return;
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final navContext = appNavigatorKey.currentContext;
    final targetContext = navContext ?? (context.mounted ? context : null);
    if (targetContext == null || !targetContext.mounted) {
      return;
    }
    FFAppState().openRenewalFromPush = false;
    targetContext.goNamed('ManageSubscription');
  });
}

Future<String?> initPushTapListener(BuildContext context) async {
  try {
    String? firstRoute;

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      firstRoute = _routeFromMessage(initialMessage);
    }

    if (!_pushTapListenerInitialized) {
      _pushTapListenerInitialized = true;

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final route = _routeFromMessage(message);
        if (route == 'renew_btcpay') {
          _handleRenewalPushTap(context);
        }
      });
    }

    return firstRoute;
  } catch (e) {
    print('initPushTapListener error: $e');
    return null;
  }
}
