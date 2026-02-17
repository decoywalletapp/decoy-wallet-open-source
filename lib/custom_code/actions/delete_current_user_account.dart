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

Future<bool?> deleteCurrentUserAccount() async {
  // Call the Supabase RPC function that deletes the current user account
  try {
    final supabase = SupaFlow.client;
    final response = await supabase.rpc('delete_current_user_account');

    // If you want to log the whole response for debugging:
    // print('Delete account RPC response: $response');

    // Supabase RPC throws on error, so if we got here it likely worked
    return true;
  } catch (e) {
    // Log the error so you can see it in Test Mode
    print('Error deleting account: $e');
    return false;
  }
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
