import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('duress PIN alert call contract remains intact', () {
    final apiSource =
        File('lib/backend/api_requests/api_calls.dart').readAsStringSync();
    final pinSource = File('lib/pin_pages/p_i_n_page/p_i_n_page_widget.dart')
        .readAsStringSync();

    expect(apiSource, contains('class SendEmergencyAlertsCall'));
    expect(apiSource, contains(r"'${baseUrl}/sendEmergencyAlerts'"));
    expect(apiSource, contains('"triggerType":'));
    expect(apiSource, contains('"contacts":'));
    expect(apiSource, contains('"location":'));
    expect(apiSource, contains("'Authorization': 'Bearer \${jwt}'"));

    expect(pinSource, contains('.sendEmergencyAlertsCall'));
    expect(pinSource, contains('.call('));
    expect(pinSource, contains("'PIN_DECOY'"));
  });

  test('watch-only setup screens do not send emergency alerts directly', () {
    final sources = [
      File(
        'lib/create_decoy_seed/generate_decoy_seed_phrase/'
        'generate_decoy_seed_phrase_widget.dart',
      ).readAsStringSync(),
      File(
        'lib/create_decoy_seed/import_watch_only_wallet/'
        'import_watch_only_wallet_widget.dart',
      ).readAsStringSync(),
      File(
        'lib/custom_code/actions/prepare_watch_only_decoy_draft.dart',
      ).readAsStringSync(),
    ].join('\n');

    expect(sources, isNot(contains('SendEmergencyAlertsCall')));
    expect(sources, isNot(contains('sendEmergencyAlertsCall')));
    expect(sources, isNot(contains('/sendEmergencyAlerts')));
    expect(sources, isNot(contains('alert_logs')));
  });

  test('generated seed arming still uses the existing decoy seed fields', () {
    final source = File(
      'lib/create_decoy_seed/decoy_seed_system_values/'
      'decoy_seed_system_values_widget.dart',
    ).readAsStringSync();

    expect(source, contains("'decoy_seed_armed': seedMonitorEnabled"));
    expect(
        source, contains("'decoy_seed_contacts_enabled': seedMonitorEnabled"));
    expect(source, contains("'decoy_seed_decoy_id': decoyId"));
    expect(source, contains("'decoy_seed_armed_at': seedMonitorEnabled"));
    expect(source, contains('CommitDecoyCall.call'));
    expect(source, isNot(contains('SendEmergencyAlertsCall')));
  });
}
