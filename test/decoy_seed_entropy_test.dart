import 'dart:io';

import 'package:bip39/bip39.dart' as bip39;
import 'package:decoy_wallet_app/custom_code/actions/decoy_seed_entropy.dart';
import 'package:decoy_wallet_app/custom_code/actions/generate_decoy_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generates valid 12-word BIP39 Decoy Seeds from explicit entropy', () {
    final mnemonic = generateDecoyMnemonic();

    expect(bip39.validateMnemonic(mnemonic), isTrue);
    expect(mnemonic.split(' '), hasLength(decoySeedWordCount));
    expect(decoySeedEntropyBytes, 16);
  });

  test('generated Decoy Seeds are unique across a sample set', () {
    final mnemonics = <String>{};

    for (var i = 0; i < 64; i++) {
      mnemonics.add(generateDecoyMnemonic());
    }

    expect(mnemonics, hasLength(64));
  });

  test('Decoy draft keeps mnemonic local and returns BIP84 watch-only data',
      () async {
    final draft = await generateDecoyDraft() as Map;
    final mnemonic = draft['mnemonic'] as String;
    final addresses = (draft['addresses'] as List).cast<String>();

    expect(draft['ok'], isTrue);
    expect(bip39.validateMnemonic(mnemonic), isTrue);
    expect(mnemonic.split(' '), hasLength(decoySeedWordCount));
    expect(draft['derivation_path'], "m/84'/0'/0'");
    expect(draft['xpub'], isA<String>());
    expect((draft['xpub'] as String), startsWith('xpub'));
    expect(draft['zpub'], isA<String>());
    expect((draft['zpub'] as String), startsWith('zpub'));
    expect(draft['watch_public_key'], draft['zpub']);
    expect(draft['watch_public_key_type'], 'bip84-account-zpub');
    expect(addresses, hasLength(30));
    expect(addresses.every((address) => address.startsWith('bc1q')), isTrue);
  });

  test('seed generation avoids package default entropy and nextInt(255)', () {
    final seedSourceFiles = [
      'lib/custom_code/actions/decoy_seed_entropy.dart',
      'lib/custom_code/actions/create_and_register_decoy.dart',
      'lib/custom_code/actions/generate_decoy_draft.dart',
    ];
    final source =
        seedSourceFiles.map((path) => File(path).readAsStringSync()).join('\n');

    expect(source, contains('Random.secure()'));
    expect(source, contains('nextInt(256)'));
    expect(source, isNot(contains('nextInt(255)')));
    expect(source, isNot(contains('bip39.generateMnemonic')));
    expect(source, isNot(contains('Random();')));
  });

  test('Decoy Seed setup does not use local mnemonic storage helpers', () {
    final seedFlowSourceFiles = [
      'lib/custom_code/actions/index.dart',
      'lib/create_decoy_seed/generate_decoy_seed_phrase/generate_decoy_seed_phrase_widget.dart',
      'lib/create_decoy_seed/show_decoy_seed_phrase/show_decoy_seed_phrase_widget.dart',
      'lib/create_decoy_seed/seed_phrase_verification/seed_phrase_verification_widget.dart',
      'lib/create_decoy_seed/decoy_seed_system_values/decoy_seed_system_values_widget.dart',
    ];
    final source = seedFlowSourceFiles
        .map((path) => File(path).readAsStringSync())
        .join('\n');

    expect(source, isNot(contains('loadDecoyMnemonicFromStorage')));
    expect(source, isNot(contains('decoy_aes_key')));
    expect(source, isNot(contains('_ct')));
    expect(source, isNot(contains('_iv')));
  });
}
