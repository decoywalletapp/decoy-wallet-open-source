import 'package:rxdart/rxdart.dart';
import 'package:flutter/foundation.dart';

import '/backend/public_config.dart';
import '/backend/supabase/supabase.dart';
import '../base_auth_user_provider.dart';

export '../base_auth_user_provider.dart';

class DecoyWalletAppSupabaseUser extends BaseAuthUser {
  DecoyWalletAppSupabaseUser(this.user);
  User? user;
  bool get loggedIn => user != null;

  @override
  AuthUserInfo get authUserInfo => AuthUserInfo(
        uid: user?.id,
        email: user?.email,
        phoneNumber: user?.phone,
      );

  @override
  Future? delete() =>
      throw UnsupportedError('The delete user operation is not yet supported.');

  @override
  Future<bool>? updateEmail(String email) async {
    final redirectTo = requiredPublicConfig(
      'DECOY_EMAIL_CONFIRM_URL',
      kEmailConfirmUrl,
    );
    final response = await SupaFlow.client.auth.updateUser(
      UserAttributes(email: email),
      emailRedirectTo: redirectTo,
    );
    if (response.user != null) {
      user = response.user;
    }
    if (kDebugMode) {
      debugPrint(
        '[DecoyEmailChange] updateUser accepted=${response.user != null} '
        'pendingNewEmail=${response.user?.newEmail?.isNotEmpty == true} '
        'emailChangeSentAt=${response.user?.emailChangeSentAt?.isNotEmpty == true}',
      );
    }
    if (response.user?.newEmail?.isNotEmpty == true) {
      try {
        await SupaFlow.client.auth.resend(
          email: email,
          type: OtpType.emailChange,
          emailRedirectTo: redirectTo,
        );
        if (kDebugMode) {
          debugPrint('[DecoyEmailChange] resend email_change accepted');
        }
      } on AuthException catch (e) {
        if (kDebugMode) {
          debugPrint('[DecoyEmailChange] resend email_change skipped: '
              '${e.message}');
        }
      }
    }
    return response.user != null;
  }

  @override
  Future? updatePassword(String newPassword) async {
    final response = await SupaFlow.client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    if (response.user != null) {
      user = response.user;
    }
  }

  @override
  Future? sendEmailVerification() => throw UnsupportedError(
      'The send email verification operation is not yet supported.');

  @override
  bool get emailVerified {
    // Reloads the user when checking in order to get the most up to date
    // email verified status.
    if (loggedIn && user!.emailConfirmedAt == null) {
      refreshUser();
    }
    return user?.emailConfirmedAt != null;
  }

  @override
  Future refreshUser() async {
    await SupaFlow.client.auth
        .refreshSession()
        .then((_) => user = SupaFlow.client.auth.currentUser);
  }
}

/// Generates a stream of the authenticated user.
/// [SupaFlow.client.auth.onAuthStateChange] does not yield any values until the
/// user is already authenticated. So we add a default null user to the stream,
/// if we need to interact with the [currentUser] before logging in.
Stream<BaseAuthUser> decoyWalletAppSupabaseUserStream() {
  final supabaseAuthStream = SupaFlow.client.auth.onAuthStateChange.debounce(
      (authState) => authState.event == AuthChangeEvent.tokenRefreshed
          ? TimerStream(authState, Duration(seconds: 1))
          : Stream.value(authState));
  return (!loggedIn
          ? Stream<AuthState?>.value(null).concatWith([supabaseAuthStream])
          : supabaseAuthStream)
      .map<BaseAuthUser>(
    (authState) {
      currentUser = DecoyWalletAppSupabaseUser(authState?.session?.user);
      return currentUser!;
    },
  );
}
