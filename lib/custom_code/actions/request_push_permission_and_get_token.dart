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

import 'dart:async';
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
      return 'PERMISSION_DENIED';
    }

    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    // iOS: make sure APNs token exists first
    String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();

    // APNs token can take a moment after the permission prompt / install
    for (var i = 0; i < 6 && (apnsToken == null || apnsToken.isEmpty); i++) {
      await Future.delayed(const Duration(seconds: 2));
      apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    }

    if (apnsToken == null || apnsToken.isEmpty) {
      return 'APNS_NULL';
    }

    // Now get the FCM token (this is what you store in Supabase)
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    for (var i = 0; i < 6 && (fcmToken == null || fcmToken.isEmpty); i++) {
      await Future.delayed(const Duration(seconds: 2));
      fcmToken = await FirebaseMessaging.instance.getToken();
    }

    if (fcmToken == null || fcmToken.isEmpty) {
      return 'FCM_NULL';
    }

    return fcmToken;
  } catch (e) {
    return 'ERR_${e.toString()}';
  }
}
