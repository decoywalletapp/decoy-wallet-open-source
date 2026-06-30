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

// helpers
String _s(String? v) => (v ?? '').trim();

String _normalizePhone(String? input) {
  return normalizePhoneToE164(input);
}

String _normalizeConsentStatus(String? status) {
  final s = _s(status).toLowerCase();

  switch (s) {
    case 'confirmed':
      return 'confirmed';
    case 'pending':
      return 'pending';
    case 'denied':
      return 'denied';
    case 'opted out':
    case 'opted_out':
      return 'opted_out';
    case 'not sent':
    case 'not_sent':
    default:
      return 'not_sent';
  }
}

Map<String, dynamic> _contact(
  int slot,
  String? f,
  String? l,
  String? p,
  String? status,
) =>
    {
      'slot': slot,
      'first': _s(f),
      'last': _s(l),
      'phone': _normalizePhone(p),
      'consent_status': _normalizeConsentStatus(status),
    };

bool _isEmptyContact(Map<String, dynamic> c) =>
    (_s(c['first']?.toString()).isEmpty) &&
    (_s(c['last']?.toString()).isEmpty) &&
    (_s(c['phone']?.toString()).isEmpty);

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
  String? c1Status,
  String? c2Status,
  String? c3Status,
  String? c4Status,
  String? c5Status,
) async {
  final c1 = _contact(1, c1First, c1Last, c1Phone, c1Status);
  final c2 = _contact(2, c2First, c2Last, c2Phone, c2Status);
  final c3 = _contact(3, c3First, c3Last, c3Phone, c3Status);
  final c4 = _contact(4, c4First, c4Last, c4Phone, c4Status);
  final c5 = _contact(5, c5First, c5Last, c5Phone, c5Status);

  final all = [c1, c2, c3, c4, c5];
  final allowed = all.take(contactsVisibleCount.clamp(0, 5)).toList();
  final filtered = allowed.where((c) => !_isEmptyContact(c)).toList();

  final out = {
    'version': 2,
    'contacts': filtered,
    'validCount': filtered.length,
  };

  return jsonEncode(out);
}
