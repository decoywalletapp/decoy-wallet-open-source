import 'package:decoy_wallet_app/app_state.dart';
import 'package:decoy_wallet_app/services/account_balance.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/account_balance_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DateTime accountNow;
  late MemoryRemote remote;
  late AccountBalance balance;

  setUp(() {
    accountNow = DateTime.now().toUtc();
    remote = MemoryRemote(now: () => accountNow);
    balance = AccountBalance(
        remote: remote,
        cache: MemoryCache(),
        now: () => accountNow,
        randomSats: () => 300000000);
  });

  tearDown(() {
    FFAppState.reset();
    balance.dispose();
  });

  Future<FFAppState> loadLegacy(
      double amount, DateTime seededAt, String mode) async {
    FlutterSecureStorage.setMockInitialValues({
      'ff_fakeBtcBalance': '$amount',
      'ff_fakeSeeded': 'true',
      'ff_fakeBtcSeededAt': seededAt.toIso8601String(),
    });
    FFAppState.reset();
    final app = FFAppState();
    await app.initializePersistedState();
    if (mode != 'disabled') {
      app.attachAccountBalance(balance);
      remote.offline = mode == 'offline';
      await app.selectBalanceUser('legacy');
    }
    return app;
  }

  int sats(FFAppState app) => (app.fakeBtcBalance * 100000000).round();

  // 1.1.6 measures 24 hours from seeding/configuration, not from draining.
  // Check the same fixtures with no service, unknown offline eligibility, and
  // confirmed legacy eligibility. Only entering the PIN path may reseed them.
  for (final mode in ['disabled', 'offline', 'online']) {
    for (final amount in [0.0, 0.00000001, 4.52380952, 195.0]) {
      for (final expired in [false, true]) {
        test('$mode legacy $amount retains original reset (expired: $expired)',
            () async {
          final startedAt = DateTime.now().toUtc().subtract(expired
              ? const Duration(hours: 24, minutes: 1)
              : const Duration(hours: 23, minutes: 59));
          final app = await loadLegacy(amount, startedAt, mode);
          expect(sats(app), (amount * 100000000).round());
          expect(app.fakeBtcSeededAt, startedAt);
          expect(app.shouldSeedFakeBtcBalance, expired);
          expect(app.fakeSeeded, !expired);
          expect(await app.secureStorage.read(key: 'ff_fakeBtcBalance'),
              '$amount');

          await app.ensureSimulatedBalance();
          if (expired) {
            expect(app.fakeBtcBalance, inInclusiveRange(1, 5));
            expect(app.fakeBtcSeededAt!.isAfter(startedAt), true);
          } else {
            expect(sats(app), (amount * 100000000).round());
            expect(app.fakeBtcSeededAt, startedAt);
          }
          expect(app.shouldSeedFakeBtcBalance, false);
          final retained = sats(app);
          final retainedSeed = app.fakeBtcSeededAt;
          await app.ensureSimulatedBalance();
          expect(sats(app), retained);
          expect(app.fakeBtcSeededAt, retainedSeed);

          await Future<void>.delayed(Duration.zero);
          FFAppState.reset();
          final restarted = FFAppState();
          await restarted.initializePersistedState();
          if (mode != 'disabled') {
            restarted.attachAccountBalance(balance);
            await restarted.selectBalanceUser('legacy');
          }
          await restarted.ensureSimulatedBalance();
          expect(sats(restarted), retained);
          expect(restarted.fakeBtcSeededAt?.toUtc(), retainedSeed?.toUtc());
          expect(remote.values, isEmpty);
          expect(remote.applied, isEmpty);
          expect(remote.users, isNot(contains('legacy')));
        });
      }
    }

    for (final send in ['5', '200']) {
      test('$mode legacy send $send keeps the original configuration clock',
          () async {
        final startedAt = DateTime.now().toUtc()
            .subtract(const Duration(hours: 23, minutes: 59));
        final app = await loadLegacy(200, startedAt, mode);
        expect(await app.spendSimulatedBalance(send, 0.00001), true);
        expect(sats(app), send == '5' ? 19500000000 : 0);
        expect(app.fakeBtcSeededAt, startedAt);
        await app.ensureSimulatedBalance();
        expect(sats(app), send == '5' ? 19500000000 : 0);

        // Advance the original clock in mock storage, not any user account.
        app.fakeBtcSeededAt = DateTime.now().toUtc()
            .subtract(const Duration(hours: 24, minutes: 1));
        await app.ensureSimulatedBalance();
        expect(app.fakeBtcBalance, inInclusiveRange(1, 5));
        expect(remote.values, isEmpty);
        expect(remote.applied, isEmpty);
      });
    }
  }

  test('normal Set moves an aged legacy amount to the tested account rules',
      () async {
    final startedAt = accountNow.subtract(const Duration(days: 30));
    final app = await loadLegacy(195, startedAt, 'online');
    expect(app.fakeBtcBalance, 195);
    expect(app.shouldSeedFakeBtcBalance, true);
    expect(
        await app.configureSimulatedBalance(195,
            expectedUserId: 'legacy', expectedAccountMode: false),
        true);
    expect(app.usesSavedAccountBalance, true);
    await app.ensureSimulatedBalance();
    expect(app.fakeBtcBalance, 195);
    expect(balance.value.configuredSats, 19500000000);

    await app.spendSimulatedBalance('5', 0.00001);
    await balance.refresh();
    accountNow = accountNow.add(const Duration(days: 2));
    await app.ensureSimulatedBalance();
    expect(app.fakeBtcBalance, 190);
    expect(balance.value.drainedAt, isNull);

    await app.spendSimulatedBalance('190', 0.00001);
    await balance.refresh();
    expect(sats(app), 0);
    expect(balance.value.drainedAt, accountNow);
    accountNow = accountNow.add(const Duration(hours: 23, minutes: 59));
    await app.ensureSimulatedBalance();
    expect(sats(app), 0);
    accountNow = accountNow.add(const Duration(minutes: 2));
    await app.ensureSimulatedBalance();
    await balance.refresh();
    expect(app.fakeBtcBalance, 195);
    expect(balance.value.configuredSats, 19500000000);
    expect(balance.value.drainedAt, isNull);
    expect(await app.secureStorage.read(key: 'ff_fakeBtcBalance'), '195.0');
    expect(await app.secureStorage.read(key: 'ff_fakeBtcSeededAt'),
        startedAt.toIso8601String());
  });

  test('normal Set of legacy zero uses the account manual-zero rule', () async {
    final app = await loadLegacy(
        0, accountNow.subtract(const Duration(days: 30)), 'online');
    expect(app.shouldSeedFakeBtcBalance, true);
    expect(await app.configureSimulatedBalance(0), true);
    accountNow = accountNow.add(const Duration(days: 30));
    await app.ensureSimulatedBalance();
    expect(sats(app), 0);
    expect(app.shouldSeedFakeBtcBalance, false);
    expect(balance.value.configuredSats, 0);
    expect(balance.value.drainedAt, isNull);
    expect(await app.secureStorage.read(key: 'ff_fakeBtcBalance'), '0.0');
  });
}
