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

import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

Future<dynamic> finalizeRegisterDecoy(
  String decoyId,
  String derivationPath,
  List<String> addresses,
) async {
  try {
    final jwt = Supabase.instance.client.auth.currentSession?.accessToken;
    if (jwt == null || jwt.isEmpty) {
      return {
        'ok': false,
        'status': -1,
        'error': 'Missing Supabase session token',
      };
    }

    if (decoyId.isEmpty)
      return {'ok': false, 'status': -1, 'error': 'Missing decoyId'};
    if (addresses.isEmpty)
      return {'ok': false, 'status': -1, 'error': 'Missing addresses'};

    final body = jsonEncode({
      'id': decoyId,
      'derivation_path': derivationPath,
      'addresses': addresses,
    });

    final resp = await http.post(
      Uri.parse(supabaseFunctionUrl('register-decoy')),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: body,
    );

    final ok = resp.statusCode == 200 || resp.statusCode == 201;
    return {
      'ok': ok,
      'status': resp.statusCode,
      'body': resp.body,
      'error': ok ? '' : resp.body,
    };
  } catch (e) {
    return {'ok': false, 'status': -1, 'error': e.toString()};
  }
}
