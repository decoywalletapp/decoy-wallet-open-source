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

double randomBtc(
  double min,
  double max,
  int decimals,
) {
  // guard rails
  final lo = min;
  final hi = (max <= min) ? (min + 0.000001) : max;
  final d = decimals.clamp(0, 8); // num

  final r = lo + (hi - lo) * math.Random().nextDouble();
  final f = math.pow(10, d).toDouble(); // double
  return (r * f).round() / f;
}

double usdFromBtc(
  double btc,
  double price,
) {
  // Defensive guards so we never crash or return NaN/Infinity.

  final p = (price ?? 0).toDouble();
  final b = (btc.isNaN || btc.isInfinite) ? 0.0 : btc;
  final result = b * p;
  if (result.isNaN || result.isInfinite) return 0.0;
  return result;
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

String? formatBtc(String? text) {
  // Trim and handle empty
  final t = (text ?? '').trim();
  if (t.isEmpty) return '0.00000000';

  // Allow commas or stray characters from paste
  final cleaned = t
      .replaceAll(',', '')
      .replaceAll(RegExp(r'[^0-9\.]'), ''); // keep digits and decimal point

  final v = double.tryParse(cleaned);
  if (v == null || v.isNaN || v.isInfinite) {
    return '0.00000000';
  }

  // No negatives for send amount
  final n = v < 0 ? 0.0 : v;

  // Always show 8 decimals
  return n.toStringAsFixed(8);
}

String applyKey(
  String current,
  String key,
  int maxDecimals,
) {
  // Helper defined BEFORE use (as a local function)
  String _normalize(String s) {
    if (s.contains('.')) {
      final parts = s.split('.');
      final intPart = parts[0].replaceFirst(RegExp(r'^0+(?=\d)'), '');
      final normInt = intPart.isEmpty ? '0' : intPart;
      final dec = parts[1];
      return dec.isEmpty ? normInt : '$normInt.$dec';
    } else {
      final intPart = s.replaceFirst(RegExp(r'^0+(?=\d)'), '');
      return intPart.isEmpty ? '0' : intPart;
    }
  }

  String cur = (current ?? '').trim();
  if (cur.isEmpty) cur = '0';

  // sanitize maxDecimals
  final md = (maxDecimals <= 0 || maxDecimals > 18) ? 8 : maxDecimals;

  // Backspace
  if (key == 'BACKSPACE') {
    if (cur.length <= 1) return '0';
    cur = cur.substring(0, cur.length - 1);
    if (cur.endsWith('.')) cur = cur.substring(0, cur.length - 1);
    return _normalize(cur);
  }

  // Decimal point
  if (key == '.') {
    if (cur.contains('.')) return cur; // ignore second dot
    return cur == '0' ? '0.' : '$cur.';
  }

  // Digits
  if (RegExp(r'^\d$').hasMatch(key)) {
    if (cur.contains('.')) {
      final after = cur.split('.')[1];
      if (after.length >= md) return cur; // enforce decimal limit
    }
    if (cur == '0') return key == '0' ? '0' : key; // replace leading 0
    return _normalize('$cur$key');
  }

  // Unknown key: no change
  return cur;
}
