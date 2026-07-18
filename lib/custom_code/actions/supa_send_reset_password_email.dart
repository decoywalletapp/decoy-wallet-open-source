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

import 'package:supabase_flutter/supabase_flutter.dart';

Future<String> supaSendResetPasswordEmail(
  String email,
  String redirectToUrl,
) async {
  try {
    final client = Supabase.instance.client;

    final e = email.trim();
    if (e.isEmpty) return 'ERR: missing email';

    // Example redirectToUrl should point at your own password reset verifier.
    await client.auth.resetPasswordForEmail(
      e,
      redirectTo: redirectToUrl.trim().isEmpty ? null : redirectToUrl.trim(),
    );

    return 'ok';
  } on AuthException catch (ae) {
    return 'ERR: ${ae.message}';
  } catch (e) {
    return 'ERR: $e';
  }
}
