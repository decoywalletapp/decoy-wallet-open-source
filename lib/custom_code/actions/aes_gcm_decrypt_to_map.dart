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
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

Uint8List _decodeB64Any(String s) {
  // tolerate url-safe and standard Base64 and missing padding
  String norm = s.replaceAll('-', '+').replaceAll('_', '/');
  final pad = norm.length % 4;
  if (pad != 0) norm = norm + ('=' * (4 - pad));
  return Uint8List.fromList(base64.decode(norm));
}

// Recursively replace nulls with empty strings in maps/lists
void _nullsToEmpty(dynamic node) {
  if (node is Map) {
    node.forEach((k, v) {
      if (v == null) {
        node[k] = '';
      } else {
        _nullsToEmpty(v);
      }
    });
  } else if (node is List) {
    for (var i = 0; i < node.length; i++) {
      final v = node[i];
      if (v == null) {
        node[i] = '';
      } else {
        _nullsToEmpty(v);
      }
    }
  }
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
    final data =
        _decodeB64Any(ciphertextB64); // expects [ciphertext || 16-byte tag]
    final nonce = _decodeB64Any(nonceB64);
    final key = SecretKey(_decodeB64Any(base64DataKey));

    if (data.length < 17) {
      return {'_ok': false, '_error': 'ciphertext too short'};
    }

    // split into ct and tag (Mac)
    final ctLen = data.length - 16;
    final ct = data.sublist(0, ctLen);
    final mac = Mac(data.sublist(ctLen));

    // decrypt
    final algo = AesGcm.with128bits();
    final box = SecretBox(ct, nonce: nonce, mac: mac);
    final bytes = await algo.decrypt(box, secretKey: key);

    // plaintext must be a JSON string (your encrypt step builds JSON)
    final obj = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;

    // sanitize: convert any nulls (including inside lists) to ''
    _nullsToEmpty(obj);

    obj['_ok'] = true;
    return obj;
  } catch (e) {
    return {'_ok': false, '_error': e.toString()};
  }
}
