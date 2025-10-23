// Automatic FlutterFlow imports
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

Future<dynamic> buildAddressPayloadV1(
  String? street,
  String? city,
  String? state,
  String? zip,
  String? apt,
  String? country,
) async {
  // coerce null -> '' and trim
  String _s(String? v) => (v ?? '').trim();

  final m = <String, dynamic>{
    'street': _s(street),
    'city': _s(city),
    'state': _s(state),
    'zip': _s(zip),
    'apt': _s(apt),
    'country': _s(country),
    'version': 1
  };

  return m; // JSON object
}
