import 'dart:io';

import 'package:decoy_wallet_app/backend/api_requests/api_calls.dart';
import 'package:decoy_wallet_app/custom_code/actions/generate_decoy_draft.dart';
import 'package:decoy_wallet_app/custom_code/actions/prepare_watch_only_decoy_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('zpub import prepares the same BIP84 watch-only address set', () async {
    final generatedDraft = await generateDecoyDraft() as Map;
    final generatedAddresses =
        (generatedDraft['addresses'] as List).cast<String>();

    expect(generatedDraft['source_type'], 'generated-seed');

    final importDraft = prepareWatchOnlyDecoyDraftPayload(
      generatedDraft['zpub'] as String,
      decoyId: 'test-decoy-id',
    );

    expect(importDraft['ok'], isTrue);
    expect(importDraft['decoyId'], 'test-decoy-id');
    expect(importDraft['derivation_path'], "m/84'/0'/0'");
    expect(importDraft['xpub'], isEmpty);
    expect(importDraft['zpub'], isEmpty);
    expect(importDraft['watch_public_key'], generatedDraft['zpub']);
    expect(importDraft['watch_public_key_type'], 'bip84-account-zpub');
    expect(importDraft['source_type'], 'zpub');
    expect(importDraft['addresses'], generatedAddresses);
  });

  test('xpub import normalizes to existing zpub watch-key format', () async {
    final generatedDraft = await generateDecoyDraft() as Map;
    final generatedAddresses =
        (generatedDraft['addresses'] as List).cast<String>();

    final importDraft = prepareWatchOnlyDecoyDraftPayload(
      generatedDraft['xpub'] as String,
      decoyId: 'test-decoy-id',
    );

    expect(importDraft['ok'], isTrue);
    expect(importDraft['xpub'], isEmpty);
    expect(importDraft['zpub'], isEmpty);
    expect(importDraft['watch_public_key'], generatedDraft['zpub']);
    expect(importDraft['watch_public_key_type'], 'bip84-account-zpub');
    expect(importDraft['source_type'], 'xpub');
    expect(importDraft['addresses'], generatedAddresses);
  });

  test('receive address import accepts address lists and bitcoin URIs',
      () async {
    final generatedDraft = await generateDecoyDraft() as Map;
    final generatedAddresses =
        (generatedDraft['addresses'] as List).cast<String>();
    final address0 = generatedAddresses[0];
    final address1 = generatedAddresses[1];

    final importDraft = prepareWatchOnlyDecoyDraftPayload(
      'bitcoin:$address0?amount=1\n$address1\n$address0',
      decoyId: 'address-list-id',
    );

    expect(importDraft['ok'], isTrue);
    expect(importDraft['decoyId'], 'address-list-id');
    expect(importDraft['derivation_path'], 'imported-addresses');
    expect(importDraft['xpub'], isEmpty);
    expect(importDraft['zpub'], isEmpty);
    expect(importDraft['watch_public_key_type'], 'bitcoin-address-list');
    expect(importDraft['source_type'], 'address-list');
    expect(importDraft['addresses'], <String>[address0, address1]);
    expect(importDraft['watch_public_key'], isEmpty);
  });

  test('receive address import accepts common mainnet address formats',
      () async {
    final generatedDraft = await generateDecoyDraft() as Map;
    final generatedAddresses =
        (generatedDraft['addresses'] as List).cast<String>();
    final uppercaseBech32 = generatedAddresses.first.toUpperCase();
    const p2pkhAddress = '1BoatSLRHtKNngkdXEeobR76b53LETtpyT';
    const p2shAddress = '3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy';

    final importDraft = prepareWatchOnlyDecoyDraftPayload(
      '$uppercaseBech32\n$p2pkhAddress\n$p2shAddress',
      decoyId: 'format-test-id',
    );

    expect(importDraft['ok'], isTrue);
    expect(importDraft['source_type'], 'address-list');
    expect(importDraft['addresses'], <String>[
      generatedAddresses.first,
      p2pkhAddress,
      p2shAddress,
    ]);
  });

  test('watch-only import rejects seed phrases and private keys', () async {
    final generatedDraft = await generateDecoyDraft() as Map;

    final seedResult =
        await prepareWatchOnlyDecoyDraft(generatedDraft['mnemonic'] as String)
            as Map;
    final xprvResult = await prepareWatchOnlyDecoyDraft('xprv123') as Map;
    final uppercaseXprvResult =
        await prepareWatchOnlyDecoyDraft('XPRV123') as Map;
    final wifResult = await prepareWatchOnlyDecoyDraft(
      'KwdMAjHcbJ8e1S7p85GeEsjK9Uo9XvGCpMVqdpu4WzeUFHYyNe6Y',
    ) as Map;

    expect(seedResult['ok'], isFalse);
    expect(seedResult['error'], contains('Do not paste seed phrases'));
    expect(xprvResult['ok'], isFalse);
    expect(xprvResult['error'], contains('private extended keys'));
    expect(uppercaseXprvResult['ok'], isFalse);
    expect(uppercaseXprvResult['error'], contains('private extended keys'));
    expect(wifResult['ok'], isFalse);
    expect(wifResult['error'], contains('private keys'));
  });

  test('watch-only import rejects malformed or mixed-case address input',
      () async {
    final generatedDraft = await generateDecoyDraft() as Map;
    final generatedAddresses =
        (generatedDraft['addresses'] as List).cast<String>();
    final mixedCaseAddress =
        generatedAddresses.first.replaceFirst('bc1', 'bC1');

    final mixedCaseResult =
        await prepareWatchOnlyDecoyDraft(mixedCaseAddress) as Map;
    final invalidResult =
        await prepareWatchOnlyDecoyDraft('not-a-bitcoin-address') as Map;

    expect(mixedCaseResult['ok'], isFalse);
    expect(invalidResult['ok'], isFalse);
  });

  test('watch-only import rejects testnet addresses and mixed input', () async {
    final generatedDraft = await generateDecoyDraft() as Map;
    final generatedAddresses =
        (generatedDraft['addresses'] as List).cast<String>();

    final testnetResult = await prepareWatchOnlyDecoyDraft(
      'tb1qfm7pnj8jfyysgz4g0xjm9k6v3s6c9w5v0qypnl',
    ) as Map;
    final mixedResult = await prepareWatchOnlyDecoyDraft(
      '${generatedDraft['zpub']} ${generatedAddresses.first}',
    ) as Map;

    expect(testnetResult['ok'], isFalse);
    expect(mixedResult['ok'], isFalse);
    expect(mixedResult['error'], contains('not both'));
  });

  test('watch-only import action does not store or send spendable material',
      () {
    final source = File(
      'lib/custom_code/actions/prepare_watch_only_decoy_draft.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('mnemonicToSeed')));
    expect(source, isNot(contains('CommitDecoyCall')));
    expect(source, isNot(contains('ApiManager.instance.makeApiCall')));
    expect(source, isNot(contains('supabaseFunctionUrl')));
    expect(source, isNot(contains('SupaFlow.client')));
  });

  test('system-values screen commits the full watch-only draft contract', () {
    final source = File(
      'lib/create_decoy_seed/decoy_seed_system_values/'
      'decoy_seed_system_values_widget.dart',
    ).readAsStringSync();

    expect(source, contains('final derivationPath'));
    expect(source, contains('final watchPublicKey'));
    expect(source, contains('final watchPublicKeyType'));
    expect(source, contains("watchPublicKey.isEmpty && !addressListWatch"));
    expect(source, contains('!storedWatchPublicKey && !addressListWatch'));
    expect(source, contains('FFAppState().draftAddresses'));
    expect(source, contains('CommitDecoyCall.call'));
    expect(source, contains('derivationPath: derivationPath'));
    expect(source, contains('addressesList: addresses'));
    expect(source, contains('xpub: FFAppState().draftXpub.trim()'));
    expect(source, contains('watchPublicKey: watchPublicKey'));
    expect(source, contains('watchPublicKeyType: watchPublicKeyType'));
  });

  test('commit JSON escaping preserves address-list watch keys', () async {
    final generatedDraft = await generateDecoyDraft() as Map;
    final generatedAddresses =
        (generatedDraft['addresses'] as List).cast<String>();
    final watchKey = '${generatedAddresses[0]}\n${generatedAddresses[1]}';

    expect(
      escapeStringForJson(watchKey),
      '${generatedAddresses[0]}\\n${generatedAddresses[1]}',
    );
  });

  test('watch-only import entry point is gated for enabled builds', () {
    final source = File(
      'lib/create_decoy_seed/generate_decoy_seed_phrase/'
      'generate_decoy_seed_phrase_widget.dart',
    ).readAsStringSync();

    expect(source, contains('DecoyBuildProvenance.watchOnlyImportEnabled'));
    expect(source, contains('ImportWatchOnlyWalletWidget.routeName'));
  });

  test('watch-only import route is gated for enabled builds', () {
    final source = File(
      'lib/create_decoy_seed/import_watch_only_wallet/'
      'import_watch_only_wallet_widget.dart',
    ).readAsStringSync();

    expect(source, contains('DecoyBuildProvenance.watchOnlyImportEnabled'));
    expect(source, contains('enabled test builds only'));
    expect(source, contains('prepareWatchOnlyDecoyDraft'));
  });
}
