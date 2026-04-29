import 'dart:async';

import 'package:flutter/material.dart';
import 'package:from_css_color/from_css_color.dart';

import '/backend/supabase/supabase.dart';
import 'apple_auth.dart';
import 'email_auth.dart';

export 'base_auth_user_provider.dart';

class SupabaseUserProvider extends BaseAuthUserProvider {
  @override
  String? get currentUserEmail => currentUser?.email;

  @override
  String? get currentUserUid => currentUser?.uid;

  @override
  bool get loggedIn => currentUser?.loggedIn ?? false;

  @override
  bool get emailVerified => currentUser?.emailVerified ?? false;

  @override
  bool get phoneVerified => currentUser?.phoneVerified ?? false;
}

class SupabaseAuthUser extends BaseAuthUser {
  User? user;
  SupabaseAuthUser(this.user);
  @override
  bool get loggedIn => user != null;

  @override
  bool get emailVerified => user?.emailConfirmedAt != null;

  @override
  bool get phoneVerified => user?.phoneConfirmedAt != null;

  @override
  AuthUserInfo get authUserInfo => AuthUserInfo(
        uid: user?.id,
        email: user?.email,
        phoneNumber: user?.phone,
      );

  @override
  Future? delete() => user?.delete();
}

Stream<BaseAuthUser> decoyWalletAppSupabaseUserStream() => SupaFlow
    .client.auth.onAuthStateChange
    .map<BaseAuthUser>((event) => currentUser = SupabaseAuthUser(event.session?.user));

class SupabaseAuthManager extends AuthManager
    with EmailSignInManager, AppleSignInManager {
  @override
  Future signOut() {
    return SupaFlow.client.auth.signOut();
  }

  @override
  Future<BaseAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) =>
      _signInOrCreateAccount(
        context,
        () => emailSignInFunc(email, password),
      );

  @override
  Future<BaseAuthUser?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  ) =>
      _signInOrCreateAccount(
        context,
        () => emailCreateAccountFunc(email, password),
      );

  @override
  Future<BaseAuthUser?> signInWithApple(BuildContext context) =>
      _signInOrCreateAccount(context, appleSignInFunc);

  Future<BaseAuthUser?> _signInOrCreateAccount(
    BuildContext context,
    Future<User?> Function() signInFunc,
  ) async {
    try {
      final user = await signInFunc();
      if (user == null) {
        return null;
      }
      return currentUser = SupabaseAuthUser(user);
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.message}',
            style: TextStyle(color: FlutterFlowTheme.of(context).primaryText),
          ),
          backgroundColor: FlutterFlowTheme.of(context).secondary,
        ),
      );
      return null;
    }
  }
}
