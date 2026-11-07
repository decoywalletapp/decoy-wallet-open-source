/// In-memory hand-off for the freshly generated decoy mnemonic.
///
/// The mnemonic must never travel through router query/path parameters or
/// `extra`: on web those become part of the URL and browser history, and a
/// custom-scheme deep link could otherwise inject attacker-chosen words.
/// Instead the generating screen stores it here and the show/verify routes
/// read it back for the matching decoy id.
///
/// This class never persists or logs the mnemonic. The reference is dropped
/// when verification succeeds, when generation is re-entered, when the
/// signed-in user changes (including sign-out) and when the duress PIN opens
/// decoy mode. Locking the app keeps it, so unlocking returns to the seed
/// screen. Dart strings are immutable, so [clear] cannot overwrite the words;
/// they stay in process memory until garbage-collected.
class SeedHandoff {
  SeedHandoff._();

  static String? _mnemonic;
  static String? _decoyId;

  /// Stores [mnemonic] for the decoy identified by [decoyId].
  static void put({required String? mnemonic, required String? decoyId}) {
    _mnemonic = mnemonic;
    _decoyId = decoyId;
  }

  /// Returns the mnemonic only when it belongs to [decoyId].
  static String? mnemonicFor(String? decoyId) {
    if (_mnemonic == null || decoyId == null || decoyId != _decoyId) {
      return null;
    }
    return _mnemonic;
  }

  static bool get hasPending => _mnemonic != null;

  static void clear() {
    _mnemonic = null;
    _decoyId = null;
  }
}
