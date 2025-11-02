// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/actions/index.dart'; // other actions

// You also need the Supabase Flutter singleton
import 'package:supabase_flutter/supabase_flutter.dart';

Future<String> supaEmailSignUp(
  String email,
  String password,
  String redirectUrl,
) async {
  try {
    final client = Supabase.instance.client;

    // sanity
    final e = (email.trim());
    final p = password;
    if (e.isEmpty || p.isEmpty) {
      return 'ERR: missing email or password';
    }

    final res = await client.auth.signUp(
      email: e,
      password: p,
      emailRedirectTo: redirectUrl, // must match your deep link host/path
    );

    // If we got here, the call returned. We expect an email to be sent.
    // We return "ok" so the flow condition can branch.
    if (res.user != null) {
      return 'ok';
    }

    // Occasionally user is null but no exception is thrown; still fine.
    return 'ok';
  } on AuthException catch (ae) {
    // Supabase auth error with message/code
    return 'ERR: ${ae.message}';
  } catch (e) {
    return 'ERR: $e';
  }
}
