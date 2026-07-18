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

Future<bool> refreshSupabaseSession2(
  String accessToken,
  String refreshToken,
) async {
  try {
    final at = accessToken.trim();
    final rt = refreshToken.trim();

    if (at.isEmpty || rt.isEmpty) {
      return false;
    }

    // This is the critical part: establish the session in-app
    await Supabase.instance.client.auth.setSession(rt);

    // Extra sanity check
    final s = Supabase.instance.client.auth.currentSession;
    return s != null && (s.accessToken.isNotEmpty);
  } catch (_) {
    return false;
  }
}
