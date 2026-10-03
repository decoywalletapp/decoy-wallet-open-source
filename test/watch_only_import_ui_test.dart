import 'package:decoy_wallet_app/build_provenance.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:decoy_wallet_app/create_decoy_seed/generate_decoy_seed_phrase/generate_decoy_seed_phrase_widget.dart';
import 'package:decoy_wallet_app/create_decoy_seed/import_watch_only_wallet/import_watch_only_wallet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'localization_fonts.dart';

void main() {
  setUpAll(loadLocalizationFonts);
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final code in ['en', 'de', 'nl']) {
    for (final size in [
      const Size(320, 640),
      const Size(402, 874),
      const Size(768, 1024)
    ]) {
      testWidgets('watch-only import entry and route in $code at $size',
          (tester) async {
        final strings = await AppLocalizations.delegate.load(Locale(code));
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final router = GoRouter(routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const GenerateDecoySeedPhraseWidget(),
          ),
          GoRoute(
            name: ImportWatchOnlyWalletWidget.routeName,
            path: ImportWatchOnlyWalletWidget.routePath,
            builder: (_, __) => const ImportWatchOnlyWalletWidget(),
          ),
        ]);
        addTearDown(router.dispose);
        await tester.pumpWidget(MaterialApp.router(
          routerConfig: router,
          locale: Locale(code),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ));
        await tester.pumpAndSettle();
        expect(find.text(strings.msgGenerateSeedPhrase), findsOneWidget);

        final importButton = find.text(strings.msgMonitorExistingWallet);
        if (DecoyBuildProvenance.watchOnlyImportEnabled) {
          expect(importButton, findsOneWidget);
          await tester.ensureVisible(importButton);
          await tester.tap(importButton);
          await tester.pumpAndSettle();
          expect(find.byType(ImportWatchOnlyWalletWidget), findsOneWidget);
          expect(find.byType(TextFormField), findsOneWidget);
          expect(
              find.text(strings.msgZpubXpubOrReceiveAddresses), findsOneWidget);
          expect(
              find.text(strings.msgWatchOnlyWalletImportIsAvailableInEnabled),
              findsNothing);
        } else {
          expect(importButton, findsNothing);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
