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

// Automatic FlutterFlow imports...
import 'dart:convert';

Future<String> buildPersonalJson(
  String? firstName,
  String? lastName,
  String? phone,
  String? email,
) async {
  String _s(String? v) => (v ?? '').trim();

  String _normalizePhone(String? input) {
    return normalizePhoneToE164(input);
  }

  final m = <String, dynamic>{
    'firstName': _s(firstName),
    'lastName': _s(lastName),
    'phone': _normalizePhone(phone),
    'email': _s(email),
    'version': 1,
  };

  return jsonEncode(m);
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
