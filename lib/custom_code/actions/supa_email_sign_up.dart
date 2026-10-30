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

import '/custom_code/actions/index.dart'; // other actions

// You also need the Supabase Flutter singleton
import '/services/account_balance.dart';

Future<String> supaEmailSignUp(
  String email,
  String password,
  String redirectUrl,
) async {
  SupaFlow.cancelPendingAuthLinks();
  try {
    final e = email.trim();
    final p = password.trim();

    if (e.isEmpty || p.isEmpty) {
      return 'ERR: missing email or password';
    }

    if (p.length < 10) {
      return 'ERR: password too short';
    }

    final res = await SupaFlow.authLinks.signUp(
      email: e,
      password: p,
      emailRedirectTo: redirectUrl,
      data: accountBalanceSignupData,
    );

    if (res.user != null) return 'ok';
    return 'ok';
  } on AuthException catch (ae) {
    return 'ERR: ${ae.message}';
  } catch (e) {
    return 'ERR: $e';
  }
}
