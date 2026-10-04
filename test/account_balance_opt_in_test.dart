import 'dart:async';

import 'package:decoy_wallet_app/app_state.dart';
import 'package:decoy_wallet_app/services/account_balance.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/account_balance_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime.utc(2026, 10, 4);
  late MemoryRemote remote;
  late MemoryCache cache;
  late AccountBalance balance;

  setUp(() {
    remote = MemoryRemote(now: () => now);
    cache = MemoryCache();
    balance = AccountBalance(
        remote: remote,
        cache: cache,
        now: () => now,
        randomSats: () => 300000000);
  });
  tearDown(() {
    FFAppState.reset();
    balance.dispose();
  });

  test('loading an existing nonenrolled account never adopts or seeds it',
      () async {
    await balance.selectUser('legacy');
    await balance.refresh();
    await balance.ensureSeeded();
    expect(balance.eligible, false);
    expect(remote.values, isEmpty);
    expect(remote.applied, isEmpty);
  });

  test('explicit adoption preserves every satoshi and manual zero', () async {
    for (final amount in [0.0, 0.00000001, 12.34567891, 21000000.0]) {
      final id = 'legacy-$amount';
      await balance.selectUser(id);
      expect(await balance.adopt(amount, expectedUserId: id), true);
      expect(balance.value.sats, (amount * 100000000).round());
      expect(balance.value.configuredSats, balance.value.sats);
      expect(balance.value.drainedAt, isNull);
    }
  });

  test('existing account value wins over another device legacy amount',
      () async {
    await balance.selectUser('legacy');
    final saved = BalanceSnapshot(
        sats: 150000000,
        configuredSats: 200000000,
        seededAt: now,
        epoch: 'existing');
    remote.values['legacy'] = saved;
    remote.users.add('legacy');
    expect(await balance.adopt(99, expectedUserId: 'legacy'), false);
    expect(balance.value.sats, 150000000);
    expect(balance.value.configuredSats, 200000000);
    expect(remote.applied, isEmpty);
  });

  test('adoption never replaces an existing drained balance or timer',
      () async {
    await balance.selectUser('legacy');
    final saved = BalanceSnapshot(
        sats: 0,
        configuredSats: 200000000,
        seededAt: now,
        drainedAt: now,
        epoch: 'existing');
    remote.values['legacy'] = saved;
    expect(await balance.adopt(99, expectedUserId: 'legacy'), false);
    expect(balance.value.sats, 0);
    expect(balance.value.drainedAt, now);
    expect(balance.value.configuredSats, 200000000);
  });

  test('offline adoption leaves legacy eligibility and storage intact',
      () async {
    await balance.selectUser('legacy');
    final before = cache.values['legacy'];
    remote.offline = true;
    expect(await balance.adopt(7, expectedUserId: 'legacy'), false);
    expect(balance.eligible, false);
    expect(cache.values['legacy'], before);
    expect(remote.values, isEmpty);
    expect(balance.hasPendingChanges, false);
  });

  test('lost adoption response can be retried without replacing server value',
      () async {
    await balance.selectUser('legacy');
    remote.loseNextReply = true;
    expect(await balance.adopt(7, expectedUserId: 'legacy'), false);
    expect(balance.eligible, false);
    expect(remote.values['legacy']!.sats, 700000000);
    expect(await balance.adopt(99, expectedUserId: 'legacy'), false);
    expect(balance.value.sats, 700000000);
    expect(await balance.adopt(7, expectedUserId: 'legacy'), true);
    expect(remote.applied.length, 1);
  });

  test('storage failure after server adoption recovers without reseeding',
      () async {
    await balance.selectUser('legacy');
    cache.fail = true;
    expect(await balance.adopt(7, expectedUserId: 'legacy'), false);
    expect(balance.eligible, false);
    cache.fail = false;
    await balance.refresh();
    expect(balance.eligible, true);
    expect(balance.value.sats, 700000000);
    expect(remote.applied.length, 1);
  });

  test('stale save cannot adopt a different signed-in account', () async {
    await balance.selectUser('legacy');
    await balance.selectUser('other');
    expect(await balance.adopt(7, expectedUserId: 'legacy'), false);
    expect(remote.values, isEmpty);
  });

  test('late adoption reply is not exposed to a newly selected account',
      () async {
    await balance.selectUser('legacy');
    remote.blockAdoption = Completer<void>();
    final saving = balance.adopt(7, expectedUserId: 'legacy');
    await Future<void>.delayed(Duration.zero);
    await balance.selectUser('other');
    remote.blockAdoption!.complete();
    expect(await saving, false);
    expect(balance.userId, 'other');
    expect(balance.eligible, false);
    expect(balance.value.sats, 0);
    expect(remote.values['other'], isNull);
  });

  test('refresh racing adoption cannot revert the account to legacy mode',
      () async {
    await balance.selectUser('legacy');
    remote.blockAdoption = Completer<void>();
    final saving = balance.adopt(7, expectedUserId: 'legacy');
    await Future<void>.delayed(Duration.zero);
    final refreshing = balance.refresh();
    remote.blockAdoption!.complete();
    expect(await saving, true);
    await refreshing;
    expect(balance.eligible, true);
    expect(balance.value.sats, 700000000);
  });

  test(
      'adopted account survives restart and another device sees the same amount',
      () async {
    await balance.selectUser('legacy');
    await balance.adopt(7, expectedUserId: 'legacy');
    final restarted = AccountBalance(remote: remote, cache: cache);
    final otherPhone = AccountBalance(remote: remote, cache: MemoryCache());
    addTearDown(restarted.dispose);
    addTearDown(otherPhone.dispose);
    await restarted.selectUser('legacy');
    await otherPhone.selectUser('legacy');
    expect(restarted.value.sats, 700000000);
    expect(otherPhone.value.sats, 700000000);
    expect(remote.applied.length, 1);
  });

  test(
      'first offline upgrade preserves legacy value; Set never overwrites its backup',
      () async {
    FlutterSecureStorage.setMockInitialValues({
      'ff_fakeBtcBalance': '7.25',
      'ff_fakeSeeded': 'true',
      'ff_fakeBtcSeededAt': now.toIso8601String(),
    });
    FFAppState.reset();
    final app = FFAppState();
    await app.initializePersistedState();
    app.attachAccountBalance(balance);
    remote.offline = true;
    await app.selectBalanceUser('legacy');
    expect(app.fakeBtcBalance, 7.25);
    expect(app.isSimulatedBalanceReady, true);
    expect(await app.configureSimulatedBalance(9), false);
    expect(app.fakeBtcBalance, 7.25);
    remote.offline = false;
    await app.refreshAccountBalance();
    expect(
        await app.configureSimulatedBalance(7.25,
            expectedUserId: 'legacy', expectedAccountMode: false),
        true);
    expect(await app.secureStorage.read(key: 'ff_fakeBtcBalance'), '7.25');
    await app.selectBalanceUser('other');
    expect(app.usesSavedAccountBalance, false);
    expect(app.fakeBtcBalance, 7.25);
  });

  test('stale legacy editor cannot replace an account value after a refresh',
      () async {
    FlutterSecureStorage.setMockInitialValues({});
    FFAppState.reset();
    final app = FFAppState();
    await app.initializePersistedState();
    app.attachAccountBalance(balance);
    await app.selectBalanceUser('legacy');
    expect(await app.configureSimulatedBalance(2), true);
    expect(
        await app.configureSimulatedBalance(99,
            expectedUserId: 'legacy', expectedAccountMode: false),
        false);
    expect(app.fakeBtcBalance, 2);
  });

  for (final stored in ['0.0', '0.00000001', '4.52380952', '195.0']) {
    for (final seeded in [false, true]) {
      test('upgrade and Set preserve old $stored BTC (seeded: $seeded)',
          () async {
        FlutterSecureStorage.setMockInitialValues({
          'ff_fakeBtcBalance': stored,
          'ff_fakeSeeded': '$seeded',
          'ff_fakeBtcSeededAt':
              now.subtract(const Duration(days: 30)).toIso8601String(),
        });
        FFAppState.reset();
        final app = FFAppState();
        await app.initializePersistedState();
        app.attachAccountBalance(balance);
        remote.offline = true;
        await app.selectBalanceUser('legacy');
        expect((app.fakeBtcBalance * 100000000).round(),
            (double.parse(stored) * 100000000).round());
        remote.offline = false;
        await app.refreshAccountBalance();
        expect(await app.secureStorage.read(key: 'ff_fakeBtcBalance'), stored);
        expect(remote.values, isEmpty);
        expect(remote.applied, isEmpty);
        expect(await app.configureSimulatedBalance(double.parse(stored)), true);
        expect(balance.value.sats, (double.parse(stored) * 100000000).round());
        expect(balance.value.configuredSats, balance.value.sats);
        expect(balance.value.drainedAt, isNull);
        expect(await app.secureStorage.read(key: 'ff_fakeBtcBalance'), stored);
      });
    }
  }

  test(
      'Set can change the amount while switching storage without modifying other accounts',
      () async {
    FlutterSecureStorage.setMockInitialValues({
      'ff_fakeBtcBalance': '200.0',
      'ff_fakeSeeded': 'true',
    });
    FFAppState.reset();
    final app = FFAppState();
    await app.initializePersistedState();
    app.attachAccountBalance(balance);
    final savedOther = BalanceSnapshot(
        sats: 150000000,
        configuredSats: 175000000,
        seededAt: now,
        epoch: 'other-account');
    remote.values['a'] = savedOther;
    await app.selectBalanceUser('legacy');
    expect(await app.configureSimulatedBalance(250), true);
    expect(balance.value.sats, 25000000000);
    expect(remote.values['a'], same(savedOther));
    expect(await app.secureStorage.read(key: 'ff_fakeBtcBalance'), '200.0');
    expect(
        await app.configureSimulatedBalance(300,
            expectedUserId: 'legacy', expectedAccountMode: true),
        true);
    await balance.refresh();
    expect(remote.values['legacy']!.sats, 30000000000);
  });

  test(
      'Set from an older device cannot claim an existing account amount was saved',
      () async {
    FlutterSecureStorage.setMockInitialValues({'ff_fakeBtcBalance': '99.0'});
    FFAppState.reset();
    final app = FFAppState();
    await app.initializePersistedState();
    app.attachAccountBalance(balance);
    await app.selectBalanceUser('legacy');
    remote.values['legacy'] = BalanceSnapshot(
        sats: 0,
        configuredSats: 200000000,
        seededAt: now,
        drainedAt: now,
        epoch: 'drained');
    expect(
        await app.configureSimulatedBalance(99,
            expectedUserId: 'legacy', expectedAccountMode: false),
        false);
    expect(balance.value.sats, 0);
    expect(balance.value.drainedAt, now);
    expect(balance.value.configuredSats, 200000000);
    expect(remote.applied, isEmpty);
  });

  test('signed-out Set cannot adopt or modify the legacy value', () async {
    FlutterSecureStorage.setMockInitialValues({'ff_fakeBtcBalance': '7.25'});
    FFAppState.reset();
    final app = FFAppState();
    await app.initializePersistedState();
    app.attachAccountBalance(balance);
    expect(await app.configureSimulatedBalance(99), false);
    expect(await app.secureStorage.read(key: 'ff_fakeBtcBalance'), '7.25');
    expect(remote.values, isEmpty);
  });

  test(
      'new signup ignores another accounts legacy balance and starts with the new default',
      () async {
    FlutterSecureStorage.setMockInitialValues({'ff_fakeBtcBalance': '99.0'});
    FFAppState.reset();
    final app = FFAppState();
    await app.initializePersistedState();
    app.attachAccountBalance(balance);
    remote.newAccountUsers.add('new-user');
    remote.delayedUser = 'new-user';
    remote.delayedRead = Completer<BalanceReply>();
    final selecting = app.selectBalanceUser('new-user');
    expect(app.isSimulatedBalanceReady, false);
    expect(app.fakeBtcBalance, isNot(99));
    remote.delayedUser = null;
    remote.delayedRead!.complete(const BalanceReply(true, BalanceSnapshot()));
    await selecting;
    expect(app.fakeBtcBalance, 3);
    expect(balance.value.configuredSats, isNull);
    expect(remote.values['new-user']!.sats, 300000000);
    expect(await app.secureStorage.read(key: 'ff_fakeBtcBalance'), '99.0');
    await app.selectBalanceUser('legacy');
    expect(app.fakeBtcBalance, 99);
    expect(balance.eligible, false);
  });

  test('new signup offline does not use or modify a shared device balance',
      () async {
    FlutterSecureStorage.setMockInitialValues({'ff_fakeBtcBalance': '99.0'});
    FFAppState.reset();
    final app = FFAppState();
    await app.initializePersistedState();
    app.attachAccountBalance(balance);
    remote.newAccountUsers.add('new-user');
    remote.offline = true;
    await app.selectBalanceUser('new-user');
    expect(app.isSimulatedBalanceReady, false);
    expect(app.fakeBtcBalance, isNot(99));
    await app.ensureSimulatedBalance();
    expect(remote.values, isEmpty);
    expect(await app.secureStorage.read(key: 'ff_fakeBtcBalance'), '99.0');
    remote.offline = false;
    await app.refreshAccountBalance();
    expect(app.isSimulatedBalanceReady, true);
    expect(app.fakeBtcBalance, 3);
    expect(balance.value.configuredSats, isNull);
  });
}
