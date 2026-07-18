// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/public_config.dart';
import '/backend/supabase/supabase.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> supaSignUpWithRedirect(String email, String password) async {
  final client = Supabase.instance.client;

  final redirect = requiredPublicConfig(
    'DECOY_EMAIL_CONFIRM_DEEP_LINK',
    kEmailConfirmDeepLink,
  );

  await client.auth.signUp(
    email: email,
    password: password,
    emailRedirectTo: redirect,
  );
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
