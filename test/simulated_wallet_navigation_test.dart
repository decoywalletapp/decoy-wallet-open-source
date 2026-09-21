import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('simulated wallet discovery actions use dedicated inert pages', () {
    final homeSource = File(
      'lib/duress_mode/duress_home_page/duress_home_page_widget.dart',
    ).readAsStringSync();
    final previewSource = File(
      'lib/duress_mode/wallet_feature_preview/'
      'wallet_feature_preview_widget.dart',
    ).readAsStringSync();

    for (final feature in [
      'recurring-buy',
      'limit-order',
      'bitcoin-pay',
      'auto-withdraw',
    ]) {
      expect(homeSource, contains("_openFeature(context, '$feature')"));
      expect(previewSource, contains("case '$feature':"));
    }
    expect(previewSource, contains('context.safePop()'));
    expect(previewSource, isNot(contains('FilledButton')));
    expect(previewSource, isNot(contains('OutlinedButton')));
  });

  test('simulated wallet settings never identify the wallet as a decoy', () {
    final settingsSource = File(
      'lib/duress_mode/duress_settings_page/'
      'duress_settings_page_widget.dart',
    ).readAsStringSync();

    expect(settingsSource.toLowerCase(), isNot(contains('decoy wallet')));
    expect(settingsSource, contains("title: 'Currency'"));
    expect(settingsSource, contains("value: 'Bitcoin Mainnet'"));
  });

  test('balance slider reserves its first half for zero through 25 BTC', () {
    final source = File(
      'lib/settings_pages/configure_bitcoin_balance/'
      'configure_bitcoin_balance_widget.dart',
    ).readAsStringSync();

    expect(source, contains('if (amount <= 25.0)'));
    expect(source, contains('(amount / 25.0) * 0.5'));
    expect(source, contains('if (position <= 0.5)'));
    expect(source, contains('(position / 0.5) * 25.0'));
    expect(source, contains('AlignmentDirectional(-0.01, 0.0)'));
    expect(source, contains('AlignmentDirectional(0.0, 0.0)'));
    expect(source, contains('AlignmentDirectional(0.01, 0.0)'));
    expect(source, isNot(contains('AlignmentDirectional(0.0, 0.1)')));
    expect(source, isNot(contains('AlignmentDirectional(0.0, -0.1)')));
    expect(source, contains('width: 340.0'));
  });
}
