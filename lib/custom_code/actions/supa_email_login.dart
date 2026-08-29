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

import '/build_provenance.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String? _lastSupaEmailLoginError;

void _setLastSupaEmailLoginError(String message) {
  _lastSupaEmailLoginError = message;
}

String _safeAuthExceptionMessage(AuthException error) {
  final details = <String>[error.message.trim()];
  if (error is AuthApiException) {
    final code = error.code?.trim();
    if (code != null && code.isNotEmpty) {
      details.add('code=$code');
    }
    final statusCode = error.statusCode?.toString().trim();
    if (statusCode != null && statusCode.isNotEmpty) {
      details.add('status=$statusCode');
    }
  }
  return details.where((part) => part.isNotEmpty).join(' ');
}

Future<bool> supaEmailLogin(
  String email,
  String password,
) async {
  try {
    _setLastSupaEmailLoginError('');
    final client = Supabase.instance.client;

    final e = email.trim();
    final p = password.trim();

    if (e.isEmpty || p.isEmpty) {
      _setLastSupaEmailLoginError('Missing email or password.');
      return false;
    }

    // Match your Supabase minimum password length
    if (p.length < 10) {
      _setLastSupaEmailLoginError('Password must be at least 10 characters.');
      return false;
    }

    final res = await client.auth.signInWithPassword(
      email: e,
      password: p,
    );

    if (res.session != null) {
      _setLastSupaEmailLoginError('');
      return true;
    }

    _setLastSupaEmailLoginError(
      DecoyBuildProvenance.backendEnvironment == 'staging'
          ? 'Staging login returned no Supabase session.'
          : 'Unable to log in.',
    );
    return false;
  } on AuthException catch (error) {
    _setLastSupaEmailLoginError(
      DecoyBuildProvenance.backendEnvironment == 'staging'
          ? 'Staging login failed: ${_safeAuthExceptionMessage(error)}'
          : 'Unable to log in.',
    );
    return false;
  } catch (error) {
    _setLastSupaEmailLoginError(
      DecoyBuildProvenance.backendEnvironment == 'staging'
          ? 'Staging login failed before Supabase returned a session: $error'
          : 'Unable to log in.',
    );
    return false;
  }
}

Future<String> supaLastEmailLoginError() async {
  final message = _lastSupaEmailLoginError?.trim();
  if (message == null || message.isEmpty) {
    return DecoyBuildProvenance.backendEnvironment == 'staging'
        ? 'Staging login failed without a captured Supabase error.'
        : 'Unable to log in.';
  }
  return message;
}
