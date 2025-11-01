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

  // normalize starting value
  var cur = (current ?? '').trim();
  if (cur.isEmpty || cur == '0.00000000') cur = '0';

  // backspace
  if (key == 'BACKSPACE') {
    if (cur.length <= 1) return '0';
    final next = cur.substring(0, cur.length - 1);
    return next == '' || next == '-' ? '0' : next;
  }

  // dot
  if (key == '.') {
    if (cur.contains('.')) return cur;
    return '$cur.';
  }

  // digits
  if (RegExp(r'^\d$').hasMatch(key)) {
    // enforce decimal limit
    if (cur.contains('.')) {
      final after = cur.split('.')[1];
      if (after.length >= maxDecimals) return cur;
    }
    if (cur == '0') return key; // replace leading 0
    return cur + key; // append
  }

  // default: no change
  return cur;
}

double amountToDouble(String text) {
  final t = (text ?? '').trim();
  if (t.isEmpty) return 0.0;
  final cleaned = t.replaceAll(',', '');
  final v = double.tryParse(cleaned);
  if (v == null || v.isNaN || v.isInfinite) return 0.0;
  return v < 0 ? 0.0 : v;
}

String formatBtcTrim(String text) {
  final raw = (text ?? '').trim();
  if (raw.isEmpty) return '0';

  // While typing "1." keep it as-is so the UX doesn’t jump.
  if (raw.endsWith('.')) return raw;

  // Keep digits and dot only; ignore commas etc.
  final cleaned = raw.replaceAll(',', '').replaceAll(RegExp(r'[^0-9\.]'), '');
  final v = double.tryParse(cleaned);
  if (v == null || v.isNaN || v.isInfinite) return '0';

  // Cap to 8 decimals, then trim trailing zeros and an optional trailing dot.
  String s = v.toStringAsFixed(8);
  s = s.replaceFirst(RegExp(r'\.?0+$'), '');

  return s.isEmpty ? '0' : s;
}

String usdFromBtcText(
  String btcText,
  double btcUsdPrice,
) {
  final t = (btcText ?? '').trim().replaceAll(',', '');
  final v = double.tryParse(t) ?? 0.0;
  final price = btcUsdPrice.isFinite ? btcUsdPrice : 0.0;
  final usd = v * price;
  return NumberFormat.currency(symbol: '\$').format(usd);
}

double estimateFeeBtc(
  int feeRateSatVb,
  int inputs,
  int outputs,
) {
  final fr = feeRateSatVb <= 0 ? 1 : feeRateSatVb;
  // simple P2WPKH size model
  final vbytes = (inputs * 68) + (outputs * 31) + 10;
  final sats = vbytes * fr;
  return sats / 100000000.0; // BTC
}

String totalAfterFee(
  String btcText,
  double feeBtc,
) {
  final v = double.tryParse((btcText ?? '').replaceAll(',', '')) ?? 0.0;
  final fee = feeBtc.isFinite ? feeBtc : 0.0;
  final t = v - fee;
  if (t <= 0) return '0';
  final s = t.toStringAsFixed(8);
  return s.replaceFirst(RegExp(r'\.?0+$'), '');
}

String maskAddress(
  String addr,
  int head,
  int tail,
) {
  final a = (addr ?? '').trim();
  if (a.isEmpty) return '';
  final h = head < 0 ? 0 : head;
  final t = tail < 0 ? 0 : tail;
  if (a.length <= h + t) return a;
  return '${a.substring(0, h)}...${a.substring(a.length - t)}';
}

double alignXFromPercent(double p) {
  // map 0..100 → -1..1 (Align.x)
  final clamped = p < 0 ? 0 : (p > 100 ? 100 : p);
  return -1.0 + 2.0 * (clamped / 100.0);
}

bool shouldSeed(
  bool? seeded,
  double? btc,
) {
  final s = (seeded == true);
  final b = btc ?? 0.0;
  return (!s) || (b <= 0.0);
}

List<double> extractPriceList(List<dynamic> pricesJson) {
  final out = <double>[];
  for (final row in pricesJson) {
    try {
      final price = (row is List && row.length > 1) ? row[1] : row;
      out.add((price as num).toDouble());
    } catch (_) {
      // skip bad rows
    }
  }
  return out;
}

List<double> extractEpochMsList(List<dynamic> pricesJson) {
  final out = <double>[];
  for (final row in pricesJson) {
    try {
      final ts = (row is List && row.isNotEmpty) ? row[0] : row;
      out.add((ts as num).toDouble());
    } catch (_) {
      // skip bad rows
    }
  }
  return out;
}

int remainingForm(
  int total,
  int elapsed,
) {
  final r = total - elapsed;
  return r < 0 ? 0 : r;
}

double progressForm(
  int elapsed,
  int total,
) {
  if (total <= 0) return 0.0;
  final p = elapsed / total; // int / int is double in Dart
  if (p < 0) return 0.0;
  if (p > 1) return 1.0;
  return p;
}

int incElapsedFromStart(
  DateTime startAt,
  DateTime nowTs,
) {
  final ms = nowTs.millisecondsSinceEpoch - startAt.millisecondsSinceEpoch;
  final mins = ms ~/ 60000; // integer division
  return mins < 0 ? 0 : mins;
}

String plusOneToString(int v) {
  return (v + 1).toString();
}

String safeStr(String? v) {
  if (v == null) return '';
  final t = v.trim();
  if (t.toLowerCase() == 'null') return '';
  return t;
}

String normalizeEmail(String? v) {
  final s = (v ?? '').trim();
  return s.toLowerCase();
}
