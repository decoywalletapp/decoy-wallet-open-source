import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:decoy_wallet_app/app_state.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:decoy_wallet_app/services/account_balance.dart';
import 'package:decoy_wallet_app/settings_pages/configure_bitcoin_balance/configure_bitcoin_balance_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';

import 'localization_fonts.dart';
import 'support/account_balance_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime.utc(2026, 10, 3, 12);
  late MemoryRemote remote;
  late AccountBalance balance;
  final boundaryKey = GlobalKey();

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await loadLocalizationFonts();
  });
  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    FFAppState.reset();
    await FFAppState().initializePersistedState();
    remote = MemoryRemote(now: () => now);
    balance = AccountBalance(
        remote: remote,
        cache: MemoryCache(),
        now: () => now,
        randomSats: () => 314159265);
    FFAppState().attachAccountBalance(balance);
  });
  tearDown(() {
    FFAppState.reset();
    balance.dispose();
  });

  Future<void> showPage(WidgetTester tester,
      {Locale locale = const Locale('en')}) {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    return tester.pumpWidget(RepaintBoundary(
        key: boundaryKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              useMaterial3: false,
              fontFamily: 'robot',
              fontFamilyFallback: decoyFontFallbacks(locale)),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ConfigureBitcoinBalanceWidget(),
        )));
  }

  Future<void> capture(WidgetTester tester, String name) async {
    if (!const bool.fromEnvironment('DECOY_CAPTURE_BALANCE')) return;
    final boundary = boundaryKey.currentContext!.findRenderObject()!
        as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final directory = Directory('/private/tmp/decoy-balance-opt-in-screens');
      await directory.create(recursive: true);
      await File('${directory.path}/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  String amount(WidgetTester tester) =>
      tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text;

  testWidgets('first settings visit waits then shows the saved random default',
      (tester) async {
    remote.delayedUser = 'a';
    remote.delayedRead = Completer<BalanceReply>();
    final selecting = balance.selectUser('a');
    await showPage(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
    remote.delayedUser = null;
    remote.delayedRead!.complete(const BalanceReply(true, BalanceSnapshot()));
    await selecting;
    await tester.pumpAndSettle();
    expect(amount(tester), '3.14159265');
    expect(remote.values['a']!.sats, 314159265);
    expect(remote.values['a']!.configuredSats, isNull);
    expect(remote.applied.length, 1);
    await balance.ensureSeeded();
    await balance.refresh();
    expect(balance.value.sats, 314159265);
    expect(remote.applied.length, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a saved manual zero remains visible and editable',
      (tester) async {
    remote.values['a'] = BalanceSnapshot(
        sats: 0, configuredSats: 0, seededAt: now, epoch: 'zero');
    await balance.selectUser('a');
    await showPage(tester);
    await tester.pumpAndSettle();
    expect(amount(tester), '0');
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(remote.applied, isEmpty);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull);
  });

  testWidgets('an expired drain is not refilled by opening settings',
      (tester) async {
    remote.values['a'] = BalanceSnapshot(
        sats: 0,
        configuredSats: 200000000,
        seededAt: now.subtract(const Duration(days: 5)),
        drainedAt: now.subtract(const Duration(days: 2)),
        epoch: 'drained');
    await balance.selectUser('a');
    await showPage(tester);
    await tester.pumpAndSettle();
    expect(amount(tester), '0');
    expect(remote.applied, isEmpty);
    expect(balance.value.configuredSats, 200000000);
  });

  testWidgets('offline first visit offers retry without a false zero or save',
      (tester) async {
    remote.offline = true;
    await balance.selectUser('a');
    await showPage(tester);
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
    expect(find.text('Retry'), findsOneWidget);
    remote.offline = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(amount(tester), '3.14159265');
    expect(remote.applied.length, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('background refresh does not overwrite the users unsaved input',
      (tester) async {
    await balance.selectUser('a');
    remote.delayedUser = 'a';
    remote.delayedRead = Completer<BalanceReply>();
    await showPage(tester);
    expect(amount(tester), '3.14159265');
    await tester.enterText(find.byType(TextFormField), '200');
    remote.delayedRead!.complete(BalanceReply(true, remote.values['a']!));
    await tester.pumpAndSettle();
    expect(amount(tester), '200');
    expect(remote.values['a']!.sats, 314159265);
  });

  testWidgets(
      'closing the page while loading does not update a disposed widget',
      (tester) async {
    remote.delayedUser = 'a';
    remote.delayedRead = Completer<BalanceReply>();
    final selecting = balance.selectUser('a');
    await showPage(tester);
    await tester.pumpWidget(const SizedBox());
    remote.delayedUser = null;
    remote.delayedRead!.complete(const BalanceReply(true, BalanceSnapshot()));
    await selecting;
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets(
        'optional adoption fits ${locale.languageCode} and cancellation preserves legacy balance',
        (tester) async {
      await balance.selectUser('legacy');
      await FFAppState().configureSimulatedBalance(12.34567891);
      await showPage(tester, locale: locale);
      tester.view.physicalSize = const Size(320, 640);
      await tester.pumpAndSettle();
      expect(amount(tester), '12.34567891');
      final strings =
          AppLocalizations.of(tester.element(find.byType(TextFormField)))!;
      final button =
          find.widgetWithText(OutlinedButton, strings.msgSaveBalanceToAccount);
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await capture(tester, 'balance-${locale.languageCode}');
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await capture(tester, 'confirmation-${locale.languageCode}');
      expect(tester.takeException(), isNull);
      await tester.tap(find.text(strings.msgCancel));
      await tester.pumpAndSettle();
      expect(remote.values, isEmpty);
      expect(balance.eligible, false);
      expect(FFAppState().fakeBtcBalance, 12.34567891);
    });

    testWidgets('retry state fits ${locale.languageCode} on a small phone',
        (tester) async {
      remote.offline = true;
      await balance.selectUser('a');
      await showPage(tester, locale: locale);
      tester.view.physicalSize = const Size(320, 640);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('ordinary Set still uses legacy storage without enrolling',
      (tester) async {
    await balance.selectUser('legacy');
    await FFAppState().configureSimulatedBalance(7);
    await showPage(tester);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '9');
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(FFAppState().fakeBtcBalance, 9);
    expect(balance.eligible, false);
    expect(remote.values, isEmpty);
  });

  Future<void> openAdoption(WidgetTester tester) async {
    final button =
        find.widgetWithText(OutlinedButton, 'Save this balance to my account');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets(
      'confirmation adopts the displayed amount without changing legacy storage',
      (tester) async {
    await balance.selectUser('legacy');
    await FFAppState().configureSimulatedBalance(12.34567891);
    await showPage(tester);
    await tester.pumpAndSettle();
    await openAdoption(tester);
    expect(remote.values, isEmpty);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(balance.eligible, true);
    expect(amount(tester), '12.34567891');
    expect(remote.values['legacy']!.sats, 1234567891);
    expect(await FFAppState().secureStorage.read(key: 'ff_fakeBtcBalance'),
        '12.34567891');
    expect(find.byIcon(Icons.cloud_upload_outlined), findsNothing);
  });

  testWidgets('second device confirmation keeps the existing account balance',
      (tester) async {
    await balance.selectUser('legacy');
    await FFAppState().configureSimulatedBalance(12);
    await showPage(tester);
    await tester.pumpAndSettle();
    await openAdoption(tester);
    remote.values['legacy'] = BalanceSnapshot(
        sats: 150000000,
        configuredSats: 200000000,
        epoch: 'existing',
        seededAt: now);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(amount(tester), '1.5');
    expect(balance.value.configuredSats, 200000000);
    expect(remote.applied, isEmpty);
  });

  testWidgets('failed adoption keeps the device balance and allows retry',
      (tester) async {
    await balance.selectUser('legacy');
    await FFAppState().configureSimulatedBalance(7);
    await showPage(tester);
    await tester.pumpAndSettle();
    await openAdoption(tester);
    remote.offline = true;
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(amount(tester), '7');
    expect(remote.values, isEmpty);
    expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);
    expect(balance.eligible, false);
  });

  testWidgets(
      'changing accounts while confirmation is open does not copy a balance',
      (tester) async {
    await balance.selectUser('legacy');
    await FFAppState().configureSimulatedBalance(7);
    await showPage(tester);
    await tester.pumpAndSettle();
    await openAdoption(tester);
    await balance.selectUser('other');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(remote.values, isEmpty);
    expect(balance.userId, 'other');
    expect(balance.eligible, false);
  });
}
