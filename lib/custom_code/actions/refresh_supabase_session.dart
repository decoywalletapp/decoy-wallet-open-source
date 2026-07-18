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

import 'package:supabase_flutter/supabase_flutter.dart';

Future<dynamic> refreshSupabaseSession() async {
  try {
    final client = Supabase.instance.client;

    // If there is no session, nothing to refresh.
    final session = client.auth.currentSession;
    if (session == null) {
      return {
        'ok': false,
        'reason': 'no_session',
        'email': null,
      };
    }

    // Force a refresh token exchange to get a fresh user object.
    final refreshed = await client.auth.refreshSession();

    final email = refreshed.user?.email ?? client.auth.currentUser?.email;

    return {
      'ok': true,
      'reason': 'refreshed',
      'email': email,
    };
  } catch (e) {
    return {
      'ok': false,
      'reason': 'error',
      'error': e.toString(),
      'email': null,
    };
  }
}
