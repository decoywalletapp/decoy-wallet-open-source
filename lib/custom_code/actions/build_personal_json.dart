// Automatic FlutterFlow imports
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
  String s(String? v) => (v ?? '').trim();
  final m = <String, dynamic>{
    'firstName': s(firstName),
    'lastName': s(lastName),
    'phone': s(phone),
    'email': s(email),
    'version': 1,
  };
  return jsonEncode(m);
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
