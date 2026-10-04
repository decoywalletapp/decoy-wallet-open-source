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

  Future<void> loadLegacy(double amount,
      {Duration age = const Duration(hours: 1)}) async {
    FlutterSecureStorage.setMockInitialValues({
      'ff_fakeBtcBalance': '$amount',
      'ff_fakeSeeded': 'true',
      'ff_fakeBtcSeededAt':
          DateTime.now().toUtc().subtract(age).toIso8601String(),
    });
    FFAppState.reset();
    await FFAppState().initializePersistedState();
    FFAppState().attachAccountBalance(balance);
    await FFAppState().selectBalanceUser('legacy');
  }

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
      final directory = Directory('/private/tmp/decoy-balance-set-screens');
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
        'single Set fits ${locale.languageCode} and saves the exact legacy amount without a prompt',
        (tester) async {
      await loadLegacy(12.34567891);
      await showPage(tester, locale: locale);
      tester.view.physicalSize = const Size(320, 640);
      await tester.pumpAndSettle();
      expect(amount(tester), '12.34567891');
      final strings =
          AppLocalizations.of(tester.element(find.byType(TextFormField)))!;
      final button = find.widgetWithText(FilledButton, strings.msgSet);
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await capture(tester, 'balance-${locale.languageCode}');
      expect(find.byType(OutlinedButton), findsNothing);
      expect(remote.values, isEmpty);
      expect(balance.eligible, false);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
      expect(remote.values['legacy']!.sats, 1234567891);
      expect(balance.eligible, true);
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

  testWidgets(
      'ordinary Set saves to the account and later edits use the same button',
      (tester) async {
    await loadLegacy(7);
    await showPage(tester);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '9');
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(FFAppState().fakeBtcBalance, 9);
    expect(balance.eligible, true);
    expect(remote.values['legacy']!.sats, 900000000);
    expect(
        await FFAppState().secureStorage.read(key: 'ff_fakeBtcBalance'), '7.0');
    await tester.enterText(find.byType(TextFormField), '10');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(FFAppState().fakeBtcBalance, 10);
    expect(remote.values['legacy']!.sats, 1000000000);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
  });

  Future<void> pressSet(WidgetTester tester) async {
    final button = find.byType(FilledButton);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets(
      'opening and closing settings preserves the old amount without migrating',
      (tester) async {
    await loadLegacy(12.34567891);
    await showPage(tester);
    await tester.pumpAndSettle();
    expect(remote.values, isEmpty);
    expect(amount(tester), '12.34567891');
    await tester.pumpWidget(const SizedBox());
    await FFAppState().ensureSimulatedBalance();
    await showPage(tester);
    await tester.pumpAndSettle();
    expect(balance.eligible, false);
    expect(amount(tester), '12.34567891');
    expect(remote.values, isEmpty);
    expect(await FFAppState().secureStorage.read(key: 'ff_fakeBtcBalance'),
        '12.34567891');
    expect(find.byIcon(Icons.cloud_upload_outlined), findsNothing);
  });

  testWidgets('settings preserves an aged local balance; PIN still resets it',
      (tester) async {
    await loadLegacy(195, age: const Duration(days: 30));
    await showPage(tester);
    await tester.pumpAndSettle();
    expect(amount(tester), '195');
    expect(remote.values, isEmpty);
    await tester.pumpWidget(const SizedBox());
    await FFAppState().ensureSimulatedBalance();
    await showPage(tester);
    await tester.pumpAndSettle();
    final displayed = double.parse(amount(tester));
    expect(displayed, inInclusiveRange(1, 5));
    expect(displayed, FFAppState().fakeBtcBalance);
    expect(balance.eligible, false);
    expect(remote.values, isEmpty);
  });

  testWidgets(
      'stale second device Set preserves the account balance without a false success',
      (tester) async {
    await loadLegacy(12);
    await showPage(tester);
    await tester.pumpAndSettle();
    remote.values['legacy'] = BalanceSnapshot(
        sats: 150000000,
        configuredSats: 200000000,
        epoch: 'existing',
        seededAt: now);
    await pressSet(tester);
    expect(amount(tester), '1.5');
    expect(balance.value.configuredSats, 200000000);
    expect(remote.applied, isEmpty);
    final strings =
        AppLocalizations.of(tester.element(find.byType(TextFormField)))!;
    expect(find.text(strings.msgBitcoinBalanceUpdated), findsNothing);
    expect(find.text(strings.msgNotQuiteTryAgain), findsOneWidget);
  });

  testWidgets(
      'offline first Set keeps the device balance and can be retried online',
      (tester) async {
    await loadLegacy(7);
    await showPage(tester);
    await tester.pumpAndSettle();
    remote.offline = true;
    await tester.enterText(find.byType(TextFormField), '9');
    await pressSet(tester);
    expect(amount(tester), '7');
    expect(remote.values, isEmpty);
    expect(find.byIcon(Icons.cloud_upload_outlined), findsNothing);
    expect(balance.eligible, false);
    expect(FFAppState().fakeBtcBalance, 7);
    expect(
        await FFAppState().secureStorage.read(key: 'ff_fakeBtcBalance'), '7.0');
    remote.offline = false;
    await pressSet(tester);
    expect(balance.eligible, true);
    expect(remote.values['legacy']!.sats, 700000000);
  });

  testWidgets(
      'changing accounts while settings is open does not copy a balance',
      (tester) async {
    await loadLegacy(7);
    await showPage(tester);
    await tester.pumpAndSettle();
    await balance.selectUser('other');
    await pressSet(tester);
    expect(remote.values, isEmpty);
    expect(balance.userId, 'other');
    expect(balance.eligible, false);
  });

  testWidgets('Set preserves a legacy zero without creating a drain timer',
      (tester) async {
    await loadLegacy(0);
    await showPage(tester);
    await tester.pumpAndSettle();
    expect(amount(tester), '0');
    await FFAppState().ensureSimulatedBalance();
    await pressSet(tester);
    expect(amount(tester), '0');
    expect(balance.value.configuredSats, 0);
    expect(balance.value.drainedAt, isNull);
  });

  testWidgets('Set is disabled during first save and only one adoption is made',
      (tester) async {
    await loadLegacy(7);
    await showPage(tester);
    await tester.pumpAndSettle();
    remote.blockAdoption = Completer<void>();
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);
    remote.blockAdoption!.complete();
    await tester.pumpAndSettle();
    expect(remote.applied.length, 1);
    expect(balance.value.sats, 700000000);
    expect(tester.takeException(), isNull);
  });
}
