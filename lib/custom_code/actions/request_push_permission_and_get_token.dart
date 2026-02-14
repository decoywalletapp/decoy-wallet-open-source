// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom actions
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<String?> requestPushPermissionAndGetToken() async {
  try {
    // 1) Ask permission (shows the system prompt the first time)
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    // If user denied, return null
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return null;
    }

    // 2) Ensure FCM can auto init
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    // 3) iOS: check APNs token (helps diagnose why FCM token might be null)
    // This can still be null immediately after the prompt
    String? apnsToken;
    try {
      apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    } catch (_) {
      apnsToken = null;
    }

    // 4) Try to get FCM token, with retries
    String? fcmToken;
    for (int i = 0; i < 6; i++) {
      fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null && fcmToken.trim().isNotEmpty) {
        return fcmToken;
      }
      await Future.delayed(const Duration(seconds: 2));
    }

    // If APNs token exists but FCM is still null, that points to Firebase config
    // If APNs token is null, that points to iOS registration not completing yet
    return null;
  } catch (e) {
    return null;
  }
}
