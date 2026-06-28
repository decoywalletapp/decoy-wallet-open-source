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
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

Uint8List _decodeB64Any(String s) {
  // tolerate url-safe and standard Base64 and missing padding
  String norm = s.replaceAll('-', '+').replaceAll('_', '/');
  final pad = norm.length % 4;
  if (pad != 0) norm = norm + ('=' * (4 - pad));
  return Uint8List.fromList(base64.decode(norm));
}

Future<dynamic> aesGcmDecryptToMap(
  String ciphertextB64,
  String nonceB64,
  String base64DataKey,
) async {
  try {
    if (ciphertextB64.isEmpty || nonceB64.isEmpty || base64DataKey.isEmpty) {
      return {'_ok': false, '_error': 'missing input'};
    }

    // decode inputs
    final data = _decodeB64Any(ciphertextB64); // [ciphertext || 16-byte tag]
    final nonce = _decodeB64Any(nonceB64);
    final keyBytes = _decodeB64Any(base64DataKey);
    if (keyBytes.length != 16 && keyBytes.length != 32) {
      return {'_ok': false, '_error': 'invalid key length'};
    }
    final key = SecretKey(keyBytes);

    if (data.length < 17) {
      return {'_ok': false, '_error': 'ciphertext too short'};
    }

    // split into ct and tag (Mac)
    final ctLen = data.length - 16;
    final ct = data.sublist(0, ctLen);
    final mac = Mac(data.sublist(ctLen));

    // decrypt
    final algo =
        keyBytes.length == 32 ? AesGcm.with256bits() : AesGcm.with128bits();
    final box = SecretBox(ct, nonce: nonce, mac: mac);
    final bytes = await algo.decrypt(box, secretKey: key);

    // plaintext must be a JSON string
    final obj = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;

    // --- SANITIZER: make sure optional fields are strings, not null ---
    // For address-like payloads
    for (final k in const [
      'street',
      'city',
      'state',
      'zip',
      'apt',
      'country'
    ]) {
      if (obj.containsKey(k)) {
        obj[k] = (obj[k] ?? '').toString();
      }
    }
    // For contacts payloads
    if (obj['contacts'] is List) {
      final list = obj['contacts'] as List;
      for (var i = 0; i < list.length; i++) {
        final c = list[i];
        if (c is Map) {
          c['first'] = (c['first'] ?? '').toString();
          c['last'] = (c['last'] ?? '').toString();
          c['phone'] = (c['phone'] ?? '').toString();
        }
      }
    }
    // For personal info payloads
    for (final k in const ['firstName', 'lastName', 'phone', 'email']) {
      if (obj.containsKey(k)) {
        obj[k] = (obj[k] ?? '').toString();
      }
    }
    // ---------------------------------------------------------------

    obj['_ok'] = true;
    return obj;
  } catch (e) {
    return {'_ok': false, '_error': e.toString()};
  }
}
