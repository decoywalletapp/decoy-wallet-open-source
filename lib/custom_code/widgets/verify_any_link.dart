// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

/// Listens for any incoming deep link and verifies the Supabase OTP.
/// Keep this mounted on the very first page that opens (e.g. Login).
class VerifyAnyLink extends StatefulWidget {
  final double? width;
  final double? height;
  const VerifyAnyLink({Key? key, this.width, this.height}) : super(key: key);

  @override
  State<VerifyAnyLink> createState() => _VerifyAnyLinkState();
}

class _VerifyAnyLinkState extends State<VerifyAnyLink> {
  AppLinks? _appLinks;
  StreamSubscription<Uri>? _sub;
  bool _navigated = false; // guard against double nav

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _appLinks = AppLinks();

    // Handle a link that launched the app (cold start).
    try {
      final uri = await _appLinks!.getInitialLink();
      if (kDebugMode) debugPrint('[VerifyAnyLink] initial link: $uri');
      if (uri != null) _handleUri(uri);
    } catch (e, st) {
      if (kDebugMode)
        debugPrint('[VerifyAnyLink] getInitialLink error: $e\n$st');
    }

    // Handle links while the app is running.
    _sub = _appLinks!.uriLinkStream.listen(
      (uri) {
        if (kDebugMode) debugPrint('[VerifyAnyLink] stream link: $uri');
        _handleUri(uri);
      },
      onError: (e) {
        if (kDebugMode) debugPrint('[VerifyAnyLink] stream error: $e');
      },
    );
  }

  Future<void> _handleUri(Uri uri) async {
    // Accept either `token_hash` or `tokenHash`
    final p = uri.queryParameters;
    final tokenHash = p['token_hash'] ?? p['tokenHash'];
    final t = (p['type'] ?? 'signup').toLowerCase();

    if (kDebugMode) {
      debugPrint('[VerifyAnyLink] handling: $uri');
      debugPrint('[VerifyAnyLink]   tokenHash: $tokenHash | type: $t');
    }

    if (tokenHash == null || tokenHash.isEmpty) {
      if (kDebugMode)
        debugPrint('[VerifyAnyLink]   -> no token_hash, ignoring');
      return;
    }

    final typeMap = <String, OtpType>{
      'signup': OtpType.signup,
      'magiclink': OtpType.magiclink,
      'recovery': OtpType.recovery,
      'invite': OtpType.invite,
      'email_change': OtpType.emailChange,
    };
    final otpType = typeMap[t] ?? OtpType.signup;

    try {
      final client = Supabase.instance.client;

      if (kDebugMode) debugPrint('[VerifyAnyLink] calling verifyOTP...');
      final res = await client.auth.verifyOTP(
        type: otpType,
        tokenHash: tokenHash,
      );
      if (kDebugMode) {
        debugPrint('[VerifyAnyLink] verifyOTP -> '
            'user? ${res.user != null}, session? ${res.session != null}');
      }

      // Give time for the SDK to hydrate the current session.
      await Future.delayed(const Duration(milliseconds: 300));

      final session = client.auth.currentSession ?? res.session;
      final ok = session != null || res.user != null;

      if (!mounted || _navigated) {
        if (kDebugMode)
          debugPrint(
              '[VerifyAnyLink] not mounted or already navigated, return');
        return;
      }

      if (ok) {
        _navigated = true;
        if (kDebugMode)
          debugPrint('[VerifyAnyLink] nav -> subscriptionOptions');
        // IMPORTANT: this must match your FlutterFlow named route exactly
        context.goNamed('subscriptionOptions');
      } else {
        if (!mounted) return;
        if (kDebugMode)
          debugPrint('[VerifyAnyLink] verification failed (no session)');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification failed.')),
        );
      }
    } catch (e, st) {
      if (!mounted) return;
      if (kDebugMode) debugPrint('[VerifyAnyLink] ERROR: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Invisible placeholder so FlutterFlow can place the widget.
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: const SizedBox.shrink(),
    );
  }
}
