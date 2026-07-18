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

// No FlutterFlow imports needed for this action.

import 'package:supabase_flutter/supabase_flutter.dart';

/// Exchanges a Supabase email confirmation deep link for a session.
/// Returns true when a session is present after verification.
Future<bool> supaExchangeDeepLinkForSession(String link) async {
  try {
    final uri = Uri.parse(link);

    // token_hash is present in Supabase confirmation links
    final tokenHash = uri.queryParameters['token_hash'];
    if (tokenHash == null || tokenHash.isEmpty) return false;

    // Map Supabase link type -> OtpType
    final typeParam = (uri.queryParameters['type'] ?? 'signup').toLowerCase();
    final otpType = const {
          'signup': OtpType.signup,
          'magiclink': OtpType.signup,
          'recovery': OtpType.recovery,
          'invite': OtpType.invite,
          'email_change': OtpType.emailChange,
        }[typeParam] ??
        OtpType.signup;

    // Verify and hydrate session
    final supa = Supabase.instance.client;
    await supa.auth.verifyOTP(token: tokenHash, type: otpType);

    return supa.auth.currentSession != null;
  } catch (_) {
    return false;
  }
}
