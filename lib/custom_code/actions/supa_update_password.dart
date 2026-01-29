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

Future<String> supaUpdatePassword(String newPassword) async {
  try {
    final client = Supabase.instance.client;

    final pw = newPassword.trim();
    if (pw.isEmpty) return 'ERR: missing password';
    if (pw.length < 8) return 'ERR: password too short';

    // This updates the currently active Supabase session user.
    await client.auth.updateUser(
      UserAttributes(password: pw),
    );

    return 'ok';
  } on AuthException catch (ae) {
    return 'ERR: ${ae.message}';
  } catch (e) {
    return 'ERR: $e';
  }
}
