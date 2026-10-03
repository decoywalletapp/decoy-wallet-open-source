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
    remote = MemoryRemote(now: () => now);
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

  test(
      'account load seeds once before PIN entry and reentry does not regenerate',
      () async {
    await balance.selectUser('a');
    final epoch = balance.value.epoch;
    expect(balance.value.sats, 300000000);
    expect(balance.hasInitializedBalance, isTrue);
    expect(remote.values['a']!.sats, 300000000);
    expect(balance.value.configuredSats, isNull);
    expect(remote.applied.length, 1);
    await balance.selectUser(null);
    await balance.selectUser('a');
    await settle();
    await balance.ensureSeeded();
    expect(balance.value.epoch, epoch);
    expect(remote.applied.length, 1);
  });

  test('initial load waits for server and preserves an existing custom zero',
      () async {
    remote.delayedUser = 'a';
    remote.delayedRead = Completer<BalanceReply>();
    final loading = balance.selectUser('a');
    await Future<void>.delayed(Duration.zero);
    expect(balance.hasInitializedBalance, isFalse);
    expect(remote.applied, isEmpty);
    final saved = BalanceSnapshot(
        sats: 0, configuredSats: 0, seededAt: now, epoch: 'manual-zero');
    remote.delayedRead!.complete(BalanceReply(true, saved));
    await loading;
    expect(balance.hasInitializedBalance, isTrue);
    expect(balance.value.toJson(), saved.toJson());
    expect(remote.applied, isEmpty);
  });

  test('initial load preserves custom and partially spent balances', () async {
    final saved = BalanceSnapshot(
        sats: 19500000000,
        configuredSats: 20000000000,
        seededAt: now.subtract(const Duration(days: 90)),
        epoch: 'partial');
    remote.values['a'] = saved;
    await balance.selectUser('a');
    await balance.refresh();
    expect(balance.value.toJson(), saved.toJson());
    expect(remote.applied, isEmpty);
  });

  test('loading and refreshing do not refill an expired drain before PIN entry',
      () async {
    final saved = BalanceSnapshot(
        sats: 0,
        configuredSats: 200000000,
        seededAt: now.subtract(const Duration(days: 5)),
        drainedAt: now.subtract(const Duration(days: 2)),
        epoch: 'drained');
    remote.values['a'] = saved;
    await balance.selectUser('a');
    await balance.refresh();
    expect(balance.value.toJson(), saved.toJson());
    expect(balance.hasInitializedBalance, isTrue);
    expect(remote.applied, isEmpty);
    await balance.ensureSeeded();
    await settle();
    expect(balance.value.sats, 200000000);
  });

  test('an offline first load retries initialization when connectivity returns',
      () async {
    remote.offline = true;
    await balance.selectUser('a');
    expect(balance.hasInitializedBalance, isFalse);
    expect(remote.applied, isEmpty);
    expect(cache.values, isEmpty);
    remote.offline = false;
    await balance.refresh();
    expect(balance.value.sats, 300000000);
    expect(balance.hasInitializedBalance, isTrue);
    expect(remote.applied.length, 1);
  });

  test('simultaneous first loads converge on one server balance', () async {
    remote.delayedUser = 'a';
    remote.delayedRead = Completer<BalanceReply>();
    final phone = AccountBalance(
        remote: remote,
        cache: MemoryCache(),
        now: () => now,
        randomSats: () => 500000000);
    addTearDown(phone.dispose);
    final first = balance.selectUser('a');
    final second = phone.selectUser('a');
    await Future<void>.delayed(Duration.zero);
    remote.delayedRead!.complete(const BalanceReply(true, BalanceSnapshot()));
    await Future.wait([first, second]);
    expect(balance.value.sats, phone.value.sats);
    expect(balance.value.epoch, phone.value.epoch);
    expect(balance.value.sats, remote.values['a']!.sats);
    expect(balance.hasPendingChanges, isFalse);
    expect(phone.hasPendingChanges, isFalse);
  });

  test(
      'lost initial seed reply is durable and does not generate another amount',
      () async {
    remote.loseNextReply = true;
    await balance.selectUser('a');
    final epoch = remote.values['a']!.epoch;
    expect(balance.hasPendingChanges, isTrue);
    final restarted = AccountBalance(
        remote: remote,
        cache: cache,
        now: () => now,
        randomSats: () => 500000000);
    addTearDown(restarted.dispose);
    await restarted.selectUser('a');
    await restarted.refresh();
    expect(restarted.value.sats, 300000000);
    expect(restarted.value.epoch, epoch);
    expect(restarted.hasPendingChanges, isFalse);
    expect(remote.applied.length, 1);
  });

  test('failed seed persistence cannot write a remote default', () async {
    cache.fail = true;
    await balance.selectUser('a');
    expect(balance.hasInitializedBalance, isFalse);
    expect(remote.applied, isEmpty);
    cache.fail = false;
    await balance.refresh();
    expect(balance.hasInitializedBalance, isTrue);
    expect(remote.applied.length, 1);
  });

  test('cached empty account waits for a successful read before early seeding',
      () async {
    cache.values['a'] = jsonEncode({
      'eligible': true,
      'base': const BalanceSnapshot().toJson(),
      'pending': [],
    });
    remote.offline = true;
    await balance.selectUser('a');
    await balance.refresh();
    expect(balance.hasInitializedBalance, isFalse);
    expect(balance.hasPendingChanges, isFalse);
    remote.offline = false;
    await balance.refresh();
    expect(balance.value.sats, 300000000);
    expect(remote.applied.length, 1);
  });

  test('an in-flight empty read cannot seed over a queued manual zero',
      () async {
    cache.values['a'] = jsonEncode({
      'eligible': true,
      'base': const BalanceSnapshot().toJson(),
      'pending': [],
    });
    remote.delayedUser = 'a';
    remote.delayedRead = Completer<BalanceReply>();
    await balance.selectUser('a');
    await balance.configure(0);
    remote.delayedUser = null;
    remote.delayedRead!.complete(const BalanceReply(true, BalanceSnapshot()));
    await balance.refresh();
    expect(balance.value.sats, 0);
    expect(balance.value.configuredSats, 0);
    expect(remote.values['a']!.configuredSats, 0);
    expect(remote.applied.length, 1);
  });

  test('200 BTC minus 5 stays 195 indefinitely and retains the custom target',
      () async {
    await balance.selectUser('a');
    await balance.configure(200);
    await settle();
    now = now.add(const Duration(days: 30));
    await balance.ensureSeeded();
    expect(balance.value.sats, 20000000000);
    await balance.spend(5, 0.00001);
    await settle();
    now = now.add(const Duration(days: 30));
    await balance.ensureSeeded();
    await settle();
    expect(balance.value.sats, 19500000000);
    expect(balance.value.configuredSats, 20000000000);
    expect(balance.value.drainedAt, isNull);
  });

  test('custom refill waits 24 hours from drain, not from configuration',
      () async {
    await balance.selectUser('a');
    await balance.configure(200);
    await settle();
    now = now.add(const Duration(days: 30));
    await balance.spend(200, 0.00001);
    await settle();
    final drainedAt = now;
    expect(balance.value.drainedAt, drainedAt);
    now = now.add(const Duration(hours: 24) - const Duration(microseconds: 1));
    await balance.ensureSeeded();
    expect(balance.value.sats, 0);
    now = drainedAt.add(const Duration(hours: 24));
    await balance.ensureSeeded();
    await settle();
    expect(balance.value.sats, 20000000000);
    expect(balance.value.configuredSats, 20000000000);
    expect(balance.value.drainedAt, isNull);
    now = now.add(const Duration(days: 30));
    await balance.ensureSeeded();
    expect(balance.value.sats, 20000000000);
  });

  test('default balances persist partially spent and use random refill',
      () async {
    var nextRandom = 400000000;
    final randomBalance = AccountBalance(
        remote: remote,
        cache: cache,
        now: () => now,
        randomSats: () => nextRandom);
    addTearDown(randomBalance.dispose);
    await randomBalance.selectUser('a');
    await randomBalance.ensureSeeded();
    await randomBalance.refresh();
    await randomBalance.spend(1, 0);
    await randomBalance.refresh();
    now = now.add(const Duration(days: 30));
    await randomBalance.ensureSeeded();
    expect(randomBalance.value.sats, 300000000);
    expect(randomBalance.value.configuredSats, isNull);
    await randomBalance.spend(3, 0);
    await randomBalance.refresh();
    now = now.add(const Duration(hours: 24));
    nextRandom = 250000000;
    await randomBalance.ensureSeeded();
    await randomBalance.refresh();
    expect(randomBalance.value.sats, 250000000);
    expect(randomBalance.value.configuredSats, isNull);
  });

  test('duplicate and additional sends at zero do not extend the cooldown',
      () async {
    await balance.selectUser('a');
    await balance.configure(2);
    await settle();
    await balance.spend(2, 0);
    await settle();
    final drainedAt = balance.value.drainedAt;
    now = now.add(const Duration(hours: 12));
    await balance.spend(1, 0);
    await settle();
    expect(balance.value.drainedAt, drainedAt);
    await balance.ensureSeeded();
    expect(balance.value.sats, 0);
    now = drainedAt!.add(const Duration(hours: 24));
    await balance.ensureSeeded();
    await settle();
    expect(balance.value.sats, 200000000);
    now = now.add(const Duration(hours: 2));
    await balance.spend(2, 0);
    await settle();
    expect(balance.value.drainedAt, now);
    expect(balance.value.drainedAt, isNot(drainedAt));
  });

  test('manual zero is retained indefinitely, even after attempted spending',
      () async {
    await balance.selectUser('a');
    await balance.configure(0);
    await settle();
    now = now.add(const Duration(days: 90));
    await balance.spend(1, 0);
    await balance.ensureSeeded();
    await settle();
    expect(balance.value.sats, 0);
    expect(balance.value.configuredSats, 0);
    expect(balance.value.drainedAt, isNull);
    expect(balance.value.needsSeed(now), isFalse);
  });

  test('reconfiguration cancels a drain and replaces the refill target',
      () async {
    await balance.selectUser('a');
    await balance.configure(200);
    await settle();
    await balance.spend(200, 0);
    await settle();
    await balance.configure(7);
    await settle();
    now = now.add(const Duration(days: 7));
    await balance.ensureSeeded();
    expect(balance.value.sats, 700000000);
    expect(balance.value.configuredSats, 700000000);
    expect(balance.value.drainedAt, isNull);
    await balance.spend(7, 0);
    await settle();
    await balance.configure(0);
    await settle();
    now = now.add(const Duration(days: 7));
    await balance.ensureSeeded();
    expect(balance.value.sats, 0);
    expect(balance.value.drainedAt, isNull);
  });

  test('fee-sized remainder counts as drained but zero sends do not', () async {
    await balance.selectUser('a');
    await balance.configure(0.00002002);
    await settle();
    await balance.spend(0, 0.001);
    await settle();
    expect(balance.value.sats, 2002);
    expect(balance.value.drainedAt, isNull);
    await balance.spend(0.00001, 0.00001);
    await settle();
    expect(balance.value.sats, 1002);
    expect(balance.value.drainedAt, isNull);
    await balance.spend(0.00000001, 0.00001);
    await settle();
    expect(balance.value.sats, 0);
    expect(balance.value.drainedAt, now);
    expect(balance.value.configuredSats, 2002);
  });

  test('older cache keeps its remaining balance and never guesses a drain', () {
    for (final sats in [0, 75000000]) {
      final snapshot = BalanceSnapshot.fromJson({
        'sats': sats,
        'seeded_at': now.toIso8601String(),
        'epoch': 'old',
      });
      expect(snapshot.sats, sats);
      expect(snapshot.configuredSats, sats);
      expect(snapshot.drainedAt, isNull);
      expect(snapshot.needsSeed(now.add(const Duration(days: 90))), isFalse);
    }
    expect(BalanceSnapshot.fromJson({'sats': 0}).needsSeed(now), isTrue);
  });

  test('confirmed drain and target survive offline restart and refill once',
      () async {
    await balance.selectUser('a');
    await balance.configure(200);
    await settle();
    await balance.spend(200, 0);
    await settle();
    final drainedAt = now;
    remote.offline = true;
    now = now.add(const Duration(hours: 24));
    final restarted =
        AccountBalance(remote: remote, cache: cache, now: () => now);
    addTearDown(restarted.dispose);
    await restarted.selectUser('a');
    expect(restarted.value.drainedAt, drainedAt);
    expect(restarted.value.configuredSats, 20000000000);
    await restarted.ensureSeeded();
    expect(restarted.value.sats, 20000000000);
    await restarted.spend(5, 0);
    expect(restarted.value.sats, 19500000000);
    remote.offline = false;
    await restarted.refresh();
    expect(remote.values['a']!.sats, 19500000000);
    expect(remote.values['a']!.configuredSats, 20000000000);
    expect(restarted.hasPendingChanges, isFalse);
  });

  test('offline drain waits for server acknowledgement before refill',
      () async {
    await balance.selectUser('a');
    await balance.configure(2);
    await settle();
    remote.offline = true;
    await balance.spend(2, 0);
    await settle();
    now = now.add(const Duration(hours: 25));
    await balance.ensureSeeded();
    expect(balance.value.sats, 0);
    remote.offline = false;
    await settle();
    expect(balance.value.drainedAt, now);
    await balance.ensureSeeded();
    expect(balance.value.sats, 0);
    now = now.add(const Duration(hours: 24));
    await balance.ensureSeeded();
    await settle();
    expect(balance.value.sats, 200000000);
  });

  test('another device receives the custom target and the same drain clock',
      () async {
    await balance.selectUser('a');
    await balance.configure(200);
    await settle();
    await balance.spend(200, 0);
    await settle();
    final phone =
        AccountBalance(remote: remote, cache: MemoryCache(), now: () => now);
    addTearDown(phone.dispose);
    await phone.selectUser('a');
    expect(phone.value.sats, 0);
    expect(phone.value.configuredSats, 20000000000);
    expect(phone.value.drainedAt, now);
    now = now.add(const Duration(hours: 24));
    await phone.ensureSeeded();
    await phone.refresh();
    await balance.refresh();
    expect(balance.value.sats, 20000000000);
    expect(balance.value.epoch, phone.value.epoch);
    expect(balance.value.drainedAt, isNull);
  });

  test('two offline refills of one cycle retain both phones subsequent sends',
      () async {
    await balance.selectUser('a');
    await balance.configure(200);
    await settle();
    await balance.spend(200, 0);
    await settle();
    final phone =
        AccountBalance(remote: remote, cache: MemoryCache(), now: () => now);
    addTearDown(phone.dispose);
    await phone.selectUser('a');
    remote.offline = true;
    now = now.add(const Duration(hours: 24));
    await balance.ensureSeeded();
    await phone.ensureSeeded();
    await balance.spend(5, 0);
    await phone.spend(7, 0);
    await settle();
    await phone.refresh();
    remote.offline = false;
    await balance.refresh();
    await phone.refresh();
    await balance.refresh();
    expect(balance.value.sats, 18800000000);
    expect(phone.value.sats, 18800000000);
    expect(balance.value.configuredSats, 20000000000);
    expect(balance.hasPendingChanges, isFalse);
    expect(phone.hasPendingChanges, isFalse);
  });

  test('a manual configuration is never mistaken for a competing refill',
      () async {
    await balance.selectUser('a');
    await balance.configure(200);
    await settle();
    await balance.spend(200, 0);
    await settle();
    final phone =
        AccountBalance(remote: remote, cache: MemoryCache(), now: () => now);
    addTearDown(phone.dispose);
    await phone.selectUser('a');
    remote.offline = true;
    now = now.add(const Duration(hours: 24));
    await balance.ensureSeeded();
    await balance.spend(5, 0);
    await settle();
    remote.offline = false;
    await phone.configure(200);
    await phone.refresh();
    await balance.refresh();
    expect(balance.value.sats, 20000000000);
    expect(balance.value.epoch, phone.value.epoch);
  });

  test('two initial offline seeds rebase sends without refilling twice',
      () async {
    final emptyCache = jsonEncode({
      'eligible': true,
      'base': const BalanceSnapshot().toJson(),
      'pending': [],
    });
    cache.values['a'] = emptyCache;
    final phoneCache = MemoryCache()..values['a'] = emptyCache;
    remote.offline = true;
    await balance.selectUser('a');
    final phone = AccountBalance(
        remote: remote,
        cache: phoneCache,
        now: () => now,
        randomSats: () => 500000000);
    addTearDown(phone.dispose);
    await phone.selectUser('a');
    remote.offline = true;
    await balance.ensureSeeded();
    await phone.ensureSeeded();
    await balance.spend(1, 0);
    await phone.spend(1, 0);
    await settle();
    await phone.refresh();
    remote.offline = false;
    await balance.refresh();
    await phone.refresh();
    await balance.refresh();
    expect(balance.value.sats, 100000000);
    expect(phone.value.sats, 100000000);
    expect(balance.value.configuredSats, isNull);
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
    expect(balance.hasInitializedBalance, isFalse);
    expect(remote.applied, isEmpty);
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
    expect(balance.value.sats, 300000000);
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
    expect(balance.value.sats, 300000000);
    expect(remote.values['b']!.configuredSats, isNull);
    expect(remote.values['a'], isNull);
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
    expect(remote.values['b']!.sats, 300000000);
    expect(remote.values['b']!.configuredSats, isNull);
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
    expect(app.fakeBtcBalance, 3);
    expect(app.isSimulatedBalanceReady, isTrue);
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
