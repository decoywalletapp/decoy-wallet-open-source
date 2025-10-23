// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// ---------- Helpers ----------
String _safeTrim(String? s) => (s ?? '').trim();

String _normalizePhone(String? input) {
  // Very forgiving normalizer:
  // 1) strip everything except digits and '+'
  // 2) if it already starts with '+', keep it
  // 3) if 11 digits and starts with '1' -> +1XXXXXXXXXX
  // 4) if 10 digits -> assume US -> +1XXXXXXXXXX
  // 5) if starts with '00' -> replace with '+'
  final raw = (input ?? '').replaceAll(RegExp(r'[^0-9\+]'), '');
  if (raw.isEmpty) return '';

  if (raw.startsWith('+')) return raw;

  if (raw.startsWith('00') && raw.length > 2) {
    return '+${raw.substring(2)}';
  }

  final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length == 11 && digits.startsWith('1')) return '+$digits';
  if (digits.length == 10) return '+1$digits';

  // Fallback: if we have digits but no leading '+', add it
  return '+$digits';
}

Map<String, String> _contact(String? first, String? last, String? phone) {
  return {
    'first': _safeTrim(first),
    'last': _safeTrim(last),
    'phone': _normalizePhone(phone),
  };
}

bool _isEmptyContact(Map<String, String> c) {
  return (c['first']?.isEmpty ?? true) &&
      (c['last']?.isEmpty ?? true) &&
      (c['phone']?.isEmpty ?? true);
}

// ---------- Action ----------
Future<dynamic> buildContactsPayloadV2(
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
  // Build each contact
  final c1 = _contact(c1First, c1Last, c1Phone);
  final c2 = _contact(c2First, c2Last, c2Phone);
  final c3 = _contact(c3First, c3Last, c3Phone);
  final c4 = _contact(c4First, c4Last, c4Phone);
  final c5 = _contact(c5First, c5Last, c5Phone);

  // Only include up to the visible count
  final all = [c1, c2, c3, c4, c5];
  final allowed = all.take(contactsVisibleCount.clamp(0, 5)).toList();

  // Keep contacts that have at least one non-empty field
  final filtered = allowed.where((c) => !_isEmptyContact(c)).toList();

  return {
    'contacts': filtered,
    'validCount': filtered.length,
  };
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
