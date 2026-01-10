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

// ---------------- Device-key helpers ----------------
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

// ---------------- Backend registration (never throws) ----------------
Future<Map<String, dynamic>> _registerDecoy({
  required String serverRegistrationUrl,
  required String decoyId,
  required String xpub,
  required String derivationPath,
}) async {
  try {
    final jwt = Supabase.instance.client.auth.currentSession?.accessToken;
    if (jwt == null || jwt.isEmpty) {
      return {
        'ok': false,
        'status': -1,
        'error': 'Missing Supabase session token',
      };
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

    final ok = resp.statusCode == 200 || resp.statusCode == 201;
    return {
      'ok': ok,
      'status': resp.statusCode,
      'body': resp.body,
    };
  } catch (e) {
    return {
      'ok': false,
      'status': -1,
      'error': e.toString(),
    };
  }
}

// ---------------- Main action ----------------
Future<dynamic> createAndRegisterDecoy(
  String pin, // unused; keep for now to avoid rewiring
  String serverRegistrationUrl,
) async {
  // Never throw; always return a JSON result
  try {
    if (serverRegistrationUrl.isEmpty) {
      return {
        'ok': false,
        'regStatus': -1,
        'regError': 'Missing serverRegistrationUrl',
      };
    }

    // 1) Generate mnemonic + seed
    final mnemonic = bip39.generateMnemonic();
    final seed = bip39.mnemonicToSeed(mnemonic);

    // 2) Derive BIP84 account (mainnet): m/84'/0'/0'
    final derivationPath = "m/84'/0'/0'";
    final root = bip32.BIP32.fromSeed(seed);
    final account = root.derivePath(derivationPath);

    // 3) xpub (neutered)
    final xpub = account.neutered().toBase58();

    // 4) Encrypt mnemonic with device key (DO NOT SAVE YET)
    final enc = await _encryptMnemonicDeviceKey(mnemonic);
    final decoyId = const Uuid().v4();

    // 5) Register with backend FIRST
    final reg = await _registerDecoy(
      serverRegistrationUrl: serverRegistrationUrl,
      decoyId: decoyId,
      xpub: xpub,
      derivationPath: derivationPath,
    );

    final ok = reg['ok'] == true;

    // 6) Save locally ONLY on success (tank cleanup)
    if (ok) {
      await _saveEncryptedLocally(decoyId, enc);
    }

    // 7) Return payload (no mnemonic)
    return {
      'ok': ok,
      'decoyId': decoyId,
      'xpub': xpub,
      'addresses': <String>[],
      // Debug info (remove from UI later)
      'regStatus': reg['status'],
      'regBody': reg['body'] ?? '',
      'regError': reg['error'] ?? '',
    };
  } catch (e) {
    return {
      'ok': false,
      'regStatus': -1,
      'regError': e.toString(),
    };
  }
}
