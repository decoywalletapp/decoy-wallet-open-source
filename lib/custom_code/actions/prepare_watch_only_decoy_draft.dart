// ignore_for_file: unused_import

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

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:pointycastle/export.dart';
import 'package:uuid/uuid.dart';

const List<int> _xpubVersion = <int>[0x04, 0x88, 0xb2, 0x1e];
const List<int> _zpubVersion = <int>[0x04, 0xb2, 0x47, 0x46];
const String _base58Alphabet =
    '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
const String _bech32Charset = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';
const int _addressLookaheadCount = 30;

class _WatchOnlyImportException implements Exception {
  const _WatchOnlyImportException(this.message);

  final String message;

  @override
  String toString() => message;
}

Future<dynamic> prepareWatchOnlyDecoyDraft(String watchOnlyInput) async {
  try {
    return prepareWatchOnlyDecoyDraftPayload(watchOnlyInput);
  } on _WatchOnlyImportException catch (e) {
    return {
      'ok': false,
      'error': e.message,
    };
  } catch (e) {
    return {
      'ok': false,
      'error':
          'Unable to validate this watch-only wallet data. Please check the value and try again.',
    };
  }
}

Map<String, dynamic> prepareWatchOnlyDecoyDraftPayload(
  String watchOnlyInput, {
  String? decoyId,
}) {
  final input = watchOnlyInput.trim();
  if (input.isEmpty) {
    throw const _WatchOnlyImportException(
      'Paste a zpub, xpub, or one or more Bitcoin receive addresses.',
    );
  }

  _rejectSpendableSecretMaterial(input);

  final tokens = _watchOnlyTokens(input);
  final extendedKeys = tokens
      .where((token) => token.startsWith('zpub') || token.startsWith('xpub'))
      .toList();

  if (extendedKeys.length > 1) {
    throw const _WatchOnlyImportException(
      'Paste one watch-only public key at a time.',
    );
  }

  if (extendedKeys.length == 1) {
    if (tokens.length != 1) {
      throw const _WatchOnlyImportException(
        'Paste either one zpub/xpub or a list of receive addresses, not both.',
      );
    }
    return _prepareExtendedPublicKeyDraft(
      extendedKeys.single,
      decoyId: decoyId,
    );
  }

  final addresses = <String>[];
  for (final token in tokens) {
    final candidate = _extractBitcoinAddress(token);
    if (!_isValidMainnetBitcoinAddress(candidate)) {
      throw _WatchOnlyImportException(
        'This does not look like a valid mainnet Bitcoin receive address: $token',
      );
    }
    final address = _normalizeBitcoinAddress(candidate);
    if (!addresses.contains(address)) {
      addresses.add(address);
    }
  }

  if (addresses.isEmpty) {
    throw const _WatchOnlyImportException(
      'Paste at least one valid Bitcoin receive address.',
    );
  }

  final importId = decoyId ?? const Uuid().v4();
  return {
    'ok': true,
    'decoyId': importId,
    'addresses': addresses,
    'addressesCount': addresses.length,
    'derivation_path': 'imported-addresses',
    'xpub': '',
    'zpub': '',
    'watch_public_key': '',
    'watch_public_key_type': 'bitcoin-address-list',
    'source_type': 'address-list',
  };
}

void _rejectSpendableSecretMaterial(String input) {
  final normalizedWords = input
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((word) => word.trim().isNotEmpty)
      .join(' ');
  final wordCount = normalizedWords.split(' ').length;
  if (<int>{12, 15, 18, 21, 24}.contains(wordCount) &&
      bip39.validateMnemonic(normalizedWords)) {
    throw const _WatchOnlyImportException(
      'Do not paste seed phrases into Decoy. Paste only watch-only public wallet data.',
    );
  }

  final tokens = _watchOnlyTokens(input);
  for (final token in tokens) {
    if (RegExp(r'^[xtuvyz]prv').hasMatch(token.toLowerCase())) {
      throw const _WatchOnlyImportException(
        'Do not paste private extended keys into Decoy. Paste only xpub/zpub or receive addresses.',
      );
    }
    if (RegExp(r'^[5KL][1-9A-HJ-NP-Za-km-z]{50,51}$').hasMatch(token) ||
        RegExp(r'^6P[1-9A-HJ-NP-Za-km-z]{56}$').hasMatch(token)) {
      throw const _WatchOnlyImportException(
        'Do not paste private keys into Decoy. Paste only watch-only public wallet data.',
      );
    }
  }
}

List<String> _watchOnlyTokens(String input) {
  return input
      .split(RegExp(r'[\s,;]+'))
      .map((token) => token.trim())
      .where((token) => token.isNotEmpty)
      .map(_stripCommonPunctuation)
      .where((token) => token.isNotEmpty)
      .toList();
}

