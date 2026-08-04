import 'dart:math';
import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;

// The current seed display page is built around 12 words. Keep Decoy Seeds at
// 128 bits until the 24-word display and quiz flow are migrated together.
const int decoySeedEntropyBytes = 16;
const int decoySeedWordCount = 12;

String generateDecoyMnemonic({int entropyBytes = decoySeedEntropyBytes}) {
  final entropy = generateDecoyEntropy(entropyBytes: entropyBytes);
  return bip39.entropyToMnemonic(_hexEncode(entropy));
}

Uint8List generateDecoyEntropy({int entropyBytes = decoySeedEntropyBytes}) {
  if (entropyBytes < 16 || entropyBytes > 32 || entropyBytes % 4 != 0) {
    throw ArgumentError.value(
      entropyBytes,
      'entropyBytes',
      'BIP39 entropy must be 16..32 bytes and divisible by 4',
    );
  }

  final rng = Random.secure();
  final bytes = Uint8List(entropyBytes);
  for (var i = 0; i < bytes.length; i++) {
    bytes[i] = rng.nextInt(256);
  }
  return bytes;
}

String _hexEncode(Uint8List bytes) {
  final buffer = StringBuffer();
  for (final byte in bytes) {
    buffer.write(byte.toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}
