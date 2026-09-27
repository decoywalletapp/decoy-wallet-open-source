import 'dart:convert';
import 'dart:io';

import 'package:decoy_wallet_app/l10n/app_language_controller.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:decoy_wallet_app/l10n/language_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'localization_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadLocalizationFonts);

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

  test('every supported language has a complete translation catalog', () {
    final en =
        jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync()) as Map;
    final keys = en.keys.where((key) => !key.toString().startsWith('@'));
    expect(keys.length, greaterThan(450));
    expect(AppLanguageController.supportedLanguageCodes, hasLength(18));
    expect(AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
        AppLanguageController.supportedLanguageCodes);
    for (final code in AppLanguageController.supportedLanguageCodes) {
      final catalog =
          jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync()) as Map;
      expect(catalog['@@locale'], code);
      expect(
          catalog.keys.where((key) => !key.toString().startsWith('@')).toSet(),
          keys.toSet(),
          reason: code);
      for (final key in keys) {
        expect(catalog[key], isA<String>(), reason: '$code/$key');
        expect((catalog[key] as String).trim(), isNotEmpty,
            reason: '$code/$key');
        if (en['@$key'] != null) {
          expect(catalog['@$key'], en['@$key'], reason: '$code/$key metadata');
        }
      }
    }
  });

  for (final code in AppLanguageController.supportedLanguageCodes) {
    test('$code preference persists independently of account settings',
        () async {
      final language = AppLanguageController();
      await language.initialize();
      expect(await language.setLanguage(code), isTrue);
      final reopened = AppLanguageController();
      await reopened.initialize();
      expect(reopened.locale, Locale(code));
    });
  }

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

  testWidgets(
      'every language can be selected on a small phone without losing input',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final language = AppLanguageController();
    await language.initialize();
    final input = TextEditingController(text: 'unchanged@example.com');
    addTearDown(input.dispose);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: language,
      child: Builder(builder: (context) {
        final locale = context.watch<AppLanguageController>().locale;
        return MaterialApp(
          locale: locale,
          theme: ThemeData(fontFamilyFallback: decoyFontFallbacks(locale)),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
              body: Column(children: [
            const LanguagePickerButton(),
            TextField(controller: input),
          ])),
        );
      }),
    ));
    for (final code in AppLanguageController.supportedLanguageCodes) {
      await tester.pumpAndSettle();
      final button = find.byKey(const ValueKey('language-picker'));
      expect(tester.getCenter(button).dx, greaterThan(160));
      await tester.tap(button);
      await tester.pumpAndSettle();
      final systemOption = tester.widget<ListTile>(
          find.byKey(const ValueKey('language-system')));
      expect((systemOption.title! as Text).textDirection,
          Directionality.of(tester.element(button)));
      final choice = find.byKey(ValueKey('language-$code'));
      await tester.scrollUntilVisible(choice, 150,
          scrollable: find.byType(Scrollable).last);
      await tester.ensureVisible(choice);
      await tester.pumpAndSettle();
      await tester.tap(choice);
      await tester.pumpAndSettle();
      expect(language.languageCode, code);
      expect(input.text, 'unchanged@example.com');
      expect(Localizations.localeOf(tester.element(button)).languageCode, code);
      expect(tester.takeException(), isNull);
    }
  });

  for (final languageCode in [
    ...AppLanguageController.supportedLanguageCodes,
    'xx'
  ]) {
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
      final expectedCode = languageCode == 'xx' ? 'en' : languageCode;
      final element = tester.element(find.byType(Text).first);
      expect(Localizations.localeOf(element).languageCode, expectedCode);
      expect(
          Directionality.of(element),
          {'ar', 'he'}.contains(expectedCode)
              ? TextDirection.rtl
              : TextDirection.ltr);
      expect(tester.takeException(), isNull);
    });
  }
}
