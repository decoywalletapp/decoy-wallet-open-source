import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Toggles OS-level capture protection while a seed phrase is on screen.
///
/// Android: sets/clears WindowManager.LayoutParams.FLAG_SECURE (blocks
/// screenshots, screen recording and the recents thumbnail).
/// iOS: shows a privacy overlay when the app resigns active (app switcher
/// snapshot) and while the screen is being captured/mirrored. iOS does not
/// allow apps to block screenshots, and this code does not detect them
/// either: a screenshot of a seed screen on iOS captures the words.
///
/// Uses reference counting so nested seed screens do not clear protection
/// early. Failures are swallowed: protection is best effort and must never
/// crash the seed flow.
class SecureScreen {
  SecureScreen._();

  @visibleForTesting
  static const MethodChannel channel =
      MethodChannel('decoy_wallet/secure_screen');

  static int _depth = 0;

  @visibleForTesting
  static int get depth => _depth;

  static Future<void> enable() async {
    _depth++;
    if (_depth == 1) await _invoke('enable');
  }

  static Future<void> disable() async {
    if (_depth == 0) return;
    _depth--;
    if (_depth == 0) await _invoke('disable');
  }

  static Future<void> _invoke(String method) async {
    if (kIsWeb) return;
    try {
      await channel.invokeMethod<void>(method);
    } on MissingPluginException {
      // Platform without an implementation (tests, desktop).
    } on PlatformException {
      // Best effort.
    }
  }
}
