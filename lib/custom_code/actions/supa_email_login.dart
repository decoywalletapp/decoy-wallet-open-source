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

Future<bool> supaEmailLogin(
  String email,
  String password,
) async {
  try {
    final client = Supabase.instance.client;

    final e = email.trim();
    final p = password;

    if (e.isEmpty || p.isEmpty) {
      return false;
    }

    final res = await client.auth.signInWithPassword(
      email: e,
      password: p,
    );

    // Success if session exists
    return res.session != null;
  } on AuthException {
    return false;
  } catch (_) {
    return false;
  }
}
