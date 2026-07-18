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

import 'dart:convert';

bool _isE164(String s) {
  final re = RegExp(r'^\+[1-9]\d{6,15}$');
  return re.hasMatch((s ?? '').trim());
}

Future<String> buildContactsJson(
  String c1First,
  String c1Last,
  String c1Phone,
  String c2First,
  String c2Last,
  String c2Phone,
  String c3First,
  String c3Last,
  String c3Phone,
  String c4First,
  String c4Last,
  String c4Phone,
  String c5First,
  String c5Last,
  String c5Phone,
  int contactsVisibleCount,
) async {
  final all = [
    {'fn': c1First, 'ln': c1Last, 'ph': c1Phone},
    {'fn': c2First, 'ln': c2Last, 'ph': c2Phone},
    {'fn': c3First, 'ln': c3Last, 'ph': c3Phone},
    {'fn': c4First, 'ln': c4Last, 'ph': c4Phone},
    {'fn': c5First, 'ln': c5Last, 'ph': c5Phone},
  ];

  final out = <Map<String, String>>[];
  for (var i = 0; i < contactsVisibleCount && i < all.length; i++) {
    final m = all[i];
    final ph = (m['ph'] ?? '').trim();
    if (_isE164(ph)) {
      out.add({
        'firstName': (m['fn'] ?? '').trim(),
        'lastName': (m['ln'] ?? '').trim(),
        'phoneE164': ph,
      });
    }
  }

  final res = {
    'contactsJson': jsonEncode(out), // JSON string of the array
    'validCount': out.length
  };
  return jsonEncode(res); // ONE String
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
