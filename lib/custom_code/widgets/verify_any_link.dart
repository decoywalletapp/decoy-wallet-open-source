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
import '/auth/auth_link_flow.dart';
import '/auth/auth_link_service.dart';

class VerifyAnyLink extends StatefulWidget {
  static int _listeners = 0;
  static bool get hasListener => _listeners > 0;
  final double? width;
  final double? height;
  final Uri? routedUri;
  final void Function(bool hasAuthPayload)? onInitialLinkChecked;
  const VerifyAnyLink({Key? key, this.width, this.height,
    this.onInitialLinkChecked, this.routedUri}) : super(key: key);

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
    return AuthLinkRequest.hasPayload(uri);
  }

  @override
  State<VerifyAnyLink> createState() => _VerifyAnyLinkState();
}

class _VerifyAnyLinkState extends State<VerifyAnyLink> {
  AppLinks? _appLinks;
  StreamSubscription<Uri>? _sub;
  bool _navigated = false;
  int _authLinksPending = 0;
  final Set<String> _linksInFlight = <String>{};

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  @override
  void initState() {
    super.initState();
    VerifyAnyLink._listeners++;
    _init();
  }

  @override
  void didUpdateWidget(covariant VerifyAnyLink oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.routedUri != null && widget.routedUri != oldWidget.routedUri) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleUri(widget.routedUri!);
      });
    }
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
      if (kDebugMode) _debugLog('[VerifyAnyLink] initial link checked');
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
    if (!mounted || AppStateNotifier.instance.unlock.inDecoy ||
        !VerifyAnyLink.hasAuthPayload(uri)) return;
    if (SupaFlow.authLinks.hasCompleted(uri)) return;

    // A retained login page can receive the plugin event before iOS routes the
    // same link. Route first so that navigation cannot dismiss its confirmation.
    final routed = GoRouterState.of(context).uri;
    bool sameRequest;
    try {
      sameRequest = AuthLinkRequest.parse(routed).fingerprint ==
          AuthLinkRequest.parse(uri).fingerprint;
    } catch (_) {
      sameRequest = routed.query == uri.query && routed.fragment == uri.fragment;
    }
    if (!sameRequest) {
      context.go(Uri(path: LoginPageWidget.routePath,
        query: uri.hasQuery ? uri.query : null,
        fragment: uri.hasFragment ? uri.fragment : null).toString());
      return;
    }
    final linkKey = uri.toString();
    if (SupaFlow.authLinks.hasCompleted(uri) || !_linksInFlight.add(linkKey)) {
      if (kDebugMode) _debugLog('[VerifyAnyLink] duplicate link skipped');
      return;
    }

    _authLinksPending++;
    final client = Supabase.instance.client;

    try {
      final accepted = await acceptAuthLink(context, uri);
      if (accepted == null || !SupaFlow.authLinks.isCurrent(accepted) ||
          !mounted || AppStateNotifier.instance.unlock.inDecoy) return;
      AppStateNotifier.instance.update(
          DecoyWalletAppSupabaseUser(client.auth.currentUser));

      if (accepted.request.isRecovery) {
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

          if (pending.isNotEmpty && pending == nowEmail &&
              SupaFlow.authLinks.isCurrent(accepted)) {
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

      if (!_navigated && mounted && SupaFlow.authLinks.isCurrent(accepted) &&
          !AppStateNotifier.instance.unlock.inDecoy) {
        _navigated = true;
        if (kDebugMode) {
          _debugLog('[VerifyAnyLink] verified link; routing authentication');
        }
        context.goNamed(AuthRouterWidget.routeName);
      }
    } on AuthLinkSignInRequired catch (e) {
      if (!mounted || AppStateNotifier.instance.unlock.inDecoy) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This sign-in link could not be verified. Request a new link.')),
      );
    } finally {
      _authLinksPending--;
      _linksInFlight.remove(linkKey);
    }
  }

  @override
  void dispose() {
    VerifyAnyLink._listeners--;
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: widget.width, height: widget.height);
  }
}
