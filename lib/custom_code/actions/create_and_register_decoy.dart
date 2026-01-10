// Automatic FlutterFlow imports
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

// Action: createAndRegisterDecoy (TANK VERSION)
// Inputs: pin (unused), serverRegistrationUrl
// Auth: Supabase session access token (Authorization: Bearer <jwt>)
// Returns: JSON with ok(bool), decoyId, xpub, addresses([])

import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------- Device-key helpers (Option B) ----------------
const _storage = FlutterSecureStorage();
final _rnd = Random.secure();

Future<Uint8List> _getOrCreateDeviceKey() async {
  final existing = await _storage.read(key: 'decoy_aes_key');
  if (existing != null && existing.isNotEmpty) {
    return Uint8List.fromList(base64Decode(existing));
  }
  final key =
      Uint8List.fromList(List<int>.generate(32, (_) => _rnd.nextInt(256)));
  await _storage.write(key: 'decoy_aes_key', value: base64Encode(key));
  return key;
}

Future<Map<String, String>> _encryptMnemonicDeviceKey(String mnemonic) async {
  final key = await _getOrCreateDeviceKey();
  final iv =
      Uint8List.fromList(List<int>.generate(12, (_) => _rnd.nextInt(256)));
  final cipher = GCMBlockCipher(AESEngine())
    ..init(true, AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)));
  final ct = cipher.process(Uint8List.fromList(utf8.encode(mnemonic)));
  return {
    'salt': '',
    'iv': base64Encode(iv),
    'ciphertext': base64Encode(ct),
  };
}

Future<void> _saveEncryptedLocally(
    String decoyId, Map<String, String> enc) async {
  final baseKey = 'decoy_$decoyId';
  await _storage.write(key: '${baseKey}_iv', value: enc['iv']);
  await _storage.write(key: '${baseKey}_ct', value: enc['ciphertext']);
  await _storage.write(key: '${baseKey}_salt', value: enc['salt'] ?? '');
}

// ---------------- Backend registration (JWT header auth) ----------------
Future<bool> _registerDecoy({
  required String serverRegistrationUrl,
  required String decoyId,
  required String xpub,
  required String derivationPath,
}) async {
  // Supabase access token from current session
  final jwt = Supabase.instance.client.auth.currentSession?.accessToken;
  if (jwt == null || jwt.isEmpty) {
    throw Exception('Missing Supabase session token');
  }

  final body = jsonEncode({
    'id': decoyId,
    'xpub': xpub,
    'derivation_path': derivationPath,
  });

  final resp = await http.post(
    Uri.parse(serverRegistrationUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwt',
    },
    body: body,
  );

  return resp.statusCode == 200 || resp.statusCode == 201;
}

// ---------------- Main action ----------------
Future<dynamic> createAndRegisterDecoy(
  String pin, // unused for device-key mode; pass "" from caller
  String serverRegistrationUrl,
) async {
  if (serverRegistrationUrl.isEmpty) {
    throw Exception('Missing serverRegistrationUrl');
  }

  // 1) Generate mnemonic + seed
  final mnemonic = bip39.generateMnemonic(); // 12 words
  final seed = bip39.mnemonicToSeed(mnemonic);

  // 2) Derive BIP84 account (mainnet): m/84'/0'/0'
  final derivationPath = "m/84'/0'/0'";
  final root = bip32.BIP32.fromSeed(seed);
  final account = root.derivePath(derivationPath);

  // 3) xpub (neutered)
  final xpub = account.neutered().toBase58();

  // 4) Encrypt mnemonic with device key and store locally
  final enc = await _encryptMnemonicDeviceKey(mnemonic);
  final decoyId = const Uuid().v4();
  await _saveEncryptedLocally(decoyId, enc);

  // 5) Register with backend (server derives addresses & deactivates old decoy)
  final ok = await _registerDecoy(
    serverRegistrationUrl: serverRegistrationUrl,
    decoyId: decoyId,
    xpub: xpub,
    derivationPath: derivationPath,
  );

  // 6) Return payload (no mnemonic)
  return {
    'ok': ok,
    'decoyId': decoyId,
    'xpub': xpub,
    'addresses': <String>[],
  };
}
