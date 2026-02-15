// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';

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

    // Ensure FCM is allowed to initialize
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    // iOS: APNs token may take a moment after permission is granted.
    // Poll a few times for APNs token.
    String? apns;
    for (int i = 0; i < 10; i++) {
      apns = await FirebaseMessaging.instance.getAPNSToken();
      if (apns != null && apns.isNotEmpty) break;
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (apns == null || apns.isEmpty) {
      return 'APNS_NULL';
    }

    // Now request the FCM token
    String? fcm;
    for (int i = 0; i < 10; i++) {
      fcm = await FirebaseMessaging.instance.getToken();
      if (fcm != null && fcm.isNotEmpty) break;
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (fcm == null || fcm.isEmpty) {
      return 'FCM_NULL';
    }

    return fcm;
  } catch (e) {
    return 'ERR_${e.toString()}';
  }
}
