// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';

// helpers
String _s(String? v) => (v ?? '').trim();
String _normalizePhone(String? input) {
  final raw = (input ?? '').replaceAll(RegExp(r'[^0-9+]'), '');
  if (raw.isEmpty) return '';
  if (raw.startsWith('+')) return raw;
  final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length == 11 && digits.startsWith('1')) return '+$digits';
  if (digits.length == 10) return '+1$digits';
  return '+$digits';
}

Map<String, String> _contact(String? f, String? l, String? p) => {
      'first': _s(f),
      'last': _s(l),
      'phone': _normalizePhone(p),
    };

bool _isEmptyContact(Map<String, String> c) =>
    (_s(c['first']).isEmpty) &&
    (_s(c['last']).isEmpty) &&
    (_s(c['phone']).isEmpty);

// ACTION
Future<String> buildContactsPayloadV2(
  String? c1First,
  String? c1Last,
  String? c1Phone,
  String? c2First,
  String? c2Last,
  String? c2Phone,
  String? c3First,
  String? c3Last,
  String? c3Phone,
  String? c4First,
  String? c4Last,
  String? c4Phone,
  String? c5First,
  String? c5Last,
  String? c5Phone,
  int contactsVisibleCount,
) async {
  final c1 = _contact(c1First, c1Last, c1Phone);
  final c2 = _contact(c2First, c2Last, c2Phone);
  final c3 = _contact(c3First, c3Last, c3Phone);
  final c4 = _contact(c4First, c4Last, c4Phone);
  final c5 = _contact(c5First, c5Last, c5Phone);

  final all = [c1, c2, c3, c4, c5];
  final allowed = all.take(contactsVisibleCount.clamp(0, 5)).toList();
  final filtered = allowed.where((c) => !_isEmptyContact(c)).toList();

  final out = {
    'version': 1,
    'contacts': filtered,
    'validCount': filtered.length,
  };
  return jsonEncode(out); // IMPORTANT: String
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
