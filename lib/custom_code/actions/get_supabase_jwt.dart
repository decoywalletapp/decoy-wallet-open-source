// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:supabase_flutter/supabase_flutter.dart';

Future<String> getSupabaseJwt() async {
  final supa = Supabase.instance.client;

  // Try current session token
  String? token = supa.auth.currentSession?.accessToken;

  // If missing/expired, try a one-time refresh
  if (token == null || token.isEmpty) {
    try {
      final refreshed = await supa.auth.refreshSession();
      token = refreshed.session?.accessToken;
    } catch (_) {
      // ignore; we'll return empty
    }
  }

  return token ?? '';
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
