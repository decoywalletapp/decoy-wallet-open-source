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

    // iOS needs APNs before FCM can issue a usable token. Android does not
    // have APNs, so it should go straight to the FCM token request.
    if (isiOS) {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();

      for (var i = 0; i < 6 && (apnsToken == null || apnsToken.isEmpty); i++) {
        await Future.delayed(const Duration(seconds: 2));
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      }

      if (apnsToken == null || apnsToken.isEmpty) {
        return 'APNS_NULL';
      }
    }

    // Get FCM token
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    for (var i = 0; i < 6 && (fcmToken == null || fcmToken.isEmpty); i++) {
      await Future.delayed(const Duration(seconds: 2));
      fcmToken = await FirebaseMessaging.instance.getToken();
    }

    if (fcmToken == null || fcmToken.isEmpty) {
      return 'FCM_NULL';
    }

    // Use FCM token itself as device_id
    await SupaFlow.client.rpc(
      'upsert_user_device',
      params: {
        'p_device_id': fcmToken,
        'p_platform': 'mobile',
        'p_fcm_token': fcmToken,
      },
    );

    return fcmToken;
  } catch (e) {
    return 'ERR_${e.toString()}';
  }
}
