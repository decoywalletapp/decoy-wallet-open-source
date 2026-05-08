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

Future<dynamic> supaRecoveryUpdatePassword(
  String accessToken,
  String refreshToken,
  String newPassword,
) async {
  final client = Supabase.instance.client;

  try {
    final rt = refreshToken.trim();
    final pw = newPassword;

    if (rt.isEmpty) {
      return {'ok': false, 'error': 'Missing refreshToken'};
    }
    if (pw.isEmpty || pw.length < 10) {
      return {'ok': false, 'error': 'Password must be at least 10 characters'};
    }

    // 1) Set the recovery session in this app instance
    await client.auth.setSession(rt);

    // 2) Now the password update is authorized
    await client.auth.updateUser(
      UserAttributes(password: pw),
    );

    // Optional: sign out so user must log in with new password
    await client.auth.signOut();

    return {'ok': true, 'error': ''};
  } on AuthException catch (e) {
    return {'ok': false, 'error': e.message};
  } catch (e) {
    return {'ok': false, 'error': e.toString()};
  }
}
