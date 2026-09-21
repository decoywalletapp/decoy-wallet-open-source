import 'package:decoy_wallet_app/build_provenance.dart';
import 'package:decoy_wallet_app/create_decoy_seed/generate_decoy_seed_phrase/generate_decoy_seed_phrase_widget.dart';
import 'package:decoy_wallet_app/create_decoy_seed/import_watch_only_wallet/import_watch_only_wallet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final size in [const Size(402, 874), const Size(768, 1024)]) {
    testWidgets('watch-only import entry and route at $size', (tester) async {
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
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(find.text('Generate Seed Phrase'), findsOneWidget);

      final importButton = find.text('Monitor Existing Wallet');
      if (DecoyBuildProvenance.watchOnlyImportEnabled) {
        expect(importButton, findsOneWidget);
        await tester.ensureVisible(importButton);
        await tester.tap(importButton);
        await tester.pumpAndSettle();
        expect(find.byType(ImportWatchOnlyWalletWidget), findsOneWidget);
        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.text('zpub, xpub, or receive addresses'), findsOneWidget);
        expect(find.textContaining('enabled test builds only'), findsNothing);
      } else {
        expect(importButton, findsNothing);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
