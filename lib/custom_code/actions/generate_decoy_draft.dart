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

const String _base58Alphabet =
    '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

Uint8List _base58Decode(String value) {
  var number = BigInt.zero;
  for (final codeUnit in value.codeUnits) {
    final index = _base58Alphabet.indexOf(String.fromCharCode(codeUnit));
    if (index < 0) {
      throw Exception('Invalid base58 character');
    }
    number = number * BigInt.from(58) + BigInt.from(index);
  }

  final bytes = <int>[];
  while (number > BigInt.zero) {
    bytes.insert(0, (number % BigInt.from(256)).toInt());
    number = number ~/ BigInt.from(256);
  }

  for (final codeUnit in value.codeUnits) {
    if (String.fromCharCode(codeUnit) == '1') {
      bytes.insert(0, 0);
    } else {
      break;
    }
  }

  return Uint8List.fromList(bytes);
}

String _base58Encode(Uint8List bytes) {
  var number = BigInt.zero;
  for (final byte in bytes) {
    number = number * BigInt.from(256) + BigInt.from(byte);
  }

  final chars = <String>[];
  while (number > BigInt.zero) {
    final remainder = (number % BigInt.from(58)).toInt();
    chars.insert(0, _base58Alphabet[remainder]);
    number = number ~/ BigInt.from(58);
  }

  for (final byte in bytes) {
    if (byte == 0) {
      chars.insert(0, '1');
    } else {
      break;
    }
  }

  return chars.join();
}

bool _bytesEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

Uint8List _base58CheckDecode(String value) {
  final decoded = _base58Decode(value);
  if (decoded.length < 5) {
    throw Exception('Invalid base58check payload');
  }

  final payload = decoded.sublist(0, decoded.length - 4);
  final checksum = decoded.sublist(decoded.length - 4);
  final expected = _sha256(_sha256(Uint8List.fromList(payload))).sublist(0, 4);
  if (!_bytesEqual(checksum, expected)) {
    throw Exception('Invalid base58check checksum');
  }

  return Uint8List.fromList(payload);
}

String _base58CheckEncode(Uint8List payload) {
  final checksum = _sha256(_sha256(payload)).sublist(0, 4);
  return _base58Encode(Uint8List.fromList([...payload, ...checksum]));
}

String _convertXpubToZpub(String xpub) {
  final payload = _base58CheckDecode(xpub);
  if (payload.length != 78) {
    throw Exception('Invalid extended public key length');
  }

  final zpub = Uint8List.fromList(payload);
  zpub[0] = 0x04;
  zpub[1] = 0xb2;
  zpub[2] = 0x47;
  zpub[3] = 0x46;
  return _base58CheckEncode(zpub);
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
    const String accountDerivationPath = "m/84'/0'/0'";
    final account = root.derivePath(accountDerivationPath);
    final xpub = account.neutered().toBase58();
    final zpub = _convertXpubToZpub(xpub);
    const String derivationPathPrefix = "$accountDerivationPath/0/";
    final List<String> addresses = <String>[];

    for (int i = 0; i < 30; i++) {
      final node = root.derivePath('$derivationPathPrefix$i');
      final pub = node.publicKey;
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
      'derivation_path': accountDerivationPath,
      'xpub': xpub,
      'zpub': zpub,
      'watch_public_key': zpub,
      'watch_public_key_type': 'bip84-account-zpub',
    };
  } catch (e) {
    return {
      'ok': false,
      'error': e.toString(),
    };
  }
}
