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

import 'dart:convert';
import 'package:http/http.dart' as http;

String get _deleteAccountUrl =>
    '${requiredPublicConfig('DECOY_PAYMENT_BASE_URL', kPaymentBaseUrl)}/delete-account-and-cancel-billing';

Future<bool?> deleteCurrentUserAccount() async {
  try {
    final supabase = SupaFlow.client;
    final jwt = supabase.auth.currentSession?.accessToken;
    final userId = supabase.auth.currentUser?.id;

    if (jwt == null || jwt.isEmpty || userId == null || userId.isEmpty) {
      return false;
    }

    final response = await http.post(
      Uri.parse(_deleteAccountUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode({'user_id': userId}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return false;
    }

    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      return body['ok'] == true && body['deleted'] == true;
    }

    return false;
  } catch (e) {
    // Log the error so you can see it in Test Mode
    print('Error deleting account: $e');
    return false;
  }
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
