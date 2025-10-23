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
import 'package:cryptography/cryptography.dart';

Future<dynamic> aesGcmDecryptToMap(
  String ciphertextB64,
  String nonceB64,
  String base64DataKey,
) async {
  // parse inputs
  final data = base64Url.decode(ciphertextB64);
  final nonce = base64Url.decode(nonceB64);
  final key = SecretKey(base64Url.decode(base64DataKey));

  // split data = ciphertext || mac(16)
  if (data.length < 17) {
    throw Exception('ciphertext too short');
  }
  final ctLen = data.length - 16;
  final ct = data.sublist(0, ctLen);
  final mac = Mac(data.sublist(ctLen));

  // decrypt
  final algo = AesGcm.with128bits();
  final box = SecretBox(ct, nonce: nonce, mac: mac);
  final bytes = await algo.decrypt(box, secretKey: key);

  // plaintext is a JSON string (from your encrypt action)
  final obj = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  return obj; // Return JSON so FlutterFlow can JSON-path it
}
