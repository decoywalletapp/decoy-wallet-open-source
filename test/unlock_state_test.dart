import 'package:decoy_wallet_app/auth/app_unlock_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppUnlockState state;
  setUp(() {
    state = AppUnlockState()..bindUser('test-owner');
  });
  tearDown(() => state.dispose());

  test('retained authentication supplies no local owner proof', () {
    expect(state.ownerUnlocked, isFalse);
    expect(state.allows(AppRouteAccess.owner), isFalse);
    expect(state.allows(AppRouteAccess.pin), isFalse);
    expect(state.unlockOwner(state.attempt), isFalse);
  });

  for (final paid in [true, false]) {
    test('normal PIN unlock is independent of paid access: $paid', () {
      final attempt = state.attempt;
      expect(state.preparePin(attempt, paidDecoyAllowed: paid), isTrue);
      expect(state.unlockOwner(attempt), isTrue);
      expect(state.allows(AppRouteAccess.owner), isTrue);
      expect(state.allows(AppRouteAccess.firstPin), isFalse);
      expect(state.allows(AppRouteAccess.decoy), isFalse);
    });
  }

  test('unpaid decoy PIN does not unlock or authorize an alert transition', () {
    final attempt = state.attempt;
    state.preparePin(attempt, paidDecoyAllowed: false);
    expect(state.beginDecoy(attempt), isFalse);
    expect(state.ownerUnlocked, isFalse);
    expect(state.pinReady, isTrue);
  });

  test(
      'paid decoy transition keeps the PIN flow mounted but denies owner screens',
      () {
    final attempt = state.attempt;
    state.preparePin(attempt, paidDecoyAllowed: true);
    expect(state.beginDecoy(attempt), isTrue);
    expect(state.allows(AppRouteAccess.pin), isTrue);
    expect(state.allows(AppRouteAccess.entry), isFalse);
    expect(state.unlockOwner(attempt), isFalse);
    expect(state.allowRecovery(attempt), isFalse);
    expect(state.finishDecoy(attempt), isTrue);
    for (final access in AppRouteAccess.values) {
      expect(state.allows(access), access == AppRouteAccess.decoy);
    }
  });

  test('same-user refresh retains owner proof; account change revokes it', () {
    state.preparePin(state.attempt, paidDecoyAllowed: true);
    state.unlockOwner(state.attempt);
    state.bindUser('test-owner');
    expect(state.ownerUnlocked, isTrue);
    state.bindUser('another-owner');
    expect(state.ownerUnlocked, isFalse);
  });

  test('late PIN result cannot survive logout and same-user sign-in', () {
    final attempt = state.attempt;
    state.preparePin(attempt, paidDecoyAllowed: true);
    state.bindUser(null);
    state.bindUser('test-owner');
    state.preparePin(state.attempt, paidDecoyAllowed: true);
    expect(state.unlockOwner(attempt), isFalse);
    expect(state.beginDecoy(attempt), isFalse);
  });

  test('explicit lock invalidates in-flight results even for same account', () {
    final attempt = state.attempt;
    state.preparePin(attempt, paidDecoyAllowed: true);
    state.lock();
    expect(state.preparePin(attempt, paidDecoyAllowed: true), isFalse);
    expect(state.unlockOwner(attempt), isFalse);
  });

  for (final complete in <bool?>[true, false, null]) {
    for (final hasPin in [true, false]) {
      test('first PIN is limited to confirmed new setup: $complete/$hasPin',
          () {
        final allowed = complete == false && !hasPin;
        expect(
            state.allowSetup(state.attempt,
                setupComplete: complete, hasAccountPin: hasPin),
            allowed);
        expect(state.allows(AppRouteAccess.firstPin), allowed);
        expect(state.allows(AppRouteAccess.owner), isFalse);
        expect(state.unlockOwner(state.attempt, firstPin: true), allowed);
      });
    }
  }

  test('recovery never implies owner access and must finish before PIN', () {
    final attempt = state.attempt;
    state.preparePin(attempt, paidDecoyAllowed: true);
    expect(state.allowRecovery(attempt), isTrue);
    expect(state.ownerUnlocked, isFalse);
    expect(state.recoveryAllowed, isTrue);
    expect(state.preparePin(state.attempt, paidDecoyAllowed: true), isFalse);
    expect(
        state.allowSetup(state.attempt,
            setupComplete: false, hasAccountPin: false),
        isFalse);
    state.lock();
    expect(state.recoveryAllowed, isFalse);
  });

  test('failed decoy preparation preserves retry without granting owner access',
      () async {
    var attempts = 0;
    var alerts = 0;
    final first = state.attempt!;
    state.preparePin(first, paidDecoyAllowed: true);
    state.beginDecoy(first);
    await expectLater(
        state.runDecoyPreparation(first, () async {
          attempts++;
          throw StateError('synthetic temporary connection failure');
        }),
        throwsStateError);
    expect(state.pinReady, isTrue);
    expect(state.ownerUnlocked, isFalse);
    expect(state.isCurrent(first), isFalse);
    final retry = state.attempt!;
    expect(state.beginDecoy(retry), isTrue);
    await state.runDecoyPreparation(retry, () async {
      attempts++;
      alerts++;
      state.finishDecoy(retry);
    });
    expect(attempts, 2);
    expect(alerts, 1);
    expect(state.mode, AppUnlockMode.decoy);
    expect(state.ownerUnlocked, isFalse);
  });

  test('late decoy failure cannot restore PIN permission after account change',
      () async {
    final first = state.attempt!;
    state.preparePin(first, paidDecoyAllowed: true);
    state.beginDecoy(first);
    await expectLater(
        state.runDecoyPreparation(first, () async {
          state.bindUser('another-account');
          throw StateError('synthetic failure');
        }),
        throwsStateError);
    expect(state.pinReady, isFalse);
    expect(state.ownerUnlocked, isFalse);
  });
}
