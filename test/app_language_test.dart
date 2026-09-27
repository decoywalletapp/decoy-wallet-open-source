import 'dart:convert';
import 'dart:io';

import 'package:decoy_wallet_app/l10n/app_language_controller.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:decoy_wallet_app/l10n/language_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('language preference persists without modifying account preferences',
      () async {
    SharedPreferences.setMockInitialValues({'account_marker': 'unchanged'});
    final language = AppLanguageController();
    await language.initialize();
    expect(language.locale, isNull);
    expect(await language.setLanguage('es'), isTrue);
    final reopened = AppLanguageController();
    await reopened.initialize();
    expect(reopened.locale, const Locale('es'));
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('account_marker'), 'unchanged');
    expect(await reopened.setLanguage(null), isTrue);
    expect(
        preferences.containsKey(AppLanguageController.preferenceKey), isFalse);
  });

  test('unsupported preference falls back to device language safely', () async {
    SharedPreferences.setMockInitialValues(
        {AppLanguageController.preferenceKey: 'invalid'});
    final language = AppLanguageController();
    await language.initialize();
    expect(language.locale, isNull);
    expect(await language.setLanguage('invalid'), isFalse);
    expect(language.locale, isNull);
  });

  test('rapid selections persist the final choice', () async {
    final language = AppLanguageController();
    await language.initialize();
    await Future.wait([language.setLanguage('es'), language.setLanguage('en')]);
    final reopened = AppLanguageController();
    await reopened.initialize();
    expect(reopened.languageCode, 'en');
  });

  test('every English message has a non-empty Spanish translation', () {
    final en =
        jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync()) as Map;
    final es =
        jsonDecode(File('lib/l10n/app_es.arb').readAsStringSync()) as Map;
    final keys = en.keys.where((key) => !key.toString().startsWith('@'));
    expect(keys.length, greaterThan(450));
    expect(es.keys.where((key) => !key.toString().startsWith('@')).toSet(),
        keys.toSet());
    for (final key in keys) {
      expect(es[key], isA<String>());
      expect((es[key] as String).trim(), isNotEmpty, reason: '$key');
    }
  });

  testWidgets(
      'picker changes language immediately and preserves route/form state',
      (tester) async {
    final language = AppLanguageController();
    await language.initialize();
    final text = TextEditingController(text: 'unchanged@example.com');
    addTearDown(text.dispose);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: language,
      child: Builder(
          builder: (context) => MaterialApp(
                locale: context.watch<AppLanguageController>().locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                    body: Column(children: [
                  const LanguagePickerButton(),
                  TextField(controller: text),
                ])),
              )),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('language-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('language-es')));
    await tester.pumpAndSettle();
    expect(find.text('Idioma'), findsOneWidget);
    expect(text.text, 'unchanged@example.com');
    expect(language.languageCode, 'es');
    await tester.tap(find.byKey(const ValueKey('language-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('language-en')));
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final languageCode in ['es', 'ja']) {
    testWidgets('device language resolves safely for $languageCode',
        (tester) async {
      tester.platformDispatcher.localesTestValue = [Locale(languageCode)];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
            builder: (context) =>
                Text(AppLocalizations.of(context)!.msgLanguage)),
      ));
      await tester.pumpAndSettle();
      expect(find.text(languageCode == 'es' ? 'Idioma' : 'Language'),
          findsOneWidget);
    });
  }
}
