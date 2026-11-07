import 'dart:convert';
import 'dart:io';

import 'package:decoy_wallet_app/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Decoy PIN heading describes alerts, not emergency services', () {
    const heading = 'Create a DECOY PIN for Emergency Alerts';
    final strings = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
        as Map<String, dynamic>;

    expect(strings['msgCreateADecoyPinForEmergencyServices'], heading);
    expect(AppLocalizationsEn().msgCreateADecoyPinForEmergencyServices, heading);
  });
}
