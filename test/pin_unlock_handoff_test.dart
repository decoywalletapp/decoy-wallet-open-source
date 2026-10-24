import 'package:decoy_wallet_app/components/pin_unlock_handoff.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'localization_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await loadLocalizationFonts();
  });

  for (final reducedMotion in [false, true]) {
    testWidgets(
        'PIN and title fade through without remounting: '
        'reducedMotion=$reducedMotion', (tester) async {
      final active = ValueNotifier(false);
      addTearDown(active.dispose);
      var taps = 0;
      final child = TextButton(
        onPressed: () => taps++,
        child: const Text('PIN INPUT'),
      );
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reducedMotion),
          child: Scaffold(
            backgroundColor: Colors.black,
            body: ValueListenableBuilder<bool>(
              valueListenable: active,
              child: child,
              builder: (_, value, child) =>
                  PinUnlockHandoff(active: value, child: child!),
            ),
          ),
        ),
      ));
      final inputElement = tester.element(find.byType(TextButton));
      double opacity(String key) =>
          tester.widget<Opacity>(find.byKey(ValueKey(key))).opacity;
      expect(opacity('pin-input-opacity'), 1);
      active.value = true;
      await tester.pump();
      expect(
          tester
              .widget<AbsorbPointer>(
                  find.byKey(const ValueKey('pin-input-presentation')))
              .absorbing,
          isTrue);
      expect(find.text('PIN INPUT').hitTestable(), findsNothing);
      if (!reducedMotion) {
        expect(opacity('pin-input-opacity'), 1);
        expect(opacity('pin-title-opacity'), 0);
        await tester.pump(const Duration(milliseconds: 40));
        expect(opacity('pin-input-opacity'), inExclusiveRange(0, 1));
        expect(opacity('pin-title-opacity'), 0);
        await tester.pump(const Duration(milliseconds: 140));
        expect(opacity('pin-input-opacity'), 0);
        expect(opacity('pin-title-opacity'), inExclusiveRange(0, 1));
        await tester.pump(const Duration(milliseconds: 140));
      }
      expect(opacity('pin-input-opacity'), 0);
      expect(opacity('pin-title-opacity'), 1);
      expect(tester.element(find.byType(TextButton)), same(inputElement));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(taps, 0);

      // A failed preparation restores input immediately, with no animation wait.
      active.value = false;
      await tester.pump();
      expect(opacity('pin-input-opacity'), 1);
      expect(find.byKey(const ValueKey('pin-unlock-title')), findsNothing);
      expect(tester.element(find.byType(TextButton)), same(inputElement));
      await tester.tap(find.text('PIN INPUT'));
      expect(taps, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
