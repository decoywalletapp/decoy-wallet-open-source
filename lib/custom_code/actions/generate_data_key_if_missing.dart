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

// imports that FlutterFlow already added above …

import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

List<int> _randomBytes(int len) =>
    List<int>.generate(len, (_) => Random.secure().nextInt(256));

Future<String> generateDataKeyIfMissing() async {
  const storage = FlutterSecureStorage();
  const keyName = 'decoy_data_key_b64';

  final existing = await storage.read(key: keyName);
  if (existing != null && existing.trim().isNotEmpty) {
    return existing; // keep the current key, do NOT overwrite
  }

  // 16 bytes = 128-bit key (matches your aesGcmEncryptString)
  final rnd = _randomBytes(16);
  final b64 = base64UrlEncode(rnd);
  await storage.write(key: keyName, value: b64);
  return b64;
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
