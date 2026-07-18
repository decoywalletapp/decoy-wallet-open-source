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

import 'dart:convert';

Future<String> buildAddressPayloadV1(
  String? street,
  String? city,
  String? state,
  String? zip,
  String? apt,
  String? country,
) async {
  String s(String? v) => (v ?? '').trim();
  final m = <String, dynamic>{
    'street': s(street),
    'city': s(city),
    'state': s(state),
    'zip': s(zip),
    'apt': s(apt),
    'country': s(country),
    'version': 1,
  };
  return jsonEncode(m); // ← IMPORTANT
}
