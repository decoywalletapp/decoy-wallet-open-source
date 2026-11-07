import 'dart:io';

import 'package:decoy_wallet_app/create_decoy_seed/seed_handoff.dart';
import 'package:flutter_test/flutter_test.dart';

/// Source-level guards for the decoy mnemonic. These are a lint, not the
/// main proof: `seed_route_behaviour_test.dart` drives the real routes and
/// checks what the router reports. Static scans cannot follow data flow
/// (`final w = words; print(w);` in an unrelated file still passes here).
void main() {
  List<File> appSources() => Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  // Files that hold or move the mnemonic.
  const seedFlowFiles = [
    'lib/create_decoy_seed/seed_handoff.dart',
    'lib/create_decoy_seed/generate_decoy_seed_phrase/generate_decoy_seed_phrase_widget.dart',
    'lib/create_decoy_seed/generate_decoy_seed_phrase/generate_decoy_seed_phrase_model.dart',
    'lib/create_decoy_seed/show_decoy_seed_phrase/show_decoy_seed_phrase_widget.dart',
    'lib/create_decoy_seed/show_decoy_seed_phrase/show_decoy_seed_phrase_model.dart',
    'lib/create_decoy_seed/seed_phrase_verification/seed_phrase_verification_widget.dart',
    'lib/create_decoy_seed/seed_phrase_verification/seed_phrase_verification_model.dart',
    'lib/custom_code/actions/decoy_seed_entropy.dart',
    'lib/custom_code/actions/generate_decoy_draft.dart',
    'lib/custom_code/actions/create_and_register_decoy.dart',
    'lib/custom_code/actions/split_mnemonic_action.dart',
    'lib/custom_code/actions/make_quiz_indices_action.dart',
    'lib/custom_code/actions/build_quiz_step_action.dart',
  ];

  // Any identifier or string that names seed material. Route-name references
  // such as `ShowDecoySeedPhraseWidget.routeName` are stripped first.
  final sensitive = RegExp(
      r'\w*(mnemonic|seedphrase|seedwords|words|splitout)\w*',
      caseSensitive: false);
  final routeNameRef = RegExp(r'\w+Widget\s*\.\s*route(Name|Path)\b');

  // Calls whose arguments can reach a URL, browser history, another app or
  // the clipboard.
  final sinkCall = RegExp(r'(?<![\w.])(?:\w+\.)*'
      r'(pushNamed|goNamed|pushReplacementNamed|replaceNamed|namedLocation|'
      r'push|go|pushReplacement|replace|Uri|Uri\.parse|Uri\.https|Uri\.http|'
      r'launchUrl|launchUrlString|share|shareUri|setData)'
      r'\s*(<[^>()]*>)?\s*\(');

  final logCall = RegExp(r'(?<![\w.])(?:\w+\.)*'
      r'(print|debugPrint|log|_debugLog|debugLog|logger\.\w+)\s*\(');

  // Returns the text between the '(' at [open] and its matching ')'.
  String argsFrom(String src, int open) {
    var depth = 0;
    String? quote;
    for (var i = open; i < src.length; i++) {
      final c = src[i];
      if (quote != null) {
        if (c == r'\') {
          i++;
        } else if (c == quote) {
          quote = null;
        }
        continue;
      }
      if (c == "'" || c == '"') {
        quote = c;
      } else if (c == '(') {
        depth++;
      } else if (c == ')') {
        depth--;
        if (depth == 0) return src.substring(open + 1, i);
      }
    }
    return src.substring(open + 1);
  }

  Iterable<(int, String)> callArgs(RegExp call, String src) sync* {
    for (final m in call.allMatches(src)) {
      yield (m.start, argsFrom(src, m.end - 1));
    }
  }

  int lineOf(String src, int offset) =>
      '\n'.allMatches(src.substring(0, offset)).length + 1;

  test('no navigation, URL, share or clipboard call carries seed material', () {
    final offenders = <String>[];
    for (final file in appSources()) {
      final src = file.readAsStringSync();
      for (final (at, args) in callArgs(sinkCall, src)) {
        final hit = sensitive.firstMatch(args.replaceAll(routeNameRef, ''));
        if (hit != null) {
          offenders.add('${file.path}:${lineOf(src, at)} (${hit[0]})');
        }
      }
      for (final m in RegExp(r'''getParam[^(]*\(\s*['"]([^'"]+)['"]''')
          .allMatches(src)) {
        if (sensitive.hasMatch(m[1]!)) {
          offenders.add('${file.path}:${lineOf(src, m.start)} (getParam)');
        }
      }
      for (final m in RegExp(r''':(\w+)''').allMatches(src)) {
        // Path templates such as '/showSeed/:mnemonic'.
        if (m.start > 0 &&
            '\'"/'.contains(src[m.start - 1]) &&
            sensitive.hasMatch(m[1]!)) {
          offenders.add('${file.path}:${lineOf(src, m.start)} (path template)');
        }
      }
    }
    expect(offenders, isEmpty,
        reason: 'Mnemonic must use SeedHandoff, never router params, URLs, '
            'share sheets or the clipboard');
  });

  test('no log call anywhere mentions seed material', () {
    final offenders = <String>[];
    for (final file in appSources()) {
      final src = file.readAsStringSync();
      for (final (at, args) in callArgs(logCall, src)) {
        if (sensitive.hasMatch(args.replaceAll(routeNameRef, ''))) {
          offenders.add('${file.path}:${lineOf(src, at)}');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('seed flow files only log plain string literals', () {
    final plainLiteral = RegExp(r'''^\s*('[^'$\\]*'|"[^"$\\]*")\s*,?\s*$''');
    final offenders = <String>[];
    for (final path in seedFlowFiles) {
      final src = File(path).readAsStringSync();
      for (final (at, args) in callArgs(logCall, src)) {
        if (!plainLiteral.hasMatch(args)) {
          offenders.add('$path:${lineOf(src, at)}');
        }
      }
    }
    expect(offenders, isEmpty,
        reason: 'Variables or interpolation in a seed-flow log call can leak '
            'the mnemonic through an alias');
  });

  group('SeedHandoff', () {
    tearDown(SeedHandoff.clear);

    test('returns mnemonic only for the matching decoy id', () {
      SeedHandoff.put(mnemonic: 'abandon ability', decoyId: 'd1');
      expect(SeedHandoff.mnemonicFor('d1'), 'abandon ability');
      expect(SeedHandoff.mnemonicFor('d2'), isNull);
      expect(SeedHandoff.mnemonicFor(null), isNull);
    });

    test('clear drops the mnemonic', () {
      SeedHandoff.put(mnemonic: 'abandon ability', decoyId: 'd1');
      SeedHandoff.clear();
      expect(SeedHandoff.hasPending, isFalse);
      expect(SeedHandoff.mnemonicFor('d1'), isNull);
    });

    test('a new generation replaces the previous mnemonic', () {
      SeedHandoff.put(mnemonic: 'old words', decoyId: 'd1');
      SeedHandoff.put(mnemonic: 'new words', decoyId: 'd2');
      expect(SeedHandoff.mnemonicFor('d1'), isNull);
      expect(SeedHandoff.mnemonicFor('d2'), 'new words');
    });
  });
}
