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
    final params = <String, String>{...uri.queryParameters};
    if (uri.fragment.isNotEmpty) {
      final cleanFragment = uri.fragment.startsWith('?')
          ? uri.fragment.substring(1)
          : uri.fragment;
      params.addAll(Uri.splitQueryString(cleanFragment));
    }

    final tokenHash =
        params['token_hash'] ?? params['tokenHash'] ?? params['token'];
    final authCode = params['code'] ?? params['auth_code'];
    final refreshToken = params['refresh_token'] ?? params['refreshToken'];
    final accessToken = params['access_token'] ?? params['accessToken'];

    // Map Supabase link type -> OtpType
    final typeParam = (params['type'] ?? 'signup').toLowerCase();
    final otpType = const {
          'signup': OtpType.signup,
          'magiclink': OtpType.magiclink,
          'recovery': OtpType.recovery,
          'invite': OtpType.invite,
          'email_change': OtpType.emailChange,
        }[typeParam] ??
        OtpType.signup;

    // Verify and hydrate session
    final supa = Supabase.instance.client;
    if (tokenHash != null && tokenHash.isNotEmpty) {
      await supa.auth.verifyOTP(type: otpType, tokenHash: tokenHash);
    } else if (authCode != null && authCode.isNotEmpty) {
      await supa.auth.exchangeCodeForSession(authCode);
    } else if (refreshToken != null && refreshToken.isNotEmpty) {
      await supa.auth.setSession(refreshToken);
    } else if (accessToken != null && accessToken.isNotEmpty) {
      await supa.auth.getSessionFromUrl(uri);
    } else {
      return false;
    }

    for (var attempt = 0; attempt < 20; attempt++) {
      if (supa.auth.currentSession != null) {
        return true;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return false;
  } catch (_) {
    return false;
  }
}
