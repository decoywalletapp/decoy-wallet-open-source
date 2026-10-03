import 'dart:convert';
import 'dart:io';

import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, String> _walletMessages(AppLocalizations strings) => {
      'msgAddAWatchOnlyWalletKeyOrSpecific':
          strings.msgAddAWatchOnlyWalletKeyOrSpecific,
      'msgAutomaticallySendPurchasedBitcoinToYourWallet':
          strings.msgAutomaticallySendPurchasedBitcoinToYourWallet,
      'msgByContinuingYouAgreeToReceiveAutomatedText':
          strings.msgByContinuingYouAgreeToReceiveAutomatedText,
      'msgDecoyWalletBalance': strings.msgDecoyWalletBalance,
      'msgEmergencyAlertsWalletMonitoringAndEmergencyContactNotifications':
          strings
              .msgEmergencyAlertsWalletMonitoringAndEmergencyContactNotifications,
      'msgIUnderstandDecoySeedAlertsAreDesignedFor':
          strings.msgIUnderstandDecoySeedAlertsAreDesignedFor,
      'msgManageYourWalletPreferencesAndSession':
          strings.msgManageYourWalletPreferencesAndSession,
      'msgMonitorExistingWallet': strings.msgMonitorExistingWallet,
      'msgPasteOrEnterWalletAddress': strings.msgPasteOrEnterWalletAddress,
      'msgPleaseAuthenticateToUnlockYourWallet':
          strings.msgPleaseAuthenticateToUnlockYourWallet,
      'msgUseXpubForLegacy1AddressWalletsZpub':
          strings.msgUseXpubForLegacy1AddressWalletsZpub,
      'msgWallet': strings.msgWallet,
      'msgWalletActivityMonitor': strings.msgWalletActivityMonitor,
      'msgWalletSeedPhrasesAndPrivateKeys':
          strings.msgWalletSeedPhrasesAndPrivateKeys,
      'msgWatchOnlyWalletImportIsAvailableInEnabled':
          strings.msgWatchOnlyWalletImportIsAvailableInEnabled,
      'msgYourBitcoinFundsRemainSafeInYourExternal':
          strings.msgYourBitcoinFundsRemainSafeInYourExternal,
      'msgItcoinWallet': strings.msgItcoinWallet,
      'msgAccountLevelSeedWalletMonitoring':
          strings.msgAccountLevelSeedWalletMonitoring,
      'msgGenerateANewDecoySeedPhraseOrMonitor':
          strings.msgGenerateANewDecoySeedPhraseOrMonitor,
      'msgGenerateANewDecoySeedPhraseToMonitor':
          strings.msgGenerateANewDecoySeedPhraseToMonitor,
      'msgThisWalletOrReceiveAddressIsAlreadyBeing':
          strings.msgThisWalletOrReceiveAddressIsAlreadyBeing,
      'msgUnableToCheckWhetherThisWalletIsAlready':
          strings.msgUnableToCheckWhetherThisWalletIsAlready,
      'msgUnableToValidateThisWatchOnlyWalletData':
          strings.msgUnableToValidateThisWatchOnlyWalletData,
      'msgWalletActivityMonitor2': strings.msgWalletActivityMonitor2,
      'msgWallet2': strings.msgWallet2,
    };

void main() {
  for (final code in ['de', 'nl']) {
    test('$code uses wallet terminology in all affected runtime messages',
        () async {
      final strings = await AppLocalizations.delegate.load(Locale(code));
      final catalog =
          jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
              as Map<String, dynamic>;
      final messages = _walletMessages(strings);
      expect(messages, hasLength(25));
      for (final entry in messages.entries) {
        expect(entry.value, catalog[entry.key],
            reason: '$code/${entry.key} generated text must match the catalog');
        expect(entry.value.toLowerCase(), contains('wallet'),
            reason: '$code/${entry.key}');
      }
      expect(strings.msgWallet, 'Wallet');
      expect(strings.msgWallet2, 'WALLET');
    });

    test('$code catalog does not reintroduce physical purse terminology', () {
      final catalog =
          jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
              as Map<String, dynamic>;
      final oldTerms =
          RegExp(r'geldb(?:\u00f6|oe)rs|portemonnee', caseSensitive: false);
      for (final entry in catalog.entries) {
        if (entry.key.startsWith('@') || entry.value is! String) continue;
        expect(oldTerms.hasMatch(entry.value as String), isFalse,
            reason: '$code/${entry.key}');
      }
    });

    test('$code keeps brand names and protocol instructions intact', () async {
      final strings = await AppLocalizations.delegate.load(Locale(code));
      expect(strings.msgUnlockDecoyWallet, contains('Decoy Wallet'));
      expect(strings.msgFollowDecoyWallet, contains('DECOY WALLET'));
      final consent = strings.msgByContinuingYouAgreeToReceiveAutomatedText;
      for (final token in ['Decoy Wallet', 'STOP', 'HELP']) {
        expect(consent, contains(token));
      }
      for (final token in ['xpub', 'zpub', 'SegWit', 'bc1', '1']) {
        expect(strings.msgUseXpubForLegacy1AddressWalletsZpub, contains(token));
      }
    });
  }
}
