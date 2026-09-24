import '/custom_code/actions/aes_gcm_decrypt_to_map.dart';

/// Unconfigured profile fields must not prevent a verified decoy PIN opening
/// the wallet. Existing encrypted fields retain the normal decryption behavior.
Future<dynamic> decryptOptionalPinPayload({
  required String? ciphertext,
  required String? nonce,
  required String? dataKey,
  required Map<String, dynamic> emptyPayload,
}) async {
  if (ciphertext == null ||
      ciphertext.isEmpty ||
      nonce == null ||
      nonce.isEmpty) {
    return emptyPayload;
  }
  return aesGcmDecryptToMap(ciphertext, nonce, dataKey ?? '');
}
