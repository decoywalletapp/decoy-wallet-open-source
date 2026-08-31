import '/backend/supabase/supabase.dart';
import 'supabase_auth_manager.dart';

export 'supabase_auth_manager.dart';

final _authManager = SupabaseAuthManager();
SupabaseAuthManager get authManager => _authManager;

String get currentUserEmail => currentUser?.email ?? '';

String get currentUserUid => currentUser?.uid ?? '';

String get currentUserDisplayName => currentUser?.displayName ?? '';

String get currentUserPhoto => currentUser?.photoUrl ?? '';

String get currentPhoneNumber => currentUser?.phoneNumber ?? '';

String get currentJwtToken =>
    SupaFlow.client.auth.currentSession?.accessToken ?? _currentJwtToken ?? '';

String get activeJwtToken =>
    SupaFlow.client.auth.currentSession?.accessToken ?? currentJwtToken;

String get activeUserUid =>
    SupaFlow.client.auth.currentUser?.id ?? currentUserUid;

String get activeUserEmail =>
    SupaFlow.client.auth.currentUser?.email ?? currentUserEmail;

bool get currentUserEmailVerified => currentUser?.emailVerified ?? false;

Future<bool> waitForActiveSupabaseSession({
  Duration timeout = const Duration(seconds: 6),
  Duration retryDelay = const Duration(milliseconds: 250),
}) async {
  final deadline = DateTime.now().add(timeout);

  while (true) {
    final session = SupaFlow.client.auth.currentSession;
    if (session?.accessToken.trim().isNotEmpty == true &&
        (SupaFlow.client.auth.currentUser?.id ?? currentUserUid)
            .trim()
            .isNotEmpty) {
      return true;
    }

    if (session != null) {
      try {
        await SupaFlow.client.auth.refreshSession();
      } catch (_) {
        // The caller will handle the session still being unavailable.
      }
    }

    if (DateTime.now().isAfter(deadline)) {
      return activeJwtToken.trim().isNotEmpty &&
          activeUserUid.trim().isNotEmpty;
    }

    await Future.delayed(retryDelay);
  }
}

/// Create a Stream that listens to the current user's JWT Token.
String? _currentJwtToken;
final jwtTokenStream = SupaFlow.client.auth.onAuthStateChange
    .map(
      (authState) => _currentJwtToken = authState.session?.accessToken,
    )
    .asBroadcastStream();
