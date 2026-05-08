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

import 'package:supabase_flutter/supabase_flutter.dart';

Future<bool> supaUpdatePassword(String newPassword) async {
  try {
    final pw = newPassword.trim();

    if (pw.length < 10) return false;

    final client = Supabase.instance.client;

    // This updates the currently authenticated user's password.
    // In recovery flow, the user must have a valid session already set.
    await client.auth.updateUser(
      UserAttributes(password: pw),
    );

    return true;
  } catch (_) {
    return false;
  }
}
