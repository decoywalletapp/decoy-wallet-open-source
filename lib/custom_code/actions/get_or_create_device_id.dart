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
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Returns a stable, random per-install device identifier.
/// Tank notes:
/// - Stored locally in Keychain/Keystore via flutter_secure_storage.
/// - Not derived from hardware identifiers (avoids privacy issues and OS restrictions).
/// - Safe to keep in App State too, but the source of truth is secure storage.
Future<String> getOrCreateDeviceId() async {
  const storage = FlutterSecureStorage();
  const storageKey = 'decoy_device_id_v1';

  // 1) Try to load existing
  final existing = await storage.read(key: storageKey);
  if (existing != null && existing.trim().isNotEmpty) {
    return existing.trim();
  }

  // 2) Create a new random UUID v4, then hash it (nice-to-have)
  // Hashing is optional, but it makes the stored value opaque.
  final raw = const Uuid().v4();
  final hashed = sha256.convert(utf8.encode(raw)).toString();

  // 3) Persist
  await storage.write(key: storageKey, value: hashed);

  return hashed;
}
