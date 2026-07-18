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

/// Encrypts [plaintext] with an AES-GCM 128-bit key provided as base64url.
///
/// Returns a JSON object: { ciphertextB64, nonceB64, version }

// imports stay the same
import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';

List<int> _randomBytes(int len) =>
    List<int>.generate(len, (_) => Random.secure().nextInt(256));

List<int> _decodeB64Any(String s) {
  var normalized = s.replaceAll('-', '+').replaceAll('_', '/');
  final pad = normalized.length % 4;
  if (pad != 0) {
    normalized = normalized + ('=' * (4 - pad));
  }
  return base64.decode(normalized);
}

Future<dynamic> aesGcmEncryptString(
  String plaintext,
  String base64DataKey,
) async {
  final keyBytes = _decodeB64Any(base64DataKey);

  // Choose AES-GCM variant from key length: 16 -> 128-bit, 32 -> 256-bit
  final AesGcm algo = (keyBytes.length == 32)
      ? AesGcm.with256bits()
      : AesGcm.with128bits(); // default to 128

  final secretKey = SecretKey(keyBytes);
  final nonce = _randomBytes(12);

  final box = await algo.encrypt(
    utf8.encode(plaintext),
    secretKey: secretKey,
    nonce: nonce,
  );

  return <String, dynamic>{
    'ciphertextB64': base64UrlEncode(box.cipherText + box.mac.bytes),
    'nonceB64': base64UrlEncode(nonce),
    'version': 1,
  };
}
