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
import 'package:go_router/go_router.dart';
import 'dart:async';

/// Listens for any incoming deep link and verifies the Supabase OTP.
/// Accepts optional width/height so FlutterFlow's generated calls compile.
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
      if (uri != null) _handleUri(uri);
    } catch (_) {}

    // Handle links while the app is running.
    _sub = _appLinks!.uriLinkStream.listen(
      _handleUri,
      onError: (_) {},
    );
  }

  Future<void> _handleUri(Uri uri) async {
    final p = uri.queryParameters;
    final tokenHash = p['token_hash'] ?? p['tokenHash'];
    final t = (p['type'] ?? 'signup').toLowerCase();
    if (tokenHash == null || tokenHash.isEmpty) return;

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
      final res =
          await client.auth.verifyOTP(type: otpType, tokenHash: tokenHash);

      await Future.delayed(
          const Duration(milliseconds: 300)); // hydrate session

      final session = client.auth.currentSession ?? res.session;
      final ok = session != null || res.user != null;
      if (!mounted || _navigated) return;

      if (ok) {
        _navigated = true;
        // IMPORTANT: must match your FF route key exactly
        context.goNamed('subscriptionOptions');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification failed.')),
        );
      }
    } catch (e) {
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
  Widget build(BuildContext context) {
    // Keep it invisible but sized if FF passes width/height.
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: const SizedBox.shrink(),
    );
  }
}
