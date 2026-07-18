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

import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';

const _storage = FlutterSecureStorage();
final _rnd = Random.secure();

Future<Uint8List> _getDeviceKey() async {
  final existing = await _storage.read(key: 'decoy_aes_key');
  if (existing == null || existing.isEmpty) {
    throw Exception('Device key missing');
  }
  return Uint8List.fromList(base64Decode(existing));
}

Future<String> loadDecoyMnemonicFromStorage(String decoyId) async {
  if (decoyId.isEmpty) {
    throw Exception('Missing decoyId');
  }

  final ivB64 = await _storage.read(key: 'decoy_${decoyId}_iv');
  final ctB64 = await _storage.read(key: 'decoy_${decoyId}_ct');

  if (ivB64 == null || ctB64 == null) {
    throw Exception('Encrypted mnemonic not found');
  }

  final iv = base64Decode(ivB64);
  final ciphertext = base64Decode(ctB64);
  final key = await _getDeviceKey();

  final cipher = GCMBlockCipher(AESEngine())
    ..init(
      false,
      AEADParameters(
        KeyParameter(key),
        128,
        iv,
        Uint8List(0),
      ),
    );

  final plaintext = cipher.process(Uint8List.fromList(ciphertext));

  return utf8.decode(plaintext);
}
