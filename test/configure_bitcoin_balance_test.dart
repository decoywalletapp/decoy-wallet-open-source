import 'dart:async';

import 'package:decoy_wallet_app/app_state.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:decoy_wallet_app/services/account_balance.dart';
import 'package:decoy_wallet_app/settings_pages/configure_bitcoin_balance/configure_bitcoin_balance_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'localization_fonts.dart';
import 'support/account_balance_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime.utc(2026, 10, 3, 12);
  late MemoryRemote remote;
  late AccountBalance balance;

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
    return tester.pumpWidget(MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ConfigureBitcoinBalanceWidget(),
    ));
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
}
