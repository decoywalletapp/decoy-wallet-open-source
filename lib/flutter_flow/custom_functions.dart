import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:ff_commons/flutter_flow/lat_lng.dart';
import 'package:ff_commons/flutter_flow/place.dart';
import 'package:ff_commons/flutter_flow/uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

String displayTenDigits(String input) {
  if (input == null) return '';
  final digits = input.replaceAll(RegExp(r'\D'), '');
  // If it's E.164 +1xxxxxxxxxx, show the last 10.
  if (digits.length == 11 && digits.startsWith('1')) return digits.substring(1);
  // If the user stored plain 10 digits, just show them.
  if (digits.length == 10) return digits;
  // Anything else -> show nothing (or you could return digits).
  return '';
}

String displayUSPhone(String? input) {
  if (input == null) return '';
  // keep only digits
  final digits = input.replaceAll(RegExp(r'\D'), '');
  // take last 10 so it works for +1XXXXXXXXXX too
  final ten =
      digits.length >= 10 ? digits.substring(digits.length - 10) : digits;
  if (ten.length != 10) return digits; // not a 10-digit US number, show as-is
  return '(${ten.substring(0, 3)}) ${ten.substring(3, 6)}-${ten.substring(6)}';
}

String displayTenFromE164(String input) {
  final d = input.replaceAll(RegExp(r'\D'), '');
  if (d.isEmpty) return '';
  if (d.length >= 11 && d.startsWith('1')) return d.substring(1, 11);
  if (d.length >= 10) return d.substring(0, 10);
  return d; // partial input while typing
}

String toE164US(String input) {
  final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return '';
  // if user/device provides 11 with leading 1
  if (digits.length >= 11 && digits.startsWith('1')) {
    final d11 = digits.substring(0, 11);
    return '+$d11';
  }
  // otherwise use last 10 as US number
  if (digits.length >= 10) {
    final last10 = digits.substring(digits.length - 10);
    return '+1$last10';
  }
  // partial typing
  return '+1$digits';
}

String formatUSPhone(String input) {
  final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return '';

  final last10 =
      digits.length >= 10 ? digits.substring(digits.length - 10) : digits;

  if (last10.length <= 3) {
    return last10;
  } else if (last10.length <= 6) {
    return '(${last10.substring(0, 3)}) ${last10.substring(3)}';
  } else {
    return '(${last10.substring(0, 3)}) ${last10.substring(3, 6)}-${last10.substring(6)}';
  }
}

String normalizeToTenDigits(String input) {
  final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length >= 11 && digits.startsWith('1')) {
    // drop leading country digit
    final core = digits.substring(1);
    return core.length >= 10 ? core.substring(0, 10) : core;
  }
  // not starting with 1; just take first 10
  return digits.length >= 10 ? digits.substring(0, 10) : digits;
}

String formatAsUsPhone(String d10) {
  final d = d10.replaceAll(RegExp(r'[^0-9]'), '');
  if (d.length < 1) return '';
  final b = StringBuffer('(')..write(d.substring(0, d.length.clamp(0, 3)));
  if (d.length > 3) {
    b.write(') ');
    b.write(d.substring(3, d.length.clamp(3, 6)));
  }
  if (d.length > 6) {
    b.write('-');
    b.write(d.substring(6, d.length.clamp(6, 10)));
  }
  return b.toString();
}

String toE164USpt2(String input) {
  final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return '';

  // Case: iOS/keyboard provides 11 with leading 1
  if (digits.length >= 11 && digits.startsWith('1')) {
    final d11 = digits.substring(0, 11); // keep only the first 11
    return '+$d11'; // +1##########
  }

  // Case: any 10+ digits → use the last 10 as US number
  if (digits.length >= 10) {
    final last10 = digits.substring(digits.length - 10);
    return '+1$last10';
  }

  // Partial typing → not yet valid
  return '';
}

int stringLength(String? s) {
  if (s == null) return 0;
  return s.length;
}

String prefix(
  String? s,
  int n,
) {
  if (s == null || n <= 0) return '';
  return s.length <= n ? s : s.substring(0, n);
}

String getQueryParam(
  String url,
  String key,
) {
  try {
    final uri = Uri.parse(url);
    return uri.queryParameters[key] ?? '';
  } catch (_) {
    return '';
  }
}

dynamic latLngToJson(LatLng? location) {
  // If we somehow don't have a location, just return null
  if (location == null) {
    return null;
  }

  // JSON-compatible map that Supabase can store in a jsonb column
  return <String, dynamic>{
    'lat': location.latitude,
    'lng': location.longitude,
  };
}

/// Returns latitude from a LatLng, or 0.0 if null (anything is fine)
double latFromLatLng(LatLng? location) {
  // if we somehow do not have a location, return 0.0
  if (location == null) {
    return 0.0;
  }

  // normal case
  return location.latitude;
}

double lngFromLatLng(LatLng? location) {
  if (location == null) {
    return 0.0;
  }

  return location.longitude;
}

String sanitizePhoneDigits(String input) {
  return input.replaceAll(RegExp(r'[^0-9]'), '');
}

double computeEmergencyProgress(
  bool? personalComplete,
  bool? addressComplete,
  bool? contactsComplete,
) {
  final count = ((personalComplete ?? false) ? 1 : 0) +
      ((addressComplete ?? false) ? 1 : 0) +
      ((contactsComplete ?? false) ? 1 : 0);

  return count / 3.0;
}

int computeEmergencyPercent(
  bool? personalComplete,
  bool? addressComplete,
  bool? contactsComplete,
) {
  final count = ((personalComplete ?? false) ? 1 : 0) +
      ((addressComplete ?? false) ? 1 : 0) +
      ((contactsComplete ?? false) ? 1 : 0);

  return ((count / 3.0) * 100).round();
}

String btcToUsdDisplay(
  String btcText,
  double btcUsdPrice,
) {
  final raw = btcText.trim();
  if (raw.isEmpty) return r'$0.00';

  // If user is mid typing "1." treat it like "1" for math.
  final normalized = raw.endsWith('.') ? raw.substring(0, raw.length - 1) : raw;

  // Keep digits and dot only.
  final cleaned =
      normalized.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), '');

  final btc = double.tryParse(cleaned) ?? 0.0;
  final usd = btc * btcUsdPrice;

  return NumberFormat.currency(symbol: r'$', decimalDigits: 2).format(usd);
}

int daysLeftFromPeriodEnd(DateTime? currentPeriodEnd) {
  if (currentPeriodEnd == null) return 0;

  final now = DateTime.now().toUtc();
  final end = currentPeriodEnd.toUtc();

  final diff = end.difference(now);
  if (diff.inSeconds <= 0) return 0;

  // Ceil to avoid showing 0 when there are hours left
  final hours = diff.inHours;
  final hasRemainder = diff.inMinutes % 60 != 0 || diff.inSeconds % 60 != 0;
  final totalHours = hours + (hasRemainder ? 1 : 0);

  final days = (totalHours / 24.0).ceil();
  return days < 0 ? 0 : days;
}

bool isEntitlementCurrentlyActive(
  bool isActive,
  DateTime? currentPeriodEnd,
) {
  // If backend already says inactive, it is inactive
  if (!isActive) {
    return false;
  }

  // If no expiration date is set, treat as active
  if (currentPeriodEnd == null) {
    return true;
  }

  // If expiration date has passed, treat as inactive
  if (currentPeriodEnd.isBefore(DateTime.now())) {
    return false;
  }

  // Otherwise it is active
  return true;
}
