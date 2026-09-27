import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language is a device preference, independent of accounts and alert settings.
class AppLanguageController extends ChangeNotifier {
  static const preferenceKey = 'app_language';
  static const supportedLanguageCodes = {'en', 'es'};

  String? _languageCode;
  SharedPreferences? _preferences;
  Future<void> _pendingWrite = Future.value();

  Locale? get locale => _languageCode == null ? null : Locale(_languageCode!);
  String? get languageCode => _languageCode;

  Future<void> initialize() async {
    try {
      _preferences = await SharedPreferences.getInstance();
      final saved = _preferences!.getString(preferenceKey);
      _languageCode = supportedLanguageCodes.contains(saved) ? saved : null;
    } catch (_) {
      // A preference read must never prevent access to the app.
      _languageCode = null;
    }
  }

  Future<bool> setLanguage(String? languageCode) async {
    if (languageCode != null &&
        !supportedLanguageCodes.contains(languageCode)) {
      return false;
    }
    _languageCode = languageCode;
    notifyListeners();
    var saved = false;
    // Keep quick consecutive selections in order on disk.
    _pendingWrite = _pendingWrite.then((_) async {
      try {
        final preferences =
            _preferences ??= await SharedPreferences.getInstance();
        saved = languageCode == null
            ? await preferences.remove(preferenceKey)
            : await preferences.setString(preferenceKey, languageCode);
      } catch (_) {
        saved = false;
      }
    });
    await _pendingWrite;
    return saved;
  }
}
