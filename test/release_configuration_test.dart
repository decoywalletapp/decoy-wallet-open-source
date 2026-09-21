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

  for (final id in ['ios-testflight-rehearsal', 'ios-app-store-release']) {
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
