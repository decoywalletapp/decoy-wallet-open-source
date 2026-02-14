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

import 'package:firebase_messaging/firebase_messaging.dart';

Future<String?> requestPushPermissionAndGetToken() async {
  try {
    // iOS: this triggers the system prompt the first time it is called
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

    // Ensure FCM is allowed to auto init
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    // Get the device token (this is what you store in Supabase)
    final token = await FirebaseMessaging.instance.getToken();

    return token;
  } catch (e) {
    // If anything fails, return null so you can handle it in UI
    return null;
  }
}
