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
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return null;
    }

    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    // iOS can take a moment to register with APNs/FCM after the prompt.
    // Retry a few times before returning null.
    String? token;
    for (int i = 0; i < 8; i++) {
      token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        return token;
      }
      await Future.delayed(const Duration(milliseconds: 750));
    }

    return null;
  } catch (_) {
    return null;
  }
}
