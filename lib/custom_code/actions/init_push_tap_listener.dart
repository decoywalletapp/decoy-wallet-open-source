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

import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';

bool _tapListenerInitialized = false;
String? _lastPushRoute;

Future<String?> initPushTapListener(BuildContext context) async {
  try {
    if (_tapListenerInitialized) {
      return _lastPushRoute;
    }
    _tapListenerInitialized = true;

    // If app was opened by tapping a notification while terminated
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final type = initialMessage.data['type']?.toString();
      _lastPushRoute = type;
      return _lastPushRoute;
    }

    // If app is in background and user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final type = message.data['type']?.toString();
      _lastPushRoute = type;
    });

    return _lastPushRoute;
  } catch (e) {
    return null;
  }
}