String _stripCommonPunctuation(String token) {
  var cleaned = token.trim();
  while (cleaned.startsWith('(') ||
      cleaned.startsWith('[') ||
      cleaned.startsWith('{') ||
      cleaned.startsWith('"') ||
      cleaned.startsWith("'")) {
    cleaned = cleaned.substring(1);
  }
  while (cleaned.endsWith('.') ||
      cleaned.endsWith(',') ||
      cleaned.endsWith(';') ||
      cleaned.endsWith(':') ||
      cleaned.endsWith(')') ||
      cleaned.endsWith(']') ||
      cleaned.endsWith('}') ||
      cleaned.endsWith('"') ||
      cleaned.endsWith("'")) {
    cleaned = cleaned.substring(0, cleaned.length - 1);
  }
  return cleaned;
}

Map<String, dynamic> _prepareExtendedPublicKeyDraft(
  String watchKey, {
  String? decoyId,
}) {
  final detectedVersion = _extendedKeyVersion(watchKey);
  final bool isZpub = _bytesEqual(detectedVersion, _zpubVersion);
  final bool isXpub = _bytesEqual(detectedVersion, _xpubVersion);
  if (!isZpub && !isXpub) {
    throw const _WatchOnlyImportException(
      'Only mainnet zpub or xpub watch-only public keys are supported in this first version.',
    );
  }

  final xpub = isZpub
      ? _convertExtendedPublicKeyVersion(watchKey, _xpubVersion)
      : watchKey;
  final zpub = isZpub
      ? watchKey
      : _convertExtendedPublicKeyVersion(watchKey, _zpubVersion);
  final account = bip32.BIP32.fromBase58(xpub);
  final externalChain = account.derive(0);
  final addresses = <String>[];

  for (var i = 0; i < _addressLookaheadCount; i++) {
    final pubkey = Uint8List.fromList(externalChain.derive(i).publicKey);
    addresses.add(_p2wpkhAddressFromPubkey(pubkey));
  }

  final importId = decoyId ?? const Uuid().v4();
  return {
    'ok': true,
    'decoyId': importId,
    'addresses': addresses,
    'addressesCount': addresses.length,
    'derivation_path': "m/84'/0'/0'",
    'xpub': xpub,
    'zpub': zpub,
    'watch_public_key': zpub,
    'watch_public_key_type': 'bip84-account-zpub',
    'source_type': isZpub ? 'zpub' : 'xpub',
  };
}

List<int> _extendedKeyVersion(String key) {
  final payload = _base58CheckDecode(key);
  if (payload.length != 78) {
    throw const _WatchOnlyImportException(
      'This extended public key is not the expected length.',
    );
  }
  return payload.sublist(0, 4);
}

String _convertExtendedPublicKeyVersion(String key, List<int> targetVersion) {
  final payload = _base58CheckDecode(key);
  if (payload.length != 78) {
    throw const _WatchOnlyImportException(
      'This extended public key is not the expected length.',
    );
  }

  final converted = Uint8List.fromList(payload);
  for (var i = 0; i < targetVersion.length; i++) {
    converted[i] = targetVersion[i];
  }
  return _base58CheckEncode(converted);
}

String _extractBitcoinAddress(String rawToken) {
  var token = rawToken.trim();
  if (token.toLowerCase().startsWith('bitcoin:')) {
    token = token.substring('bitcoin:'.length);
  }
  final queryIndex = token.indexOf('?');
  if (queryIndex >= 0) {
    token = token.substring(0, queryIndex);
  }
  return token;
}

String _normalizeBitcoinAddress(String address) {
  return address.toLowerCase().startsWith('bc1')
      ? address.toLowerCase()
      : address;
}

bool _isValidMainnetBitcoinAddress(String address) {
  return _isValidBase58MainnetAddress(address) ||
      _isValidBech32MainnetAddress(address);
}

bool _isValidBase58MainnetAddress(String address) {
  try {
    final payload = _base58CheckDecode(address);
    return payload.length == 21 &&
        (payload.first == 0x00 || payload.first == 0x05);
  } catch (_) {
    return false;
  }
}

bool _isValidBech32MainnetAddress(String address) {
  if (address.isEmpty) {
    return false;
  }
  final hasMixedCase =
      address != address.toLowerCase() && address != address.toUpperCase();
  if (hasMixedCase) {
    return false;
  }

  final lower = address.toLowerCase();
  if (!lower.startsWith('bc1')) {
    return false;
  }

  final separatorIndex = lower.lastIndexOf('1');
  if (separatorIndex < 1 || separatorIndex + 7 > lower.length) {
    return false;
  }

  final hrp = lower.substring(0, separatorIndex);
  final data = <int>[];
  for (final codeUnit in lower.substring(separatorIndex + 1).codeUnits) {
    final value = _bech32Charset.indexOf(String.fromCharCode(codeUnit));
    if (value < 0) {
      return false;
    }
    data.add(value);
  }

  final checksumType = _bech32ChecksumType(hrp, data);
  if (checksumType == null) {
    return false;
  }

  final version = data.first;
  if (version > 16) {
    return false;
  }
  final program = data.sublist(1, data.length - 6);
  List<int> decodedProgram;
  try {
    decodedProgram = _convertBits(program, 5, 8, pad: false);
  } catch (_) {
    return false;
  }

  if (decodedProgram.length < 2 || decodedProgram.length > 40) {
    return false;
  }
  if (version == 0) {
    return checksumType == _Bech32Checksum.bech32 &&
        (decodedProgram.length == 20 || decodedProgram.length == 32);
  }
  return checksumType == _Bech32Checksum.bech32m;
}

