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


/// Exchanges a Supabase email confirmation deep link for a session.
/// Returns true when a session is present after verification.
Future<bool> supaExchangeDeepLinkForSession(String link) async {
  try {
    final uri = Uri.parse(link);

    final accepted = await SupaFlow.authLinks.accept(uri,
        requestEmail: () async => null,
        mayContinue: () => !AppStateNotifier.instance.unlock.inDecoy);
    return accepted != null && SupaFlow.authLinks.isCurrent(accepted);
  } catch (_) {
    return false;
  }
}
