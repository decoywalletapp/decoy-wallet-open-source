import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

Map<String, String> dartDefines(String script) {
  final matches =
      RegExp(r'--dart-define=([^\s=]+)=([^\s\\]+)').allMatches(script);
  final result = <String, String>{};
  for (final match in matches) {
    final name = match.group(1)!;
    expect(result.containsKey(name), isFalse,
        reason: 'Duplicate build setting: $name');
    result[name] = match.group(2)!;
  }
  return result;
}

void main() {
  final workflows = (loadYaml(File('codemagic.yaml').readAsStringSync())
      as YamlMap)['workflows'] as YamlMap;

  String buildScript(String id) => (workflows[id]['scripts'] as YamlList)
          .cast<YamlMap>()
          .singleWhere((step) =>
              (step['script'] as String).contains('flutter build'))['script']
      as String;

  for (final id in workflows.keys.cast<String>()) {
    test('$id explicitly enables existing-wallet imports', () {
      expect(dartDefines(buildScript(id))['DECOY_ENABLE_WATCH_ONLY_IMPORT'],
          'true');
    });
  }

  test('iOS packages use the same configuration inputs without diagnostics', () {
    expect(dartDefines(buildScript('ios-app-store-release')),
        dartDefines(buildScript('ios-testflight-rehearsal')));
  });

  test('no package enables the temporary PIN recorder', () {
    for (final id in workflows.keys.cast<String>()) {
      expect(dartDefines(buildScript(id)),
          isNot(contains('DECOY_UNLOCK_DIAGNOSTICS')));
    }
  });

  test('iOS package values retain only the intended internal differences', () {
    Map<String, String> resolvedDefines(String id) {
      final variables = workflows[id]['environment']['vars'] as YamlMap;
      return dartDefines(buildScript(id)).map((key, value) => MapEntry(
          key,
          value.replaceAllMapped(RegExp(r'\$([A-Z_][A-Z_0-9]*)'), (match) {
            return variables[match.group(1)]?.toString() ?? match.group(0)!;
          })));
    }

    final internal = resolvedDefines('ios-testflight-rehearsal');
    final release = resolvedDefines('ios-app-store-release');
    expect(internal.remove('DECOY_ACCOUNT_BALANCE_PILOT'), '"true"');
    expect(release.remove('DECOY_ACCOUNT_BALANCE_PILOT'), '"false"');
    expect(internal.remove('DECOY_BUILD_VERIFICATION'),
        '"pin-security-private-test"');
    expect(release.remove('DECOY_BUILD_VERIFICATION'), '"store-release"');
    expect(internal, release);
  });

  for (final id in ['ios-testflight-rehearsal']) {
    test('$id preserves enabled balances and restricts its test branch', () {
      expect(
          workflows[id]['environment']['vars']['DECOY_ACCOUNT_BALANCE_PILOT'],
          'true');
      expect(dartDefines(buildScript(id)),
          contains('DECOY_ACCOUNT_BALANCE_PILOT'));
      final guard = (workflows[id]['scripts'] as YamlList).first['script'];
      for (final branch in [
        'main',
        'codex/wallet-terminology-20261002',
        'codex/account-balance-pilot-20261003',
        'codex/qr-send-address-fix-20261011',
        ''
      ]) {
        expect(
            Process.runSync('/bin/sh', ['-c', guard],
                environment: {'CM_BRANCH': branch}).exitCode,
            isNot(0));
      }
      expect(
          Process.runSync('/bin/sh', [
            '-c',
            guard
          ], environment: {
            'CM_BRANCH': 'codex/pin-unlock-security-20261023'
          }).exitCode,
          0);
    });
  }

  test('release workflows preserve each platform balance configuration', () {
    expect(
        workflows['ios-app-store-release']['environment']['vars']
            ['DECOY_ACCOUNT_BALANCE_PILOT'],
        'false');
    expect(workflows['android-signed-release-rehearsal']['publishing'], isNull);
    expect(
        workflows['android-signed-release-rehearsal']['environment']['vars']
            ['DECOY_ACCOUNT_BALANCE_PILOT'],
        'true');
    expect(dartDefines(buildScript('android-debug-rehearsal')),
        isNot(contains('DECOY_ACCOUNT_BALANCE_PILOT')));
  });

  test('signup verification upload does not submit to external or store review',
      () {
    final workflow = workflows['ios-app-store-release'];
    final publishing = workflow['publishing']['app_store_connect'];
    expect(publishing['submit_to_testflight'], isFalse);
    expect(publishing['submit_to_app_store'], isFalse);
    expect(publishing['beta_groups'], isNull);
    expect(publishing['cancel_previous_submissions'], isNull);
    expect(publishing['expire_build_submitted_for_review'], isNull);
    expect(workflow['triggering'], isNull);
  });

  test('Android PIN release keeps package inputs and runs isolated access tests', () {
    final workflow = workflows['android-signed-release-rehearsal'];
    final environment = workflow['environment'] as YamlMap;
    expect(environment['groups'], ['decoy_public_runtime', 'android_signing']);
    expect(environment['vars']['ANDROID_PACKAGE_NAME'], 'com.decoywalletapp.app');
    expect(environment['vars']['DECOY_BUILD_VERIFICATION'], 'store-release');
    expect(environment['vars']['DECOY_ACCOUNT_BALANCE_PILOT'], 'true');
    expect(workflow['publishing'], isNull);
    expect(workflow['triggering'], isNull);
    final guard = (workflow['scripts'] as YamlList).first['script'] as String;
    for (final branch in ['main', 'codex/pin-unlock-security-20261023', '']) {
      expect(
          Process.runSync('/bin/sh', ['-c', guard],
              environment: {'CM_BRANCH': branch}).exitCode,
          isNot(0));
    }
    expect(
        Process.runSync('/bin/sh', ['-c', guard], environment: {
          'CM_BRANCH': 'codex/signup-confirmation-20261030'
        }).exitCode,
        0);
    final scripts = (workflow['scripts'] as YamlList)
        .cast<YamlMap>()
        .map((step) => step['script'] as String)
        .toList();
    final index = scripts.indexWhere(
        (script) => script.contains('test/login_biometric_lifecycle_test.dart'));
    expect(index, greaterThanOrEqualTo(0));
    expect(index, lessThan(scripts.indexWhere((s) => s.contains('flutter build'))));
    final tests = scripts[index];
    expect(tests, contains('test/membership_redemption_test.dart'));
    expect(tests, contains('test/release_configuration_test.dart'));
    expect(tests, contains('test/control_center_saved_choices_test.dart'));
    expect(tests, contains('test/auth_link_service_test.dart'));
    expect(tests, contains('test/auth_link_entrypoints_test.dart'));
    for (final path in [
      'test/pin_direct_transition_test.dart',
      'test/pin_unlock_handoff_test.dart',
      'test/unlock_transition_lifecycle_test.dart',
      'test/emergency_contacts_responsiveness_test.dart',
      'test/emergency_setup_progress_test.dart',
    ]) {
      expect(tests, contains(path));
    }
    final defines = dartDefines(tests);
    expect(defines['DECOY_TEST_ACCOUNT_BALANCE'], 'true');
    expect(defines['DECOY_SUPABASE_URL'], 'https://test.invalid');
    expect(defines['DECOY_SUPABASE_ANON_KEY'], 'synthetic-anon');
    expect(defines['DECOY_FIREBASE_FUNCTIONS_BASE_URL'], 'https://test.invalid');
    expect(defines['DECOY_ALERT_BASE_URL'], 'https://test.invalid');
    expect(defines['DECOY_DATA_KEY_BASE_URL'], 'https://test.invalid/unwrap');
    expect(defines['DECOY_PAYMENT_BASE_URL'], 'https://test.invalid');
  });

  test('App Store release runs saved-choice and paid-access regressions', () {
    final scripts = (workflows['ios-app-store-release']['scripts'] as YamlList)
        .cast<YamlMap>()
        .map((step) => step['script'] as String)
        .toList();
    final tests = scripts.singleWhere((script) =>
        script.contains('test/control_center_saved_choices_test.dart'));
    for (final path in [
      'test/localized_pin_navigation_test.dart',
      'test/login_biometric_lifecycle_test.dart',
      'test/auth_link_service_test.dart',
      'test/auth_link_entrypoints_test.dart',
      'test/unlock_state_test.dart',
      'test/unlock_routes_test.dart',
      'test/membership_redemption_test.dart',
      'test/release_configuration_test.dart',
      'test/emergency_setup_progress_test.dart',
    ]) {
      expect(tests, contains(path));
    }
    expect(scripts.indexOf(tests),
        lessThan(scripts.indexWhere((script) => script.contains('flutter build'))));
  });

  test('PIN security test upload stays internal and restricted to the fix branch', () {
    final workflow = workflows['ios-testflight-rehearsal'];
    expect(workflow['environment']['vars']['DECOY_ACCOUNT_BALANCE_PILOT'],
        'true');
    final publishing = workflow['publishing']['app_store_connect'];
    expect(publishing['submit_to_testflight'], isFalse);
    expect(publishing['submit_to_app_store'], isFalse);
    final guard = (workflow['scripts'] as YamlList).first['script'] as String;
    for (final branch in ['main', 'codex/account-balance-pilot-20261003', '']) {
      expect(
          Process.runSync('/bin/sh', ['-c', guard],
              environment: {'CM_BRANCH': branch}).exitCode,
          isNot(0));
    }
    expect(
        Process.runSync('/bin/sh', ['-c', guard], environment: {
          'CM_BRANCH': 'codex/pin-unlock-security-20261023'
        }).exitCode,
        0);
  });

  for (final id in ['ios-testflight-rehearsal', 'ios-app-store-release']) {
    test('$id runs the login lifecycle regression with isolated endpoints', () {
      final scripts = (workflows[id]['scripts'] as YamlList)
          .cast<YamlMap>()
          .map((step) => step['script'] as String)
          .toList();
      final index = scripts.indexWhere(
          (script) => script.contains('test/login_biometric_lifecycle_test.dart'));
      expect(index, greaterThanOrEqualTo(0));
      expect(index,
          lessThan(scripts.indexWhere((script) => script.contains('flutter build'))));
      for (final script in scripts.where((script) =>
          script.contains('test/login_biometric_lifecycle_test.dart'))) {
        expect(script, contains('test/auth_link_service_test.dart'));
        expect(script, contains('test/auth_link_entrypoints_test.dart'));
        expect(script,
            contains('--dart-define=DECOY_FIREBASE_FUNCTIONS_BASE_URL=https://test.invalid'));
        expect(script,
            contains('--dart-define=DECOY_SUPABASE_ANON_KEY=synthetic-anon'));
        for (final endpoint in {
          'DECOY_ALERT_BASE_URL': 'https://test.invalid',
          'DECOY_DATA_KEY_BASE_URL': 'https://test.invalid/unwrap',
          'DECOY_PAYMENT_BASE_URL': 'https://test.invalid',
        }.entries) {
          expect(script, contains('--dart-define=${endpoint.key}=${endpoint.value}'));
        }
        expect(script, contains('--dart-define=DECOY_TEST_ACCOUNT_BALANCE=true'));
      }
    });

    group('$id Apple upload target', () {
      late Directory temporary;
      late File calls;
      final script = (workflows[id]['scripts'] as YamlList)
              .cast<YamlMap>()
              .singleWhere((step) =>
                  step['name'] == 'Validate App Store upload target')['script']
          as String;

      setUp(() {
        temporary = Directory.systemTemp.createTempSync('decoy-upload-test-');
        calls = File('${temporary.path}/calls');
        final stub = File('${temporary.path}/app-store-connect');
        stub.writeAsStringSync('''#!/bin/sh
printf '%s\\n' "\$@" > "\$TEST_CALLS"
exit "\$TEST_API_EXIT"
''');
        expect(Process.runSync('chmod', ['+x', stub.path]).exitCode, 0);
      });

      tearDown(() => temporary.deleteSync(recursive: true));

      ProcessResult run(String appId, {int apiExit = 0}) =>
          Process.runSync('/bin/sh', [
            '-c',
            script
          ], environment: {
            'PATH': '${temporary.path}:${Platform.environment['PATH']}',
            'APP_STORE_APPLE_ID': appId,
            'TEST_CALLS': calls.path,
            'TEST_API_EXIT': '$apiExit',
          });

      test('validates access to the configured Apple app', () {
        final result = run('1234567890');
        expect(result.exitCode, 0, reason: '${result.stderr}');
        expect(calls.readAsLinesSync(), ['apps', 'get', '1234567890']);
      });

      test('rejects invalid app IDs before accessing Apple', () {
        for (final appId in ['', 'name@example.com', '123 --other-argument']) {
          expect(run(appId).exitCode, isNot(0));
          expect(calls.existsSync(), isFalse);
        }
      });

      test('stops when Apple rejects app access', () {
        expect(run('1234567890', apiExit: 23).exitCode, 23);
      });
    });

    test('$id tests the enabled import UI before building', () {
      final scripts = (workflows[id]['scripts'] as YamlList)
          .cast<YamlMap>()
          .map((step) => step['script'] as String)
          .toList();
      final testIndex = scripts.indexWhere((s) => s.contains('flutter test'));
      final buildIndex = scripts.indexWhere((s) => s.contains('flutter build'));
      expect(testIndex, greaterThanOrEqualTo(0));
      expect(testIndex, lessThan(buildIndex));
      expect(dartDefines(scripts[testIndex])['DECOY_ENABLE_WATCH_ONLY_IMPORT'],
          'true');
    });

    test('$id cannot automatically submit to App Store review', () {
      expect(
          workflows[id]['publishing']['app_store_connect']
              ['submit_to_app_store'],
          isNot(true));
    });
  }
}
