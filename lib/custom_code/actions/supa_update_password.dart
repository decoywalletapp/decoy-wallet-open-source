// Automatic FlutterFlow imports
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

import 'package:supabase_flutter/supabase_flutter.dart';

/// Updates the currently-authenticated user's password.
/// Returns:
/// - "ok" on success
/// - "ERR: <message>" on failure
Future<String> supaUpdatePassword(String newPassword) async {
  try {
    final client = Supabase.instance.client;

    final p = newPassword.trim();
    if (p.isEmpty) {
      return 'ERR: missing new password';
    }
    if (p.length < 8) {
      return 'ERR: password too short';
    }

    final session = client.auth.currentSession;
    if (session == null) {
      return 'ERR: no active session (recovery session not set)';
    }

    final resp = await client.auth.updateUser(
      UserAttributes(password: p),
    );

    // Supabase sometimes returns user/session null even when successful,
    // but if no exception was thrown, treat as ok.
    return 'ok';
  } on AuthException catch (ae) {
    return 'ERR: ${ae.message}';
  } catch (e) {
    return 'ERR: $e';
  }
}
