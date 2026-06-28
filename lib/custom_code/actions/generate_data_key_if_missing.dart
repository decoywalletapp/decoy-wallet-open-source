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

String _newDataKey() => base64UrlEncode(_randomBytes(16));

String? _normalizeDataKey(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return null;
  }

  try {
    var normalized = trimmed.replaceAll('-', '+').replaceAll('_', '/');
    final pad = normalized.length % 4;
    if (pad != 0) {
      normalized = normalized + ('=' * (4 - pad));
    }

    final bytes = base64.decode(normalized);
    if (bytes.length != 16 && bytes.length != 32) {
      return null;
    }
    return base64UrlEncode(bytes);
  } catch (_) {
    return null;
  }
}

Future<String> _writeFreshKey(
  FlutterSecureStorage storage,
  String keyName,
) async {
  final key = _newDataKey();
  await storage.write(key: keyName, value: key);

  final confirmed = _normalizeDataKey(await storage.read(key: keyName));
  return confirmed ?? key;
}

Future<String> generateDataKeyIfMissing() async {
  const storage = FlutterSecureStorage();
  const keyName = 'decoy_data_key_b64';

  try {
    final existing = _normalizeDataKey(await storage.read(key: keyName));
    if (existing != null) {
      return existing; // keep a valid current key, do NOT overwrite
    }
  } catch (_) {
    // Android secure storage can occasionally fail to read an old key. Treat it
    // the same as a missing/invalid key and recreate below.
  }

  try {
    await storage.delete(key: keyName);
  } catch (_) {}

  try {
    return await _writeFreshKey(storage, keyName);
  } catch (_) {
    try {
      await storage.delete(key: keyName);
      return await _writeFreshKey(storage, keyName);
    } catch (_) {
      return _newDataKey();
    }
  }
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
