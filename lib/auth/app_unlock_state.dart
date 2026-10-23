import 'package:flutter/foundation.dart';

enum AppUnlockMode { locked, owner, enteringDecoy, decoy }

enum AppRouteAccess {
  entry,
  owner,
  setup,
  firstPin,
  pin,
  recovery,
  decoy,
  legal
}

class UnlockAttempt {
  const UnlockAttempt._(this.userId, this.generation);
  final String userId;
  final int generation;
}

/// Local unlock proof is deliberately not persisted with the backend session.
class AppUnlockState extends ChangeNotifier {
  String? _userId;
  int _generation = 0;
  AppUnlockMode _mode = AppUnlockMode.locked;
  bool _setupAllowed = false;
  bool _pinReady = false;
  bool _decoyAllowed = false;
  bool _recoveryAllowed = false;

  AppUnlockMode get mode => _mode;
  bool get ownerUnlocked => _userId != null && _mode == AppUnlockMode.owner;
  bool get inDecoy =>
      _mode == AppUnlockMode.decoy || _mode == AppUnlockMode.enteringDecoy;
  bool get setupAllowed => _userId != null && _setupAllowed && !inDecoy;
  bool get pinReady => _pinReady && !inDecoy;
  bool get recoveryAllowed => _recoveryAllowed && !inDecoy;
  UnlockAttempt? get attempt =>
      _userId == null ? null : UnlockAttempt._(_userId!, _generation);

  void bindUser(String? userId) {
    final next = userId == null || userId.isEmpty ? null : userId;
    if (_userId == next) return;
    _userId = next;
    lock();
  }

  void lock() {
    _generation++;
    _mode = AppUnlockMode.locked;
    _setupAllowed = false;
    _pinReady = false;
    _decoyAllowed = false;
    _recoveryAllowed = false;
    notifyListeners();
  }

  bool isCurrent(UnlockAttempt? value) =>
      value != null &&
      value.userId == _userId &&
      value.generation == _generation;

  bool allowSetup(
    UnlockAttempt? value, {
    required bool? setupComplete,
    required bool hasAccountPin,
  }) {
    if (!isCurrent(value) || inDecoy || recoveryAllowed) return false;
    _setupAllowed = setupComplete == false && !hasAccountPin;
    notifyListeners();
    return _setupAllowed;
  }

  bool preparePin(UnlockAttempt? value, {required bool paidDecoyAllowed}) {
    if (!isCurrent(value) || inDecoy || recoveryAllowed) return false;
    _pinReady = true;
    _decoyAllowed = paidDecoyAllowed;
    notifyListeners();
    return true;
  }

  bool unlockOwner(UnlockAttempt? value, {bool firstPin = false}) {
    if (!isCurrent(value) ||
        inDecoy ||
        recoveryAllowed ||
        (firstPin ? !_setupAllowed : !_pinReady)) return false;
    _mode = AppUnlockMode.owner;
    _setupAllowed = false;
    _pinReady = false;
    _generation++;
    notifyListeners();
    return true;
  }

  bool beginDecoy(UnlockAttempt? value) {
    if (!isCurrent(value) || !_pinReady || !_decoyAllowed || inDecoy) {
      return false;
    }
    _mode = AppUnlockMode.enteringDecoy;
    _setupAllowed = false;
    _pinReady = false;
    notifyListeners();
    return true;
  }

  bool finishDecoy(UnlockAttempt? value) {
    if (!isCurrent(value) || _mode != AppUnlockMode.enteringDecoy) return false;
    _mode = AppUnlockMode.decoy;
    _generation++;
    notifyListeners();
    return true;
  }

  Future<void> runDecoyPreparation(
      UnlockAttempt value, Future<void> Function() prepare) async {
    if (!isCurrent(value) || _mode != AppUnlockMode.enteringDecoy) return;
    try {
      await prepare();
    } catch (_) {
      if (isCurrent(value) && _mode == AppUnlockMode.enteringDecoy) {
        _mode = AppUnlockMode.locked;
        _pinReady = true;
        _generation++;
        notifyListeners();
      }
      rethrow;
    }
  }

  bool allowRecovery(UnlockAttempt? value) {
    if (!isCurrent(value) || inDecoy) return false;
    lock();
    _recoveryAllowed = true;
    notifyListeners();
    return true;
  }

  bool allows(AppRouteAccess access) {
    if (inDecoy) {
      return _mode == AppUnlockMode.enteringDecoy
          ? access == AppRouteAccess.pin
          : access == AppRouteAccess.decoy;
    }
    if (recoveryAllowed) {
      return access == AppRouteAccess.recovery ||
          access == AppRouteAccess.legal;
    }
    switch (access) {
      case AppRouteAccess.entry:
      case AppRouteAccess.legal:
        return true;
      case AppRouteAccess.owner:
        return ownerUnlocked;
      case AppRouteAccess.setup:
        return ownerUnlocked || setupAllowed;
      case AppRouteAccess.firstPin:
        return setupAllowed;
      case AppRouteAccess.pin:
        return pinReady;
      case AppRouteAccess.recovery:
        return ownerUnlocked || recoveryAllowed;
      case AppRouteAccess.decoy:
        return false;
    }
  }

  String get safeLocation {
    if (_mode == AppUnlockMode.enteringDecoy) return '/PINPage';
    if (_mode == AppUnlockMode.decoy) return '/duressHomePage';
    if (_userId == null) return '/loginPage';
    if (recoveryAllowed) return '/updatePasswordPage';
    if (ownerUnlocked) return '/homePage';
    if (pinReady) return '/PINPage';
    return '/authRouter';
  }
}
