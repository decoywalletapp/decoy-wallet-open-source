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

import 'dart:math' as math;
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:pointycastle/export.dart';

// -------------------- BIP173 Bech32 helpers --------------------
const String _charset = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';

int _polymod(List<int> values) {
  int chk = 1;
  const List<int> gen = <int>[
    0x3b6a57b2,
    0x26508e6d,
    0x1ea119fa,
    0x3d4233dd,
    0x2a1462b3,
  ];
  for (final v in values) {
    final top = chk >> 25;
    chk = ((chk & 0x1ffffff) << 5) ^ v;
    for (int i = 0; i < 5; i++) {
      if (((top >> i) & 1) != 0) chk ^= gen[i];
    }
  }
  return chk;
}

List<int> _hrpExpand(String hrp) {
  final List<int> ret = <int>[];
  for (int i = 0; i < hrp.length; i++) {
    ret.add(hrp.codeUnitAt(i) >> 5);
  }
  ret.add(0);
  for (int i = 0; i < hrp.length; i++) {
    ret.add(hrp.codeUnitAt(i) & 31);
  }
  return ret;
}

List<int> _createChecksum(String hrp, List<int> data) {
  final values = <int>[..._hrpExpand(hrp), ...data, 0, 0, 0, 0, 0, 0];
  final mod = _polymod(values) ^ 1;
  final List<int> ret = <int>[];
  for (int p = 0; p < 6; p++) {
    ret.add((mod >> (5 * (5 - p))) & 31);
  }
  return ret;
}

String _bech32Encode(String hrp, List<int> data) {
  final combined = <int>[...data, ..._createChecksum(hrp, data)];
  final sb = StringBuffer()
    ..write(hrp)
    ..write('1');
  for (final d in combined) {
    sb.write(_charset[d]);
  }
  return sb.toString();
}

List<int> _convertBits(List<int> data, int from, int to, {bool pad = true}) {
  int acc = 0;
  int bits = 0;
  final List<int> ret = <int>[];
  final int maxv = (1 << to) - 1;

  for (final value in data) {
    if (value < 0 || (value >> from) != 0) {
      throw Exception('convertBits invalid value');
    }
    acc = (acc << from) | value;
    bits += from;
    while (bits >= to) {
      bits -= to;
      ret.add((acc >> bits) & maxv);
    }
  }

  if (pad) {
    if (bits > 0) {
      ret.add((acc << (to - bits)) & maxv);
    }
  } else {
    if (bits >= from) throw Exception('convertBits excess padding');
    if (((acc << (to - bits)) & maxv) != 0) {
      throw Exception('convertBits non-zero padding');
    }
  }

  return ret;
}

// -------------------- HASH160 + P2WPKH --------------------
Uint8List _sha256(Uint8List data) => SHA256Digest().process(data);
Uint8List _ripemd160(Uint8List data) => RIPEMD160Digest().process(data);
Uint8List _hash160(Uint8List data) => _ripemd160(_sha256(data));

String _p2wpkhAddressFromPubkey(Uint8List compressedPubkey,
    {String hrp = 'bc'}) {
  final program = _hash160(compressedPubkey); // 20 bytes
  final payload = <int>[
    0, // witness version
    ..._convertBits(program.toList(), 8, 5, pad: true),
  ];
  return _bech32Encode(hrp, payload);
}

// -------------------- Main action --------------------
// NO arguments
// NO backend call
// Returns a draft package to drive UI + quiz
Future<dynamic> generateDecoyDraft() async {
  try {
    final mnemonic = bip39.generateMnemonic();
    final seed = bip39.mnemonicToSeed(mnemonic);

    final root = bip32.BIP32.fromSeed(seed);
    const String derivationPathPrefix = "m/84'/0'/0'/0/";
    final List<String> addresses = <String>[];

    for (int i = 0; i < 30; i++) {
      final node = root.derivePath('$derivationPathPrefix$i');
      final pub = node.publicKey;
      if (pub == null) throw Exception('Missing publicKey at index $i');
      addresses
          .add(_p2wpkhAddressFromPubkey(Uint8List.fromList(pub), hrp: 'bc'));
    }

    final decoyId = const Uuid().v4();

    return {
      'ok': true,
      'decoyId': decoyId,
      'mnemonic': mnemonic,
      'addresses': addresses,
      'addressesCount': addresses.length,
      'derivation_path': "m/84'/0'/0'",
    };
  } catch (e) {
    return {
      'ok': false,
      'error': e.toString(),
    };
  }
}
