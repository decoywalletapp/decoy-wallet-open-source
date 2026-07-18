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
import 'dart:math';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    // 4) Generate decoy id
    final decoyId = const Uuid().v4();

    // 5) Register with backend
    final reg = await _registerDecoy(
      serverRegistrationUrl: serverRegistrationUrl,
      decoyId: decoyId,
      xpub: xpub,
      derivationPath: derivationPath,
    );

    final ok = reg['ok'] == true;

    // Return payload
    // This does not store the mnemonic locally or in the backend.
    // It only returns it to the UI once so you can display it and run the quiz.
    return {
      'ok': ok,
      'decoyId': decoyId,
      'mnemonic': mnemonic,
      'xpub': xpub,
      'addresses': <String>[],

      // Debug info
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
