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
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    final status = settings.authorizationStatus;

    // Only treat "denied" as a hard stop.
    // "authorized" and "provisional" can both receive tokens.
    if (status == AuthorizationStatus.denied) {
      return null;
    }

    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    // On iOS, this will be non-null only if APNs + FCM are configured correctly.
    final token = await FirebaseMessaging.instance.getToken();

    return token;
  } catch (e) {
    return null;
  }
}
