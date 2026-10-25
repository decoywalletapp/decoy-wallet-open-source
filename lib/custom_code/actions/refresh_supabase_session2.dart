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

import '/auth/auth_link_flow.dart';

Future<bool> refreshSupabaseSession2(
  String accessToken,
  String refreshToken, {
  BuildContext? context,
}) async {
  try {
    final at = accessToken.trim();
    final rt = refreshToken.trim();

    if (at.isEmpty || rt.isEmpty) {
      return false;
    }

    final uri = Uri(path: '/authRouter', queryParameters: {
      'type': 'recovery',
      'accessToken': at,
      'refreshToken': rt,
    });
    final accepted = context == null
        ? await SupaFlow.authLinks.accept(uri,
            requestEmail: () async => null,
            mayContinue: () => !AppStateNotifier.instance.unlock.inDecoy)
        : await acceptAuthLink(context, uri);
    return accepted != null && SupaFlow.authLinks.isCurrent(accepted);
  } catch (_) {
    return false;
  }
}
