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

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
// If this import causes a compile error in your project, delete it —
// FlutterFlow's flutter_flow_util.dart already extends BuildContext with goNamed/pushNamed.
import 'package:go_router/go_router.dart';
import 'dart:async';

/// Listens for confirm-email deep links and verifies the Supabase OTP.
/// No parameters — place once on the Login page.
class VerifyAnyLink extends StatefulWidget {
  const VerifyAnyLink({Key? key}) : super(key: key);
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
      if (uri != null) _handleUri(uri);
    } catch (e) {
      debugPrint('getInitialLink error: $e');
    }

    // Handle links while the app is running.
    _sub = _appLinks!.uriLinkStream.listen(
      _handleUri,
      onError: (e) => debugPrint('uriLinkStream error: $e'),
    );
  }

  Future<void> _handleUri(Uri uri) async {
    debugPrint('🔗 Incoming URI: $uri');

    // Only react to your app scheme + confirm-email destination.
    // Adjust these if your scheme/host/path differ.
    if (uri.scheme != 'decoywalletapp') return;
    final isConfirmHost = (uri.host == 'confirm-email');
    final isConfirmPath = (uri.path == '/confirm-email');
    if (!isConfirmHost && !isConfirmPath) return;

    final p = uri.queryParameters;
    final tokenHash = p['token_hash'] ?? p['tokenHash'];
    final t = (p['type'] ?? 'signup').toLowerCase();
    if (t != 'signup') return; // only handle signup links
    if (tokenHash == null || tokenHash.isEmpty) return;

    // Map the Supabase OTP type
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
      final res = await client.auth.verifyOTP(
        type: otpType,
        tokenHash: tokenHash,
      );

      // Give Supabase a beat to hydrate session for guarded routes.
      await Future.delayed(const Duration(milliseconds: 300));

      final session = client.auth.currentSession ?? res.session;
      final ok = session != null || res.user != null;
      if (!mounted || _navigated) return;

      if (ok) {
        _navigated = true;
        debugPrint('✅ OTP verified; navigating to SubscriptionOptions');
        // IMPORTANT: use the EXACT route key from FlutterFlow Routes (case-sensitive).
        context.goNamed('subscriptionOptions');
      } else {
        debugPrint('❌ OTP verification failed');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification failed.')),
        );
      }
    } catch (e) {
      debugPrint('⚠️ verifyOTP error: $e');
      if (!mounted) return;
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
  Widget build(BuildContext context) => const SizedBox.shrink();
}
