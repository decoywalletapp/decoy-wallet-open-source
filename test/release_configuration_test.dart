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

  test('iOS release and TestFlight use the same Dart build settings', () {
    expect(dartDefines(buildScript('ios-app-store-release')),
        dartDefines(buildScript('ios-testflight-rehearsal')));
  });

  for (final id in [
    'ios-testflight-rehearsal',
    'android-signed-release-rehearsal'
  ]) {
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
            'CM_BRANCH': 'codex/qr-send-address-fix-20261011'
          }).exitCode,
          0);
    });
  }

  test('public release workflow does not enable the balance pilot', () {
    expect(
        workflows['ios-app-store-release']['environment']['vars']
            ['DECOY_ACCOUNT_BALANCE_PILOT'],
        'false');
    expect(workflows['android-signed-release-rehearsal']['publishing'], isNull);
    expect(dartDefines(buildScript('android-debug-rehearsal')),
        isNot(contains('DECOY_ACCOUNT_BALANCE_PILOT')));
  });

  test('QR test upload stays internal and restricted to the fix branch', () {
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
          'CM_BRANCH': 'codex/qr-send-address-fix-20261011'
        }).exitCode,
        0);
  });

  for (final id in ['ios-testflight-rehearsal', 'ios-app-store-release']) {
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
