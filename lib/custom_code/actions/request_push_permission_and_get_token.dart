// Automatic FlutterFlow imports
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

Future<String?> requestPushPermissionAndGetToken() async {
  try {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return 'DENIED';
    }

    // Force registration and fetch APNs token first (iOS)
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    String? apns;
    try {
      apns = await FirebaseMessaging.instance.getAPNSToken();
    } catch (_) {
      apns = null;
    }

    // If APNs token is missing, return a clear debug string
    if (apns == null || apns.isEmpty) {
      return 'APNS_NULL';
    }

    final fcm = await FirebaseMessaging.instance.getToken();
    if (fcm == null || fcm.isEmpty) {
      return 'FCM_NULL';
    }

    // Return both so you can see exactly what happened
    return 'APNS:$apns\nFCM:$fcm';
  } catch (e) {
    return 'ERR:$e';
  }
}