enum _Bech32Checksum { bech32, bech32m }

_Bech32Checksum? _bech32ChecksumType(String hrp, List<int> data) {
  final polymod = _polymod(<int>[..._hrpExpand(hrp), ...data]);
  if (polymod == 1) {
    return _Bech32Checksum.bech32;
  }
  if (polymod == 0x2bc830a3) {
    return _Bech32Checksum.bech32m;
  }
  return null;
}

Uint8List _base58Decode(String value) {
  var number = BigInt.zero;
  for (final codeUnit in value.codeUnits) {
    final index = _base58Alphabet.indexOf(String.fromCharCode(codeUnit));
    if (index < 0) {
      throw const _WatchOnlyImportException('Invalid base58 character.');
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

Uint8List _base58CheckDecode(String value) {
  final decoded = _base58Decode(value);
  if (decoded.length < 5) {
    throw const _WatchOnlyImportException('Invalid base58check payload.');
  }

  final payload = decoded.sublist(0, decoded.length - 4);
  final checksum = decoded.sublist(decoded.length - 4);
  final expected = _sha256(_sha256(Uint8List.fromList(payload))).sublist(0, 4);
  if (!_bytesEqual(checksum, expected)) {
    throw const _WatchOnlyImportException('Invalid base58check checksum.');
  }

  return Uint8List.fromList(payload);
}

String _base58CheckEncode(Uint8List payload) {
  final checksum = _sha256(_sha256(payload)).sublist(0, 4);
  return _base58Encode(Uint8List.fromList(<int>[...payload, ...checksum]));
}

Uint8List _sha256(Uint8List data) => SHA256Digest().process(data);
Uint8List _ripemd160(Uint8List data) => RIPEMD160Digest().process(data);
Uint8List _hash160(Uint8List data) => _ripemd160(_sha256(data));

String _p2wpkhAddressFromPubkey(Uint8List compressedPubkey) {
  final program = _hash160(compressedPubkey);
  final payload = <int>[
    0,
    ..._convertBits(program.toList(), 8, 5, pad: true),
  ];
  return _bech32Encode('bc', payload);
}

String _bech32Encode(String hrp, List<int> data) {
  final combined = <int>[...data, ..._createChecksum(hrp, data)];
  final buffer = StringBuffer()
    ..write(hrp)
    ..write('1');
  for (final value in combined) {
    buffer.write(_bech32Charset[value]);
  }
  return buffer.toString();
}

List<int> _createChecksum(String hrp, List<int> data) {
  final values = <int>[..._hrpExpand(hrp), ...data, 0, 0, 0, 0, 0, 0];
  final mod = _polymod(values) ^ 1;
  return List<int>.generate(
    6,
    (index) => (mod >> (5 * (5 - index))) & 31,
  );
}

int _polymod(List<int> values) {
  var chk = 1;
  const gen = <int>[
    0x3b6a57b2,
    0x26508e6d,
    0x1ea119fa,
    0x3d4233dd,
    0x2a1462b3,
  ];

  for (final value in values) {
    final top = chk >> 25;
    chk = ((chk & 0x1ffffff) << 5) ^ value;
    for (var i = 0; i < 5; i++) {
      if (((top >> i) & 1) != 0) {
        chk ^= gen[i];
      }
    }
  }
  return chk;
}

List<int> _hrpExpand(String hrp) {
  final expanded = <int>[];
  for (var i = 0; i < hrp.length; i++) {
    expanded.add(hrp.codeUnitAt(i) >> 5);
  }
  expanded.add(0);
  for (var i = 0; i < hrp.length; i++) {
    expanded.add(hrp.codeUnitAt(i) & 31);
  }
  return expanded;
}

List<int> _convertBits(
  List<int> data,
  int from,
  int to, {
  bool pad = true,
}) {
  var acc = 0;
  var bits = 0;
  final result = <int>[];
  final maxv = (1 << to) - 1;

  for (final value in data) {
    if (value < 0 || (value >> from) != 0) {
      throw const _WatchOnlyImportException('Invalid bit conversion value.');
    }
    acc = (acc << from) | value;
    bits += from;
    while (bits >= to) {
      bits -= to;
      result.add((acc >> bits) & maxv);
    }
  }

  if (pad) {
    if (bits > 0) {
      result.add((acc << (to - bits)) & maxv);
    }
  } else {
    if (bits >= from || ((acc << (to - bits)) & maxv) != 0) {
      throw const _WatchOnlyImportException('Invalid bit conversion padding.');
    }
  }

  return result;
}

bool _bytesEqual(List<int> a, List<int> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}
