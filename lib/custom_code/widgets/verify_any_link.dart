// ignore_for_file: unnecessary_import, unused_import

// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/supabase/supabase.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import '/index.dart';
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '/auth/supabase_auth/auth_util.dart';
import '/auth/supabase_auth/supabase_user_provider.dart';

class VerifyAnyLink extends StatefulWidget {
  final double? width;
  final double? height;
  final void Function(bool hasAuthPayload)? onInitialLinkChecked;
  const VerifyAnyLink({Key? key, this.width, this.height,
    this.onInitialLinkChecked}) : super(key: key);

  static Map<String, String> authParameters(Uri uri) {
    final params = <String, String>{...uri.queryParameters};
    try {
      final fragment = uri.fragment.startsWith('?')
          ? uri.fragment.substring(1) : uri.fragment;
      params.addAll(Uri.splitQueryString(fragment));
    } on FormatException {
      // Non-query fragments are not authentication evidence.
    }
    return params;
  }

  static bool hasAuthPayload(Uri uri) {
    final params = authParameters(uri);
    return const ['token_hash', 'tokenHash', 'token', 'refresh_token',
      'refreshToken', 'access_token', 'accessToken']
        .any((key) => params[key]?.isNotEmpty ?? false);
  }

  @override
  State<VerifyAnyLink> createState() => _VerifyAnyLinkState();
}

class _VerifyAnyLinkState extends State<VerifyAnyLink> {
  AppLinks? _appLinks;
  StreamSubscription<Uri>? _sub;
  bool _navigated = false;
  int _authLinksPending = 0;
  static final Set<String> _linksInFlight = <String>{};
  static final Set<String> _linksCompleted = <String>{};

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _appLinks = AppLinks();
    _sub = _appLinks!.uriLinkStream.listen(
      (uri) => _handleUri(uri),
      onError: (e) {
        if (kDebugMode) _debugLog('[VerifyAnyLink] stream error: $e');
      },
    );

    // Cold start
    var hasAuthPayload = false;
    try {
      final initial = await (authManager.mayUseLaunchAuthLink
          ? _appLinks!.getInitialLink()
          : Future<Uri?>.value(null));
      if (!mounted) return;
      final routed = GoRouterState.of(context).uri;
      // Logout can happen while the platform lookup is pending. Current route
      // payloads and newly received stream events remain eligible independently.
      final uri = VerifyAnyLink.hasAuthPayload(routed)
          ? routed
          : authManager.mayUseLaunchAuthLink ? initial : null;
      if (kDebugMode) _debugLog('[VerifyAnyLink] initial link: $uri');
      if (uri != null) {
        hasAuthPayload = VerifyAnyLink.hasAuthPayload(uri);
        await _handleUri(uri);
      }
    } catch (e, st) {
      if (kDebugMode)
        _debugLog('[VerifyAnyLink] getInitialLink error: $e\n$st');
    }

    if (!mounted) return;
    if (!_navigated) {
      widget.onInitialLinkChecked?.call(hasAuthPayload || _authLinksPending > 0);
    }
  }

  Future<void> _handleUri(Uri uri) async {
    if (AppStateNotifier.instance.unlock.inDecoy ||
        !VerifyAnyLink.hasAuthPayload(uri)) return;
    final linkKey = uri.toString();
    if (_linksCompleted.contains(linkKey) || !_linksInFlight.add(linkKey)) {
      if (kDebugMode) _debugLog('[VerifyAnyLink] duplicate link skipped: $uri');
      return;
    }

    var completed = false;
    _authLinksPending++;
    final p = VerifyAnyLink.authParameters(uri);
    final tokenHash = p['token_hash'] ?? p['tokenHash'] ?? p['token'];
    final refreshToken = p['refresh_token'] ?? p['refreshToken'];
    final accessToken = p['access_token'] ?? p['accessToken'];
    final t = (p['type'] ?? 'signup').toLowerCase();
    final isRecoveryLink = t == 'recovery';

    final typeMap = <String, OtpType>{
      'signup': OtpType.signup,
      'magiclink': OtpType.magiclink,
      'recovery': OtpType.recovery,
      'invite': OtpType.invite,
      'email_change': OtpType.emailChange,
    };
    final otpType = typeMap[t] ?? OtpType.signup;
    final client = Supabase.instance.client;

    try {
      AuthResponse? res;

      if (tokenHash != null && tokenHash.isNotEmpty) {
        res = await client.auth.verifyOTP(
          type: otpType,
          tokenHash: tokenHash,
        );
      } else if (refreshToken != null && refreshToken.isNotEmpty) {
        await client.auth.setSession(refreshToken);
      } else if (accessToken != null && accessToken.isNotEmpty) {
        await client.auth.getSessionFromUrl(uri);
      } else {
        if (kDebugMode) {
          _debugLog('[VerifyAnyLink] no auth payload in link: $uri');
        }
        return;
      }

      // let session hydrate
      await Future.delayed(const Duration(milliseconds: 300));
      final session = client.auth.currentSession ?? res?.session;
      final ok = session != null || res?.user != null;
      if (!ok || !mounted || AppStateNotifier.instance.unlock.inDecoy) return;
      AppStateNotifier.instance.update(
          DecoyWalletAppSupabaseUser(client.auth.currentUser));
      completed = true;

      if (isRecoveryLink) {
        final unlock = AppStateNotifier.instance.unlock;
        if (!unlock.allowRecovery(unlock.attempt)) return;
        if (!_navigated && mounted) {
          _navigated = true;
          if (kDebugMode) {
            _debugLog(
                '[VerifyAnyLink] verified recovery link; routing updatePasswordPage');
          }
          context.goNamed(UpdatePasswordPageWidget.routeName);
        }
        return;
      }

      // Optional: promote pending_email -> email on your profile row
      try {
        final uid = client.auth.currentUser?.id;
        final nowEmail =
            (client.auth.currentUser?.email ?? '').trim().toLowerCase();
        if (uid != null && nowEmail.isNotEmpty) {
          // maybeSingle() can return null; keep everything nullable-safe
          final dynamic profDyn = await client
              .from('profiles') // <-- change table name if yours differs
              .select()
              .eq('id', uid)
              .maybeSingle();

          final Map<String, dynamic>? prof =
              (profDyn is Map<String, dynamic>) ? profDyn : null;

          String pending = '';
          final dynamic val = prof?['pending_email']; // null-safe index
          if (val is String) {
            pending = val.trim().toLowerCase();
          }

          if (pending.isNotEmpty && pending == nowEmail) {
            await client.from('profiles').update({
              'email': nowEmail,
              'pending_email': null,
              'email_verified': true,
            }).eq('id', uid);
          }
        }
      } catch (e, st) {
        if (kDebugMode)
          _debugLog('[VerifyAnyLink] profile promote err: $e\n$st');
      }

      if (!_navigated && mounted) {
        _navigated = true;
        if (kDebugMode) {
          _debugLog('[VerifyAnyLink] verified link; routing authentication');
        }
        context.goNamed(AuthRouterWidget.routeName);
      }
    } on AuthApiException catch (e, st) {
      if (e.code == 'otp_expired' || e.statusCode == 403) {
        completed = true;
        if (kDebugMode) _debugLog('[VerifyAnyLink] expired/403: $e\n$st');
        return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } catch (e, st) {
      if (!mounted) return;
      if (kDebugMode) _debugLog('[VerifyAnyLink] ERROR: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      _authLinksPending--;
      _linksInFlight.remove(linkKey);
      if (completed) {
        _linksCompleted.add(linkKey);
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: widget.width, height: widget.height);
  }
}
