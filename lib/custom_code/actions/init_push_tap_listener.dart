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

import 'package:firebase_messaging/firebase_messaging.dart';

bool _pushTapListenerInitialized = false;

Future<String?> initPushTapListener(BuildContext context) async {
  // You can call this action on multiple pages; it will only wire listeners once.
  if (_pushTapListenerInitialized) {
    return null;
  }
  _pushTapListenerInitialized = true;

  String? routeFromMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type']?.toString();

    // This must match what you send in sendPush:
    // type: "entitlement_renewal_reminder"
    if (type == 'entitlement_renewal_reminder') {
      return 'renew_btcpay';
    }

    return null;
  }

  void handleRoute(String route) {
    // Always force the user back through your auth flow (Face ID + PIN)
    // Then Home will redirect to Manage Subscriptions based on app state.
    try {
      context.goNamed('AuthRouter');
    } catch (_) {
      // If routing fails for any reason, do nothing (avoid crashing).
    }
  }

  // Cold start: app launched from terminated by tapping push
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) {
    final r = routeFromMessage(initial);
    if (r != null) {
      handleRoute(r);
      return r;
    }
  }

  // Background: app opened by tapping push
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    final r = routeFromMessage(message);
    if (r != null) {
      handleRoute(r);
    }
  });

  return null;
}
