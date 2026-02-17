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

  // very forgiving E.164-ish normalizer: keeps digits and a single leading +
  String _normalizePhone(String? input) {
    final raw = (input ?? '').trim();
    if (raw.isEmpty) return '';
    final digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.startsWith('+')) return '+' + digits.replaceAll('+', '');
    // if 11 digits and starts with 1, assume US
    final onlyNums = digits.replaceAll(RegExp(r'[^0-9]'), '');
    if (onlyNums.length == 11 && onlyNums.startsWith('1')) {
      return '+$onlyNums';
    }
    // fallback: just return digits
    return onlyNums;
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
