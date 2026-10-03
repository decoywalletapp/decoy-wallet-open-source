import 'dart:async';
import 'dart:convert';

import 'package:decoy_wallet_app/app_state.dart';
import 'package:decoy_wallet_app/services/account_balance.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/account_balance_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MemoryRemote remote;
  late MemoryCache cache;
  late AccountBalance balance;
  late DateTime now;

  setUp(() {
    remote = MemoryRemote();
    cache = MemoryCache();
    now = DateTime.utc(2026, 10, 3, 12);
    balance = AccountBalance(
        remote: remote,
        cache: cache,
        now: () => now,
        randomSats: () => 300000000);
  });
  tearDown(() => balance.dispose());

  Future<void> settle() async {
    await Future<void>.delayed(Duration.zero);
    await balance.refresh();
  }

  test('pilot defaults off in an ordinary build', () {
    expect(accountBalancePilotEnabled, isFalse);
  });

  test('all four users have independent values on the same device', () async {
    var amount = 1.0;
    for (final user in ['a', 'b', 'c', 'd']) {
      final ready = balance.selectUser(user);
      expect(balance.value.sats, 0);
      await ready;
      expect(await balance.configure(amount++), isTrue);
      await settle();
    }
    amount = 1;
    for (final user in ['a', 'b', 'c', 'd']) {
      await balance.selectUser(user);
      expect(balance.value.sats, (amount++ * 100000000).round());
    }
    await balance.selectUser(null);
    expect(balance.value.sats, 0);
  });

  test('new account starts with 1 to 5 BTC; reentry does not regenerate',
      () async {
    await balance.selectUser('a');
    await balance.ensureSeeded();
    await settle();
    final epoch = balance.value.epoch;
    expect(balance.value.sats, 300000000);
    await balance.ensureSeeded();
    expect(balance.value.epoch, epoch);
  });

  test('spend persists, zero stays zero, timer does not restart on spend',
      () async {
    await balance.selectUser('a');
    await balance.configure(2);
    await settle();
    final seededAt = balance.value.seededAt;
    now = now.add(const Duration(hours: 12));
    await balance.spend(0.5, 0.00001);
    await settle();
    expect(balance.value.sats, 150000000);
    expect(balance.value.seededAt, seededAt);
    await balance.spend(1.5, 0.00001);
    await settle();
    await balance.ensureSeeded();
    expect(balance.value.sats, 0);
    now = seededAt!.add(const Duration(hours: 24));
    await balance.ensureSeeded();
    expect(balance.value.sats, 300000000);
  });

  test('manual zero is retained until the same 24 hour expiration', () async {
    await balance.selectUser('a');
    await balance.configure(0);
    await settle();
    await balance.ensureSeeded();
    expect(balance.value.sats, 0);
    expect(balance.value.expired(now), isFalse);
  });

  test('configured balance and spending follow account onto another device',
      () async {
    await balance.selectUser('a');
    await balance.configure(7.12345678);
    await settle();
    final phone =
        AccountBalance(remote: remote, cache: MemoryCache(), now: () => now);
    addTearDown(phone.dispose);
    await phone.selectUser('a');
    expect(phone.value.sats, 712345678);
    await phone.spend(1, 0.00001);
    await Future<void>.delayed(Duration.zero);
    await phone.refresh();
    await balance.refresh();
    expect(balance.value.sats, 612345678);
  });

  test('offline queue survives restart and does not belong to next user',
      () async {
    await balance.selectUser('a');
    await balance.configure(2);
    await settle();
    remote.offline = true;
    await balance.spend(0.5, 0.00001);
    await settle();
    await balance.selectUser('b');
    expect(balance.value.sats, 0);
    final restarted =
        AccountBalance(remote: remote, cache: cache, now: () => now);
    addTearDown(restarted.dispose);
    await restarted.selectUser('a');
    expect(restarted.value.sats, 150000000);
    expect(restarted.hasPendingChanges, isTrue);
    remote.offline = false;
    await restarted.refresh();
    expect(remote.values['a']!.sats, 150000000);
    expect(restarted.hasPendingChanges, isFalse);
  });

  test('lost response and retry cannot subtract the same send twice', () async {
    await balance.selectUser('a');
    await balance.configure(3);
    await settle();
    remote.loseNextReply = true;
    await balance.spend(1, 0.00001);
    await Future<void>.delayed(Duration.zero);
    await balance.refresh();
    expect(remote.values['a']!.sats, 200000000);
    expect(balance.value.sats, 200000000);
  });

  test('late response for A cannot overwrite B', () async {
    remote.delayedUser = 'a';
    remote.delayedRead = Completer<BalanceReply>();
    final pending = balance.selectUser('a');
    await Future<void>.delayed(Duration.zero);
    await balance.selectUser('b');
    await balance.configure(4);
    await settle();
    remote.delayedRead!.complete(BalanceReply(
        true, BalanceSnapshot(sats: 999000000, seededAt: now, epoch: 'old')));
    await pending;
    expect(balance.userId, 'b');
    expect(balance.value.sats, 400000000);
  });

  test('offline stale spend cannot drain a newly configured balance', () async {
    await balance.selectUser('a');
    await balance.configure(2);
    await settle();
    remote.offline = true;
    await balance.spend(2, 0);
    await settle();
    remote.values['a'] = BalanceSnapshot(
        sats: 500000000,
        seededAt: now,
        epoch: 'configuration-from-other-device');
    remote.offline = false;
    await balance.refresh();
    expect(balance.value.sats, 500000000);
  });

  test('not enrolled and unknown offline accounts cannot queue mutations',
      () async {
    await balance.selectUser('outsider');
    expect(balance.eligible, isFalse);
    expect(await balance.configure(9), isFalse);
    remote.offline = true;
    await balance.selectUser('a');
    expect(balance.eligible, isNull);
    expect(await balance.configure(9), isFalse);
  });

  test('failed local persistence does not claim a successful save', () async {
    await balance.selectUser('a');
    cache.fail = true;
    expect(await balance.configure(2), isFalse);
    expect(balance.value.sats, 0);
  });

  test('edit waiting for account A initialization cannot mutate account B',
      () async {
    remote.delayedUser = 'a';
    remote.delayedRead = Completer<BalanceReply>();
    final loading = balance.selectUser('a');
    final save = balance.configure(9);
    await balance.selectUser('b');
    remote.delayedRead!.complete(const BalanceReply(true, BalanceSnapshot()));
    await loading;
    expect(await save, isFalse);
    expect(balance.value.sats, 0);
    expect(remote.values['b'], isNull);
  });

  test('quick A to B to A switch serializes cache writes for the same owner',
      () async {
    await balance.selectUser('a');
    final blocked = Completer<void>();
    cache.blockNextWrite = blocked;
    final save = balance.configure(2);
    await Future<void>.delayed(Duration.zero);
    await balance.selectUser('b');
    final returning = balance.selectUser('a');
    blocked.complete();
    expect(await save, isFalse);
    await returning;
    expect(balance.value.sats, 200000000);
    await settle();
    expect(remote.values['a']!.sats, 200000000);
    expect(remote.values['b'], isNull);
  });

  test('cached PIN entry does not wait for a slow network refresh', () async {
    await balance.selectUser('a');
    await balance.configure(2);
    await settle();
    await balance.selectUser(null);
    remote.delayedUser = 'a';
    remote.delayedRead = Completer<BalanceReply>();
    await balance.selectUser('a').timeout(const Duration(seconds: 1));
    expect(await balance.ensureSeeded().timeout(const Duration(seconds: 1)),
        isTrue);
    expect(balance.value.sats, 200000000);
    remote.delayedRead!.complete(BalanceReply(true, remote.values['a']!));
    await balance.refresh();
  });

  test('legacy app behavior remains available when pilot is not attached',
      () async {
    FlutterSecureStorage.setMockInitialValues({});
    FFAppState.reset();
    final app = FFAppState();
    await app.initializePersistedState();
    await app.configureSimulatedBalance(2);
    await app.spendSimulatedBalance('0.5', 0.00001);
    expect(app.fakeBtcBalance, 1.5);
    await app.spendSimulatedBalance('1.5', 0.00001);
    expect(app.fakeBtcBalance, lessThan(0.00000001));
    await app.ensureSimulatedBalance();
    expect(app.fakeBtcBalance, lessThan(0.00000001));
  });

  test('pilot never imports shared legacy value and UI uses account value',
      () async {
    FlutterSecureStorage.setMockInitialValues({
      'ff_fakeBtcBalance': '99.0',
      'ff_fakeSeeded': 'true',
      'ff_fakeBtcSeededAt': now.toIso8601String(),
    });
    FFAppState.reset();
    final app = FFAppState();
    await app.initializePersistedState();
    app.attachAccountBalance(balance);
    await app.selectBalanceUser('a');
    expect(app.fakeBtcBalance, 0);
    await app.configureSimulatedBalance(2);
    app.currentPriceMultiple = 100000;
    expect(app.fakeBtcBalance, 2);
    expect(app.fakeUsdValue, 200000);
    await app.spendSimulatedBalance('2', 0.00001);
    expect(app.fakeBtcBalance, lessThan(0.00000001));
    expect(app.fakeUsdValue, 0);
    expect(jsonDecode(cache.values['a']!)['pending'], isNotEmpty);
  });
}
