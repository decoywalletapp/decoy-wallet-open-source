import 'dart:convert';
import 'dart:io';

import 'package:decoy_wallet_app/custom_code/actions/aes_gcm_encrypt_string.dart';
import 'package:decoy_wallet_app/flutter_flow/custom_functions.dart'
    as functions;
import 'package:decoy_wallet_app/utils/decoy_pin_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final key = base64UrlEncode(List<int>.generate(16, (index) => index));
  const personal = {'firstName': 'Test', 'lastName': 'User'};
  const contacts = {
    'contacts': [
      {
        'slot': 1,
        'first': 'Test',
        'last': 'Contact',
        'phone': '+12025550123',
        'consent_status': 'confirmed',
      },
    ],
  };

  for (final hasPersonal in [false, true]) {
    for (final hasContacts in [false, true]) {
      test('PIN payload loading: personal=$hasPersonal contacts=$hasContacts',
          () async {
        final encryptedPersonal = hasPersonal
            ? await aesGcmEncryptString(jsonEncode(personal), key)
            : null;
        final encryptedContacts = hasContacts
            ? await aesGcmEncryptString(jsonEncode(contacts), key)
            : null;

        final loadedContacts = await decryptOptionalPinPayload(
          ciphertext: encryptedContacts?['ciphertextB64'],
          nonce: encryptedContacts?['nonceB64'],
          dataKey: key,
          emptyPayload: {'contacts': <dynamic>[]},
        );
        final loadedPersonal = await decryptOptionalPinPayload(
          ciphertext: encryptedPersonal?['ciphertextB64'],
          nonce: encryptedPersonal?['nonceB64'],
          dataKey: key,
          emptyPayload: {'firstName': '', 'lastName': ''},
        );

        expect(loadedPersonal['firstName'], hasPersonal ? 'Test' : '');
        expect(loadedPersonal['lastName'], hasPersonal ? 'User' : '');
        expect(loadedContacts['contacts'],
            hasContacts ? contacts['contacts'] : isEmpty);

        final withConsent = functions.applyConsentStatusesToContactsPayload(
          loadedContacts,
          'confirmed',
          null,
          null,
          null,
          null,
        );
        expect(withConsent['contacts'],
            hasContacts ? contacts['contacts'] : isEmpty);
      });
    }
  }

  test('null, empty, and incomplete payloads do not throw', () async {
    for (final fields in <List<String?>>[
      [null, null],
      ['', ''],
      [null, 'nonce'],
      ['ciphertext', null],
      ['', 'nonce'],
      ['ciphertext', ''],
    ]) {
      expect(
          await decryptOptionalPinPayload(
            ciphertext: fields[0],
            nonce: fields[1],
            dataKey: null,
            emptyPayload: {'contacts': <dynamic>[]},
          ),
          {'contacts': <dynamic>[]});
    }
  });

  test('invalid encrypted data remains an explicit decryption failure',
      () async {
    final result = await decryptOptionalPinPayload(
      ciphertext: 'not-base64!',
      nonce: 'not-base64!',
      dataKey: key,
      emptyPayload: {'contacts': <dynamic>[]},
    );
    expect(result['_ok'], isFalse);
    expect(result, isNot(contains('contacts')));
  });

  test('wrong key cannot expose an existing encrypted contact', () async {
    final encrypted = await aesGcmEncryptString(jsonEncode(contacts), key);
    final wrongKey = base64UrlEncode(List<int>.filled(16, 42));
    final result = await decryptOptionalPinPayload(
      ciphertext: encrypted['ciphertextB64'],
      nonce: encrypted['nonceB64'],
      dataKey: wrongKey,
      emptyPayload: {'contacts': <dynamic>[]},
    );
    expect(result['_ok'], isFalse);
    expect(result, isNot(contains('contacts')));
  });

  test(
      'PIN page loads optional payloads only after successful PIN verification',
      () {
    final source = File('lib/pin_pages/p_i_n_page/p_i_n_page_widget.dart')
        .readAsStringSync();
    final verified = source.indexOf('if (VerifyPINCall.ok(');
    final decoy = source.indexOf('if (VerifyPINCall.isDecoy(', verified);
    final load = source.indexOf('await decryptOptionalPinPayload(', decoy);
    final navigate = source.indexOf('DuressHomePageWidget', load);
    expect(verified, greaterThanOrEqualTo(0));
    expect(decoy, greaterThan(verified));
    expect(load, greaterThan(decoy));
    expect(navigate, greaterThan(load));
    expect('await decryptOptionalPinPayload('.allMatches(source), hasLength(2));
    for (final field in [
      'contactsCiphertext',
      'contactsNonce',
      'personalCiphertext',
      'personalNonce'
    ]) {
      expect(source, isNot(contains('$field!')));
    }
    expect(source, contains('GetConsentStatusesCall'));
    expect(source, contains('liveContactsComplete =='));
    expect(source, contains('.decoyPinContactsEnabled =='));
    expect(source, contains("'PIN_DECOY'"));
  });
}
