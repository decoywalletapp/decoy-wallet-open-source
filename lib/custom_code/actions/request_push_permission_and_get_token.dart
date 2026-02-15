// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<String> requestPushPermissionAndGetToken() async {
  try {
    // Ask permission (iOS)
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final status = settings.authorizationStatus;

    // Note: "authorized" or "provisional" can both yield a token.
    if (status == AuthorizationStatus.denied ||
        status == AuthorizationStatus.notDetermined) {
      return 'ERR_PERMISSION_$status';
    }

    // Ensure APNs token exists first (iOS requirement path)
    String? apns;
    try {
      apns = await FirebaseMessaging.instance.getAPNSToken();
    } catch (_) {
      apns = null;
    }

    // Try to get FCM token with a hard timeout so we never hang forever
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance
          .getToken()
          .timeout(const Duration(seconds: 8));
    } on TimeoutException {
      fcmToken = null;
    }

    // If token not ready yet, return a diagnostic string instead of null
    if (fcmToken == null || fcmToken.isEmpty) {
      return 'ERR_NO_FCM_TOKEN_apns=${apns ?? "null"}_auth=$status';
    }

    return fcmToken;
  } catch (e) {
    return 'ERR_EXCEPTION_${e.toString()}';
  }
}
