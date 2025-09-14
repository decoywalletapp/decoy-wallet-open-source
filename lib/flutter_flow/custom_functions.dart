import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:ff_commons/flutter_flow/lat_lng.dart';
import 'package:ff_commons/flutter_flow/place.dart';
import 'package:ff_commons/flutter_flow/uploaded_file.dart';
import '/backend/supabase/supabase.dart';
import '/auth/supabase_auth/auth_util.dart';

String newCustomFunction(List<String> pinList) {
  return pinList.join('');
}

String newCustomFunction2(List<String> pinList2) {
  return pinList2.join('');
}

int getPhoneNumberLength(String? phoneNumberTextField) {
  return phoneNumberTextField?.replaceAll(RegExp(r'[^\d]'), '').length ?? 0;
}

String joinVerificationCode(
  String d1,
  String d2,
  String d3,
  String d4,
  String d5,
  String d6,
) {
  return d1 + d2 + d3 + d4 + d5 + d6;
}

String sanitizePhoneNumber(String input) {
// Strip everything except digits
  final digits = input.replaceAll(RegExp(r'\D'), '');

// NANP: area code NXX and prefix NXX (N = 2–9)
  final tenDigit = RegExp(r'^[2-9]\d{2}[2-9]\d{6}$');

// Case 1: user types 10 digits
  if (tenDigit.hasMatch(digits)) {
    return '+1$digits';
  }

// Case 2: user pasted 11 digits starting with 1 (e.g. 1XXXXXXXXXX)
  if (RegExp(r'^1([2-9]\d{2}[2-9]\d{6})$').hasMatch(digits)) {
    return '+$digits';
  }

// Not a valid US number
  return '';
}

bool isCodeSixDigits(String code) {
  return code.length == 6;
}

double? percentageChange(
  double? start,
  double? end,
) {
  {
    final s = start ?? 0;
    final e = end ?? 0;
    if (s == 0) return 0;
    return (e - s) / s * 100.0;
  }
}

String formatpctLabel(double? v) {
  final x = (v ?? 0).toDouble();
  final s = x.abs().toStringAsFixed(1);
  // Use ASCII minus to avoid font issues
  final sign = x >= 0 ? '+' : '-';
  return '$sign$s%';
}

double? randomBtc(
  double? min,
  double? max,
  int? decimals,
) {
  double randomBtc(double min, double max, int decimals) {
    final rnd = (math.Random().nextDouble() * (max - min)) + min;
    final factor = math.pow(10, decimals);
    // round to N decimals (BTC commonly shown to 8)
    return (rnd * factor).round() / factor;
  }
}

double? usdFromBtc(
  double? btc,
  double? price,
) {
  final b = (btc ?? 0).toDouble();
  final p = (price ?? 0).toDouble();
  return b * p;
}

String? extractBitcoinAddress(String? input) {
  if (input == null) return '';

  String s = input.trim();

  // Strip BIP21 scheme and query if present
  if (s.toLowerCase().startsWith('bitcoin:')) {
    s = s.substring(8); // remove 'bitcoin:'
    final qIndex = s.indexOf('?');
    if (qIndex >= 0) s = s.substring(0, qIndex);
  }

  // Valid address patterns
  final bech32 = RegExp(r'^(bc1[0-9a-z]{11,71})$');
  final base58 = RegExp(r'^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$');

  if (bech32.hasMatch(s) || base58.hasMatch(s)) return s;

  // Fallback: search inside free text
  final scan = RegExp(r'(bc1[0-9a-z]{11,71}|[13][a-km-zA-HJ-NP-Z1-9]{25,34})');
  final m = scan.firstMatch(input);
  return m?.group(0) ?? '';
}

String digitsOnly(String input) {
// Keep the generated signature:
//
// String digitsOnly(String input) {
//
// Paste ONLY this body:
  final digits = input.replaceAll(RegExp(r'\D'), '');
  return digits.length <= 6 ? digits : digits.substring(0, 6);
//
// }
}
